// =============================================================================
// T2MI PPS Generator Top Level Module v3 - Full Featured Version
// Модуль верхнего уровня генератора PPS из потока T2MI v3 - Полнофункциональная версия
// =============================================================================
// Description: Top-level module with all advanced features including:
//              - Kalman filtering for phase/frequency estimation
//              - Advanced DPLL with PID control
//              - Comprehensive logging system
//              - UART monitoring interface
//              - Satellite delay compensation
// Описание: Модуль верхнего уровня со всеми расширенными функциями включая:
//          - Фильтрацию Калмана для оценки фазы/частоты
//          - Улучшенный DPLL с PID управлением
//          - Комплексную систему логирования
//          - Интерфейс мониторинга UART
//          - Компенсацию спутниковой задержки
// Target: Lattice LFE5U-25F-6BG256C
// Author: Manus AI
// Date: December 2024
// Version: 3.0 - Full featured version
// =============================================================================

module t2mi_pps_top_v3 (
    // Clock and Reset / Тактирование и сброс
    input  wire        clk_100mhz,       // 100 MHz system clock
    input  wire        rst_n,            // Active low reset
    
    // T2-MI Input Interface / Интерфейс входного потока T2-MI
    input  wire        t2mi_clk,         // T2-MI stream clock
    input  wire        t2mi_valid,       // T2-MI data valid
    input  wire [7:0]  t2mi_data,        // T2-MI data byte
    input  wire        t2mi_sync,        // T2-MI sync signal
    
    // SiT5503 High-Stability Oscillator Interface
    input  wire        sit5503_clk,      // 10 MHz from SiT5503
    output wire        sit5503_scl,      // I2C clock to SiT5503
    inout  wire        sit5503_sda,      // I2C data to SiT5503
    
    // PPS Outputs / Выходы PPS
    output wire        pps_out,          // Main PPS output
    output wire        pps_backup,       // Backup PPS output
    output wire        pps_compensated,  // Satellite delay compensated PPS
    
    // UART Monitor Interface / Интерфейс UART монитора
    input  wire        uart_rx,          // UART receive
    output wire        uart_tx,          // UART transmit
    
    // Satellite Parameters Input / Входы параметров спутника
    input  wire [31:0] satellite_distance_km,  // Distance to satellite in km
    input  wire [15:0] satellite_elevation,    // Elevation angle (degrees * 100)
    input  wire        satellite_params_valid, // Parameters are valid
    
    // Status and Debug / Статус и отладка
    output wire        timestamp_valid,  // Timestamp extracted flag
    output wire        sync_locked,      // System fully synchronized
    output wire        autonomous_mode,  // Operating in autonomous mode
    output wire        sit5503_ready,    // SiT5503 oscillator ready
    output wire        dpll_locked,      // DPLL locked status
    output wire [31:0] allan_deviation,  // Current Allan deviation
    output wire [31:0] mtie_value,      // Current MTIE value
    output wire [7:0]  debug_status,     // Debug status register
    output wire [7:0]  pps_status,       // PPS generator status
    
    // LED Indicators / Светодиодные индикаторы
    output wire        led_power,        // Power indicator
    output wire        led_sync,         // Sync status indicator
    output wire        led_pps,          // PPS activity indicator
    output wire        led_error,        // Error indicator
    output wire        led_autonomous,   // Autonomous mode indicator
    output wire        led_sit5503,      // SiT5503 status indicator
    output wire        led_dpll_lock,    // DPLL lock indicator
    output wire        led_uart_activity // UART activity indicator
);

// =============================================================================
// Internal Signals / Внутренние сигналы
// =============================================================================

// Clock and reset signals
wire        clk_100mhz_buf;
wire        rst_sync;

// T2-MI packet parser signals
wire        packet_valid;
wire [7:0]  packet_type;
wire [15:0] packet_length;
wire [7:0]  packet_data;
wire        packet_start;
wire        packet_end;

// Timestamp extractor signals
wire [39:0] timestamp_seconds;
wire [31:0] timestamp_subseconds;
wire        timestamp_ready;
wire        timestamp_error;

// SiT5503 controller signals
wire        sit5503_calibrate_start;
wire [15:0] sit5503_frequency_offset;
wire        sit5503_offset_valid;
wire        sit5503_calibration_done;
wire [7:0]  sit5503_status_reg;

// Enhanced PPS generator signals
wire        pps_sync_status;
wire [31:0] pps_time_error;
wire        pps_calibrate_request;
wire [15:0] pps_freq_correction;

// Kalman filter signals
wire signed [31:0] kalman_phase_estimate;
wire signed [31:0] kalman_freq_estimate;
wire signed [31:0] kalman_phase_variance;
wire signed [31:0] kalman_freq_variance;
wire        kalman_estimates_valid;

// Advanced DPLL signals
wire signed [47:0] dpll_phase_error;
wire signed [47:0] dpll_freq_correction;
wire [31:0] dpll_allan_dev;
wire [31:0] dpll_mtie;
wire        dpll_lock_status;

// Logging system signals
wire        log_read_req;
wire [127:0] log_read_data;
wire        log_read_valid;
wire        log_buffer_full;

// Satellite delay compensation signals
wire [31:0] satellite_delay_ns;
wire        delay_comp_valid;
wire        pps_compensated_internal;

// Status and control signals
wire        t2mi_sync_locked;
wire        force_autonomous_mode;
reg [7:0]   status_counter;
reg [23:0]  led_blink_counter;

// System timestamp for logging
reg [63:0]  system_timestamp;

// =============================================================================
// Clock and Reset Management
// =============================================================================

assign clk_100mhz_buf = clk_100mhz;

// Synchronous reset generation
reset_synchronizer rst_sync_inst (
    .clk        (clk_100mhz_buf),
    .async_rst_n(rst_n),
    .sync_rst_n (rst_sync)
);

// System timestamp counter
always @(posedge clk_100mhz_buf or negedge rst_sync) begin
    if (!rst_sync) begin
        system_timestamp <= 64'h0;
    end else begin
        system_timestamp <= system_timestamp + 1;
    end
end

// =============================================================================
// T2-MI Packet Parser
// =============================================================================

t2mi_packet_parser parser_inst (
    .clk            (clk_100mhz_buf),
    .rst_n          (rst_sync),
    .t2mi_clk       (t2mi_clk),
    .t2mi_data      (t2mi_data),
    .t2mi_valid     (t2mi_valid),
    .t2mi_sync      (t2mi_sync),
    .packet_valid   (packet_valid),
    .packet_type    (packet_type),
    .packet_length  (packet_length),
    .packet_data    (packet_data),
    .packet_start   (packet_start),
    .packet_end     (packet_end),
    .sync_locked    (t2mi_sync_locked),
    .parser_error   (debug_status[0])
);

// =============================================================================
// Timestamp Extractor
// =============================================================================

timestamp_extractor ts_extractor_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .packet_valid       (packet_valid),
    .packet_type        (packet_type),
    .packet_data        (packet_data),
    .packet_start       (packet_start),
    .packet_end         (packet_end),
    .seconds_since_2000 (timestamp_seconds),
    .subseconds         (timestamp_subseconds),
    .timestamp_valid    (timestamp_ready),
    .extractor_error    (timestamp_error)
);

// =============================================================================
// Kalman Filter for Phase/Frequency Estimation
// =============================================================================

kalman_filter #(
    .DATA_WIDTH(32),
    .FRAC_BITS(16)
) kalman_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .measurement_valid  (pps_sync_status),
    .phase_measurement  (pps_time_error),
    .phase_estimate     (kalman_phase_estimate),
    .frequency_estimate (kalman_freq_estimate),
    .phase_variance     (kalman_phase_variance),
    .freq_variance      (kalman_freq_variance),
    .estimates_valid    (kalman_estimates_valid),
    .filter_converged   ()
);

// =============================================================================
// Advanced DPLL with PID Controller
// =============================================================================

advanced_dpll_pid #(
    .CLK_FREQ_HZ(100_000_000)
) dpll_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .ref_pulse          (timestamp_ready),
    .feedback_pulse     (pps_out),
    .phase_error_in     ({16'h0, kalman_phase_estimate}),
    .phase_error_valid  (kalman_estimates_valid),
    .kp                 (32'h0001_0000), // Q16.16 format
    .ki                 (32'h0000_1000), // Q16.16 format
    .kd                 (32'h0000_0800), // Q16.16 format
    .loop_enable        (1'b1),
    .phase_error_out    (dpll_phase_error),
    .frequency_correction(dpll_freq_correction),
    .dpll_locked        (dpll_lock_status),
    .allan_deviation    (dpll_allan_dev),
    .mtie               (dpll_mtie),
    .pid_saturated      ()
);

// =============================================================================
// SiT5503 High-Stability Oscillator Controller
// =============================================================================

sit5503_controller sit5503_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .scl                (sit5503_scl),
    .sda                (sit5503_sda),
    .sit5503_clk        (sit5503_clk),
    .sit5503_clk_out    (),
    .calibrate_start    (pps_calibrate_request),
    .frequency_offset   (dpll_freq_correction[15:0]),
    .offset_valid       (dpll_lock_status),
    .calibration_done   (sit5503_calibration_done),
    .oscillator_ready   (sit5503_ready),
    .status_reg         (sit5503_status_reg),
    .ref_pps            (pps_out),
    .ref_valid          (pps_sync_status)
);

// =============================================================================
// Enhanced PPS Generator with SiT5503 Support
// =============================================================================

enhanced_pps_generator pps_inst (
    .clk_100mhz         (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .sit5503_clk        (sit5503_clk),
    .sit5503_ready      (sit5503_ready),
    .timestamp_valid    (timestamp_ready),
    .timestamp_seconds  (timestamp_seconds),
    .timestamp_subsec   (timestamp_subseconds),
    .t2mi_sync_locked   (t2mi_sync_locked),
    .pps_out            (pps_out),
    .pps_backup         (pps_backup),
    .force_autonomous   (force_autonomous_mode),
    .autonomous_mode    (autonomous_mode),
    .sync_status        (pps_sync_status),
    .pps_status         (pps_status),
    .time_error         (pps_time_error),
    .calibrate_request  (pps_calibrate_request),
    .freq_correction    (pps_freq_correction),
    .calibration_done   (sit5503_calibration_done)
);

// =============================================================================
// Satellite Delay Compensation
// =============================================================================

satellite_delay_compensation sat_delay_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .pps_in             (pps_out),
    .satellite_distance (satellite_distance_km),
    .elevation_angle    (satellite_elevation),
    .params_valid       (satellite_params_valid),
    .pps_compensated    (pps_compensated_internal),
    .delay_ns           (satellite_delay_ns),
    .compensation_valid (delay_comp_valid)
);

assign pps_compensated = delay_comp_valid ? pps_compensated_internal : pps_out;

// =============================================================================
// Logging System
// =============================================================================

logging_system #(
    .LOG_BUFFER_SIZE(1024),
    .LOG_ENTRY_WIDTH(128)
) logging_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .system_timestamp   (system_timestamp),
    // Log inputs
    .log_valid          (timestamp_ready || dpll_lock_status || pps_sync_status),
    .module_id          (8'h01), // Top module ID
    .severity           (timestamp_error ? 3'd3 : 3'd1), // ERROR or INFO
    .event_id           (timestamp_ready ? 16'h0001 : 16'h0002),
    .event_data         (pps_time_error),
    // Log read interface
    .read_req           (log_read_req),
    .read_addr          (10'h0),
    .read_data          (log_read_data),
    .read_valid         (log_read_valid),
    // Status
    .buffer_full        (log_buffer_full),
    .buffer_empty       (),
    .entries_count      ()
);

// =============================================================================
// UART Monitor
// =============================================================================

uart_monitor #(
    .CLK_FREQ(100_000_000),
    .BAUD_RATE(115200)
) uart_mon_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .uart_rx            (uart_rx),
    .uart_tx            (uart_tx),
    .allan_deviation    (dpll_allan_dev),
    .mtie               (dpll_mtie),
    .phase_error        (dpll_phase_error[31:0]),
    .frequency_error    (dpll_freq_correction[31:0]),
    .dpll_locked        (dpll_lock_status),
    .pps_status         (pps_status),
    .sit5503_status     (sit5503_status_reg),
    .satellite_delay    (satellite_delay_ns),
    .log_read_req       (log_read_req),
    .log_data           (log_read_data),
    .log_data_valid     (log_read_valid),
    .tx_busy            (led_uart_activity),
    .rx_data_ready      ()
);

// =============================================================================
// Status and Debug Logic
// =============================================================================

assign timestamp_valid = timestamp_ready;
assign sync_locked = t2mi_sync_locked && pps_sync_status && dpll_lock_status;
assign dpll_locked = dpll_lock_status;
assign allan_deviation = dpll_allan_dev;
assign mtie_value = dpll_mtie;

// Debug status register
assign debug_status[1] = timestamp_error;
assign debug_status[2] = sit5503_ready;
assign debug_status[3] = autonomous_mode;
assign debug_status[4] = pps_calibrate_request;
assign debug_status[5] = sit5503_calibration_done;
assign debug_status[6] = log_buffer_full;
assign debug_status[7] = |sit5503_status_reg[7:4];

// Force autonomous mode control
assign force_autonomous_mode = 1'b0;

// =============================================================================
// LED Control Logic
// =============================================================================

always @(posedge clk_100mhz_buf or negedge rst_sync) begin
    if (!rst_sync) begin
        led_blink_counter <= 24'h0;
        status_counter <= 8'h0;
    end else begin
        led_blink_counter <= led_blink_counter + 1;
        status_counter <= status_counter + 1;
    end
end

// LED assignments
assign led_power = 1'b1;
assign led_sync = sync_locked ? 1'b1 : led_blink_counter[22];
assign led_pps = pps_out;
assign led_error = (timestamp_error || debug_status[7]) ? led_blink_counter[20] : 1'b0;
assign led_autonomous = autonomous_mode ? led_blink_counter[21] : 1'b0;
assign led_sit5503 = sit5503_ready ? 1'b1 : led_blink_counter[23];
assign led_dpll_lock = dpll_lock_status ? 1'b1 : led_blink_counter[21];

endmodule