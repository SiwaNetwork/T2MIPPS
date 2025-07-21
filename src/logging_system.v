// =============================================================================
// Logging System for T2MI PPS Generator
// Система логирования для генератора PPS T2MI
// =============================================================================
// Description: Circular buffer logging system with severity levels and filtering
// Описание: Система логирования с кольцевым буфером, уровнями важности и фильтрацией
// Author: Implementation for T2MI PPS Generator
// Date: 2024
// =============================================================================

module logging_system #(
    parameter LOG_BUFFER_SIZE = 1024,        // Размер буфера логов (записей)
    parameter LOG_ENTRY_WIDTH = 128,         // Ширина одной записи лога (бит)
    parameter TIMESTAMP_WIDTH = 64,          // Ширина временной метки
    parameter MODULE_ID_WIDTH = 8,           // Ширина идентификатора модуля
    parameter EVENT_ID_WIDTH = 16,           // Ширина идентификатора события
    parameter DATA_WIDTH = 32                // Ширина данных события
)(
    // Clock and Reset / Тактирование и сброс
    input  wire                          clk,
    input  wire                          rst_n,
    
    // System timestamp / Системная временная метка
    input  wire [TIMESTAMP_WIDTH-1:0]    system_timestamp,
    
    // Log input interface / Интерфейс входа логов
    input  wire                          log_valid,
    input  wire [MODULE_ID_WIDTH-1:0]    module_id,       // ID модуля-источника
    input  wire [2:0]                    severity,        // 0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=CRITICAL
    input  wire [EVENT_ID_WIDTH-1:0]     event_id,        // ID события
    input  wire [DATA_WIDTH-1:0]         event_data,      // Данные события
    
    // Configuration / Конфигурация
    input  wire [2:0]                    min_severity,    // Минимальный уровень для записи
    input  wire                          logging_enable,  // Включение логирования
    input  wire [MODULE_ID_WIDTH-1:0]    filter_module,   // Фильтр по модулю (0 = все)
    input  wire                          clear_buffer,    // Очистка буфера
    
    // Read interface / Интерфейс чтения
    input  wire                          read_enable,
    input  wire [$clog2(LOG_BUFFER_SIZE)-1:0] read_address,
    output reg  [LOG_ENTRY_WIDTH-1:0]    read_data,
    output reg                           read_valid,
    
    // Status outputs / Выходы статуса
    output reg  [$clog2(LOG_BUFFER_SIZE)-1:0] write_pointer,    // Указатель записи
    output reg  [$clog2(LOG_BUFFER_SIZE)-1:0] entries_count,    // Количество записей
    output reg                           buffer_full,      // Буфер полон
    output reg                           buffer_overflow,  // Было переполнение
    output reg  [31:0]                   total_logs,       // Всего логов записано
    output reg  [31:0]                   dropped_logs,     // Логов отброшено
    
    // Statistics by severity / Статистика по уровням важности
    output reg  [31:0]                   debug_count,
    output reg  [31:0]                   info_count,
    output reg  [31:0]                   warning_count,
    output reg  [31:0]                   error_count,
    output reg  [31:0]                   critical_count
);

// =============================================================================
// Local parameters / Локальные параметры
// =============================================================================
localparam ADDR_WIDTH = $clog2(LOG_BUFFER_SIZE);

// Severity levels / Уровни важности
localparam [2:0] SEV_DEBUG    = 3'd0;
localparam [2:0] SEV_INFO     = 3'd1;
localparam [2:0] SEV_WARNING  = 3'd2;
localparam [2:0] SEV_ERROR    = 3'd3;
localparam [2:0] SEV_CRITICAL = 3'd4;

// =============================================================================
// Internal signals / Внутренние сигналы
// =============================================================================

// Log buffer memory / Память буфера логов
reg [LOG_ENTRY_WIDTH-1:0] log_buffer [0:LOG_BUFFER_SIZE-1];

// Write control / Управление записью
reg [ADDR_WIDTH-1:0] read_pointer;
reg write_enable;
reg [LOG_ENTRY_WIDTH-1:0] write_data;

// Filter logic / Логика фильтрации
reg log_accepted;

// =============================================================================
// Log entry format / Формат записи лога
// =============================================================================
// [127:64] - Timestamp (64 bits)
// [63:56]  - Module ID (8 bits)
// [55:53]  - Severity (3 bits)
// [52:37]  - Event ID (16 bits)
// [36:5]   - Event Data (32 bits)
// [4:0]    - Reserved (5 bits)

// =============================================================================
// Filter logic / Логика фильтрации
// =============================================================================
always @(*) begin
    log_accepted = 1'b0;
    
    if (logging_enable && log_valid) begin
        // Check severity filter / Проверка фильтра важности
        if (severity >= min_severity) begin
            // Check module filter / Проверка фильтра модуля
            if (filter_module == 0 || module_id == filter_module) begin
                log_accepted = 1'b1;
            end
        end
    end
end

// =============================================================================
// Write logic / Логика записи
// =============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || clear_buffer) begin
        write_pointer <= {ADDR_WIDTH{1'b0}};
        entries_count <= {ADDR_WIDTH{1'b0}};
        buffer_full <= 1'b0;
        buffer_overflow <= 1'b0;
        total_logs <= 32'd0;
        dropped_logs <= 32'd0;
        write_enable <= 1'b0;
        write_data <= {LOG_ENTRY_WIDTH{1'b0}};
    end else begin
        write_enable <= 1'b0;
        
        if (log_accepted) begin
            // Prepare log entry / Подготовка записи лога
            write_data <= {
                system_timestamp,                    // [127:64]
                module_id,                          // [63:56]
                severity,                           // [55:53]
                event_id,                           // [52:37]
                event_data,                         // [36:5]
                5'b00000                            // [4:0] Reserved
            };
            
            // Check if buffer is full / Проверка переполнения буфера
            if (buffer_full) begin
                dropped_logs <= dropped_logs + 1;
                buffer_overflow <= 1'b1;
            end else begin
                write_enable <= 1'b1;
                total_logs <= total_logs + 1;
                
                // Update write pointer / Обновление указателя записи
                if (write_pointer == LOG_BUFFER_SIZE - 1) begin
                    write_pointer <= {ADDR_WIDTH{1'b0}};
                end else begin
                    write_pointer <= write_pointer + 1;
                end
                
                // Update entries count / Обновление счетчика записей
                if (entries_count < LOG_BUFFER_SIZE) begin
                    entries_count <= entries_count + 1;
                    if (entries_count == LOG_BUFFER_SIZE - 1) begin
                        buffer_full <= 1'b1;
                    end
                end
            end
        end
    end
end

// =============================================================================
// Memory write / Запись в память
// =============================================================================
always @(posedge clk) begin
    if (write_enable) begin
        log_buffer[write_pointer] <= write_data;
    end
end

// =============================================================================
// Read logic / Логика чтения
// =============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_data <= {LOG_ENTRY_WIDTH{1'b0}};
        read_valid <= 1'b0;
        read_pointer <= {ADDR_WIDTH{1'b0}};
    end else begin
        if (read_enable && entries_count > 0) begin
            // Calculate actual read address in circular buffer
            if (buffer_full) begin
                // When full, oldest entry is at write_pointer
                read_pointer <= (write_pointer + read_address) % LOG_BUFFER_SIZE;
            end else begin
                // When not full, oldest entry is at 0
                read_pointer <= read_address;
            end
            
            read_data <= log_buffer[read_pointer];
            read_valid <= 1'b1;
        end else begin
            read_valid <= 1'b0;
        end
    end
end

// =============================================================================
// Statistics counters / Счетчики статистики
// =============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || clear_buffer) begin
        debug_count <= 32'd0;
        info_count <= 32'd0;
        warning_count <= 32'd0;
        error_count <= 32'd0;
        critical_count <= 32'd0;
    end else if (log_accepted) begin
        case (severity)
            SEV_DEBUG:    debug_count <= debug_count + 1;
            SEV_INFO:     info_count <= info_count + 1;
            SEV_WARNING:  warning_count <= warning_count + 1;
            SEV_ERROR:    error_count <= error_count + 1;
            SEV_CRITICAL: critical_count <= critical_count + 1;
            default:      ; // Do nothing
        endcase
    end
end

// =============================================================================
// Module IDs definition (for reference) / Определение ID модулей (для справки)
// =============================================================================
// 8'h01 - T2MI Packet Parser
// 8'h02 - Timestamp Extractor
// 8'h03 - PPS Generator
// 8'h04 - DPLL
// 8'h05 - Kalman Filter
// 8'h06 - SiT5503 Controller
// 8'h07 - Satellite Delay Compensation
// 8'h08 - System Controller
// 8'h09 - UART Interface
// 8'h0A - STM32 Interface
// 8'h0B - GNSS Interface
// 8'h0C - External PPS Interface

// =============================================================================
// Event IDs definition (for reference) / Определение ID событий (для справки)
// =============================================================================
// 16'h0001 - System Start
// 16'h0002 - System Reset
// 16'h0003 - Configuration Changed
// 16'h0010 - T2MI Sync Acquired
// 16'h0011 - T2MI Sync Lost
// 16'h0012 - T2MI Packet Received
// 16'h0013 - T2MI Packet Error
// 16'h0020 - Timestamp Extracted
// 16'h0021 - Timestamp Error
// 16'h0030 - PPS Generated
// 16'h0031 - PPS Skipped
// 16'h0040 - DPLL Locked
// 16'h0041 - DPLL Unlocked
// 16'h0042 - DPLL Holdover
// 16'h0050 - Kalman Converged
// 16'h0051 - Kalman Reset
// 16'h0060 - Temperature Warning
// 16'h0061 - Frequency Drift Warning
// 16'h0070 - GNSS Fix Acquired
// 16'h0071 - GNSS Fix Lost

endmodule