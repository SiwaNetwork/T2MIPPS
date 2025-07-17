// =============================================================================
// SiT5503 Oscillator Controller
// =============================================================================
// Description: High-level controller for SiT5503 programmable oscillator.
//              Provides frequency control and calibration capabilities.
// Author: Manus AI
// Date: June 6, 2025
// =============================================================================

module sit5503_controller (
    // Clock and Reset
    input  wire        clk,              // System clock (100 MHz)
    input  wire        rst_n,            // Active low reset
    
    // I2C Interface to SiT5503
    output wire        scl,              // I2C clock
    inout  wire        sda,              // I2C data
    
    // SiT5503 Clock Output
    input  wire        sit5503_clk,      // 10 MHz from SiT5503
    output wire        sit5503_clk_out,  // Buffered 10 MHz output
    
    // Control Interface
    input  wire        calibrate_start,  // Start calibration
    input  wire [15:0] frequency_offset, // Frequency offset (signed)
    input  wire        offset_valid,     // Offset value valid
    output reg         calibration_done, // Calibration complete
    output reg         oscillator_ready, // Oscillator stable and ready
    output reg [7:0]   status_reg,       // Status register
    
    // Reference for calibration
    input  wire        ref_pps,          // Reference PPS signal
    input  wire        ref_valid         // Reference signal valid
);

// =============================================================================
// Parameters
// =============================================================================

// SiT5503 I2C address (7-bit, depends on A0/A1 pins)
parameter SIT5503_I2C_ADDR = 7'h68;     // Default address

// Register addresses (based on SiT5503 datasheet)
parameter REG_DEVICE_ID     = 8'h00;    // Device ID register
parameter REG_FREQ_CTRL_LSB = 8'h01;    // Frequency control LSB
parameter REG_FREQ_CTRL_MSB = 8'h02;    // Frequency control MSB
parameter REG_OUTPUT_CTRL   = 8'h03;    // Output control
parameter REG_STATUS        = 8'h04;    // Status register

// Frequency control parameters
parameter NOMINAL_FREQ_HZ   = 10_000_000; // 10 MHz nominal
parameter PPM_RESOLUTION    = 32;        // Resolution in ppb per LSB
parameter MAX_OFFSET_PPM    = 25;        // ±25 ppm range

// State machine states
localparam [3:0] IDLE           = 4'h0,
                 INIT_START     = 4'h1,
                 READ_ID        = 4'h2,
                 ENABLE_OUTPUT  = 4'h3,
                 WAIT_STABLE    = 4'h4,
                 READY          = 4'h5,
                 CALIBRATE      = 4'h6,
                 WRITE_FREQ     = 4'h7,
                 VERIFY_FREQ    = 4'h8,
                 ERROR_ST       = 4'h9;

// =============================================================================
// Internal Signals
// =============================================================================

reg [3:0]   state;
reg [3:0]   next_state;
reg [15:0]  init_counter;
reg [15:0]  stable_counter;
reg [7:0]   device_id;
reg [15:0]  current_freq_ctrl;
reg [15:0]  target_freq_ctrl;

// I2C Master interface
reg         i2c_start;
reg         i2c_stop;
reg [6:0]   i2c_device_addr;
reg         i2c_rw_bit;
reg [7:0]   i2c_write_data;
reg         i2c_write_valid;
wire [7:0]  i2c_read_data;
wire        i2c_read_valid;
wire        i2c_ack_received;
wire        i2c_busy;
wire        i2c_error;

// Calibration logic
reg [31:0]  ref_period_counter;
reg [31:0]  sit_period_counter;
reg [31:0]  ref_period_measured;
reg [31:0]  sit_period_measured;
reg         ref_pps_prev;
reg         measurement_active;
reg [15:0]  calibration_counter;

// Clock domain crossing for SiT5503 clock
reg         sit5503_clk_sync1;
reg         sit5503_clk_sync2;
reg         sit5503_clk_prev;
reg         sit5503_pulse;

// =============================================================================
// I2C Master Instance
// =============================================================================

i2c_master i2c_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .scl            (scl),
    .sda            (sda),
    .start          (i2c_start),
    .stop           (i2c_stop),
    .device_addr    (i2c_device_addr),
    .rw_bit         (i2c_rw_bit),
    .write_data     (i2c_write_data),
    .write_valid    (i2c_write_valid),
    .read_data      (i2c_read_data),
    .read_valid     (i2c_read_valid),
    .ack_received   (i2c_ack_received),
    .busy           (i2c_busy),
    .error          (i2c_error)
);

// =============================================================================
// Clock Domain Crossing for SiT5503
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sit5503_clk_sync1 <= 1'b0;
        sit5503_clk_sync2 <= 1'b0;
        sit5503_clk_prev <= 1'b0;
        sit5503_pulse <= 1'b0;
    end else begin
        sit5503_clk_sync1 <= sit5503_clk;
        sit5503_clk_sync2 <= sit5503_clk_sync1;
        sit5503_clk_prev <= sit5503_clk_sync2;
        sit5503_pulse <= sit5503_clk_sync2 && !sit5503_clk_prev;
    end
end

assign sit5503_clk_out = sit5503_clk_sync2;

// =============================================================================
// Main State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        IDLE: begin
            next_state = INIT_START;
        end
        
        INIT_START: begin
            if (init_counter >= 16'd50000) begin  // 500 us delay
                next_state = READ_ID;
            end
        end
        
        READ_ID: begin
            if (!i2c_busy && i2c_read_valid) begin
                if (device_id == 8'h53) begin  // Expected SiT5503 ID
                    next_state = ENABLE_OUTPUT;
                end else begin
                    next_state = ERROR_ST;
                end
            end else if (i2c_error) begin
                next_state = ERROR_ST;
            end
        end
        
        ENABLE_OUTPUT: begin
            if (!i2c_busy && i2c_ack_received) begin
                next_state = WAIT_STABLE;
            end else if (i2c_error) begin
                next_state = ERROR_ST;
            end
        end
        
        WAIT_STABLE: begin
            if (stable_counter >= 16'd10000) begin  // 100 us stability time
                next_state = READY;
            end
        end
        
        READY: begin
            if (calibrate_start) begin
                next_state = CALIBRATE;
            end else if (offset_valid) begin
                next_state = WRITE_FREQ;
            end
        end
        
        CALIBRATE: begin
            if (calibration_counter >= 16'd10000) begin  // Calibration timeout
                next_state = WRITE_FREQ;
            end
        end
        
        WRITE_FREQ: begin
            if (!i2c_busy && i2c_ack_received) begin
                next_state = VERIFY_FREQ;
            end else if (i2c_error) begin
                next_state = ERROR_ST;
            end
        end
        
        VERIFY_FREQ: begin
            if (!i2c_busy && i2c_read_valid) begin
                next_state = READY;
            end else if (i2c_error) begin
                next_state = ERROR_ST;
            end
        end
        
        ERROR_ST: begin
            // Stay in error state until reset
        end
        
        default: next_state = IDLE;
    endcase
end

// =============================================================================
// Control Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        init_counter <= 16'h0;
        stable_counter <= 16'h0;
        device_id <= 8'h00;
        current_freq_ctrl <= 16'h8000;  // Center value
        target_freq_ctrl <= 16'h8000;
        calibration_done <= 1'b0;
        oscillator_ready <= 1'b0;
        status_reg <= 8'h00;
        
        // I2C control signals
        i2c_start <= 1'b0;
        i2c_stop <= 1'b0;
        i2c_device_addr <= SIT5503_I2C_ADDR;
        i2c_rw_bit <= 1'b0;
        i2c_write_data <= 8'h00;
        i2c_write_valid <= 1'b0;
        
        calibration_counter <= 16'h0;
    end else begin
        // Default values
        i2c_start <= 1'b0;
        i2c_stop <= 1'b0;
        i2c_write_valid <= 1'b0;
        calibration_done <= 1'b0;
        
        case (state)
            IDLE: begin
                oscillator_ready <= 1'b0;
                status_reg[0] <= 1'b0;  // Not ready
                init_counter <= 16'h0;
            end
            
            INIT_START: begin
                init_counter <= init_counter + 1;
                status_reg[1] <= 1'b1;  // Initializing
            end
            
            READ_ID: begin
                if (!i2c_busy && !i2c_start) begin
                    i2c_start <= 1'b1;
                    i2c_rw_bit <= 1'b1;  // Read
                    i2c_write_data <= REG_DEVICE_ID;
                    i2c_write_valid <= 1'b1;
                end
                
                if (i2c_read_valid) begin
                    device_id <= i2c_read_data;
                end
            end
            
            ENABLE_OUTPUT: begin
                if (!i2c_busy && !i2c_start) begin
                    i2c_start <= 1'b1;
                    i2c_rw_bit <= 1'b0;  // Write
                    i2c_write_data <= 8'h01;  // Enable output
                    i2c_write_valid <= 1'b1;
                end
            end
            
            WAIT_STABLE: begin
                stable_counter <= stable_counter + 1;
                status_reg[2] <= 1'b1;  // Stabilizing
            end
            
            READY: begin
                oscillator_ready <= 1'b1;
                status_reg[0] <= 1'b1;  // Ready
                status_reg[1] <= 1'b0;  // Not initializing
                status_reg[2] <= 1'b0;  // Stable
                
                if (offset_valid) begin
                    // Convert frequency offset to control value
                    target_freq_ctrl <= current_freq_ctrl + frequency_offset;
                end
            end
            
            CALIBRATE: begin
                calibration_counter <= calibration_counter + 1;
                status_reg[3] <= 1'b1;  // Calibrating
                
                // Perform automatic calibration based on reference
                if (ref_valid && measurement_active) begin
                    // Calculate frequency error and adjust
                    // This is a simplified calibration algorithm
                    if (sit_period_measured > ref_period_measured) begin
                        target_freq_ctrl <= current_freq_ctrl + 1;
                    end else if (sit_period_measured < ref_period_measured) begin
                        target_freq_ctrl <= current_freq_ctrl - 1;
                    end
                    calibration_done <= 1'b1;
                end
            end
            
            WRITE_FREQ: begin
                if (!i2c_busy && !i2c_start) begin
                    i2c_start <= 1'b1;
                    i2c_rw_bit <= 1'b0;  // Write
                    i2c_write_data <= target_freq_ctrl[7:0];  // LSB first
                    i2c_write_valid <= 1'b1;
                    current_freq_ctrl <= target_freq_ctrl;
                end
            end
            
            VERIFY_FREQ: begin
                if (!i2c_busy && !i2c_start) begin
                    i2c_start <= 1'b1;
                    i2c_rw_bit <= 1'b1;  // Read back
                    i2c_write_data <= REG_FREQ_CTRL_LSB;
                    i2c_write_valid <= 1'b1;
                end
                status_reg[3] <= 1'b0;  // Not calibrating
            end
            
            ERROR_ST: begin
                status_reg[7] <= 1'b1;  // Error flag
                oscillator_ready <= 1'b0;
            end
        endcase
    end
end

// =============================================================================
// Calibration Measurement Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ref_period_counter <= 32'h0;
        sit_period_counter <= 32'h0;
        ref_period_measured <= 32'h0;
        sit_period_measured <= 32'h0;
        ref_pps_prev <= 1'b0;
        measurement_active <= 1'b0;
    end else begin
        ref_pps_prev <= ref_pps;
        
        // Start measurement on PPS rising edge
        if (ref_pps && !ref_pps_prev && ref_valid) begin
            measurement_active <= 1'b1;
            ref_period_counter <= 32'h0;
            sit_period_counter <= 32'h0;
        end
        
        // Count periods during measurement
        if (measurement_active) begin
            ref_period_counter <= ref_period_counter + 1;
            
            if (sit5503_pulse) begin
                sit_period_counter <= sit_period_counter + 1;
            end
            
            // End measurement on next PPS edge
            if (ref_pps && !ref_pps_prev) begin
                measurement_active <= 1'b0;
                ref_period_measured <= ref_period_counter;
                sit_period_measured <= sit_period_counter;
            end
        end
    end
end

endmodule

