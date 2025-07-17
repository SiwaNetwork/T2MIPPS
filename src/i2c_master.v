// =============================================================================
// I2C Master Controller for SiT5503 Oscillator
// =============================================================================
// Description: I2C master controller for communicating with SiT5503 
//              programmable oscillator. Supports standard and fast mode.
// Author: Manus AI
// Date: June 6, 2025
// =============================================================================

module i2c_master (
    // Clock and Reset
    input  wire        clk,              // System clock (100 MHz)
    input  wire        rst_n,            // Active low reset
    
    // I2C Physical Interface
    output reg         scl,              // I2C clock line
    inout  wire        sda,              // I2C data line (bidirectional)
    
    // Control Interface
    input  wire        start,            // Start transaction
    input  wire        stop,             // Stop transaction
    input  wire [6:0]  device_addr,      // 7-bit device address
    input  wire        rw_bit,           // Read(1)/Write(0) bit
    input  wire [7:0]  write_data,       // Data to write
    input  wire        write_valid,      // Write data valid
    output reg  [7:0]  read_data,        // Data read from slave
    output reg         read_valid,       // Read data valid
    output reg         ack_received,     // ACK received from slave
    output reg         busy,             // Transaction in progress
    output reg         error             // Error flag
);

// =============================================================================
// Parameters
// =============================================================================

// I2C timing parameters for 100 kHz (standard mode)
parameter CLK_FREQ_HZ = 100_000_000;    // 100 MHz system clock
parameter I2C_FREQ_HZ = 100_000;        // 100 kHz I2C clock
parameter CLK_DIVIDER = CLK_FREQ_HZ / (4 * I2C_FREQ_HZ); // Quarter period

// State machine states
localparam [3:0] IDLE       = 4'h0,
                 START      = 4'h1,
                 ADDR_SEND  = 4'h2,
                 ADDR_ACK   = 4'h3,
                 DATA_SEND  = 4'h4,
                 DATA_ACK   = 4'h5,
                 DATA_READ  = 4'h6,
                 DATA_NACK  = 4'h7,
                 STOP_COND  = 4'h8,
                 ERROR_ST   = 4'h9;

// =============================================================================
// Internal Signals
// =============================================================================

reg [3:0]   state;
reg [3:0]   next_state;
reg [15:0]  clk_counter;
reg [2:0]   bit_counter;
reg [7:0]   shift_reg;
reg         sda_out;
reg         sda_oe;        // SDA output enable
reg         scl_enable;
reg [7:0]   addr_byte;

// Clock generation signals
reg         clk_tick;
reg [1:0]   clk_phase;     // 0=low, 1=setup, 2=high, 3=hold

// =============================================================================
// I2C Clock Generation
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_counter <= 16'h0;
        clk_tick <= 1'b0;
        clk_phase <= 2'b00;
    end else begin
        clk_tick <= 1'b0;
        
        if (clk_counter >= CLK_DIVIDER - 1) begin
            clk_counter <= 16'h0;
            clk_tick <= 1'b1;
            clk_phase <= clk_phase + 1;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end
end

// Generate SCL
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scl <= 1'b1;
    end else begin
        if (scl_enable) begin
            case (clk_phase)
                2'b00, 2'b01: scl <= 1'b0;  // Low phase
                2'b10, 2'b11: scl <= 1'b1;  // High phase
            endcase
        end else begin
            scl <= 1'b1;  // Idle high
        end
    end
end

// =============================================================================
// SDA Bidirectional Control
// =============================================================================

assign sda = sda_oe ? sda_out : 1'bz;

// =============================================================================
// Main State Machine
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        IDLE: begin
            if (start) begin
                next_state = START;
            end
        end
        
        START: begin
            if (clk_tick && clk_phase == 2'b11) begin
                next_state = ADDR_SEND;
            end
        end
        
        ADDR_SEND: begin
            if (clk_tick && clk_phase == 2'b11) begin
                if (bit_counter == 3'h7) begin
                    next_state = ADDR_ACK;
                end
            end
        end
        
        ADDR_ACK: begin
            if (clk_tick && clk_phase == 2'b11) begin
                if (!sda) begin  // ACK received
                    if (rw_bit) begin
                        next_state = DATA_READ;
                    end else begin
                        next_state = DATA_SEND;
                    end
                end else begin
                    next_state = ERROR_ST;
                end
            end
        end
        
        DATA_SEND: begin
            if (clk_tick && clk_phase == 2'b11) begin
                if (bit_counter == 3'h7) begin
                    next_state = DATA_ACK;
                end
            end
        end
        
        DATA_ACK: begin
            if (clk_tick && clk_phase == 2'b11) begin
                if (stop) begin
                    next_state = STOP_COND;
                end else begin
                    next_state = IDLE;
                end
            end
        end
        
        DATA_READ: begin
            if (clk_tick && clk_phase == 2'b11) begin
                if (bit_counter == 3'h7) begin
                    next_state = DATA_NACK;
                end
            end
        end
        
        DATA_NACK: begin
            if (clk_tick && clk_phase == 2'b11) begin
                next_state = STOP_COND;
            end
        end
        
        STOP_COND: begin
            if (clk_tick && clk_phase == 2'b11) begin
                next_state = IDLE;
            end
        end
        
        ERROR_ST: begin
            if (stop) begin
                next_state = STOP_COND;
            end
        end
        
        default: next_state = IDLE;
    endcase
end

// =============================================================================
// Control Logic
// =============================================================================

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sda_out <= 1'b1;
        sda_oe <= 1'b0;
        scl_enable <= 1'b0;
        bit_counter <= 3'h0;
        shift_reg <= 8'h00;
        addr_byte <= 8'h00;
        read_data <= 8'h00;
        read_valid <= 1'b0;
        ack_received <= 1'b0;
        busy <= 1'b0;
        error <= 1'b0;
    end else begin
        read_valid <= 1'b0;  // Pulse signal
        
        case (state)
            IDLE: begin
                sda_out <= 1'b1;
                sda_oe <= 1'b0;
                scl_enable <= 1'b0;
                bit_counter <= 3'h0;
                busy <= 1'b0;
                error <= 1'b0;
                
                if (start) begin
                    addr_byte <= {device_addr, rw_bit};
                    shift_reg <= write_data;
                    busy <= 1'b1;
                end
            end
            
            START: begin
                scl_enable <= 1'b1;
                sda_oe <= 1'b1;
                
                case (clk_phase)
                    2'b00: sda_out <= 1'b1;  // SDA high
                    2'b01: sda_out <= 1'b0;  // SDA low (start condition)
                    2'b10: sda_out <= 1'b0;  // Hold low
                    2'b11: begin
                        sda_out <= addr_byte[7];  // First bit
                        shift_reg <= {addr_byte[6:0], 1'b0};
                        bit_counter <= 3'h0;
                    end
                endcase
            end
            
            ADDR_SEND: begin
                if (clk_tick) begin
                    case (clk_phase)
                        2'b01: sda_out <= shift_reg[7];  // Setup data
                        2'b11: begin
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            bit_counter <= bit_counter + 1;
                        end
                    endcase
                end
            end
            
            ADDR_ACK: begin
                sda_oe <= 1'b0;  // Release SDA for ACK
                if (clk_tick && clk_phase == 2'b11) begin
                    ack_received <= !sda;
                    if (!sda) begin
                        if (!rw_bit) begin
                            shift_reg <= write_data;
                            bit_counter <= 3'h0;
                        end
                    end else begin
                        error <= 1'b1;
                    end
                end
            end
            
            DATA_SEND: begin
                sda_oe <= 1'b1;
                if (clk_tick) begin
                    case (clk_phase)
                        2'b01: sda_out <= shift_reg[7];  // Setup data
                        2'b11: begin
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            bit_counter <= bit_counter + 1;
                        end
                    endcase
                end
            end
            
            DATA_ACK: begin
                sda_oe <= 1'b0;  // Release SDA for ACK
                if (clk_tick && clk_phase == 2'b11) begin
                    ack_received <= !sda;
                end
            end
            
            DATA_READ: begin
                sda_oe <= 1'b0;  // Release SDA for reading
                if (clk_tick && clk_phase == 2'b10) begin  // Sample on high
                    shift_reg <= {shift_reg[6:0], sda};
                    bit_counter <= bit_counter + 1;
                    
                    if (bit_counter == 3'h7) begin
                        read_data <= {shift_reg[6:0], sda};
                        read_valid <= 1'b1;
                    end
                end
            end
            
            DATA_NACK: begin
                sda_oe <= 1'b1;
                sda_out <= 1'b1;  // Send NACK
            end
            
            STOP_COND: begin
                sda_oe <= 1'b1;
                case (clk_phase)
                    2'b00: sda_out <= 1'b0;  // SDA low
                    2'b01: sda_out <= 1'b0;  // Hold low
                    2'b10: sda_out <= 1'b1;  // SDA high (stop condition)
                    2'b11: begin
                        sda_oe <= 1'b0;
                        scl_enable <= 1'b0;
                    end
                endcase
            end
            
            ERROR_ST: begin
                error <= 1'b1;
                sda_oe <= 1'b0;
            end
        endcase
    end
end

endmodule

