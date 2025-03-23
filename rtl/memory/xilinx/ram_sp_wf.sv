// Single-Port Block RAM Write-First Mode
// File: rams_sp_wf.v
module ram_sp_wf #(
    parameter ADDR_W = 10,
    parameter DATA_W = 16
) (
    input clk,
    input we,
    input en,
    input [ADDR_W-1:0] addr,
    input [DATA_W-1:0] di,
    output logic [DATA_W-1:0] dout

);
    logic [DATA_W-1:0] RAM[0:2**ADDR_W-1];

    always_ff @(posedge clk) begin
        if (en) begin
            if (we) begin
                RAM[addr] <= di;
                dout <= di;
            end else begin
                dout <= RAM[addr];
            end
        end
    end
endmodule

