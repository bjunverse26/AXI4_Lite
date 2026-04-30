//==============================================================================
// File Name   : AxiTop.sv
// Project     : AXI4_Lite
// Author      : Beomjun Kim
// Description : Top-level integration of the AXI4-Lite slave protocol engine and
//               register map.
// Notes       : Protocol handling and register storage are split to keep
//               verification ownership clear and future register growth local.
//==============================================================================

`timescale 1ns / 1ps

module AxiTop #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32,
    parameter int NUM_REGS   = 16
) (
    input  logic                         i_aclk,
    input  logic                         i_aresetn,

    input  logic [ADDR_WIDTH-1:0]        i_s_axi_awaddr,
    input  logic                         i_s_axi_awvalid,
    output logic                         o_s_axi_awready,

    input  logic [DATA_WIDTH-1:0]        i_s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0]      i_s_axi_wstrb,
    input  logic                         i_s_axi_wvalid,
    output logic                         o_s_axi_wready,

    output logic [1:0]                   o_s_axi_bresp,
    output logic                         o_s_axi_bvalid,
    input  logic                         i_s_axi_bready,

    input  logic [ADDR_WIDTH-1:0]        i_s_axi_araddr,
    input  logic                         i_s_axi_arvalid,
    output logic                         o_s_axi_arready,

    output logic [DATA_WIDTH-1:0]        o_s_axi_rdata,
    output logic                         o_s_axi_rvalid,
    output logic [1:0]                   o_s_axi_rresp,
    input  logic                         i_s_axi_rready
);

    logic [DATA_WIDTH-1:0]   w_reg_wdata;
    logic [NUM_REGS-1:0]     w_reg_wen;
    logic [DATA_WIDTH/8-1:0] w_reg_wstrb;
    logic [DATA_WIDTH-1:0]   w_reg_rdata [NUM_REGS-1:0];

    logic [DATA_WIDTH-1:0]   w_control_reg;
    logic [DATA_WIDTH-1:0]   w_config_reg;

    AxiLiteSlave #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .NUM_REGS   (NUM_REGS)
    ) u_axi_lite_slave (
        .i_aclk          (i_aclk),
        .i_aresetn       (i_aresetn),
        .i_s_axi_awaddr  (i_s_axi_awaddr),
        .i_s_axi_awvalid (i_s_axi_awvalid),
        .o_s_axi_awready (o_s_axi_awready),
        .i_s_axi_wdata   (i_s_axi_wdata),
        .i_s_axi_wstrb   (i_s_axi_wstrb),
        .i_s_axi_wvalid  (i_s_axi_wvalid),
        .o_s_axi_wready  (o_s_axi_wready),
        .i_s_axi_bready  (i_s_axi_bready),
        .o_s_axi_bresp   (o_s_axi_bresp),
        .o_s_axi_bvalid  (o_s_axi_bvalid),
        .i_s_axi_araddr  (i_s_axi_araddr),
        .i_s_axi_arvalid (i_s_axi_arvalid),
        .o_s_axi_arready (o_s_axi_arready),
        .i_s_axi_rready  (i_s_axi_rready),
        .o_s_axi_rdata   (o_s_axi_rdata),
        .o_s_axi_rresp   (o_s_axi_rresp),
        .o_s_axi_rvalid  (o_s_axi_rvalid),
        .o_reg_wdata     (w_reg_wdata),
        .o_reg_wen       (w_reg_wen),
        .o_reg_wstrb     (w_reg_wstrb),
        .i_reg_rdata     (w_reg_rdata)
    );

    AxiRegisterMap #(
        .DATA_WIDTH (DATA_WIDTH),
        .NUM_REGS   (NUM_REGS)
    ) u_axi_register_map (
        .i_clk         (i_aclk),
        .i_resetn      (i_aresetn),
        .i_reg_wdata   (w_reg_wdata),
        .i_reg_wen     (w_reg_wen),
        .i_reg_wstrb   (w_reg_wstrb),
        .o_reg_rdata   (w_reg_rdata),
        .o_control_reg (w_control_reg),
        .i_status_reg  (32'hABCD_1234),
        .o_config_reg  (w_config_reg),
        .i_error_reg   (32'h0000_0000)
    );

endmodule
