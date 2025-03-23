// Xilinx Single-Port Block RAM Write-First Mode with Byte Enable
// File: rams_sp_wf.v
module ram_sp_be_wf #(
    parameter ADDR_W = 10,
    parameter DATA_W = 16,
    parameter COL_W  = 8    // write column width ( must be a multiple of 8 or 9 bit)
) (
    input clk,
    input [(DATA_W / COL_W)-1:0] we,
    input en,
    input [ADDR_W-1:0] addr,
    input [DATA_W-1:0] di,
    output logic [DATA_W-1:0] dout

);
    localparam COL_NUM = DATA_W / COL_W;

    // check params
    initial begin
        if ((COL_W % 8) != 0 && (COL_W % 9) != 0) begin
            $error("COL_W must be a multiple of 8-bit or 9-bit");
            $finish();
        end
        if ((DATA_W % COL_W) != 0) begin
            $error("DATA_W must be a multiple of COL_W");
            $finish();
        end
    end

    logic [DATA_W-1:0] RAM[0:2**ADDR_W-1];

    always_ff @(posedge clk) begin
        if (en) begin
            for (int i = 0; i < COL_NUM; i++) begin
                if (we[i]) begin
                    RAM[addr][i*COL_W+:COL_W] <= di[i*COL_W+:COL_W];
                end
            end
            dout <= RAM[addr];
        end
    end
endmodule

