// =============================================================================
// T2MI Packet Parser Testbench
// =============================================================================
// Description: Unit test for T2MI packet parser module
// Tests sync detection, packet extraction, and error handling
// =============================================================================

`timescale 1ns/1ps

module t2mi_packet_parser_tb();

// Parameters
parameter CLK_PERIOD = 10;    // 100 MHz
parameter T2MI_CLK_PERIOD = 37.037;  // 27 MHz

// DUT signals
reg         clk;
reg         rst_n;
reg         t2mi_clk;
reg         t2mi_valid;
reg [7:0]   t2mi_data;
reg         t2mi_sync;

wire        packet_valid;
wire [7:0]  packet_type;
wire [15:0] packet_length;
wire [7:0]  packet_data;
wire        packet_start;
wire        packet_end;
wire        sync_locked;
wire        parser_error;

// Test variables
integer     test_count;
integer     error_count;
reg [7:0]   expected_data;
integer     byte_count;

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    t2mi_clk = 0;
    forever #(T2MI_CLK_PERIOD/2) t2mi_clk = ~t2mi_clk;
end

// DUT instantiation
t2mi_packet_parser dut (
    .clk            (clk),
    .rst_n          (rst_n),
    .t2mi_clk       (t2mi_clk),
    .t2mi_valid     (t2mi_valid),
    .t2mi_data      (t2mi_data),
    .t2mi_sync      (t2mi_sync),
    .packet_valid   (packet_valid),
    .packet_type    (packet_type),
    .packet_length  (packet_length),
    .packet_data    (packet_data),
    .packet_start   (packet_start),
    .packet_end     (packet_end),
    .sync_locked    (sync_locked),
    .parser_error   (parser_error)
);

// Test tasks
task send_byte;
    input [7:0] data;
    input sync;
    begin
        @(posedge t2mi_clk);
        t2mi_valid = 1'b1;
        t2mi_data = data;
        t2mi_sync = sync;
        @(posedge t2mi_clk);
        t2mi_valid = 1'b0;
        t2mi_sync = 1'b0;
    end
endtask

task send_packet;
    input [7:0] pkt_type;
    input [15:0] pkt_length;
    integer i;
    begin
        // Send sync byte
        send_byte(8'h47, 1'b1);
        
        // Send packet type
        send_byte(pkt_type, 1'b0);
        
        // Send length
        send_byte(pkt_length[15:8], 1'b0);
        send_byte(pkt_length[7:0], 1'b0);
        
        // Send data
        for (i = 0; i < pkt_length; i = i + 1) begin
            send_byte(i[7:0], 1'b0);
        end
    end
endtask

task check_packet_output;
    input [7:0] exp_type;
    input [15:0] exp_length;
    integer i;
    begin
        // Wait for packet start
        @(posedge packet_start);
        $display("[%0t] Packet start detected", $time);
        
        if (packet_type !== exp_type) begin
            $display("[%0t] ERROR: Expected type %02h, got %02h", 
                    $time, exp_type, packet_type);
            error_count = error_count + 1;
        end
        
        if (packet_length !== exp_length) begin
            $display("[%0t] ERROR: Expected length %04h, got %04h", 
                    $time, exp_length, packet_length);
            error_count = error_count + 1;
        end
        
        // Check data bytes
        byte_count = 0;
        while (!packet_end) begin
            @(posedge clk);
            if (packet_valid) begin
                if (packet_data !== byte_count[7:0]) begin
                    $display("[%0t] ERROR: Expected data %02h, got %02h at position %0d", 
                            $time, byte_count[7:0], packet_data, byte_count);
                    error_count = error_count + 1;
                end
                byte_count = byte_count + 1;
            end
        end
        
        $display("[%0t] Packet end detected, received %0d bytes", $time, byte_count);
    end
endtask

// Main test
initial begin
    // Initialize
    rst_n = 1'b0;
    t2mi_valid = 1'b0;
    t2mi_data = 8'h00;
    t2mi_sync = 1'b0;
    test_count = 0;
    error_count = 0;
    
    $dumpfile("t2mi_packet_parser_tb.vcd");
    $dumpvars(0, t2mi_packet_parser_tb);
    
    $display("========================================");
    $display("T2MI Packet Parser Testbench");
    $display("========================================");
    
    // Reset
    #100;
    rst_n = 1'b1;
    #100;
    
    // Test 1: Basic packet
    $display("\n[%0t] Test 1: Basic packet parsing", $time);
    test_count = test_count + 1;
    fork
        send_packet(8'h20, 16'd12);
        check_packet_output(8'h20, 16'd12);
    join
    
    #1000;
    
    // Test 2: Multiple sync bytes for lock
    $display("\n[%0t] Test 2: Sync lock acquisition", $time);
    test_count = test_count + 1;
    repeat(10) send_byte(8'h47, 1'b1);
    
    if (!sync_locked) begin
        $display("[%0t] ERROR: Sync not locked after multiple sync bytes", $time);
        error_count = error_count + 1;
    end
    
    // Test 3: Large packet
    $display("\n[%0t] Test 3: Large packet (256 bytes)", $time);
    test_count = test_count + 1;
    fork
        send_packet(8'hA5, 16'd256);
        check_packet_output(8'hA5, 16'd256);
    join
    
    #1000;
    
    // Test 4: Invalid sync byte recovery
    $display("\n[%0t] Test 4: Invalid sync byte recovery", $time);
    test_count = test_count + 1;
    
    // Send garbage
    repeat(20) send_byte($random, 1'b0);
    
    // Send valid packet
    fork
        send_packet(8'h33, 16'd8);
        check_packet_output(8'h33, 16'd8);
    join
    
    // Test 5: Minimum packet length
    $display("\n[%0t] Test 5: Minimum packet length", $time);
    test_count = test_count + 1;
    fork
        send_packet(8'h11, 16'd4);
        check_packet_output(8'h11, 16'd4);
    join
    
    #1000;
    
    // Test 6: Invalid packet length (too small)
    $display("\n[%0t] Test 6: Invalid packet length", $time);
    test_count = test_count + 1;
    
    // Send sync byte
    send_byte(8'h47, 1'b1);
    send_byte(8'h99, 1'b0);  // Type
    send_byte(8'h00, 1'b0);  // Length high
    send_byte(8'h02, 1'b0);  // Length low = 2 (invalid)
    
    #1000;
    
    if (!parser_error) begin
        $display("[%0t] ERROR: Parser error not detected for invalid length", $time);
        error_count = error_count + 1;
    end
    
    // Summary
    $display("\n========================================");
    $display("Test Summary:");
    $display("Total tests: %0d", test_count);
    $display("Errors: %0d", error_count);
    $display("Result: %s", (error_count == 0) ? "PASSED" : "FAILED");
    $display("========================================");
    
    #1000;
    $finish;
end

// Timeout
initial begin
    #1_000_000;
    $display("Timeout!");
    $finish;
end

endmodule