// =============================================================================
// Testbench for External PPS Processor
// =============================================================================

`timescale 1ns/1ps

module tb_external_pps;

// =============================================================================
// Parameters
// =============================================================================

parameter CLK_PERIOD = 10;  // 100 MHz clock

// =============================================================================
// Signals
// =============================================================================

reg         clk;
reg         rst_n;
reg         ext_pps_in;
reg  [39:0] ref_seconds;
reg  [31:0] ref_subseconds;
reg         ref_time_valid;

wire        ext_pps_out;
wire [39:0] ext_seconds;
wire [31:0] ext_subseconds;
wire        ext_valid;
wire [15:0] ext_quality;
wire [31:0] frequency_offset;
wire [31:0] phase_offset;
wire [31:0] jitter_rms;
wire        signal_present;
wire        frequency_locked;
wire        phase_locked;

// =============================================================================
// DUT Instance
// =============================================================================

external_pps_processor #(
    .CLK_FREQ(100_000_000),
    .MEASUREMENT_WINDOW(100),  // Shorter for simulation
    .JITTER_THRESHOLD(1000)
) dut (
    .clk                (clk),
    .rst_n              (rst_n),
    .ext_pps_in         (ext_pps_in),
    .ref_seconds        (ref_seconds),
    .ref_subseconds     (ref_subseconds),
    .ref_time_valid     (ref_time_valid),
    .ext_pps_out        (ext_pps_out),
    .ext_seconds        (ext_seconds),
    .ext_subseconds     (ext_subseconds),
    .ext_valid          (ext_valid),
    .ext_quality        (ext_quality),
    .frequency_offset   (frequency_offset),
    .phase_offset       (phase_offset),
    .jitter_rms         (jitter_rms),
    .pulse_width        (),
    .pulse_period       (),
    .signal_present     (signal_present),
    .frequency_locked   (frequency_locked),
    .phase_locked       (phase_locked),
    .lock_counter       (),
    .missed_pulses      ()
);

// =============================================================================
// Clock Generation
// =============================================================================

initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// =============================================================================
// Reference Time Generation
// =============================================================================

initial begin
    ref_seconds = 40'd0;
    ref_subseconds = 32'd0;
    ref_time_valid = 1'b0;
    
    #100;
    ref_time_valid = 1'b1;
    
    forever begin
        @(posedge clk);
        if (ref_subseconds >= 32'd99_999_999) begin
            ref_subseconds <= 32'd0;
            ref_seconds <= ref_seconds + 1;
        end else begin
            ref_subseconds <= ref_subseconds + 1;
        end
    end
end

// =============================================================================
// Test Tasks
// =============================================================================

task generate_pps_pulse;
    input [31:0] pulse_width_ns;
    begin
        ext_pps_in = 1'b1;
        #(pulse_width_ns);
        ext_pps_in = 1'b0;
    end
endtask

task generate_perfect_pps;
    input integer count;
    integer i;
    begin
        for (i = 0; i < count; i = i + 1) begin
            generate_pps_pulse(100_000);  // 100 us pulse
            #(1_000_000_000 - 100_000);  // Wait for rest of second
        end
    end
endtask

task generate_pps_with_jitter;
    input integer count;
    input integer jitter_ns;
    integer i;
    integer random_jitter;
    begin
        for (i = 0; i < count; i = i + 1) begin
            random_jitter = $random % (2 * jitter_ns) - jitter_ns;
            generate_pps_pulse(100_000);
            #(1_000_000_000 - 100_000 + random_jitter);
        end
    end
endtask

task generate_pps_with_frequency_offset;
    input integer count;
    input integer offset_ppb;
    integer i;
    real period_ns;
    begin
        period_ns = 1_000_000_000.0 * (1.0 + offset_ppb / 1.0e9);
        for (i = 0; i < count; i = i + 1) begin
            generate_pps_pulse(100_000);
            #(period_ns - 100_000);
        end
    end
endtask

// =============================================================================
// Test Stimulus
// =============================================================================

initial begin
    // Initialize
    rst_n = 1'b0;
    ext_pps_in = 1'b0;
    
    // Dump waveforms
    $dumpfile("tb_external_pps.vcd");
    $dumpvars(0, tb_external_pps);
    
    // Reset
    #100;
    rst_n = 1'b1;
    #100;
    
    // Test 1: Perfect PPS signal
    $display("Test 1: Perfect PPS signal");
    generate_perfect_pps(20);
    
    // Wait for lock
    wait(phase_locked);
    $display("Phase locked achieved");
    #(1_000_000_000);
    
    // Test 2: PPS with jitter
    $display("Test 2: PPS with 100ns jitter");
    generate_pps_with_jitter(20, 100);
    #(1_000_000_000);
    
    // Test 3: PPS with frequency offset
    $display("Test 3: PPS with 50 ppb frequency offset");
    generate_pps_with_frequency_offset(20, 50);
    #(1_000_000_000);
    
    // Test 4: Missing pulses
    $display("Test 4: Missing pulses");
    generate_perfect_pps(5);
    #(3_000_000_000);  // Miss 3 pulses
    generate_perfect_pps(5);
    #(1_000_000_000);
    
    // Test 5: Large phase jump
    $display("Test 5: Large phase jump");
    generate_perfect_pps(10);
    #(500_000_000);  // 500ms phase jump
    generate_perfect_pps(10);
    #(1_000_000_000);
    
    // Display final results
    $display("=== Final Results ===");
    $display("Signal Present: %b", signal_present);
    $display("Frequency Locked: %b", frequency_locked);
    $display("Phase Locked: %b", phase_locked);
    $display("Frequency Offset: %d ppb", frequency_offset);
    $display("Phase Offset: %d ns", phase_offset);
    $display("Jitter RMS: %d ns", jitter_rms);
    $display("Quality: %d", ext_quality);
    
    #1000;
    $finish;
end

// =============================================================================
// Monitors
// =============================================================================

always @(posedge frequency_locked) begin
    $display("Time %t: Frequency locked, offset = %d ppb", $time, frequency_offset);
end

always @(posedge phase_locked) begin
    $display("Time %t: Phase locked, offset = %d ns", $time, phase_offset);
end

always @(negedge signal_present) begin
    $display("Time %t: Signal lost!", $time);
end

always @(posedge signal_present) begin
    $display("Time %t: Signal detected", $time);
end

endmodule