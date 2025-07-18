// =============================================================================
// Kalman Filter Module for Timestamp Prediction and Filtering
// =============================================================================
// Description: Implements a Kalman filter for T2MI timestamp processing
// Provides optimal estimation of time and frequency offset
// =============================================================================

module kalman_filter #(
    parameter FIXED_POINT_WIDTH = 64,
    parameter FRACTION_BITS = 32
)(
    input  wire        clk,
    input  wire        rst_n,
    
    // Input timestamp
    input  wire        timestamp_valid,
    input  wire [39:0] seconds_in,
    input  wire [31:0] subseconds_in,
    
    // Filter control
    input  wire        enable,
    input  wire [31:0] process_noise_q,      // Process noise covariance
    input  wire [31:0] measurement_noise_r,  // Measurement noise covariance
    
    // Filtered output
    output reg         filtered_valid,
    output reg  [39:0] filtered_seconds,
    output reg  [31:0] filtered_subseconds,
    output reg  [31:0] frequency_offset,     // Estimated frequency offset
    output reg  [31:0] prediction_error,     // Current prediction error
    
    // Status
    output reg  [3:0]  filter_state,
    output reg         filter_converged
);

// =============================================================================
// Fixed-point arithmetic helpers
// =============================================================================

// Convert to fixed-point
function [FIXED_POINT_WIDTH-1:0] to_fixed;
    input [31:0] integer_part;
    input [31:0] fraction_part;
    begin
        to_fixed = {integer_part, fraction_part};
    end
endfunction

// Fixed-point multiplication
function [FIXED_POINT_WIDTH-1:0] fixed_mult;
    input [FIXED_POINT_WIDTH-1:0] a;
    input [FIXED_POINT_WIDTH-1:0] b;
    reg [2*FIXED_POINT_WIDTH-1:0] temp;
    begin
        temp = a * b;
        fixed_mult = temp >> FRACTION_BITS;
    end
endfunction

// =============================================================================
// State definitions
// =============================================================================

localparam STATE_INIT        = 4'd0;
localparam STATE_PREDICT     = 4'd1;
localparam STATE_UPDATE      = 4'd2;
localparam STATE_CONVERGED   = 4'd3;
localparam STATE_ERROR       = 4'd4;

// =============================================================================
// Kalman filter state variables
// =============================================================================

// State vector: [time, frequency_offset]
reg [FIXED_POINT_WIDTH-1:0] x_time;           // Current time estimate
reg [FIXED_POINT_WIDTH-1:0] x_freq;           // Frequency offset estimate

// State covariance matrix P (2x2)
reg [FIXED_POINT_WIDTH-1:0] P_00, P_01;       // P[0][0], P[0][1]
reg [FIXED_POINT_WIDTH-1:0] P_10, P_11;       // P[1][0], P[1][1]

// Kalman gain K (2x1)
reg [FIXED_POINT_WIDTH-1:0] K_0, K_1;

// Innovation
reg [FIXED_POINT_WIDTH-1:0] innovation;

// Prediction variables
reg [FIXED_POINT_WIDTH-1:0] x_time_pred;
reg [FIXED_POINT_WIDTH-1:0] x_freq_pred;

// Time tracking
reg [31:0] sample_counter;
reg [31:0] convergence_counter;

// Previous timestamp for delta calculation
reg [39:0] prev_seconds;
reg [31:0] prev_subseconds;
reg        first_sample;

// =============================================================================
// Constants
// =============================================================================

localparam [FIXED_POINT_WIDTH-1:0] ONE = 64'h0000000100000000;  // 1.0 in fixed-point
localparam CONVERGENCE_THRESHOLD = 32'd100;  // Convergence after 100 stable samples

// State transition matrix F (2x2)
// F = [1, dt; 0, 1] where dt is the sampling period
reg [FIXED_POINT_WIDTH-1:0] dt;  // Time between samples

// =============================================================================
// Main Kalman Filter Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all state variables
        filter_state <= STATE_INIT;
        x_time <= 64'd0;
        x_freq <= ONE;  // Initialize to 1.0 (no offset)
        
        // Initialize covariance matrix to identity
        P_00 <= ONE;
        P_01 <= 64'd0;
        P_10 <= 64'd0;
        P_11 <= ONE;
        
        K_0 <= 64'd0;
        K_1 <= 64'd0;
        
        innovation <= 64'd0;
        prediction_error <= 32'd0;
        
        filtered_valid <= 1'b0;
        filtered_seconds <= 40'd0;
        filtered_subseconds <= 32'd0;
        frequency_offset <= 32'd0;
        
        sample_counter <= 32'd0;
        convergence_counter <= 32'd0;
        filter_converged <= 1'b0;
        
        prev_seconds <= 40'd0;
        prev_subseconds <= 32'd0;
        first_sample <= 1'b1;
        dt <= ONE;  // Default to 1 second
        
    end else if (enable) begin
        case (filter_state)
            
            STATE_INIT: begin
                if (timestamp_valid) begin
                    // Initialize with first timestamp
                    x_time <= to_fixed(seconds_in, subseconds_in);
                    prev_seconds <= seconds_in;
                    prev_subseconds <= subseconds_in;
                    first_sample <= 1'b0;
                    filter_state <= STATE_PREDICT;
                end
            end
            
            STATE_PREDICT: begin
                if (timestamp_valid && !first_sample) begin
                    // Calculate time delta
                    reg [40:0] delta_sec;
                    reg [32:0] delta_subsec;
                    
                    delta_sec = seconds_in - prev_seconds;
                    if (subseconds_in >= prev_subseconds) begin
                        delta_subsec = subseconds_in - prev_subseconds;
                    end else begin
                        delta_sec = delta_sec - 1;
                        delta_subsec = (33'h100000000 + subseconds_in) - prev_subseconds;
                    end
                    
                    dt <= to_fixed(delta_sec[31:0], delta_subsec[31:0]);
                    
                    // Predict state: x_pred = F * x
                    x_time_pred <= x_time + fixed_mult(x_freq, dt);
                    x_freq_pred <= x_freq;
                    
                    // Predict covariance: P_pred = F * P * F' + Q
                    reg [FIXED_POINT_WIDTH-1:0] temp_P00, temp_P01, temp_P11;
                    
                    temp_P00 = P_00 + fixed_mult(P_01, dt) + fixed_mult(P_10, dt) + 
                               fixed_mult(fixed_mult(P_11, dt), dt) + process_noise_q;
                    temp_P01 = P_01 + fixed_mult(P_11, dt);
                    temp_P11 = P_11 + process_noise_q;
                    
                    P_00 <= temp_P00;
                    P_01 <= temp_P01;
                    P_10 <= temp_P01;  // Symmetric
                    P_11 <= temp_P11;
                    
                    filter_state <= STATE_UPDATE;
                end
            end
            
            STATE_UPDATE: begin
                // Calculate innovation: y = z - H * x_pred
                reg [FIXED_POINT_WIDTH-1:0] measurement;
                measurement = to_fixed(seconds_in, subseconds_in);
                innovation <= measurement - x_time_pred;
                
                // Calculate innovation covariance: S = H * P_pred * H' + R
                reg [FIXED_POINT_WIDTH-1:0] S;
                S = P_00 + measurement_noise_r;
                
                // Calculate Kalman gain: K = P_pred * H' * inv(S)
                K_0 <= P_00 / S[FRACTION_BITS-1:0];  // Simplified division
                K_1 <= P_10 / S[FRACTION_BITS-1:0];
                
                // Update state estimate: x = x_pred + K * y
                x_time <= x_time_pred + fixed_mult(K_0, innovation);
                x_freq <= x_freq_pred + fixed_mult(K_1, innovation);
                
                // Update covariance: P = (I - K * H) * P_pred
                reg [FIXED_POINT_WIDTH-1:0] temp_factor;
                temp_factor = ONE - K_0;
                
                P_00 <= fixed_mult(temp_factor, P_00);
                P_01 <= fixed_mult(temp_factor, P_01);
                P_10 <= P_10 - fixed_mult(K_1, P_00);
                P_11 <= P_11 - fixed_mult(K_1, P_01);
                
                // Update outputs
                filtered_seconds <= x_time[FIXED_POINT_WIDTH-1:FRACTION_BITS];
                filtered_subseconds <= x_time[FRACTION_BITS-1:0];
                frequency_offset <= x_freq[FRACTION_BITS-1:0];
                prediction_error <= innovation[FRACTION_BITS-1:0];
                filtered_valid <= 1'b1;
                
                // Update previous values
                prev_seconds <= seconds_in;
                prev_subseconds <= subseconds_in;
                
                // Check convergence
                if (innovation < 32'h00010000) begin  // Small innovation
                    convergence_counter <= convergence_counter + 1;
                    if (convergence_counter >= CONVERGENCE_THRESHOLD) begin
                        filter_converged <= 1'b1;
                        filter_state <= STATE_CONVERGED;
                    end
                end else begin
                    convergence_counter <= 32'd0;
                end
                
                sample_counter <= sample_counter + 1;
                filter_state <= STATE_PREDICT;
            end
            
            STATE_CONVERGED: begin
                // Continue filtering with reduced gain adaptation
                filter_state <= STATE_PREDICT;
            end
            
            STATE_ERROR: begin
                // Error recovery
                filter_state <= STATE_INIT;
            end
            
            default: begin
                filter_state <= STATE_INIT;
            end
        endcase
        
    end else begin
        filtered_valid <= 1'b0;
    end
end

// =============================================================================
// Debug outputs
// =============================================================================

`ifdef DEBUG
always @(posedge clk) begin
    if (filtered_valid) begin
        $display("Kalman: time=%d.%d, freq_offset=%h, error=%h, converged=%b",
                 filtered_seconds, filtered_subseconds, 
                 frequency_offset, prediction_error, filter_converged);
    end
end
`endif

endmodule