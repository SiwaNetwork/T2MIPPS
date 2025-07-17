// =============================================================================
// Timestamp Extractor Module
// =============================================================================
// Description: Extracts timestamp information from T2-MI packets type 0x20
// Decodes DVB-T2 timestamp structure according to DVB standard
// =============================================================================

module timestamp_extractor (
    input  wire        clk,
    input  wire        rst_n,
    
    // Packet input interface
    input  wire        packet_valid,
    input  wire [7:0]  packet_type,
    input  wire [7:0]  packet_data,
    input  wire        packet_start,
    input  wire        packet_end,
    
    // Timestamp output interface
    output reg         timestamp_valid,
    output reg [39:0]  seconds_since_2000,
    output reg [31:0]  subseconds,
    output reg [12:0]  utc_offset,
    output reg [3:0]   bandwidth_code,
    output reg         timestamp_ready,
    
    // Status output
    output reg         extractor_error
);

// =============================================================================
// Parameters and Constants
// =============================================================================

// T2-MI packet types
parameter TIMESTAMP_PACKET_TYPE = 8'h20;

// Timestamp packet structure (in bytes)
parameter TIMESTAMP_PACKET_SIZE = 8'd12;  // 12 bytes total

// Extraction state machine
localparam STATE_IDLE       = 3'b000;
localparam STATE_HEADER     = 3'b001;
localparam STATE_SECONDS    = 3'b010;
localparam STATE_SUBSEC     = 3'b011;
localparam STATE_COMPLETE   = 3'b100;
localparam STATE_ERROR      = 3'b101;

// =============================================================================
// Internal Signals
// =============================================================================

reg [2:0]   extract_state;
reg [2:0]   next_extract_state;
reg [3:0]   byte_index;
reg [7:0]   timestamp_buffer [0:11];  // 12-byte buffer
reg         packet_active;
reg [3:0]   rfu_field;
reg [3:0]   bw_field;
reg [12:0]  utco_field;
reg [39:0]  seconds_field;
reg [31:0]  subsec_field;
reg         header_valid;
reg         data_complete;

// Loop variable for synthesis
integer     i;

// =============================================================================
// Packet Detection and Buffer Management
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        packet_active <= 1'b0;
        byte_index <= 4'h0;
        data_complete <= 1'b0;
        // Initialize buffer
        for (i = 0; i < 12; i = i + 1) begin
            timestamp_buffer[i] <= 8'h00;
        end
    end else begin
        if (packet_start && (packet_type == TIMESTAMP_PACKET_TYPE)) begin
            packet_active <= 1'b1;
            byte_index <= 4'h0;
            data_complete <= 1'b0;
        end else if (packet_end) begin
            packet_active <= 1'b0;
            if (packet_active && (byte_index == TIMESTAMP_PACKET_SIZE)) begin
                data_complete <= 1'b1;
            end
        end else if (packet_active && packet_valid) begin
            if (byte_index < TIMESTAMP_PACKET_SIZE) begin
                timestamp_buffer[byte_index] <= packet_data;
                byte_index <= byte_index + 1'b1;
            end
        end else begin
            data_complete <= 1'b0;
        end
    end
end

// =============================================================================
// Timestamp Field Extraction
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rfu_field <= 4'h0;
        bw_field <= 4'h0;
        utco_field <= 13'h0000;
        seconds_field <= 40'h0000000000;
        subsec_field <= 32'h00000000;
        header_valid <= 1'b0;
    end else if (data_complete) begin
        // Extract header fields from first byte
        rfu_field <= timestamp_buffer[0][7:4];
        bw_field <= timestamp_buffer[0][3:0];
        
        // Validate header (rfu should be 0)
        header_valid <= (timestamp_buffer[0][7:4] == 4'h0);
        
        // Extract UTC offset (13 bits across bytes 1-2)
        utco_field <= {timestamp_buffer[1][4:0], timestamp_buffer[2]};
        
        // Extract seconds since 2000 (40 bits across bytes 3-7)
        seconds_field <= {
            timestamp_buffer[3],
            timestamp_buffer[4],
            timestamp_buffer[5],
            timestamp_buffer[6],
            timestamp_buffer[7]
        };
        
        // Extract subseconds (32 bits across bytes 8-11)
        subsec_field <= {
            timestamp_buffer[8],
            timestamp_buffer[9],
            timestamp_buffer[10],
            timestamp_buffer[11]
        };
    end
end

// =============================================================================
// Extraction State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        extract_state <= STATE_IDLE;
    end else begin
        extract_state <= next_extract_state;
    end
end

always @(*) begin
    next_extract_state = extract_state;
    
    case (extract_state)
        STATE_IDLE: begin
            if (data_complete) begin
                next_extract_state = STATE_HEADER;
            end
        end
        
        STATE_HEADER: begin
            if (header_valid) begin
                next_extract_state = STATE_SECONDS;
            end else begin
                next_extract_state = STATE_ERROR;
            end
        end
        
        STATE_SECONDS: begin
            // Validate seconds field (basic range check)
            if (seconds_field < 40'hFFFFFFFFFF) begin  // Max reasonable value
                next_extract_state = STATE_SUBSEC;
            end else begin
                next_extract_state = STATE_ERROR;
            end
        end
        
        STATE_SUBSEC: begin
            // Subseconds validation could be added here
            next_extract_state = STATE_COMPLETE;
        end
        
        STATE_COMPLETE: begin
            next_extract_state = STATE_IDLE;
        end
        
        STATE_ERROR: begin
            next_extract_state = STATE_IDLE;
        end
        
        default: begin
            next_extract_state = STATE_IDLE;
        end
    endcase
end

// =============================================================================
// Output Generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timestamp_valid <= 1'b0;
        seconds_since_2000 <= 40'h0000000000;
        subseconds <= 32'h00000000;
        utc_offset <= 13'h0000;
        bandwidth_code <= 4'h0;
        timestamp_ready <= 1'b0;
        extractor_error <= 1'b0;
    end else begin
        // Default values
        timestamp_valid <= 1'b0;
        timestamp_ready <= 1'b0;
        extractor_error <= 1'b0;
        
        case (extract_state)
            STATE_COMPLETE: begin
                timestamp_valid <= 1'b1;
                timestamp_ready <= 1'b1;
                seconds_since_2000 <= seconds_field;
                subseconds <= subsec_field;
                utc_offset <= utco_field;
                bandwidth_code <= bw_field;
            end
            
            STATE_ERROR: begin
                extractor_error <= 1'b1;
            end
            
            default: begin
                // Keep previous values
            end
        endcase
    end
end

// =============================================================================
// Debug and Monitoring
// =============================================================================

// Synthesis translate_off
always @(posedge clk) begin
    if (timestamp_ready) begin
        $display("Timestamp extracted at time %t:", $time);
        $display("  Bandwidth code: %h", bandwidth_code);
        $display("  UTC offset: %d seconds", utc_offset);
        $display("  Seconds since 2000: %d", seconds_since_2000);
        $display("  Subseconds: 0x%08x", subseconds);
    end
    
    if (extractor_error) begin
        $display("Timestamp extraction error at time %t", $time);
        $display("  Header valid: %b", header_valid);
        $display("  RFU field: %h (should be 0)", rfu_field);
    end
end
// Synthesis translate_on

endmodule

