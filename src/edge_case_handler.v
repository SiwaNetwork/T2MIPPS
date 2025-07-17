// =============================================================================
// Edge Case Handler Module
// =============================================================================
// Description: Handles edge cases and exceptional conditions for T2MI PPS
// Provides additional validation and error recovery mechanisms
// =============================================================================

module edge_case_handler (
    input  wire        clk,
    input  wire        rst_n,
    
    // Input monitoring
    input  wire        t2mi_valid,
    input  wire [7:0]  t2mi_data,
    input  wire        sync_locked,
    input  wire        parser_error,
    
    // Timestamp monitoring
    input  wire        timestamp_valid,
    input  wire [39:0] seconds_since_2000,
    input  wire [31:0] subseconds,
    
    // PPS monitoring
    input  wire        pps_pulse,
    input  wire        pps_error,
    
    // Control outputs
    output reg         force_resync,
    output reg         timestamp_override,
    output reg [39:0]  override_seconds,
    output reg [31:0]  override_subseconds,
    
    // Status outputs
    output reg [7:0]   edge_case_flags,
    output reg [31:0]  error_counter,
    output reg         watchdog_timeout
);

// =============================================================================
// Parameters
// =============================================================================

// Timeout values
parameter SYNC_LOSS_TIMEOUT = 32'd500_000_000;  // 5 seconds at 100MHz
parameter PPS_TIMEOUT = 32'd150_000_000;        // 1.5 seconds
parameter DATA_TIMEOUT = 32'd100_000_000;       // 1 second

// Sanity check limits
parameter MAX_TIME_JUMP = 40'd3600;             // 1 hour maximum jump
parameter MIN_YEAR = 40'd0;                     // Year 2000
parameter MAX_YEAR = 40'd2_524_608_000;         // Year 2080 (80 years)

// Error thresholds
parameter MAX_CONSECUTIVE_ERRORS = 16'd100;
parameter PARSER_ERROR_THRESHOLD = 16'd10;

// =============================================================================
// Internal Registers
// =============================================================================

// Timers
reg [31:0] sync_loss_timer;
reg [31:0] pps_timeout_timer;
reg [31:0] data_timeout_timer;
reg [31:0] watchdog_timer;

// Error tracking
reg [15:0] consecutive_errors;
reg [15:0] parser_error_count;
reg [15:0] timestamp_error_count;

// State tracking
reg        last_sync_locked;
reg        last_pps_pulse;
reg [39:0] last_valid_seconds;
reg [31:0] last_valid_subseconds;
reg        time_initialized;

// Edge case detection
reg        sync_loss_detected;
reg        pps_loss_detected;
reg        data_loss_detected;
reg        time_jump_detected;
reg        invalid_time_detected;
reg        overflow_detected;
reg        underflow_detected;
reg        rapid_error_detected;

// =============================================================================
// Sync Loss Detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_loss_timer <= 32'd0;
        sync_loss_detected <= 1'b0;
        last_sync_locked <= 1'b0;
    end else begin
        last_sync_locked <= sync_locked;
        
        if (sync_locked) begin
            sync_loss_timer <= 32'd0;
            sync_loss_detected <= 1'b0;
        end else if (last_sync_locked && !sync_locked) begin
            // Just lost sync
            sync_loss_timer <= 32'd1;
        end else if (sync_loss_timer > 32'd0 && sync_loss_timer < SYNC_LOSS_TIMEOUT) begin
            sync_loss_timer <= sync_loss_timer + 1'b1;
        end else if (sync_loss_timer >= SYNC_LOSS_TIMEOUT) begin
            sync_loss_detected <= 1'b1;
        end
    end
end

// =============================================================================
// PPS Timeout Detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_timeout_timer <= 32'd0;
        pps_loss_detected <= 1'b0;
        last_pps_pulse <= 1'b0;
    end else begin
        last_pps_pulse <= pps_pulse;
        
        if (pps_pulse && !last_pps_pulse) begin
            // PPS pulse detected
            pps_timeout_timer <= 32'd0;
            pps_loss_detected <= 1'b0;
        end else if (pps_timeout_timer < PPS_TIMEOUT) begin
            pps_timeout_timer <= pps_timeout_timer + 1'b1;
        end else begin
            pps_loss_detected <= 1'b1;
        end
    end
end

// =============================================================================
// Data Flow Monitoring
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_timeout_timer <= 32'd0;
        data_loss_detected <= 1'b0;
    end else begin
        if (t2mi_valid) begin
            data_timeout_timer <= 32'd0;
            data_loss_detected <= 1'b0;
        end else if (data_timeout_timer < DATA_TIMEOUT) begin
            data_timeout_timer <= data_timeout_timer + 1'b1;
        end else begin
            data_loss_detected <= 1'b1;
        end
    end
end

// =============================================================================
// Timestamp Validation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        time_jump_detected <= 1'b0;
        invalid_time_detected <= 1'b0;
        last_valid_seconds <= 40'd0;
        last_valid_subseconds <= 32'd0;
        time_initialized <= 1'b0;
    end else begin
        if (timestamp_valid) begin
            // Check for reasonable time range
            if (seconds_since_2000 < MIN_YEAR || seconds_since_2000 > MAX_YEAR) begin
                invalid_time_detected <= 1'b1;
            end else begin
                invalid_time_detected <= 1'b0;
            end
            
            // Check for time jumps
            if (time_initialized) begin
                if (seconds_since_2000 > last_valid_seconds) begin
                    if ((seconds_since_2000 - last_valid_seconds) > MAX_TIME_JUMP) begin
                        time_jump_detected <= 1'b1;
                    end else begin
                        time_jump_detected <= 1'b0;
                    end
                end else if (last_valid_seconds > seconds_since_2000) begin
                    if ((last_valid_seconds - seconds_since_2000) > MAX_TIME_JUMP) begin
                        time_jump_detected <= 1'b1;
                    end else begin
                        time_jump_detected <= 1'b0;
                    end
                end
            end
            
            // Update last valid time
            if (!invalid_time_detected && !time_jump_detected) begin
                last_valid_seconds <= seconds_since_2000;
                last_valid_subseconds <= subseconds;
                time_initialized <= 1'b1;
            end
        end
    end
end

// =============================================================================
// Error Rate Monitoring
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        consecutive_errors <= 16'd0;
        parser_error_count <= 16'd0;
        timestamp_error_count <= 16'd0;
        rapid_error_detected <= 1'b0;
    end else begin
        // Count parser errors
        if (parser_error) begin
            if (parser_error_count < 16'hFFFF) begin
                parser_error_count <= parser_error_count + 1'b1;
            end
        end
        
        // Count consecutive errors
        if (parser_error || pps_error || invalid_time_detected) begin
            if (consecutive_errors < MAX_CONSECUTIVE_ERRORS) begin
                consecutive_errors <= consecutive_errors + 1'b1;
            end else begin
                rapid_error_detected <= 1'b1;
            end
        end else if (timestamp_valid && !invalid_time_detected) begin
            consecutive_errors <= 16'd0;
            rapid_error_detected <= 1'b0;
        end
    end
end

// =============================================================================
// Overflow/Underflow Detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        overflow_detected <= 1'b0;
        underflow_detected <= 1'b0;
    end else begin
        // Check for seconds overflow (approaching year 2080)
        if (seconds_since_2000 > (MAX_YEAR - 40'd31536000)) begin  // Within 1 year
            overflow_detected <= 1'b1;
        end else begin
            overflow_detected <= 1'b0;
        end
        
        // Check for subseconds overflow
        if (subseconds > 32'hFFFFF000) begin  // Very close to overflow
            underflow_detected <= 1'b1;
        end else begin
            underflow_detected <= 1'b0;
        end
    end
end

// =============================================================================
// Watchdog Timer
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        watchdog_timer <= 32'd0;
        watchdog_timeout <= 1'b0;
    end else begin
        // Reset watchdog on any valid activity
        if (timestamp_valid || pps_pulse || (t2mi_valid && sync_locked)) begin
            watchdog_timer <= 32'd0;
            watchdog_timeout <= 1'b0;
        end else if (watchdog_timer < SYNC_LOSS_TIMEOUT) begin
            watchdog_timer <= watchdog_timer + 1'b1;
        end else begin
            watchdog_timeout <= 1'b1;
        end
    end
end

// =============================================================================
// Control Output Generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        force_resync <= 1'b0;
        timestamp_override <= 1'b0;
        override_seconds <= 40'd0;
        override_subseconds <= 32'd0;
    end else begin
        // Force resync on critical errors
        force_resync <= sync_loss_detected || rapid_error_detected || watchdog_timeout;
        
        // Override timestamp on invalid time
        if (invalid_time_detected || time_jump_detected) begin
            timestamp_override <= 1'b1;
            // Use last known good time
            override_seconds <= last_valid_seconds + 1'b1;
            override_subseconds <= 32'd0;
        end else begin
            timestamp_override <= 1'b0;
        end
    end
end

// =============================================================================
// Status Output Generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        edge_case_flags <= 8'h00;
        error_counter <= 32'd0;
    end else begin
        // Aggregate edge case flags
        edge_case_flags <= {
            overflow_detected,      // bit 7
            underflow_detected,     // bit 6
            rapid_error_detected,   // bit 5
            time_jump_detected,     // bit 4
            invalid_time_detected,  // bit 3
            data_loss_detected,     // bit 2
            pps_loss_detected,      // bit 1
            sync_loss_detected      // bit 0
        };
        
        // Total error counter
        error_counter <= {16'd0, parser_error_count} + 
                        {16'd0, timestamp_error_count} + 
                        {16'd0, consecutive_errors};
    end
end

endmodule