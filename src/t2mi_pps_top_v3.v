// =============================================================================
// T2MI PPS Generator Top Level Module with CAM Support
// =============================================================================
// Description: Top-level module for T2MI PPS generator with CAM interface
//              supporting EN50221/PCMCIA standards
// Target: Lattice LFE5U-25F-6BG256C
// Author: System
// Date: December 2024
// Version: 3.0 - Added CAM interface support
// =============================================================================

module t2mi_pps_top_v3 (
    // Clock and Reset
    input  wire        clk_100mhz,       // 100 MHz system clock
    input  wire        rst_n,            // Active low reset
    
    // T2-MI Input Interface
    input  wire        t2mi_clk,         // T2-MI stream clock
    input  wire        t2mi_valid,       // T2-MI data valid
    input  wire [7:0]  t2mi_data,        // T2-MI data byte
    input  wire        t2mi_sync,        // T2-MI sync signal
    
    // PCMCIA/CAM Interface (16-bit data bus)
    inout  wire [15:0] pcmcia_data,     // PCMCIA data bus
    output wire [25:0] pcmcia_addr,     // PCMCIA address bus
    output wire        pcmcia_ce1_n,     // Card Enable 1
    output wire        pcmcia_ce2_n,     // Card Enable 2
    output wire        pcmcia_oe_n,      // Output Enable
    output wire        pcmcia_we_n,      // Write Enable
    output wire        pcmcia_reg_n,     // Register select
    input  wire        pcmcia_wait_n,    // Wait signal
    input  wire        pcmcia_cd1_n,     // Card Detect 1
    input  wire        pcmcia_cd2_n,     // Card Detect 2
    output wire        pcmcia_reset,     // CAM reset
    input  wire        pcmcia_ready,     // CAM ready
    input  wire        pcmcia_ireq_n,    // Interrupt request
    output wire        pcmcia_vcc_en,    // VCC enable
    output wire        pcmcia_vpp_en,    // VPP enable
    output wire [1:0]  pcmcia_vs,        // Voltage sense
    
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
    output wire        led_power,        // Power indicator
    output wire        led_sync,         // Sync status indicator
    output wire        led_pps,          // PPS activity indicator
    output wire        led_error,        // Error indicator
    output wire        led_autonomous,   // Autonomous mode indicator
    output wire        led_sit5503,      // SiT5503 status indicator
    output wire        led_cam,          // CAM status indicator
    
    // Control inputs
    input  wire        cam_bypass        // Bypass CAM processing
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

// CAM interface signals
wire        t2mi_cam_valid;
wire [7:0]  t2mi_cam_data;
wire        cam_error;
wire        ts_clk;
wire        ts_valid;
wire        ts_sync;
wire [7:0]  ts_data;

// EN50221 protocol signals
wire [25:0] mem_addr;
wire [15:0] mem_data_out;
wire [15:0] mem_data_in;
wire        mem_read;
wire        mem_write;
wire        mem_attr;
wire        mem_ready;
wire        link_ready;
wire        link_error;
wire [7:0]  link_status;
wire        session_open;
wire [15:0] session_number;

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

// Buffer input clock
assign clk_100mhz_buf = clk_100mhz;

// Synchronous reset generation
reset_synchronizer rst_sync_inst (
    .clk        (clk_100mhz_buf),
    .async_rst_n(rst_n),
    .sync_rst_n (rst_sync)
);

// =============================================================================
// CAM Interface Module
// =============================================================================

cam_interface cam_inst (
    .clk_100mhz       (clk_100mhz_buf),
    .rst_n            (rst_sync),
    
    // PCMCIA Interface
    .pcmcia_data      (pcmcia_data),
    .pcmcia_addr      (pcmcia_addr),
    .pcmcia_ce1_n     (pcmcia_ce1_n),
    .pcmcia_ce2_n     (pcmcia_ce2_n),
    .pcmcia_oe_n      (pcmcia_oe_n),
    .pcmcia_we_n      (pcmcia_we_n),
    .pcmcia_reg_n     (pcmcia_reg_n),
    .pcmcia_wait_n    (pcmcia_wait_n),
    .pcmcia_cd1_n     (pcmcia_cd1_n),
    .pcmcia_cd2_n     (pcmcia_cd2_n),
    .pcmcia_reset     (pcmcia_reset),
    .pcmcia_ready     (pcmcia_ready),
    .pcmcia_ireq_n    (pcmcia_ireq_n),
    .pcmcia_vcc_en    (pcmcia_vcc_en),
    .pcmcia_vpp_en    (pcmcia_vpp_en),
    .pcmcia_vs        (pcmcia_vs),
    
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
    .cam_bypass       (cam_bypass),
    
    // Transport Stream Interface
    .ts_clk           (ts_clk),
    .ts_valid         (ts_valid),
    .ts_sync          (ts_sync),
    .ts_data          (ts_data)
);

// =============================================================================
// EN50221 Protocol Module
// =============================================================================

en50221_protocol protocol_inst (
    .clk              (clk_100mhz_buf),
    .rst_n            (rst_sync),
    
    // Memory Interface
    .mem_addr         (mem_addr),
    .mem_data_out     (mem_data_out),
    .mem_data_in      (pcmcia_data),
    .mem_read         (mem_read),
    .mem_write        (mem_write),
    .mem_attr         (mem_attr),
    .mem_ready        (mem_ready),
    
    // Transport Layer Interface
    .tpdu_valid       (),
    .tpdu_tag         (),
    .tpdu_length      (),
    .tpdu_data        (),
    .tpdu_start       (),
    .tpdu_end         (),
    
    .tpdu_req_valid   (1'b0),
    .tpdu_req_tag     (8'h00),
    .tpdu_req_length  (16'h0000),
    .tpdu_req_data    (8'h00),
    .tpdu_req_start   (1'b0),
    .tpdu_req_end     (1'b0),
    
    // Control Interface
    .link_init        (cam_present),
    .buffer_size      (16'd2048),
    .link_ready       (link_ready),
    .link_error       (link_error),
    .link_status      (link_status),
    
    // Session Layer Interface
    .session_open     (session_open),
    .session_number   (session_number),
    .session_close_req(1'b0)
);

// Memory ready signal generation
assign mem_ready = ~pcmcia_wait_n;

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
assign debug_status[7] = link_error;

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

// LED assignments with blinking patterns
assign led_power = 1'b1;  // Always on when powered

assign led_sync = sync_locked ? 1'b1 : led_blink_counter[22];

assign led_pps = pps_out;  // Flash with PPS pulse

assign led_error = (timestamp_error || debug_status[7] || cam_error) ? 
                   led_blink_counter[20] : 1'b0;

assign led_autonomous = autonomous_mode ? 
                       led_blink_counter[21] : 1'b0;

assign led_sit5503 = sit5503_ready ? 1'b1 : led_blink_counter[23];

assign led_cam = cam_present ? 
                (cam_initialized ? 1'b1 : led_blink_counter[21]) : 
                led_blink_counter[23];

endmodule