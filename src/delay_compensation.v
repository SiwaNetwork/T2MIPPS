// =============================================================================
// Delay Compensation Module
// =============================================================================
// Description: Compensates for propagation delays in cables and antennas
// Provides nanosecond-precision delay adjustment
// =============================================================================

module delay_compensation #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter MAX_DELAY_NS = 1_000_000  // Max 1ms delay compensation
)(
    input  wire        clk,
    input  wire        rst_n,
    
    // Input PPS and timestamp
    input  wire        pps_in,
    input  wire [39:0] timestamp_seconds_in,
    input  wire [31:0] timestamp_subseconds_in,
    input  wire        timestamp_valid_in,
    
    // Delay configuration (in nanoseconds)
    input  wire [31:0] cable_delay_ns,      // Cable propagation delay
    input  wire [31:0] antenna_delay_ns,    // Antenna delay
    input  wire [31:0] system_delay_ns,     // Additional system delays
    input  wire        delay_enable,        // Enable delay compensation
    
    // Temperature compensation
    input  wire [15:0] temperature_c,       // Temperature in 0.01°C units
    input  wire [15:0] temp_coeff_ps_c,    // Temperature coefficient in ps/°C
    
    // Output PPS and timestamp (compensated)
    output reg         pps_out,
    output reg  [39:0] timestamp_seconds_out,
    output reg  [31:0] timestamp_subseconds_out,
    output reg         timestamp_valid_out,
    
    // Status and monitoring
    output reg  [31:0] total_delay_ns,      // Total applied delay
    output reg  [31:0] temp_delay_ps,       // Temperature-induced delay
    output reg         compensation_active
);

// =============================================================================
// Constants and calculations
// =============================================================================

// Clock period in picoseconds
localparam CLK_PERIOD_PS = 1_000_000_000_000 / CLK_FREQ_HZ;

// Subsecond increment per nanosecond (2^32 / 10^9)
localparam SUBSEC_PER_NS = 32'd4295;  // Approximation

// =============================================================================
// Internal signals
// =============================================================================

// Delay calculation
reg  [31:0] total_delay_calc;
reg  [31:0] temp_compensation;
reg  [63:0] delay_in_subsecs;

// PPS delay line
reg  [31:0] pps_delay_counter;
reg         pps_delayed;
reg         pps_delay_active;

// Edge detection
reg         pps_in_d1, pps_in_d2;
wire        pps_rising_edge;

// Timestamp adjustment
reg  [63:0] timestamp_adjusted;
reg  [39:0] seconds_adjusted;
reg  [31:0] subseconds_adjusted;

// Temperature reference (25°C = 2500 in 0.01°C units)
localparam TEMP_REFERENCE = 16'd2500;

// =============================================================================
// Edge detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_in_d1 <= 1'b0;
        pps_in_d2 <= 1'b0;
    end else begin
        pps_in_d1 <= pps_in;
        pps_in_d2 <= pps_in_d1;
    end
end

assign pps_rising_edge = pps_in_d1 && !pps_in_d2;

// =============================================================================
// Delay calculation with temperature compensation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        total_delay_calc <= 32'd0;
        temp_compensation <= 32'd0;
        temp_delay_ps <= 32'd0;
        total_delay_ns <= 32'd0;
    end else if (delay_enable) begin
        // Calculate temperature compensation
        // temp_delay = (T - T_ref) * temp_coeff
        if (temperature_c > TEMP_REFERENCE) begin
            temp_delay_ps <= (temperature_c - TEMP_REFERENCE) * temp_coeff_ps_c;
            temp_compensation <= temp_delay_ps / 1000;  // Convert ps to ns
        end else begin
            temp_delay_ps <= (TEMP_REFERENCE - temperature_c) * temp_coeff_ps_c;
            temp_compensation <= -(temp_delay_ps / 1000);  // Negative compensation
        end
        
        // Calculate total delay
        total_delay_calc <= cable_delay_ns + antenna_delay_ns + 
                           system_delay_ns + temp_compensation;
        
        // Limit to maximum delay
        if (total_delay_calc > MAX_DELAY_NS) begin
            total_delay_ns <= MAX_DELAY_NS;
        end else begin
            total_delay_ns <= total_delay_calc;
        end
    end else begin
        total_delay_ns <= 32'd0;
        temp_delay_ps <= 32'd0;
    end
end

// =============================================================================
// PPS delay implementation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_delay_counter <= 32'd0;
        pps_delayed <= 1'b0;
        pps_delay_active <= 1'b0;
        pps_out <= 1'b0;
        compensation_active <= 1'b0;
    end else begin
        if (delay_enable && pps_rising_edge) begin
            // Start delay counter
            pps_delay_active <= 1'b1;
            pps_delay_counter <= 32'd0;
            compensation_active <= 1'b1;
        end else if (pps_delay_active) begin
            // Increment counter
            pps_delay_counter <= pps_delay_counter + CLK_PERIOD_PS;
            
            // Check if delay reached
            if (pps_delay_counter >= (total_delay_ns * 1000)) begin
                pps_delayed <= 1'b1;
                pps_delay_active <= 1'b0;
            end
        end else begin
            pps_delayed <= 1'b0;
        end
        
        // Generate output PPS
        if (!delay_enable) begin
            // Pass through without delay
            pps_out <= pps_in;
            compensation_active <= 1'b0;
        end else begin
            pps_out <= pps_delayed || (pps_delay_counter > 0 && 
                                      pps_delay_counter < 10000000);  // 10us pulse
        end
    end
end

// =============================================================================
// Timestamp compensation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timestamp_seconds_out <= 40'd0;
        timestamp_subseconds_out <= 32'd0;
        timestamp_valid_out <= 1'b0;
        delay_in_subsecs <= 64'd0;
        timestamp_adjusted <= 64'd0;
        seconds_adjusted <= 40'd0;
        subseconds_adjusted <= 32'd0;
    end else if (timestamp_valid_in) begin
        if (delay_enable) begin
            // Convert delay to subsecond units
            delay_in_subsecs <= total_delay_ns * SUBSEC_PER_NS;
            
            // Add delay to timestamp
            timestamp_adjusted <= {timestamp_seconds_in, timestamp_subseconds_in} + 
                                 delay_in_subsecs;
            
            // Extract adjusted seconds and subseconds
            if (timestamp_adjusted[31:0] < timestamp_subseconds_in) begin
                // Subsecond overflow, increment seconds
                seconds_adjusted <= timestamp_adjusted[71:32] + 1;
                subseconds_adjusted <= timestamp_adjusted[31:0];
            end else begin
                seconds_adjusted <= timestamp_adjusted[71:32];
                subseconds_adjusted <= timestamp_adjusted[31:0];
            end
            
            // Output compensated timestamp
            timestamp_seconds_out <= seconds_adjusted;
            timestamp_subseconds_out <= subseconds_adjusted;
            timestamp_valid_out <= 1'b1;
        end else begin
            // Pass through without compensation
            timestamp_seconds_out <= timestamp_seconds_in;
            timestamp_subseconds_out <= timestamp_subseconds_in;
            timestamp_valid_out <= 1'b1;
        end
    end else begin
        timestamp_valid_out <= 1'b0;
    end
end

// =============================================================================
// Debug outputs
// =============================================================================

`ifdef DEBUG
always @(posedge clk) begin
    if (pps_rising_edge && delay_enable) begin
        $display("Delay Compensation: total=%d ns, cable=%d ns, antenna=%d ns, temp=%d ps",
                 total_delay_ns, cable_delay_ns, antenna_delay_ns, temp_delay_ps);
    end
end
`endif

endmodule