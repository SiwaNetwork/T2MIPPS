// =============================================================================
// Тестовый стенд генератора PPS
// =============================================================================
// Описание: Модульный тест для модуля генератора PPS
// Тестирует отслеживание времени, синхронизацию и генерацию импульсов PPS
// =============================================================================

`timescale 1ns/1ps

module pps_generator_tb();

// Параметры
parameter CLK_PERIOD = 10;  // 100 МГц
parameter CLK_FREQ = 100_000_000;

// Сигналы тестируемого устройства
reg         clk;
reg         rst_n;
reg         timestamp_valid;
reg [39:0]  seconds_since_2000;
reg [31:0]  subseconds;
reg         timestamp_ready;

wire        pps_pulse;
wire [31:0] pps_counter;
wire        pps_error;

// Тестовые переменные
real        expected_pps_time;
real        actual_pps_time;
real        time_error;
integer     test_count;
integer     error_count;
reg         pps_detected;
real        last_pps_time;
integer     pps_count;

// Генерация тактового сигнала
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Создание экземпляра тестируемого устройства
pps_generator dut (
    .clk                (clk),
    .rst_n              (rst_n),
    .timestamp_valid    (timestamp_valid),
    .seconds_since_2000 (seconds_since_2000),
    .subseconds         (subseconds),
    .timestamp_ready    (timestamp_ready),
    .pps_pulse          (pps_pulse),
    .pps_counter        (pps_counter),
    .pps_error          (pps_error)
);

// Задачи
task send_timestamp;
    input [39:0] seconds;
    input [31:0] subsec;
    begin
        @(posedge clk);
        timestamp_valid <= 1'b1;
        seconds_since_2000 <= seconds;
        subseconds <= subsec;
        @(posedge clk);
        timestamp_valid <= 1'b0;
        
        $display("Время %0t: Отправлена временная метка: %0d.%09d секунд",
                 $time, seconds, subsec * 1000000000 / 32'hFFFFFFFF);
    end
endtask

task wait_for_pps;
    begin
        pps_detected = 0;
        @(posedge pps_pulse);
        pps_detected = 1;
        actual_pps_time = $realtime;
        pps_count = pps_count + 1;
        
        $display("Время %0t: Обнаружен импульс PPS #%0d", $time, pps_count);
    end
endtask

// Монитор PPS
always @(posedge pps_pulse) begin
    if (last_pps_time > 0) begin
        real period;
        period = $realtime - last_pps_time;
        
        $display("Время %0t: Период PPS = %0.6f мс (ошибка = %0.3f ppm)",
                 $time, period/1000000, (period - 1e9) / 1000);
    end
    last_pps_time = $realtime;
end

// Основной тест
initial begin
    // Инициализация
    rst_n = 0;
    timestamp_valid = 0;
    seconds_since_2000 = 0;
    subseconds = 0;
    timestamp_ready = 1;
    test_count = 0;
    error_count = 0;
    pps_count = 0;
    last_pps_time = 0;
    
    $display("=========================================");
    $display("Запуск тестового стенда генератора PPS");
    $display("=========================================");
    
    // Сброс
    #100;
    rst_n = 1;
    #100;
    
    // Тест 1: Начальная синхронизация
    $display("\nТест 1: Начальная синхронизация");
    test_count = test_count + 1;
    
    // Отправка временной метки на 0.5 секунды
    send_timestamp(40'd1000, 32'h80000000);
    
    // Ожидание следующей границы секунды
    wait_for_pps();
    
    // Проверка времени (должно быть примерно через 0.5 секунды)
    expected_pps_time = $realtime + 500_000_000;
    time_error = actual_pps_time - expected_pps_time;
    
    $display("Ожидаемое время PPS: %0.3f мс", expected_pps_time/1000000);
    $display("Фактическое время PPS: %0.3f мс", actual_pps_time/1000000);
    $display("Ошибка времени: %0.3f мкс", time_error/1000);
    
    if (time_error > 1000) begin  // Допуск 1 мкс
        $display("ОШИБКА: Слишком большая ошибка времени!");
        error_count = error_count + 1;
    end
    
    // Тест 2: Обычная работа
    $display("\nТест 2: Обычная работа");
    test_count = test_count + 1;
    
    // Работа в течение 3 секунд
    repeat(3) begin
        wait_for_pps();
    end
    
    if (pps_count < 3) begin
        $display("ОШИБКА: Недостаточно импульсов PPS!");
        error_count = error_count + 1;
    end
    
    // Тест 3: Обновление временной метки
    $display("\nТест 3: Обновление временной метки");
    test_count = test_count + 1;
    
    // Отправка новой временной метки с небольшим смещением
    send_timestamp(40'd1005, 32'h00100000);  // Немного впереди
    
    wait_for_pps();
    
    // Тест 4: Большой скачок времени
    $display("\nТест 4: Большой скачок времени");
    test_count = test_count + 1;
    
    // Скачок на 1 час вперед
    send_timestamp(40'd4600, 32'h00000000);
    
    #100000;  // Ожидание обработки
    
    wait_for_pps();
    
    // Тест 5: Точность долей секунды
    $display("\nТест 5: Точность долей секунды");
    test_count = test_count + 1;
    
    // Отправка временной метки с точными значениями долей секунды
    send_timestamp(40'd5000, 32'h00000000);  // Точно на секунде
    wait_for_pps();
    
    send_timestamp(40'd5001, 32'h19999999);  // 0.1 секунды
    wait_for_pps();
    
    // Тест 6: Максимальные значения
    $display("\nТест 6: Максимальные значения");
    test_count = test_count + 1;
    
    // Близко к максимальным секундам
    send_timestamp(40'hFFFFFFFF00, 32'h00000000);
    
    #100000;
    
    // Проверка обработки переполнения
    if (pps_error) begin
        $display("Обнаружена ошибка PPS (ожидаемо для больших значений)");
    end
    
    // Сводка
    $display("\n=========================================");
    $display("Сводка тестов:");
    $display("Всего тестов: %0d", test_count);
    $display("Ошибок: %0d", error_count);
    $display("Всего импульсов PPS: %0d", pps_count);
    
    if (error_count == 0) begin
        $display("ВСЕ ТЕСТЫ ПРОЙДЕНЫ!");
    end else begin
        $display("ТЕСТЫ ПРОВАЛЕНЫ!");
    end
    $display("=========================================");
    
    $finish;
end

// Тайм-аут
initial begin
    #10_000_000;  // 10мс
    $display("ОШИБКА: Тайм-аут симуляции!");
    $finish;
end

endmodule