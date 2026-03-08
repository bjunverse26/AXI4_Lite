module axi_top #(
    parameter int                       DATA_WIDTH = 32,
    parameter int                       ADDR_WIDTH = 32,
    parameter int                       NUM_REGS = 16
)(
    input logic                         aclk,
    input logic                         aresetn,

    // AW Channel
    input logic [ADDR_WIDTH-1:0]        s_axi_awaddr,
    input logic                         s_axi_awvalid,
    output logic                        s_axi_awready,

    // W Channel
    input logic [DATA_WIDTH-1:0]        s_axi_wdata,
    input logic [DATA_WIDTH/8-1:0]      s_axi_wstrb,
    input logic                         s_axi_wvalid,
    output logic                        s_axi_wready,

    // B Channel
    output logic [1:0]                  s_axi_bresp,
    output logic                        s_axi_bvalid,
    input logic                         s_axi_bready,

    // AR Channel
    input logic [ADDR_WIDTH-1:0]        s_axi_araddr,
    input logic                         s_axi_arvalid,
    output logic                        s_axi_arready,
    
    // R Channel
    output logic [DATA_WIDTH-1:0]       s_axi_rdata,
    output logic                        s_axi_rvalid,
    output logic [1:0]                  s_axi_rresp,
    input logic                         s_axi_rready
);

    logic [DATA_WIDTH-1:0] reg_wdata;
    logic [NUM_REGS-1:0] reg_wen;
    logic [DATA_WIDTH/8-1:0] reg_wstrb;
    logic [DATA_WIDTH-1:0] reg_rdata [NUM_REGS-1:0];

    logic [DATA_WIDTH-1:0] control_reg;
    logic [DATA_WIDTH-1:0] status_reg;
    logic [DATA_WIDTH-1:0] config_reg;
    logic [DATA_WIDTH-1:0] error_reg;

    // module 1: axi-lite-slave
    axi_lite_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) u_axi_slave (
        .aclk(aclk),
        .aresetn(aresetn),

        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),

        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        .s_axi_rready(s_axi_rready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),

        .reg_wdata(reg_wdata),
        .reg_wen(reg_wen),
        .reg_wstrb(reg_wstrb),
        .reg_rdata(reg_rdata)
    );

    // module 2: axi_register_map
    axi_register_map #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) u_register_map (
        .clk(aclk),
        .resetn(aresetn),

        .reg_wdata(reg_wdata),
        .reg_wen(reg_wen),
        .reg_wstrb(reg_wstrb),
        .reg_rdata(reg_rdata),

        .control_reg(control_reg),
        .status_reg(status_reg),
        .config_reg(config_reg),
        .error_reg(error_reg)
    );

endmodule
