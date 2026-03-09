`timescale 1ns / 1ps

module tb_axi;

    reg clk;
    reg resetn;

    // AW Channel
    reg [31:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;

    // W Channel
    reg [31:0] s_axi_wdata;
    reg [3:0] s_axi_wstrb;
    reg s_axi_wvalid;
    wire s_axi_wready;

    // B Channel
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;

    // AR Channel
    reg [31:0] s_axi_araddr;
    reg s_axi_arvalid;
    wire s_axi_arready;

    // R Channel
    wire [31:0] s_axi_rdata;
    wire s_axi_rvalid;
    wire [1:0] s_axi_rresp;
    reg s_axi_rready;

    // For simulation 
    time time_start;
    time time_end;
    reg [31:0] read_data;
    integer test_number;
    integer test_pass;
    integer test_fail;

    axi_top #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .NUM_REGS(16)   
    ) dut (
        .aclk(clk),
        .aresetn(resetn),

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
        .s_axi_rvalid(s_axi_rvalid)
    );

    // clk (Period - 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // response function (utility)
    function string get_resp_string;
        input [1:0] resp;
        begin
            case (resp)
                2'b00: get_resp_string = "OKAY";
                2'b01: get_resp_string = "EXOKAY";
                2'b10: get_resp_string = "SLVERR";
                2'b11: get_resp_string = "DECERR";
            endcase
        end
    endfunction

    // Write Test1 (ADDR -> DATA)
    task write_test1;
        input [31:0] addr;
        input [31:0] data;
        begin
            // IDLE State
            time_start = $time;
            s_axi_awaddr = addr;
            s_axi_awvalid = 1'b1;
            s_axi_bready = 1'b1;
            @(posedge clk iff s_axi_awready);
            s_axi_awvalid = 1'b0;

            // WRITE State
            s_axi_wdata = data;
            s_axi_wvalid = 1'b1;
            s_axi_wstrb = 4'b1111; // All Write
            @(posedge clk iff s_axi_wready);
            s_axi_wvalid = 1'b0;

            // DONE State
            @(posedge clk iff s_axi_bvalid);
            s_axi_bready = 1'b0;

            // Return: IDLE State 
            time_end = $time;

            // Result Display
            $display("[%0t ns] Write1 Transaction", $time);
            $display("- Address  : 0x%08h", addr);
            $display("- Data     : 0x%08h", data);
            $display("- Response : %s", get_resp_string(s_axi_bresp));
            $display("- Duration : %0d ns", time_end - time_start);
        end
    endtask

    // Write Test2 (DATA -> ADDR)
    task write_test2;
        input [31:0] addr;
        input [31:0] data;
        begin
            // IDLE State
            time_start = $time;
            s_axi_wdata = data;
            s_axi_wstrb = 4'b1111;
            s_axi_wvalid = 1'b1;
            s_axi_bready = 1'b1;
            @(posedge clk iff s_axi_wready);
            s_axi_wvalid = 1'b0;

            // ADDR State
            s_axi_awaddr = addr;
            s_axi_awvalid = 1'b1;
            @(posedge clk iff s_axi_awready);
            s_axi_awvalid = 1'b0;

            // DONE State
            @(posedge clk iff s_axi_bvalid);
            s_axi_bready = 1'b0;

            // Return: IDLE State
            time_end = $time;

            // Result Display
            $display("[%0t ns] Write2 Transaction", $time);
            $display("- Address  : 0x%08h", addr);
            $display("- Data     : 0x%08h", data);
            $display("- Response : %s", get_resp_string(s_axi_bresp));
            $display("- Duration : %0d ns", time_end - time_start);
        end
    endtask

    task read_test;
        input [31:0] addr;
        output [31:0] data;
        begin
            // IDLE State
            time_start = $time;
            s_axi_araddr = addr;
            s_axi_arvalid = 1'b1;
            s_axi_rready = 1'b1;
            @(posedge clk iff s_axi_arready);
            s_axi_arvalid = 1'b0;

            // DONE State
            @(posedge clk iff s_axi_rvalid);
            data = s_axi_rdata;
            s_axi_rready = 1'b0;

            // Return: IDLE State
            time_end = $time;

            // Result Display
            $display("[%0t ns] Read Transaction", $time);
            $display("- Address  : 0x%08h", addr);
            $display("- Data     : 0x%08h", data);
            $display("- Response : %s", get_resp_string(s_axi_rresp));
            $display("- Duration : %0d ns", time_end - time_start);
        end
    endtask

    task check_data;
        input [31:0] expected;
        input [31:0] actual;
        input string msg;
        begin
            if (expected == actual) begin
                $display("[PASS] Test Case %s", msg);
                $display("- Expected : 0x%08h", expected);
                $display("- Actual   : 0x%08h", actual);
                $display("- Result   : MATCH\n");
                test_pass = test_pass + 1;
            end else begin
                $display("[FAIL] Test Case %s", msg);
                $display("- Explected : 0x%08h", expected);
                $display("- Acutal    : 0x%08h", actual);
                $display("- Result    : MISMATCH\n");
                test_fail = test_fail + 1;
            end
        end
    endtask

    initial begin
        resetn= 0;

        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;

        test_pass = 0;
        test_fail = 0;
        test_number = 0;

        repeat(10) @(posedge clk);
        resetn = 1;
        repeat(20) @(posedge clk);

        // 테스트 시작 배너
        $display("\n========================================");
        $display("    AXI-Lite Verification Testbench");
        $display("        (SVA Error Fixed Version)");
        $display("========================================");
        $display("Clock Frequency: 100 MHz");
        $display("Test Start Time: %0t ns\n", $time);

        // Test 1: Write1 Test
        test_number = test_number + 1;
        $display("========================================");
        $display("Test %0d: Single Write/Read", test_number);
        $display("========================================\n");

        write_test1(32'h00000000, 32'h12345678);
        read_test(32'h00000000, read_data);
        check_data(32'h12345678, read_data, "Single Write/Read 1");

        // Test 2: Write2 Test
        test_number = test_number + 1;
        $display("========================================");
        $display("Test %0d: Single Write/Read", test_number);
        $display("========================================\n");

        write_test2(32'h00000008, 32'h12345678);
        read_test(32'h00000008, read_data);
        check_data(32'h12345678, read_data, "Single Write/Read 2");

        // Test 3: Multiple Write Test
        test_number = test_number + 1;
        $display("========================================");
        $display("Test %0d: Multiple Sequential Writes", test_number);
        $display("========================================\n");

        write_test1(32'h00000000, 32'hAABBCCDD);
        write_test1(32'h00000008, 32'h11223344);
        read_test(32'h00000000, read_data);
        check_data(32'hAABBCCDD, read_data, "Control Register Check");
        test_number = test_number + 1;
        read_test(32'h00000008, read_data);
        check_data(32'h11223344, read_data, "Config Register Check");

        // Test 4: Read-Only Test
        test_number = test_number + 1;
        $display("========================================");
        $display("Test %0d: Read-Only Status Register", test_number);
        $display("========================================\n");

        read_test(32'h00000004, read_data);
        check_data(32'hABCD1234, read_data, "Status Register");

        // ========================================
        // 테스트 결과 요약 (Test Summary)
        // ========================================
        $display("\n========================================");
        $display("    Test Execution Summary");
        $display("========================================");
        $display("Total Tests:    %0d", test_number);
        $display("Passed:         %0d", test_pass);
        $display("Failed:         %0d", test_fail);
        $display("Pass Rate:      %0d%%", (test_pass * 100) / test_number);
        $display("Test End Time:  %0t ns", $time);
        $display("========================================\n");

        // 최종 판정
        if (test_fail == 0) begin
            $display("*** ALL TESTS PASSED ***");
            $display("The AXI-Lite slave is functioning correctly.\n");
            $finish(0);   // 정상 종료 (exit code 0)
        end else begin
            $display("*** SOME TESTS FAILED ***");
            $finish(1);   // 에러 종료 (exit code 1)
        end
    end

endmodule