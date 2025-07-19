// =============================================================================
// T2MI PPS Generator Top Level Module with CI Interface
// =============================================================================
// Description: Top-level module for T2MI PPS generator with 8-bit CI interface
//              for CAM module support (EN50221 compliant)
// Target: Lattice LFE5U-25F-6BG256C
// Author: System
// Date: December 2024
// Version: 1.0 - CI Interface version
// =============================================================================

module t2mi_pps_top_ci (
    // Clock and Reset
    input  wire        clk,              // System clock (from L16)
    input  wire        rst_n,            // Active low reset
    
    // T2-MI Input Interface
    input  wire        t2mi_clk,         // T2-MI stream clock
    input  wire        t2mi_valid,       // T2-MI data valid
    input  wire [7:0]  t2mi_data,        // T2-MI data byte
    input  wire        t2mi_sync,        // T2-MI sync signal
    
    // CI Interface (8-bit data bus)
    output wire        ci_reset,         // CI reset
    output wire [7:0]  ci_a,            // 8-bit address bus
    output wire [6:0]  ci_a_ext,        // Extended address bits
    inout  wire [7:0]  ci_d,            // 8-bit bidirectional data bus
    output wire        ci_reg_n,         // Register/Attribute Memory Select
    output wire        ci_ce1_n,         // Card Enable
    output wire        ci_oe_n,          // Output Enable
    output wire        ci_we_n,          // Write Enable
    output wire        ci_iord_n,        // I/O Read
    output wire        ci_iowr_n,        // I/O Write
    input  wire        ci_ireq_n,        // Interrupt Request
    input  wire        ci_inpack_n,      // Input Acknowledge
    output wire        bus_oe,           // Bus output enable
    
    // Media Data Input (from CAM to Host)
    input  wire [7:0]  ci_mdi,           // Media data input
    input  wire        ci_mclki,         // Media clock input
    input  wire        ci_mival,         // Media input valid
    input  wire        ci_mistrt,        // Media input start
    
    // Media Data Output (from Host to CAM)
    output wire [7:0]  ci_mdo,           // Media data output
    output wire        ci_mclko,         // Media clock output
    output wire        ci_moval,         // Media output valid
    output wire        ci_mostrt,        // Media output start
    
    // SiT5503 High-Stability Oscillator Interface
    input  wire        sit5503_clk,      // 10 MHz from SiT5503
    output wire        sit5503_scl,      // I2C clock to SiT5503
    inout  wire        sit5503_sda,      // I2C data to SiT5503
    
    // PPS Outputs
    output wire        pps_out,          // Main PPS output
    output wire        pps_backup,       // Backup PPS output
    
    // Status and Debug
    output wire        timestamp_valid,  // Timestamp extracted flag
    output wire        sync_locked,      // T2-MI sync locked
    output wire        autonomous_mode,  // Operating in autonomous mode
    output wire        sit5503_ready,    // SiT5503 oscillator ready
    output wire        cam_present,      // CAM module present
    output wire        cam_initialized,  // CAM initialized
    output wire [7:0]  debug_status,     // Debug status register
    output wire [7:0]  pps_status,       // PPS generator status
    output wire [7:0]  cam_status,       // CAM status register
    
    // LED Indicators
    output wire        led_1,            // Main status LED (D16)
    output wire        led_power,        // Power indicator
    output wire        led_sync,         // Sync status indicator
    output wire        led_pps,          // PPS activity indicator
    output wire        led_error,        // Error indicator
    output wire        led_cam,          // CAM status indicator
    
    // Control inputs
    input  wire        cam_bypass,       // Bypass CAM processing
    
    // SPI Interfaces (unused in this version)
    input  wire        spi2_mosi,
    input  wire        spi2_cs_n,
    input  wire        spi2_clk,
    input  wire        sspi_clk,
    input  wire        sspi_cs_n,
    input  wire        sspi_mosi,
    output wire        sspi_miso,
    input  wire        program_n
);

// =============================================================================
// Internal Signals
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

// CI interface signals
wire        t2mi_cam_valid;
wire [7:0]  t2mi_cam_data;
wire        cam_error;

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

// Status and control signals
wire        t2mi_sync_locked;
wire        force_autonomous_mode;
reg [7:0]   status_counter;
reg [23:0]  led_blink_counter;

// =============================================================================
// Clock and Reset Management
// =============================================================================

// Use input clock directly (already at correct frequency)
assign clk_100mhz_buf = clk;

// Synchronous reset generation
reset_synchronizer rst_sync_inst (
    .clk        (clk_100mhz_buf),
    .async_rst_n(rst_n),
    .sync_rst_n (rst_sync)
);

// =============================================================================
// CI Interface Module (8-bit)
// =============================================================================

ci_interface_8bit ci_inst (
    .clk              (clk_100mhz_buf),
    .rst_n            (rst_sync),
    
    // CI Control Interface
    .ci_reset         (ci_reset),
    .ci_a             (ci_a),
    .ci_a_ext         (ci_a_ext),
    .ci_d             (ci_d),
    .ci_reg_n         (ci_reg_n),
    .ci_ce1_n         (ci_ce1_n),
    .ci_oe_n          (ci_oe_n),
    .ci_we_n          (ci_we_n),
    .ci_iord_n        (ci_iord_n),
    .ci_iowr_n        (ci_iowr_n),
    .ci_ireq_n        (ci_ireq_n),
    .ci_inpack_n      (ci_inpack_n),
    .bus_oe           (bus_oe),
    
    // Media Data Input
    .ci_mdi           (ci_mdi),
    .ci_mclki         (ci_mclki),
    .ci_mival         (ci_mival),
    .ci_mistrt        (ci_mistrt),
    
    // Media Data Output
    .ci_mdo           (ci_mdo),
    .ci_mclko         (ci_mclko),
    .ci_moval         (ci_moval),
    .ci_mostrt        (ci_mostrt),
    
    // T2MI Stream Interface
    .t2mi_clk         (t2mi_clk),
    .t2mi_valid       (t2mi_valid),
    .t2mi_data        (t2mi_data),
    .t2mi_cam_valid   (t2mi_cam_valid),
    .t2mi_cam_data    (t2mi_cam_data),
    
    // Control and Status
    .cam_present      (cam_present),
    .cam_initialized  (cam_initialized),
    .cam_error        (cam_error),
    .cam_status       (cam_status),
    .cam_bypass       (cam_bypass)
);

// =============================================================================
// T2-MI Packet Parser
// =============================================================================

t2mi_packet_parser parser_inst (
    .clk            (clk_100mhz_buf),
    .rst_n          (rst_sync),
    .t2mi_clk       (t2mi_clk),
    .t2mi_data      (cam_bypass ? t2mi_data : t2mi_cam_data),
    .t2mi_valid     (cam_bypass ? t2mi_valid : t2mi_cam_valid),
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
    .frequency_offset   (pps_freq_correction),
    .offset_valid       (pps_calibrate_request),
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
// Status and Debug Logic
// =============================================================================

assign timestamp_valid = timestamp_ready;
assign sync_locked = t2mi_sync_locked && pps_sync_status;

// Debug status register
assign debug_status[1] = timestamp_error;
assign debug_status[2] = sit5503_ready;
assign debug_status[3] = autonomous_mode;
assign debug_status[4] = cam_present;
assign debug_status[5] = cam_initialized;
assign debug_status[6] = cam_error;
assign debug_status[7] = |cam_status[7:4];

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
assign led_1 = cam_present ? 
               (cam_initialized ? 1'b1 : led_blink_counter[21]) : 
               led_blink_counter[23];  // Main status LED

assign led_power = 1'b1;  // Always on when powered

assign led_sync = sync_locked ? 1'b1 : led_blink_counter[22];

assign led_pps = pps_out;  // Flash with PPS pulse

assign led_error = (timestamp_error || cam_error) ? 
                   led_blink_counter[20] : 1'b0;

assign led_cam = cam_present ? 
                (cam_initialized ? 1'b1 : led_blink_counter[21]) : 
                led_blink_counter[23];

// =============================================================================
// Unused SPI interfaces
// =============================================================================

assign sspi_miso = 1'b0;

endmodule