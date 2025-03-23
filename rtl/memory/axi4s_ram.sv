module axi4s_ram (
    axi4l_if axi4l
);

    assign rst_n = axi4l.aresetn;

    typedef enum logic [1:0] {
        IDLE,
        READ,
        WRITE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge axi4l.aclk) begin : state_logic
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    assign ar_ack = axi4l.arvalid && axi4l.arready;

    always_ff @(posedge axi4l.aclk) begin
        if (!rst_n) begin
            axi4l.arready <= 0;
            axi4l.rvalid <= 0;
            axi4l.bvalid <= 0;

        end else begin

            axi4l.arready <= (state == IDLE) ? 1 : 0;
            axi4l.rvalid <= (state == READ) ? 1 : 0;


        end
    end

    // RAM interface
    logic [$bits(axi4l.wstrb)-1:0] ram_we;
    logic ram_en;
    logic [axi4l.ADDR_W-1:0] ram_addr;
    logic [axi4l.DATA_W-1:0] ram_di;
    logic [axi4l.DATA_W-1:0] ram_dout;

    always_comb begin : state_transition
        next_state = state;
        case (state)
            IDLE: begin
                if (ar_ack) begin
                    next_state = READ;
                end
                if (axi4l.awvalid) begin
                    next_state = WRITE;
                end
            end
            READ: begin
                if (axi4l.rready) begin
                    next_state = IDLE;
                end
            end
            WRITE: begin
                if (axi4l.bvalid) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_comb begin : output_logic
        case (state)
            IDLE: begin
                ram_en   <= 0;
                ram_we   <= 0;
                ram_addr <= 0;
                ram_di   <= 0;
            end
            READ: begin
                ram_we   <= 0;
                ram_en   <= 1;
                ram_addr <= axi4l.araddr;
                ram_di   <= 0;
            end
            WRITE: begin
                ram_we   <= axi4l.wstrb;
                ram_en   <= 1;
                ram_addr <= axi4l.awaddr;
                ram_di   <= axi4l.wdata;
            end

            default: begin
                ram_we   <= 0;
                ram_en   <= 0;
                ram_addr <= 0;
                ram_di   <= 0;
            end
        endcase
    end

    ram_sp_be_wf #(
        .ADDR_W(axi4l.ADDR_W),
        .DATA_W(axi4l.DATA_W),
        .COL_W ($bits(axi4l.wstrb))
    ) i_ram_sp_wf (
        .clk (axi4l.aclk),
        .we  (ram_we),
        .en  (ram_en),
        .addr(ram_addr),
        .di  (ram_di),
        .dout(ram_dout)
    );
endmodule
