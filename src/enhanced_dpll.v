// =============================================================================
// Enhanced Digital Phase-Locked Loop (DPLL) Module
// =============================================================================
// Description: Advanced DPLL with PI controller and adaptive bandwidth
// Provides high-precision phase and frequency synchronization
// =============================================================================

module enhanced_dpll #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter PHASE_BITS = 32,
    parameter FREQ_BITS = 32
)(
    input  wire        clk,
    input  wire        rst_n,
    
    // Reference input
    input  wire        ref_pulse,            // Reference PPS pulse
    input  wire [39:0] ref_seconds,          // Reference time
    input  wire [31:0] ref_subseconds,
    
    // Local oscillator input
    input  wire        local_clk,            // Local oscillator (10MHz from SiT5503)
    
    // Control parameters
    input  wire [15:0] kp,                   // Proportional gain
    input  wire [15:0] ki,                   // Integral gain
    input  wire [15:0] bandwidth,            // Loop bandwidth control
    input  wire        adaptive_enable,      // Enable adaptive bandwidth
    
    // Outputs
    output reg         pps_out,              // Synchronized PPS output
    output reg  [39:0] locked_seconds,       // Locked time output
    output reg  [31:0] locked_subseconds,
    output reg  [31:0] phase_error,          // Current phase error
    output reg  [31:0] frequency_error,      // Current frequency error
    output reg         dpll_locked,          // Lock indicator
    output reg  [3:0]  dpll_state,
    
    // Holdover mode
    output reg         holdover_active,      // In holdover mode
    output reg  [31:0] holdover_quality      // Holdover performance metric
);

// =============================================================================
// State definitions
// =============================================================================

localparam STATE_UNLOCKED    = 4'd0;
localparam STATE_FREQ_LOCK   = 4'd1;
localparam STATE_PHASE_LOCK  = 4'd2;
localparam STATE_LOCKED      = 4'd3;
localparam STATE_HOLDOVER    = 4'd4;

// =============================================================================
// Internal signals
// =============================================================================

// NCO (Numerically Controlled Oscillator)
reg [PHASE_BITS-1:0] nco_phase;
reg [FREQ_BITS-1:0]  nco_frequency;
reg [FREQ_BITS-1:0]  nco_freq_nominal;

// Phase detector
reg signed [PHASE_BITS-1:0] phase_detector_out;
reg phase_detector_valid;

// Frequency detector
reg signed [FREQ_BITS-1:0] freq_detector_out;
reg freq_detector_valid;

// PI controller state
reg signed [PHASE_BITS-1:0] integral_error;
reg signed [PHASE_BITS-1:0] proportional_error;
reg signed [FREQ_BITS-1:0] control_output;

// Lock detection
reg [15:0] lock_counter;
reg [15:0] unlock_counter;
reg [31:0] phase_variance;

// Adaptive bandwidth control
reg [15:0] current_bandwidth;
reg [15:0] bandwidth_timer;

// Holdover state
reg [FREQ_BITS-1:0] holdover_frequency;
reg [31:0] holdover_timer;
reg [31:0] last_good_timestamp;

// Reference edge detection
reg ref_pulse_d1, ref_pulse_d2;
wire ref_pulse_edge;

// Local time counter
reg [39:0] local_seconds;
reg [31:0] local_subseconds;
reg [31:0] subsec_accumulator;

// =============================================================================
// Constants
// =============================================================================

localparam LOCK_THRESHOLD = 16'd1000;      // Lock after 1000 good samples
localparam UNLOCK_THRESHOLD = 16'd100;     // Unlock after 100 bad samples
localparam PHASE_LOCK_TOLERANCE = 32'd1000; // ±10us phase tolerance
localparam FREQ_LOCK_TOLERANCE = 32'd100;   // ±1ppm frequency tolerance
localparam HOLDOVER_TIMEOUT = 32'd500_000_000; // 5 seconds

// NCO frequency for 100MHz clock to generate 1Hz
localparam NCO_FREQ_NOMINAL = 32'd42949673; // 2^32 / 100e6

// =============================================================================
// Reference edge detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ref_pulse_d1 <= 1'b0;
        ref_pulse_d2 <= 1'b0;
    end else begin
        ref_pulse_d1 <= ref_pulse;
        ref_pulse_d2 <= ref_pulse_d1;
    end
end

assign ref_pulse_edge = ref_pulse_d1 && !ref_pulse_d2;

// =============================================================================
// Local time counter
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        local_seconds <= 40'd0;
        local_subseconds <= 32'd0;
        subsec_accumulator <= 32'd0;
    end else begin
        // Increment subseconds
        subsec_accumulator <= subsec_accumulator + nco_frequency;
        
        // Check for second rollover
        if (subsec_accumulator < nco_frequency) begin
            local_seconds <= local_seconds + 1;
            local_subseconds <= subsec_accumulator;
        end
    end
end

// =============================================================================
// Phase Detector
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase_detector_out <= 32'd0;
        phase_detector_valid <= 1'b0;
    end else begin
        if (ref_pulse_edge) begin
            // Calculate phase error between reference and local
            reg signed [32:0] temp_error;
            
            if (ref_subseconds >= local_subseconds) begin
                temp_error = ref_subseconds - local_subseconds;
            end else begin
                temp_error = -(local_subseconds - ref_subseconds);
            end
            
            phase_detector_out <= temp_error[31:0];
            phase_detector_valid <= 1'b1;
        end else begin
            phase_detector_valid <= 1'b0;
        end
    end
end

// =============================================================================
// Frequency Detector
// =============================================================================

reg [39:0] prev_ref_seconds;
reg [31:0] prev_ref_subseconds;
reg        first_ref_sample;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        freq_detector_out <= 32'd0;
        freq_detector_valid <= 1'b0;
        prev_ref_seconds <= 40'd0;
        prev_ref_subseconds <= 32'd0;
        first_ref_sample <= 1'b1;
    end else begin
        if (ref_pulse_edge) begin
            if (!first_ref_sample) begin
                // Calculate frequency error
                reg [40:0] ref_delta;
                reg [40:0] local_delta;
                
                ref_delta = {1'b0, ref_seconds} - {1'b0, prev_ref_seconds};
                local_delta = {1'b0, local_seconds} - {1'b0, prev_ref_seconds};
                
                freq_detector_out <= (ref_delta - local_delta);
                freq_detector_valid <= 1'b1;
            end else begin
                first_ref_sample <= 1'b0;
            end
            
            prev_ref_seconds <= ref_seconds;
            prev_ref_subseconds <= ref_subseconds;
        end else begin
            freq_detector_valid <= 1'b0;
        end
    end
end

// =============================================================================
// PI Controller
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        integral_error <= 32'd0;
        proportional_error <= 32'd0;
        control_output <= 32'd0;
    end else begin
        if (phase_detector_valid) begin
            // Proportional term
            proportional_error <= phase_detector_out;
            
            // Integral term with anti-windup
            reg signed [33:0] temp_integral;
            temp_integral = integral_error + phase_detector_out;
            
            // Limit integral term
            if (temp_integral > 32'h7FFFFFFF) begin
                integral_error <= 32'h7FFFFFFF;
            end else if (temp_integral < -32'h80000000) begin
                integral_error <= -32'h80000000;
            end else begin
                integral_error <= temp_integral[31:0];
            end
            
            // Calculate control output
            reg signed [47:0] temp_control;
            temp_control = (kp * proportional_error) + (ki * integral_error);
            
            // Apply bandwidth limiting
            control_output <= temp_control >> current_bandwidth;
        end
    end
end

// =============================================================================
// NCO Control
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        nco_phase <= 32'd0;
        nco_frequency <= NCO_FREQ_NOMINAL;
        nco_freq_nominal <= NCO_FREQ_NOMINAL;
    end else begin
        // Update NCO frequency based on control output
        if (dpll_state == STATE_LOCKED || dpll_state == STATE_PHASE_LOCK) begin
            nco_frequency <= nco_freq_nominal + control_output;
        end else if (dpll_state == STATE_HOLDOVER) begin
            nco_frequency <= holdover_frequency;
        end else begin
            nco_frequency <= nco_freq_nominal;
        end
        
        // Update NCO phase
        nco_phase <= nco_phase + nco_frequency;
    end
end

// =============================================================================
// PPS Generation
// =============================================================================

reg [31:0] pps_counter;
reg pps_active;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_out <= 1'b0;
        pps_counter <= 32'd0;
        pps_active <= 1'b0;
    end else begin
        // Generate PPS when NCO phase wraps
        if (nco_phase < nco_frequency && !pps_active) begin
            pps_out <= 1'b1;
            pps_active <= 1'b1;
            pps_counter <= 32'd0;
        end else if (pps_active) begin
            pps_counter <= pps_counter + 1;
            if (pps_counter >= 32'd10000) begin  // 100us pulse width
                pps_out <= 1'b0;
                pps_active <= 1'b0;
            end
        end
    end
end

// =============================================================================
// Lock Detection and State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dpll_state <= STATE_UNLOCKED;
        dpll_locked <= 1'b0;
        lock_counter <= 16'd0;
        unlock_counter <= 16'd0;
        holdover_active <= 1'b0;
        holdover_timer <= 32'd0;
        holdover_frequency <= NCO_FREQ_NOMINAL;
    end else begin
        case (dpll_state)
            
            STATE_UNLOCKED: begin
                dpll_locked <= 1'b0;
                holdover_active <= 1'b0;
                
                if (freq_detector_valid && 
                    (freq_detector_out < FREQ_LOCK_TOLERANCE)) begin
                    dpll_state <= STATE_FREQ_LOCK;
                    lock_counter <= 16'd0;
                end
            end
            
            STATE_FREQ_LOCK: begin
                if (phase_detector_valid && 
                    (phase_detector_out < PHASE_LOCK_TOLERANCE)) begin
                    lock_counter <= lock_counter + 1;
                    if (lock_counter >= LOCK_THRESHOLD/2) begin
                        dpll_state <= STATE_PHASE_LOCK;
                    end
                end else begin
                    lock_counter <= 16'd0;
                    unlock_counter <= unlock_counter + 1;
                    if (unlock_counter >= UNLOCK_THRESHOLD) begin
                        dpll_state <= STATE_UNLOCKED;
                    end
                end
            end
            
            STATE_PHASE_LOCK: begin
                if (phase_detector_valid && 
                    (phase_detector_out < PHASE_LOCK_TOLERANCE/10)) begin
                    lock_counter <= lock_counter + 1;
                    if (lock_counter >= LOCK_THRESHOLD) begin
                        dpll_state <= STATE_LOCKED;
                        dpll_locked <= 1'b1;
                        holdover_frequency <= nco_frequency;
                    end
                end else begin
                    lock_counter <= lock_counter >> 1;  // Decay slowly
                end
            end
            
            STATE_LOCKED: begin
                dpll_locked <= 1'b1;
                
                // Monitor lock quality
                if (phase_detector_valid) begin
                    if (phase_detector_out > PHASE_LOCK_TOLERANCE) begin
                        unlock_counter <= unlock_counter + 1;
                        if (unlock_counter >= UNLOCK_THRESHOLD) begin
                            dpll_state <= STATE_HOLDOVER;
                            holdover_active <= 1'b1;
                            holdover_timer <= 32'd0;
                        end
                    end else begin
                        unlock_counter <= 16'd0;
                        // Update holdover frequency with current good frequency
                        holdover_frequency <= nco_frequency;
                        last_good_timestamp <= {ref_seconds[7:0], ref_subseconds[31:8]};
                    end
                end
            end
            
            STATE_HOLDOVER: begin
                holdover_active <= 1'b1;
                holdover_timer <= holdover_timer + 1;
                
                // Try to reacquire lock
                if (phase_detector_valid && 
                    (phase_detector_out < PHASE_LOCK_TOLERANCE)) begin
                    dpll_state <= STATE_PHASE_LOCK;
                    holdover_active <= 1'b0;
                    lock_counter <= 16'd0;
                end else if (holdover_timer >= HOLDOVER_TIMEOUT) begin
                    // Holdover timeout, return to unlocked
                    dpll_state <= STATE_UNLOCKED;
                    dpll_locked <= 1'b0;
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

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_bandwidth <= bandwidth;
        bandwidth_timer <= 16'd0;
        phase_variance <= 32'd0;
    end else if (adaptive_enable) begin
        if (phase_detector_valid) begin
            // Calculate phase variance (simplified)
            reg [31:0] abs_phase_error;
            abs_phase_error = (phase_detector_out[31]) ? 
                              -phase_detector_out : phase_detector_out;
            
            // Update variance estimate (IIR filter)
            phase_variance <= (phase_variance * 7 + abs_phase_error) >> 3;
            
            // Adjust bandwidth based on variance
            bandwidth_timer <= bandwidth_timer + 1;
            if (bandwidth_timer >= 16'd10000) begin  // Update every 100ms
                bandwidth_timer <= 16'd0;
                
                if (phase_variance < 32'd100) begin
                    // Low variance, reduce bandwidth
                    if (current_bandwidth < bandwidth + 4)
                        current_bandwidth <= current_bandwidth + 1;
                end else if (phase_variance > 32'd1000) begin
                    // High variance, increase bandwidth
                    if (current_bandwidth > bandwidth - 4)
                        current_bandwidth <= current_bandwidth - 1;
                end
            end
        end
    end else begin
        current_bandwidth <= bandwidth;
    end
end

// =============================================================================
// Output assignments
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        locked_seconds <= 40'd0;
        locked_subseconds <= 32'd0;
        phase_error <= 32'd0;
        frequency_error <= 32'd0;
        holdover_quality <= 32'd0;
    end else begin
        locked_seconds <= local_seconds;
        locked_subseconds <= local_subseconds;
        phase_error <= phase_detector_out;
        frequency_error <= freq_detector_out;
        
        // Calculate holdover quality metric
        if (holdover_active) begin
            holdover_quality <= HOLDOVER_TIMEOUT - holdover_timer;
        end else begin
            holdover_quality <= 32'hFFFFFFFF;  // Best quality when not in holdover
        end
    end
end

endmodule