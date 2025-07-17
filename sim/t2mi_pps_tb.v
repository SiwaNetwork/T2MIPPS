// =============================================================================
// T2MI PPS Generator Testbench
// =============================================================================
// Description: Basic testbench for T2MI PPS generator functionality
// =============================================================================

`timescale 1ns / 1ps

module t2mi_pps_tb;

// =============================================================================
// Parameters
// =============================================================================

parameter CLK_PERIOD = 10;      // 100 MHz clock
parameter T2MI_CLK_PERIOD = 37; // ~27 MHz T2-MI clock

// =============================================================================
// Signals
// =============================================================================

// Clock and Reset
reg         clk_100mhz;
reg         rst_n;

// T2-MI Input Interface
reg         t2mi_clk;
reg         t2mi_valid;
reg [7:0]   t2mi_data;
reg         t2mi_sync;

// Outputs
wire        pps_out;
wire        timestamp_valid;
wire        sync_locked;
wire [7:0]  debug_status;
wire        led_power;
wire        led_sync;
wire        led_pps;
wire        led_error;

// Test variables
reg [7:0]   test_packet [0:15];
integer     packet_index;
integer     test_phase;

// =============================================================================
// Clock Generation
// =============================================================================

initial begin
    clk_100mhz = 0;
    forever #(CLK_PERIOD/2) clk_100mhz = ~clk_100mhz;
end

initial begin
    t2mi_clk = 0;
    forever #(T2MI_CLK_PERIOD/2) t2mi_clk = ~t2mi_clk;
end

// =============================================================================
// DUT Instantiation
// =============================================================================

t2mi_pps_top dut (
    .clk_100mhz     (clk_100mhz),
    .rst_n          (rst_n),
    .t2mi_clk       (t2mi_clk),
    .t2mi_valid     (t2mi_valid),
    .t2mi_data      (t2mi_data),
    .t2mi_sync      (t2mi_sync),
    .pps_out        (pps_out),
    .timestamp_valid(timestamp_valid),
    .sync_locked    (sync_locked),
    .debug_status   (debug_status),
    .led_power      (led_power),
    .led_sync       (led_sync),
    .led_pps        (led_pps),
    .led_error      (led_error)
);

// =============================================================================
// Test Stimulus
// =============================================================================

initial begin
    // Initialize signals
    rst_n = 0;
    t2mi_valid = 0;
    t2mi_data = 8'h00;
    t2mi_sync = 0;
    packet_index = 0;
    test_phase = 0;
    
    // Initialize test packet (timestamp packet type 0x20)
    test_packet[0]  = 8'h47;    // Sync byte
    test_packet[1]  = 8'h20;    // Packet type (timestamp)
    test_packet[2]  = 8'h00;    // Length high byte
    test_packet[3]  = 8'h0C;    // Length low byte (12 bytes)
    test_packet[4]  = 8'h05;    // Header: bw=5 (8MHz), rfu=0
    test_packet[5]  = 8'h00;    // UTC offset high
    test_packet[6]  = 8'h25;    // UTC offset low (37 seconds)
    test_packet[7]  = 8'h12;    // Seconds since 2000 [39:32]
    test_packet[8]  = 8'h34;    // Seconds since 2000 [31:24]
    test_packet[9]  = 8'h56;    // Seconds since 2000 [23:16]
    test_packet[10] = 8'h78;    // Seconds since 2000 [15:8]
    test_packet[11] = 8'h9A;    // Seconds since 2000 [7:0]
    test_packet[12] = 8'h80;    // Subseconds [31:24] (0.5 seconds)
    test_packet[13] = 8'h00;    // Subseconds [23:16]
    test_packet[14] = 8'h00;    // Subseconds [15:8]
    test_packet[15] = 8'h00;    // Subseconds [7:0]
    
    // Reset sequence
    #100;
    rst_n = 1;
    #100;
    
    $display("Starting T2MI PPS Generator Test");
    $display("Time: %t", $time);
    
    // Test Phase 1: Send timestamp packet
    test_phase = 1;
    $display("Phase 1: Sending timestamp packet");
    
    repeat (5) @(posedge t2mi_clk);
    
    // Send test packet
    for (packet_index = 0; packet_index < 16; packet_index = packet_index + 1) begin
        @(posedge t2mi_clk);
        t2mi_valid = 1;
        t2mi_data = test_packet[packet_index];
        if (packet_index == 0) begin
            t2mi_sync = 1;
        end else begin
            t2mi_sync = 0;
        end
        #1;
    end
    
    @(posedge t2mi_clk);
    t2mi_valid = 0;
    t2mi_sync = 0;
    
    // Wait for processing
    #1000;
    
    // Test Phase 2: Monitor PPS generation
    test_phase = 2;
    $display("Phase 2: Monitoring PPS generation");
    
    // Wait for potential PPS pulse
    #50000;
    
    // Test Phase 3: Send another timestamp packet
    test_phase = 3;
    $display("Phase 3: Sending second timestamp packet");
    
    // Modify timestamp for next second
    test_packet[11] = 8'h9B;    // Increment seconds
    test_packet[12] = 8'h00;    // Reset subseconds to 0
    
    repeat (5) @(posedge t2mi_clk);
    
    // Send second packet
    for (packet_index = 0; packet_index < 16; packet_index = packet_index + 1) begin
        @(posedge t2mi_clk);
        t2mi_valid = 1;
        t2mi_data = test_packet[packet_index];
        if (packet_index == 0) begin
            t2mi_sync = 1;
        end else begin
            t2mi_sync = 0;
        end
        #1;
    end
    
    @(posedge t2mi_clk);
    t2mi_valid = 0;
    t2mi_sync = 0;
    
    // Wait for PPS generation
    #100000;
    
    $display("Test completed at time %t", $time);
    $finish;
end

// =============================================================================
// Monitoring
// =============================================================================

// Monitor key signals
always @(posedge clk_100mhz) begin
    if (timestamp_valid) begin
        $display("Timestamp valid at time %t", $time);
    end
    
    if (pps_out) begin
        $display("PPS pulse generated at time %t", $time);
    end
    
    if (led_error) begin
        $display("Error detected at time %t, debug_status = %b", $time, debug_status);
    end
end

// Monitor sync lock
always @(posedge sync_locked) begin
    $display("T2-MI sync locked at time %t", $time);
end

always @(negedge sync_locked) begin
    $display("T2-MI sync lost at time %t", $time);
end

endmodule

