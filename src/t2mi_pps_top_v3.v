// =============================================================================
// T2MI PPS Generator Top Module v3
// =============================================================================
// Description: Enhanced top-level module with Kalman filter, improved DPLL,
// parallel parser, STM32 interface, GNSS support, and delay compensation
// =============================================================================

module t2mi_pps_top_v3 (
    // Clock and reset
    input  wire        clk_100mhz,       // System clock 100 MHz
    input  wire        rst_n,            // Active low reset
    
    // T2MI interface
    input  wire        t2mi_clk,         // T2MI clock (27 MHz)
    input  wire        t2mi_valid,       // T2MI data valid
    input  wire [63:0] t2mi_data,        // T2MI data (8 bytes parallel)
    input  wire [7:0]  t2mi_byte_enable, // Byte enable mask
    input  wire        t2mi_sync,        // T2MI sync signal
    
    // SiT5503 interface
    input  wire        sit5503_clk,      // 10 MHz from SiT5503
    inout  wire        sit5503_sda,      // I2C data
    output wire        sit5503_scl,      // I2C clock
    
    // STM32 interface
    input  wire        stm32_sclk,       // SPI clock
    input  wire        stm32_mosi,       // SPI MOSI
    output wire        stm32_miso,       // SPI MISO
    input  wire        stm32_cs_n,       // SPI chip select
    output wire        stm32_irq_n,      // Interrupt to STM32
    
    // GNSS interface
    input  wire        gnss_rx,          // GNSS UART RX
    output wire        gnss_tx,          // GNSS UART TX
    input  wire        gnss_pps_in,      // GNSS PPS input
    
    // UART Monitor interface
    input  wire        uart_rx,          // UART RX for monitor
    output wire        uart_tx,          // UART TX for monitor
    
    // Temperature sensor
    input  wire [15:0] temperature,      // Temperature in 0.01°C
    
    // Main outputs
    output wire        pps_out,          // Primary PPS output
    output wire        pps_backup,       // Backup PPS output
    output wire [39:0] time_seconds,     // Current time seconds
    output wire [31:0] time_subseconds,  // Current time subseconds
    
    // Status and debug
    output wire        sync_locked,      // T2MI sync status
    output wire        dpll_locked,      // DPLL lock status
    output wire        kalman_converged, // Kalman filter converged
    output wire [7:0]  debug_status,     // Debug status register
    
    // LED outputs
    output wire        led_power,        // Power LED
    output wire        led_sync,         // Sync LED
    output wire        led_pps,          // PPS LED
    output wire        led_error,        // Error LED
    output wire        led_gnss,         // GNSS LED
    output wire        led_stm32         // STM32 communication LED
);

// =============================================================================
// Internal signals
// =============================================================================

// Clock synchronization
wire rst_n_sync;

// Parallel parser outputs
wire        packet_valid;
wire [7:0]  packet_type;
wire [15:0] packet_length;
wire [7:0]  packet_data;
wire        packet_data_valid;
wire        packet_complete;
wire [31:0] parser_error_count;

// Timestamp extractor outputs
wire        timestamp_valid;
wire [39:0] timestamp_seconds;
wire [31:0] timestamp_subseconds;
wire [12:0] timestamp_utco;
wire [3:0]  timestamp_bw;

// Kalman filter outputs
wire        kalman_valid;
wire [39:0] kalman_seconds;
wire [31:0] kalman_subseconds;
wire [31:0] kalman_freq_offset;
wire [31:0] kalman_pred_error;
wire [3:0]  kalman_state;

// DPLL outputs
wire        dpll_pps;
wire [39:0] dpll_seconds;
wire [31:0] dpll_subseconds;
wire signed [47:0] dpll_phase_error;     // Changed to 48-bit signed
wire signed [47:0] dpll_freq_error;      // Changed to 48-bit signed
wire        dpll_holdover;
wire [31:0] dpll_holdover_quality;
wire [31:0] dpll_holdover_duration;
wire [3:0]  dpll_state;

// Advanced DPLL diagnostics
wire [47:0] dpll_phase_variance;
wire [47:0] dpll_frequency_variance;
wire [31:0] dpll_allan_deviation;
wire [31:0] dpll_mtie;
wire [31:0] dpll_tdev;
wire signed [47:0] dpll_phase_prediction;
wire [15:0] dpll_lock_quality;

// PID components
wire signed [47:0] dpll_p_term;
wire signed [47:0] dpll_i_term;
wire signed [47:0] dpll_d_term;
wire signed [47:0] dpll_pid_output;

// STM32 interface signals
wire [31:0] cable_delay_ns;
wire [31:0] antenna_delay_ns;
wire [31:0] dpll_kp;         // Changed to 32-bit for PID controller
wire [31:0] dpll_ki;         // Changed to 32-bit for PID controller
wire [31:0] dpll_kd;         // Added derivative gain
wire [31:0] dpll_integral_limit;
wire [15:0] dpll_derivative_filter;
wire [15:0] dpll_prediction_depth;
wire        kalman_enable;
wire [31:0] kalman_q;
wire [31:0] kalman_r;
wire        gnss_enable;
wire [2:0]  gnss_mode;
wire        gnss_reset_n;

// GNSS interface outputs
wire        gnss_time_valid;
wire [39:0] gnss_seconds;
wire [31:0] gnss_subseconds;
wire        gnss_pps_pulse;
wire [31:0] gnss_latitude;
wire [31:0] gnss_longitude;
wire [31:0] gnss_altitude;
wire        gnss_position_valid;
wire [7:0]  gnss_satellites;
wire [31:0] gnss_status;

// Delay compensation outputs
wire        pps_compensated;
wire [39:0] time_seconds_comp;
wire [31:0] time_subseconds_comp;
wire        time_valid_comp;
wire [31:0] total_delay_ns;
wire        compensation_active;

// Source selection
reg  [1:0]  time_source;  // 00=T2MI, 01=GNSS, 10=SiT5503
wire        source_valid;
wire [39:0] selected_seconds;
wire [31:0] selected_subseconds;

// =============================================================================
// Clock domain synchronization
// =============================================================================

sync_modules sync_inst (
    .clk        (clk_100mhz),
    .rst_n_in   (rst_n),
    .rst_n_out  (rst_n_sync)
);

// =============================================================================
// Parallel T2MI Parser
// =============================================================================

parallel_t2mi_parser #(
    .DATA_WIDTH(64),
    .BYTE_WIDTH(8)
) parser_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .data_valid         (t2mi_valid),
    .data_in            (t2mi_data),
    .byte_enable        (t2mi_byte_enable),
    .packet_valid       (packet_valid),
    .packet_type        (packet_type),
    .packet_length      (packet_length),
    .packet_data        (packet_data),
    .packet_data_valid  (packet_data_valid),
    .packet_complete    (packet_complete),
    .sync_locked        (sync_locked),
    .packet_counter     (),
    .error_counter      (parser_error_count),
    .parser_state       ()
);

// =============================================================================
// Timestamp Extractor
// =============================================================================

timestamp_extractor extractor_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .packet_valid       (packet_valid && packet_type == 8'h20),
    .packet_data        (packet_data),
    .packet_data_valid  (packet_data_valid),
    .timestamp_valid    (timestamp_valid),
    .seconds_since_2000 (timestamp_seconds),
    .subseconds         (timestamp_subseconds),
    .utco               (timestamp_utco),
    .bw                 (timestamp_bw),
    .error              ()
);

// =============================================================================
// Kalman Filter
// =============================================================================

kalman_filter #(
    .FIXED_POINT_WIDTH(64),
    .FRACTION_BITS(32)
) kalman_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .timestamp_valid    (timestamp_valid),
    .seconds_in         (timestamp_seconds),
    .subseconds_in      (timestamp_subseconds),
    .enable             (kalman_enable),
    .process_noise_q    (kalman_q),
    .measurement_noise_r(kalman_r),
    .filtered_valid     (kalman_valid),
    .filtered_seconds   (kalman_seconds),
    .filtered_subseconds(kalman_subseconds),
    .frequency_offset   (kalman_freq_offset),
    .prediction_error   (kalman_pred_error),
    .filter_state       (kalman_state),
    .filter_converged   (kalman_converged)
);

// =============================================================================
// Advanced DPLL with PID Controller
// =============================================================================

advanced_dpll_pid #(
    .CLK_FREQ_HZ(100_000_000),
    .PHASE_BITS(48),
    .FREQ_BITS(48),
    .FIXED_POINT_BITS(16)
) dpll_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .ref_pulse          (source_valid),
    .ref_seconds        (selected_seconds),
    .ref_subseconds     (selected_subseconds),
    .ref_valid          (source_valid),
    .local_clk_10mhz    (sit5503_clk),
    
    // PID control parameters
    .kp                 (dpll_kp),
    .ki                 (dpll_ki),
    .kd                 (dpll_kd),
    .loop_bandwidth     (16'd8),
    .adaptive_enable    (1'b1),
    .prediction_depth   (dpll_prediction_depth),
    
    // Advanced control
    .integral_limit     (dpll_integral_limit),
    .derivative_filter  (dpll_derivative_filter),
    .holdover_enable    (1'b1),
    
    // Outputs
    .pps_out            (dpll_pps),
    .locked_seconds     (dpll_seconds),
    .locked_subseconds  (dpll_subseconds),
    .phase_error        (dpll_phase_error),
    .frequency_error    (dpll_freq_error),
    .dpll_locked        (dpll_locked),
    .dpll_state         (dpll_state),
    
    // Holdover mode
    .holdover_active    (dpll_holdover),
    .holdover_quality   (dpll_holdover_quality),
    .holdover_duration  (dpll_holdover_duration),
    
    // Advanced diagnostics
    .phase_variance     (dpll_phase_variance),
    .frequency_variance (dpll_frequency_variance),
    .allan_deviation    (dpll_allan_deviation),
    .mtie               (dpll_mtie),
    .tdev               (dpll_tdev),
    .phase_prediction   (dpll_phase_prediction),
    .lock_quality       (dpll_lock_quality),
    
    // PID components
    .p_term             (dpll_p_term),
    .i_term             (dpll_i_term),
    .d_term             (dpll_d_term),
    .pid_output         (dpll_pid_output)
);

// =============================================================================
// STM32 Interface
// =============================================================================

stm32_interface stm32_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .spi_sclk           (stm32_sclk),
    .spi_mosi           (stm32_mosi),
    .spi_miso           (stm32_miso),
    .spi_cs_n           (stm32_cs_n),
    .irq_n              (stm32_irq_n),
    .bus_write          (),
    .bus_read           (),
    .bus_addr           (),
    .bus_wdata          (),
    .bus_rdata          (32'd0),
    .bus_ready          (1'b1),
    .pps_pulse          (pps_compensated),
    .sync_locked        (sync_locked),
    .dpll_locked        (dpll_locked),
    .current_seconds    (time_seconds_comp),
    .current_subseconds (time_subseconds_comp),
    .phase_error        (dpll_phase_error[31:0]),  // Take lower 32 bits
    .frequency_error    (dpll_freq_error[31:0]),   // Take lower 32 bits
    .cable_delay_ns     (cable_delay_ns),
    .antenna_delay_ns   (antenna_delay_ns),
    .dpll_kp            (dpll_kp),
    .dpll_ki            (dpll_ki),
    .kalman_enable      (kalman_enable),
    .kalman_q           (kalman_q),
    .kalman_r           (kalman_r),
    .gnss_enable        (gnss_enable),
    .gnss_mode          (gnss_mode),
    .gnss_reset_n       (gnss_reset_n)
);

// =============================================================================
// GNSS Interface
// =============================================================================

gnss_interface gnss_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .gnss_rx            (gnss_rx),
    .gnss_tx            (gnss_tx),
    .gnss_enable        (gnss_enable),
    .gnss_mode          (gnss_mode),
    .gnss_reset_n       (gnss_reset_n),
    .time_valid         (gnss_time_valid),
    .gnss_seconds       (gnss_seconds),
    .gnss_subseconds    (gnss_subseconds),
    .pps_from_gnss      (gnss_pps_pulse),
    .latitude           (gnss_latitude),
    .longitude          (gnss_longitude),
    .altitude           (gnss_altitude),
    .position_valid     (gnss_position_valid),
    .satellites_used    (gnss_satellites),
    .hdop               (),
    .fix_type           (),
    .gnss_status        (gnss_status)
);

// =============================================================================
// UART Monitor
// =============================================================================

uart_monitor #(
    .CLK_FREQ(100_000_000),
    .BAUD_RATE(115200)
) uart_monitor_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .uart_rx            (uart_rx),
    .uart_tx            (uart_tx),
    
    // Status inputs
    .sync_locked        (sync_locked),
    .dpll_locked        (dpll_locked),
    .dpll_state         (dpll_state),
    .lock_quality       (dpll_lock_quality),
    .phase_error        (dpll_phase_error[31:0]),
    
    // Statistics inputs
    .allan_deviation    (dpll_allan_deviation),
    .mtie               (dpll_mtie),
    
    // Time inputs
    .current_seconds    (time_seconds),
    .current_subseconds (time_subseconds),
    
    // Control outputs
    .cmd_valid          (),
    .cmd_type           (),
    .cmd_data           ()
);

// =============================================================================
// Default PID Parameters
// =============================================================================

// These can be overridden by STM32 interface
assign dpll_kd = 32'h0000_0100;              // Default Kd = 1.0 in 16.16 fixed point
assign dpll_integral_limit = 32'h0010_0000;  // Default integral limit
assign dpll_derivative_filter = 16'd10;      // Default derivative filter
assign dpll_prediction_depth = 16'd5;        // Default prediction depth

// =============================================================================
// Time Source Selection
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n_sync) begin
    if (!rst_n_sync) begin
        time_source <= 2'b00;  // Default to T2MI
    end else begin
        // Automatic source selection based on availability
        if (kalman_valid && kalman_converged) begin
            time_source <= 2'b00;  // T2MI with Kalman
        end else if (gnss_time_valid && gnss_satellites >= 4) begin
            time_source <= 2'b01;  // GNSS
        end else if (dpll_holdover) begin
            time_source <= 2'b10;  // SiT5503 holdover
        end else begin
            time_source <= 2'b00;  // Default to T2MI
        end
    end
end

// Source multiplexing
assign source_valid = (time_source == 2'b00) ? kalman_valid :
                     (time_source == 2'b01) ? gnss_time_valid :
                     (time_source == 2'b10) ? 1'b1 : 1'b0;

assign selected_seconds = (time_source == 2'b00) ? kalman_seconds :
                         (time_source == 2'b01) ? gnss_seconds :
                         (time_source == 2'b10) ? dpll_seconds : 40'd0;

assign selected_subseconds = (time_source == 2'b00) ? kalman_subseconds :
                            (time_source == 2'b01) ? gnss_subseconds :
                            (time_source == 2'b10) ? dpll_subseconds : 32'd0;

// =============================================================================
// Delay Compensation
// =============================================================================

delay_compensation #(
    .CLK_FREQ_HZ(100_000_000),
    .MAX_DELAY_NS(1_000_000)
) delay_comp_inst (
    .clk                     (clk_100mhz),
    .rst_n                   (rst_n_sync),
    .pps_in                  (dpll_pps),
    .timestamp_seconds_in    (dpll_seconds),
    .timestamp_subseconds_in (dpll_subseconds),
    .timestamp_valid_in      (dpll_locked),
    .cable_delay_ns          (cable_delay_ns),
    .antenna_delay_ns        (antenna_delay_ns),
    .system_delay_ns         (32'd0),
    .delay_enable            (1'b1),
    .temperature_c           (temperature),
    .temp_coeff_ps_c         (16'd50),  // 50 ps/°C typical
    .pps_out                 (pps_compensated),
    .timestamp_seconds_out   (time_seconds_comp),
    .timestamp_subseconds_out(time_subseconds_comp),
    .timestamp_valid_out     (time_valid_comp),
    .total_delay_ns          (total_delay_ns),
    .temp_delay_ps           (),
    .compensation_active     (compensation_active)
);

// =============================================================================
// Output assignments
// =============================================================================

assign pps_out = pps_compensated;
assign pps_backup = gnss_pps_pulse;  // GNSS PPS as backup
assign time_seconds = time_seconds_comp;
assign time_subseconds = time_subseconds_comp;

// =============================================================================
// Status and LED control
// =============================================================================

assign debug_status = {
    compensation_active,
    gnss_time_valid,
    kalman_converged,
    dpll_holdover,
    dpll_locked,
    sync_locked,
    time_source
};

// LED drivers with PWM for activity indication
reg [15:0] led_pwm_counter;
reg [7:0]  pps_activity;
reg [7:0]  comm_activity;

always @(posedge clk_100mhz or negedge rst_n_sync) begin
    if (!rst_n_sync) begin
        led_pwm_counter <= 16'd0;
        pps_activity <= 8'd0;
        comm_activity <= 8'd0;
    end else begin
        led_pwm_counter <= led_pwm_counter + 1;
        
        // PPS activity detector
        if (pps_compensated) begin
            pps_activity <= 8'hFF;
        end else if (pps_activity > 0) begin
            pps_activity <= pps_activity - 1;
        end
        
        // Communication activity
        if (!stm32_cs_n) begin
            comm_activity <= 8'hFF;
        end else if (comm_activity > 0) begin
            comm_activity <= comm_activity - 1;
        end
    end
end

assign led_power = 1'b1;
assign led_sync = sync_locked;
assign led_pps = |pps_activity;
assign led_error = (parser_error_count > 0) || !dpll_locked;
assign led_gnss = gnss_time_valid && gnss_position_valid;
assign led_stm32 = |comm_activity;

endmodule