// =============================================================================
// PPS Generator Testbench
// =============================================================================
// Description: Unit test for PPS generator module
// Tests time tracking, synchronization, and PPS pulse generation
// =============================================================================

`timescale 1ns/1ps

module pps_generator_tb();

// Parameters
parameter CLK_PERIOD = 10;  // 100 MHz
parameter CLK_FREQ = 100_000_000;

// DUT signals
reg         clk;
reg         rst_n;
reg         timestamp_valid;
reg [39:0]  seconds_since_2000;
reg [31:0]  subseconds;
reg         timestamp_ready;

wire        pps_pulse;
wire [31:0] pps_counter;
wire        pps_error;

// Test variables
real        expected_pps_time;
real        actual_pps_time;
real        time_error;
integer     test_count;
integer     error_count;
reg         pps_detected;
real        last_pps_time;
integer     pps_count;

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// DUT instantiation
pps_generator dut (
    .clk                (clk),
    .rst_n              (rst_n),
    .timestamp_valid    (timestamp_valid),
    .seconds_since_2000 (seconds_since_2000),
    .subseconds         (subseconds),
    .timestamp_ready    (timestamp_ready),
    .pps_pulse          (pps_pulse),
    .pps_counter        (pps_counter),
    .pps_error          (pps_error)
);

// Tasks
task send_timestamp;
    input [39:0] seconds;
    input [31:0] subsec;
    begin
        @(posedge clk);
        timestamp_valid = 1'b1;
        timestamp_ready = 1'b1;
        seconds_since_2000 = seconds;
        subseconds = subsec;
        @(posedge clk);
        timestamp_valid = 1'b0;
        timestamp_ready = 1'b0;
    end
endtask

task wait_for_pps;
    output real pulse_time;
    begin
        pps_detected = 1'b0;
        while (!pps_detected) begin
            @(posedge clk);
            if (pps_pulse && !pps_detected) begin
                pps_detected = 1'b1;
                pulse_time = $realtime;
            end
        end
    end
endtask

// PPS monitor
always @(posedge pps_pulse) begin
    if (pps_count > 0) begin
        $display("[%0t] PPS pulse #%0d, interval: %.3f ms", 
                $time, pps_count + 1, ($realtime - last_pps_time) / 1_000_000);
    end else begin
        $display("[%0t] First PPS pulse detected", $time);
    end
    last_pps_time = $realtime;
    pps_count = pps_count + 1;
end

// Main test
initial begin
    // Initialize
    rst_n = 1'b0;
    timestamp_valid = 1'b0;
    timestamp_ready = 1'b0;
    seconds_since_2000 = 40'd0;
    subseconds = 32'd0;
    test_count = 0;
    error_count = 0;
    pps_count = 0;
    
    $dumpfile("pps_generator_tb.vcd");
    $dumpvars(0, pps_generator_tb);
    
    $display("========================================");
    $display("PPS Generator Testbench");
    $display("========================================");
    
    // Reset
    #100;
    rst_n = 1'b1;
    #100;
    
    // Test 1: Initial synchronization
    $display("\n[%0t] Test 1: Initial synchronization", $time);
    test_count = test_count + 1;
    
    // Send timestamp at 0.5 seconds
    send_timestamp(40'd1000, 32'h80000000);
    
    // Wait for next second boundary
    wait_for_pps(actual_pps_time);
    
    // Verify timing (should be ~0.5 seconds later)
    expected_pps_time = $realtime + (0.5 * 1_000_000_000);
    time_error = actual_pps_time - expected_pps_time;
    
    $display("[%0t] Expected PPS at %.0f ns, actual at %.0f ns, error: %.0f ns",
            $time, expected_pps_time, actual_pps_time, time_error);
    
    if (time_error > 1000) begin  // 1 us tolerance
        $display("[%0t] ERROR: PPS timing error too large", $time);
        error_count = error_count + 1;
    end
    
    // Test 2: Regular operation
    $display("\n[%0t] Test 2: Regular PPS generation", $time);
    test_count = test_count + 1;
    
    // Let it run for 3 seconds
    repeat(3) begin
        wait_for_pps(actual_pps_time);
    end
    
    if (pps_counter < 3) begin
        $display("[%0t] ERROR: Not enough PPS pulses generated", $time);
        error_count = error_count + 1;
    end
    
    // Test 3: Timestamp update
    $display("\n[%0t] Test 3: Timestamp update and resync", $time);
    test_count = test_count + 1;
    
    // Send new timestamp with small offset
    send_timestamp(40'd1005, 32'h00100000);  // Slightly ahead
    
    wait_for_pps(actual_pps_time);
    
    // Test 4: Large time jump
    $display("\n[%0t] Test 4: Large time jump", $time);
    test_count = test_count + 1;
    
    // Jump 1 hour ahead
    send_timestamp(40'd4605, 32'h00000000);
    
    #100000;  // Wait for processing
    
    if (!pps_error) begin
        $display("[%0t] WARNING: No error for large time jump", $time);
    end
    
    // Test 5: Subsecond precision
    $display("\n[%0t] Test 5: Subsecond precision test", $time);
    test_count = test_count + 1;
    
    // Send timestamp at precise subsecond values
    send_timestamp(40'd5000, 32'h00000000);  // Exactly on second
    wait_for_pps(actual_pps_time);
    
    send_timestamp(40'd5001, 32'h19999999);  // 0.1 seconds
    wait_for_pps(actual_pps_time);
    
    // Test 6: Maximum values
    $display("\n[%0t] Test 6: Boundary values", $time);
    test_count = test_count + 1;
    
    // Near maximum seconds
    send_timestamp(40'hFFFFFFFFF0, 32'h00000000);
    #10000;
    
    // Check for overflow handling
    if (pps_error) begin
        $display("[%0t] Error detected for boundary value (expected)", $time);
    end
    
    // Summary
    #100000;
    $display("\n========================================");
    $display("Test Summary:");
    $display("Total tests: %0d", test_count);
    $display("Errors: %0d", error_count);
    $display("Total PPS pulses: %0d", pps_count);
    $display("Result: %s", (error_count == 0) ? "PASSED" : "FAILED");
    $display("========================================");
    
    $finish;
end

// Timeout
initial begin
    #10_000_000;  // 10ms
    $display("Timeout!");
    $finish;
end

endmodule