# Статус реализации Allan deviation и MTIE

## Текущее состояние

### ✅ Частично реализовано

1. **Модуль `advanced_dpll_pid.v`**:
   - Имеет выходные порты для Allan deviation и MTIE:
     ```verilog
     output reg  [31:0] allan_deviation,      // Allan deviation estimate
     output reg  [31:0] mtie,                 // Maximum time interval error
     output reg  [31:0] tdev,                 // Time deviation
     ```
   
   - Содержит упрощенную реализацию расчета Allan deviation:
     ```verilog
     // Allan deviation calculation (simplified)
     if (allan_counter < 1000) begin
         allan_accumulator <= allan_accumulator + 
             (phase_detector_out - prev_error) * (phase_detector_out - prev_error);
         allan_counter <= allan_counter + 1;
     end else begin
         allan_deviation <= allan_accumulator / (2 * allan_counter);
         allan_accumulator <= 64'd0;
         allan_counter <= 32'd0;
     end
     ```
   
   - Реализован расчет MTIE:
     ```verilog
     // Update MTIE
     if (phase_detector_out > max_phase_error) begin
         max_phase_error <= phase_detector_out;
     end
     if (phase_detector_out < min_phase_error) begin
         min_phase_error <= phase_detector_out;
     end
     mtie <= (max_phase_error - min_phase_error) >> 16;  // Convert to nanoseconds
     ```

2. **Модуль `uart_monitor.v`**:
   - Подготовлен для передачи Allan deviation и MTIE по UART:
     ```verilog
     input  wire [31:0] allan_deviation,
     input  wire [31:0] mtie,
     
     // В протоколе передачи:
     // Allan deviation
     tx_buffer[10] <= allan_deviation[31:24];
     tx_buffer[11] <= allan_deviation[23:16];
     tx_buffer[12] <= allan_deviation[15:8];
     tx_buffer[13] <= allan_deviation[7:0];
     
     // MTIE
     tx_buffer[14] <= mtie[31:24];
     tx_buffer[15] <= mtie[23:16];
     tx_buffer[16] <= mtie[15:8];
     tx_buffer[17] <= mtie[7:0];
     ```

3. **Модуль `clock_monitor.v`**:
   - Имеет выходы для Allan deviation (но только 16-битные):
     ```verilog
     output reg  [15:0] sys_stability,      // Allan deviation (scaled)
     output reg  [15:0] ref_stability,      // Allan deviation (scaled)
     ```

### ❌ Не реализовано

1. **Интеграция в топ-модуль**:
   - В текущем топ-модуле `t2mi_pps_top_v3.v` используется `enhanced_dpll`, а не `advanced_dpll_pid`
   - `enhanced_dpll` не имеет выходов для Allan deviation и MTIE
   - Сигналы Allan deviation и MTIE не подключены к UART monitor или STM32 интерфейсу

2. **Полноценная реализация Allan deviation**:
   - Текущая реализация упрощенная и не соответствует стандартному алгоритму
   - Отсутствует поддержка различных tau (временных интервалов)
   - Нет overlapping или non-overlapping вариантов расчета

3. **Расширенная статистика**:
   - Не реализованы другие метрики стабильности (TDEV, MDEV, Hadamard deviation)
   - Нет долговременного накопления статистики

## Рекомендации по доработке

1. **Замена DPLL модуля**:
   - Заменить `enhanced_dpll` на `advanced_dpll_pid` в топ-модуле
   - Или добавить функционал Allan deviation и MTIE в `enhanced_dpll`

2. **Улучшение алгоритма Allan deviation**:
   - Реализовать стандартный алгоритм с поддержкой различных tau
   - Добавить буферы для хранения истории измерений
   - Реализовать overlapping Allan deviation для лучшей статистики

3. **Интеграция с интерфейсами**:
   - Подключить сигналы к STM32 интерфейсу для передачи статистики
   - Добавить команды для запроса статистики качества сигнала
   - Реализовать веб-интерфейс для отображения графиков Allan deviation

4. **Расширение функционала**:
   - Добавить другие метрики стабильности (TDEV, MDEV)
   - Реализовать долговременное логирование статистики
   - Добавить пороговые значения и алармы при деградации качества