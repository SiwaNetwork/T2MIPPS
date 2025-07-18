// =============================================================================
// UART Monitor Module for STM32
// =============================================================================
// Description: Real-time monitoring and diagnostics via UART
// =============================================================================

module uart_monitor #(
    parameter UART_BAUD = 921600,
    parameter CLK_FREQ = 100_000_000
)(
    input  wire        clk,
    input  wire        rst_n,
    
    // UART
    input  wire        uart_rx,
    output wire        uart_tx,
    
    // Status inputs
    input  wire        sync_locked,
    input  wire        dpll_locked,
    input  wire [39:0] current_seconds,
    input  wire [31:0] current_subseconds,
    
    // DPLL diagnostics
    input  wire signed [47:0] phase_error,
    input  wire signed [47:0] frequency_error,
    input  wire [3:0]  dpll_state,
    input  wire [31:0] allan_deviation,
    input  wire [31:0] mtie,
    input  wire [15:0] lock_quality,
    
    // PID terms
    input  wire signed [47:0] p_term,
    input  wire signed [47:0] i_term,
    input  wire signed [47:0] d_term,
    
    // Statistics
    input  wire [31:0] pps_count,
    input  wire [31:0] error_count,
    
    // Configuration outputs
    output reg  [31:0] pid_kp,
    output reg  [31:0] pid_ki,
    output reg  [31:0] pid_kd,
    output reg         force_resync
);

// UART clock divider
localparam UART_DIV = CLK_FREQ / UART_BAUD;

// Protocol commands
localparam CMD_GET_STATUS = 8'h01;
localparam CMD_GET_DPLL   = 8'h02;
localparam CMD_GET_PID    = 8'h03;
localparam CMD_GET_STATS  = 8'h04;
localparam CMD_SET_PID    = 8'h10;
localparam CMD_RESYNC     = 8'h20;

// Internal signals
reg [7:0] rx_byte;
reg       rx_valid;
reg [7:0] tx_byte;
reg       tx_start;
reg       tx_busy;

// Command processing
reg [7:0] cmd;
reg       cmd_valid;

// TX buffer
reg [7:0] tx_buffer[0:63];
reg [5:0] tx_len;
reg [5:0] tx_idx;

// UART RX
reg [15:0] rx_div_cnt;
reg [3:0]  rx_bit_cnt;
reg [2:0]  rx_state;
reg        rx_sync;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_div_cnt <= 16'd0;
        rx_bit_cnt <= 4'd0;
        rx_state <= 3'd0;
        rx_byte <= 8'd0;
        rx_valid <= 1'b0;
        rx_sync <= 1'b1;
    end else begin
        rx_sync <= uart_rx;
        rx_valid <= 1'b0;
        
        case (rx_state)
            3'd0: begin // IDLE
                if (!rx_sync) begin
                    rx_state <= 3'd1;
                    rx_div_cnt <= UART_DIV/2;
                end
            end
            
            3'd1: begin // START
                if (rx_div_cnt == 0) begin
                    rx_state <= 3'd2;
                    rx_div_cnt <= UART_DIV;
                    rx_bit_cnt <= 4'd0;
                end else begin
                    rx_div_cnt <= rx_div_cnt - 1;
                end
            end
            
            3'd2: begin // DATA
                if (rx_div_cnt == 0) begin
                    rx_byte[rx_bit_cnt] <= rx_sync;
                    rx_div_cnt <= UART_DIV;
                    if (rx_bit_cnt == 7) begin
                        rx_state <= 3'd3;
                    end else begin
                        rx_bit_cnt <= rx_bit_cnt + 1;
                    end
                end else begin
                    rx_div_cnt <= rx_div_cnt - 1;
                end
            end
            
            3'd3: begin // STOP
                if (rx_div_cnt == 0) begin
                    rx_valid <= 1'b1;
                    rx_state <= 3'd0;
                end else begin
                    rx_div_cnt <= rx_div_cnt - 1;
                end
            end
        endcase
    end
end

// UART TX
reg [15:0] tx_div_cnt;
reg [3:0]  tx_bit_cnt;
reg [2:0]  tx_state;
reg [7:0]  tx_data;

assign uart_tx = (tx_state == 3'd0) ? 1'b1 :
                 (tx_state == 3'd1) ? 1'b0 :
                 (tx_state == 3'd2) ? tx_data[tx_bit_cnt] : 1'b1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_div_cnt <= 16'd0;
        tx_bit_cnt <= 4'd0;
        tx_state <= 3'd0;
        tx_data <= 8'd0;
        tx_busy <= 1'b0;
    end else begin
        case (tx_state)
            3'd0: begin // IDLE
                if (tx_start) begin
                    tx_data <= tx_byte;
                    tx_state <= 3'd1;
                    tx_div_cnt <= UART_DIV;
                    tx_busy <= 1'b1;
                end else begin
                    tx_busy <= 1'b0;
                end
            end
            
            3'd1: begin // START
                if (tx_div_cnt == 0) begin
                    tx_state <= 3'd2;
                    tx_div_cnt <= UART_DIV;
                    tx_bit_cnt <= 4'd0;
                end else begin
                    tx_div_cnt <= tx_div_cnt - 1;
                end
            end
            
            3'd2: begin // DATA
                if (tx_div_cnt == 0) begin
                    tx_div_cnt <= UART_DIV;
                    if (tx_bit_cnt == 7) begin
                        tx_state <= 3'd3;
                    end else begin
                        tx_bit_cnt <= tx_bit_cnt + 1;
                    end
                end else begin
                    tx_div_cnt <= tx_div_cnt - 1;
                end
            end
            
            3'd3: begin // STOP
                if (tx_div_cnt == 0) begin
                    tx_state <= 3'd0;
                    tx_busy <= 1'b0;
                end else begin
                    tx_div_cnt <= tx_div_cnt - 1;
                end
            end
        endcase
    end
end

// Command processing
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cmd <= 8'd0;
        cmd_valid <= 1'b0;
        pid_kp <= 32'h00000064;
        pid_ki <= 32'h0000000A;
        pid_kd <= 32'h00000005;
        force_resync <= 1'b0;
    end else begin
        cmd_valid <= 1'b0;
        force_resync <= 1'b0;
        
        if (rx_valid) begin
            cmd <= rx_byte;
            cmd_valid <= 1'b1;
            
            // Handle immediate commands
            if (rx_byte == CMD_RESYNC) begin
                force_resync <= 1'b1;
            end
        end
    end
end

// Response generation
integer i;
reg [31:0] send_timer;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_len <= 6'd0;
        tx_idx <= 6'd0;
        tx_start <= 1'b0;
        send_timer <= 32'd0;
        for (i = 0; i < 64; i = i + 1) begin
            tx_buffer[i] <= 8'd0;
        end
    end else begin
        tx_start <= 1'b0;
        send_timer <= send_timer + 1;
        
        // Auto-send status every 100ms
        if (send_timer >= CLK_FREQ/10) begin
            send_timer <= 32'd0;
            
            // Build status packet
            tx_buffer[0] <= 8'hAA; // Header
            tx_buffer[1] <= CMD_GET_STATUS;
            tx_buffer[2] <= {5'd0, sync_locked, dpll_locked, 1'b0};
            tx_buffer[3] <= dpll_state;
            tx_buffer[4] <= lock_quality[15:8];
            tx_buffer[5] <= lock_quality[7:0];
            
            // Phase error (simplified)
            tx_buffer[6] <= phase_error[31:24];
            tx_buffer[7] <= phase_error[23:16];
            tx_buffer[8] <= phase_error[15:8];
            tx_buffer[9] <= phase_error[7:0];
            
            // Allan deviation
            tx_buffer[10] <= allan_deviation[31:24];
            tx_buffer[11] <= allan_deviation[23:16];
            tx_buffer[12] <= allan_deviation[15:8];
            tx_buffer[13] <= allan_deviation[7:0];
            
            // MTIE
            tx_buffer[14] <= mtie[31:24];
            tx_buffer[15] <= mtie[23:16];
            tx_buffer[16] <= mtie[15:8];
            tx_buffer[17] <= mtie[7:0];
            
            tx_buffer[18] <= 8'h55; // Footer
            
            tx_len <= 6'd19;
            tx_idx <= 6'd0;
        end
        
        // Handle command responses
        if (cmd_valid) begin
            case (cmd)
                CMD_GET_PID: begin
                    tx_buffer[0] <= 8'hAA;
                    tx_buffer[1] <= CMD_GET_PID;
                    tx_buffer[2] <= p_term[31:24];
                    tx_buffer[3] <= p_term[23:16];
                    tx_buffer[4] <= p_term[15:8];
                    tx_buffer[5] <= p_term[7:0];
                    tx_buffer[6] <= i_term[31:24];
                    tx_buffer[7] <= i_term[23:16];
                    tx_buffer[8] <= i_term[15:8];
                    tx_buffer[9] <= i_term[7:0];
                    tx_buffer[10] <= d_term[31:24];
                    tx_buffer[11] <= d_term[23:16];
                    tx_buffer[12] <= d_term[15:8];
                    tx_buffer[13] <= d_term[7:0];
                    tx_buffer[14] <= 8'h55;
                    tx_len <= 6'd15;
                    tx_idx <= 6'd0;
                end
                
                CMD_GET_STATS: begin
                    tx_buffer[0] <= 8'hAA;
                    tx_buffer[1] <= CMD_GET_STATS;
                    tx_buffer[2] <= pps_count[31:24];
                    tx_buffer[3] <= pps_count[23:16];
                    tx_buffer[4] <= pps_count[15:8];
                    tx_buffer[5] <= pps_count[7:0];
                    tx_buffer[6] <= error_count[31:24];
                    tx_buffer[7] <= error_count[23:16];
                    tx_buffer[8] <= error_count[15:8];
                    tx_buffer[9] <= error_count[7:0];
                    tx_buffer[10] <= 8'h55;
                    tx_len <= 6'd11;
                    tx_idx <= 6'd0;
                end
            endcase
        end
        
        // Send buffered data
        if (tx_len > 0 && !tx_busy && !tx_start) begin
            if (tx_idx < tx_len) begin
                tx_byte <= tx_buffer[tx_idx];
                tx_start <= 1'b1;
                tx_idx <= tx_idx + 1;
            end else begin
                tx_len <= 6'd0;
            end
        end
    end
end

endmodule
