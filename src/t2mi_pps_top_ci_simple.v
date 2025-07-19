// =============================================================================
// T2MI PPS Generator Top Level Module with CI Interface (Simplified)
// =============================================================================
// Description: Simplified top-level module with minimal status signals
// Target: Lattice LFE5U-25F-6BG256C
// Author: System
// Date: December 2024
// Version: 2.0 - Simplified version
// =============================================================================

module t2mi_pps_top_ci_simple (
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
    
    // Essential Status Outputs Only
    output wire        sync_locked,      // System synchronized
    output wire        cam_ready,        // CAM ready (combines present & initialized)
    output wire        system_error,     // Any system error
    output wire [3:0]  status_code,      // 4-bit status code for diagnostics
    
    // LED Indicator
    output wire        led_1,            // Main status LED (D16)
    
    // Control inputs
    input  wire        cam_bypass,       // Bypass CAM processing
    
    // SPI Interfaces (unused but required by constraints)
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
wire        rst_sync;

// T2-MI packet parser signals
wire        packet_valid;
wire [7:0]  packet_type;
wire [15:0] packet_length;
wire [7:0]  packet_data;
wire        packet_start;
wire        packet_end;
wire        parser_error;

// CI interface signals
wire        t2mi_cam_valid;
wire [7:0]  t2mi_cam_data;
wire        cam_present;
wire        cam_initialized;
wire        cam_error;
wire [7:0]  cam_status;

// Timestamp extractor signals
wire [39:0] timestamp_seconds;
wire [31:0] timestamp_subseconds;
wire        timestamp_ready;
wire        timestamp_error;

// SiT5503 controller signals
wire        sit5503_ready;
wire        pps_calibrate_request;
wire [15:0] pps_freq_correction;
wire        sit5503_calibration_done;

// PPS generator signals
wire        t2mi_sync_locked;
wire        pps_sync_status;
wire        autonomous_mode;
wire [7:0]  pps_status;

// LED control
reg [23:0]  led_counter;

// =============================================================================
// Clock and Reset Management
// =============================================================================

// Synchronous reset generation
reset_synchronizer rst_sync_inst (
    .clk        (clk),
    .async_rst_n(rst_n),
    .sync_rst_n (rst_sync)
);

// =============================================================================
// CI Interface Module (8-bit)
// =============================================================================

ci_interface_8bit ci_inst (
    .clk              (clk),
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
    .clk            (clk),
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
    .parser_error   (parser_error)
);

// =============================================================================
// Timestamp Extractor
// =============================================================================

timestamp_extractor ts_extractor_inst (
    .clk                (clk),
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
    .clk                (clk),
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
    .status_reg         (),
    .ref_pps            (pps_out),
    .ref_valid          (pps_sync_status)
);

// =============================================================================
// Enhanced PPS Generator
// =============================================================================

enhanced_pps_generator pps_inst (
    .clk_100mhz         (clk),
    .rst_n              (rst_sync),
    .sit5503_clk        (sit5503_clk),
    .sit5503_ready      (sit5503_ready),
    .timestamp_valid    (timestamp_ready),
    .timestamp_seconds  (timestamp_seconds),
    .timestamp_subsec   (timestamp_subseconds),
    .t2mi_sync_locked   (t2mi_sync_locked),
    .pps_out            (pps_out),
    .pps_backup         (pps_backup),
    .force_autonomous   (1'b0),
    .autonomous_mode    (autonomous_mode),
    .sync_status        (pps_sync_status),
    .pps_status         (pps_status),
    .time_error         (),
    .calibrate_request  (pps_calibrate_request),
    .freq_correction    (pps_freq_correction),
    .calibration_done   (sit5503_calibration_done)
);

// =============================================================================
// Simplified Status Logic
// =============================================================================

// Main sync status - system is locked when T2MI sync and PPS sync are both good
assign sync_locked = t2mi_sync_locked && pps_sync_status;

// CAM ready when present and initialized
assign cam_ready = cam_present && cam_initialized;

// System error if any critical error occurs
assign system_error = parser_error || timestamp_error || cam_error;

// 4-bit status code for basic diagnostics
// Bit 3: CAM status (0=not ready, 1=ready)
// Bit 2: Sync status (0=not locked, 1=locked)  
// Bit 1: Autonomous mode (0=normal, 1=autonomous)
// Bit 0: Error flag (0=no error, 1=error)
assign status_code = {cam_ready, sync_locked, autonomous_mode, system_error};

// =============================================================================
// LED Control
// =============================================================================

always @(posedge clk or negedge rst_sync) begin
    if (!rst_sync) begin
        led_counter <= 24'h0;
    end else begin
        led_counter <= led_counter + 1;
    end
end

// LED behavior:
// - Solid ON: System fully operational (sync locked, CAM ready if not bypassed)
// - Fast blink: System error
// - Slow blink: System initializing or no sync
// - Very slow blink: CAM not ready (when not bypassed)
assign led_1 = system_error ? led_counter[20] :                    // Fast blink on error
               (!sync_locked) ? led_counter[22] :                  // Slow blink if no sync
               (!cam_bypass && !cam_ready) ? led_counter[23] :     // Very slow if CAM not ready
               1'b1;                                                // Solid ON when all good

// =============================================================================
// Unused SPI interface
// =============================================================================

assign sspi_miso = 1'b0;

endmodule