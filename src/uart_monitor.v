// =============================================================================
// UART Monitor for Allan Deviation and MTIE
// UART монитор для Allan deviation и MTIE
// =============================================================================
// Description: Transmits system statistics via UART for monitoring
// Описание: Передает системную статистику через UART для мониторинга
// Author: Implementation for T2MI PPS Generator
// Date: 2024
// =============================================================================

module uart_monitor #(
    parameter CLK_FREQ = 100_000_000,    // Частота тактирования
    parameter BAUD_RATE = 115200,        // Скорость UART
    parameter DATA_BITS = 8,             // Биты данных
    parameter STOP_BITS = 1              // Стоп-биты
)(
    // Clock and Reset / Тактирование и сброс
    input  wire        clk,
    input  wire        rst_n,
    
    // UART interface / Интерфейс UART
    input  wire        uart_rx,          // UART receive
    output reg         uart_tx,          // UART transmit
    
    // Statistics inputs / Входы статистики
    input  wire [31:0] allan_deviation,  // Allan deviation value
    input  wire [31:0] mtie,            // MTIE value
    input  wire [31:0] phase_error,     // Current phase error
    input  wire [31:0] frequency_error, // Current frequency error
    input  wire        dpll_locked,     // DPLL lock status
    input  wire [15:0] lock_quality,    // Lock quality (0-65535)
    input  wire [31:0] temperature,     // Temperature reading
    input  wire [31:0] uptime_seconds,  // System uptime
    
    // Control / Управление
    input  wire        enable,          // Enable monitoring
    input  wire [15:0] tx_interval,     // Transmission interval (ms)
    output reg         tx_busy,         // Transmitter busy
    output reg  [31:0] packets_sent     // Number of packets sent
);

// =============================================================================
// Constants / Константы
// =============================================================================
localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
localparam PACKET_SIZE = 32;  // Bytes per packet

// Packet format (32 bytes):
// [0-1]   - Header (0xAA55)
// [2]     - Packet type (0x01 = statistics)
// [3]     - Packet length (28)
// [4-7]   - Allan deviation
// [8-11]  - MTIE
// [12-15] - Phase error
// [16-19] - Frequency error
// [20]    - Status byte (bit 0 = DPLL locked)
// [21-22] - Lock quality
// [23-26] - Temperature
// [27-30] - Uptime
// [31]    - Checksum

// =============================================================================
// Internal signals / Внутренние сигналы
// =============================================================================

// UART transmitter states
localparam [2:0] TX_IDLE       = 3'd0;
localparam [2:0] TX_START_BIT  = 3'd1;
localparam [2:0] TX_DATA_BITS  = 3'd2;
localparam [2:0] TX_STOP_BIT   = 3'd3;

reg [2:0]  tx_state;
reg [15:0] tx_clk_count;
reg [2:0]  tx_bit_index;
reg [7:0]  tx_byte;
reg        tx_done;

// Packet buffer
reg [7:0]  tx_buffer [0:PACKET_SIZE-1];
reg [5:0]  tx_index;
reg        tx_start;

// Timing control
reg [31:0] interval_counter;
reg        send_packet;

// Checksum calculation
reg [7:0]  checksum;

// =============================================================================
// Interval timer / Таймер интервала
// =============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        interval_counter <= 32'd0;
        send_packet <= 1'b0;
    end else if (enable) begin
        if (interval_counter >= (tx_interval * (CLK_FREQ / 1000))) begin
            interval_counter <= 32'd0;
            send_packet <= 1'b1;
        end else begin
            interval_counter <= interval_counter + 1;
            send_packet <= 1'b0;
        end
    end else begin
        interval_counter <= 32'd0;
        send_packet <= 1'b0;
    end
end

// =============================================================================
// Packet preparation / Подготовка пакета
// =============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_index <= 6'd0;
        tx_start <= 1'b0;
        packets_sent <= 32'd0;
        checksum <= 8'd0;
    end else if (enable && send_packet && !tx_busy) begin
        // Prepare packet
        tx_buffer[0] <= 8'hAA;  // Header byte 1
        tx_buffer[1] <= 8'h55;  // Header byte 2
        tx_buffer[2] <= 8'h01;  // Packet type: statistics
        tx_buffer[3] <= 8'd28;  // Payload length
        
        // Allan deviation
        tx_buffer[4] <= allan_deviation[31:24];
        tx_buffer[5] <= allan_deviation[23:16];
        tx_buffer[6] <= allan_deviation[15:8];
        tx_buffer[7] <= allan_deviation[7:0];
        
        // MTIE
        tx_buffer[8] <= mtie[31:24];
        tx_buffer[9] <= mtie[23:16];
        tx_buffer[10] <= mtie[15:8];
        tx_buffer[11] <= mtie[7:0];
        
        // Phase error
        tx_buffer[12] <= phase_error[31:24];
        tx_buffer[13] <= phase_error[23:16];
        tx_buffer[14] <= phase_error[15:8];
        tx_buffer[15] <= phase_error[7:0];
        
        // Frequency error
        tx_buffer[16] <= frequency_error[31:24];
        tx_buffer[17] <= frequency_error[23:16];
        tx_buffer[18] <= frequency_error[15:8];
        tx_buffer[19] <= frequency_error[7:0];
        
        // Status byte
        tx_buffer[20] <= {7'b0, dpll_locked};
        
        // Lock quality
        tx_buffer[21] <= lock_quality[15:8];
        tx_buffer[22] <= lock_quality[7:0];
        
        // Temperature
        tx_buffer[23] <= temperature[31:24];
        tx_buffer[24] <= temperature[23:16];
        tx_buffer[25] <= temperature[15:8];
        tx_buffer[26] <= temperature[7:0];
        
        // Uptime
        tx_buffer[27] <= uptime_seconds[31:24];
        tx_buffer[28] <= uptime_seconds[23:16];
        tx_buffer[29] <= uptime_seconds[15:8];
        tx_buffer[30] <= uptime_seconds[7:0];
        
        // Calculate checksum
        checksum <= 8'd0;
        tx_index <= 6'd0;
        tx_start <= 1'b1;
        packets_sent <= packets_sent + 1;
    end else if (tx_start && tx_done) begin
        if (tx_index < PACKET_SIZE - 1) begin
            // Continue sending
            tx_index <= tx_index + 1;
            checksum <= checksum + tx_buffer[tx_index];
        end else begin
            // Packet complete
            tx_start <= 1'b0;
            tx_index <= 6'd0;
        end
    end
end

// Set checksum in last byte
always @(posedge clk) begin
    if (tx_index == PACKET_SIZE - 2) begin
        tx_buffer[31] <= ~checksum + 1;  // Two's complement checksum
    end
end

// =============================================================================
// UART Transmitter / UART передатчик
// =============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_state <= TX_IDLE;
        tx_clk_count <= 16'd0;
        tx_bit_index <= 3'd0;
        tx_byte <= 8'd0;
        tx_done <= 1'b0;
        uart_tx <= 1'b1;  // Idle high
        tx_busy <= 1'b0;
    end else begin
        tx_done <= 1'b0;
        
        case (tx_state)
            TX_IDLE: begin
                uart_tx <= 1'b1;  // Idle high
                tx_clk_count <= 16'd0;
                tx_bit_index <= 3'd0;
                
                if (tx_start && tx_index < PACKET_SIZE) begin
                    tx_byte <= tx_buffer[tx_index];
                    tx_state <= TX_START_BIT;
                    tx_busy <= 1'b1;
                end else begin
                    tx_busy <= 1'b0;
                end
            end
            
            TX_START_BIT: begin
                uart_tx <= 1'b0;  // Start bit
                
                if (tx_clk_count < CLKS_PER_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_clk_count <= 16'd0;
                    tx_state <= TX_DATA_BITS;
                end
            end
            
            TX_DATA_BITS: begin
                uart_tx <= tx_byte[tx_bit_index];
                
                if (tx_clk_count < CLKS_PER_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_clk_count <= 16'd0;
                    
                    if (tx_bit_index < DATA_BITS - 1) begin
                        tx_bit_index <= tx_bit_index + 1;
                    end else begin
                        tx_bit_index <= 3'd0;
                        tx_state <= TX_STOP_BIT;
                    end
                end
            end
            
            TX_STOP_BIT: begin
                uart_tx <= 1'b1;  // Stop bit
                
                if (tx_clk_count < CLKS_PER_BIT - 1) begin
                    tx_clk_count <= tx_clk_count + 1;
                end else begin
                    tx_clk_count <= 16'd0;
                    tx_state <= TX_IDLE;
                    tx_done <= 1'b1;
                end
            end
            
            default: begin
                tx_state <= TX_IDLE;
            end
        endcase
    end
end

endmodule