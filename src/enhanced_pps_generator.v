// =============================================================================
// Enhanced PPS Generator with SiT5503 Support
// Улучшенный генератор PPS с поддержкой SiT5503
// =============================================================================
// Description: High-precision PPS generator using SiT5503 10 MHz oscillator
//              with T2-MI synchronization and autonomous operation capability
// Описание: Высокоточный генератор PPS, использующий осциллятор SiT5503 10 МГц
//          с синхронизацией T2-MI и возможностью автономной работы
// Author: Manus AI
// Date: June 6, 2025
// =============================================================================

module enhanced_pps_generator (
    // Clock and Reset / Тактирование и сброс
    input  wire        clk_100mhz,       // System clock (100 MHz) / Системная тактовая частота (100 МГц)
    input  wire        rst_n,            // Active low reset / Сброс активным низким уровнем
    
    // High-stability reference from SiT5503 / Высокостабильный опорный сигнал от SiT5503
    input  wire        sit5503_clk,      // 10 MHz from SiT5503 / 10 МГц от SiT5503
    input  wire        sit5503_ready,    // SiT5503 oscillator ready / Осциллятор SiT5503 готов
    
    // T2-MI Timestamp Input / Вход временных меток T2-MI
    input  wire        timestamp_valid,  // New timestamp available / Новая временная метка доступна
    input  wire [39:0] timestamp_seconds, // Seconds since epoch / Секунды с начала эпохи
    input  wire [31:0] timestamp_subsec, // Subseconds (32-bit fraction) / Доли секунды (32-битная дробь)
    input  wire        t2mi_sync_locked, // T2-MI synchronization status / Статус синхронизации T2-MI
    
    // PPS Outputs / Выходы PPS
    output reg         pps_out,          // Main PPS output / Основной выход PPS
    output reg         pps_backup,       // Backup PPS (autonomous mode) / Резервный PPS (автономный режим)
    
    // Control and Status / Управление и статус
    input  wire        force_autonomous, // Force autonomous mode / Принудительный автономный режим
    output reg         autonomous_mode,  // Currently in autonomous mode / Текущий режим - автономный
    output reg         sync_status,      // Synchronization status / Статус синхронизации
    output reg [7:0]   pps_status,       // Status register / Регистр статуса
    output reg [31:0]  time_error,       // Time error measurement / Измерение ошибки времени
    
    // Calibration Interface / Интерфейс калибровки
    output reg         calibrate_request, // Request SiT5503 calibration / Запрос калибровки SiT5503
    output reg [15:0]  freq_correction,   // Frequency correction value / Значение коррекции частоты
    input  wire        calibration_done   // Calibration completed / Калибровка завершена
);

// =============================================================================
// Parameters / Параметры
// =============================================================================

parameter SIT5503_FREQ_HZ = 10_000_000;     // 10 MHz SiT5503 frequency / Частота SiT5503 10 МГц
parameter CLK_100M_FREQ_HZ = 100_000_000;   // 100 MHz system clock / Системная частота 100 МГц
parameter PPS_PULSE_WIDTH = 1000;           // PPS pulse width (10 us) / Ширина импульса PPS (10 мкс)

// Timing parameters / Временные параметры
parameter SYNC_TIMEOUT_MS = 5000;           // 5 second sync timeout / Таймаут синхронизации 5 секунд
parameter CALIBRATION_INTERVAL_S = 3600;    // 1 hour calibration interval / Интервал калибровки 1 час
parameter MAX_TIME_ERROR_NS = 1000;         // 1 us maximum time error / Максимальная ошибка времени 1 мкс

// State machine states / Состояния конечного автомата
localparam [2:0] INIT          = 3'h0,  // Инициализация
                 WAIT_SYNC     = 3'h1,  // Ожидание синхронизации
                 SYNCHRONIZED  = 3'h2,  // Синхронизирован
                 AUTONOMOUS    = 3'h3,  // Автономный режим
                 CALIBRATING   = 3'h4,  // Калибровка
                 ERROR_ST      = 3'h5;  // Ошибка

// =============================================================================
// Internal Signals / Внутренние сигналы
// =============================================================================

reg [2:0]   state;                  // Текущее состояние
reg [2:0]   next_state;             // Следующее состояние

// Time keeping / Учет времени
reg [39:0]  current_seconds;        // Текущие секунды
reg [31:0]  current_subseconds;     // Текущие доли секунды
reg [31:0]  subsec_increment_100m;  // Приращение долей секунды для 100 МГц
reg [31:0]  subsec_increment_10m;   // Приращение долей секунды для 10 МГц
reg [31:0]  subsec_counter;         // Счетчик долей секунды
reg         time_valid;             // Время валидно

// SiT5503 clock domain crossing / Пересечение тактовых доменов SiT5503
reg         sit5503_clk_sync1;      // Первая ступень синхронизации
reg         sit5503_clk_sync2;      // Вторая ступень синхронизации
reg         sit5503_clk_prev;       // Предыдущее значение
reg         sit5503_pulse;          // Импульс от SiT5503
reg [31:0]  sit5503_counter;        // Счетчик импульсов SiT5503

// Synchronization logic / Логика синхронизации
reg [31:0]  sync_timeout_counter;   // Счетчик таймаута синхронизации
reg [39:0]  last_sync_seconds;      // Последние синхронизированные секунды
reg [31:0]  last_sync_subsec;       // Последние синхронизированные доли секунды
reg         sync_pending;           // Синхронизация ожидается
reg [31:0]  sync_error_accum;       // Накопитель ошибки синхронизации

// PPS generation / Генерация PPS
reg [31:0]  pps_counter;            // Счетчик PPS
reg [15:0]  pps_pulse_counter;      // Счетчик длительности импульса
reg         pps_active;             // Импульс PPS активен
reg         next_second_pending;    // Ожидается следующая секунда

// Calibration logic / Логика калибровки
reg [31:0]  calibration_timer;      // Таймер калибровки
reg [31:0]  freq_error_measurement; // Измерение ошибки частоты
reg [15:0]  calibration_history [0:7];
reg [2:0]   calibration_index;
reg         calibration_needed;

// Clock selection and monitoring / Выбор тактового сигнала и мониторинг
reg         use_sit5503_clock;
reg [31:0]  clock_monitor_counter;
reg         clock_stable;

// =============================================================================
// Clock Domain Crossing for SiT5503 / Пересечение тактовых доменов SiT5503
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        sit5503_clk_sync1 <= 1'b0;
        sit5503_clk_sync2 <= 1'b0;
        sit5503_clk_prev <= 1'b0;
        sit5503_pulse <= 1'b0;
    end else begin
        sit5503_clk_sync1 <= sit5503_clk;
        sit5503_clk_sync2 <= sit5503_clk_sync1;
        sit5503_clk_prev <= sit5503_clk_sync2;
        sit5503_pulse <= sit5503_clk_sync2 && !sit5503_clk_prev;
    end
end

// =============================================================================
// Subsecond Increment Calculation / Расчет приращения долей секунды
// =============================================================================

// Calculate subsecond increment for 100 MHz clock / Расчет приращения долей секунды для 100 МГц
// 2^32 / 100,000,000 = 42.94967296
initial begin
    subsec_increment_100m = 32'd42949673;  // Precise value for 100 MHz / Точный расчет для 100 МГц
end

// Calculate subsecond increment for 10 MHz clock (from SiT5503) / Расчет приращения долей секунды для 10 МГц (от SiT5503)
// 2^32 / 10,000,000 = 429.4967296
initial begin
    subsec_increment_10m = 32'd429496730;  // Precise value for 10 MHz / Точный расчет для 10 МГц
end

// =============================================================================
// Main State Machine / Основной конечный автомат
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        state <= INIT;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        INIT: begin
            if (sit5503_ready && clock_stable) begin
                next_state = WAIT_SYNC;
            end
        end
        
        WAIT_SYNC: begin
            if (timestamp_valid && t2mi_sync_locked) begin
                next_state = SYNCHRONIZED;
            end else if (sync_timeout_counter >= SYNC_TIMEOUT_MS * 100000) begin
                next_state = AUTONOMOUS;
            end else if (force_autonomous) begin
                next_state = AUTONOMOUS;
            end
        end
        
        SYNCHRONIZED: begin
            if (!t2mi_sync_locked || force_autonomous) begin
                next_state = AUTONOMOUS;
            end else if (calibration_needed) begin
                next_state = CALIBRATING;
            end
        end
        
        AUTONOMOUS: begin
            if (timestamp_valid && t2mi_sync_locked && !force_autonomous) begin
                next_state = SYNCHRONIZED;
            end else if (calibration_needed) begin
                next_state = CALIBRATING;
            end
        end
        
        CALIBRATING: begin
            if (calibration_done) begin
                if (t2mi_sync_locked && !force_autonomous) begin
                    next_state = SYNCHRONIZED;
                end else begin
                    next_state = AUTONOMOUS;
                end
            end
        end
        
        ERROR_ST: begin
            if (sit5503_ready && clock_stable) begin
                next_state = INIT;
            end
        end
        
        default: next_state = INIT;
    endcase
end

// =============================================================================
// Time Keeping Logic / Логика учета времени
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        current_seconds <= 40'h0;
        current_subseconds <= 32'h0;
        subsec_counter <= 32'h0;
        sit5503_counter <= 32'h0;
        time_valid <= 1'b0;
        use_sit5503_clock <= 1'b0;
    end else begin
        // Default increment using system clock / По умолчанию используем системный тактовый сигнал
        if (use_sit5503_clock && sit5503_pulse) begin
            // Use high-precision SiT5503 clock / Используем высокоточный тактовый сигнал SiT5503
            subsec_counter <= subsec_counter + subsec_increment_10m;
            sit5503_counter <= sit5503_counter + 1;
        end else begin
            // Use system clock as fallback / Используем системный тактовый сигнал как резерв
            subsec_counter <= subsec_counter + subsec_increment_100m;
        end
        
        // Handle subsecond overflow (new second) / Обработка переполнения долей секунды (новая секунда)
        if (subsec_counter >= 32'hFFFFFFFF) begin
            subsec_counter <= subsec_counter - 32'hFFFFFFFF;
            current_seconds <= current_seconds + 1;
            current_subseconds <= subsec_counter;
            next_second_pending <= 1'b1;
        end else begin
            current_subseconds <= subsec_counter;
        end
        
        // Synchronization with T2-MI timestamps / Синхронизация с временными метками T2-MI
        if (timestamp_valid && (state == SYNCHRONIZED)) begin
            // Calculate time error / Расчет ошибки времени
            time_error <= {8'h0, timestamp_subsec} - {8'h0, current_subseconds};
            
            // Apply correction if error is significant / Применение коррекции, если ошибка значительна
            if (time_error > MAX_TIME_ERROR_NS || time_error < -MAX_TIME_ERROR_NS) begin
                current_seconds <= timestamp_seconds;
                current_subseconds <= timestamp_subsec;
                subsec_counter <= timestamp_subsec;
                sync_error_accum <= sync_error_accum + time_error;
            end
            
            last_sync_seconds <= timestamp_seconds;
            last_sync_subsec <= timestamp_subsec;
            time_valid <= 1'b1;
        end
    end
end

// =============================================================================
// PPS Generation Logic / Логика генерации PPS
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        pps_out <= 1'b0;
        pps_backup <= 1'b0;
        pps_counter <= 32'h0;
        pps_pulse_counter <= 16'h0;
        pps_active <= 1'b0;
    end else begin
        // Generate PPS pulse on second boundary / Генерация импульса PPS на границе секунды
        if (next_second_pending && time_valid) begin
            pps_active <= 1'b1;
            pps_pulse_counter <= 16'h0;
            next_second_pending <= 1'b0;
        end
        
        // Control PPS pulse width / Управление шириной импульса PPS
        if (pps_active) begin
            pps_pulse_counter <= pps_pulse_counter + 1;
            
            if (pps_pulse_counter < PPS_PULSE_WIDTH) begin
                pps_out <= 1'b1;
                pps_backup <= 1'b1;
            end else begin
                pps_out <= 1'b0;
                pps_backup <= 1'b0;
                pps_active <= 1'b0;
            end
        end
    end
end

// =============================================================================
// Control Logic / Логика управления
// =============================================================================

always @(posedge clk_100mhz or negedge rst_n) begin
    if (!rst_n) begin
        sync_timeout_counter <= 32'h0;
        calibration_timer <= 32'h0;
        calibration_needed <= 1'b0;
        calibrate_request <= 1'b0;
        freq_correction <= 16'h0;
        autonomous_mode <= 1'b0;
        sync_status <= 1'b0;
        pps_status <= 8'h00;
        clock_monitor_counter <= 32'h0;
        clock_stable <= 1'b0;
        calibration_index <= 3'h0;
    end else begin
        // Default values / Значения по умолчанию
        calibrate_request <= 1'b0;
        
        // Clock stability monitoring / Мониторинг стабильности тактового сигнала
        if (sit5503_ready) begin
            clock_monitor_counter <= clock_monitor_counter + 1;
            if (clock_monitor_counter >= 32'd100000) begin  // 1 ms / 1 мс
                clock_stable <= 1'b1;
            end
        end else begin
            clock_monitor_counter <= 32'h0;
            clock_stable <= 1'b0;
        end
        
        case (state)
            INIT: begin
                pps_status[0] <= 1'b1;  // Initializing / Инициализация
                autonomous_mode <= 1'b0;
                sync_status <= 1'b0;
                use_sit5503_clock <= 1'b0;
            end
            
            WAIT_SYNC: begin
                pps_status[0] <= 1'b0;  // Not initializing / Не инициализация
                pps_status[1] <= 1'b1;  // Waiting for sync / Ожидание синхронизации
                sync_timeout_counter <= sync_timeout_counter + 1;
                use_sit5503_clock <= sit5503_ready;
            end
            
            SYNCHRONIZED: begin
                pps_status[1] <= 1'b0;  // Not waiting / Не ожидается
                pps_status[2] <= 1'b1;  // Synchronized / Синхронизирован
                autonomous_mode <= 1'b0;
                sync_status <= 1'b1;
                sync_timeout_counter <= 32'h0;
                use_sit5503_clock <= 1'b1;
                
                // Check if calibration is needed / Проверка необходимости калибровки
                calibration_timer <= calibration_timer + 1;
                if (calibration_timer >= CALIBRATION_INTERVAL_S * 100000000) begin
                    calibration_needed <= 1'b1;
                    calibration_timer <= 32'h0;
                end
            end
            
            AUTONOMOUS: begin
                pps_status[2] <= 1'b0;  // Not synchronized / Не синхронизирован
                pps_status[3] <= 1'b1;  // Autonomous mode / Автономный режим
                autonomous_mode <= 1'b1;
                sync_status <= 1'b0;
                use_sit5503_clock <= 1'b1;
                
                // Continue calibration timer in autonomous mode / Продолжение таймера калибровки в автономном режиме
                calibration_timer <= calibration_timer + 1;
                if (calibration_timer >= CALIBRATION_INTERVAL_S * 100000000) begin
                    calibration_needed <= 1'b1;
                    calibration_timer <= 32'h0;
                end
            end
            
            CALIBRATING: begin
                pps_status[4] <= 1'b1;  // Calibrating / Калибровка
                calibration_needed <= 1'b0;
                
                if (!calibrate_request) begin
                    // Calculate frequency correction based on accumulated error / Расчет коррекции частоты на основе накопленной ошибки
                    freq_correction <= sync_error_accum[15:0];
                    calibrate_request <= 1'b1;
                    
                    // Store calibration history / Хранение истории калибровки
                    calibration_history[calibration_index] <= freq_correction;
                    calibration_index <= calibration_index + 1;
                end
                
                if (calibration_done) begin
                    pps_status[4] <= 1'b0;  // Not calibrating / Не калибровка
                    sync_error_accum <= 32'h0;  // Reset error accumulator / Сброс накопителя ошибок
                end
            end
            
            ERROR_ST: begin
                pps_status[7] <= 1'b1;  // Error flag / Флаг ошибки
                autonomous_mode <= 1'b0;
                sync_status <= 1'b0;
                use_sit5503_clock <= 1'b0;
            end
        endcase
        
        // Update status register / Обновление регистра статуса
        pps_status[5] <= use_sit5503_clock;     // Using SiT5503 clock / Использование тактового сигнала SiT5503
        pps_status[6] <= time_valid;            // Time is valid / Время валидно
    end
end

endmodule

