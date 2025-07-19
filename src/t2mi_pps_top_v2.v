// =============================================================================
// T2MI PPS Generator Top Level Module with SiT5503 Support
// Модуль верхнего уровня генератора PPS из потока T2MI с поддержкой SiT5503
// =============================================================================
// Description: Top-level module for T2MI PPS generator with high-stability
//              SiT5503 oscillator support and autonomous operation capability
// Описание: Модуль верхнего уровня для генератора PPS из потока T2MI с поддержкой
//          высокостабильного осциллятора SiT5503 и возможностью автономной работы
// Target: Lattice LFE5U-25F-6BG256C
// Целевая платформа: Lattice LFE5U-25F-6BG256C
// Author: Manus AI
// Date: June 6, 2025
// Version: 2.0 - Added SiT5503 support
// Версия: 2.0 - Добавлена поддержка SiT5503
// =============================================================================

module t2mi_pps_top_v2 (
    // Clock and Reset / Тактирование и сброс
    input  wire        clk_100mhz,       // 100 MHz system clock / Системная тактовая частота 100 МГц
    input  wire        rst_n,            // Active low reset / Сброс активным низким уровнем
    
    // T2-MI Input Interface / Интерфейс входного потока T2-MI
    input  wire        t2mi_clk,         // T2-MI stream clock / Тактовая частота потока T2-MI
    input  wire        t2mi_valid,       // T2-MI data valid / Признак валидности данных T2-MI
    input  wire [7:0]  t2mi_data,        // T2-MI data byte / Байт данных T2-MI
    input  wire        t2mi_sync,        // T2-MI sync signal / Сигнал синхронизации T2-MI
    
    // SiT5503 High-Stability Oscillator Interface / Интерфейс высокостабильного осциллятора SiT5503
    input  wire        sit5503_clk,      // 10 MHz from SiT5503 / 10 МГц от SiT5503
    output wire        sit5503_scl,      // I2C clock to SiT5503 / I2C тактовая частота к SiT5503
    inout  wire        sit5503_sda,      // I2C data to SiT5503 / I2C данные к SiT5503
    
    // PPS Outputs / Выходы PPS
    output wire        pps_out,          // Main PPS output (high precision) / Основной выход PPS (высокая точность)
    output wire        pps_backup,       // Backup PPS output / Резервный выход PPS
    
    // Status and Debug / Статус и отладка
    output wire        timestamp_valid,  // Timestamp extracted flag / Флаг извлечения временной метки
    output wire        sync_locked,      // T2-MI sync locked / Захват синхронизации T2-MI
    output wire        autonomous_mode,  // Operating in autonomous mode / Работа в автономном режиме
    output wire        sit5503_ready,    // SiT5503 oscillator ready / Готовность осциллятора SiT5503
    output wire [7:0]  debug_status,     // Debug status register / Регистр отладочного статуса
    output wire [7:0]  pps_status,       // PPS generator status / Статус генератора PPS
    
    // LED Indicators / Светодиодные индикаторы
    output wire        led_power,        // Power indicator / Индикатор питания
    output wire        led_sync,         // Sync status indicator / Индикатор статуса синхронизации
    output wire        led_pps,          // PPS activity indicator / Индикатор активности PPS
    output wire        led_error,        // Error indicator / Индикатор ошибки
    output wire        led_autonomous,   // Autonomous mode indicator / Индикатор автономного режима
    output wire        led_sit5503       // SiT5503 status indicator / Индикатор статуса SiT5503
);

// =============================================================================
// Internal Signals / Внутренние сигналы
// =============================================================================

// Clock and reset signals / Сигналы тактирования и сброса
wire        clk_100mhz_buf;
wire        rst_sync;

// T2-MI packet parser signals / Сигналы парсера пакетов T2-MI
wire        packet_valid;
wire [7:0]  packet_type;
wire [15:0] packet_length;
wire [7:0]  packet_data;
wire        packet_start;
wire        packet_end;

// Timestamp extractor signals / Сигналы экстрактора временных меток
wire [39:0] timestamp_seconds;      // Секунды с 2000 года
wire [31:0] timestamp_subseconds;   // Доли секунды
wire        timestamp_ready;        // Временная метка готова
wire        timestamp_error;        // Ошибка извлечения метки

// SiT5503 controller signals / Сигналы контроллера SiT5503
wire        sit5503_calibrate_start;     // Запуск калибровки
wire [15:0] sit5503_frequency_offset;    // Смещение частоты
wire        sit5503_offset_valid;        // Валидность смещения
wire        sit5503_calibration_done;    // Калибровка завершена
wire [7:0]  sit5503_status_reg;         // Регистр статуса

// Enhanced PPS generator signals / Сигналы улучшенного генератора PPS
wire        pps_sync_status;        // Статус синхронизации PPS
wire [31:0] pps_time_error;        // Ошибка времени
wire        pps_calibrate_request;  // Запрос калибровки
wire [15:0] pps_freq_correction;    // Коррекция частоты

// Status and control signals / Сигналы статуса и управления
wire        t2mi_sync_locked;       // Захват синхронизации T2MI
wire        force_autonomous_mode;   // Принудительный автономный режим
reg [7:0]   status_counter;         // Счетчик статуса
reg [23:0]  led_blink_counter;     // Счетчик мигания светодиодов

// =============================================================================
// Clock and Reset Management / Управление тактированием и сбросом
// =============================================================================

// Buffer input clock / Буферизация входной тактовой частоты
assign clk_100mhz_buf = clk_100mhz;

// Synchronous reset generation / Генерация синхронного сброса
reset_synchronizer rst_sync_inst (
    .clk        (clk_100mhz_buf),
    .async_rst_n(rst_n),
    .sync_rst_n (rst_sync)
);

// =============================================================================
// T2-MI Packet Parser / Парсер пакетов T2-MI
// =============================================================================

t2mi_packet_parser parser_inst (
    .clk            (clk_100mhz_buf),
    .rst_n          (rst_sync),
    .t2mi_clk       (t2mi_clk),
    .t2mi_data      (t2mi_data),
    .t2mi_valid     (t2mi_valid),
    .t2mi_sync      (t2mi_sync),
    .packet_valid   (packet_valid),
    .packet_type    (packet_type),
    .packet_length  (packet_length),
    .packet_data    (packet_data),
    .packet_start   (packet_start),
    .packet_end     (packet_end),
    .sync_locked    (t2mi_sync_locked),
    .parser_error   (debug_status[0])
);

// =============================================================================
// Timestamp Extractor / Экстрактор временных меток
// =============================================================================

timestamp_extractor ts_extractor_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .packet_valid       (packet_valid),
    .packet_type        (packet_type),
    .packet_data        (packet_data),
    .packet_start       (packet_start),
    .packet_end         (packet_end),
    .seconds_since_2000 (timestamp_seconds),
    .subseconds         (timestamp_subseconds),
    .timestamp_valid    (timestamp_ready),
    .extractor_error    (timestamp_error)
);

// =============================================================================
// SiT5503 High-Stability Oscillator Controller / Контроллер высокостабильного осциллятора SiT5503
// =============================================================================

sit5503_controller sit5503_inst (
    .clk                (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .scl                (sit5503_scl),
    .sda                (sit5503_sda),
    .sit5503_clk        (sit5503_clk),
    .sit5503_clk_out    (), // Internal use only
    .calibrate_start    (pps_calibrate_request),
    .frequency_offset   (pps_freq_correction),
    .offset_valid       (pps_calibrate_request),
    .calibration_done   (sit5503_calibration_done),
    .oscillator_ready   (sit5503_ready),
    .status_reg         (sit5503_status_reg),
    .ref_pps            (pps_out),
    .ref_valid          (pps_sync_status)
);

// =============================================================================
// Enhanced PPS Generator with SiT5503 Support / Улучшенный генератор PPS с поддержкой SiT5503
// =============================================================================

enhanced_pps_generator pps_inst (
    .clk_100mhz         (clk_100mhz_buf),
    .rst_n              (rst_sync),
    .sit5503_clk        (sit5503_clk),
    .sit5503_ready      (sit5503_ready),
    .timestamp_valid    (timestamp_ready),
    .timestamp_seconds  (timestamp_seconds),
    .timestamp_subsec   (timestamp_subseconds),
    .t2mi_sync_locked   (t2mi_sync_locked),
    .pps_out            (pps_out),
    .pps_backup         (pps_backup),
    .force_autonomous   (force_autonomous_mode),
    .autonomous_mode    (autonomous_mode),
    .sync_status        (pps_sync_status),
    .pps_status         (pps_status),
    .time_error         (pps_time_error),
    .calibrate_request  (pps_calibrate_request),
    .freq_correction    (pps_freq_correction),
    .calibration_done   (sit5503_calibration_done)
);

// =============================================================================
// Status and Debug Logic / Логика статуса и отладки
// =============================================================================

assign timestamp_valid = timestamp_ready;
assign sync_locked = t2mi_sync_locked && pps_sync_status;

// Debug status register / Регистр отладочного статуса
assign debug_status[1] = timestamp_error;
assign debug_status[2] = sit5503_ready;
assign debug_status[3] = autonomous_mode;
assign debug_status[4] = pps_calibrate_request;
assign debug_status[5] = sit5503_calibration_done;
assign debug_status[6] = |pps_time_error[31:16];  // High time error / Высокая ошибка времени
assign debug_status[7] = |sit5503_status_reg[7:4]; // SiT5503 error / Ошибка SiT5503

// Force autonomous mode control (can be controlled via debug interface) / Управление автономным режимом (может контролироваться через интерфейс отладки)
assign force_autonomous_mode = 1'b0;  // Default: automatic mode selection / По умолчанию: автоматический выбор режима

// =============================================================================
// LED Control Logic / Логика управления светодиодами
// =============================================================================

always @(posedge clk_100mhz_buf or negedge rst_sync) begin
    if (!rst_sync) begin
        led_blink_counter <= 24'h0;
        status_counter <= 8'h0;
    end else begin
        led_blink_counter <= led_blink_counter + 1;
        status_counter <= status_counter + 1;
    end
end

// LED assignments with blinking patterns / Назначение светодиодов с мигающими паттернами
assign led_power = 1'b1;  // Always on when powered / Всегда включен при питании

assign led_sync = sync_locked ? 1'b1 : led_blink_counter[22];  // Solid when synced, slow blink when not / Включен при синхронизации, медленно мигает при отсутствии

assign led_pps = pps_out;  // Flash with PPS pulse / Мигает с импульсом PPS

assign led_error = (timestamp_error || debug_status[7]) ? 
                   led_blink_counter[20] : 1'b0;  // Fast blink on error / Быстро мигает при ошибке

assign led_autonomous = autonomous_mode ? 
                       led_blink_counter[21] : 1'b0;  // Medium blink in autonomous mode / Средний миг в автономном режиме

assign led_sit5503 = sit5503_ready ? 1'b1 : led_blink_counter[23];  // Solid when ready, very slow blink when not / Включен при готовности, очень медленно мигает при отсутствии

endmodule

