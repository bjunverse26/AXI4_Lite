//==============================================================================
// File Name   : AxiRegisterMap.sv
// Project     : AXI4_Lite
// Author      : Beomjun Kim
// Description : Memory-mapped register bank for the AXI4-Lite slave.
// Notes       : Byte strobes are handled in the register layer so the protocol
//               engine can remain focused on channel sequencing.
//==============================================================================

`timescale 1ns / 1ps

module AxiRegisterMap #(
    parameter int DATA_WIDTH = 32,
    parameter int NUM_REGS   = 16
) (
    input  logic                         i_clk,
    input  logic                         i_resetn,

    input  logic [DATA_WIDTH-1:0]        i_reg_wdata,
    input  logic [NUM_REGS-1:0]          i_reg_wen,
    input  logic [DATA_WIDTH/8-1:0]      i_reg_wstrb,
    output logic [DATA_WIDTH-1:0]        o_reg_rdata [NUM_REGS-1:0],

    output logic [DATA_WIDTH-1:0]        o_control_reg,
    input  logic [DATA_WIDTH-1:0]        i_status_reg,
    output logic [DATA_WIDTH-1:0]        o_config_reg,
    input  logic [DATA_WIDTH-1:0]        i_error_reg
);

    localparam int DATA_REG_NUM = 12;
    localparam int BYTE_NUM     = DATA_WIDTH / 8;

    logic [DATA_WIDTH-1:0] r_data_reg [0:DATA_REG_NUM-1];

    integer i;
    integer j;
    integer k;

    always_ff @(posedge i_clk or negedge i_resetn) begin
        if (!i_resetn) begin
            o_control_reg <= '0;
            o_config_reg  <= '0;

            for (i = 0; i < DATA_REG_NUM; i = i + 1) begin
                r_data_reg[i] <= '0;
            end
        end else begin
            if (i_reg_wen[0]) begin
                for (j = 0; j < BYTE_NUM; j = j + 1) begin
                    if (i_reg_wstrb[j]) begin
                        o_control_reg[8*j +: 8] <= i_reg_wdata[8*j +: 8];
                    end
                end
            end

            if (i_reg_wen[2]) begin
                for (j = 0; j < BYTE_NUM; j = j + 1) begin
                    if (i_reg_wstrb[j]) begin
                        o_config_reg[8*j +: 8] <= i_reg_wdata[8*j +: 8];
                    end
                end
            end

            for (i = 0; i < DATA_REG_NUM; i = i + 1) begin
                if (i_reg_wen[i + 4]) begin
                    for (j = 0; j < BYTE_NUM; j = j + 1) begin
                        if (i_reg_wstrb[j]) begin
                            r_data_reg[i][8*j +: 8] <= i_reg_wdata[8*j +: 8];
                        end
                    end
                end
            end
        end
    end

    always_comb begin
        o_reg_rdata[0] = o_control_reg;
        o_reg_rdata[1] = i_status_reg;
        o_reg_rdata[2] = o_config_reg;
        o_reg_rdata[3] = i_error_reg;

        // Registers 4 through 15 are generic data registers reserved for
        // simple read/write expansion.
        for (k = 0; k < DATA_REG_NUM; k = k + 1) begin
            o_reg_rdata[k + 4] = r_data_reg[k];
        end
    end

endmodule
