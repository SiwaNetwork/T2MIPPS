// =============================================================================
// EN50221 Protocol Implementation Module
// =============================================================================
// Description: Implements EN50221 DVB Common Interface protocol layer
//              for communication with Conditional Access Module (CAM)
// Target: Lattice LFE5U-25F-6BG256C
// Author: System
// Date: December 2024
// Version: 1.0
// =============================================================================

module en50221_protocol (
    // System Clock and Reset
    input  wire        clk,              // System clock
    input  wire        rst_n,            // Active low reset
    
    // PCMCIA Memory Interface
    output reg [25:0]  mem_addr,         // Memory address
    output reg [15:0]  mem_data_out,     // Data to write
    input  wire [15:0] mem_data_in,      // Data read
    output reg         mem_read,         // Read enable
    output reg         mem_write,        // Write enable
    output reg         mem_attr,         // Attribute memory select
    input  wire        mem_ready,        // Memory ready
    
    // Transport Layer Interface
    output reg         tpdu_valid,       // TPDU valid
    output reg [7:0]   tpdu_tag,         // TPDU tag
    output reg [15:0]  tpdu_length,      // TPDU length
    output reg [7:0]   tpdu_data,        // TPDU data byte
    output reg         tpdu_start,       // TPDU start flag
    output reg         tpdu_end,         // TPDU end flag
    
    input  wire        tpdu_req_valid,   // TPDU request valid
    input  wire [7:0]  tpdu_req_tag,     // TPDU request tag
    input  wire [15:0] tpdu_req_length,  // TPDU request length
    input  wire [7:0]  tpdu_req_data,    // TPDU request data
    input  wire        tpdu_req_start,   // TPDU request start
    input  wire        tpdu_req_end,     // TPDU request end
    
    // Control Interface
    input  wire        link_init,        // Initialize link layer
    input  wire [15:0] buffer_size,      // Negotiated buffer size
    output reg         link_ready,       // Link layer ready
    output reg         link_error,       // Link layer error
    output reg [7:0]   link_status,      // Link status register
    
    // Session Layer Interface
    output reg         session_open,     // Session opened
    output reg [15:0]  session_number,   // Session number
    input  wire        session_close_req // Session close request
);

// =============================================================================
// Parameters and Constants
// =============================================================================

// EN50221 Link Layer Tags
parameter TAG_RES_ID         = 8'h00;  // Resource ID
parameter TAG_PROFILE_ENQ    = 8'h01;  // Profile enquiry
parameter TAG_PROFILE        = 8'h02;  // Profile
parameter TAG_PROFILE_CHANGE = 8'h03;  // Profile change
parameter TAG_CREATE_TC      = 8'h82;  // Create transport connection
parameter TAG_CREATE_TC_REPLY = 8'h83; // Create TC reply
parameter TAG_DELETE_TC      = 8'h84;  // Delete transport connection
parameter TAG_DELETE_TC_REPLY = 8'h85; // Delete TC reply
parameter TAG_REQUEST_TC     = 8'h86;  // Request TC
parameter TAG_NEW_TC         = 8'h87;  // New TC
parameter TAG_TC_ERROR       = 8'h88;  // TC error
parameter TAG_DATA_LAST      = 8'hA0;  // Data last
parameter TAG_DATA_MORE      = 8'hA1;  // Data more

// Control Interface Register Addresses
parameter CTRL_IF_SIZE_LS    = 26'h000200;  // Buffer size LS
parameter CTRL_IF_SIZE_MS    = 26'h000201;  // Buffer size MS
parameter CTRL_IF_INFO_LEN   = 26'h000202;  // Info length
parameter CTRL_IF_INFO_ADDR  = 26'h000203;  // Info address
parameter CTRL_IF_CMD_REG    = 26'h000204;  // Command register
parameter CTRL_IF_STAT_REG   = 26'h000205;  // Status register
parameter CTRL_IF_SIZE_REG   = 26'h000206;  // Size register
parameter CTRL_IF_DATA_ADDR  = 26'h000600;  // Data buffer address

// Command/Status bits
parameter CMD_RESET          = 8'h01;  // Reset interface
parameter CMD_SIZE_NEG       = 8'h02;  // Size negotiation
parameter CMD_SW_RESET       = 8'h04;  // Software reset
parameter CMD_DATA_AVAIL     = 8'h80;  // Data available

parameter STAT_FREE          = 8'h01;  // Interface free
parameter STAT_DATA_AVAIL    = 8'h80;  // Data available

// State Machine States
localparam STATE_IDLE        = 4'h0;
localparam STATE_INIT        = 4'h1;
localparam STATE_SIZE_NEG    = 4'h2;
localparam STATE_WAIT_LINK   = 4'h3;
localparam STATE_CREATE_TC   = 4'h4;
localparam STATE_ACTIVE      = 4'h5;
localparam STATE_READ_TPDU   = 4'h6;
localparam STATE_WRITE_TPDU  = 4'h7;
localparam STATE_DELETE_TC   = 4'h8;
localparam STATE_ERROR       = 4'h9;

// =============================================================================
// Internal Signals
// =============================================================================

// State machine
reg [3:0]   current_state;
reg [3:0]   next_state;

// Memory access control
reg [25:0]  mem_addr_reg;
reg [15:0]  write_data_reg;
reg         read_pending;
reg         write_pending;

// Buffer management
reg [15:0]  write_ptr;
reg [15:0]  read_ptr;
reg [15:0]  data_count;
reg [15:0]  negotiated_size;

// TPDU processing
reg [7:0]   tpdu_buffer[0:2047];
reg [10:0]  tpdu_index;
reg [15:0]  tpdu_remaining;
reg         tpdu_in_progress;

// Transport connection
reg         tc_created;
reg [7:0]   tc_id;

// Timing
reg [7:0]   timeout_counter;
reg         timeout_flag;

// =============================================================================
// State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= STATE_IDLE;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    next_state = current_state;
    
    case (current_state)
        STATE_IDLE: begin
            if (link_init) begin
                next_state = STATE_INIT;
            end
        end
        
        STATE_INIT: begin
            next_state = STATE_SIZE_NEG;
        end
        
        STATE_SIZE_NEG: begin
            if (negotiated_size > 0) begin
                next_state = STATE_WAIT_LINK;
            end else if (timeout_flag) begin
                next_state = STATE_ERROR;
            end
        end
        
        STATE_WAIT_LINK: begin
            if (mem_ready) begin
                next_state = STATE_CREATE_TC;
            end
        end
        
        STATE_CREATE_TC: begin
            if (tc_created) begin
                next_state = STATE_ACTIVE;
            end else if (timeout_flag) begin
                next_state = STATE_ERROR;
            end
        end
        
        STATE_ACTIVE: begin
            if (session_close_req) begin
                next_state = STATE_DELETE_TC;
            end else if (tpdu_req_valid && tpdu_req_start) begin
                next_state = STATE_WRITE_TPDU;
            end else if (data_count > 0) begin
                next_state = STATE_READ_TPDU;
            end
        end
        
        STATE_READ_TPDU: begin
            if (tpdu_end) begin
                next_state = STATE_ACTIVE;
            end
        end
        
        STATE_WRITE_TPDU: begin
            if (tpdu_req_end && !write_pending) begin
                next_state = STATE_ACTIVE;
            end
        end
        
        STATE_DELETE_TC: begin
            if (!tc_created) begin
                next_state = STATE_IDLE;
            end
        end
        
        STATE_ERROR: begin
            if (!link_init) begin
                next_state = STATE_IDLE;
            end
        end
        
        default: begin
            next_state = STATE_IDLE;
        end
    endcase
end

// =============================================================================
// Memory Access Control
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_addr <= 26'h0;
        mem_data_out <= 16'h0;
        mem_read <= 1'b0;
        mem_write <= 1'b0;
        mem_attr <= 1'b0;
        read_pending <= 1'b0;
        write_pending <= 1'b0;
    end else begin
        // Default values
        mem_read <= 1'b0;
        mem_write <= 1'b0;
        
        // Handle pending operations
        if (read_pending && mem_ready) begin
            read_pending <= 1'b0;
        end
        if (write_pending && mem_ready) begin
            write_pending <= 1'b0;
        end
        
        // State-based memory operations
        case (current_state)
            STATE_SIZE_NEG: begin
                // Write buffer size to CAM
                if (!write_pending) begin
                    mem_attr <= 1'b1;  // Attribute memory
                    mem_addr <= CTRL_IF_SIZE_LS;
                    mem_data_out <= buffer_size;
                    mem_write <= 1'b1;
                    write_pending <= 1'b1;
                end
            end
            
            STATE_CREATE_TC: begin
                // Write create TC command
                if (!write_pending && !tc_created) begin
                    mem_attr <= 1'b0;  // Common memory
                    mem_addr <= CTRL_IF_DATA_ADDR;
                    mem_data_out <= {8'h00, TAG_CREATE_TC};
                    mem_write <= 1'b1;
                    write_pending <= 1'b1;
                end
            end
            
            STATE_READ_TPDU: begin
                // Read TPDU data from CAM
                if (!read_pending && tpdu_index < tpdu_remaining) begin
                    mem_attr <= 1'b0;
                    mem_addr <= CTRL_IF_DATA_ADDR + tpdu_index;
                    mem_read <= 1'b1;
                    read_pending <= 1'b1;
                end
            end
            
            STATE_WRITE_TPDU: begin
                // Write TPDU data to CAM
                if (!write_pending && tpdu_req_valid) begin
                    mem_attr <= 1'b0;
                    mem_addr <= CTRL_IF_DATA_ADDR + write_ptr;
                    mem_data_out <= {8'h00, tpdu_req_data};
                    mem_write <= 1'b1;
                    write_pending <= 1'b1;
                end
            end
        endcase
    end
end

// =============================================================================
// TPDU Processing
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tpdu_valid <= 1'b0;
        tpdu_tag <= 8'h00;
        tpdu_length <= 16'h0000;
        tpdu_data <= 8'h00;
        tpdu_start <= 1'b0;
        tpdu_end <= 1'b0;
        tpdu_index <= 11'h000;
        tpdu_remaining <= 16'h0000;
        tpdu_in_progress <= 1'b0;
    end else begin
        // Default values
        tpdu_valid <= 1'b0;
        tpdu_start <= 1'b0;
        tpdu_end <= 1'b0;
        
        case (current_state)
            STATE_READ_TPDU: begin
                if (mem_ready && read_pending) begin
                    if (!tpdu_in_progress) begin
                        // First byte - tag
                        tpdu_tag <= mem_data_in[7:0];
                        tpdu_start <= 1'b1;
                        tpdu_in_progress <= 1'b1;
                        tpdu_index <= tpdu_index + 1'b1;
                    end else if (tpdu_index == 11'h001) begin
                        // Length high byte
                        tpdu_length[15:8] <= mem_data_in[7:0];
                        tpdu_index <= tpdu_index + 1'b1;
                    end else if (tpdu_index == 11'h002) begin
                        // Length low byte
                        tpdu_length[7:0] <= mem_data_in[7:0];
                        tpdu_remaining <= {tpdu_length[15:8], mem_data_in[7:0]};
                        tpdu_index <= tpdu_index + 1'b1;
                    end else begin
                        // Data bytes
                        tpdu_valid <= 1'b0;
                        tpdu_data <= mem_data_in[7:0];
                        tpdu_index <= tpdu_index + 1'b1;
                        
                        if (tpdu_index >= tpdu_remaining + 16'd3) begin
                            tpdu_end <= 1'b1;
                            tpdu_in_progress <= 1'b0;
                            tpdu_index <= 11'h000;
                        end
                    end
                end
            end
            
            STATE_ACTIVE: begin
                tpdu_index <= 11'h000;
                tpdu_in_progress <= 1'b0;
            end
            
            default: begin
                tpdu_index <= 11'h000;
                tpdu_in_progress <= 1'b0;
            end
        endcase
    end
end

// =============================================================================
// Buffer Management
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_ptr <= 16'h0000;
        read_ptr <= 16'h0000;
        data_count <= 16'h0000;
        negotiated_size <= 16'h0000;
    end else begin
        case (current_state)
            STATE_SIZE_NEG: begin
                negotiated_size <= buffer_size;
            end
            
            STATE_WRITE_TPDU: begin
                if (mem_ready && write_pending) begin
                    write_ptr <= write_ptr + 1'b1;
                    data_count <= data_count + 1'b1;
                end
            end
            
            STATE_READ_TPDU: begin
                if (tpdu_end) begin
                    read_ptr <= read_ptr + tpdu_remaining + 16'd3;
                    data_count <= data_count - (tpdu_remaining + 16'd3);
                end
            end
            
            STATE_IDLE: begin
                write_ptr <= 16'h0000;
                read_ptr <= 16'h0000;
                data_count <= 16'h0000;
            end
        endcase
    end
end

// =============================================================================
// Transport Connection Management
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tc_created <= 1'b0;
        tc_id <= 8'h00;
        session_open <= 1'b0;
        session_number <= 16'h0000;
    end else begin
        case (current_state)
            STATE_CREATE_TC: begin
                if (mem_ready && write_pending) begin
                    tc_created <= 1'b1;
                    tc_id <= 8'h01;  // Default TC ID
                    session_open <= 1'b1;
                    session_number <= 16'h0001;
                end
            end
            
            STATE_DELETE_TC: begin
                tc_created <= 1'b0;
                session_open <= 1'b0;
            end
            
            STATE_IDLE: begin
                tc_created <= 1'b0;
                session_open <= 1'b0;
            end
        endcase
    end
end

// =============================================================================
// Status and Control
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        link_ready <= 1'b0;
        link_error <= 1'b0;
        link_status <= 8'h00;
        timeout_counter <= 8'h00;
        timeout_flag <= 1'b0;
    end else begin
        // Timeout management
        if (current_state == STATE_SIZE_NEG || 
            current_state == STATE_CREATE_TC) begin
            if (timeout_counter < 8'hFF) begin
                timeout_counter <= timeout_counter + 1'b1;
            end else begin
                timeout_flag <= 1'b1;
            end
        end else begin
            timeout_counter <= 8'h00;
            timeout_flag <= 1'b0;
        end
        
        // Status updates
        case (current_state)
            STATE_ACTIVE: begin
                link_ready <= 1'b1;
                link_error <= 1'b0;
                link_status <= {tc_created, session_open, 6'h00};
            end
            
            STATE_ERROR: begin
                link_ready <= 1'b0;
                link_error <= 1'b1;
                link_status <= 8'hFF;
            end
            
            default: begin
                link_ready <= 1'b0;
                link_error <= 1'b0;
                link_status <= {4'h0, current_state};
            end
        endcase
    end
end

endmodule