//==============================================================================
// File Name   : TbAxiSva.sv
// Project     : AXI4_Lite
// Author      : Beomjun Kim
// Description : Directed self-checking testbench for the AXI4-Lite register
//               subsystem.
// Notes       : The AXI interface, driver tasks, and checker tasks are separated
//               so each scenario reads like an executable verification plan.
//==============================================================================

`timescale 1ns / 1ps

//==============================================================================
// Testbench Interface
//==============================================================================

interface AxiLiteIf #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    input logic i_aclk
);
    logic                         i_aresetn;
    logic [ADDR_WIDTH-1:0]        i_s_axi_awaddr;
    logic                         i_s_axi_awvalid;
    logic                         o_s_axi_awready;
    logic [DATA_WIDTH-1:0]        i_s_axi_wdata;
    logic [DATA_WIDTH/8-1:0]      i_s_axi_wstrb;
    logic                         i_s_axi_wvalid;
    logic                         o_s_axi_wready;
    logic [1:0]                   o_s_axi_bresp;
    logic                         o_s_axi_bvalid;
    logic                         i_s_axi_bready;
    logic [ADDR_WIDTH-1:0]        i_s_axi_araddr;
    logic                         i_s_axi_arvalid;
    logic                         o_s_axi_arready;
    logic [DATA_WIDTH-1:0]        o_s_axi_rdata;
    logic                         o_s_axi_rvalid;
    logic [1:0]                   o_s_axi_rresp;
    logic                         i_s_axi_rready;

    modport dut (
        input  i_aclk,
        input  i_aresetn,
        input  i_s_axi_awaddr,
        input  i_s_axi_awvalid,
        output o_s_axi_awready,
        input  i_s_axi_wdata,
        input  i_s_axi_wstrb,
        input  i_s_axi_wvalid,
        output o_s_axi_wready,
        output o_s_axi_bresp,
        output o_s_axi_bvalid,
        input  i_s_axi_bready,
        input  i_s_axi_araddr,
        input  i_s_axi_arvalid,
        output o_s_axi_arready,
        output o_s_axi_rdata,
        output o_s_axi_rvalid,
        output o_s_axi_rresp,
        input  i_s_axi_rready
    );
endinterface

module TbAxiSva;

    //==============================================================================
    // Testbench Parameters And State
    //==============================================================================

    localparam int ADDR_WIDTH = 32;
    localparam int DATA_WIDTH = 32;
    localparam int NUM_REGS   = 16;
    localparam int CLK_PERIOD = 10;

    localparam logic [1:0] RESP_OKAY = 2'b00;

    localparam logic [31:0] ADDR_CONTROL = 32'h0000_0000;
    localparam logic [31:0] ADDR_STATUS  = 32'h0000_0004;
    localparam logic [31:0] ADDR_CONFIG  = 32'h0000_0008;

    logic w_aclk;
    logic [31:0] r_read_data;
    int unsigned r_test_number;
    int unsigned r_test_pass;
    int unsigned r_test_fail;

    //==============================================================================
    // Interface Instance
    //==============================================================================

    AxiLiteIf #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) axi_if (
        .i_aclk (w_aclk)
    );

    //==============================================================================
    // DUT Instantiation
    //==============================================================================

    AxiTop #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .NUM_REGS   (NUM_REGS)
    ) u_dut (
        .i_aclk          (axi_if.i_aclk),
        .i_aresetn       (axi_if.i_aresetn),
        .i_s_axi_awaddr  (axi_if.i_s_axi_awaddr),
        .i_s_axi_awvalid (axi_if.i_s_axi_awvalid),
        .o_s_axi_awready (axi_if.o_s_axi_awready),
        .i_s_axi_wdata   (axi_if.i_s_axi_wdata),
        .i_s_axi_wstrb   (axi_if.i_s_axi_wstrb),
        .i_s_axi_wvalid  (axi_if.i_s_axi_wvalid),
        .o_s_axi_wready  (axi_if.o_s_axi_wready),
        .o_s_axi_bresp   (axi_if.o_s_axi_bresp),
        .o_s_axi_bvalid  (axi_if.o_s_axi_bvalid),
        .i_s_axi_bready  (axi_if.i_s_axi_bready),
        .i_s_axi_araddr  (axi_if.i_s_axi_araddr),
        .i_s_axi_arvalid (axi_if.i_s_axi_arvalid),
        .o_s_axi_arready (axi_if.o_s_axi_arready),
        .o_s_axi_rdata   (axi_if.o_s_axi_rdata),
        .o_s_axi_rvalid  (axi_if.o_s_axi_rvalid),
        .o_s_axi_rresp   (axi_if.o_s_axi_rresp),
        .i_s_axi_rready  (axi_if.i_s_axi_rready)
    );

    //==============================================================================
    // Protocol Monitor
    //==============================================================================

    AxiProtocolSva u_sva (
        .i_aclk     (axi_if.i_aclk),
        .i_aresetn  (axi_if.i_aresetn),
        .i_awaddr   (axi_if.i_s_axi_awaddr),
        .i_awvalid  (axi_if.i_s_axi_awvalid),
        .i_awready  (axi_if.o_s_axi_awready),
        .i_wdata    (axi_if.i_s_axi_wdata),
        .i_wstrb    (axi_if.i_s_axi_wstrb),
        .i_wvalid   (axi_if.i_s_axi_wvalid),
        .i_wready   (axi_if.o_s_axi_wready),
        .i_bresp    (axi_if.o_s_axi_bresp),
        .i_bvalid   (axi_if.o_s_axi_bvalid),
        .i_bready   (axi_if.i_s_axi_bready),
        .i_araddr   (axi_if.i_s_axi_araddr),
        .i_arvalid  (axi_if.i_s_axi_arvalid),
        .i_arready  (axi_if.o_s_axi_arready),
        .i_rdata    (axi_if.o_s_axi_rdata),
        .i_rresp    (axi_if.o_s_axi_rresp),
        .i_rvalid   (axi_if.o_s_axi_rvalid),
        .i_rready   (axi_if.i_s_axi_rready)
    );

    //==============================================================================
    // Clock Generation
    //==============================================================================

    initial begin
        w_aclk = 1'b0;
        forever #(CLK_PERIOD / 2) w_aclk = ~w_aclk;
    end

    //==============================================================================
    // Test Sequence
    //==============================================================================

    initial begin
        init_interface();
        apply_reset();
        run_aw_then_w_case();
        run_w_then_aw_case();
        run_same_cycle_case();
        run_b_backpressure_case();
        run_r_backpressure_case();
        report_summary();
    end

    //==============================================================================
    // Utility Functions
    //==============================================================================

    function automatic string resp_to_string(input logic [1:0] resp);
        case (resp)
            2'b00: resp_to_string = "OKAY";
            2'b01: resp_to_string = "EXOKAY";
            2'b10: resp_to_string = "SLVERR";
            2'b11: resp_to_string = "DECERR";
        endcase
    endfunction

    //==============================================================================
    // Initialization And Reset Tasks
    //==============================================================================

    task automatic init_interface();
        begin
            axi_if.i_aresetn       = 1'b0;
            axi_if.i_s_axi_awaddr  = '0;
            axi_if.i_s_axi_awvalid = 1'b0;
            axi_if.i_s_axi_wdata   = '0;
            axi_if.i_s_axi_wstrb   = '0;
            axi_if.i_s_axi_wvalid  = 1'b0;
            axi_if.i_s_axi_bready  = 1'b0;
            axi_if.i_s_axi_araddr  = '0;
            axi_if.i_s_axi_arvalid = 1'b0;
            axi_if.i_s_axi_rready  = 1'b0;
            r_test_number          = 0;
            r_test_pass            = 0;
            r_test_fail            = 0;
        end
    endtask

    task automatic apply_reset();
        begin
            repeat (10) @(posedge w_aclk);
            axi_if.i_aresetn = 1'b1;
            repeat (5) @(posedge w_aclk);
        end
    endtask

    task automatic check_data(
        input logic [31:0] expected,
        input logic [31:0] actual,
        input string       msg
    );
        begin
            if (expected == actual) begin
                $display("[PASS] %s expected=0x%08h actual=0x%08h", msg, expected, actual);
                r_test_pass++;
            end else begin
                $display("[FAIL] %s expected=0x%08h actual=0x%08h", msg, expected, actual);
                r_test_fail++;
            end
        end
    endtask

    task automatic check_resp(
        input logic [1:0] expected,
        input logic [1:0] actual,
        input string      msg
    );
        begin
            if (expected == actual) begin
                $display("[PASS] %s expected=%s actual=%s",
                         msg,
                         resp_to_string(expected),
                         resp_to_string(actual));
                r_test_pass++;
            end else begin
                $display("[FAIL] %s expected=%s actual=%s",
                         msg,
                         resp_to_string(expected),
                         resp_to_string(actual));
                r_test_fail++;
            end
        end
    endtask

    //==============================================================================
    // Bus Driver Tasks
    //==============================================================================

    task automatic write_aw_then_w(
        input  logic [31:0] addr,
        input  logic [31:0] data,
        input  logic [3:0]  strb,
        output logic [1:0]  resp
    );
        begin
            axi_if.i_s_axi_awaddr  = addr;
            axi_if.i_s_axi_awvalid = 1'b1;
            axi_if.i_s_axi_bready  = 1'b1;
            @(posedge w_aclk iff axi_if.o_s_axi_awready);
            axi_if.i_s_axi_awvalid = 1'b0;

            axi_if.i_s_axi_wdata  = data;
            axi_if.i_s_axi_wstrb  = strb;
            axi_if.i_s_axi_wvalid = 1'b1;
            @(posedge w_aclk iff axi_if.o_s_axi_wready);
            axi_if.i_s_axi_wvalid = 1'b0;

            @(posedge w_aclk iff axi_if.o_s_axi_bvalid);
            resp = axi_if.o_s_axi_bresp;
            axi_if.i_s_axi_bready = 1'b0;
        end
    endtask

    task automatic write_w_then_aw(
        input  logic [31:0] addr,
        input  logic [31:0] data,
        input  logic [3:0]  strb,
        output logic [1:0]  resp
    );
        begin
            axi_if.i_s_axi_wdata  = data;
            axi_if.i_s_axi_wstrb  = strb;
            axi_if.i_s_axi_wvalid = 1'b1;
            axi_if.i_s_axi_bready = 1'b1;
            @(posedge w_aclk iff axi_if.o_s_axi_wready);
            axi_if.i_s_axi_wvalid = 1'b0;

            axi_if.i_s_axi_awaddr  = addr;
            axi_if.i_s_axi_awvalid = 1'b1;
            @(posedge w_aclk iff axi_if.o_s_axi_awready);
            axi_if.i_s_axi_awvalid = 1'b0;

            @(posedge w_aclk iff axi_if.o_s_axi_bvalid);
            resp = axi_if.o_s_axi_bresp;
            axi_if.i_s_axi_bready = 1'b0;
        end
    endtask

    task automatic write_same_cycle(
        input  logic [31:0] addr,
        input  logic [31:0] data,
        input  logic [3:0]  strb,
        output logic [1:0]  resp
    );
        begin
            axi_if.i_s_axi_awaddr  = addr;
            axi_if.i_s_axi_awvalid = 1'b1;
            axi_if.i_s_axi_wdata   = data;
            axi_if.i_s_axi_wstrb   = strb;
            axi_if.i_s_axi_wvalid  = 1'b1;
            axi_if.i_s_axi_bready  = 1'b1;
            @(posedge w_aclk iff (axi_if.o_s_axi_awready && axi_if.o_s_axi_wready));
            axi_if.i_s_axi_awvalid = 1'b0;
            axi_if.i_s_axi_wvalid  = 1'b0;

            @(posedge w_aclk iff axi_if.o_s_axi_bvalid);
            resp = axi_if.o_s_axi_bresp;
            axi_if.i_s_axi_bready = 1'b0;
        end
    endtask

    task automatic write_with_b_backpressure(
        input  logic [31:0] addr,
        input  logic [31:0] data,
        input  logic [3:0]  strb,
        input  int unsigned delay_cycles,
        output logic [1:0]  resp
    );
        begin
            axi_if.i_s_axi_awaddr  = addr;
            axi_if.i_s_axi_awvalid = 1'b1;
            axi_if.i_s_axi_wdata   = data;
            axi_if.i_s_axi_wstrb   = strb;
            axi_if.i_s_axi_wvalid  = 1'b1;
            axi_if.i_s_axi_bready  = 1'b0;
            @(posedge w_aclk iff (axi_if.o_s_axi_awready && axi_if.o_s_axi_wready));
            axi_if.i_s_axi_awvalid = 1'b0;
            axi_if.i_s_axi_wvalid  = 1'b0;

            @(posedge w_aclk iff axi_if.o_s_axi_bvalid);
            repeat (delay_cycles) @(posedge w_aclk);
            resp = axi_if.o_s_axi_bresp;
            axi_if.i_s_axi_bready = 1'b1;
            @(posedge w_aclk);
            axi_if.i_s_axi_bready = 1'b0;
        end
    endtask

    //==============================================================================
    // Read Driver Tasks
    //==============================================================================

    task automatic read_data(
        input  logic [31:0] addr,
        output logic [31:0] data,
        output logic [1:0]  resp
    );
        begin
            axi_if.i_s_axi_araddr  = addr;
            axi_if.i_s_axi_arvalid = 1'b1;
            axi_if.i_s_axi_rready  = 1'b1;
            @(posedge w_aclk iff axi_if.o_s_axi_arready);
            axi_if.i_s_axi_arvalid = 1'b0;

            @(posedge w_aclk iff axi_if.o_s_axi_rvalid);
            data = axi_if.o_s_axi_rdata;
            resp = axi_if.o_s_axi_rresp;
            axi_if.i_s_axi_rready = 1'b0;
        end
    endtask

    task automatic read_with_r_backpressure(
        input  logic [31:0] addr,
        input  int unsigned delay_cycles,
        output logic [31:0] data,
        output logic [1:0]  resp
    );
        begin
            axi_if.i_s_axi_araddr  = addr;
            axi_if.i_s_axi_arvalid = 1'b1;
            axi_if.i_s_axi_rready  = 1'b0;
            @(posedge w_aclk iff axi_if.o_s_axi_arready);
            axi_if.i_s_axi_arvalid = 1'b0;

            @(posedge w_aclk iff axi_if.o_s_axi_rvalid);
            repeat (delay_cycles) @(posedge w_aclk);
            data = axi_if.o_s_axi_rdata;
            resp = axi_if.o_s_axi_rresp;
            axi_if.i_s_axi_rready = 1'b1;
            @(posedge w_aclk);
            axi_if.i_s_axi_rready = 1'b0;
        end
    endtask

    //==============================================================================
    // Directed Test Scenarios
    //==============================================================================

    task automatic run_aw_then_w_case();
        logic [1:0] wr_resp;
        logic [1:0] rd_resp;

        begin
            r_test_number++;
            $display("Test %0d: AW then W write/read", r_test_number);
            write_aw_then_w(ADDR_CONTROL, 32'h1234_5678, 4'b1111, wr_resp);
            check_resp(RESP_OKAY, wr_resp, "AW->W write response");
            read_data(ADDR_CONTROL, r_read_data, rd_resp);
            check_resp(RESP_OKAY, rd_resp, "Read response after AW->W write");
            check_data(32'h1234_5678, r_read_data, "Readback after AW->W write");
        end
    endtask

    task automatic run_w_then_aw_case();
        logic [1:0] wr_resp;
        logic [1:0] rd_resp;

        begin
            r_test_number++;
            $display("Test %0d: W then AW write/read", r_test_number);
            write_w_then_aw(ADDR_CONFIG, 32'h8765_4321, 4'b1111, wr_resp);
            check_resp(RESP_OKAY, wr_resp, "W->AW write response");
            read_data(ADDR_CONFIG, r_read_data, rd_resp);
            check_resp(RESP_OKAY, rd_resp, "Read response after W->AW write");
            check_data(32'h8765_4321, r_read_data, "Readback after W->AW write");
        end
    endtask

    task automatic run_same_cycle_case();
        logic [1:0] wr_resp;
        logic [1:0] rd_resp;

        begin
            r_test_number++;
            $display("Test %0d: Same-cycle write", r_test_number);
            write_same_cycle(ADDR_CONTROL, 32'hA5A5_5A5A, 4'b1111, wr_resp);
            check_resp(RESP_OKAY, wr_resp, "Same-cycle write response");
            read_data(ADDR_CONTROL, r_read_data, rd_resp);
            check_resp(RESP_OKAY, rd_resp, "Read response after same-cycle write");
            check_data(32'hA5A5_5A5A, r_read_data, "Readback after same-cycle write");
        end
    endtask

    task automatic run_b_backpressure_case();
        logic [1:0] wr_resp;

        begin
            r_test_number++;
            $display("Test %0d: B channel backpressure", r_test_number);
            write_with_b_backpressure(ADDR_CONTROL, 32'hCAFE_BABE, 4'b1111, 3, wr_resp);
            check_resp(RESP_OKAY, wr_resp, "Write response with B backpressure");
        end
    endtask

    task automatic run_r_backpressure_case();
        logic [1:0] rd_resp;

        begin
            r_test_number++;
            $display("Test %0d: R channel backpressure", r_test_number);
            read_with_r_backpressure(ADDR_STATUS, 3, r_read_data, rd_resp);
            check_resp(RESP_OKAY, rd_resp, "Read response with R backpressure");
            check_data(32'hABCD_1234, r_read_data, "Status register readback");
        end
    endtask

    //==============================================================================
    // Summary Reporting
    //==============================================================================

    task automatic report_summary();
        begin
            $display("\n========================================");
            $display("    AXI4-Lite Test Execution Summary");
            $display("========================================");
            $display("Total Tests: %0d", r_test_number);
            $display("Passed:      %0d", r_test_pass);
            $display("Failed:      %0d", r_test_fail);
            $display("========================================\n");

            if (r_test_fail == 0) begin
                $display("*** ALL TESTS PASSED ***");
                $finish(0);
            end else begin
                $display("*** SOME TESTS FAILED ***");
                $finish(1);
            end
        end
    endtask

endmodule
