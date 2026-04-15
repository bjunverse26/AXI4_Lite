module axi_register_map #(
    parameter                       DATA_WIDTH = 32,
    parameter                       NUM_REGS = 16
)(
    input logic                     clk,
    input logic                     resetn,

    input logic [DATA_WIDTH-1:0]    reg_wdata,
    input logic [NUM_REGS-1:0]      reg_wen,
    input logic [DATA_WIDTH/8-1:0]  reg_wstrb,
    output logic [DATA_WIDTH-1:0]   reg_rdata [NUM_REGS-1:0],

    output logic [DATA_WIDTH-1:0]   control_reg,
    input logic [DATA_WIDTH-1:0]    status_reg,
    output logic [DATA_WIDTH-1:0]   config_reg,
    input logic [DATA_WIDTH-1:0]    error_reg
);

    logic [DATA_WIDTH-1:0]              data_reg [11:0];
    integer i, j, k;

    // WRITE
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            control_reg <= 32'h0;
            config_reg <= 32'h0;
            for (i = 0; i < 12; i++) begin
                data_reg[i] <= 32'h0;
            end
        end else begin
            if (reg_wen[0]) begin
                for (j = 0; j < 4; j++) begin
                    if (reg_wstrb[j]) control_reg[8*j +: 8] <= reg_wdata[8*j +: 8];
                end
            end

            if (reg_wen[2]) begin
                for (j = 0; j < 4; j++) begin
                    if (reg_wstrb[j]) config_reg[8*j +: 8] <= reg_wdata[8*j +: 8];
                end
            end

            for (i = 0; i < 12; i++) begin
                if (reg_wen[i+4]) begin
                    for (j = 0; j < 4; j++) begin
                        if (reg_wstrb[j]) data_reg[i][8*j +: 8] <= reg_wdata[8*j +: 8];
                    end
                end
            end
        end
    end

    // READ
    always_comb begin
        reg_rdata[0] = control_reg;
        reg_rdata[1] = status_reg;
        reg_rdata[2] = config_reg;
        reg_rdata[3] = error_reg;

        for (k = 0; k < 12; k++) begin
            reg_rdata[k+4] = data_reg[k];
        end
    end

endmodule