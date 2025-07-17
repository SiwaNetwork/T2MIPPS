// =============================================================================
// PPS Generator Module
// =============================================================================
// Description: Generates precise 1 pulse per second (PPS) signal based on
// extracted timestamp information from T2-MI stream
// =============================================================================

module pps_generator (
    input  wire        clk,              // 100 MHz system clock
    input  wire        rst_n,
    
    // Timestamp input interface
    input  wire        timestamp_valid,
    input  wire [39:0] seconds_since_2000,
    input  wire [31:0] subseconds,
    input  wire        timestamp_ready,
    
    // PPS output interface
    output reg         pps_pulse,
    output reg [31:0]  pps_counter,
    
    // Status output
    output reg         pps_error
);

// =============================================================================
// Parameters and Constants
// =============================================================================

// Clock parameters
parameter CLK_FREQ_HZ = 100_000_000;    // 100 MHz system clock
parameter PPS_PULSE_WIDTH = 1000;       // PPS pulse width in clock cycles (10 us)

// Subseconds resolution
parameter SUBSEC_RESOLUTION = 32'hFFFFFFFF;  // 32-bit subseconds resolution

// Synchronization parameters
parameter SYNC_THRESHOLD = 1000;        // Sync threshold in clock cycles
parameter MAX_DRIFT = 10000;            // Maximum allowed drift in clock cycles

// =============================================================================
// Internal Signals
// =============================================================================

// Time tracking
reg [39:0]  current_seconds;
reg [31:0]  current_subseconds;
reg [31:0]  subsec_counter;
reg [31:0]  subsec_increment;
reg         time_valid;

// PPS generation
reg [31:0]  pps_pulse_counter;
reg         pps_active;
reg [31:0]  next_pps_time;
reg         pps_armed;

// Synchronization
reg [39:0]  last_sync_seconds;
reg [31:0]  last_sync_subseconds;
reg [31:0]  sync_error;
reg         sync_valid;
reg [31:0]  drift_accumulator;

// State machine
reg [2:0]   pps_state;
localparam  STATE_INIT      = 3'b000;
localparam  STATE_SYNC      = 3'b001;
localparam  STATE_TRACKING  = 3'b010;
localparam  STATE_GENERATE  = 3'b011;
localparam  STATE_ERROR     = 3'b100;

// =============================================================================
// Subseconds Increment Calculation
// =============================================================================

// Calculate increment per clock cycle for subseconds counter
// subsec_increment = (2^32) / CLK_FREQ_HZ
always @(*) begin
    subsec_increment = 32'd42949673;  // Approximately 2^32 / 100MHz
end

// =============================================================================
// Time Tracking Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_seconds <= 40'h0000000000;
        current_subseconds <= 32'h00000000;
        subsec_counter <= 32'h00000000;
        time_valid <= 1'b0;
    end else begin
        if (timestamp_ready && timestamp_valid) begin
            // Synchronize to incoming timestamp
            current_seconds <= seconds_since_2000;
            current_subseconds <= subseconds;
            subsec_counter <= subseconds;
            time_valid <= 1'b1;
        end else if (time_valid) begin
            // Free-running time tracking
            subsec_counter <= subsec_counter + subsec_increment;
            
            // Handle subseconds overflow (new second)
            if (subsec_counter >= SUBSEC_RESOLUTION) begin
                subsec_counter <= subsec_counter - SUBSEC_RESOLUTION;
                current_seconds <= current_seconds + 1'b1;
            end
            
            current_subseconds <= subsec_counter;
        end
    end
end

// =============================================================================
// Synchronization Error Calculation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_error <= 32'h00000000;
        sync_valid <= 1'b0;
        drift_accumulator <= 32'h00000000;
        last_sync_seconds <= 40'h0000000000;
        last_sync_subseconds <= 32'h00000000;
    end else begin
        if (timestamp_ready && timestamp_valid && time_valid) begin
            // Calculate synchronization error
            if (seconds_since_2000 == current_seconds) begin
                // Same second, calculate subseconds difference
                if (subseconds > current_subseconds) begin
                    sync_error <= subseconds - current_subseconds;
                end else begin
                    sync_error <= current_subseconds - subseconds;
                end
            end else begin
                // Different seconds, large error
                sync_error <= 32'hFFFFFFFF;
            end
            
            // Update drift accumulator
            if (sync_error < SYNC_THRESHOLD) begin
                drift_accumulator <= drift_accumulator + sync_error;
                sync_valid <= 1'b1;
            end else begin
                drift_accumulator <= 32'h00000000;
                sync_valid <= 1'b0;
            end
            
            last_sync_seconds <= seconds_since_2000;
            last_sync_subseconds <= subseconds;
        end
    end
end

// =============================================================================
// PPS Generation State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_state <= STATE_INIT;
    end else begin
        case (pps_state)
            STATE_INIT: begin
                if (time_valid) begin
                    pps_state <= STATE_SYNC;
                end
            end
            
            STATE_SYNC: begin
                if (sync_valid && (sync_error < SYNC_THRESHOLD)) begin
                    pps_state <= STATE_TRACKING;
                end else if (sync_error > MAX_DRIFT) begin
                    pps_state <= STATE_ERROR;
                end
            end
            
            STATE_TRACKING: begin
                if (pps_armed && (current_subseconds >= next_pps_time)) begin
                    pps_state <= STATE_GENERATE;
                end else if (sync_error > MAX_DRIFT) begin
                    pps_state <= STATE_ERROR;
                end
            end
            
            STATE_GENERATE: begin
                if (pps_pulse_counter >= PPS_PULSE_WIDTH) begin
                    pps_state <= STATE_TRACKING;
                end
            end
            
            STATE_ERROR: begin
                if (timestamp_ready && timestamp_valid) begin
                    pps_state <= STATE_INIT;
                end
            end
            
            default: begin
                pps_state <= STATE_INIT;
            end
        endcase
    end
end

// =============================================================================
// PPS Pulse Generation Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_pulse <= 1'b0;
        pps_pulse_counter <= 32'h00000000;
        pps_counter <= 32'h00000000;
        next_pps_time <= 32'h00000000;
        pps_armed <= 1'b0;
        pps_active <= 1'b0;
        pps_error <= 1'b0;
    end else begin
        // Default values
        pps_error <= 1'b0;
        
        case (pps_state)
            STATE_INIT: begin
                pps_pulse <= 1'b0;
                pps_pulse_counter <= 32'h00000000;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
            end
            
            STATE_SYNC: begin
                pps_pulse <= 1'b0;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
            end
            
            STATE_TRACKING: begin
                pps_pulse <= 1'b0;
                pps_pulse_counter <= 32'h00000000;
                
                // Arm PPS for next second boundary
                if (!pps_armed) begin
                    next_pps_time <= 32'h00000000;  // Target start of next second
                    pps_armed <= 1'b1;
                end
                
                // Check if we should generate PPS
                if (pps_armed && (current_subseconds < 32'h10000000)) begin  // Near second boundary
                    pps_active <= 1'b1;
                end
            end
            
            STATE_GENERATE: begin
                pps_active <= 1'b1;
                pps_pulse <= 1'b1;
                pps_pulse_counter <= pps_pulse_counter + 1'b1;
                
                if (pps_pulse_counter >= PPS_PULSE_WIDTH) begin
                    pps_pulse <= 1'b0;
                    pps_counter <= pps_counter + 1'b1;
                    pps_armed <= 1'b0;
                    pps_active <= 1'b0;
                end
            end
            
            STATE_ERROR: begin
                pps_pulse <= 1'b0;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
                pps_error <= 1'b1;
            end
            
            default: begin
                pps_pulse <= 1'b0;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
            end
        endcase
    end
end

// =============================================================================
// Debug and Monitoring
// =============================================================================

// Synthesis translate_off
always @(posedge clk) begin
    if (pps_pulse && !pps_active) begin  // Rising edge of PPS
        $display("PPS pulse generated at time %t", $time);
        $display("  Current seconds: %d", current_seconds);
        $display("  Current subseconds: 0x%08x", current_subseconds);
        $display("  PPS counter: %d", pps_counter + 1);
        $display("  Sync error: %d", sync_error);
    end
    
    if (pps_error) begin
        $display("PPS generation error at time %t", $time);
        $display("  Sync error: %d (threshold: %d)", sync_error, MAX_DRIFT);
        $display("  State: %d", pps_state);
    end
end
// Synthesis translate_on

endmodule

