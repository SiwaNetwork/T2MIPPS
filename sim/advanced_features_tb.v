// =============================================================================
// Testbench for Advanced Features (Kalman Filter, DPLL, etc.)
// Тестбенч для расширенных функций (фильтр Калмана, DPLL и т.д.)
// =============================================================================

`timescale 1ns / 1ps

module advanced_features_tb;

    // Test parameters
    parameter CLK_PERIOD = 10;  // 100 MHz clock
    parameter SIM_TIME = 10_000_000; // 10ms simulation
    
    // Clock and reset
    reg clk;
    reg rst_n;
    
    // Test signals for Kalman filter
    reg measurement_valid;
    reg signed [31:0] phase_measurement;
    wire signed [31:0] kalman_phase_estimate;
    wire signed [31:0] kalman_freq_estimate;
    wire kalman_estimates_valid;
    
    // Test signals for Advanced DPLL
    reg ref_pulse;
    reg feedback_pulse;
    wire signed [47:0] dpll_phase_error;
    wire signed [47:0] dpll_freq_correction;
    wire dpll_locked;
    wire [31:0] allan_deviation;
    wire [31:0] mtie;
    
    // Test signals for logging system
    reg log_valid;
    reg [7:0] module_id;
    reg [2:0] severity;
    reg [15:0] event_id;
    reg [31:0] event_data;
    wire log_buffer_full;
    
    // Test signals for UART monitor
    wire uart_tx;
    reg uart_rx;
    
    // System timestamp
    reg [63:0] system_timestamp;
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // System timestamp counter
    always @(posedge clk) begin
        if (!rst_n)
            system_timestamp <= 64'h0;
        else
            system_timestamp <= system_timestamp + 1;
    end
    
    // =============================================================================
    // DUT Instantiations
    // =============================================================================
    
    // Kalman Filter
    kalman_filter #(
        .DATA_WIDTH(32),
        .FRAC_BITS(16)
    ) kalman_dut (
        .clk(clk),
        .rst_n(rst_n),
        .measurement_valid(measurement_valid),
        .phase_measurement(phase_measurement),
        .phase_estimate(kalman_phase_estimate),
        .frequency_estimate(kalman_freq_estimate),
        .phase_variance(),
        .freq_variance(),
        .estimates_valid(kalman_estimates_valid),
        .filter_converged()
    );
    
    // Advanced DPLL with PID
    advanced_dpll_pid #(
        .CLK_FREQ_HZ(100_000_000)
    ) dpll_dut (
        .clk(clk),
        .rst_n(rst_n),
        .ref_pulse(ref_pulse),
        .feedback_pulse(feedback_pulse),
        .phase_error_in({16'h0, kalman_phase_estimate}),
        .phase_error_valid(kalman_estimates_valid),
        .kp(32'h0001_0000), // Q16.16
        .ki(32'h0000_1000), // Q16.16
        .kd(32'h0000_0800), // Q16.16
        .loop_enable(1'b1),
        .phase_error_out(dpll_phase_error),
        .frequency_correction(dpll_freq_correction),
        .dpll_locked(dpll_locked),
        .allan_deviation(allan_deviation),
        .mtie(mtie),
        .pid_saturated()
    );
    
    // Logging System
    logging_system #(
        .LOG_BUFFER_SIZE(256),
        .LOG_ENTRY_WIDTH(128)
    ) logging_dut (
        .clk(clk),
        .rst_n(rst_n),
        .system_timestamp(system_timestamp),
        .log_valid(log_valid),
        .module_id(module_id),
        .severity(severity),
        .event_id(event_id),
        .event_data(event_data),
        .read_req(1'b0),
        .read_addr(10'h0),
        .read_data(),
        .read_valid(),
        .buffer_full(log_buffer_full),
        .buffer_empty(),
        .entries_count()
    );
    
    // UART Monitor
    uart_monitor #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) uart_dut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .allan_deviation(allan_deviation),
        .mtie(mtie),
        .phase_error(dpll_phase_error[31:0]),
        .frequency_error(dpll_freq_correction[31:0]),
        .dpll_locked(dpll_locked),
        .pps_status(8'hAA),
        .sit5503_status(8'h55),
        .satellite_delay(32'd119_400),
        .log_read_req(),
        .log_data(128'h0),
        .log_data_valid(1'b0),
        .tx_busy(),
        .rx_data_ready()
    );
    
    // =============================================================================
    // Test Stimulus
    // =============================================================================
    
    // Phase measurement generator (simulating jitter)
    real phase_error_ns;
    real frequency_error_ppb;
    
    initial begin
        // Initialize signals
        rst_n = 1'b0;
        measurement_valid = 1'b0;
        phase_measurement = 32'h0;
        ref_pulse = 1'b0;
        feedback_pulse = 1'b0;
        log_valid = 1'b0;
        module_id = 8'h00;
        severity = 3'd0;
        event_id = 16'h0000;
        event_data = 32'h0;
        uart_rx = 1'b1;
        
        phase_error_ns = 0.0;
        frequency_error_ppb = 0.0;
        
        // Reset sequence
        #(CLK_PERIOD * 10);
        rst_n = 1'b1;
        #(CLK_PERIOD * 10);
        
        $display("=== Advanced Features Testbench Started ===");
        $display("Time\tPhase Error(ns)\tKalman Est\tDPLL Locked\tAllan Dev");
        
        // Start periodic measurements
        fork
            generate_phase_measurements();
            generate_pps_pulses();
            generate_log_events();
            monitor_results();
        join
    end
    
    // Generate phase measurements with noise
    task generate_phase_measurements;
        integer i;
        real noise;
        begin
            for (i = 0; i < 1000; i = i + 1) begin
                // Add some gaussian-like noise
                noise = ($random % 1000) / 1000.0 - 0.5; // -0.5 to +0.5 ns
                phase_error_ns = 10.0 * $sin(2.0 * 3.14159 * i / 200.0) + noise;
                
                // Convert to fixed point (Q16.16)
                phase_measurement = $rtoi(phase_error_ns * 65536.0);
                measurement_valid = 1'b1;
                
                @(posedge clk);
                measurement_valid = 1'b0;
                
                // Wait 1ms between measurements
                repeat(100_000) @(posedge clk);
            end
        end
    endtask
    
    // Generate reference and feedback PPS pulses
    task generate_pps_pulses;
        integer i;
        integer phase_offset;
        begin
            for (i = 0; i < 10; i = i + 1) begin
                // Reference pulse
                ref_pulse = 1'b1;
                repeat(100) @(posedge clk);
                ref_pulse = 1'b0;
                
                // Feedback pulse with phase offset
                phase_offset = $rtoi(phase_error_ns * 100); // Convert ns to clock cycles
                repeat(100_000_000 - 100 + phase_offset) @(posedge clk);
                
                feedback_pulse = 1'b1;
                repeat(100) @(posedge clk);
                feedback_pulse = 1'b0;
            end
        end
    endtask
    
    // Generate log events
    task generate_log_events;
        integer i;
        begin
            for (i = 0; i < 100; i = i + 1) begin
                module_id = i[7:0];
                severity = i % 5;
                event_id = 16'h1000 + i;
                event_data = 32'hDEAD0000 + i;
                log_valid = 1'b1;
                
                @(posedge clk);
                log_valid = 1'b0;
                
                // Wait between log events
                repeat(10_000) @(posedge clk);
            end
        end
    endtask
    
    // Monitor and display results
    task monitor_results;
        integer i;
        begin
            for (i = 0; i < 1000; i = i + 1) begin
                if (i % 10 == 0) begin
                    $display("%0t\t%0.2f\t\t%08x\t%b\t\t%08x",
                        $time,
                        phase_error_ns,
                        kalman_phase_estimate,
                        dpll_locked,
                        allan_deviation
                    );
                end
                repeat(100_000) @(posedge clk);
            end
            
            $display("\n=== Test Summary ===");
            $display("Final DPLL locked status: %b", dpll_locked);
            $display("Final Allan deviation: %0d", allan_deviation);
            $display("Final MTIE: %0d", mtie);
            $display("Log buffer full: %b", log_buffer_full);
            
            $display("\n=== Testbench Completed ===");
            $finish;
        end
    endtask
    
    // Timeout watchdog
    initial begin
        #SIM_TIME;
        $display("\n=== Simulation Timeout ===");
        $finish;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("advanced_features_tb.vcd");
        $dumpvars(0, advanced_features_tb);
    end

endmodule