// =============================================================================
// T2-MI Packet Parser Module
// Модуль парсера пакетов T2-MI
// =============================================================================
// Description: Parses T2-MI stream and extracts individual packets
// Supports packet type identification and data extraction
// Описание: Разбирает поток T2-MI и извлекает отдельные пакеты
// Поддерживает идентификацию типа пакета и извлечение данных
// =============================================================================

module t2mi_packet_parser (
    input  wire        clk,
    input  wire        rst_n,
    
    // T2-MI input interface / Входной интерфейс T2-MI
    input  wire        t2mi_clk,        // Тактовая частота T2-MI
    input  wire        t2mi_valid,      // Флаг валидности данных
    input  wire [7:0]  t2mi_data,       // Байт данных T2-MI
    input  wire        t2mi_sync,       // Сигнал синхронизации
    
    // Packet output interface / Выходной интерфейс пакетов
    output reg         packet_valid,     // Флаг валидности пакета
    output reg [7:0]   packet_type,      // Тип пакета
    output reg [15:0]  packet_length,    // Длина пакета
    output reg [7:0]   packet_data,      // Данные пакета
    output reg         packet_start,     // Начало пакета
    output reg         packet_end,       // Конец пакета
    
    // Status outputs / Выходы статуса
    output reg         sync_locked,      // Синхронизация захвачена
    output reg         parser_error      // Ошибка парсера
);

// =============================================================================
// Parameters and Constants / Параметры и константы
// =============================================================================

// T2-MI packet header structure / Структура заголовка пакета T2-MI
parameter SYNC_BYTE         = 8'h47;    // T2-MI sync byte / Байт синхронизации T2-MI
parameter MIN_PACKET_LENGTH = 16'd4;    // Minimum packet length / Минимальная длина пакета
parameter MAX_PACKET_LENGTH = 16'd65535; // Maximum packet length / Максимальная длина пакета

// Parser state machine states / Состояния конечного автомата парсера
localparam STATE_SYNC       = 3'b000;   // Поиск синхронизации
localparam STATE_TYPE       = 3'b001;   // Чтение типа пакета
localparam STATE_LENGTH_H   = 3'b010;   // Чтение старшего байта длины
localparam STATE_LENGTH_L   = 3'b011;   // Чтение младшего байта длины
localparam STATE_DATA       = 3'b100;   // Чтение данных пакета
localparam STATE_ERROR      = 3'b101;   // Состояние ошибки

// =============================================================================
// Internal Signals / Внутренние сигналы
// =============================================================================

reg [2:0]   parser_state;        // Текущее состояние парсера
reg [2:0]   next_state;          // Следующее состояние
reg [15:0]  byte_counter;        // Счетчик байтов в пакете
reg [15:0]  packet_length_reg;   // Регистр длины пакета
reg [7:0]   packet_type_reg;     // Регистр типа пакета
reg [7:0]   data_buffer;         // Буфер данных
reg         sync_found;          // Флаг обнаружения синхронизации
reg [3:0]   sync_counter;        // Счетчик синхронизации
reg         length_valid;        // Флаг валидности длины

// Input synchronization registers / Регистры синхронизации входов
reg [7:0]   t2mi_data_sync;     // Синхронизированные данные
reg         t2mi_valid_sync;    // Синхронизированный флаг валидности
reg         t2mi_sync_sync;     // Синхронизированный сигнал синхронизации

// =============================================================================
// Input Synchronization / Синхронизация входов
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        t2mi_data_sync  <= 8'h00;
        t2mi_valid_sync <= 1'b0;
        t2mi_sync_sync  <= 1'b0;
    end else begin
        t2mi_data_sync  <= t2mi_data;
        t2mi_valid_sync <= t2mi_valid;
        t2mi_sync_sync  <= t2mi_sync;
    end
end

// =============================================================================
// Sync Detection Logic / Логика обнаружения синхронизации
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_found <= 1'b0;
        sync_counter <= 4'h0;
        sync_locked <= 1'b0;
    end else begin
        if (t2mi_valid_sync && (t2mi_data_sync == SYNC_BYTE)) begin
            // Обнаружен байт синхронизации
            if (sync_counter < 4'hF) begin
                sync_counter <= sync_counter + 1'b1;
            end
            sync_found <= 1'b1;
        end else begin
            sync_found <= 1'b0;
            if (sync_counter > 4'h0) begin
                sync_counter <= sync_counter - 1'b1;
            end
        end
        
        // Lock when we see consistent sync patterns
        sync_locked <= (sync_counter >= 4'h8);
    end
end

// =============================================================================
// Packet Length Validation
// =============================================================================

always @(*) begin
    length_valid = (packet_length_reg >= MIN_PACKET_LENGTH) && 
                   (packet_length_reg <= MAX_PACKET_LENGTH);
end

// =============================================================================
// Parser State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        parser_state <= STATE_SYNC;
    end else begin
        parser_state <= next_state;
    end
end

always @(*) begin
    next_state = parser_state;
    
    case (parser_state)
        STATE_SYNC: begin
            if (t2mi_valid_sync && sync_found && sync_locked) begin
                next_state = STATE_TYPE;
            end
        end
        
        STATE_TYPE: begin
            if (t2mi_valid_sync) begin
                next_state = STATE_LENGTH_H;
            end
        end
        
        STATE_LENGTH_H: begin
            if (t2mi_valid_sync) begin
                next_state = STATE_LENGTH_L;
            end
        end
        
        STATE_LENGTH_L: begin
            if (t2mi_valid_sync) begin
                if (length_valid) begin
                    next_state = STATE_DATA;
                end else begin
                    next_state = STATE_ERROR;
                end
            end
        end
        
        STATE_DATA: begin
            if (t2mi_valid_sync) begin
                if (byte_counter >= packet_length_reg - 1) begin
                    next_state = STATE_SYNC;
                end
            end
        end
        
        STATE_ERROR: begin
            // Stay in error state until sync is re-established
            if (sync_found && sync_locked) begin
                next_state = STATE_SYNC;
            end
        end
        
        default: begin
            next_state = STATE_SYNC;
        end
    endcase
end

// =============================================================================
// Parser Control Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        packet_valid    <= 1'b0;
        packet_type     <= 8'h00;
        packet_length   <= 16'h0000;
        packet_data     <= 8'h00;
        packet_start    <= 1'b0;
        packet_end      <= 1'b0;
        parser_error    <= 1'b0;
        byte_counter    <= 16'h0000;
        packet_length_reg <= 16'h0000;
        packet_type_reg <= 8'h00;
        data_buffer     <= 8'h00;
    end else begin
        // Default values
        packet_valid <= 1'b0;
        packet_start <= 1'b0;
        packet_end   <= 1'b0;
        parser_error <= 1'b0;
        
        case (parser_state)
            STATE_SYNC: begin
                byte_counter <= 16'h0000;
                if (next_state == STATE_TYPE) begin
                    // Sync found, prepare for packet
                    packet_start <= 1'b1;
                end
            end
            
            STATE_TYPE: begin
                if (t2mi_valid_sync) begin
                    packet_type_reg <= t2mi_data_sync;
                    packet_type <= t2mi_data_sync;
                end
            end
            
            STATE_LENGTH_H: begin
                if (t2mi_valid_sync) begin
                    packet_length_reg[15:8] <= t2mi_data_sync;
                end
            end
            
            STATE_LENGTH_L: begin
                if (t2mi_valid_sync) begin
                    packet_length_reg[7:0] <= t2mi_data_sync;
                    packet_length <= {packet_length_reg[15:8], t2mi_data_sync};
                end
            end
            
            STATE_DATA: begin
                if (t2mi_valid_sync) begin
                    packet_valid <= 1'b1;
                    packet_data <= t2mi_data_sync;
                    byte_counter <= byte_counter + 1'b1;
                    
                    if (byte_counter >= packet_length_reg - 1) begin
                        packet_end <= 1'b1;
                    end
                end
            end
            
            STATE_ERROR: begin
                parser_error <= 1'b1;
                byte_counter <= 16'h0000;
            end
            
            default: begin
                // Reset all outputs
                byte_counter <= 16'h0000;
            end
        endcase
    end
end

endmodule

