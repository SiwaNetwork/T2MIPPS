// =============================================================================
// Parallel T2MI Parser Module
// =============================================================================
// Description: High-performance parallel parser for T2MI packets
// Processes multiple bytes per clock cycle for increased throughput
// =============================================================================

module parallel_t2mi_parser #(
    parameter DATA_WIDTH = 64,        // Process 8 bytes in parallel
    parameter BYTE_WIDTH = 8,
    parameter NUM_BYTES = DATA_WIDTH / BYTE_WIDTH
)(
    input  wire                    clk,
    input  wire                    rst_n,
    
    // Parallel input interface
    input  wire                    data_valid,
    input  wire [DATA_WIDTH-1:0]   data_in,        // 8 bytes of data
    input  wire [NUM_BYTES-1:0]    byte_enable,    // Which bytes are valid
    
    // Output interface
    output reg                     packet_valid,
    output reg  [7:0]              packet_type,
    output reg  [15:0]             packet_length,
    output reg  [7:0]              packet_data,
    output reg                     packet_data_valid,
    output reg                     packet_complete,
    
    // Status
    output reg                     sync_locked,
    output reg  [31:0]             packet_counter,
    output reg  [31:0]             error_counter,
    output reg  [3:0]              parser_state
);

// =============================================================================
// State definitions
// =============================================================================

localparam STATE_SEARCH_SYNC = 4'd0;
localparam STATE_GET_HEADER  = 4'd1;
localparam STATE_GET_LENGTH  = 4'd2;
localparam STATE_GET_DATA    = 4'd3;
localparam STATE_PACKET_END  = 4'd4;
localparam STATE_ERROR       = 4'd5;

// =============================================================================
// Constants
// =============================================================================

localparam SYNC_BYTE = 8'h47;
localparam MIN_PACKET_LENGTH = 16'd4;
localparam MAX_PACKET_LENGTH = 16'd65535;

// =============================================================================
// Internal signals
// =============================================================================

// Sync pattern detection
reg  [NUM_BYTES-1:0] sync_detect;
wire [3:0] sync_position;
wire       sync_found;

// Packet buffer for header assembly
reg  [31:0] header_buffer;
reg  [2:0]  header_bytes;

// Data extraction
reg  [15:0] bytes_remaining;
reg  [15:0] bytes_processed;

// Shift register for data alignment
reg  [DATA_WIDTH*2-1:0] data_shift_reg;
reg  [3:0]              shift_amount;

// Pipeline stages
reg  [DATA_WIDTH-1:0]   data_pipe_1;
reg  [NUM_BYTES-1:0]    enable_pipe_1;
reg                     valid_pipe_1;

// =============================================================================
// Sync byte detection logic
// =============================================================================

integer i;
always @(*) begin
    for (i = 0; i < NUM_BYTES; i = i + 1) begin
        sync_detect[i] = (data_in[i*8 +: 8] == SYNC_BYTE) && byte_enable[i];
    end
end

// Priority encoder to find first sync byte
assign sync_found = |sync_detect;

// Find position of first sync byte
reg [3:0] sync_pos_temp;
always @(*) begin
    sync_pos_temp = 4'd0;
    for (i = NUM_BYTES-1; i >= 0; i = i - 1) begin
        if (sync_detect[i]) begin
            sync_pos_temp = i[3:0];
        end
    end
end
assign sync_position = sync_pos_temp;

// =============================================================================
// Data alignment and shifting
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_shift_reg <= {(DATA_WIDTH*2){1'b0}};
        shift_amount <= 4'd0;
    end else if (data_valid) begin
        // Shift in new data
        data_shift_reg <= {data_shift_reg[DATA_WIDTH-1:0], data_in};
        
        // Update shift amount based on sync position
        if (sync_found && parser_state == STATE_SEARCH_SYNC) begin
            shift_amount <= sync_position;
        end
    end
end

// Extract aligned data based on shift amount
wire [DATA_WIDTH-1:0] aligned_data;
assign aligned_data = data_shift_reg >> (shift_amount * 8);

// =============================================================================
// Pipeline stage 1 - Data alignment
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_pipe_1 <= {DATA_WIDTH{1'b0}};
        enable_pipe_1 <= {NUM_BYTES{1'b0}};
        valid_pipe_1 <= 1'b0;
    end else begin
        data_pipe_1 <= aligned_data;
        enable_pipe_1 <= byte_enable >> shift_amount;
        valid_pipe_1 <= data_valid;
    end
end

// =============================================================================
// Main parser state machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        parser_state <= STATE_SEARCH_SYNC;
        packet_valid <= 1'b0;
        packet_type <= 8'd0;
        packet_length <= 16'd0;
        packet_data <= 8'd0;
        packet_data_valid <= 1'b0;
        packet_complete <= 1'b0;
        sync_locked <= 1'b0;
        packet_counter <= 32'd0;
        error_counter <= 32'd0;
        header_buffer <= 32'd0;
        header_bytes <= 3'd0;
        bytes_remaining <= 16'd0;
        bytes_processed <= 16'd0;
    end else begin
        // Default outputs
        packet_data_valid <= 1'b0;
        packet_complete <= 1'b0;
        
        case (parser_state)
            
            STATE_SEARCH_SYNC: begin
                if (sync_found) begin
                    sync_locked <= 1'b1;
                    parser_state <= STATE_GET_HEADER;
                    header_bytes <= 3'd0;
                    header_buffer <= 32'd0;
                end
            end
            
            STATE_GET_HEADER: begin
                if (valid_pipe_1) begin
                    // Extract header bytes from aligned data
                    reg [2:0] bytes_to_process;
                    bytes_to_process = 3'd0;
                    
                    // Count valid bytes in this cycle
                    for (i = 0; i < NUM_BYTES && i < 4; i = i + 1) begin
                        if (enable_pipe_1[i] && header_bytes + i < 4) begin
                            bytes_to_process = i + 1;
                        end
                    end
                    
                    // Store header bytes
                    case (bytes_to_process)
                        3'd1: header_buffer[7:0]   <= data_pipe_1[7:0];
                        3'd2: header_buffer[15:0]  <= data_pipe_1[15:0];
                        3'd3: header_buffer[23:0]  <= data_pipe_1[23:0];
                        3'd4: header_buffer[31:0]  <= data_pipe_1[31:0];
                        default: ;
                    endcase
                    
                    header_bytes <= header_bytes + bytes_to_process;
                    
                    // Check if we have complete header
                    if (header_bytes + bytes_to_process >= 4) begin
                        // Verify sync byte
                        if (header_buffer[7:0] == SYNC_BYTE || 
                            (bytes_to_process >= 1 && data_pipe_1[7:0] == SYNC_BYTE)) begin
                            
                            // Extract packet info based on what we have
                            if (bytes_to_process >= 4) begin
                                packet_type <= data_pipe_1[15:8];
                                packet_length <= {data_pipe_1[23:16], data_pipe_1[31:24]};
                            end else if (header_bytes >= 2) begin
                                packet_type <= header_buffer[15:8];
                                if (header_bytes >= 4) begin
                                    packet_length <= {header_buffer[23:16], header_buffer[31:24]};
                                end else if (bytes_to_process >= 2) begin
                                    packet_length <= {data_pipe_1[7:0], data_pipe_1[15:8]};
                                end
                            end
                            
                            parser_state <= STATE_GET_LENGTH;
                        end else begin
                            // Sync error
                            parser_state <= STATE_ERROR;
                            error_counter <= error_counter + 1;
                        end
                    end
                end
            end
            
            STATE_GET_LENGTH: begin
                // Validate packet length
                if (packet_length >= MIN_PACKET_LENGTH && 
                    packet_length <= MAX_PACKET_LENGTH) begin
                    
                    packet_valid <= 1'b0;
                    bytes_remaining <= packet_length - 4;  // Subtract header size
                    bytes_processed <= 16'd0;
                    
                    if (packet_length > 4) begin
                        parser_state <= STATE_GET_DATA;
                    end else begin
                        parser_state <= STATE_PACKET_END;
                    end
                end else begin
                    parser_state <= STATE_ERROR;
                    error_counter <= error_counter + 1;
                end
            end
            
            STATE_GET_DATA: begin
                if (valid_pipe_1) begin
                    // Process multiple data bytes in parallel
                    reg [3:0] bytes_this_cycle;
                    bytes_this_cycle = 4'd0;
                    
                    // Determine how many bytes to process
                    for (i = 0; i < NUM_BYTES; i = i + 1) begin
                        if (enable_pipe_1[i] && i < bytes_remaining) begin
                            bytes_this_cycle = i + 1;
                        end
                    end
                    
                    // Output data bytes sequentially (for compatibility)
                    // In a full parallel design, this would output all bytes at once
                    for (i = 0; i < bytes_this_cycle; i = i + 1) begin
                        packet_data <= data_pipe_1[i*8 +: 8];
                        packet_data_valid <= 1'b1;
                    end
                    
                    bytes_processed <= bytes_processed + bytes_this_cycle;
                    bytes_remaining <= bytes_remaining - bytes_this_cycle;
                    
                    // Check if packet is complete
                    if (bytes_remaining <= bytes_this_cycle) begin
                        parser_state <= STATE_PACKET_END;
                        packet_complete <= 1'b1;
                    end
                end
            end
            
            STATE_PACKET_END: begin
                packet_complete <= 1'b1;
                packet_counter <= packet_counter + 1;
                
                // Look for next sync byte in remaining data
                if (valid_pipe_1 && sync_found) begin
                    parser_state <= STATE_GET_HEADER;
                    header_bytes <= 3'd0;
                end else begin
                    parser_state <= STATE_SEARCH_SYNC;
                end
            end
            
            STATE_ERROR: begin
                sync_locked <= 1'b0;
                packet_valid <= 1'b0;
                parser_state <= STATE_SEARCH_SYNC;
            end
            
            default: begin
                parser_state <= STATE_SEARCH_SYNC;
            end
        endcase
    end
end

// =============================================================================
// Performance monitoring
// =============================================================================

reg [31:0] throughput_counter;
reg [31:0] cycle_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        throughput_counter <= 32'd0;
        cycle_counter <= 32'd0;
    end else begin
        cycle_counter <= cycle_counter + 1;
        
        if (valid_pipe_1) begin
            // Count valid bytes processed
            reg [3:0] valid_bytes;
            valid_bytes = 0;
            for (i = 0; i < NUM_BYTES; i = i + 1) begin
                if (enable_pipe_1[i]) valid_bytes = valid_bytes + 1;
            end
            throughput_counter <= throughput_counter + valid_bytes;
        end
    end
end

endmodule