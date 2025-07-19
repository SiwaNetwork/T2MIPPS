// =============================================================================
// PPS Generator Module
// Модуль генератора PPS
// =============================================================================
// Description: Generates precise 1 pulse per second (PPS) signal based on
// extracted timestamp information from T2-MI stream
// Описание: Генерирует точный сигнал 1 импульс в секунду (PPS) на основе
// извлеченной информации о временных метках из потока T2-MI
// =============================================================================

module pps_generator (
    input  wire        clk,              // 100 MHz system clock / Системная тактовая частота 100 МГц
    input  wire        rst_n,
    
    // Timestamp input interface / Входной интерфейс временных меток
    input  wire        timestamp_valid,   // Флаг валидности временной метки
    input  wire [39:0] seconds_since_2000,// Секунды с 2000 года
    input  wire [31:0] subseconds,       // Доли секунды
    input  wire        timestamp_ready,   // Временная метка готова
    
    // PPS output interface / Выходной интерфейс PPS
    output reg         pps_pulse,        // Импульс PPS
    output reg [31:0]  pps_counter,      // Счетчик PPS
    
    // Status output / Выход статуса
    output reg         pps_error         // Ошибка PPS
);

// =============================================================================
// Parameters and Constants / Параметры и константы
// =============================================================================

// Clock parameters / Параметры тактирования
parameter CLK_FREQ_HZ = 100_000_000;    // 100 MHz system clock / Системная частота 100 МГц
parameter PPS_PULSE_WIDTH = 1000;       // PPS pulse width in clock cycles (10 us) / Ширина импульса PPS в тактах (10 мкс)

// Subseconds resolution / Разрешение долей секунды
parameter SUBSEC_RESOLUTION = 32'hFFFFFFFF;  // 32-bit subseconds resolution / 32-битное разрешение долей секунды

// Synchronization parameters / Параметры синхронизации
parameter SYNC_THRESHOLD = 1000;        // Sync threshold in clock cycles / Порог синхронизации в тактах
parameter MAX_DRIFT = 10000;            // Maximum allowed drift in clock cycles / Максимальный допустимый дрейф в тактах

// =============================================================================
// Internal Signals / Внутренние сигналы
// =============================================================================

// Time tracking / Отслеживание времени
reg [39:0]  current_seconds;        // Текущие секунды
reg [31:0]  current_subseconds;     // Текущие доли секунды
reg [31:0]  subsec_counter;         // Счетчик долей секунды
reg [31:0]  subsec_increment;       // Приращение долей секунды за такт
reg         time_valid;             // Время валидно

// PPS generation / Генерация PPS
reg [31:0]  pps_pulse_counter;      // Счетчик длительности импульса PPS
reg         pps_active;             // Импульс PPS активен
reg [31:0]  next_pps_time;          // Время следующего PPS
reg         pps_armed;              // PPS взведен

// Synchronization / Синхронизация
reg [39:0]  last_sync_seconds;      // Последние синхронизированные секунды
reg [31:0]  last_sync_subseconds;   // Последние синхронизированные доли секунды
reg [31:0]  sync_error;             // Ошибка синхронизации
reg         sync_valid;             // Синхронизация валидна
reg [31:0]  drift_accumulator;      // Накопитель дрейфа

// State machine / Конечный автомат
reg [2:0]   pps_state;              // Состояние автомата
localparam  STATE_INIT      = 3'b000;   // Инициализация
localparam  STATE_SYNC      = 3'b001;   // Синхронизация
localparam  STATE_TRACKING  = 3'b010;   // Отслеживание
localparam  STATE_GENERATE  = 3'b011;   // Генерация
localparam  STATE_ERROR     = 3'b100;   // Ошибка

// =============================================================================
// Subseconds Increment Calculation / Расчет приращения долей секунды
// =============================================================================

// Calculate increment per clock cycle for subseconds counter
// Расчет приращения за такт для счетчика долей секунды
// subsec_increment = (2^32) / CLK_FREQ_HZ
always @(*) begin
    subsec_increment = 32'd42949673;  // Approximately 2^32 / 100MHz / Приблизительно 2^32 / 100МГц
end

// =============================================================================
// Time Tracking Logic / Логика отслеживания времени
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_seconds <= 40'h0000000000;
        current_subseconds <= 32'h00000000;
        subsec_counter <= 32'h00000000;
        time_valid <= 1'b0;
    end else begin
        if (timestamp_ready && timestamp_valid) begin
            // Synchronize to incoming timestamp / Синхронизация с входной временной меткой
            current_seconds <= seconds_since_2000;
            current_subseconds <= subseconds;
            subsec_counter <= subseconds;
            time_valid <= 1'b1;
        end else if (time_valid) begin
            // Free-running time tracking / Свободное отслеживание времени
            subsec_counter <= subsec_counter + subsec_increment;
            
            // Handle subseconds overflow (new second) / Обработка переполнения долей секунды (новый момент)
            if (subsec_counter >= SUBSEC_RESOLUTION) begin
                subsec_counter <= subsec_counter - SUBSEC_RESOLUTION;
                current_seconds <= current_seconds + 1'b1;
            end
            
            current_subseconds <= subsec_counter;
        end
    end
end

// =============================================================================
// Synchronization Error Calculation / Расчет ошибки синхронизации
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_error <= 32'h00000000;
        sync_valid <= 1'b0;
        drift_accumulator <= 32'h00000000;
        last_sync_seconds <= 40'h0000000000;
        last_sync_subseconds <= 32'h00000000;
    end else begin
        if (timestamp_ready && timestamp_valid && time_valid) begin
            // Calculate synchronization error / Расчет ошибки синхронизации
            if (seconds_since_2000 == current_seconds) begin
                // Same second, calculate subseconds difference / Одинаковые секунды, расчет разницы долей секунды
                if (subseconds > current_subseconds) begin
                    sync_error <= subseconds - current_subseconds;
                end else begin
                    sync_error <= current_subseconds - subseconds;
                end
            end else begin
                // Different seconds, large error / Разные секунды, большая ошибка
                sync_error <= 32'hFFFFFFFF;
            end
            
            // Update drift accumulator / Обновление накопителя дрейфа
            if (sync_error < SYNC_THRESHOLD) begin
                drift_accumulator <= drift_accumulator + sync_error;
                sync_valid <= 1'b1;
            end else begin
                drift_accumulator <= 32'h00000000;
                sync_valid <= 1'b0;
            end
            
            last_sync_seconds <= seconds_since_2000;
            last_sync_subseconds <= subseconds;
        end
    end
end

// =============================================================================
// PPS Generation State Machine / Конечный автомат генерации PPS
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_state <= STATE_INIT;
    end else begin
        case (pps_state)
            STATE_INIT: begin
                if (time_valid) begin
                    pps_state <= STATE_SYNC;
                end
            end
            
            STATE_SYNC: begin
                if (sync_valid && (sync_error < SYNC_THRESHOLD)) begin
                    pps_state <= STATE_TRACKING;
                end else if (sync_error > MAX_DRIFT) begin
                    pps_state <= STATE_ERROR;
                end
            end
            
            STATE_TRACKING: begin
                if (pps_armed && (current_subseconds >= next_pps_time)) begin
                    pps_state <= STATE_GENERATE;
                end else if (sync_error > MAX_DRIFT) begin
                    pps_state <= STATE_ERROR;
                end
            end
            
            STATE_GENERATE: begin
                if (pps_pulse_counter >= PPS_PULSE_WIDTH) begin
                    pps_state <= STATE_TRACKING;
                end
            end
            
            STATE_ERROR: begin
                if (timestamp_ready && timestamp_valid) begin
                    pps_state <= STATE_INIT;
                end
            end
            
            default: begin
                pps_state <= STATE_INIT;
            end
        endcase
    end
end

// =============================================================================
// PPS Pulse Generation Logic / Логика генерации импульса PPS
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pps_pulse <= 1'b0;
        pps_pulse_counter <= 32'h00000000;
        pps_counter <= 32'h00000000;
        next_pps_time <= 32'h00000000;
        pps_armed <= 1'b0;
        pps_active <= 1'b0;
        pps_error <= 1'b0;
    end else begin
        // Default values / Значения по умолчанию
        pps_error <= 1'b0;
        
        case (pps_state)
            STATE_INIT: begin
                pps_pulse <= 1'b0;
                pps_pulse_counter <= 32'h00000000;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
            end
            
            STATE_SYNC: begin
                pps_pulse <= 1'b0;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
            end
            
            STATE_TRACKING: begin
                pps_pulse <= 1'b0;
                pps_pulse_counter <= 32'h00000000;
                
                // Arm PPS for next second boundary / Взведение PPS для следующей границы секунды
                if (!pps_armed) begin
                    next_pps_time <= 32'h00000000;  // Target start of next second / Цель - начало следующей секунды
                    pps_armed <= 1'b1;
                end
                
                // Check if we should generate PPS / Проверка, нужно ли генерировать PPS
                if (pps_armed && (current_subseconds < 32'h10000000)) begin  // Near second boundary / Близкая к границе секунды
                    pps_active <= 1'b1;
                end
            end
            
            STATE_GENERATE: begin
                pps_active <= 1'b1;
                pps_pulse <= 1'b1;
                pps_pulse_counter <= pps_pulse_counter + 1'b1;
                
                if (pps_pulse_counter >= PPS_PULSE_WIDTH) begin
                    pps_pulse <= 1'b0;
                    pps_counter <= pps_counter + 1'b1;
                    pps_armed <= 1'b0;
                    pps_active <= 1'b0;
                end
            end
            
            STATE_ERROR: begin
                pps_pulse <= 1'b0;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
                pps_error <= 1'b1;
            end
            
            default: begin
                pps_pulse <= 1'b0;
                pps_armed <= 1'b0;
                pps_active <= 1'b0;
            end
        endcase
    end
end

// =============================================================================
// Debug and Monitoring / Отладка и мониторинг
// =============================================================================

// Synthesis translate_off
always @(posedge clk) begin
    if (pps_pulse && !pps_active) begin  // Rising edge of PPS / Переход импульса PPS в 1
        $display("PPS pulse generated at time %t", $time);
        $display("  Current seconds: %d", current_seconds);
        $display("  Current subseconds: 0x%08x", current_subseconds);
        $display("  PPS counter: %d", pps_counter + 1);
        $display("  Sync error: %d", sync_error);
    end
    
    if (pps_error) begin
        $display("PPS generation error at time %t", $time);
        $display("  Sync error: %d (threshold: %d)", sync_error, MAX_DRIFT);
        $display("  State: %d", pps_state);
    end
end
// Synthesis translate_on

endmodule

