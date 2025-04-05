// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: Verilog testbench for VeeRwolf
// Comments:
//
//********************************************************************************

`default_nettype none
module top_tb #(
    parameter bootrom_file = ""
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        i_jtag_tck,
    input  wire        i_jtag_tms,
    input  wire        i_jtag_tdi,
    input  wire        i_jtag_trst_n,
    output wire        o_jtag_tdo,
    output wire        o_uart_tx,
    input  wire [31:0] i_gpio,
    output wire [15:0] o_gpio
);

    localparam RAM_SIZE = 32'h100000;


    reg [1023:0] ram_init_file;

    initial begin
        if (|$test$plusargs("jtag_vpi_enable")) $display("JTAG VPI enabled. Not loading RAM");
        else if ($value$plusargs("ram_init_file=%s", ram_init_file)) begin
            $display("Loading RAM contents from %0s", ram_init_file);
            $readmemh(ram_init_file, ram.mem);
        end
    end

    reg [1023:0] rom_init_file;

    initial begin
        if ($value$plusargs("rom_init_file=%s", rom_init_file)) begin
            $display("Loading ROM contents from %0s", rom_init_file);
            $readmemh(rom_init_file, veerwolf.bootrom.ram.mem);
        end else if (!(|bootrom_file)) begin
            /*
         Set mrac to 0xAAAA0000 and jump to address 0
         if no bootloader is selected
         0:   aaaa02b7                lui     t0,0xaaaa0
         4:   7c029073                csrw    0x7c0,t0
         8:   00000067                jr      zero
         */
            veerwolf.bootrom.ram.mem[0] = 64'h7c029073aaaa02b7;
            veerwolf.bootrom.ram.mem[1] = 64'h0000000000000067;
        end
    end

    wire [63:0] gpio_out;
    assign o_gpio = gpio_out[15:0];


    wire        dmi_reg_en;
    wire [ 6:0] dmi_reg_addr;
    wire        dmi_reg_wr_en;
    wire [31:0] dmi_reg_wdata;
    wire [31:0] dmi_reg_rdata;
    wire        dmi_hard_reset;

    taxi_axi_if #(
        .DATA_W(64),
        .ADDR_W(32),
        .ID_W  (6)
    ) axi_if ();

    taxi_axi_ram #(
        .ADDR_WIDTH(),
        .PIPELINE_OUTPUT(1'b1)
    ) ram (
        .clk     (clk),
        .rst     (rst),
        .s_axi_wr(axi_if.wr_slv),
        .s_axi_rd(axi_if.rd_slv)

    );


    dmi_wrapper i_dmi_wrapper (
        .trst_n        (i_jtag_trst_n),
        .tck           (i_jtag_tck),
        .tms           (i_jtag_tms),
        .tdi           (i_jtag_tdi),
        .tdo           (o_jtag_tdo),
        .tdoEnable     (),
        // Processor Signals
        .core_rst_n    (!rst),
        .core_clk      (clk),
        .jtag_id       (31'd0),
        .rd_data       (dmi_reg_rdata),
        .reg_wr_data   (dmi_reg_wdata),
        .reg_wr_addr   (dmi_reg_addr),
        .reg_en        (dmi_reg_en),
        .reg_wr_en     (dmi_reg_wr_en),
        .dmi_hard_reset(dmi_hard_reset)
    );

    veerwolf_core #(
        .bootrom_file(bootrom_file),
        .clk_freq_hz (32'd50_000_000)
    ) veerwolf (
        .clk             (clk),
        .rstn            (!rst),
        .dmi_reg_rdata   (dmi_reg_rdata),
        .dmi_reg_wdata   (dmi_reg_wdata),
        .dmi_reg_addr    (dmi_reg_addr),
        .dmi_reg_en      (dmi_reg_en),
        .dmi_reg_wr_en   (dmi_reg_wr_en),
        .dmi_hard_reset  (dmi_hard_reset),
        .o_flash_sclk    (),
        .o_flash_cs_n    (),
        .o_flash_mosi    (),
        .i_flash_miso    (1'b0),
        .i_uart_rx       (1'b1),
        .o_uart_tx       (o_uart_tx),
        .o_ram_awid      (axi_if.wr_mst.awid),
        .o_ram_awaddr    (axi_if.wr_mst.awaddr),
        .o_ram_awlen     (axi_if.wr_mst.awlen),
        .o_ram_awsize    (axi_if.wr_mst.awsize),
        .o_ram_awburst   (axi_if.wr_mst.awburst),
        .o_ram_awlock    (axi_if.wr_mst.awlock),
        .o_ram_awcache   (axi_if.wr_mst.awcache),
        .o_ram_awprot    (axi_if.wr_mst.awprot),
        .o_ram_awregion  (axi_if.wr_mst.awregion),
        .o_ram_awqos     (axi_if.wr_mst.awqos),
        .o_ram_awvalid   (axi_if.wr_mst.awvalid),
        .i_ram_awready   (axi_if.wr_mst.awready),
        .o_ram_arid      (axi_if.rd_mst.arid),
        .o_ram_araddr    (axi_if.rd_mst.araddr),
        .o_ram_arlen     (axi_if.rd_mst.arlen),
        .o_ram_arsize    (axi_if.rd_mst.arsize),
        .o_ram_arburst   (axi_if.rd_mst.arburst),
        .o_ram_arlock    (axi_if.rd_mst.arlock),
        .o_ram_arcache   (axi_if.rd_mst.arcache),
        .o_ram_arprot    (axi_if.rd_mst.arprot),
        .o_ram_arregion  (axi_if.rd_mst.arregion),
        .o_ram_arqos     (axi_if.rd_mst.arqos),
        .o_ram_arvalid   (axi_if.rd_mst.arvalid),
        .i_ram_arready   (axi_if.rd_mst.arready),
        .o_ram_wdata     (axi_if.wr_mst.wdata),
        .o_ram_wstrb     (axi_if.wr_mst.wstrb),
        .o_ram_wlast     (axi_if.wr_mst.wlast),
        .o_ram_wvalid    (axi_if.wr_mst.wvalid),
        .i_ram_wready    (axi_if.wr_mst.wready),
        .i_ram_bid       (axi_if.wr_mst.bid),
        .i_ram_bresp     (axi_if.wr_mst.bresp),
        .i_ram_bvalid    (axi_if.wr_mst.bvalid),
        .o_ram_bready    (axi_if.wr_mst.bready),
        .i_ram_rid       (axi_if.rd_mst.rid),
        .i_ram_rdata     (axi_if.rd_mst.rdata),
        .i_ram_rresp     (axi_if.rd_mst.rresp),
        .i_ram_rlast     (axi_if.rd_mst.rlast),
        .i_ram_rvalid    (axi_if.rd_mst.rvalid),
        .o_ram_rready    (axi_if.rd_mst.rready),
        .i_ram_init_done (1'b1),
        .i_ram_init_error(1'b0),
        .i_gpio          ({32'd0, i_gpio}),
        .o_gpio          (gpio_out)
    );

endmodule
