// =============================================================================
// T2MI PPS Generator Testbench
// =============================================================================
// Description: Comprehensive testbench for T2MI PPS generator verification
// Author: Test Team
// Date: December 2024
// =============================================================================

`timescale 1ns/1ps

module t2mi_pps_tb();

// =============================================================================
// Parameters and Constants
// =============================================================================

parameter CLK_100M_PERIOD = 10;      // 10ns = 100MHz
parameter CLK_27M_PERIOD = 37.037;   // 37.037ns ≈ 27MHz
parameter SIM_DURATION = 5_000_000;  // 5ms simulation time

// T2MI packet parameters
parameter SYNC_BYTE = 8'h47;
parameter TIMESTAMP_PACKET_TYPE = 8'h20;
parameter TIMESTAMP_PACKET_LENGTH = 16'h000C;  // 12 bytes

// =============================================================================
// DUT Signals
// =============================================================================

// Clock and Reset
reg         clk_100mhz;
reg         rst_n;

// T2-MI Input Interface
reg         t2mi_clk;
reg         t2mi_valid;
reg  [7:0]  t2mi_data;
reg         t2mi_sync;

// PPS Outputs
wire        pps_out;
wire        timestamp_valid;
wire        sync_locked;
wire [7:0]  debug_status;

// LED Indicators
wire        led_power;
wire        led_sync;
wire        led_pps;
wire        led_error;

// =============================================================================
// Test Variables
// =============================================================================

reg [39:0]  test_seconds;
reg [31:0]  test_subseconds;
reg [12:0]  test_utc_offset;
reg [3:0]   test_bandwidth;
reg [7:0]   test_packet_buffer [0:255];
integer     packet_index;
integer     i;
reg         test_passed;
integer     pps_count;
real        pps_period;
real        last_pps_time;
reg         pps_prev;

// =============================================================================
// Clock Generation
// =============================================================================

initial begin
    clk_100mhz = 1'b0;
    forever #(CLK_100M_PERIOD/2) clk_100mhz = ~clk_100mhz;
end

initial begin
    t2mi_clk = 1'b0;
    forever #(CLK_27M_PERIOD/2) t2mi_clk = ~t2mi_clk;
end

// =============================================================================
// DUT Instantiation
// =============================================================================

t2mi_pps_top dut (
    // Clock and Reset
    .clk_100mhz      (clk_100mhz),
    .rst_n           (rst_n),
    
    // T2-MI Input Interface
    .t2mi_clk        (t2mi_clk),
    .t2mi_valid      (t2mi_valid),
    .t2mi_data       (t2mi_data),
    .t2mi_sync       (t2mi_sync),
    
    // PPS Outputs
    .pps_out         (pps_out),
    .timestamp_valid (timestamp_valid),
    .sync_locked     (sync_locked),
    .debug_status    (debug_status),
    
    // LED Indicators
    .led_power       (led_power),
    .led_sync        (led_sync),
    .led_pps         (led_pps),
    .led_error       (led_error)
);

// =============================================================================
// Test Tasks
// =============================================================================

// Task to generate T2MI timestamp packet
task generate_timestamp_packet;
    input [39:0] seconds;
    input [31:0] subseconds;
    input [12:0] utc_offset;
    input [3:0]  bandwidth;
    
    integer idx;
    begin
        // Clear packet buffer
        for (idx = 0; idx < 256; idx = idx + 1) begin
            test_packet_buffer[idx] = 8'h00;
        end
        
        // Build timestamp packet
        test_packet_buffer[0] = SYNC_BYTE;
        test_packet_buffer[1] = TIMESTAMP_PACKET_TYPE;
        test_packet_buffer[2] = TIMESTAMP_PACKET_LENGTH[15:8];
        test_packet_buffer[3] = TIMESTAMP_PACKET_LENGTH[7:0];
        
        // Header byte: RFU (4 bits) + Bandwidth (4 bits)
        test_packet_buffer[4] = {4'h0, bandwidth};
        
        // UTC offset (13 bits across 2 bytes)
        test_packet_buffer[5] = {3'b000, utc_offset[12:8]};
        test_packet_buffer[6] = utc_offset[7:0];
        
        // Seconds since 2000 (40 bits)
        test_packet_buffer[7]  = seconds[39:32];
        test_packet_buffer[8]  = seconds[31:24];
        test_packet_buffer[9]  = seconds[23:16];
        test_packet_buffer[10] = seconds[15:8];
        test_packet_buffer[11] = seconds[7:0];
        
        // Subseconds (32 bits)
        test_packet_buffer[12] = subseconds[31:24];
        test_packet_buffer[13] = subseconds[23:16];
        test_packet_buffer[14] = subseconds[15:8];
        test_packet_buffer[15] = subseconds[7:0];
    end
endtask

// Task to send packet over T2MI interface
task send_t2mi_packet;
    input integer packet_length;
    
    integer byte_idx;
    begin
        @(posedge t2mi_clk);
        t2mi_sync = 1'b1;
        
        for (byte_idx = 0; byte_idx < packet_length; byte_idx = byte_idx + 1) begin
            @(posedge t2mi_clk);
            t2mi_valid = 1'b1;
            t2mi_data = test_packet_buffer[byte_idx];
            
            if (byte_idx == 0) begin
                t2mi_sync = 1'b0;
            end
        end
        
        @(posedge t2mi_clk);
        t2mi_valid = 1'b0;
        t2mi_data = 8'h00;
    end
endtask

// Task to send invalid packet
task send_invalid_packet;
    integer idx;
    begin
        @(posedge t2mi_clk);
        
        // Send packet with wrong sync byte
        t2mi_valid = 1'b1;
        t2mi_data = 8'hAA;  // Invalid sync byte
        @(posedge t2mi_clk);
        
        // Send some random data
        for (idx = 0; idx < 10; idx = idx + 1) begin
            t2mi_data = $random;
            @(posedge t2mi_clk);
        end
        
        t2mi_valid = 1'b0;
    end
endtask

// Task to monitor PPS output
task monitor_pps;
    begin
        pps_prev = 1'b0;
        pps_count = 0;
        last_pps_time = 0;
        
        fork
            begin
                while (1) begin
                    @(posedge clk_100mhz);
                    if (pps_out && !pps_prev) begin
                        pps_count = pps_count + 1;
                        if (pps_count > 1) begin
                            pps_period = $realtime - last_pps_time;
                            $display("[%0t] PPS pulse detected. Period: %.3f ms", 
                                    $time, pps_period/1_000_000);
                        end
                        last_pps_time = $realtime;
                    end
                    pps_prev = pps_out;
                end
            end
        join_none
    end
endtask

// =============================================================================
// Test Scenarios
// =============================================================================

initial begin
    // Initialize signals
    rst_n = 1'b0;
    t2mi_valid = 1'b0;
    t2mi_data = 8'h00;
    t2mi_sync = 1'b0;
    test_passed = 1'b1;
    
    // Setup waveform dump
    $dumpfile("t2mi_pps_tb.vcd");
    $dumpvars(0, t2mi_pps_tb);
    
    // Display test header
    $display("========================================");
    $display("T2MI PPS Generator Testbench");
    $display("========================================");
    
    // Start PPS monitoring
    monitor_pps();
    
    // Reset sequence
    $display("[%0t] Applying reset...", $time);
    #100;
    rst_n = 1'b1;
    #100;
    
    // Test 1: Basic timestamp packet
    $display("[%0t] Test 1: Sending basic timestamp packet", $time);
    test_seconds = 40'd788918400;  // Approximately 25 years since 2000
    test_subseconds = 32'h80000000;  // 0.5 seconds
    test_utc_offset = 13'd0;
    test_bandwidth = 4'h8;  // 8 MHz
    
    generate_timestamp_packet(test_seconds, test_subseconds, test_utc_offset, test_bandwidth);
    send_t2mi_packet(16);
    
    // Wait for processing
    #10000;
    
    // Check sync status
    if (!sync_locked) begin
        $display("[%0t] ERROR: Sync not locked after valid packet", $time);
        test_passed = 1'b0;
    end
    
    // Test 2: Multiple consecutive packets
    $display("[%0t] Test 2: Sending multiple timestamp packets", $time);
    for (i = 0; i < 5; i = i + 1) begin
        test_seconds = test_seconds + 1;
        test_subseconds = 32'h00000000;
        generate_timestamp_packet(test_seconds, test_subseconds, test_utc_offset, test_bandwidth);
        send_t2mi_packet(16);
        #1_000_000;  // Wait 1ms between packets
    end
    
    // Test 3: Invalid packet handling
    $display("[%0t] Test 3: Testing invalid packet handling", $time);
    send_invalid_packet();
    #10000;
    
    // Test 4: Packet with invalid RFU field
    $display("[%0t] Test 4: Testing packet with invalid RFU field", $time);
    test_packet_buffer[4] = 8'hF8;  // RFU = 0xF (should be 0)
    send_t2mi_packet(16);
    #10000;
    
    // Check error status
    if (!debug_status[6]) begin  // extractor_error
        $display("[%0t] WARNING: Extractor error not detected for invalid RFU", $time);
    end
    
    // Test 5: Boundary conditions
    $display("[%0t] Test 5: Testing boundary conditions", $time);
    
    // Maximum seconds value
    test_seconds = 40'hFFFFFFFFFF;
    test_subseconds = 32'hFFFFFFFF;
    generate_timestamp_packet(test_seconds, test_subseconds, test_utc_offset, test_bandwidth);
    send_t2mi_packet(16);
    #10000;
    
    // Test 6: Sync recovery
    $display("[%0t] Test 6: Testing sync recovery", $time);
    
    // Send garbage data
    for (i = 0; i < 100; i = i + 1) begin
        @(posedge t2mi_clk);
        t2mi_valid = 1'b1;
        t2mi_data = $random;
    end
    t2mi_valid = 1'b0;
    
    #100000;  // Wait for sync loss
    
    // Send valid packet to recover
    test_seconds = 40'd788918410;
    test_subseconds = 32'h00000000;
    generate_timestamp_packet(test_seconds, test_subseconds, test_utc_offset, test_bandwidth);
    send_t2mi_packet(16);
    
    #100000;
    
    // Final check
    if (sync_locked) begin
        $display("[%0t] Sync recovery successful", $time);
    end else begin
        $display("[%0t] ERROR: Sync recovery failed", $time);
        test_passed = 1'b0;
    end
    
    // Wait for PPS generation
    $display("[%0t] Waiting for PPS generation...", $time);
    #3_000_000;  // Wait 3ms
    
    // Summary
    $display("========================================");
    $display("Test Summary:");
    $display("PPS pulses detected: %0d", pps_count);
    if (pps_count > 1) begin
        $display("Average PPS period: %.3f ms", pps_period/1_000_000);
    end
    $display("Test %s", test_passed ? "PASSED" : "FAILED");
    $display("========================================");
    
    $finish;
end

// Timeout watchdog
initial begin
    #SIM_DURATION;
    $display("[%0t] Simulation timeout reached", $time);
    $finish;
end

endmodule

