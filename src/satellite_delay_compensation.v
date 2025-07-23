`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: satellite_delay_compensation
// Description: Compensates for satellite signal propagation delay
// 
// This module adjusts the timing reference to account for the propagation
// delay from geostationary satellites (typically 119-120 ms).
//////////////////////////////////////////////////////////////////////////////////

module satellite_delay_compensation (
    input wire clk,                    // System clock (e.g., 100 MHz)
    input wire rst_n,                  // Active-low reset
    
    // Configuration interface
    input wire [31:0] delay_ms,        // Delay compensation in milliseconds (fixed-point: 16.16)
    input wire compensation_enable,    // Enable delay compensation
    
    // Time input
    input wire [63:0] time_in,         // Input timestamp (nanoseconds)
    input wire time_valid_in,          // Input timestamp valid
    
    // Time output
    output reg [63:0] time_out,        // Compensated timestamp (nanoseconds)
    output reg time_valid_out,         // Output timestamp valid
    
    // Status
    output reg compensation_active,    // Compensation is currently active
    output reg [31:0] current_delay    // Current delay value being applied
);

    // Constants
    localparam NS_PER_MS = 32'd1_000_000;  // Nanoseconds per millisecond
    
    // Internal registers
    reg [63:0] delay_ns;               // Delay in nanoseconds
    reg [63:0] time_compensated;       // Compensated time value
    reg compensation_enable_sync;       // Synchronized enable signal
    reg compensation_enable_d;          // Delayed enable for edge detection
    
    // Synchronize enable signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            compensation_enable_sync <= 1'b0;
            compensation_enable_d <= 1'b0;
        end else begin
            compensation_enable_sync <= compensation_enable;
            compensation_enable_d <= compensation_enable_sync;
        end
    end
    
    // Convert delay from milliseconds to nanoseconds
    // delay_ms is in 16.16 fixed-point format
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_ns <= 64'd0;
        end else begin
            // Multiply by 1,000,000 to convert ms to ns
            // Handle fixed-point multiplication
            delay_ns <= (delay_ms * NS_PER_MS) >> 16;
        end
    end
    
    // Apply delay compensation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            time_compensated <= 64'd0;
            time_out <= 64'd0;
            time_valid_out <= 1'b0;
            compensation_active <= 1'b0;
            current_delay <= 32'd0;
        end else begin
            if (time_valid_in) begin
                if (compensation_enable_sync) begin
                    // Apply compensation by subtracting delay
                    if (time_in >= delay_ns) begin
                        time_compensated <= time_in - delay_ns;
                    end else begin
                        // Handle underflow (shouldn't happen in normal operation)
                        time_compensated <= 64'd0;
                    end
                    compensation_active <= 1'b1;
                    current_delay <= delay_ms;
                end else begin
                    // Pass through without compensation
                    time_compensated <= time_in;
                    compensation_active <= 1'b0;
                    current_delay <= 32'd0;
                end
                
                // Output the result
                time_out <= time_compensated;
                time_valid_out <= 1'b1;
            end else begin
                time_valid_out <= 1'b0;
            end
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Module Name: satellite_delay_controller
// Description: UART command interface for satellite delay compensation
//////////////////////////////////////////////////////////////////////////////////

module satellite_delay_controller (
    input wire clk,
    input wire rst_n,
    
    // UART command interface
    input wire [7:0] uart_rx_data,
    input wire uart_rx_valid,
    output reg [7:0] uart_tx_data,
    output reg uart_tx_valid,
    
    // Compensation control
    output reg [31:0] delay_value,     // Delay in ms (16.16 fixed-point)
    output reg compensation_enable,
    
    // Status
    input wire compensation_active,
    input wire [31:0] current_delay
);

    // Command parsing states
    localparam IDLE = 3'd0;
    localparam CMD_PARSE = 3'd1;
    localparam GET_VALUE = 3'd2;
    localparam SEND_RESPONSE = 3'd3;
    
    reg [2:0] state;
    reg [127:0] cmd_buffer;
    reg [7:0] cmd_index;
    reg [31:0] new_delay_value;
    reg [7:0] response_buffer [0:31];
    reg [7:0] response_index;
    reg [7:0] response_length;
    
    // Command definitions
    localparam CMD_SET_DELAY = "SET_SAT_DELAY:";
    localparam CMD_SET_ENABLE = "SET_SAT_DELAY_EN:";
    localparam CMD_GET_DELAY = "GET_SAT_DELAY";
    localparam CMD_GET_ENABLE = "GET_SAT_DELAY_EN";
    
    // Parse incoming commands
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            cmd_index <= 8'd0;
            cmd_buffer <= 128'd0;
            delay_value <= 32'd0;
            compensation_enable <= 1'b0;
            uart_tx_valid <= 1'b0;
            response_index <= 8'd0;
            response_length <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    uart_tx_valid <= 1'b0;
                    if (uart_rx_valid) begin
                        if (uart_rx_data == 8'h0A || uart_rx_data == 8'h0D) begin
                            // End of command, start parsing
                            state <= CMD_PARSE;
                        end else begin
                            // Store command character
                            cmd_buffer[cmd_index*8 +: 8] <= uart_rx_data;
                            cmd_index <= cmd_index + 1;
                        end
                    end
                end
                
                CMD_PARSE: begin
                    // Parse the command
                    if (cmd_buffer[0:103] == CMD_SET_DELAY) begin
                        // Extract delay value
                        state <= GET_VALUE;
                        // Parse floating point value (simplified for example)
                        // In real implementation, use proper string-to-fixed-point conversion
                        new_delay_value <= 32'h01E00000; // Example: 120.0 ms in 16.16 format
                    end else if (cmd_buffer[0:119] == CMD_SET_ENABLE) begin
                        // Extract enable value
                        if (cmd_buffer[120:127] == "1") begin
                            compensation_enable <= 1'b1;
                        end else begin
                            compensation_enable <= 1'b0;
                        end
                        state <= IDLE;
                        cmd_index <= 8'd0;
                        cmd_buffer <= 128'd0;
                    end else if (cmd_buffer[0:103] == CMD_GET_DELAY) begin
                        // Prepare response with current delay
                        state <= SEND_RESPONSE;
                        // Format: "DELAY:120.000\n"
                        // Simplified response generation
                        response_length <= 8'd14;
                        response_index <= 8'd0;
                    end else if (cmd_buffer[0:111] == CMD_GET_ENABLE) begin
                        // Prepare response with enable status
                        state <= SEND_RESPONSE;
                        // Format: "ENABLED:1\n" or "ENABLED:0\n"
                        response_length <= 8'd10;
                        response_index <= 8'd0;
                    end else begin
                        // Unknown command
                        state <= IDLE;
                        cmd_index <= 8'd0;
                        cmd_buffer <= 128'd0;
                    end
                end
                
                GET_VALUE: begin
                    // Apply the new delay value
                    delay_value <= new_delay_value;
                    state <= IDLE;
                    cmd_index <= 8'd0;
                    cmd_buffer <= 128'd0;
                end
                
                SEND_RESPONSE: begin
                    // Send response via UART
                    if (response_index < response_length) begin
                        uart_tx_data <= response_buffer[response_index];
                        uart_tx_valid <= 1'b1;
                        response_index <= response_index + 1;
                    end else begin
                        uart_tx_valid <= 1'b0;
                        state <= IDLE;
                        cmd_index <= 8'd0;
                        cmd_buffer <= 128'd0;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule