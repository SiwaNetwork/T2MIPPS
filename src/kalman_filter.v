// =============================================================================
// Kalman Filter for PPS Time Error Estimation
// Фильтр Калмана для оценки временной ошибки PPS
// =============================================================================
// Description: 2D Kalman filter for phase and frequency error estimation
// Описание: 2D фильтр Калмана для оценки фазовой и частотной ошибки
// Author: Implementation based on T2MI PPS Generator requirements
// Date: 2024
// =============================================================================

module kalman_filter #(
    parameter DATA_WIDTH = 32,           // Разрядность данных
    parameter FRAC_BITS = 16,            // Количество дробных бит
    parameter MEASURE_VARIANCE = 32'h0000_1000,  // Дисперсия измерений (Q16.16)
    parameter PROCESS_VARIANCE = 32'h0000_0100   // Дисперсия процесса (Q16.16)
)(
    // Clock and Reset / Тактирование и сброс
    input  wire                    clk,
    input  wire                    rst_n,
    
    // Input measurements / Входные измерения
    input  wire                    measurement_valid,
    input  wire signed [DATA_WIDTH-1:0] phase_measurement,  // Измерение фазы (Q16.16)
    
    // Filter outputs / Выходы фильтра
    output reg  signed [DATA_WIDTH-1:0] phase_estimate,     // Оценка фазы (Q16.16)
    output reg  signed [DATA_WIDTH-1:0] frequency_estimate, // Оценка частоты (Q16.16)
    output reg  signed [DATA_WIDTH-1:0] phase_variance,     // Дисперсия фазы
    output reg  signed [DATA_WIDTH-1:0] freq_variance,      // Дисперсия частоты
    output reg                     estimates_valid,          // Оценки валидны
    
    // Control and status / Управление и статус
    input  wire                    reset_filter,            // Сброс фильтра
    output reg  [3:0]              filter_state,           // Состояние фильтра
    output reg                     filter_converged        // Фильтр сошелся
);

// =============================================================================
// State definitions / Определения состояний
// =============================================================================
localparam [3:0] STATE_INIT      = 4'd0;  // Инициализация
localparam [3:0] STATE_PREDICT   = 4'd1;  // Предсказание
localparam [3:0] STATE_UPDATE    = 4'd2;  // Обновление
localparam [3:0] STATE_READY     = 4'd3;  // Готов
localparam [3:0] STATE_CONVERGED = 4'd4;  // Сошелся

// =============================================================================
// Internal signals / Внутренние сигналы
// =============================================================================

// State vector: [phase, frequency] / Вектор состояния: [фаза, частота]
reg signed [DATA_WIDTH-1:0] x_phase;      // x[0] - фаза
reg signed [DATA_WIDTH-1:0] x_freq;       // x[1] - частота

// Covariance matrix P (2x2) / Ковариационная матрица P (2x2)
reg signed [DATA_WIDTH-1:0] P_00;         // P[0][0]
reg signed [DATA_WIDTH-1:0] P_01;         // P[0][1]
reg signed [DATA_WIDTH-1:0] P_10;         // P[1][0]
reg signed [DATA_WIDTH-1:0] P_11;         // P[1][1]

// Kalman gain K / Коэффициент усиления Калмана K
reg signed [DATA_WIDTH-1:0] K_0;          // K[0]
reg signed [DATA_WIDTH-1:0] K_1;          // K[1]

// Temporary variables / Временные переменные
reg signed [2*DATA_WIDTH-1:0] temp_mult;  // Для умножений
reg signed [DATA_WIDTH-1:0] innovation;    // y = z - H*x
reg signed [DATA_WIDTH-1:0] S;            // S = H*P*H' + R
reg signed [DATA_WIDTH-1:0] dt;           // Временной шаг

// Counters / Счетчики
reg [15:0] convergence_counter;
reg [15:0] update_counter;

// =============================================================================
// Fixed-point multiplication / Умножение с фиксированной точкой
// =============================================================================
function signed [DATA_WIDTH-1:0] fp_mult;
    input signed [DATA_WIDTH-1:0] a, b;
    reg signed [2*DATA_WIDTH-1:0] temp;
    begin
        temp = a * b;
        fp_mult = temp >>> FRAC_BITS;
    end
endfunction

// =============================================================================
// Main state machine / Основной конечный автомат
// =============================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || reset_filter) begin
        // Reset all states / Сброс всех состояний
        filter_state <= STATE_INIT;
        x_phase <= 32'd0;
        x_freq <= 32'd0;
        
        // Initialize covariance matrix with large values / Инициализация с большими значениями
        P_00 <= 32'h0100_0000;  // 256.0 in Q16.16
        P_01 <= 32'd0;
        P_10 <= 32'd0;
        P_11 <= 32'h0100_0000;  // 256.0 in Q16.16
        
        K_0 <= 32'd0;
        K_1 <= 32'd0;
        
        phase_estimate <= 32'd0;
        frequency_estimate <= 32'd0;
        phase_variance <= 32'h0100_0000;
        freq_variance <= 32'h0100_0000;
        
        estimates_valid <= 1'b0;
        filter_converged <= 1'b0;
        convergence_counter <= 16'd0;
        update_counter <= 16'd0;
        dt <= 32'h0001_0000;  // 1.0 in Q16.16
        
    end else begin
        case (filter_state)
            STATE_INIT: begin
                if (measurement_valid) begin
                    filter_state <= STATE_PREDICT;
                end
            end
            
            STATE_PREDICT: begin
                // Prediction step / Шаг предсказания
                // x_k|k-1 = F * x_k-1|k-1
                // For constant velocity model: phase += freq * dt
                x_phase <= x_phase + fp_mult(x_freq, dt);
                // x_freq stays the same in prediction
                
                // P_k|k-1 = F * P_k-1|k-1 * F' + Q
                // Update covariance matrix
                temp_mult = P_00 + fp_mult(P_01 + P_10, dt) + fp_mult(fp_mult(P_11, dt), dt);
                P_00 <= temp_mult[DATA_WIDTH-1:0] + PROCESS_VARIANCE;
                
                P_01 <= P_01 + fp_mult(P_11, dt);
                P_10 <= P_10 + fp_mult(P_11, dt);
                P_11 <= P_11 + PROCESS_VARIANCE;
                
                filter_state <= STATE_UPDATE;
            end
            
            STATE_UPDATE: begin
                if (measurement_valid) begin
                    // Innovation / Инновация
                    innovation <= phase_measurement - x_phase;
                    
                    // Innovation covariance S = H*P*H' + R
                    S <= P_00 + MEASURE_VARIANCE;
                    
                    // Kalman gain K = P*H'/S
                    K_0 <= fp_mult(P_00, fp_mult(32'h0001_0000, S));  // Division approximation
                    K_1 <= fp_mult(P_10, fp_mult(32'h0001_0000, S));
                    
                    // Update state estimate / Обновление оценки состояния
                    x_phase <= x_phase + fp_mult(K_0, innovation);
                    x_freq <= x_freq + fp_mult(K_1, innovation);
                    
                    // Update covariance / Обновление ковариации
                    // P = (I - K*H)*P
                    P_00 <= fp_mult(32'h0001_0000 - K_0, P_00);
                    P_01 <= fp_mult(32'h0001_0000 - K_0, P_01);
                    P_10 <= P_10 - fp_mult(K_1, P_00);
                    P_11 <= P_11 - fp_mult(K_1, P_01);
                    
                    // Update outputs / Обновление выходов
                    phase_estimate <= x_phase;
                    frequency_estimate <= x_freq;
                    phase_variance <= P_00;
                    freq_variance <= P_11;
                    estimates_valid <= 1'b1;
                    
                    update_counter <= update_counter + 1;
                    
                    // Check convergence / Проверка сходимости
                    if (P_00 < 32'h0000_1000 && P_11 < 32'h0000_1000) begin
                        convergence_counter <= convergence_counter + 1;
                        if (convergence_counter >= 100) begin
                            filter_state <= STATE_CONVERGED;
                            filter_converged <= 1'b1;
                        end
                    end else begin
                        convergence_counter <= 16'd0;
                    end
                    
                    filter_state <= STATE_READY;
                end
            end
            
            STATE_READY: begin
                // Wait for next measurement / Ожидание следующего измерения
                if (measurement_valid) begin
                    filter_state <= STATE_PREDICT;
                end
            end
            
            STATE_CONVERGED: begin
                // Filter has converged, continue normal operation
                if (measurement_valid) begin
                    filter_state <= STATE_PREDICT;
                end
            end
            
            default: begin
                filter_state <= STATE_INIT;
            end
        endcase
    end
end

endmodule