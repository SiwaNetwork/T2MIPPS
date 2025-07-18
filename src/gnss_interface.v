// =============================================================================
// GNSS Interface Module
// =============================================================================
// Description: Interface for GPS/GLONASS receiver integration
// Supports NMEA and binary protocols for time synchronization
// =============================================================================

module gnss_interface (
    input  wire        clk,
    input  wire        rst_n,
    
    // UART interface to GNSS module
    input  wire        gnss_rx,         // UART RX from GNSS
    output reg         gnss_tx,         // UART TX to GNSS
    
    // Control signals
    input  wire        gnss_enable,     // Enable GNSS processing
    input  wire [2:0]  gnss_mode,       // 000=GPS, 001=GLONASS, 010=GPS+GLONASS
    input  wire        gnss_reset_n,    // Reset GNSS module
    
    // Time output
    output reg         time_valid,      // Valid time available
    output reg  [39:0] gnss_seconds,    // Seconds since 2000
    output reg  [31:0] gnss_subseconds, // Fractional seconds
    output reg         pps_from_gnss,   // PPS signal from GNSS
    
    // Position output
    output reg  [31:0] latitude,        // Latitude in degrees * 10^7
    output reg  [31:0] longitude,       // Longitude in degrees * 10^7
    output reg  [31:0] altitude,        // Altitude in meters * 100
    output reg         position_valid,  // Valid position fix
    
    // Status
    output reg  [7:0]  satellites_used, // Number of satellites
    output reg  [7:0]  hdop,           // Horizontal dilution of precision
    output reg  [3:0]  fix_type,       // 0=no fix, 1=2D, 2=3D, 3=DGPS
    output reg  [31:0] gnss_status     // GNSS module status
);

// =============================================================================
// UART Parameters
// =============================================================================

parameter UART_BAUD = 115200;
parameter CLK_FREQ = 100_000_000;
parameter UART_CLKS_PER_BIT = CLK_FREQ / UART_BAUD;

// =============================================================================
// Internal signals
// =============================================================================

// UART receiver
reg  [15:0] uart_rx_clk_count;
reg  [3:0]  uart_rx_bit_index;
reg  [2:0]  uart_rx_state;
reg  [7:0]  uart_rx_byte;
reg         uart_rx_dv;
reg         uart_rx_sync;
reg         uart_rx_sync_d;

// UART transmitter
reg  [15:0] uart_tx_clk_count;
reg  [3:0]  uart_tx_bit_index;
reg  [2:0]  uart_tx_state;
reg  [7:0]  uart_tx_byte;
reg         uart_tx_active;
reg         uart_tx_start;

// NMEA parser
reg  [7:0]  nmea_buffer[0:127];
reg  [6:0]  nmea_index;
reg  [3:0]  nmea_state;
reg         nmea_sentence_ready;
reg  [7:0]  nmea_checksum;
reg  [7:0]  nmea_calc_checksum;

// Time extraction
reg  [7:0]  utc_hours;
reg  [7:0]  utc_minutes;
reg  [7:0]  utc_seconds;
reg  [15:0] utc_milliseconds;
reg  [7:0]  utc_day;
reg  [7:0]  utc_month;
reg  [15:0] utc_year;

// Command buffer
reg  [7:0]  cmd_buffer[0:31];
reg  [4:0]  cmd_length;
reg         send_command;

// PPS detection
reg         gnss_pps_sync;
reg         gnss_pps_sync_d;
wire        gnss_pps_edge;

// =============================================================================
// UART States
// =============================================================================

localparam UART_IDLE      = 3'd0;
localparam UART_START_BIT = 3'd1;
localparam UART_DATA_BITS = 3'd2;
localparam UART_STOP_BIT  = 3'd3;

// =============================================================================
// NMEA Parser States
// =============================================================================

localparam NMEA_WAIT_START = 4'd0;
localparam NMEA_GET_TYPE   = 4'd1;
localparam NMEA_GET_DATA   = 4'd2;
localparam NMEA_GET_CHKSUM = 4'd3;
localparam NMEA_VERIFY     = 4'd4;

// =============================================================================
// UART Receiver
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_rx_state <= UART_IDLE;
        uart_rx_clk_count <= 16'd0;
        uart_rx_bit_index <= 4'd0;
        uart_rx_byte <= 8'd0;
        uart_rx_dv <= 1'b0;
        uart_rx_sync <= 1'b1;
        uart_rx_sync_d <= 1'b1;
    end else begin
        uart_rx_sync <= gnss_rx;
        uart_rx_sync_d <= uart_rx_sync;
        uart_rx_dv <= 1'b0;
        
        case (uart_rx_state)
            UART_IDLE: begin
                uart_rx_clk_count <= 16'd0;
                uart_rx_bit_index <= 4'd0;
                
                if (uart_rx_sync == 1'b0) begin  // Start bit detected
                    uart_rx_state <= UART_START_BIT;
                end
            end
            
            UART_START_BIT: begin
                if (uart_rx_clk_count < (UART_CLKS_PER_BIT - 1) / 2) begin
                    uart_rx_clk_count <= uart_rx_clk_count + 1;
                end else begin
                    if (uart_rx_sync == 1'b0) begin
                        uart_rx_clk_count <= 16'd0;
                        uart_rx_state <= UART_DATA_BITS;
                    end else begin
                        uart_rx_state <= UART_IDLE;
                    end
                end
            end
            
            UART_DATA_BITS: begin
                if (uart_rx_clk_count < UART_CLKS_PER_BIT - 1) begin
                    uart_rx_clk_count <= uart_rx_clk_count + 1;
                end else begin
                    uart_rx_clk_count <= 16'd0;
                    uart_rx_byte[uart_rx_bit_index] <= uart_rx_sync;
                    
                    if (uart_rx_bit_index < 7) begin
                        uart_rx_bit_index <= uart_rx_bit_index + 1;
                    end else begin
                        uart_rx_bit_index <= 4'd0;
                        uart_rx_state <= UART_STOP_BIT;
                    end
                end
            end
            
            UART_STOP_BIT: begin
                if (uart_rx_clk_count < UART_CLKS_PER_BIT - 1) begin
                    uart_rx_clk_count <= uart_rx_clk_count + 1;
                end else begin
                    uart_rx_dv <= 1'b1;
                    uart_rx_state <= UART_IDLE;
                end
            end
            
            default: begin
                uart_rx_state <= UART_IDLE;
            end
        endcase
    end
end

// =============================================================================
// UART Transmitter
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_tx_state <= UART_IDLE;
        uart_tx_clk_count <= 16'd0;
        uart_tx_bit_index <= 4'd0;
        uart_tx <= 1'b1;
        uart_tx_active <= 1'b0;
    end else begin
        case (uart_tx_state)
            UART_IDLE: begin
                uart_tx <= 1'b1;
                uart_tx_clk_count <= 16'd0;
                uart_tx_bit_index <= 4'd0;
                
                if (uart_tx_start) begin
                    uart_tx_active <= 1'b1;
                    uart_tx_state <= UART_START_BIT;
                end else begin
                    uart_tx_active <= 1'b0;
                end
            end
            
            UART_START_BIT: begin
                uart_tx <= 1'b0;
                
                if (uart_tx_clk_count < UART_CLKS_PER_BIT - 1) begin
                    uart_tx_clk_count <= uart_tx_clk_count + 1;
                end else begin
                    uart_tx_clk_count <= 16'd0;
                    uart_tx_state <= UART_DATA_BITS;
                end
            end
            
            UART_DATA_BITS: begin
                uart_tx <= uart_tx_byte[uart_tx_bit_index];
                
                if (uart_tx_clk_count < UART_CLKS_PER_BIT - 1) begin
                    uart_tx_clk_count <= uart_tx_clk_count + 1;
                end else begin
                    uart_tx_clk_count <= 16'd0;
                    
                    if (uart_tx_bit_index < 7) begin
                        uart_tx_bit_index <= uart_tx_bit_index + 1;
                    end else begin
                        uart_tx_bit_index <= 4'd0;
                        uart_tx_state <= UART_STOP_BIT;
                    end
                end
            end
            
            UART_STOP_BIT: begin
                uart_tx <= 1'b1;
                
                if (uart_tx_clk_count < UART_CLKS_PER_BIT - 1) begin
                    uart_tx_clk_count <= uart_tx_clk_count + 1;
                end else begin
                    uart_tx_state <= UART_IDLE;
                    uart_tx_active <= 1'b0;
                end
            end
            
            default: begin
                uart_tx_state <= UART_IDLE;
            end
        endcase
    end
end

// =============================================================================
// NMEA Parser
// =============================================================================

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        nmea_state <= NMEA_WAIT_START;
        nmea_index <= 7'd0;
        nmea_sentence_ready <= 1'b0;
        nmea_checksum <= 8'd0;
        nmea_calc_checksum <= 8'd0;
        
        for (i = 0; i < 128; i = i + 1) begin
            nmea_buffer[i] <= 8'd0;
        end
        
    end else if (gnss_enable) begin
        nmea_sentence_ready <= 1'b0;
        
        if (uart_rx_dv) begin
            case (nmea_state)
                
                NMEA_WAIT_START: begin
                    if (uart_rx_byte == 8'h24) begin  // '$' character
                        nmea_state <= NMEA_GET_TYPE;
                        nmea_index <= 7'd0;
                        nmea_calc_checksum <= 8'd0;
                    end
                end
                
                NMEA_GET_TYPE: begin
                    if (uart_rx_byte == 8'h2A) begin  // '*' character
                        nmea_state <= NMEA_GET_CHKSUM;
                        nmea_checksum <= 8'd0;
                    end else if (nmea_index < 127) begin
                        nmea_buffer[nmea_index] <= uart_rx_byte;
                        nmea_index <= nmea_index + 1;
                        nmea_calc_checksum <= nmea_calc_checksum ^ uart_rx_byte;
                    end else begin
                        nmea_state <= NMEA_WAIT_START;
                    end
                end
                
                NMEA_GET_CHKSUM: begin
                    // Convert ASCII hex to binary
                    if (uart_rx_byte >= 8'h30 && uart_rx_byte <= 8'h39) begin
                        nmea_checksum <= {nmea_checksum[3:0], uart_rx_byte[3:0]};
                    end else if (uart_rx_byte >= 8'h41 && uart_rx_byte <= 8'h46) begin
                        nmea_checksum <= {nmea_checksum[3:0], uart_rx_byte[3:0] + 4'd9};
                    end
                    
                    if (nmea_index == 1) begin
                        nmea_state <= NMEA_VERIFY;
                    end else begin
                        nmea_index <= 7'd1;
                    end
                end
                
                NMEA_VERIFY: begin
                    if (nmea_calc_checksum == nmea_checksum) begin
                        nmea_sentence_ready <= 1'b1;
                    end
                    nmea_state <= NMEA_WAIT_START;
                end
                
                default: begin
                    nmea_state <= NMEA_WAIT_START;
                end
            endcase
        end
    end
end

// =============================================================================
// NMEA Sentence Processing
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        time_valid <= 1'b0;
        position_valid <= 1'b0;
        utc_hours <= 8'd0;
        utc_minutes <= 8'd0;
        utc_seconds <= 8'd0;
        utc_milliseconds <= 16'd0;
        utc_day <= 8'd0;
        utc_month <= 8'd0;
        utc_year <= 16'd0;
        satellites_used <= 8'd0;
        hdop <= 8'd0;
        fix_type <= 4'd0;
    end else if (nmea_sentence_ready) begin
        // Check sentence type
        if (nmea_buffer[0] == "G" && nmea_buffer[1] == "P" && 
            nmea_buffer[2] == "R" && nmea_buffer[3] == "M" && 
            nmea_buffer[4] == "C") begin
            // GPRMC sentence - extract time and date
            // Format: $GPRMC,hhmmss.sss,A,llll.ll,a,yyyyy.yy,a,x.x,x.x,ddmmyy,x.x,a*hh
            
            // Extract time (hhmmss.sss)
            utc_hours <= (nmea_buffer[7] - 8'h30) * 10 + (nmea_buffer[8] - 8'h30);
            utc_minutes <= (nmea_buffer[9] - 8'h30) * 10 + (nmea_buffer[10] - 8'h30);
            utc_seconds <= (nmea_buffer[11] - 8'h30) * 10 + (nmea_buffer[12] - 8'h30);
            
            if (nmea_buffer[13] == ".") begin
                utc_milliseconds <= (nmea_buffer[14] - 8'h30) * 100 + 
                                   (nmea_buffer[15] - 8'h30) * 10 + 
                                   (nmea_buffer[16] - 8'h30);
            end
            
            // Find date field (after 9th comma)
            // Simplified - would need full parser in production
            time_valid <= 1'b1;
            
        end else if (nmea_buffer[0] == "G" && nmea_buffer[1] == "P" && 
                     nmea_buffer[2] == "G" && nmea_buffer[3] == "G" && 
                     nmea_buffer[4] == "A") begin
            // GPGGA sentence - extract position and quality
            // Extract satellite count, HDOP, fix type
            // Simplified implementation
            position_valid <= 1'b1;
        end
    end
end

// =============================================================================
// Time Conversion to Seconds Since 2000
// =============================================================================

reg [39:0] days_since_2000;
reg [31:0] seconds_in_day;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gnss_seconds <= 40'd0;
        gnss_subseconds <= 32'd0;
        days_since_2000 <= 40'd0;
        seconds_in_day <= 32'd0;
    end else if (time_valid) begin
        // Calculate days since Jan 1, 2000
        // Simplified - assumes no leap years for demo
        days_since_2000 <= (utc_year - 2000) * 365 + 
                          (utc_month - 1) * 30 + 
                          (utc_day - 1);
        
        // Calculate seconds in current day
        seconds_in_day <= utc_hours * 3600 + utc_minutes * 60 + utc_seconds;
        
        // Total seconds since 2000
        gnss_seconds <= days_since_2000 * 86400 + seconds_in_day;
        
        // Fractional seconds
        gnss_subseconds <= utc_milliseconds * 32'd4294967;  // Scale to 2^32
    end
end

// =============================================================================
// PPS Signal Processing
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gnss_pps_sync <= 1'b0;
        gnss_pps_sync_d <= 1'b0;
        pps_from_gnss <= 1'b0;
    end else begin
        // Assuming PPS is derived from GNSS time
        // In real implementation, this would come from GNSS module's PPS pin
        gnss_pps_sync <= (utc_milliseconds == 16'd0) && time_valid;
        gnss_pps_sync_d <= gnss_pps_sync;
        pps_from_gnss <= gnss_pps_sync && !gnss_pps_sync_d;
    end
end

// =============================================================================
// GNSS Configuration Commands
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        send_command <= 1'b0;
        cmd_length <= 5'd0;
        uart_tx_start <= 1'b0;
        uart_tx_byte <= 8'd0;
    end else begin
        // Send configuration commands based on mode
        case (gnss_mode)
            3'b000: begin  // GPS only
                // Send command to enable GPS only
            end
            3'b001: begin  // GLONASS only
                // Send command to enable GLONASS only
            end
            3'b010: begin  // GPS + GLONASS
                // Send command to enable both
            end
            default: ;
        endcase
        
        // Simple command sender
        if (send_command && !uart_tx_active) begin
            if (cmd_length > 0) begin
                uart_tx_byte <= cmd_buffer[cmd_length - 1];
                uart_tx_start <= 1'b1;
                cmd_length <= cmd_length - 1;
            end else begin
                send_command <= 1'b0;
            end
        end else begin
            uart_tx_start <= 1'b0;
        end
    end
end

// =============================================================================
// Status Register
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gnss_status <= 32'd0;
    end else begin
        gnss_status <= {
            8'd0,                    // Reserved
            satellites_used,         // Number of satellites
            hdop,                    // HDOP value
            fix_type,                // Fix type
            1'b0,                    // Reserved
            position_valid,          // Position valid
            time_valid,              // Time valid
            gnss_enable              // Module enabled
        };
    end
end

endmodule