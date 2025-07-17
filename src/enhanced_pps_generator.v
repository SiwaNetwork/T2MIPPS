// =============================================================================
// Enhanced PPS Generator with SiT5503 Support
// =============================================================================
// Description: High-precision PPS generator using SiT5503 10 MHz oscillator
//              with T2-MI synchronization and autonomous operation capability
// Author: Manus AI
// Date: June 6, 2025
// =============================================================================

module enhanced_pps_generator (
    // Clock and Reset
    input  wire        clk_100mhz,       // System clock (100 MHz)
    input  wire        rst_n,            // Active low reset
    
    // High-stability reference from SiT5503
    input  wire        sit5503_clk,      // 10 MHz from SiT5503
    input  wire        sit5503_ready,    // SiT5503 oscillator ready
    
    // T2-MI Timestamp Input
    input  wire        timestamp_valid,  // New timestamp available
    input  wire [39:0] timestamp_seconds, // Seconds since epoch
    input  wire [31:0] timestamp_subsec, // Subseconds (32-bit fraction)
    input  wire        t2mi_sync_locked, // T2-MI synchronization status
    
    // PPS Outputs
    output reg         pps_out,          // Main PPS output
    output reg         pps_backup,       // Backup PPS (autonomous mode)
    
    // Control and Status
    input  wire        force_autonomous, // Force autonomous mode
    output reg         autonomous_mode,  // Currently in autonomous mode
    output reg         sync_status,      // Synchronization status
    output reg [7:0]   pps_status,       // Status register
    output reg [31:0]  time_error,       // Time error measurement
    
    // Calibration Interface
    output reg         calibrate_request, // Request SiT5503 calibration
    output reg [15:0]  freq_correction,   // Frequency correction value
    input  wire        calibration_done   // Calibration completed
);

// =============================================================================
// Parameters
// =============================================================================

parameter SIT5503_FREQ_HZ = 10_000_000;     // 10 MHz SiT5503 frequency
parameter CLK_100M_FREQ_HZ = 100_000_000;   // 100 MHz system clock
parameter PPS_PULSE_WIDTH = 1000;           // PPS pulse width (10 us)

// Timing parameters
parameter SYNC_TIMEOUT_MS = 5000;           // 5 second sync timeout
parameter CALIBRATION_INTERVAL_S = 3600;    // 1 hour calibration interval
parameter MAX_TIME_ERROR_NS = 1000;         // 1 us maximum time error

// State machine states
localparam [2:0] INIT          = 3'h0,
                 WAIT_SYNC     = 3'h1,
                 SYNCHRONIZED  = 3'h2,
                 AUTONOMOUS    = 3'h3,
                 CALIBRATING   = 3'h4,
                 ERROR_ST      = 3'h5;

// =============================================================================
// Internal Signals
// =============================================================================

reg [2:0]   state;
reg [2:0]   next_state;

// Time keeping
reg [39:0]  current_seconds;
reg [31:0]  current_subseconds;
reg [31:0]  subsec_increment_100m;
reg [31:0]  subsec_increment_10m;
reg [31:0]  subsec_counter;
reg         time_valid;

// SiT5503 clock domain crossing
reg         sit5503_clk_sync1;
reg         sit5503_clk_sync2;
reg         sit5503_clk_prev;
reg         sit5503_pulse;
reg [31:0]  sit5503_counter;

// Synchronization logic
reg [31:0]  sync_timeout_counter;
reg [39:0]  last_sync_seconds;
reg [31:0]  last_sync_subsec;
reg         sync_pending;
reg [31:0]  sync_error_accum;

// PPS generation
reg [31:0]  pps_counter;
reg [15:0]  pps_pulse_counter;
reg         pps_active;
reg         next_second_pending;

// Calibration logic
reg [31:0]  calibration_timer;
reg [31:0]  freq_error_measurement;
reg [15:0]  calibration_history [0:7];
reg [2:0]   calibration_index;
reg         calibration_needed;

// Clock selection and monitoring
reg         use_sit5503_clock;
reg [31:0]  clock_monitor_counter;
reg         clock_stable;

// =============================================================================
// Clock Domain Crossing for SiT5503
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
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

// =============================================================================
// Subsecond Increment Calculation
// =============================================================================

// Calculate subsecond increment for 100 MHz clock
// 2^32 / 100,000,000 = 42.94967296
initial begin
    subsec_increment_100m = 32'd42949673;  // Precise value for 100 MHz
end

// Calculate subsecond increment for 10 MHz clock (from SiT5503)
// 2^32 / 10,000,000 = 429.4967296
initial begin
    subsec_increment_10m = 32'd429496730;  // Precise value for 10 MHz
end

// =============================================================================
// Main State Machine
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        state <= INIT;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        INIT: begin
            if (sit5503_ready && clock_stable) begin
                next_state = WAIT_SYNC;
            end
        end
        
        WAIT_SYNC: begin
            if (timestamp_valid && t2mi_sync_locked) begin
                next_state = SYNCHRONIZED;
            end else if (sync_timeout_counter >= SYNC_TIMEOUT_MS * 100000) begin
                next_state = AUTONOMOUS;
            end else if (force_autonomous) begin
                next_state = AUTONOMOUS;
            end
        end
        
        SYNCHRONIZED: begin
            if (!t2mi_sync_locked || force_autonomous) begin
                next_state = AUTONOMOUS;
            end else if (calibration_needed) begin
                next_state = CALIBRATING;
            end
        end
        
        AUTONOMOUS: begin
            if (timestamp_valid && t2mi_sync_locked && !force_autonomous) begin
                next_state = SYNCHRONIZED;
            end else if (calibration_needed) begin
                next_state = CALIBRATING;
            end
        end
        
        CALIBRATING: begin
            if (calibration_done) begin
                if (t2mi_sync_locked && !force_autonomous) begin
                    next_state = SYNCHRONIZED;
                end else begin
                    next_state = AUTONOMOUS;
                end
            end
        end
        
        ERROR_ST: begin
            if (sit5503_ready && clock_stable) begin
                next_state = INIT;
            end
        end
        
        default: next_state = INIT;
    endcase
end

// =============================================================================
// Time Keeping Logic
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        current_seconds <= 40'h0;
        current_subseconds <= 32'h0;
        subsec_counter <= 32'h0;
        sit5503_counter <= 32'h0;
        time_valid <= 1'b0;
        use_sit5503_clock <= 1'b0;
    end else begin
        // Default increment using system clock
        if (use_sit5503_clock && sit5503_pulse) begin
            // Use high-precision SiT5503 clock
            subsec_counter <= subsec_counter + subsec_increment_10m;
            sit5503_counter <= sit5503_counter + 1;
        end else begin
            // Use system clock as fallback
            subsec_counter <= subsec_counter + subsec_increment_100m;
        end
        
        // Handle subsecond overflow (new second)
        if (subsec_counter >= 32'hFFFFFFFF) begin
            subsec_counter <= subsec_counter - 32'hFFFFFFFF;
            current_seconds <= current_seconds + 1;
            current_subseconds <= subsec_counter;
            next_second_pending <= 1'b1;
        end else begin
            current_subseconds <= subsec_counter;
        end
        
        // Synchronization with T2-MI timestamps
        if (timestamp_valid && (state == SYNCHRONIZED)) begin
            // Calculate time error
            time_error <= {8'h0, timestamp_subsec} - {8'h0, current_subseconds};
            
            // Apply correction if error is significant
            if (time_error > MAX_TIME_ERROR_NS || time_error < -MAX_TIME_ERROR_NS) begin
                current_seconds <= timestamp_seconds;
                current_subseconds <= timestamp_subsec;
                subsec_counter <= timestamp_subsec;
                sync_error_accum <= sync_error_accum + time_error;
            end
            
            last_sync_seconds <= timestamp_seconds;
            last_sync_subsec <= timestamp_subsec;
            time_valid <= 1'b1;
        end
    end
end

// =============================================================================
// PPS Generation Logic
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        pps_out <= 1'b0;
        pps_backup <= 1'b0;
        pps_counter <= 32'h0;
        pps_pulse_counter <= 16'h0;
        pps_active <= 1'b0;
    end else begin
        // Generate PPS pulse on second boundary
        if (next_second_pending && time_valid) begin
            pps_active <= 1'b1;
            pps_pulse_counter <= 16'h0;
            next_second_pending <= 1'b0;
        end
        
        // Control PPS pulse width
        if (pps_active) begin
            pps_pulse_counter <= pps_pulse_counter + 1;
            
            if (pps_pulse_counter < PPS_PULSE_WIDTH) begin
                pps_out <= 1'b1;
                pps_backup <= 1'b1;
            end else begin
                pps_out <= 1'b0;
                pps_backup <= 1'b0;
                pps_active <= 1'b0;
            end
        end
    end
end

// =============================================================================
// Control Logic
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        sync_timeout_counter <= 32'h0;
        calibration_timer <= 32'h0;
        calibration_needed <= 1'b0;
        calibrate_request <= 1'b0;
        freq_correction <= 16'h0;
        autonomous_mode <= 1'b0;
        sync_status <= 1'b0;
        pps_status <= 8'h00;
        clock_monitor_counter <= 32'h0;
        clock_stable <= 1'b0;
        calibration_index <= 3'h0;
    end else begin
        // Default values
        calibrate_request <= 1'b0;
        
        // Clock stability monitoring
        if (sit5503_ready) begin
            clock_monitor_counter <= clock_monitor_counter + 1;
            if (clock_monitor_counter >= 32'd100000) begin  // 1 ms
                clock_stable <= 1'b1;
            end
        end else begin
            clock_monitor_counter <= 32'h0;
            clock_stable <= 1'b0;
        end
        
        case (state)
            INIT: begin
                pps_status[0] <= 1'b1;  // Initializing
                autonomous_mode <= 1'b0;
                sync_status <= 1'b0;
                use_sit5503_clock <= 1'b0;
            end
            
            WAIT_SYNC: begin
                pps_status[0] <= 1'b0;  // Not initializing
                pps_status[1] <= 1'b1;  // Waiting for sync
                sync_timeout_counter <= sync_timeout_counter + 1;
                use_sit5503_clock <= sit5503_ready;
            end
            
            SYNCHRONIZED: begin
                pps_status[1] <= 1'b0;  // Not waiting
                pps_status[2] <= 1'b1;  // Synchronized
                autonomous_mode <= 1'b0;
                sync_status <= 1'b1;
                sync_timeout_counter <= 32'h0;
                use_sit5503_clock <= 1'b1;
                
                // Check if calibration is needed
                calibration_timer <= calibration_timer + 1;
                if (calibration_timer >= CALIBRATION_INTERVAL_S * 100000000) begin
                    calibration_needed <= 1'b1;
                    calibration_timer <= 32'h0;
                end
            end
            
            AUTONOMOUS: begin
                pps_status[2] <= 1'b0;  // Not synchronized
                pps_status[3] <= 1'b1;  // Autonomous mode
                autonomous_mode <= 1'b1;
                sync_status <= 1'b0;
                use_sit5503_clock <= 1'b1;
                
                // Continue calibration timer in autonomous mode
                calibration_timer <= calibration_timer + 1;
                if (calibration_timer >= CALIBRATION_INTERVAL_S * 100000000) begin
                    calibration_needed <= 1'b1;
                    calibration_timer <= 32'h0;
                end
            end
            
            CALIBRATING: begin
                pps_status[4] <= 1'b1;  // Calibrating
                calibration_needed <= 1'b0;
                
                if (!calibrate_request) begin
                    // Calculate frequency correction based on accumulated error
                    freq_correction <= sync_error_accum[15:0];
                    calibrate_request <= 1'b1;
                    
                    // Store calibration history
                    calibration_history[calibration_index] <= freq_correction;
                    calibration_index <= calibration_index + 1;
                end
                
                if (calibration_done) begin
                    pps_status[4] <= 1'b0;  // Not calibrating
                    sync_error_accum <= 32'h0;  // Reset error accumulator
                end
            end
            
            ERROR_ST: begin
                pps_status[7] <= 1'b1;  // Error flag
                autonomous_mode <= 1'b0;
                sync_status <= 1'b0;
                use_sit5503_clock <= 1'b0;
            end
        endcase
        
        // Update status register
        pps_status[5] <= use_sit5503_clock;     // Using SiT5503 clock
        pps_status[6] <= time_valid;            // Time is valid
    end
end

endmodule

