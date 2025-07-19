// =============================================================================
// Synchronization Modules
// Модули синхронизации
// =============================================================================
// Description: Various synchronization modules for clock domain crossing
// Описание: Различные модули синхронизации для пересечения тактовых доменов
// =============================================================================

// =============================================================================
// Reset Synchronizer
// Синхронизатор сброса
// =============================================================================
module reset_synchronizer (
    input  wire clk,            // Target clock / Целевая тактовая частота
    input  wire async_rst_n,    // Asynchronous reset input / Асинхронный вход сброса
    output wire sync_rst_n      // Synchronized reset output / Синхронизированный выход сброса
);

    // Синхронизация сброса через два триггера для предотвращения метастабильности
    reg rst_sync1, rst_sync2;
    
    always @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            // Асинхронный сброс обоих триггеров
            rst_sync1 <= 1'b0;
            rst_sync2 <= 1'b0;
        end else begin
            // Синхронная цепочка
            rst_sync1 <= 1'b1;
            rst_sync2 <= rst_sync1;
        end
    end
    
    assign sync_rst_n = rst_sync2;
    
endmodule

// =============================================================================
// Clock Domain Crossing Synchronizer
// Синхронизатор пересечения тактовых доменов
// =============================================================================
module cdc_synchronizer #(
    parameter WIDTH = 1  // Data width / Ширина данных
)(
    input  wire             src_clk,    // Source clock / Исходная тактовая частота
    input  wire             dst_clk,    // Destination clock / Целевая тактовая частота
    input  wire             rst_n,      // Reset / Сброс
    input  wire [WIDTH-1:0] data_in,    // Input data / Входные данные
    output reg  [WIDTH-1:0] data_out    // Synchronized output / Синхронизированный выход
);

    // Двухступенчатая синхронизация для предотвращения метастабильности
    reg [WIDTH-1:0] sync_stage1;
    reg [WIDTH-1:0] sync_stage2;
    
    always @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_stage1 <= {WIDTH{1'b0}};
            sync_stage2 <= {WIDTH{1'b0}};
            data_out <= {WIDTH{1'b0}};
        end else begin
            // Трехступенчатая синхронизация для надежности
            sync_stage1 <= data_in;
            sync_stage2 <= sync_stage1;
            data_out <= sync_stage2;
        end
    end
    
endmodule


