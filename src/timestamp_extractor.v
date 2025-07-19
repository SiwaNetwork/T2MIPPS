// =============================================================================
// Timestamp Extractor Module
// Модуль извлечения временных меток
// =============================================================================
// Description: Extracts timestamp information from T2-MI packets type 0x20
// Decodes DVB-T2 timestamp structure according to DVB standard
// Описание: Извлекает информацию о временных метках из пакетов T2-MI типа 0x20
// Декодирует структуру временных меток DVB-T2 согласно стандарту DVB
// =============================================================================

module timestamp_extractor (
    input  wire        clk,
    input  wire        rst_n,
    
    // Packet input interface / Входной интерфейс пакетов
    input  wire        packet_valid,     // Флаг валидности пакета
    input  wire [7:0]  packet_type,      // Тип пакета
    input  wire [7:0]  packet_data,      // Данные пакета
    input  wire        packet_start,     // Начало пакета
    input  wire        packet_end,       // Конец пакета
    
    // Timestamp output interface / Выходной интерфейс временных меток
    output reg         timestamp_valid,   // Флаг валидности временной метки
    output reg [39:0]  seconds_since_2000,// Секунды с 1 января 2000 года
    output reg [31:0]  subseconds,       // Доли секунды (1/2^32 секунды)
    output reg [12:0]  utc_offset,       // Смещение UTC в секундах
    output reg [3:0]   bandwidth_code,   // Код полосы пропускания
    output reg         timestamp_ready,  // Временная метка готова
    
    // Status output / Выход статуса
    output reg         extractor_error   // Ошибка экстрактора
);

// =============================================================================
// Parameters and Constants / Параметры и константы
// =============================================================================

// T2-MI packet types / Типы пакетов T2-MI
parameter TIMESTAMP_PACKET_TYPE = 8'h20; // Тип пакета с временной меткой

// Timestamp packet structure (in bytes) / Структура пакета временной метки (в байтах)
parameter TIMESTAMP_PACKET_SIZE = 8'd12;  // 12 bytes total / Всего 12 байт

// Extraction state machine / Состояния конечного автомата извлечения
localparam STATE_IDLE       = 3'b000;   // Ожидание
localparam STATE_HEADER     = 3'b001;   // Обработка заголовка
localparam STATE_SECONDS    = 3'b010;   // Извлечение секунд
localparam STATE_SUBSEC     = 3'b011;   // Извлечение долей секунды
localparam STATE_COMPLETE   = 3'b100;   // Завершение
localparam STATE_ERROR      = 3'b101;   // Ошибка

// =============================================================================
// Internal Signals / Внутренние сигналы
// =============================================================================

reg [2:0]   extract_state;          // Текущее состояние экстрактора
reg [2:0]   next_extract_state;     // Следующее состояние
reg [3:0]   byte_index;             // Индекс текущего байта
reg [7:0]   timestamp_buffer [0:11]; // 12-byte buffer / 12-байтный буфер
reg         packet_active;          // Пакет активен
reg [3:0]   rfu_field;             // Зарезервированное поле
reg [3:0]   bw_field;              // Поле полосы пропускания
reg [12:0]  utco_field;            // Поле смещения UTC
reg [39:0]  seconds_field;         // Поле секунд
reg [31:0]  subsec_field;          // Поле долей секунды
reg         header_valid;          // Заголовок валиден
reg         data_complete;         // Данные полностью получены

// Loop variable for synthesis / Переменная цикла для синтеза
integer     i;

// =============================================================================
// Packet Detection and Buffer Management / Обнаружение пакетов и управление буфером
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        packet_active <= 1'b0;
        byte_index <= 4'h0;
        data_complete <= 1'b0;
        // Initialize buffer / Инициализация буфера
        for (i = 0; i < 12; i = i + 1) begin
            timestamp_buffer[i] <= 8'h00;
        end
    end else begin
        if (packet_start && (packet_type == TIMESTAMP_PACKET_TYPE)) begin
            // Начало пакета с временной меткой
            packet_active <= 1'b1;
            byte_index <= 4'h0;
            data_complete <= 1'b0;
        end else if (packet_end) begin
            packet_active <= 1'b0;
            if (packet_active && (byte_index == TIMESTAMP_PACKET_SIZE)) begin
                // Пакет полностью получен
                data_complete <= 1'b1;
            end
        end else if (packet_active && packet_valid) begin
            if (byte_index < TIMESTAMP_PACKET_SIZE) begin
                // Сохранение байта в буфер
                timestamp_buffer[byte_index] <= packet_data;
                byte_index <= byte_index + 1'b1;
            end
        end else begin
            data_complete <= 1'b0;
        end
    end
end

// =============================================================================
// Timestamp Field Extraction / Извлечение полей временной метки
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
        // Extract header fields from first byte / Извлечение полей заголовка из первого байта
        rfu_field <= timestamp_buffer[0][7:4];
        bw_field <= timestamp_buffer[0][3:0];
        
        // Validate header (rfu should be 0) / Валидация заголовка (rfu должно быть 0)
        header_valid <= (timestamp_buffer[0][7:4] == 4'h0);
        
        // Extract UTC offset (13 bits across bytes 1-2) / Извлечение смещения UTC (13 бит в байтах 1-2)
        utco_field <= {timestamp_buffer[1][4:0], timestamp_buffer[2]};
        
        // Extract seconds since 2000 (40 bits across bytes 3-7) / Извлечение секунд с 2000 (40 бит в байтах 3-7)
        seconds_field <= {
            timestamp_buffer[3],
            timestamp_buffer[4],
            timestamp_buffer[5],
            timestamp_buffer[6],
            timestamp_buffer[7]
        };
        
        // Extract subseconds (32 bits across bytes 8-11) / Извлечение долей секунды (32 бит в байтах 8-11)
        subsec_field <= {
            timestamp_buffer[8],
            timestamp_buffer[9],
            timestamp_buffer[10],
            timestamp_buffer[11]
        };
    end
end

// =============================================================================
// Extraction State Machine / Состояние конечного автомата извлечения
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
            // Validate seconds field (basic range check) / Валидация поля секунд (базовая проверка диапазона)
            if (seconds_field < 40'hFFFFFFFFFF) begin  // Max reasonable value / Максимальное разумное значение
                next_extract_state = STATE_SUBSEC;
            end else begin
                next_extract_state = STATE_ERROR;
            end
        end
        
        STATE_SUBSEC: begin
            // Subseconds validation could be added here / Дополнительная валидация долей секунды может быть добавлена здесь
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
// Output Generation / Генерация выходных данных
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
        // Default values / Значения по умолчанию
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
                // Keep previous values / Сохраняем предыдущие значения
            end
        endcase
    end
end

// =============================================================================
// Debug and Monitoring / Отладка и мониторинг
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

