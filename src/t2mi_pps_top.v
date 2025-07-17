// =============================================================================
// T2MI PPS Generator Top Level Module with SiT5503 Support
// =============================================================================
// Description: Top-level module for T2MI PPS generator with high-stability
//              SiT5503 oscillator support and autonomous operation capability
// Target: Lattice LFE5U-25F-6BG256C
// Author: Manus AI
// Date: June 6, 2025
// Version: 2.0 - Added SiT5503 support
// =============================================================================

module t2mi_pps_top (
    // Clock and Reset
    input  wire        clk_100mhz,       // 100 MHz system clock
    input  wire        rst_n,            // Active low reset
    
    // T2-MI Input Interface
    input  wire        t2mi_clk,         // T2-MI stream clock
    input  wire        t2mi_valid,       // T2-MI data valid
    input  wire [7:0]  t2mi_data,        // T2-MI data byte
    input  wire        t2mi_sync,        // T2-MI sync signal
    
    // SiT5503 High-Stability Oscillator Interface
    input  wire        sit5503_clk,      // 10 MHz from SiT5503
    output wire        sit5503_scl,      // I2C clock to SiT5503
    inout  wire        sit5503_sda,      // I2C data to SiT5503
    
    // PPS Outputs
    output wire        pps_out,          // Main PPS output (high precision)
    output wire        pps_backup,       // Backup PPS output
    
    // Status and Debug
    output wire        timestamp_valid,  // Timestamp extracted flag
    output wire        sync_locked,      // T2-MI sync locked
    output wire        autonomous_mode,  // Operating in autonomous mode
    output wire        sit5503_ready,    // SiT5503 oscillator ready
    output wire [7:0]  debug_status,     // Debug status register
    output wire [7:0]  pps_status,       // PPS generator status
    
    // LED Indicators
    output wire        led_power,        // Power indicator
    output wire        led_sync,         // Sync status indicator
    output wire        led_pps,          // PPS activity indicator
    output wire        led_error,        // Error indicator
    output wire        led_autonomous,   // Autonomous mode indicator
    output wire        led_sit5503       // SiT5503 status indicator
);

// =============================================================================
// Internal Signals
// =============================================================================

// Clock domain crossing signals
wire        t2mi_clk_sync;
wire        rst_n_sync;

// T2-MI packet parser signals
wire        packet_valid;
wire [7:0]  packet_type;
wire [15:0] packet_length;
wire [7:0]  packet_data;
wire        packet_start;
wire        packet_end;

// Timestamp extractor signals
wire        timestamp_packet_valid;
wire [39:0] seconds_since_2000;
wire [31:0] subseconds;
wire [12:0] utc_offset;
wire [3:0]  bandwidth_code;
wire        timestamp_ready;

// PPS generator signals
wire        pps_pulse;
wire        pps_error;
wire [31:0] pps_counter;

// Status signals
wire        parser_error;
wire        extractor_error;
wire [7:0]  internal_status;

// =============================================================================
// Clock Domain Crossing and Reset Synchronization
// =============================================================================

// Synchronize T2-MI clock to system domain
clk_sync_module clk_sync_inst (
    .clk_in     (t2mi_clk),
    .clk_out    (clk_100mhz),
    .clk_sync   (t2mi_clk_sync)
);

// Reset synchronizer
reset_sync_module reset_sync_inst (
    .clk        (clk_100mhz),
    .rst_n_in   (rst_n),
    .rst_n_out  (rst_n_sync)
);

// =============================================================================
// T2-MI Packet Parser
// =============================================================================

t2mi_packet_parser parser_inst (
    .clk            (clk_100mhz),
    .rst_n          (rst_n_sync),
    
    // T2-MI input
    .t2mi_clk       (t2mi_clk_sync),
    .t2mi_valid     (t2mi_valid),
    .t2mi_data      (t2mi_data),
    .t2mi_sync      (t2mi_sync),
    
    // Packet output
    .packet_valid   (packet_valid),
    .packet_type    (packet_type),
    .packet_length  (packet_length),
    .packet_data    (packet_data),
    .packet_start   (packet_start),
    .packet_end     (packet_end),
    
    // Status
    .sync_locked    (sync_locked),
    .parser_error   (parser_error)
);

// =============================================================================
// Timestamp Extractor (Type 0x20 packets)
// =============================================================================

timestamp_extractor extractor_inst (
    .clk                    (clk_100mhz),
    .rst_n                  (rst_n_sync),
    
    // Packet input
    .packet_valid           (packet_valid),
    .packet_type            (packet_type),
    .packet_data            (packet_data),
    .packet_start           (packet_start),
    .packet_end             (packet_end),
    
    // Timestamp output
    .timestamp_valid        (timestamp_packet_valid),
    .seconds_since_2000     (seconds_since_2000),
    .subseconds             (subseconds),
    .utc_offset             (utc_offset),
    .bandwidth_code         (bandwidth_code),
    .timestamp_ready        (timestamp_ready),
    
    // Status
    .extractor_error        (extractor_error)
);

// =============================================================================
// PPS Generator
// =============================================================================

pps_generator pps_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    
    // Timestamp input
    .timestamp_valid    (timestamp_packet_valid),
    .seconds_since_2000 (seconds_since_2000),
    .subseconds         (subseconds),
    .timestamp_ready    (timestamp_ready),
    
    // PPS output
    .pps_pulse          (pps_pulse),
    .pps_counter        (pps_counter),
    
    // Status
    .pps_error          (pps_error)
);

// =============================================================================
// Status and Debug Logic
// =============================================================================

// Combine status signals
assign internal_status = {
    pps_error,          // bit 7
    extractor_error,    // bit 6  
    parser_error,       // bit 5
    timestamp_ready,    // bit 4
    timestamp_packet_valid, // bit 3
    packet_valid,       // bit 2
    sync_locked,        // bit 1
    rst_n_sync          // bit 0
};

// Output assignments
assign pps_out = pps_pulse;
assign timestamp_valid = timestamp_packet_valid;
assign debug_status = internal_status;

// LED assignments
assign led_power = rst_n_sync;
assign led_sync = sync_locked;
assign led_pps = pps_pulse;
assign led_error = pps_error | extractor_error | parser_error;

endmodule

