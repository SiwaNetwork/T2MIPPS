// =============================================================================
// Тестовый стенд генератора T2MI PPS
// =============================================================================
// Описание: Комплексный тестовый стенд для верификации генератора T2MI PPS
// Автор: Тестовая команда
// Дата: Декабрь 2024
// =============================================================================

`timescale 1ns/1ps

module t2mi_pps_tb();

// =============================================================================
// Параметры и константы
// =============================================================================

parameter CLK_100M_PERIOD = 10;      // 10нс = 100МГц
parameter CLK_27M_PERIOD = 37.037;   // 37.037нс ≈ 27МГц
parameter SIM_DURATION = 5_000_000;  // 5мс время симуляции

// Параметры пакета T2MI
parameter SYNC_BYTE = 8'h47;
parameter TIMESTAMP_PACKET_TYPE = 8'h20;
parameter TIMESTAMP_PACKET_LENGTH = 16'h000C;  // 12 байт

// =============================================================================
// Сигналы тестируемого устройства
// =============================================================================

// Тактирование и сброс
reg         clk_100mhz;
reg         rst_n;

// Входной интерфейс T2-MI
reg         t2mi_clk;
reg         t2mi_valid;
reg  [7:0]  t2mi_data;
reg         t2mi_sync;

// Выходы PPS
wire        pps_out;
wire        timestamp_valid;
wire        sync_locked;
wire [7:0]  debug_status;

// Светодиодные индикаторы
wire        led_power;
wire        led_sync;
wire        led_pps;
wire        led_error;

// =============================================================================
// Тестовые переменные
// =============================================================================

reg [39:0]  test_seconds;
reg [31:0]  test_subseconds;
reg [12:0]  test_utc_offset;
reg [3:0]   test_bandwidth;
reg [7:0]   test_packet_buffer [0:255];
integer     packet_index;
integer     i;
reg         test_passed;
integer     pps_count;
real        pps_period;
real        last_pps_time;
reg         pps_prev;

// =============================================================================
// Генерация тактовых сигналов
// =============================================================================

initial begin
    clk_100mhz = 1'b0;
    forever #(CLK_100M_PERIOD/2) clk_100mhz = ~clk_100mhz;
end

initial begin
    t2mi_clk = 1'b0;
    forever #(CLK_27M_PERIOD/2) t2mi_clk = ~t2mi_clk;
end

// =============================================================================
// Создание экземпляра тестируемого устройства
// =============================================================================

t2mi_pps_top dut (
    // Тактирование и сброс
    .clk_100mhz      (clk_100mhz),
    .rst_n           (rst_n),
    
    // Входной интерфейс T2-MI
    .t2mi_clk        (t2mi_clk),
    .t2mi_valid      (t2mi_valid),
    .t2mi_data       (t2mi_data),
    .t2mi_sync       (t2mi_sync),
    
    // Выходы PPS
    .pps_out         (pps_out),
    .timestamp_valid (timestamp_valid),
    .sync_locked     (sync_locked),
    .debug_status    (debug_status),
    
    // Светодиодные индикаторы
    .led_power       (led_power),
    .led_sync        (led_sync),
    .led_pps         (led_pps),
    .led_error       (led_error)
);

// =============================================================================
// Тестовые задачи
// =============================================================================

// Задача для отправки одного байта T2MI
task send_t2mi_byte;
    input [7:0] data;
    input       sync;
    begin
        @(posedge t2mi_clk);
        t2mi_valid <= 1'b1;
        t2mi_data <= data;
        t2mi_sync <= sync;
        @(posedge t2mi_clk);
        t2mi_valid <= 1'b0;
        t2mi_sync <= 1'b0;
    end
endtask

// Задача для отправки пакета временной метки
task send_timestamp_packet;
    input [39:0] seconds;
    input [31:0] subseconds;
    input [12:0] utc_offset;
    
    reg [7:0] packet_data [0:15];
    integer j;
    
    begin
        // Подготовка данных пакета
        packet_data[0] = SYNC_BYTE;
        packet_data[1] = TIMESTAMP_PACKET_TYPE;
        packet_data[2] = TIMESTAMP_PACKET_LENGTH[15:8];
        packet_data[3] = TIMESTAMP_PACKET_LENGTH[7:0];
        
        // Секунды с 2000 года (5 байт)
        packet_data[4] = seconds[39:32];
        packet_data[5] = seconds[31:24];
        packet_data[6] = seconds[23:16];
        packet_data[7] = seconds[15:8];
        packet_data[8] = seconds[7:0];
        
        // Доли секунды (4 байта)
        packet_data[9]  = subseconds[31:24];
        packet_data[10] = subseconds[23:16];
        packet_data[11] = subseconds[15:8];
        packet_data[12] = subseconds[7:0];
        
        // Смещение UTC (2 байта)
        packet_data[13] = {3'b000, utc_offset[12:8]};
        packet_data[14] = utc_offset[7:0];
        
        // Резерв
        packet_data[15] = 8'h00;
        
        $display("Время %0t: Отправка пакета временной метки", $time);
        $display("  Секунды: %0d", seconds);
        $display("  Доли секунды: 0x%08X (%0.9f сек)", 
                 subseconds, real'(subseconds) / real'(32'hFFFFFFFF));
        $display("  Смещение UTC: %0d мин", utc_offset);
        
        // Отправка пакета
        for (j = 0; j < 16; j = j + 1) begin
            send_t2mi_byte(packet_data[j], (j == 0) ? 1'b1 : 1'b0);
        end
    end
endtask

// Задача для отправки мусорных данных
task send_garbage_data;
    input integer count;
    integer k;
    begin
        for (k = 0; k < count; k = k + 1) begin
            send_t2mi_byte($random & 8'hFF, 1'b0);
        end
    end
endtask

// Задача для измерения периода PPS
task measure_pps_period;
    real current_time;
    begin
        @(posedge pps_out);
        current_time = $realtime;
        
        if (last_pps_time > 0) begin
            pps_period = current_time - last_pps_time;
            $display("Время %0t: Импульс PPS, период = %0.6f мс (ошибка = %0.3f ppm)",
                     $time, pps_period/1_000_000, 
                     ((pps_period - 1_000_000_000) / 1_000_000_000) * 1e6);
        end
        
        last_pps_time = current_time;
        pps_count = pps_count + 1;
    end
endtask

// =============================================================================
// Мониторы
// =============================================================================

// Монитор PPS
always @(posedge clk_100mhz) begin
    pps_prev <= pps_out;
    if (pps_out && !pps_prev) begin
        $display("Время %0t: Обнаружен фронт PPS", $time);
    end
end

// Монитор состояния
always @(posedge clk_100mhz) begin
    if (sync_locked && !$past(sync_locked)) begin
        $display("Время %0t: Синхронизация захвачена", $time);
    end
    if (!sync_locked && $past(sync_locked)) begin
        $display("Время %0t: Синхронизация потеряна", $time);
    end
end

// =============================================================================
// Основная тестовая последовательность
// =============================================================================

initial begin
    // Инициализация
    $display("=========================================");
    $display("Запуск тестового стенда T2MI PPS");
    $display("=========================================");
    
    rst_n = 1'b0;
    t2mi_valid = 1'b0;
    t2mi_data = 8'h00;
    t2mi_sync = 1'b0;
    test_passed = 1'b1;
    pps_count = 0;
    last_pps_time = 0;
    pps_prev = 1'b0;
    
    // Дамп для просмотра волн
    $dumpfile("t2mi_pps_tb.vcd");
    $dumpvars(0, t2mi_pps_tb);
    
    // Сброс системы
    #1000;
    rst_n = 1'b1;
    #1000;
    
    // =========================================================================
    // Тест 1: Базовая синхронизация и генерация PPS
    // =========================================================================
    $display("\n--- Тест 1: Базовая синхронизация ---");
    
    // Отправка первого пакета временной метки
    test_seconds = 40'd789456123;  // Произвольное время
    test_subseconds = 32'h80000000;  // 0.5 секунды
    test_utc_offset = 13'd0;  // UTC
    
    send_timestamp_packet(test_seconds, test_subseconds, test_utc_offset);
    
    // Ожидание захвата синхронизации
    #100000;
    
    if (!sync_locked) begin
        $display("ОШИБКА: Синхронизация не захвачена");
        test_passed = 1'b0;
    end
    
    // Измерение нескольких периодов PPS
    $display("\nИзмерение периодов PPS...");
    fork
        begin
            repeat(5) measure_pps_period();
        end
        begin
            #6_000_000;  // Тайм-аут 6мс
        end
    join_any
    
    if (pps_count < 3) begin
        $display("ОШИБКА: Недостаточно импульсов PPS (%0d)", pps_count);
        test_passed = 1'b0;
    end
    
    // =========================================================================
    // Тест 2: Обновление временной метки
    // =========================================================================
    $display("\n--- Тест 2: Обновление временной метки ---");
    
    // Отправка новой временной метки с небольшим смещением
    test_seconds = test_seconds + 10;
    test_subseconds = 32'h00000000;  // Точно на секунде
    
    send_timestamp_packet(test_seconds, test_subseconds, test_utc_offset);
    
    // Проверка продолжения генерации PPS
    pps_count = 0;
    repeat(3) measure_pps_period();
    
    // =========================================================================
    // Тест 3: Устойчивость к помехам
    // =========================================================================
    $display("\n--- Тест 3: Устойчивость к помехам ---");
    
    // Отправка мусорных данных
    send_garbage_data(50);
    
    // Отправка валидного пакета
    test_seconds = test_seconds + 5;
    send_timestamp_packet(test_seconds, test_subseconds, test_utc_offset);
    
    #2_000_000;
    
    if (!sync_locked) begin
        $display("ОШИБКА: Синхронизация потеряна после помех");
        test_passed = 1'b0;
    end
    
    // =========================================================================
    // Тест 4: Точность долей секунды
    // =========================================================================
    $display("\n--- Тест 4: Точность долей секунды ---");
    
    // Тест различных значений долей секунды
    test_subseconds = 32'h19999999;  // ~0.1 секунды
    send_timestamp_packet(test_seconds + 1, test_subseconds, test_utc_offset);
    #1_000_000;
    
    test_subseconds = 32'hCCCCCCCC;  // ~0.8 секунды
    send_timestamp_packet(test_seconds + 2, test_subseconds, test_utc_offset);
    #1_000_000;
    
    // =========================================================================
    // Завершение тестов
    // =========================================================================
    #1_000_000;
    
    $display("\n=========================================");
    $display("Результаты тестирования:");
    $display("Всего импульсов PPS: %0d", pps_count);
    
    if (test_passed) begin
        $display("ВСЕ ТЕСТЫ ПРОЙДЕНЫ!");
    end else begin
        $display("ТЕСТЫ ПРОВАЛЕНЫ!");
    end
    $display("=========================================");
    
    $finish;
end

// =============================================================================
// Тайм-аут симуляции
// =============================================================================

initial begin
    #SIM_DURATION;
    $display("\nДостигнут тайм-аут симуляции");
    $finish;
end

endmodule

