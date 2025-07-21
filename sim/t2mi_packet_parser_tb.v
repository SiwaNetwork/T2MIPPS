// =============================================================================
// Тестовый стенд парсера пакетов T2MI
// =============================================================================
// Описание: Модульный тест для модуля парсера пакетов T2MI
// Тестирует обнаружение синхронизации, извлечение пакетов и обработку ошибок
// =============================================================================

`timescale 1ns/1ps

module t2mi_packet_parser_tb();

// Параметры
parameter CLK_PERIOD = 10;    // 100 МГц
parameter T2MI_CLK_PERIOD = 37.037;  // 27 МГц

// Сигналы тестируемого устройства
reg         clk;
reg         rst_n;
reg         t2mi_clk;
reg         t2mi_valid;
reg [7:0]   t2mi_data;
reg         t2mi_sync;

wire        packet_valid;
wire [7:0]  packet_type;
wire [15:0] packet_length;
wire [7:0]  packet_data;
wire        packet_start;
wire        packet_end;
wire        sync_locked;
wire        parser_error;

// Тестовые переменные
integer     test_count;
integer     error_count;
reg [7:0]   test_data [0:1023];
integer     i;

// Генерация тактовых сигналов
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    t2mi_clk = 0;
    forever #(T2MI_CLK_PERIOD/2) t2mi_clk = ~t2mi_clk;
end

// Создание экземпляра тестируемого устройства
t2mi_packet_parser dut (
    .clk           (clk),
    .rst_n         (rst_n),
    .t2mi_clk      (t2mi_clk),
    .t2mi_valid    (t2mi_valid),
    .t2mi_data     (t2mi_data),
    .t2mi_sync     (t2mi_sync),
    .packet_valid  (packet_valid),
    .packet_type   (packet_type),
    .packet_length (packet_length),
    .packet_data   (packet_data),
    .packet_start  (packet_start),
    .packet_end    (packet_end),
    .sync_locked   (sync_locked),
    .parser_error  (parser_error)
);

// Тестовые задачи
task send_byte;
    input [7:0] data;
    input       sync;
    begin
        @(posedge t2mi_clk);
        t2mi_valid <= 1'b1;
        t2mi_data <= data;
        t2mi_sync <= sync;
        @(posedge t2mi_clk);
        t2mi_valid <= 1'b0;
    end
endtask

task send_packet;
    input [7:0] pkt_type;
    input [15:0] pkt_length;
    integer j;
    begin
        $display("Время %0t: Отправка пакета типа 0x%02X, длина %0d", 
                 $time, pkt_type, pkt_length);
        
        // Отправка байта синхронизации
        send_byte(8'h47, 1'b1);
        
        // Отправка типа пакета
        send_byte(pkt_type, 1'b0);
        
        // Отправка длины
        send_byte(pkt_length[15:8], 1'b0);
        send_byte(pkt_length[7:0], 1'b0);
        
        // Отправка данных
        for (j = 0; j < pkt_length; j = j + 1) begin
            send_byte(8'hAA + j[7:0], 1'b0);
        end
    end
endtask

task verify_packet;
    input [7:0] expected_type;
    input [15:0] expected_length;
    integer byte_count;
    begin
        // Ожидание начала пакета
        while (!packet_start) @(posedge clk);
        
        $display("Время %0t: Начало пакета обнаружено", $time);
        
        if (packet_type !== expected_type) begin
            $display("ОШИБКА: Неверный тип пакета. Ожидался 0x%02X, получен 0x%02X",
                     expected_type, packet_type);
            error_count = error_count + 1;
        end
        
        if (packet_length !== expected_length) begin
            $display("ОШИБКА: Неверная длина пакета. Ожидалась %0d, получена %0d",
                     expected_length, packet_length);
            error_count = error_count + 1;
        end
        
        // Проверка байтов данных
        byte_count = 0;
        while (!packet_end) begin
            @(posedge clk);
            if (packet_valid) begin
                if (packet_data !== (8'hAA + byte_count[7:0])) begin
                    $display("ОШИБКА: Неверные данные в байте %0d", byte_count);
                    error_count = error_count + 1;
                end
                byte_count = byte_count + 1;
            end
        end
        
        $display("Время %0t: Конец пакета, получено %0d байт", $time, byte_count);
    end
endtask

// Основной тест
initial begin
    // Инициализация
    rst_n = 0;
    t2mi_valid = 0;
    t2mi_data = 0;
    t2mi_sync = 0;
    test_count = 0;
    error_count = 0;
    
    $display("=========================================");
    $display("Запуск тестового стенда парсера пакетов T2MI");
    $display("=========================================");
    
    // Сброс
    #100;
    rst_n = 1;
    #100;
    
    // Тест 1: Базовый пакет
    $display("\nТест 1: Базовый пакет");
    test_count = test_count + 1;
    
    send_packet(8'h10, 16'd10);
    verify_packet(8'h10, 16'd10);
    
    #1000;
    
    // Тест 2: Несколько байтов синхронизации для захвата
    $display("\nТест 2: Захват синхронизации");
    test_count = test_count + 1;
    
    repeat(3) send_byte(8'h47, 1'b1);
    send_packet(8'h20, 16'd5);
    verify_packet(8'h20, 16'd5);
    
    #1000;
    
    // Тест 3: Большой пакет
    $display("\nТест 3: Большой пакет");
    test_count = test_count + 1;
    
    send_packet(8'h30, 16'd100);
    verify_packet(8'h30, 16'd100);
    
    #1000;
    
    // Тест 4: Восстановление после неверного байта синхронизации
    $display("\nТест 4: Восстановление после ошибки");
    test_count = test_count + 1;
    
    // Отправка мусора
    repeat(10) send_byte($random, 1'b0);
    
    // Отправка валидного пакета
    send_packet(8'h40, 16'd15);
    verify_packet(8'h40, 16'd15);
    
    #1000;
    
    // Тест 5: Минимальная длина пакета
    $display("\nТест 5: Минимальная длина пакета");
    test_count = test_count + 1;
    
    send_packet(8'h50, 16'd4);
    verify_packet(8'h50, 16'd4);
    
    #1000;
    
    // Тест 6: Неверная длина пакета (слишком маленькая)
    $display("\nТест 6: Неверная длина пакета");
    test_count = test_count + 1;
    
    // Отправка байта синхронизации
    send_byte(8'h47, 1'b1);
    send_byte(8'h99, 1'b0);  // Тип
    send_byte(8'h00, 1'b0);  // Старший байт длины
    send_byte(8'h02, 1'b0);  // Младший байт длины = 2 (недопустимо)
    
    #1000;
    
    if (!parser_error) begin
        $display("ОШИБКА: Ошибка парсера не обнаружена для неверной длины");
        error_count = error_count + 1;
    end
    
    // Сводка
    $display("\n=========================================");
    $display("Сводка тестов:");
    $display("Всего тестов: %0d", test_count);
    $display("Ошибок: %0d", error_count);
    
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
    #10_000_000;
    $display("ОШИБКА: Тайм-аут симуляции!");
    $finish;
end

endmodule