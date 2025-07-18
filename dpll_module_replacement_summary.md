# Замена DPLL модуля на advanced_dpll_pid

## Выполненные изменения

### 1. В файле `t2mi_pps_top_v3.v`:

#### Добавлены новые сигналы для advanced_dpll_pid:
```verilog
// DPLL outputs (расширены с 32 до 48 бит)
wire signed [47:0] dpll_phase_error;     // Changed to 48-bit signed
wire signed [47:0] dpll_freq_error;      // Changed to 48-bit signed
wire [31:0] dpll_holdover_duration;
wire [3:0]  dpll_state;

// Advanced DPLL diagnostics
wire [47:0] dpll_phase_variance;
wire [47:0] dpll_frequency_variance;
wire [31:0] dpll_allan_deviation;        // Allan deviation
wire [31:0] dpll_mtie;                   // MTIE
wire [31:0] dpll_tdev;
wire signed [47:0] dpll_phase_prediction;
wire [15:0] dpll_lock_quality;

// PID components
wire signed [47:0] dpll_p_term;
wire signed [47:0] dpll_i_term;
wire signed [47:0] dpll_d_term;
wire signed [47:0] dpll_pid_output;

// PID control parameters
wire [31:0] dpll_kp;         // Changed to 32-bit for PID controller
wire [31:0] dpll_ki;         // Changed to 32-bit for PID controller
wire [31:0] dpll_kd;         // Added derivative gain
wire [31:0] dpll_integral_limit;
wire [15:0] dpll_derivative_filter;
wire [15:0] dpll_prediction_depth;
```

#### Заменен модуль enhanced_dpll на advanced_dpll_pid:
```verilog
advanced_dpll_pid #(
    .CLK_FREQ_HZ(100_000_000),
    .PHASE_BITS(48),
    .FREQ_BITS(48),
    .FIXED_POINT_BITS(16)
) dpll_inst (
    // ... полное подключение всех портов включая allan_deviation и mtie
);
```

#### Добавлены значения по умолчанию для новых параметров:
```verilog
assign dpll_kd = 32'h0000_0100;              // Default Kd = 1.0 in 16.16 fixed point
assign dpll_integral_limit = 32'h0010_0000;  // Default integral limit
assign dpll_derivative_filter = 16'd10;      // Default derivative filter
assign dpll_prediction_depth = 16'd5;        // Default prediction depth
```

#### Добавлен UART monitor для передачи Allan deviation и MTIE:
```verilog
uart_monitor #(
    .CLK_FREQ(100_000_000),
    .BAUD_RATE(115200)
) uart_monitor_inst (
    .clk                (clk_100mhz),
    .rst_n              (rst_n_sync),
    .uart_rx            (uart_rx),
    .uart_tx            (uart_tx),
    .allan_deviation    (dpll_allan_deviation),
    .mtie               (dpll_mtie),
    // ... другие подключения
);
```

#### Добавлены новые порты для UART:
```verilog
// UART Monitor interface
input  wire        uart_rx,          // UART RX for monitor
output wire        uart_tx,          // UART TX for monitor
```

### 2. В файле `stm32_interface.v`:

#### Обновлены типы данных для PID параметров:
```verilog
output reg  [31:0] dpll_kp,  // Изменено с 16 на 32 бита
output reg  [31:0] dpll_ki,  // Изменено с 16 на 32 бита
```

#### Обновлена обработка команд:
```verilog
2'd0: dpll_kp <= data_reg;  // Full 32-bit value
2'd1: dpll_ki <= data_reg;  // Full 32-bit value
```

## Результат

Теперь система использует `advanced_dpll_pid` модуль, который включает:
- ✅ Расчет Allan deviation
- ✅ Расчет MTIE (Maximum Time Interval Error)
- ✅ Расчет TDEV (Time Deviation)
- ✅ Полный PID контроллер с настраиваемыми параметрами
- ✅ Расширенную диагностику (phase variance, frequency variance)
- ✅ Предсказание фазы
- ✅ Метрику качества захвата

Allan deviation и MTIE теперь доступны через:
1. UART monitor - для мониторинга в реальном времени
2. STM32 интерфейс - может быть расширен для чтения этих значений

## Дальнейшие улучшения

1. Добавить регистры в STM32 интерфейс для чтения Allan deviation и MTIE
2. Реализовать более точный алгоритм Allan deviation с поддержкой различных tau
3. Добавить веб-интерфейс для визуализации статистики
4. Реализовать долговременное логирование метрик качества