//==============================================================================
// File Name   : AxiLiteSlave.sv
// Project     : AXI4_Lite
// Author      : Beomjun Kim
// Description : AXI4-Lite slave protocol engine with independent read and write
//               control paths.
// Notes       : AW and W channels may arrive in either order, so address and data
//               are latched before issuing a one-hot register write pulse.
//==============================================================================

`timescale 1ns / 1ps

module AxiLiteSlave #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
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

    input  logic                         i_s_axi_bready,
    output logic [1:0]                   o_s_axi_bresp,
    output logic                         o_s_axi_bvalid,

    input  logic [ADDR_WIDTH-1:0]        i_s_axi_araddr,
    input  logic                         i_s_axi_arvalid,
    output logic                         o_s_axi_arready,

    input  logic                         i_s_axi_rready,
    output logic [DATA_WIDTH-1:0]        o_s_axi_rdata,
    output logic [1:0]                   o_s_axi_rresp,
    output logic                         o_s_axi_rvalid,

    output logic [DATA_WIDTH-1:0]        o_reg_wdata,
    output logic [NUM_REGS-1:0]          o_reg_wen,
    output logic [DATA_WIDTH/8-1:0]      o_reg_wstrb,
    input  logic [DATA_WIDTH-1:0]        i_reg_rdata [NUM_REGS-1:0]
);

    typedef enum logic [1:0] {
        W_IDLE,
        W_WAIT_DATA,
        W_WAIT_ADDR,
        W_RESP
    } write_state_t;

    typedef enum logic {
        R_IDLE,
        R_RESP
    } read_state_t;

    localparam logic [1:0] RESP_OKAY = 2'b00;

    write_state_t r_write_state;
    read_state_t  r_read_state;

    logic                         w_aw_handshake;
    logic                         w_w_handshake;
    logic                         w_b_handshake;
    logic                         w_ar_handshake;
    logic                         w_r_handshake;

    logic [7:0]                   r_awaddr_latched;
    logic [DATA_WIDTH-1:0]        r_wdata_latched;
    logic [DATA_WIDTH/8-1:0]      r_wstrb_latched;

    assign w_aw_handshake = i_s_axi_awvalid && o_s_axi_awready;
    assign w_w_handshake  = i_s_axi_wvalid  && o_s_axi_wready;
    assign w_b_handshake  = o_s_axi_bvalid  && i_s_axi_bready;
    assign w_ar_handshake = i_s_axi_arvalid && o_s_axi_arready;
    assign w_r_handshake  = o_s_axi_rvalid  && i_s_axi_rready;

    always_ff @(posedge i_aclk or negedge i_aresetn) begin
        if (!i_aresetn) begin
            r_write_state  <= W_IDLE;
            o_s_axi_awready <= 1'b0;
            o_s_axi_wready  <= 1'b0;
            o_s_axi_bresp   <= RESP_OKAY;
            o_s_axi_bvalid  <= 1'b0;
            o_reg_wen       <= '0;
            o_reg_wdata     <= '0;
            o_reg_wstrb     <= '0;
            r_awaddr_latched <= '0;
            r_wdata_latched  <= '0;
            r_wstrb_latched  <= '0;
        end else begin
            o_reg_wen <= '0;

            case (r_write_state)
                W_IDLE: begin
                    o_s_axi_awready <= 1'b1;
                    o_s_axi_wready  <= 1'b1;

                    if (w_aw_handshake && w_w_handshake) begin
                        o_s_axi_awready <= 1'b0;
                        o_s_axi_wready  <= 1'b0;
                        o_reg_wdata     <= i_s_axi_wdata;
                        o_reg_wstrb     <= i_s_axi_wstrb;
                        o_s_axi_bresp   <= RESP_OKAY;
                        o_s_axi_bvalid  <= 1'b1;
                        r_write_state   <= W_RESP;

                        if (i_s_axi_awaddr[9:2] < NUM_REGS) begin
                            o_reg_wen[i_s_axi_awaddr[9:2]] <= 1'b1;
                        end
                    end else if (w_aw_handshake) begin
                        o_s_axi_awready <= 1'b0;
                        r_awaddr_latched <= i_s_axi_awaddr[9:2];
                        r_write_state   <= W_WAIT_DATA;
                    end else if (w_w_handshake) begin
                        o_s_axi_wready <= 1'b0;
                        r_wdata_latched <= i_s_axi_wdata;
                        r_wstrb_latched <= i_s_axi_wstrb;
                        r_write_state  <= W_WAIT_ADDR;
                    end
                end

                W_WAIT_DATA: begin
                    if (w_w_handshake) begin
                        o_s_axi_wready <= 1'b0;
                        o_reg_wdata    <= i_s_axi_wdata;
                        o_reg_wstrb    <= i_s_axi_wstrb;
                        o_s_axi_bresp  <= RESP_OKAY;
                        o_s_axi_bvalid <= 1'b1;
                        r_write_state  <= W_RESP;

                        if (r_awaddr_latched < NUM_REGS) begin
                            o_reg_wen[r_awaddr_latched] <= 1'b1;
                        end
                    end
                end

                W_WAIT_ADDR: begin
                    if (w_aw_handshake) begin
                        o_s_axi_awready <= 1'b0;
                        o_reg_wdata     <= r_wdata_latched;
                        o_reg_wstrb     <= r_wstrb_latched;
                        o_s_axi_bresp   <= RESP_OKAY;
                        o_s_axi_bvalid  <= 1'b1;
                        r_write_state   <= W_RESP;

                        if (i_s_axi_awaddr[9:2] < NUM_REGS) begin
                            o_reg_wen[i_s_axi_awaddr[9:2]] <= 1'b1;
                        end
                    end
                end

                W_RESP: begin
                    // Keep BVALID asserted until BREADY so response backpressure
                    // cannot drop the write completion indication.
                    if (w_b_handshake) begin
                        o_s_axi_bvalid <= 1'b0;
                        r_write_state  <= W_IDLE;
                    end
                end

                default: begin
                    r_write_state <= W_IDLE;
                end
            endcase
        end
    end

    always_ff @(posedge i_aclk or negedge i_aresetn) begin
        if (!i_aresetn) begin
            r_read_state   <= R_IDLE;
            o_s_axi_arready <= 1'b0;
            o_s_axi_rdata   <= '0;
            o_s_axi_rresp   <= RESP_OKAY;
            o_s_axi_rvalid  <= 1'b0;
        end else begin
            case (r_read_state)
                R_IDLE: begin
                    o_s_axi_arready <= 1'b1;

                    if (w_ar_handshake) begin
                        o_s_axi_arready <= 1'b0;
                        o_s_axi_rresp   <= RESP_OKAY;
                        o_s_axi_rvalid  <= 1'b1;
                        r_read_state    <= R_RESP;

                        if (i_s_axi_araddr[9:2] < NUM_REGS) begin
                            o_s_axi_rdata <= i_reg_rdata[i_s_axi_araddr[9:2]];
                        end else begin
                            o_s_axi_rdata <= 32'hDEAD_BEEF;
                        end
                    end
                end

                R_RESP: begin
                    if (w_r_handshake) begin
                        o_s_axi_rvalid <= 1'b0;
                        r_read_state   <= R_IDLE;
                    end
                end

                default: begin
                    r_read_state <= R_IDLE;
                end
            endcase
        end
    end

endmodule
