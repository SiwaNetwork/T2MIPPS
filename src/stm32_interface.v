// =============================================================================
// STM32 Interface Module
// =============================================================================
// Description: Interface module for communication with STM32F302C8T6
// Provides SPI slave interface for configuration and monitoring
// =============================================================================

module stm32_interface (
    input  wire        clk,
    input  wire        rst_n,
    
    // SPI Slave Interface
    input  wire        spi_sclk,      // SPI clock from STM32
    input  wire        spi_mosi,      // Master Out Slave In
    output reg         spi_miso,      // Master In Slave Out
    input  wire        spi_cs_n,      // Chip Select (active low)
    
    // Interrupt to STM32
    output reg         irq_n,         // Interrupt request (active low)
    
    // Internal bus interface
    output reg         bus_write,     // Write strobe
    output reg         bus_read,      // Read strobe
    output reg  [15:0] bus_addr,      // Address bus
    output reg  [31:0] bus_wdata,     // Write data
    input  wire [31:0] bus_rdata,     // Read data
    input  wire        bus_ready,     // Bus ready signal
    
    // Status inputs from system
    input  wire        pps_pulse,
    input  wire        sync_locked,
    input  wire        dpll_locked,
    input  wire [39:0] current_seconds,
    input  wire [31:0] current_subseconds,
    input  wire [31:0] phase_error,
    input  wire [31:0] frequency_error,
    
    // Configuration outputs
    output reg  [31:0] cable_delay_ns,     // Cable delay compensation
    output reg  [31:0] antenna_delay_ns,   // Antenna delay compensation
    output reg  [15:0] dpll_kp,           // DPLL proportional gain
    output reg  [15:0] dpll_ki,           // DPLL integral gain
    output reg         kalman_enable,      // Enable Kalman filter
    output reg  [31:0] kalman_q,          // Process noise
    output reg  [31:0] kalman_r,          // Measurement noise
    
    // GPS/GLONASS interface control
    output reg         gnss_enable,        // Enable GNSS receiver
    output reg  [2:0]  gnss_mode,         // GNSS mode selection
    output reg         gnss_reset_n       // GNSS module reset
);

// =============================================================================
// SPI Protocol Definition
// =============================================================================
// Command format (16 bits):
// [15]    - R/W bit (0=Write, 1=Read)
// [14:12] - Command type
// [11:0]  - Address/Parameter
//
// Command types:
// 000 - Register access
// 001 - Status read
// 010 - Configuration write
// 011 - Delay compensation
// 100 - GNSS control
// 101 - DPLL parameters
// 110 - Kalman filter control
// 111 - System control

// =============================================================================
// Internal signals
// =============================================================================

// SPI synchronization
reg  [2:0] sclk_sync;
reg  [2:0] cs_sync;
reg  [2:0] mosi_sync;
wire       sclk_rise;
wire       sclk_fall;
wire       cs_active;

// SPI state machine
reg  [3:0] spi_state;
reg  [4:0] bit_counter;
reg  [15:0] cmd_reg;
reg  [31:0] data_reg;
reg  [31:0] tx_data;

// Command decoding
wire       cmd_read;
wire [2:0] cmd_type;
wire [11:0] cmd_addr;

// Internal registers
reg  [31:0] status_reg;
reg  [31:0] control_reg;
reg  [31:0] timestamp_capture_sec;
reg  [31:0] timestamp_capture_subsec;
reg  [31:0] error_counter;
reg  [31:0] pps_counter;

// Interrupt control
reg        irq_enable;
reg        irq_on_pps;
reg        irq_on_error;
reg  [7:0] irq_status;

// =============================================================================
// SPI Clock Domain Crossing
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sclk_sync <= 3'b111;
        cs_sync <= 3'b111;
        mosi_sync <= 3'b0;
    end else begin
        sclk_sync <= {sclk_sync[1:0], spi_sclk};
        cs_sync <= {cs_sync[1:0], spi_cs_n};
        mosi_sync <= {mosi_sync[1:0], spi_mosi};
    end
end

assign sclk_rise = (sclk_sync[2:1] == 2'b01);
assign sclk_fall = (sclk_sync[2:1] == 2'b10);
assign cs_active = !cs_sync[2];

// =============================================================================
// SPI State Machine
// =============================================================================

localparam SPI_IDLE     = 4'd0;
localparam SPI_CMD_H    = 4'd1;
localparam SPI_CMD_L    = 4'd2;
localparam SPI_ADDR_H   = 4'd3;
localparam SPI_ADDR_L   = 4'd4;
localparam SPI_DATA     = 4'd5;
localparam SPI_EXECUTE  = 4'd6;
localparam SPI_WAIT     = 4'd7;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        spi_state <= SPI_IDLE;
        bit_counter <= 5'd0;
        cmd_reg <= 16'd0;
        data_reg <= 32'd0;
        tx_data <= 32'd0;
        spi_miso <= 1'b0;
        
        bus_write <= 1'b0;
        bus_read <= 1'b0;
        bus_addr <= 16'd0;
        bus_wdata <= 32'd0;
        
    end else begin
        // Default values
        bus_write <= 1'b0;
        bus_read <= 1'b0;
        
        if (!cs_active) begin
            // CS deasserted, return to idle
            spi_state <= SPI_IDLE;
            bit_counter <= 5'd0;
            spi_miso <= 1'b0;
            
        end else begin
            case (spi_state)
                
                SPI_IDLE: begin
                    if (cs_active) begin
                        spi_state <= SPI_CMD_H;
                        bit_counter <= 5'd0;
                    end
                end
                
                SPI_CMD_H: begin
                    if (sclk_rise) begin
                        cmd_reg[15:8] <= {cmd_reg[14:8], mosi_sync[2]};
                        bit_counter <= bit_counter + 1;
                        
                        if (bit_counter == 7) begin
                            spi_state <= SPI_CMD_L;
                            bit_counter <= 5'd0;
                        end
                    end
                end
                
                SPI_CMD_L: begin
                    if (sclk_rise) begin
                        cmd_reg[7:0] <= {cmd_reg[6:0], mosi_sync[2]};
                        bit_counter <= bit_counter + 1;
                        
                        if (bit_counter == 7) begin
                            // Command received, decode it
                            if (cmd_type == 3'b001 || cmd_read) begin
                                // Read operation, prepare data
                                spi_state <= SPI_EXECUTE;
                            end else begin
                                // Write operation, get data
                                spi_state <= SPI_DATA;
                                bit_counter <= 5'd0;
                            end
                        end
                    end
                end
                
                SPI_DATA: begin
                    if (sclk_rise) begin
                        data_reg <= {data_reg[30:0], mosi_sync[2]};
                        bit_counter <= bit_counter + 1;
                        
                        if (bit_counter == 31) begin
                            spi_state <= SPI_EXECUTE;
                        end
                    end
                    
                    if (sclk_fall && cmd_read) begin
                        // Output read data
                        spi_miso <= tx_data[31-bit_counter];
                    end
                end
                
                SPI_EXECUTE: begin
                    // Execute command
                    case (cmd_type)
                        3'b000: begin // Register access
                            if (cmd_read) begin
                                bus_read <= 1'b1;
                                bus_addr <= {4'd0, cmd_addr};
                                spi_state <= SPI_WAIT;
                            end else begin
                                bus_write <= 1'b1;
                                bus_addr <= {4'd0, cmd_addr};
                                bus_wdata <= data_reg;
                                spi_state <= SPI_IDLE;
                            end
                        end
                        
                        3'b001: begin // Status read
                            case (cmd_addr[3:0])
                                4'd0: tx_data <= status_reg;
                                4'd1: tx_data <= {24'd0, current_seconds[7:0]};
                                4'd2: tx_data <= current_seconds[39:8];
                                4'd3: tx_data <= current_subseconds;
                                4'd4: tx_data <= phase_error;
                                4'd5: tx_data <= frequency_error;
                                4'd6: tx_data <= error_counter;
                                4'd7: tx_data <= pps_counter;
                                4'd8: tx_data <= timestamp_capture_sec;
                                4'd9: tx_data <= timestamp_capture_subsec;
                                default: tx_data <= 32'd0;
                            endcase
                            spi_state <= SPI_DATA;
                            bit_counter <= 5'd0;
                        end
                        
                        3'b010: begin // Configuration write
                            case (cmd_addr[3:0])
                                4'd0: control_reg <= data_reg;
                                4'd1: irq_enable <= data_reg[0];
                                4'd2: {irq_on_error, irq_on_pps} <= data_reg[1:0];
                                default: ;
                            endcase
                            spi_state <= SPI_IDLE;
                        end
                        
                        3'b011: begin // Delay compensation
                            case (cmd_addr[1:0])
                                2'd0: cable_delay_ns <= data_reg;
                                2'd1: antenna_delay_ns <= data_reg;
                                default: ;
                            endcase
                            spi_state <= SPI_IDLE;
                        end
                        
                        3'b100: begin // GNSS control
                            case (cmd_addr[1:0])
                                2'd0: gnss_enable <= data_reg[0];
                                2'd1: gnss_mode <= data_reg[2:0];
                                2'd2: gnss_reset_n <= data_reg[0];
                                default: ;
                            endcase
                            spi_state <= SPI_IDLE;
                        end
                        
                        3'b101: begin // DPLL parameters
                            case (cmd_addr[1:0])
                                2'd0: dpll_kp <= data_reg[15:0];
                                2'd1: dpll_ki <= data_reg[15:0];
                                default: ;
                            endcase
                            spi_state <= SPI_IDLE;
                        end
                        
                        3'b110: begin // Kalman filter
                            case (cmd_addr[1:0])
                                2'd0: kalman_enable <= data_reg[0];
                                2'd1: kalman_q <= data_reg;
                                2'd2: kalman_r <= data_reg;
                                default: ;
                            endcase
                            spi_state <= SPI_IDLE;
                        end
                        
                        default: begin
                            spi_state <= SPI_IDLE;
                        end
                    endcase
                end
                
                SPI_WAIT: begin
                    if (bus_ready) begin
                        tx_data <= bus_rdata;
                        spi_state <= SPI_DATA;
                        bit_counter <= 5'd0;
                    end
                end
                
                default: begin
                    spi_state <= SPI_IDLE;
                end
            endcase
        end
    end
end

// =============================================================================
// Command decoding
// =============================================================================

assign cmd_read = cmd_reg[15];
assign cmd_type = cmd_reg[14:12];
assign cmd_addr = cmd_reg[11:0];

// =============================================================================
// Status register generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        status_reg <= 32'd0;
    end else begin
        status_reg <= {
            16'd0,              // Reserved
            irq_status,         // IRQ status bits
            2'd0,               // Reserved
            gnss_enable,        // GNSS enabled
            kalman_enable,      // Kalman enabled
            dpll_locked,        // DPLL locked
            sync_locked,        // T2MI sync locked
            pps_pulse,          // PPS active
            1'b1                // System ready
        };
    end
end

// =============================================================================
// PPS timestamp capture
// =============================================================================

reg pps_pulse_d1, pps_pulse_d2;
wire pps_edge;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_pulse_d1 <= 1'b0;
        pps_pulse_d2 <= 1'b0;
    end else begin
        pps_pulse_d1 <= pps_pulse;
        pps_pulse_d2 <= pps_pulse_d1;
    end
end

assign pps_edge = pps_pulse_d1 && !pps_pulse_d2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timestamp_capture_sec <= 32'd0;
        timestamp_capture_subsec <= 32'd0;
        pps_counter <= 32'd0;
    end else begin
        if (pps_edge) begin
            timestamp_capture_sec <= current_seconds[31:0];
            timestamp_capture_subsec <= current_subseconds;
            pps_counter <= pps_counter + 1;
        end
    end
end

// =============================================================================
// Interrupt generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        irq_n <= 1'b1;
        irq_status <= 8'd0;
    end else begin
        // Update IRQ status
        if (pps_edge && irq_on_pps) begin
            irq_status[0] <= 1'b1;
        end
        
        if ((phase_error > 32'd10000) && irq_on_error) begin
            irq_status[1] <= 1'b1;
        end
        
        // Clear on read
        if (cmd_type == 3'b001 && cmd_addr == 12'd0 && spi_state == SPI_EXECUTE) begin
            irq_status <= 8'd0;
        end
        
        // Generate interrupt
        if (irq_enable && |irq_status) begin
            irq_n <= 1'b0;
        end else begin
            irq_n <= 1'b1;
        end
    end
end

// =============================================================================
// Error counting
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        error_counter <= 32'd0;
    end else begin
        if (!sync_locked || !dpll_locked) begin
            error_counter <= error_counter + 1;
        end
        
        // Clear on command
        if (cmd_type == 3'b111 && cmd_addr == 12'd0 && spi_state == SPI_EXECUTE) begin
            error_counter <= 32'd0;
        end
    end
end

endmodule