// =============================================================================
// External PPS Processor Module
// =============================================================================
// Description: Processes external PPS reference signal, measures its quality,
// and provides time alignment with internal time base
// =============================================================================

module external_pps_processor #(
    parameter CLK_FREQ = 100_000_000,        // System clock frequency
    parameter MEASUREMENT_WINDOW = 1000,     // Measurement window in ms
    parameter JITTER_THRESHOLD = 1000        // Jitter threshold in ns
)(
    // Clock and reset
    input  wire        clk,                  // System clock (100 MHz)
    input  wire        rst_n,                // Active low reset
    
    // External PPS input
    input  wire        ext_pps_in,           // External PPS input signal
    
    // Reference time input (from internal source)
    input  wire [39:0] ref_seconds,          // Reference time seconds
    input  wire [31:0] ref_subseconds,       // Reference time subseconds
    input  wire        ref_time_valid,       // Reference time valid
    
    // Processed outputs
    output reg         ext_pps_out,          // Cleaned PPS output
    output reg  [39:0] ext_seconds,          // Aligned time seconds
    output reg  [31:0] ext_subseconds,       // Aligned time subseconds
    output reg         ext_valid,            // External PPS valid
    output reg  [15:0] ext_quality,          // Quality metric (0-65535)
    
    // Measurement outputs
    output reg  [31:0] frequency_offset,     // Frequency offset in ppb
    output reg  [31:0] phase_offset,         // Phase offset in ns
    output reg  [31:0] jitter_rms,           // RMS jitter in ns
    output reg  [31:0] pulse_width,          // Pulse width in ns
    output reg  [31:0] pulse_period,         // Measured period in ns
    
    // Status outputs
    output reg         signal_present,       // External signal detected
    output reg         frequency_locked,     // Frequency within tolerance
    output reg         phase_locked,         // Phase aligned
    output reg  [7:0]  lock_counter,         // Lock quality counter
    output reg  [31:0] missed_pulses         // Count of missed pulses
);

// =============================================================================
// Internal signals
// =============================================================================

// Edge detection
reg  ext_pps_d1, ext_pps_d2, ext_pps_d3;
wire ext_pps_rising;
wire ext_pps_falling;

// Timing measurement
reg  [31:0] edge_timestamp;
reg  [31:0] last_edge_timestamp;
reg  [31:0] period_accumulator;
reg  [15:0] period_count;
reg  [31:0] period_average;

// Pulse width measurement
reg  [31:0] pulse_start_time;
reg  [31:0] pulse_width_accum;
reg  [15:0] pulse_count;

// Phase measurement
reg  signed [31:0] phase_error;
reg  signed [31:0] phase_error_accum;
reg  [15:0] phase_error_count;
reg  signed [31:0] phase_error_filtered;

// Jitter measurement
reg  signed [31:0] jitter_accum;
reg  signed [63:0] jitter_squared_accum;
reg  [15:0] jitter_count;

// Frequency measurement
reg  [31:0] freq_counter;
reg  [31:0] freq_measurement_time;
reg  [31:0] pps_count_in_window;
reg  [31:0] expected_pps_count;

// Quality calculation
reg  [15:0] quality_score;
reg  [7:0]  consecutive_good;
reg  [7:0]  consecutive_bad;

// State machine
reg  [2:0]  state;
reg  [2:0]  next_state;

localparam STATE_IDLE        = 3'b000;
localparam STATE_DETECTING   = 3'b001;
localparam STATE_MEASURING   = 3'b010;
localparam STATE_LOCKING     = 3'b011;
localparam STATE_LOCKED      = 3'b100;
localparam STATE_HOLDOVER    = 3'b101;

// Timeout and watchdog
reg  [31:0] timeout_counter;
reg  [31:0] last_pps_time;

// =============================================================================
// Edge detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ext_pps_d1 <= 1'b0;
        ext_pps_d2 <= 1'b0;
        ext_pps_d3 <= 1'b0;
    end else begin
        ext_pps_d1 <= ext_pps_in;
        ext_pps_d2 <= ext_pps_d1;
        ext_pps_d3 <= ext_pps_d2;
    end
end

assign ext_pps_rising  = ext_pps_d2 && !ext_pps_d3;
assign ext_pps_falling = !ext_pps_d2 && ext_pps_d3;

// =============================================================================
// Timestamp capture
// =============================================================================

reg [31:0] free_running_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        free_running_counter <= 32'd0;
    end else begin
        free_running_counter <= free_running_counter + 1;
    end
end

// =============================================================================
// Period measurement
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        edge_timestamp <= 32'd0;
        last_edge_timestamp <= 32'd0;
        period_accumulator <= 32'd0;
        period_count <= 16'd0;
        period_average <= 32'd100_000_000; // 1 second nominal
    end else begin
        if (ext_pps_rising) begin
            last_edge_timestamp <= edge_timestamp;
            edge_timestamp <= free_running_counter;
            
            if (state >= STATE_MEASURING) begin
                // Calculate period
                if (edge_timestamp > last_edge_timestamp) begin
                    period_accumulator <= period_accumulator + (edge_timestamp - last_edge_timestamp);
                    period_count <= period_count + 1;
                    
                    // Update average every 16 measurements
                    if (period_count[3:0] == 4'hF) begin
                        period_average <= period_accumulator >> 4;
                        period_accumulator <= 32'd0;
                        period_count <= 16'd0;
                    end
                end
            end
        end
    end
end

// =============================================================================
// Pulse width measurement
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pulse_start_time <= 32'd0;
        pulse_width_accum <= 32'd0;
        pulse_count <= 16'd0;
        pulse_width <= 32'd0;
    end else begin
        if (ext_pps_rising) begin
            pulse_start_time <= free_running_counter;
        end
        
        if (ext_pps_falling && (state >= STATE_MEASURING)) begin
            if (free_running_counter > pulse_start_time) begin
                pulse_width_accum <= pulse_width_accum + (free_running_counter - pulse_start_time);
                pulse_count <= pulse_count + 1;
                
                // Update average
                if (pulse_count[3:0] == 4'hF) begin
                    pulse_width <= (pulse_width_accum >> 4) * 10; // Convert to ns
                    pulse_width_accum <= 32'd0;
                    pulse_count <= 16'd0;
                end
            end
        end
    end
end

// =============================================================================
// Phase measurement
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase_error <= 32'd0;
        phase_error_accum <= 32'd0;
        phase_error_count <= 16'd0;
        phase_error_filtered <= 32'd0;
    end else begin
        if (ext_pps_rising && ref_time_valid) begin
            // Calculate phase error (expected vs actual)
            phase_error <= $signed(ref_subseconds) - $signed({22'd0, free_running_counter[9:0]});
            
            if (state >= STATE_LOCKING) begin
                phase_error_accum <= phase_error_accum + phase_error;
                phase_error_count <= phase_error_count + 1;
                
                // Update filtered value
                if (phase_error_count[3:0] == 4'hF) begin
                    phase_error_filtered <= phase_error_accum >>> 4;
                    phase_offset <= (phase_error_accum >>> 4) * 10; // Convert to ns
                end
            end
        end
    end
end

// =============================================================================
// Jitter measurement
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        jitter_accum <= 32'd0;
        jitter_squared_accum <= 64'd0;
        jitter_count <= 16'd0;
        jitter_rms <= 32'd0;
    end else begin
        if (ext_pps_rising && (state == STATE_LOCKED)) begin
            // Calculate instantaneous jitter
            reg signed [31:0] instant_jitter;
            instant_jitter = phase_error - phase_error_filtered;
            
            jitter_accum <= jitter_accum + instant_jitter;
            jitter_squared_accum <= jitter_squared_accum + (instant_jitter * instant_jitter);
            jitter_count <= jitter_count + 1;
            
            // Calculate RMS jitter
            if (jitter_count == 16'd1000) begin
                // RMS = sqrt(sum(x^2)/n)
                // Simplified calculation
                jitter_rms <= jitter_squared_accum[31:0] / 1000;
                jitter_accum <= 32'd0;
                jitter_squared_accum <= 64'd0;
                jitter_count <= 16'd0;
            end
        end
    end
end

// =============================================================================
// Frequency measurement
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        freq_counter <= 32'd0;
        freq_measurement_time <= 32'd0;
        pps_count_in_window <= 32'd0;
        expected_pps_count <= 32'd0;
        frequency_offset <= 32'd0;
    end else begin
        freq_counter <= freq_counter + 1;
        
        if (ext_pps_rising) begin
            pps_count_in_window <= pps_count_in_window + 1;
        end
        
        // Measure over MEASUREMENT_WINDOW ms
        if (freq_counter >= (CLK_FREQ / 1000 * MEASUREMENT_WINDOW)) begin
            freq_counter <= 32'd0;
            expected_pps_count <= MEASUREMENT_WINDOW / 1000;
            
            // Calculate frequency offset in ppb
            if (pps_count_in_window > 0) begin
                frequency_offset <= ((pps_count_in_window - expected_pps_count) * 1_000_000_000) / expected_pps_count;
            end
            
            pps_count_in_window <= 32'd0;
        end
    end
end

// =============================================================================
// Signal presence detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timeout_counter <= 32'd0;
        last_pps_time <= 32'd0;
        signal_present <= 1'b0;
        missed_pulses <= 32'd0;
    end else begin
        timeout_counter <= timeout_counter + 1;
        
        if (ext_pps_rising) begin
            last_pps_time <= free_running_counter;
            timeout_counter <= 32'd0;
            signal_present <= 1'b1;
        end
        
        // Check for timeout (2 seconds)
        if (timeout_counter > 32'd200_000_000) begin
            signal_present <= 1'b0;
            missed_pulses <= missed_pulses + 1;
        end
    end
end

// =============================================================================
// Quality calculation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        quality_score <= 16'd0;
        consecutive_good <= 8'd0;
        consecutive_bad <= 8'd0;
        frequency_locked <= 1'b0;
        phase_locked <= 1'b0;
    end else begin
        if (state >= STATE_MEASURING) begin
            // Check frequency lock (within 100 ppb)
            frequency_locked <= (frequency_offset < 32'd100) && (frequency_offset > -32'd100);
            
            // Check phase lock (within 100 ns)
            phase_locked <= (phase_offset < 32'd100) && (phase_offset > -32'd100);
            
            // Update quality counters
            if (frequency_locked && phase_locked && (jitter_rms < JITTER_THRESHOLD)) begin
                consecutive_good <= (consecutive_good < 8'd255) ? consecutive_good + 1 : 8'd255;
                consecutive_bad <= 8'd0;
            end else begin
                consecutive_bad <= (consecutive_bad < 8'd255) ? consecutive_bad + 1 : 8'd255;
                consecutive_good <= 8'd0;
            end
            
            // Calculate quality score (0-65535)
            quality_score <= {consecutive_good, 8'd0} - {consecutive_bad, 4'd0};
        end
    end
end

// =============================================================================
// State machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= STATE_IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        STATE_IDLE: begin
            if (signal_present) begin
                next_state = STATE_DETECTING;
            end
        end
        
        STATE_DETECTING: begin
            if (!signal_present) begin
                next_state = STATE_IDLE;
            end else if (period_count > 16'd10) begin
                next_state = STATE_MEASURING;
            end
        end
        
        STATE_MEASURING: begin
            if (!signal_present) begin
                next_state = STATE_HOLDOVER;
            end else if (frequency_locked) begin
                next_state = STATE_LOCKING;
            end
        end
        
        STATE_LOCKING: begin
            if (!signal_present) begin
                next_state = STATE_HOLDOVER;
            end else if (phase_locked && (consecutive_good > 8'd10)) begin
                next_state = STATE_LOCKED;
            end else if (consecutive_bad > 8'd50) begin
                next_state = STATE_MEASURING;
            end
        end
        
        STATE_LOCKED: begin
            if (!signal_present) begin
                next_state = STATE_HOLDOVER;
            end else if (!frequency_locked || !phase_locked) begin
                next_state = STATE_LOCKING;
            end
        end
        
        STATE_HOLDOVER: begin
            if (signal_present) begin
                next_state = STATE_DETECTING;
            end
        end
        
        default: next_state = STATE_IDLE;
    endcase
end

// =============================================================================
// Output generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ext_pps_out <= 1'b0;
        ext_seconds <= 40'd0;
        ext_subseconds <= 32'd0;
        ext_valid <= 1'b0;
        ext_quality <= 16'd0;
        lock_counter <= 8'd0;
        pulse_period <= 32'd0;
    end else begin
        // Generate cleaned PPS output
        ext_pps_out <= ext_pps_d2 && (state >= STATE_LOCKING);
        
        // Update time outputs
        if (ext_pps_rising && ref_time_valid) begin
            ext_seconds <= ref_seconds + 1;  // Next second
            ext_subseconds <= 32'd0;
        end else if (ref_time_valid) begin
            ext_subseconds <= ref_subseconds;
        end
        
        // Update validity and quality
        ext_valid <= (state >= STATE_LOCKING) && signal_present;
        ext_quality <= quality_score;
        
        // Update lock counter
        if (state == STATE_LOCKED) begin
            lock_counter <= (lock_counter < 8'd255) ? lock_counter + 1 : 8'd255;
        end else begin
            lock_counter <= 8'd0;
        end
        
        // Convert period to ns
        pulse_period <= period_average * 10;
    end
end

endmodule