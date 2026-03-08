module axi_lite_slave #(
    parameter int                   ADDR_WIDTH = 32,
    parameter int                   DATA_WIDTH = 32,
    parameter int                   NUM_REGS = 16
)(
    input logic                     aclk,
    input logic                     aresetn,

    // (AW) Address Write Channel
    input logic [ADDR_WIDTH-1:0]    s_axi_awaddr,
    input logic                     s_axi_awvalid,
    output logic                    s_axi_awready,

    // (W) Write Data Channel
    input logic [DATA_WIDTH-1:0]    s_axi_wdata,
    input logic [DATA_WIDTH/8-1:0]  s_axi_wstrb,
    input logic                     s_axi_wvalid,
    output logic                    s_axi_wready,

    // (B) Response Channel
    input logic                     s_axi_bready,
    output logic [1:0]              s_axi_bresp,
    output logic                    s_axi_bvalid,

    // (AR) Address Read Channel
    input logic [ADDR_WIDTH-1:0]    s_axi_araddr,
    input logic                     s_axi_arvalid,
    output logic                    s_axi_arready,

    // (R) Read Data Channel
    input logic                     s_axi_rready,
    output logic [DATA_WIDTH-1:0]   s_axi_rdata,
    output logic [1:0]              s_axi_rresp,
    output logic                    s_axi_rvalid,

    // Register Interface
    output logic [DATA_WIDTH-1:0]   reg_wdata,
    output logic [NUM_REGS-1:0]     reg_wen,
    output logic [DATA_WIDTH/8-1:0] reg_wstrb,
    input logic [DATA_WIDTH-1:0]    reg_rdata [NUM_REGS-1:0]
);

    // Write Transaction FSM
    localparam W_IDLE = 2'b00;
    localparam W_WRITE = 2'b01;
    localparam W_ADDR = 2'b10;
    localparam W_DONE = 2'b11;

    logic [1:0] current_wstate;

    logic aw_handshake;
    logic w_handshake;
    logic b_handshake;
    assign aw_handshake = s_axi_awvalid && s_axi_awready;
    assign w_handshake = s_axi_wvalid && s_axi_wready;
    assign b_handshake = s_axi_bvalid && s_axi_bready;

    logic [7:0] waddr_latched;
    logic [DATA_WIDTH-1:0] wdata_latched;
    logic [DATA_WIDTH/8-1:0] wstrb_latched;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            current_wstate <= W_IDLE;
            s_axi_awready <= 1'b0;
            s_axi_wready <= 1'b0;
            s_axi_bresp <= 2'b00;
            s_axi_bvalid <= 1'b0;

            reg_wen <= '0;
            reg_wdata <= '0;

            waddr_latched <= '0;
        end else begin
            case (current_wstate)
                W_IDLE: begin
                    reg_wen <= {NUM_REGS{1'b0}};
                    s_axi_awready <= 1'b1;
                    s_axi_wready <= 1'b1;
                    
                    if (aw_handshake && !w_handshake) begin
                        s_axi_awready <= 1'b0;
                        waddr_latched <= s_axi_awaddr[9:2];
                        current_wstate <= W_WRITE;
                    end else if (w_handshake && !aw_handshake) begin
                        s_axi_wready <= 1'b0;
                        wdata_latched <= s_axi_wdata;
                        wstrb_latched <= s_axi_wstrb;
                        current_wstate <= W_ADDR;
                    end else if (aw_handshake && w_handshake) begin
                        s_axi_awready <= 1'b0;
                        s_axi_wready <= 1'b0;
                        if (s_axi_awaddr[9:2] < NUM_REGS) begin
                            reg_wen[s_axi_awaddr[9:2]] <= 1'b1;
                            reg_wdata <= s_axi_wdata;
                            reg_wstrb <= s_axi_wstrb;
                        end
                        current_wstate <= W_DONE;
                        s_axi_bresp <= 2'b00;
                        s_axi_bvalid <= 1'b1;
                    end                        
                end

                // Case 1: ADDR -> WRITE
                W_WRITE: begin
                    if (w_handshake) begin
                        s_axi_wready <= 1'b0;
                        reg_wdata <= s_axi_wdata;
                        reg_wstrb <= s_axi_wstrb;
                        current_wstate <= W_DONE;
                        s_axi_bresp <= 2'b00;
                        s_axi_bvalid <= 1'b1;
                        if (waddr_latched < NUM_REGS) reg_wen[waddr_latched] <= 1'b1;
                    end
                end

                // Case 2: WRITE -> ADDR
                W_ADDR: begin
                    if (aw_handshake) begin
                        s_axi_awready <= 1'b0;
                        reg_wdata <= wdata_latched;
                        reg_wstrb <= wstrb_latched;
                        current_wstate <= W_DONE;
                        s_axi_bresp <= 2'b00;
                        s_axi_bvalid <= 1'b1;
                        if (s_axi_awaddr[9:2] < NUM_REGS) reg_wen[s_axi_awaddr[9:2]] <= 1'b1;
                    end
                end
                        
                W_DONE: begin
                    reg_wen <= {NUM_REGS{1'b0}};
                    
                    if (b_handshake) begin
                        s_axi_bvalid <= 1'b0;
                        current_wstate <= W_IDLE;
                    end
                end

            endcase
        end
    end

    // Read Transaction FSM
    localparam R_IDLE = 1'b0;
    localparam R_DONE = 1'b1;

    logic current_rstate;

    logic ar_handshake;
    logic r_handshake;

    assign ar_handshake = s_axi_arvalid && s_axi_arready;
    assign r_handshake = s_axi_rvalid && s_axi_rready;
    
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            current_rstate <= R_IDLE;
            s_axi_arready <= 1'b0;
            s_axi_rdata <= 'b0;
            s_axi_rvalid <= 1'b0;
            s_axi_rresp <= 2'b00;
        end else begin
            case (current_rstate)
                R_IDLE: begin
                    s_axi_arready <= 1'b1;
                    
                    if (ar_handshake) begin
                        s_axi_arready <= 1'b0;
                        current_rstate <= R_DONE;
                        s_axi_rvalid <= 1'b1;
                        s_axi_rresp <= 2'b00;
                        if (s_axi_araddr[9:2] < NUM_REGS) begin
                            s_axi_rdata <= reg_rdata[s_axi_araddr[9:2]];
                        end else begin
                            s_axi_rdata <= 32'hDEADBEEF;
                        end
                    end
                end

                R_DONE: begin
                    if (r_handshake) begin
                        current_rstate <= R_IDLE;
                        s_axi_rvalid <= 1'b0;
                    end
                end
                
            endcase
        end
    end
                    
endmodule