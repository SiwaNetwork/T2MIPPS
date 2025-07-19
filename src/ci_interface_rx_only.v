// =============================================================================
// CI Interface Module - RX Only (8-bit EN50221 Implementation)
// =============================================================================
// Description: Simplified CI module for CAM with receive-only media interface
//              Only receives decrypted stream from CAM for PPS generation
// Target: Lattice LFE5U-25F-6BG256C
// Author: System
// Date: December 2024
// Version: 3.0 - RX Only version
// =============================================================================

module ci_interface_rx_only (
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
    
    // Media Data Input ONLY (from CAM to Host)
    input  wire [7:0]  ci_mdi,           // Media data input
    input  wire        ci_mclki,         // Media clock input
    input  wire        ci_mival,         // Media input valid
    input  wire        ci_mistrt,        // Media input start
    
    // Decrypted Stream Output (for PPS generation)
    output reg         stream_valid,     // Decrypted stream data valid
    output reg  [7:0]  stream_data,      // Decrypted stream data byte
    output reg         stream_start,     // Start of packet
    output reg         stream_end,       // End of packet
    
    // Control and Status
    output wire        cam_present,      // CAM module present
    output wire        cam_ready,        // CAM initialized and ready
    output wire        cam_error,        // CAM error flag
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

// Command/Status bits
parameter CMD_RESET          = 8'h01;  // Reset interface
parameter CMD_HOST_READY     = 8'h02;  // Host ready to receive
parameter STAT_DATA_AVAIL    = 8'h80;  // Data available from CAM

// State Machine States
localparam STATE_IDLE        = 4'h0;
localparam STATE_RESET       = 4'h1;
localparam STATE_DETECT      = 4'h2;
localparam STATE_READ_CIS    = 4'h3;
localparam STATE_INIT        = 4'h4;
localparam STATE_CONFIG      = 4'h5;
localparam STATE_READY       = 4'h6;
localparam STATE_RECEIVE     = 4'h7;
localparam STATE_ERROR       = 4'h8;

// =============================================================================
// Internal Signals
// =============================================================================

// State machine
reg [3:0]   current_state;
reg [3:0]   next_state;

// CI bus control
reg [7:0]   ci_data_out;
reg         ci_data_oe;

// Timing control
reg [7:0]   access_timer;
reg [15:0]  init_timer;

// CIS data
reg [7:0]   cis_data[0:255];
reg [7:0]   cis_index;
reg         cis_valid;

// CAM status
reg         cam_present_reg;
reg         cam_initialized_reg;
reg         cam_error_reg;

// Media interface synchronization
reg         mclki_sync, mclki_sync_d;
reg         mival_sync, mival_sync_d;
reg         mistrt_sync, mistrt_sync_d;
reg [7:0]   mdi_sync;

// Packet detection
reg         packet_active;
reg [15:0]  byte_counter;

// =============================================================================
// CI Data Bus Control
// =============================================================================

// Bidirectional data bus
assign ci_d = ci_data_oe ? ci_data_out : 8'hZZ;

// Status outputs
assign cam_present = cam_present_reg;
assign cam_ready = cam_initialized_reg && (current_state == STATE_READY || 
                                          current_state == STATE_RECEIVE);
assign cam_error = cam_error_reg;

// =============================================================================
// Card Detection Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cam_present_reg <= 1'b0;
    end else begin
        // Check interrupt and inpack lines for card presence
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
            if (cam_present_reg && !cam_bypass) begin
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
            if (init_timer >= 16'd1000) begin
                next_state = STATE_CONFIG;
            end
        end
        
        STATE_CONFIG: begin
            if (cam_initialized_reg) begin
                next_state = STATE_READY;
            end
        end
        
        STATE_READY: begin
            if (!cam_present_reg) begin
                next_state = STATE_IDLE;
            end else if (mival_sync) begin
                next_state = STATE_RECEIVE;
            end
        end
        
        STATE_RECEIVE: begin
            if (!mival_sync && mival_sync_d) begin
                next_state = STATE_READY;
            end else if (!cam_present_reg) begin
                next_state = STATE_IDLE;
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
        init_timer <= 16'h0000;
        cam_initialized_reg <= 1'b0;
        cam_error_reg <= 1'b0;
        cis_valid <= 1'b0;
        cis_index <= 8'h00;
    end else begin
        // Default: increment timers
        if (access_timer < 8'hFF) begin
            access_timer <= access_timer + 1'b1;
        end
        
        if (init_timer < 16'hFFFF) begin
            init_timer <= init_timer + 1'b1;
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
                init_timer <= 16'h0000;
                ci_ce1_n <= 1'b1;
                cis_index <= 8'h00;
                cis_valid <= 1'b0;
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
                // Just wait for CAM to initialize
                access_timer <= 8'h00;
            end
            
            STATE_CONFIG: begin
                // Write host ready command
                ci_ce1_n <= 1'b0;
                ci_reg_n <= 1'b0;  // Common memory
                
                if (access_timer < 8'd20) begin
                    ci_a <= COMMAND_REG_ADDR[7:0];
                    ci_a_ext <= COMMAND_REG_ADDR[14:8];
                    ci_data_out <= CMD_HOST_READY;
                    ci_data_oe <= 1'b1;
                    if (access_timer[2:0] == 3'b010) begin
                        ci_we_n <= 1'b0;
                    end
                end else begin
                    cam_initialized_reg <= 1'b1;
                end
            end
            
            STATE_READY: begin
                access_timer <= 8'h00;
                ci_ce1_n <= 1'b1;  // Deselect during idle
            end
            
            STATE_RECEIVE: begin
                // Just monitor the media interface
                // No CI bus activity needed during streaming
                ci_ce1_n <= 1'b1;
            end
            
            STATE_ERROR: begin
                cam_error_reg <= 1'b1;
                ci_ce1_n <= 1'b1;
            end
        endcase
    end
end

// =============================================================================
// Media Interface Synchronization (RX Only)
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
// Stream Output Generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stream_valid <= 1'b0;
        stream_data <= 8'h00;
        stream_start <= 1'b0;
        stream_end <= 1'b0;
        packet_active <= 1'b0;
        byte_counter <= 16'h0000;
    end else begin
        // Default values
        stream_valid <= 1'b0;
        stream_start <= 1'b0;
        stream_end <= 1'b0;
        
        if (cam_bypass) begin
            // In bypass mode, don't output anything
            packet_active <= 1'b0;
            byte_counter <= 16'h0000;
        end else if (current_state == STATE_RECEIVE || current_state == STATE_READY) begin
            // Detect start of packet
            if (mistrt_sync && !mistrt_sync_d) begin
                packet_active <= 1'b1;
                stream_start <= 1'b1;
                byte_counter <= 16'h0000;
            end
            
            // Output received data
            if (packet_active && mival_sync && mclki_sync && !mclki_sync_d) begin
                stream_valid <= 1'b1;
                stream_data <= mdi_sync;
                byte_counter <= byte_counter + 1'b1;
            end
            
            // Detect end of packet
            if (packet_active && !mival_sync && mival_sync_d) begin
                packet_active <= 1'b0;
                stream_end <= 1'b1;
                stream_valid <= 1'b1;
                stream_data <= mdi_sync;  // Last byte
            end
        end else begin
            packet_active <= 1'b0;
            byte_counter <= 16'h0000;
        end
    end
end

endmodule