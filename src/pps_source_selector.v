// =============================================================================
// PPS Source Selector Module
// =============================================================================
// Description: Selects between multiple PPS sources (T2MI, GNSS, External)
// with automatic failover and quality monitoring
// =============================================================================

module pps_source_selector #(
    parameter QUALITY_THRESHOLD = 16'h8000,  // Quality threshold for source selection
    parameter HOLDOVER_TIMEOUT = 32'd10      // Timeout in seconds before switching
)(
    // Clock and reset
    input  wire        clk,                  // System clock (100 MHz)
    input  wire        rst_n,                // Active low reset
    
    // Source selection control
    input  wire [1:0]  source_select,        // Manual source selection
    input  wire        auto_select_enable,   // Enable automatic source selection
    
    // T2MI PPS input
    input  wire        t2mi_pps_in,          // T2MI derived PPS
    input  wire [39:0] t2mi_seconds,         // T2MI time seconds
    input  wire [31:0] t2mi_subseconds,      // T2MI time subseconds
    input  wire        t2mi_valid,           // T2MI time valid
    input  wire [15:0] t2mi_quality,         // T2MI source quality
    
    // GNSS PPS input
    input  wire        gnss_pps_in,          // GNSS PPS input
    input  wire [39:0] gnss_seconds,         // GNSS time seconds
    input  wire [31:0] gnss_subseconds,      // GNSS time subseconds
    input  wire        gnss_valid,           // GNSS time valid
    input  wire [15:0] gnss_quality,         // GNSS source quality
    
    // External PPS input
    input  wire        ext_pps_in,           // External PPS reference
    input  wire [39:0] ext_seconds,          // External time seconds (if available)
    input  wire [31:0] ext_subseconds,       // External time subseconds (if available)
    input  wire        ext_valid,            // External time valid
    input  wire [15:0] ext_quality,          // External source quality
    
    // Selected output
    output reg         pps_out,              // Selected PPS output
    output reg  [39:0] time_seconds,         // Selected time seconds
    output reg  [31:0] time_subseconds,      // Selected time subseconds
    output reg         time_valid,           // Selected time valid
    output reg  [1:0]  active_source,        // Currently active source
    output reg  [15:0] active_quality,       // Quality of active source
    
    // Status outputs
    output reg  [2:0]  sources_available,    // Bit mask of available sources
    output reg         failover_active,      // Failover mode active
    output reg  [31:0] time_since_switch,    // Time since last source switch
    output wire [47:0] source_phase_error    // Phase error between sources
);

// =============================================================================
// Parameters and Constants
// =============================================================================

localparam SOURCE_T2MI = 2'b00;
localparam SOURCE_GNSS = 2'b01;
localparam SOURCE_EXT  = 2'b10;
localparam SOURCE_NONE = 2'b11;

// =============================================================================
// Internal signals
// =============================================================================

// Edge detection for PPS signals
reg  t2mi_pps_d1, t2mi_pps_d2;
reg  gnss_pps_d1, gnss_pps_d2;
reg  ext_pps_d1, ext_pps_d2;
wire t2mi_pps_edge;
wire gnss_pps_edge;
wire ext_pps_edge;

// Source monitoring
reg  [31:0] t2mi_last_pps_time;
reg  [31:0] gnss_last_pps_time;
reg  [31:0] ext_last_pps_time;
reg  [31:0] t2mi_timeout_counter;
reg  [31:0] gnss_timeout_counter;
reg  [31:0] ext_timeout_counter;

// Quality monitoring
reg  [15:0] t2mi_quality_filtered;
reg  [15:0] gnss_quality_filtered;
reg  [15:0] ext_quality_filtered;

// Phase comparison
reg  signed [47:0] t2mi_gnss_phase_diff;
reg  signed [47:0] t2mi_ext_phase_diff;
reg  signed [47:0] gnss_ext_phase_diff;

// State machine
reg  [2:0]  state;
reg  [2:0]  next_state;
reg  [31:0] state_timer;

localparam STATE_IDLE       = 3'b000;
localparam STATE_INIT       = 3'b001;
localparam STATE_MONITOR    = 3'b010;
localparam STATE_SWITCHING  = 3'b011;
localparam STATE_HOLDOVER   = 3'b100;

// =============================================================================
// Edge detection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        t2mi_pps_d1 <= 1'b0;
        t2mi_pps_d2 <= 1'b0;
        gnss_pps_d1 <= 1'b0;
        gnss_pps_d2 <= 1'b0;
        ext_pps_d1  <= 1'b0;
        ext_pps_d2  <= 1'b0;
    end else begin
        t2mi_pps_d1 <= t2mi_pps_in;
        t2mi_pps_d2 <= t2mi_pps_d1;
        gnss_pps_d1 <= gnss_pps_in;
        gnss_pps_d2 <= gnss_pps_d1;
        ext_pps_d1  <= ext_pps_in;
        ext_pps_d2  <= ext_pps_d1;
    end
end

assign t2mi_pps_edge = t2mi_pps_d1 && !t2mi_pps_d2;
assign gnss_pps_edge = gnss_pps_d1 && !gnss_pps_d2;
assign ext_pps_edge  = ext_pps_d1  && !ext_pps_d2;

// =============================================================================
// Source availability monitoring
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sources_available <= 3'b000;
        t2mi_timeout_counter <= 32'd0;
        gnss_timeout_counter <= 32'd0;
        ext_timeout_counter  <= 32'd0;
        t2mi_last_pps_time <= 32'd0;
        gnss_last_pps_time <= 32'd0;
        ext_last_pps_time  <= 32'd0;
    end else begin
        // Update timeout counters
        t2mi_timeout_counter <= t2mi_timeout_counter + 1;
        gnss_timeout_counter <= gnss_timeout_counter + 1;
        ext_timeout_counter  <= ext_timeout_counter + 1;
        
        // Reset counters on PPS edges
        if (t2mi_pps_edge && t2mi_valid) begin
            t2mi_timeout_counter <= 32'd0;
            t2mi_last_pps_time <= time_subseconds;
        end
        
        if (gnss_pps_edge && gnss_valid) begin
            gnss_timeout_counter <= 32'd0;
            gnss_last_pps_time <= time_subseconds;
        end
        
        if (ext_pps_edge && ext_valid) begin
            ext_timeout_counter <= 32'd0;
            ext_last_pps_time <= time_subseconds;
        end
        
        // Update availability status (2 second timeout)
        sources_available[0] <= (t2mi_timeout_counter < 32'd200_000_000) && t2mi_valid;
        sources_available[1] <= (gnss_timeout_counter < 32'd200_000_000) && gnss_valid;
        sources_available[2] <= (ext_timeout_counter  < 32'd200_000_000) && ext_valid;
    end
end

// =============================================================================
// Quality filtering
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        t2mi_quality_filtered <= 16'd0;
        gnss_quality_filtered <= 16'd0;
        ext_quality_filtered  <= 16'd0;
    end else begin
        // Simple IIR filter for quality values
        t2mi_quality_filtered <= (t2mi_quality_filtered[15:1] + t2mi_quality[15:1]);
        gnss_quality_filtered <= (gnss_quality_filtered[15:1] + gnss_quality[15:1]);
        ext_quality_filtered  <= (ext_quality_filtered[15:1]  + ext_quality[15:1]);
    end
end

// =============================================================================
// Phase comparison
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        t2mi_gnss_phase_diff <= 48'd0;
        t2mi_ext_phase_diff  <= 48'd0;
        gnss_ext_phase_diff  <= 48'd0;
    end else begin
        // Calculate phase differences when both sources have valid PPS
        if (t2mi_pps_edge && gnss_pps_edge) begin
            t2mi_gnss_phase_diff <= {16'd0, t2mi_subseconds} - {16'd0, gnss_subseconds};
        end
        
        if (t2mi_pps_edge && ext_pps_edge) begin
            t2mi_ext_phase_diff <= {16'd0, t2mi_subseconds} - {16'd0, ext_subseconds};
        end
        
        if (gnss_pps_edge && ext_pps_edge) begin
            gnss_ext_phase_diff <= {16'd0, gnss_subseconds} - {16'd0, ext_subseconds};
        end
    end
end

// =============================================================================
// Source selection state machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= STATE_IDLE;
        state_timer <= 32'd0;
    end else begin
        state <= next_state;
        
        if (state != next_state) begin
            state_timer <= 32'd0;
        end else begin
            state_timer <= state_timer + 1;
        end
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        STATE_IDLE: begin
            if (|sources_available) begin
                next_state = STATE_INIT;
            end
        end
        
        STATE_INIT: begin
            // Wait for stable sources
            if (state_timer > 32'd100_000_000) begin  // 1 second
                next_state = STATE_MONITOR;
            end
        end
        
        STATE_MONITOR: begin
            // Check if current source is still valid
            if (!sources_available[active_source] || 
                (active_quality < QUALITY_THRESHOLD)) begin
                next_state = STATE_SWITCHING;
            end
        end
        
        STATE_SWITCHING: begin
            // Switch completed
            if (state_timer > 32'd10_000_000) begin  // 100ms
                next_state = STATE_MONITOR;
            end
        end
        
        STATE_HOLDOVER: begin
            // Check if any source becomes available
            if (|sources_available) begin
                next_state = STATE_SWITCHING;
            end
        end
        
        default: next_state = STATE_IDLE;
    endcase
end

// =============================================================================
// Source selection logic
// =============================================================================

reg [1:0] best_source;
reg [15:0] best_quality;

always @(*) begin
    best_source = SOURCE_NONE;
    best_quality = 16'd0;
    
    if (auto_select_enable) begin
        // Automatic selection based on quality
        if (sources_available[SOURCE_T2MI] && (t2mi_quality_filtered > best_quality)) begin
            best_source = SOURCE_T2MI;
            best_quality = t2mi_quality_filtered;
        end
        
        if (sources_available[SOURCE_GNSS] && (gnss_quality_filtered > best_quality)) begin
            best_source = SOURCE_GNSS;
            best_quality = gnss_quality_filtered;
        end
        
        if (sources_available[SOURCE_EXT] && (ext_quality_filtered > best_quality)) begin
            best_source = SOURCE_EXT;
            best_quality = ext_quality_filtered;
        end
    end else begin
        // Manual selection
        if (sources_available[source_select]) begin
            best_source = source_select;
            case (source_select)
                SOURCE_T2MI: best_quality = t2mi_quality_filtered;
                SOURCE_GNSS: best_quality = gnss_quality_filtered;
                SOURCE_EXT:  best_quality = ext_quality_filtered;
                default:     best_quality = 16'd0;
            endcase
        end
    end
end

// =============================================================================
// Output selection
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_out <= 1'b0;
        time_seconds <= 40'd0;
        time_subseconds <= 32'd0;
        time_valid <= 1'b0;
        active_source <= SOURCE_NONE;
        active_quality <= 16'd0;
        failover_active <= 1'b0;
        time_since_switch <= 32'd0;
    end else begin
        time_since_switch <= time_since_switch + 1;
        
        case (state)
            STATE_MONITOR, STATE_SWITCHING: begin
                if ((state == STATE_SWITCHING) || (active_source != best_source)) begin
                    active_source <= best_source;
                    active_quality <= best_quality;
                    time_since_switch <= 32'd0;
                    failover_active <= (state == STATE_SWITCHING);
                end
                
                // Select outputs based on active source
                case (active_source)
                    SOURCE_T2MI: begin
                        pps_out <= t2mi_pps_in;
                        time_seconds <= t2mi_seconds;
                        time_subseconds <= t2mi_subseconds;
                        time_valid <= t2mi_valid;
                    end
                    
                    SOURCE_GNSS: begin
                        pps_out <= gnss_pps_in;
                        time_seconds <= gnss_seconds;
                        time_subseconds <= gnss_subseconds;
                        time_valid <= gnss_valid;
                    end
                    
                    SOURCE_EXT: begin
                        pps_out <= ext_pps_in;
                        time_seconds <= ext_seconds;
                        time_subseconds <= ext_subseconds;
                        time_valid <= ext_valid;
                    end
                    
                    default: begin
                        pps_out <= 1'b0;
                        time_valid <= 1'b0;
                    end
                endcase
            end
            
            STATE_HOLDOVER: begin
                failover_active <= 1'b1;
                time_valid <= 1'b0;
                // Keep last valid time running
                if (time_subseconds >= 32'd99_999_999) begin
                    time_subseconds <= 32'd0;
                    time_seconds <= time_seconds + 1;
                end else begin
                    time_subseconds <= time_subseconds + 1;
                end
            end
            
            default: begin
                pps_out <= 1'b0;
                time_valid <= 1'b0;
            end
        endcase
    end
end

// =============================================================================
// Phase error output
// =============================================================================

assign source_phase_error = (active_source == SOURCE_T2MI && sources_available[SOURCE_GNSS]) ? t2mi_gnss_phase_diff :
                           (active_source == SOURCE_T2MI && sources_available[SOURCE_EXT])  ? t2mi_ext_phase_diff :
                           (active_source == SOURCE_GNSS && sources_available[SOURCE_EXT])  ? gnss_ext_phase_diff :
                           48'd0;

endmodule