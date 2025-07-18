// =============================================================================
// Advanced Digital Phase-Locked Loop with PID Controller
// =============================================================================
// Description: High-precision DPLL with full PID control and advanced features
// Includes adaptive bandwidth, phase prediction, and comprehensive diagnostics
// =============================================================================

module advanced_dpll_pid #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter PHASE_BITS = 48,           // Increased precision
    parameter FREQ_BITS = 48,
    parameter FIXED_POINT_BITS = 16      // For fractional calculations
)(
    input  wire        clk,
    input  wire        rst_n,
    
    // Reference input
    input  wire        ref_pulse,            // Reference PPS pulse
    input  wire [39:0] ref_seconds,          // Reference time
    input  wire [31:0] ref_subseconds,
    input  wire        ref_valid,
    
    // Local oscillator input
    input  wire        local_clk_10mhz,      // 10MHz from SiT5503
    
    // PID control parameters (configurable)
    input  wire [31:0] kp,                   // Proportional gain (16.16 fixed)
    input  wire [31:0] ki,                   // Integral gain (16.16 fixed)
    input  wire [31:0] kd,                   // Derivative gain (16.16 fixed)
    input  wire [15:0] loop_bandwidth,       // Loop bandwidth control
    input  wire        adaptive_enable,      // Enable adaptive features
    input  wire [15:0] prediction_depth,     // Phase prediction depth
    
    // Advanced control
    input  wire [31:0] integral_limit,       // Anti-windup limit
    input  wire [15:0] derivative_filter,    // Derivative filter coefficient
    input  wire        holdover_enable,      // Enable holdover mode
    
    // Outputs
    output reg         pps_out,              // Synchronized PPS output
    output reg  [39:0] locked_seconds,       // Locked time output
    output reg  [31:0] locked_subseconds,
    output reg  signed [47:0] phase_error,   // Current phase error (high precision)
    output reg  signed [47:0] frequency_error,// Current frequency error
    output reg         dpll_locked,          // Lock indicator
    output reg  [3:0]  dpll_state,
    
    // Holdover mode
    output reg         holdover_active,      // In holdover mode
    output reg  [31:0] holdover_quality,     // Holdover performance metric
    output reg  [31:0] holdover_duration,    // Time in holdover (seconds)
    
    // Advanced diagnostics
    output reg  [47:0] phase_variance,       // Phase error variance
    output reg  [47:0] frequency_variance,   // Frequency error variance
    output reg  [31:0] allan_deviation,      // Allan deviation estimate
    output reg  [31:0] mtie,                 // Maximum time interval error
    output reg  [31:0] tdev,                 // Time deviation
    output reg  signed [47:0] phase_prediction, // Predicted phase
    output reg  [15:0] lock_quality,         // Lock quality metric (0-65535)
    
    // PID components output for monitoring
    output reg  signed [47:0] p_term,        // Proportional term
    output reg  signed [47:0] i_term,        // Integral term
    output reg  signed [47:0] d_term,        // Derivative term
    output reg  signed [47:0] pid_output     // Total PID output
);

// =============================================================================
// State definitions
// =============================================================================

localparam STATE_UNLOCKED    = 4'd0;
localparam STATE_FREQ_ACQ    = 4'd1;  // Frequency acquisition
localparam STATE_PHASE_ACQ   = 4'd2;  // Phase acquisition
localparam STATE_FINE_LOCK   = 4'd3;  // Fine locking
localparam STATE_LOCKED      = 4'd4;  // Fully locked
localparam STATE_HOLDOVER    = 4'd5;  // Holdover mode
localparam STATE_RECOVERY    = 4'd6;  // Recovery from holdover

// =============================================================================
// Internal signals
// =============================================================================

// NCO (Numerically Controlled Oscillator)
reg [PHASE_BITS-1:0] nco_phase;
reg [FREQ_BITS-1:0]  nco_frequency;
reg [FREQ_BITS-1:0]  nco_freq_nominal;
reg [FREQ_BITS-1:0]  nco_freq_correction;

// Phase detector
reg signed [PHASE_BITS-1:0] phase_detector_out;
reg phase_detector_valid;
reg [31:0] phase_unwrap_counter;

// Frequency detector
reg signed [FREQ_BITS-1:0] freq_detector_out;
reg freq_detector_valid;

// PID controller state
reg signed [PHASE_BITS-1:0] integral_accumulator;
reg signed [PHASE_BITS-1:0] prev_error;
reg signed [PHASE_BITS-1:0] derivative_estimate;
reg signed [PHASE_BITS-1:0] derivative_filtered;

// Phase history for prediction
reg signed [PHASE_BITS-1:0] phase_history [0:15];
reg [3:0] history_index;

// Lock detection and quality
reg [31:0] lock_counter;
reg [31:0] unlock_counter;
reg [31:0] phase_stable_counter;

// Statistics accumulators
reg [63:0] phase_sum;
reg [63:0] phase_sum_sq;
reg [63:0] freq_sum;
reg [63:0] freq_sum_sq;
reg [31:0] stats_counter;

// Allan deviation calculation
reg [63:0] allan_accumulator;
reg [31:0] allan_counter;

// MTIE tracking
reg signed [47:0] max_phase_error;
reg signed [47:0] min_phase_error;

// Reference edge detection
reg ref_pulse_d1, ref_pulse_d2, ref_pulse_d3;
wire ref_pulse_edge;

// Local time counter
reg [39:0] local_seconds;
reg [47:0] local_subseconds;  // Extended precision
reg [31:0] subsec_increment;

// Holdover state
reg [FREQ_BITS-1:0] holdover_frequency;
reg [31:0] holdover_timer;
reg signed [47:0] freq_drift_estimate;

// =============================================================================
// Constants
// =============================================================================

localparam LOCK_THRESHOLD_COARSE = 32'd100;
localparam LOCK_THRESHOLD_FINE = 32'd1000;
localparam UNLOCK_THRESHOLD = 32'd50;
localparam PHASE_TOLERANCE_COARSE = 48'd1000000;  // 10us
localparam PHASE_TOLERANCE_FINE = 48'd1000;       // 10ns
localparam FREQ_TOLERANCE = 48'd100;              // 1ppm

// NCO frequency for 100MHz clock to generate 1Hz
localparam [FREQ_BITS-1:0] NCO_FREQ_NOMINAL = 48'd42949672960000;  // Extended precision

// =============================================================================
// Reference edge detection with debouncing
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ref_pulse_d1 <= 1'b0;
        ref_pulse_d2 <= 1'b0;
        ref_pulse_d3 <= 1'b0;
    end else begin
        ref_pulse_d1 <= ref_pulse;
        ref_pulse_d2 <= ref_pulse_d1;
        ref_pulse_d3 <= ref_pulse_d2;
    end
end

assign ref_pulse_edge = ref_pulse_d2 && !ref_pulse_d3 && ref_valid;

// =============================================================================
// Local time counter with extended precision
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        local_seconds <= 40'd0;
        local_subseconds <= 48'd0;
        subsec_increment <= 32'd429496730;  // Base increment
    end else begin
        // Add frequency correction to subsecond counter
        local_subseconds <= local_subseconds + {16'd0, subsec_increment} + nco_freq_correction[31:0];
        
        // Check for second rollover
        if (local_subseconds >= 48'd100000000000000) begin  // 10^14
            local_seconds <= local_seconds + 1;
            local_subseconds <= local_subseconds - 48'd100000000000000;
        end
    end
end

// =============================================================================
// Phase Detector with unwrapping
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase_detector_out <= 48'd0;
        phase_detector_valid <= 1'b0;
        phase_unwrap_counter <= 32'd0;
    end else begin
        if (ref_pulse_edge) begin
            // Calculate phase error with extended precision
            reg signed [48:0] temp_error;
            reg [47:0] ref_subsec_extended;
            
            // Extend reference subseconds to 48 bits
            ref_subsec_extended = {ref_subseconds, 16'd0};
            
            // Calculate phase difference
            temp_error = $signed({1'b0, ref_subsec_extended}) - $signed({1'b0, local_subseconds});
            
            // Handle phase unwrapping
            if (temp_error > $signed(49'd50000000000000)) begin  // > 0.5 sec
                temp_error = temp_error - $signed(49'd100000000000000);
                phase_unwrap_counter <= phase_unwrap_counter + 1;
            end else if (temp_error < -$signed(49'd50000000000000)) begin  // < -0.5 sec
                temp_error = temp_error + $signed(49'd100000000000000);
                phase_unwrap_counter <= phase_unwrap_counter - 1;
            end
            
            phase_detector_out <= temp_error[47:0];
            phase_detector_valid <= 1'b1;
        end else begin
            phase_detector_valid <= 1'b0;
        end
    end
end

// =============================================================================
// Frequency Detector with filtering
// =============================================================================

reg signed [47:0] prev_phase_error;
reg [31:0] freq_update_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        freq_detector_out <= 48'd0;
        freq_detector_valid <= 1'b0;
        prev_phase_error <= 48'd0;
        freq_update_counter <= 32'd0;
    end else begin
        if (phase_detector_valid) begin
            freq_update_counter <= freq_update_counter + 1;
            
            if (freq_update_counter >= 32'd10) begin  // Update frequency every 10 samples
                // Calculate frequency error as phase change rate
                freq_detector_out <= (phase_detector_out - prev_phase_error) / 10;
                freq_detector_valid <= 1'b1;
                prev_phase_error <= phase_detector_out;
                freq_update_counter <= 32'd0;
            end else begin
                freq_detector_valid <= 1'b0;
            end
        end
    end
end

// =============================================================================
// PID Controller with anti-windup and derivative filtering
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        integral_accumulator <= 48'd0;
        prev_error <= 48'd0;
        derivative_estimate <= 48'd0;
        derivative_filtered <= 48'd0;
        p_term <= 48'd0;
        i_term <= 48'd0;
        d_term <= 48'd0;
        pid_output <= 48'd0;
    end else begin
        if (phase_detector_valid) begin
            // Proportional term
            p_term <= (phase_detector_out * $signed({16'd0, kp})) >>> FIXED_POINT_BITS;
            
            // Integral term with anti-windup
            reg signed [63:0] temp_integral;
            temp_integral = integral_accumulator + phase_detector_out;
            
            // Apply integral limits
            if (temp_integral > $signed({16'd0, integral_limit, 16'd0})) begin
                integral_accumulator <= $signed({16'd0, integral_limit, 16'd0});
            end else if (temp_integral < -$signed({16'd0, integral_limit, 16'd0})) begin
                integral_accumulator <= -$signed({16'd0, integral_limit, 16'd0});
            end else begin
                integral_accumulator <= temp_integral[47:0];
            end
            
            i_term <= (integral_accumulator * $signed({16'd0, ki})) >>> FIXED_POINT_BITS;
            
            // Derivative term with filtering
            derivative_estimate <= phase_detector_out - prev_error;
            
            // Apply low-pass filter to derivative
            derivative_filtered <= ((derivative_filtered * derivative_filter) + 
                                   (derivative_estimate * (16'd65535 - derivative_filter))) >>> 16;
            
            d_term <= (derivative_filtered * $signed({16'd0, kd})) >>> FIXED_POINT_BITS;
            
            // Calculate total PID output
            pid_output <= p_term + i_term + d_term;
            
            // Update previous error
            prev_error <= phase_detector_out;
        end
    end
end

// =============================================================================
// NCO Control with frequency correction
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        nco_phase <= 48'd0;
        nco_frequency <= NCO_FREQ_NOMINAL;
        nco_freq_nominal <= NCO_FREQ_NOMINAL;
        nco_freq_correction <= 48'd0;
    end else begin
        // Update NCO frequency based on PID output
        case (dpll_state)
            STATE_LOCKED, STATE_FINE_LOCK: begin
                // Apply PID correction with bandwidth limiting
                nco_freq_correction <= pid_output >>> loop_bandwidth;
            end
            
            STATE_HOLDOVER: begin
                // Use stored frequency with drift compensation
                nco_freq_correction <= holdover_frequency + freq_drift_estimate;
            end
            
            default: begin
                // Coarse frequency adjustment
                nco_freq_correction <= freq_detector_out << 2;
            end
        endcase
        
        // Update NCO phase
        nco_phase <= nco_phase + nco_frequency + nco_freq_correction;
    end
end

// =============================================================================
// Phase Prediction Algorithm
// =============================================================================

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 16; i = i + 1) begin
            phase_history[i] <= 48'd0;
        end
        history_index <= 4'd0;
        phase_prediction <= 48'd0;
    end else if (phase_detector_valid) begin
        // Store phase error in circular buffer
        phase_history[history_index] <= phase_detector_out;
        history_index <= history_index + 1;
        
        // Linear prediction based on history
        if (prediction_depth > 0) begin
            reg signed [63:0] sum_x, sum_y, sum_xy, sum_xx;
            reg signed [47:0] slope;
            
            sum_x = 0;
            sum_y = 0;
            sum_xy = 0;
            sum_xx = 0;
            
            // Calculate linear regression
            for (i = 0; i < prediction_depth && i < 16; i = i + 1) begin
                sum_x = sum_x + i;
                sum_y = sum_y + phase_history[i];
                sum_xy = sum_xy + i * phase_history[i];
                sum_xx = sum_xx + i * i;
            end
            
            // Calculate slope
            if (prediction_depth > 1) begin
                slope = (prediction_depth * sum_xy - sum_x * sum_y) / 
                        (prediction_depth * sum_xx - sum_x * sum_x);
                
                // Predict next phase
                phase_prediction <= phase_history[history_index-1] + slope;
            end
        end
    end
end

// =============================================================================
// Statistics and Quality Metrics
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase_sum <= 64'd0;
        phase_sum_sq <= 64'd0;
        freq_sum <= 64'd0;
        freq_sum_sq <= 64'd0;
        stats_counter <= 32'd0;
        phase_variance <= 48'd0;
        frequency_variance <= 48'd0;
        allan_accumulator <= 64'd0;
        allan_counter <= 32'd0;
        allan_deviation <= 32'd0;
        max_phase_error <= 48'd0;
        min_phase_error <= 48'd0;
        mtie <= 32'd0;
        tdev <= 32'd0;
    end else begin
        if (phase_detector_valid) begin
            // Update statistics
            stats_counter <= stats_counter + 1;
            phase_sum <= phase_sum + phase_detector_out;
            phase_sum_sq <= phase_sum_sq + phase_detector_out * phase_detector_out;
            
            // Calculate variance every 1000 samples
            if (stats_counter[9:0] == 10'd0) begin
                reg [63:0] mean, mean_sq;
                mean = phase_sum / stats_counter;
                mean_sq = phase_sum_sq / stats_counter;
                phase_variance <= mean_sq - mean * mean;
            end
            
            // Update MTIE
            if (phase_detector_out > max_phase_error) begin
                max_phase_error <= phase_detector_out;
            end
            if (phase_detector_out < min_phase_error) begin
                min_phase_error <= phase_detector_out;
            end
            mtie <= (max_phase_error - min_phase_error) >> 16;  // Convert to nanoseconds
            
            // Allan deviation calculation (simplified)
            if (allan_counter < 1000) begin
                allan_accumulator <= allan_accumulator + 
                    (phase_detector_out - prev_error) * (phase_detector_out - prev_error);
                allan_counter <= allan_counter + 1;
            end else begin
                allan_deviation <= allan_accumulator / (2 * allan_counter);
                allan_accumulator <= 64'd0;
                allan_counter <= 32'd0;
            end
        end
        
        if (freq_detector_valid) begin
            freq_sum <= freq_sum + freq_detector_out;
            freq_sum_sq <= freq_sum_sq + freq_detector_out * freq_detector_out;
            
            // Calculate frequency variance
            if (stats_counter[11:0] == 12'd0) begin
                reg [63:0] mean, mean_sq;
                mean = freq_sum / stats_counter;
                mean_sq = freq_sum_sq / stats_counter;
                frequency_variance <= mean_sq - mean * mean;
            end
        end
    end
end

// =============================================================================
// Lock Detection and State Machine with Adaptive Thresholds
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dpll_state <= STATE_UNLOCKED;
        dpll_locked <= 1'b0;
        lock_counter <= 32'd0;
        unlock_counter <= 32'd0;
        phase_stable_counter <= 32'd0;
        holdover_active <= 1'b0;
        holdover_timer <= 32'd0;
        holdover_frequency <= 48'd0;
        holdover_duration <= 32'd0;
        lock_quality <= 16'd0;
    end else begin
        case (dpll_state)
            
            STATE_UNLOCKED: begin
                dpll_locked <= 1'b0;
                holdover_active <= 1'b0;
                lock_quality <= 16'd0;
                
                if (ref_valid && phase_detector_valid) begin
                    dpll_state <= STATE_FREQ_ACQ;
                    lock_counter <= 32'd0;
                end
            end
            
            STATE_FREQ_ACQ: begin
                if (freq_detector_valid && (freq_detector_out < FREQ_TOLERANCE)) begin
                    lock_counter <= lock_counter + 1;
                    if (lock_counter >= LOCK_THRESHOLD_COARSE) begin
                        dpll_state <= STATE_PHASE_ACQ;
                        lock_counter <= 32'd0;
                    end
                end else begin
                    lock_counter <= 32'd0;
                end
                lock_quality <= 16'd1000;  // ~1.5%
            end
            
            STATE_PHASE_ACQ: begin
                if (phase_detector_valid && (phase_detector_out < PHASE_TOLERANCE_COARSE)) begin
                    lock_counter <= lock_counter + 1;
                    if (lock_counter >= LOCK_THRESHOLD_COARSE) begin
                        dpll_state <= STATE_FINE_LOCK;
                        lock_counter <= 32'd0;
                    end
                end else begin
                    if (lock_counter > 0) lock_counter <= lock_counter - 1;
                end
                lock_quality <= 16'd10000;  // ~15%
            end
            
            STATE_FINE_LOCK: begin
                if (phase_detector_valid && (phase_detector_out < PHASE_TOLERANCE_FINE)) begin
                    phase_stable_counter <= phase_stable_counter + 1;
                    if (phase_stable_counter >= LOCK_THRESHOLD_FINE) begin
                        dpll_state <= STATE_LOCKED;
                        dpll_locked <= 1'b1;
                        holdover_frequency <= nco_freq_correction;
                    end
                end else begin
                    if (phase_stable_counter > 0) phase_stable_counter <= phase_stable_counter - 1;
                end
                lock_quality <= 16'd30000;  // ~46%
            end
            
            STATE_LOCKED: begin
                dpll_locked <= 1'b1;
                lock_quality <= 16'd65535 - (phase_variance[31:16]);  // Dynamic quality
                
                // Monitor lock quality
                if (phase_detector_valid) begin
                    if (phase_detector_out > PHASE_TOLERANCE_FINE * 10) begin
                        unlock_counter <= unlock_counter + 1;
                        if (unlock_counter >= UNLOCK_THRESHOLD) begin
                            if (holdover_enable) begin
                                dpll_state <= STATE_HOLDOVER;
                                holdover_active <= 1'b1;
                                holdover_timer <= 32'd0;
                                holdover_duration <= 32'd0;
                                // Store current frequency and drift
                                holdover_frequency <= nco_freq_correction;
                                freq_drift_estimate <= (nco_freq_correction - holdover_frequency) / stats_counter;
                            end else begin
                                dpll_state <= STATE_PHASE_ACQ;
                                dpll_locked <= 1'b0;
                            end
                        end
                    end else begin
                        unlock_counter <= 16'd0;
                        // Update holdover frequency continuously
                        holdover_frequency <= (holdover_frequency * 15 + nco_freq_correction) >> 4;
                    end
                end
            end
            
            STATE_HOLDOVER: begin
                holdover_active <= 1'b1;
                holdover_timer <= holdover_timer + 1;
                
                // Update holdover duration in seconds
                if (holdover_timer >= CLK_FREQ_HZ) begin
                    holdover_duration <= holdover_duration + 1;
                    holdover_timer <= 32'd0;
                end
                
                // Calculate holdover quality based on time
                if (holdover_duration < 60) begin
                    holdover_quality <= 32'd1000000000 - holdover_duration * 16666667;  // Linear decay
                end else begin
                    holdover_quality <= 32'd0;  // Poor quality after 1 minute
                end
                
                // Try to reacquire lock
                if (phase_detector_valid && (phase_detector_out < PHASE_TOLERANCE_COARSE)) begin
                    dpll_state <= STATE_RECOVERY;
                    lock_counter <= 32'd0;
                end
            end
            
            STATE_RECOVERY: begin
                if (phase_detector_valid && (phase_detector_out < PHASE_TOLERANCE_FINE)) begin
                    lock_counter <= lock_counter + 1;
                    if (lock_counter >= LOCK_THRESHOLD_FINE / 2) begin
                        dpll_state <= STATE_LOCKED;
                        holdover_active <= 1'b0;
                        dpll_locked <= 1'b1;
                    end
                end else begin
                    lock_counter <= 32'd0;
                    dpll_state <= STATE_HOLDOVER;
                end
            end
            
            default: begin
                dpll_state <= STATE_UNLOCKED;
            end
        endcase
    end
end

// =============================================================================
// Adaptive Bandwidth Control
// =============================================================================

reg [15:0] adaptive_bandwidth;
reg [31:0] bandwidth_update_timer;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adaptive_bandwidth <= loop_bandwidth;
        bandwidth_update_timer <= 32'd0;
    end else if (adaptive_enable) begin
        bandwidth_update_timer <= bandwidth_update_timer + 1;
        
        if (bandwidth_update_timer >= CLK_FREQ_HZ / 10) begin  // Update every 100ms
            bandwidth_update_timer <= 32'd0;
            
            // Adjust bandwidth based on phase variance
            if (phase_variance < 48'd1000) begin
                // Low variance, narrow bandwidth
                if (adaptive_bandwidth < loop_bandwidth + 4)
                    adaptive_bandwidth <= adaptive_bandwidth + 1;
            end else if (phase_variance > 48'd100000) begin
                // High variance, wide bandwidth
                if (adaptive_bandwidth > loop_bandwidth - 4)
                    adaptive_bandwidth <= adaptive_bandwidth - 1;
            end else begin
                // Return to nominal
                if (adaptive_bandwidth > loop_bandwidth)
                    adaptive_bandwidth <= adaptive_bandwidth - 1;
                else if (adaptive_bandwidth < loop_bandwidth)
                    adaptive_bandwidth <= adaptive_bandwidth + 1;
            end
        end
    end else begin
        adaptive_bandwidth <= loop_bandwidth;
    end
end

// =============================================================================
// PPS Generation with compensation
// =============================================================================

reg [31:0] pps_counter;
reg pps_active;
reg [15:0] pps_compensation;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_out <= 1'b0;
        pps_counter <= 32'd0;
        pps_active <= 1'b0;
        pps_compensation <= 16'd0;
    end else begin
        // Calculate PPS compensation based on phase error
        if (dpll_locked) begin
            pps_compensation <= phase_detector_out[31:16];  // Convert to clock cycles
        end
        
        // Generate PPS when local second increments
        if (local_subseconds < subsec_increment && !pps_active) begin
            pps_out <= 1'b1;
            pps_active <= 1'b1;
            pps_counter <= pps_compensation;  // Apply phase compensation
        end else if (pps_active) begin
            if (pps_counter < 32'd10000) begin  // 100us pulse
                pps_counter <= pps_counter + 1;
                pps_out <= 1'b1;
            end else begin
                pps_out <= 1'b0;
                pps_active <= 1'b0;
            end
        end
    end
end

// =============================================================================
// Output assignments
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        locked_seconds <= 40'd0;
        locked_subseconds <= 32'd0;
        phase_error <= 48'd0;
        frequency_error <= 48'd0;
    end else begin
        locked_seconds <= local_seconds;
        locked_subseconds <= local_subseconds[47:16];  // Convert to 32-bit
        phase_error <= phase_detector_out;
        frequency_error <= freq_detector_out;
    end
end

endmodule