// =============================================================================
// CI Interface Module (8-bit EN50221 Implementation)
// =============================================================================
// Description: Common Interface module for CAM with 8-bit data buses
//              Separate input (mdi) and output (mdo) data streams
// Target: Lattice LFE5U-25F-6BG256C
// Author: System
// Date: December 2024
// Version: 1.0
// =============================================================================

module ci_interface_8bit (
    // System Clock and Reset
    input  wire        clk,              // System clock
    input  wire        rst_n,            // Active low reset
    
    // CI Control Interface
    output reg         ci_reset,         // CI reset (active high)
    output reg  [7:0]  ci_a,            // 8-bit address bus
    output reg  [6:0]  ci_a_ext,        // Extended address bits
    inout  wire [7:0]  ci_d,            // 8-bit bidirectional data bus
    output reg         ci_reg_n,         // Register/Attribute Memory Select
    output reg         ci_ce1_n,         // Card Enable (active low)
    output reg         ci_oe_n,          // Output Enable (active low)
    output reg         ci_we_n,          // Write Enable (active low)
    output reg         ci_iord_n,        // I/O Read (active low)
    output reg         ci_iowr_n,        // I/O Write (active low)
    input  wire        ci_ireq_n,        // Interrupt Request (active low)
    input  wire        ci_inpack_n,      // Input Acknowledge (active low)
    output reg         bus_oe,           // Bus output enable
    
    // Media Data Input (from CAM to Host)
    input  wire [7:0]  ci_mdi,           // Media data input
    input  wire        ci_mclki,         // Media clock input
    input  wire        ci_mival,         // Media input valid
    input  wire        ci_mistrt,        // Media input start
    
    // Media Data Output (from Host to CAM)
    output reg  [7:0]  ci_mdo,           // Media data output
    output reg         ci_mclko,         // Media clock output
    output reg         ci_moval,         // Media output valid
    output reg         ci_mostrt,        // Media output start
    
    // T2MI Stream Interface
    input  wire        t2mi_clk,         // T2MI stream clock
    input  wire        t2mi_valid,       // T2MI data valid
    input  wire [7:0]  t2mi_data,        // T2MI data byte
    output wire        t2mi_cam_valid,   // CAM processed data valid
    output wire [7:0]  t2mi_cam_data,    // CAM processed data
    
    // Control and Status
    output wire        cam_present,      // CAM module present
    output wire        cam_initialized,  // CAM initialized and ready
    output wire        cam_error,        // CAM error flag
    output wire [7:0]  cam_status,       // CAM status register
    input  wire        cam_bypass        // Bypass CAM processing
);

// =============================================================================
// Parameters and Constants
// =============================================================================

// EN50221 Command Interface Registers
parameter CIS_BASE_ADDR      = 15'h0000;  // Card Information Structure
parameter CTRL_BASE_ADDR     = 15'h0200;  // Control registers base
parameter STATUS_REG_ADDR    = 15'h0201;  // Status register
parameter SIZE_REG_LS_ADDR   = 15'h0202;  // Buffer size LS
parameter SIZE_REG_MS_ADDR   = 15'h0203;  // Buffer size MS
parameter COMMAND_REG_ADDR   = 15'h0204;  // Command register
parameter DATA_BASE_ADDR     = 15'h0600;  // Data buffer base

// Command/Status bits
parameter CMD_RESET          = 8'h01;  // Reset interface
parameter CMD_SIZE_NEG       = 8'h02;  // Size negotiation
parameter CMD_SW_RESET       = 8'h04;  // Software reset
parameter CMD_DATA_AVAIL     = 8'h80;  // Data available

parameter STAT_FREE          = 8'h01;  // Interface free
parameter STAT_DATA_AVAIL    = 8'h80;  // Data available
parameter STAT_CARD_PRESENT  = 8'h40;  // Card present

// State Machine States
localparam STATE_IDLE        = 4'h0;
localparam STATE_RESET       = 4'h1;
localparam STATE_DETECT      = 4'h2;
localparam STATE_READ_CIS    = 4'h3;
localparam STATE_INIT        = 4'h4;
localparam STATE_SIZE_NEG    = 4'h5;
localparam STATE_READY       = 4'h6;
localparam STATE_STREAM_TX   = 4'h7;
localparam STATE_STREAM_RX   = 4'h8;
localparam STATE_ERROR       = 4'h9;

// =============================================================================
// Internal Signals
// =============================================================================

// State machine
reg [3:0]   current_state;
reg [3:0]   next_state;

// CI bus control
reg [7:0]   ci_data_out;
reg         ci_data_oe;
reg [14:0]  full_address;

// Timing control
reg [7:0]   access_timer;
reg [3:0]   setup_timer;

// CIS data
reg [7:0]   cis_data[0:255];
reg [7:0]   cis_index;
reg         cis_valid;

// Buffer management
reg [15:0]  buffer_size;
reg [15:0]  tx_write_ptr;
reg [15:0]  tx_read_ptr;
reg [15:0]  rx_write_ptr;
reg [15:0]  rx_read_ptr;

// CAM status
reg         cam_present_reg;
reg         cam_initialized_reg;
reg         cam_error_reg;
reg [7:0]   cam_status_reg;

// Media interface buffers
reg [7:0]   tx_buffer[0:2047];
reg [7:0]   rx_buffer[0:2047];
reg [10:0]  tx_count;
reg [10:0]  rx_count;
reg         tx_active;
reg         rx_active;

// Media interface synchronization
reg         mclki_sync, mclki_sync_d;
reg         mival_sync, mival_sync_d;
reg         mistrt_sync, mistrt_sync_d;
reg [7:0]   mdi_sync;

// T2MI interface
reg [7:0]   t2mi_data_sync;
reg         t2mi_valid_sync;
reg         t2mi_valid_d;

// =============================================================================
// CI Data Bus Control
// =============================================================================

// Bidirectional data bus
assign ci_d = ci_data_oe ? ci_data_out : 8'hZZ;

// Address mapping
always @(*) begin
    full_address = {ci_a_ext, ci_a};
end

// Status outputs
assign cam_present = cam_present_reg;
assign cam_initialized = cam_initialized_reg;
assign cam_error = cam_error_reg;
assign cam_status = cam_status_reg;

// =============================================================================
// Card Detection Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cam_present_reg <= 1'b0;
    end else begin
        // Check interrupt line for card presence
        cam_present_reg <= !ci_ireq_n && !ci_inpack_n;
    end
end

// =============================================================================
// State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= STATE_IDLE;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    next_state = current_state;
    
    case (current_state)
        STATE_IDLE: begin
            if (cam_present_reg) begin
                next_state = STATE_RESET;
            end
        end
        
        STATE_RESET: begin
            if (access_timer >= 8'd50) begin
                next_state = STATE_DETECT;
            end
        end
        
        STATE_DETECT: begin
            if (!cam_present_reg) begin
                next_state = STATE_IDLE;
            end else begin
                next_state = STATE_READ_CIS;
            end
        end
        
        STATE_READ_CIS: begin
            if (cis_valid) begin
                next_state = STATE_INIT;
            end else if (access_timer >= 8'd200) begin
                next_state = STATE_ERROR;
            end
        end
        
        STATE_INIT: begin
            if (cam_initialized_reg) begin
                next_state = STATE_SIZE_NEG;
            end
        end
        
        STATE_SIZE_NEG: begin
            if (buffer_size > 0) begin
                next_state = STATE_READY;
            end
        end
        
        STATE_READY: begin
            if (!cam_present_reg) begin
                next_state = STATE_IDLE;
            end else if (tx_count > 0) begin
                next_state = STATE_STREAM_TX;
            end else if (mival_sync) begin
                next_state = STATE_STREAM_RX;
            end
        end
        
        STATE_STREAM_TX: begin
            if (tx_count == 0) begin
                next_state = STATE_READY;
            end
        end
        
        STATE_STREAM_RX: begin
            if (!mival_sync) begin
                next_state = STATE_READY;
            end
        end
        
        STATE_ERROR: begin
            if (!cam_present_reg) begin
                next_state = STATE_IDLE;
            end
        end
        
        default: begin
            next_state = STATE_IDLE;
        end
    endcase
end

// =============================================================================
// CI Bus Control
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ci_reset <= 1'b0;
        ci_a <= 8'h00;
        ci_a_ext <= 7'h00;
        ci_data_out <= 8'h00;
        ci_data_oe <= 1'b0;
        ci_reg_n <= 1'b1;
        ci_ce1_n <= 1'b1;
        ci_oe_n <= 1'b1;
        ci_we_n <= 1'b1;
        ci_iord_n <= 1'b1;
        ci_iowr_n <= 1'b1;
        bus_oe <= 1'b0;
        access_timer <= 8'h00;
        cam_initialized_reg <= 1'b0;
        cam_error_reg <= 1'b0;
        cis_valid <= 1'b0;
        buffer_size <= 16'h0000;
    end else begin
        // Default: increment timer
        if (access_timer < 8'hFF) begin
            access_timer <= access_timer + 1'b1;
        end
        
        // Default control signals
        ci_oe_n <= 1'b1;
        ci_we_n <= 1'b1;
        ci_iord_n <= 1'b1;
        ci_iowr_n <= 1'b1;
        ci_data_oe <= 1'b0;
        
        case (current_state)
            STATE_IDLE: begin
                ci_reset <= 1'b0;
                cam_initialized_reg <= 1'b0;
                cam_error_reg <= 1'b0;
                access_timer <= 8'h00;
                ci_ce1_n <= 1'b1;
            end
            
            STATE_RESET: begin
                if (access_timer < 8'd10) begin
                    ci_reset <= 1'b1;
                end else begin
                    ci_reset <= 1'b0;
                end
            end
            
            STATE_READ_CIS: begin
                // Read CIS from attribute memory
                ci_ce1_n <= 1'b0;
                ci_reg_n <= 1'b1;  // Attribute memory
                ci_a <= cis_index;
                ci_a_ext <= 7'h00;
                
                if (access_timer[2:0] == 3'b010) begin
                    ci_oe_n <= 1'b0;
                end else if (access_timer[2:0] == 3'b110) begin
                    cis_data[cis_index] <= ci_d;
                    cis_index <= cis_index + 1'b1;
                    if (cis_index == 8'hFF) begin
                        cis_valid <= 1'b1;
                    end
                end
            end
            
            STATE_INIT: begin
                // Write initialization sequence
                ci_ce1_n <= 1'b0;
                ci_reg_n <= 1'b0;  // Common memory
                
                // Write command register
                if (access_timer < 8'd20) begin
                    ci_a <= COMMAND_REG_ADDR[7:0];
                    ci_a_ext <= COMMAND_REG_ADDR[14:8];
                    ci_data_out <= CMD_RESET;
                    ci_data_oe <= 1'b1;
                    if (access_timer[2:0] == 3'b010) begin
                        ci_we_n <= 1'b0;
                    end
                end else begin
                    cam_initialized_reg <= 1'b1;
                    cam_status_reg[1] <= 1'b1;
                end
            end
            
            STATE_SIZE_NEG: begin
                // Negotiate buffer size
                ci_ce1_n <= 1'b0;
                ci_reg_n <= 1'b0;
                
                if (access_timer < 8'd10) begin
                    // Write buffer size LS
                    ci_a <= SIZE_REG_LS_ADDR[7:0];
                    ci_a_ext <= SIZE_REG_LS_ADDR[14:8];
                    ci_data_out <= 8'h00;  // 2048 bytes LS
                    ci_data_oe <= 1'b1;
                    if (access_timer[2:0] == 3'b010) begin
                        ci_we_n <= 1'b0;
                    end
                end else if (access_timer < 8'd20) begin
                    // Write buffer size MS
                    ci_a <= SIZE_REG_MS_ADDR[7:0];
                    ci_a_ext <= SIZE_REG_MS_ADDR[14:8];
                    ci_data_out <= 8'h08;  // 2048 bytes MS
                    ci_data_oe <= 1'b1;
                    if (access_timer[2:0] == 3'b010) begin
                        ci_we_n <= 1'b0;
                    end
                end else begin
                    buffer_size <= 16'h0800;  // 2048 bytes
                    cam_status_reg[2] <= 1'b1;
                end
            end
            
            STATE_READY: begin
                cam_status_reg[7] <= 1'b1;  // Ready
                access_timer <= 8'h00;
            end
            
            STATE_ERROR: begin
                cam_error_reg <= 1'b1;
                cam_status_reg[6] <= 1'b1;
            end
        endcase
    end
end

// =============================================================================
// Media Interface Synchronization
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mclki_sync <= 1'b0;
        mclki_sync_d <= 1'b0;
        mival_sync <= 1'b0;
        mival_sync_d <= 1'b0;
        mistrt_sync <= 1'b0;
        mistrt_sync_d <= 1'b0;
        mdi_sync <= 8'h00;
    end else begin
        // Double synchronization
        mclki_sync <= ci_mclki;
        mclki_sync_d <= mclki_sync;
        mival_sync <= ci_mival;
        mival_sync_d <= mival_sync;
        mistrt_sync <= ci_mistrt;
        mistrt_sync_d <= mistrt_sync;
        
        // Capture data on rising edge of mclki
        if (mclki_sync && !mclki_sync_d) begin
            mdi_sync <= ci_mdi;
        end
    end
end

// =============================================================================
// RX Buffer Management (CAM to Host)
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_write_ptr <= 16'h0000;
        rx_count <= 11'h000;
        rx_active <= 1'b0;
    end else begin
        // Detect start of packet
        if (mistrt_sync && !mistrt_sync_d) begin
            rx_active <= 1'b1;
        end
        
        // Store received data
        if (rx_active && mival_sync && mclki_sync && !mclki_sync_d) begin
            rx_buffer[rx_write_ptr[10:0]] <= mdi_sync;
            rx_write_ptr <= rx_write_ptr + 1'b1;
            rx_count <= rx_count + 1'b1;
        end
        
        // End of packet
        if (rx_active && !mival_sync && mival_sync_d) begin
            rx_active <= 1'b0;
        end
    end
end

// =============================================================================
// TX Buffer Management (Host to CAM)
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_write_ptr <= 16'h0000;
        tx_count <= 11'h000;
        t2mi_data_sync <= 8'h00;
        t2mi_valid_sync <= 1'b0;
        t2mi_valid_d <= 1'b0;
    end else begin
        // Synchronize T2MI input
        t2mi_data_sync <= t2mi_data;
        t2mi_valid_sync <= t2mi_valid;
        t2mi_valid_d <= t2mi_valid_sync;
        
        // Store T2MI data in TX buffer
        if (t2mi_valid_sync && !t2mi_valid_d && !cam_bypass) begin
            tx_buffer[tx_write_ptr[10:0]] <= t2mi_data_sync;
            tx_write_ptr <= tx_write_ptr + 1'b1;
            tx_count <= tx_count + 1'b1;
        end
    end
end

// =============================================================================
// Media Output Control (Host to CAM)
// =============================================================================

reg [10:0] tx_bit_counter;
reg        tx_byte_ready;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ci_mdo <= 8'h00;
        ci_mclko <= 1'b0;
        ci_moval <= 1'b0;
        ci_mostrt <= 1'b0;
        tx_read_ptr <= 16'h0000;
        tx_active <= 1'b0;
        tx_bit_counter <= 11'h000;
        tx_byte_ready <= 1'b0;
    end else begin
        // Generate media clock (divide by 4)
        if (tx_active || (current_state == STATE_READY && tx_count > 0)) begin
            ci_mclko <= ~ci_mclko;
        end else begin
            ci_mclko <= 1'b0;
        end
        
        case (current_state)
            STATE_READY: begin
                if (tx_count > 0 && !tx_active) begin
                    tx_active <= 1'b1;
                    ci_mostrt <= 1'b1;
                    tx_bit_counter <= 11'h000;
                end
            end
            
            STATE_STREAM_TX: begin
                // Clear start signal after first clock
                if (tx_bit_counter == 11'h001) begin
                    ci_mostrt <= 1'b0;
                end
                
                // Output data on falling edge of mclko
                if (ci_mclko && tx_bit_counter[1:0] == 2'b00) begin
                    if (tx_read_ptr < tx_write_ptr) begin
                        ci_mdo <= tx_buffer[tx_read_ptr[10:0]];
                        ci_moval <= 1'b1;
                        tx_read_ptr <= tx_read_ptr + 1'b1;
                        tx_count <= tx_count - 1'b1;
                    end else begin
                        ci_moval <= 1'b0;
                        tx_active <= 1'b0;
                    end
                end
                
                tx_bit_counter <= tx_bit_counter + 1'b1;
            end
            
            default: begin
                ci_moval <= 1'b0;
                ci_mostrt <= 1'b0;
                tx_active <= 1'b0;
            end
        endcase
    end
end

// =============================================================================
// T2MI Output Interface
// =============================================================================

// Output processed data from RX buffer or bypass
assign t2mi_cam_valid = cam_bypass ? t2mi_valid_sync : 
                       (cam_initialized_reg && rx_count > 0);

assign t2mi_cam_data = cam_bypass ? t2mi_data_sync : 
                      rx_buffer[rx_read_ptr[10:0]];

// Update read pointer when data is consumed
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_read_ptr <= 16'h0000;
    end else begin
        if (!cam_bypass && t2mi_cam_valid && rx_read_ptr < rx_write_ptr) begin
            rx_read_ptr <= rx_read_ptr + 1'b1;
            rx_count <= rx_count - 1'b1;
        end
    end
end

endmodule