interface axi4l_if #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32
) (
    input aclk,
    input aresetn
);

    // Read Address
    logic [ADDR_W-1:0] araddr;
    logic [3:0] arcache;
    logic [2:0] arprot;
    logic arvalid;
    logic arready;

    // Read Data
    logic [DATA_W-1:0] rdata;
    logic [1:0] rresp;
    logic rvalid;
    logic rready;

    // Write Address
    logic [ADDR_W-1:0] awaddr;
    logic [3:0] awcache;
    logic [2:0] awprot;
    logic awvalid;
    logic awready;

    // Write Data
    logic [DATA_W-1:0] wdata;
    logic [DATA_W/8-1:0] wstrb;
    logic wvalid;
    logic wready;

    // Write Response
    logic [1:0] bresp;
    logic bvalid;
    logic bready;

    modport master(
        output araddr, arcache, arprot, arvalid,
        input arready,

        output rready,
        input rdata, rresp, rvalid,

        output awaddr, awcache, awprot, awvalid,
        input awready,

        output wdata, wstrb, wvalid,
        input wready,

        input bresp, bvalid,
        output bready
    );

    modport slave(
        input araddr, arcache, arprot, arvalid,
        output arready,

        input rready,
        output rdata, rresp, rvalid,

        input awaddr, awcache, awprot, awvalid,
        output awready,

        input wdata, wstrb, wvalid,
        output wready,

        output bresp, bvalid,
        input bready
    );





endinterface
