// =============================================================================
// Clock Synchronization Module
// =============================================================================
// Description: Synchronizes external clock to system clock domain
// =============================================================================

module clk_sync_module (
    input  wire clk_in,     // Input clock to synchronize
    input  wire clk_out,    // Output clock domain
    output reg  clk_sync    // Synchronized clock signal
);

reg [2:0] sync_reg;

always @(posedge clk_out) begin
    sync_reg <= {sync_reg[1:0], clk_in};
    clk_sync <= sync_reg[2] & ~sync_reg[1];  // Edge detection
end

endmodule

// =============================================================================
// Reset Synchronization Module
// =============================================================================
// Description: Synchronizes reset signal to clock domain
// =============================================================================

module reset_sync_module (
    input  wire clk,
    input  wire rst_n_in,
    output reg  rst_n_out
);

reg [2:0] reset_sync_reg;

always @(posedge clk or negedge rst_n_in) begin
    if (!rst_n_in) begin
        reset_sync_reg <= 3'b000;
        rst_n_out <= 1'b0;
    end else begin
        reset_sync_reg <= {reset_sync_reg[1:0], 1'b1};
        rst_n_out <= reset_sync_reg[2];
    end
end

endmodule


// =============================================================================
// Reset Synchronizer Module (Alternative name)
// =============================================================================
// Description: Alternative name for reset synchronization
// =============================================================================

module reset_synchronizer (
    input  wire clk,
    input  wire async_rst_n,
    output wire sync_rst_n
);

// Use the existing reset_sync_module
reset_sync_module rst_sync_inst (
    .clk        (clk),
    .rst_n_in   (async_rst_n),
    .rst_n_out  (sync_rst_n)
);

endmodule


