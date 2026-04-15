`timescale 1ns / 1ps

module tb_axi;

    // 클럭 / 리셋
    reg clk;
    reg resetn;

    // AW 채널
    reg [31:0] s_axi_awaddr;
    reg        s_axi_awvalid;
    wire       s_axi_awready;

    // W 채널
    reg [31:0] s_axi_wdata;
    reg [3:0]  s_axi_wstrb;
    reg        s_axi_wvalid;
    wire       s_axi_wready;

    // B 채널
    wire [1:0] s_axi_bresp;
    wire       s_axi_bvalid;
    reg        s_axi_bready;

    // AR 채널
    reg [31:0] s_axi_araddr;
    reg        s_axi_arvalid;
    wire       s_axi_arready;

    // R 채널
    wire [31:0] s_axi_rdata;
    wire        s_axi_rvalid;
    wire [1:0]  s_axi_rresp;
    reg         s_axi_rready;

    // 시뮬레이션용 변수
    time time_start;
    time time_end;
    reg [31:0] read_data;
    integer test_number;
    integer test_pass;
    integer test_fail;

    // AXI 응답 코드
    localparam [1:0] RESP_OKAY   = 2'b00;

    // 테스트용 주소
    localparam [31:0] ADDR_REG0   = 32'h0000_0000;
    localparam [31:0] ADDR_STATUS = 32'h0000_0004;
    localparam [31:0] ADDR_REG2   = 32'h0000_0008;

    // DUT 인스턴스
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

    // AXI protocol assertion 모듈 연결
    axi_protocol_sva u_sva (
        .aclk   (clk),
        .aresetn(resetn),
        .awaddr (s_axi_awaddr),
        .awvalid(s_axi_awvalid),
        .awready(s_axi_awready),
        .wdata  (s_axi_wdata),
        .wstrb  (s_axi_wstrb),
        .wvalid (s_axi_wvalid),
        .wready (s_axi_wready),
        .bresp  (s_axi_bresp),
        .bvalid (s_axi_bvalid),
        .bready (s_axi_bready),
        .araddr (s_axi_araddr),
        .arvalid(s_axi_arvalid),
        .arready(s_axi_arready),
        .rdata  (s_axi_rdata),
        .rresp  (s_axi_rresp),
        .rvalid (s_axi_rvalid),
        .rready (s_axi_rready)
    );

    // 클럭 생성
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 응답 코드를 문자열로 변환
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

    // 데이터 비교
    task check_data;
        input [31:0] expected;
        input [31:0] actual;
        input string msg;
        begin
            if (expected == actual) begin
                $display("[PASS] %s", msg);
                $display("- Expected : 0x%08h", expected);
                $display("- Actual   : 0x%08h", actual);
                test_pass = test_pass + 1;
            end else begin
                $display("[FAIL] %s", msg);
                $display("- Expected : 0x%08h", expected);
                $display("- Actual   : 0x%08h", actual);
                test_fail = test_fail + 1;
            end
            $display("");
        end
    endtask

    // 응답값 비교
    task check_resp;
        input [1:0] expected;
        input [1:0] actual;
        input string msg;
        begin
            if (expected == actual) begin
                $display("[PASS] %s", msg);
                $display("- Expected RESP : %s", get_resp_string(expected));
                $display("- Actual RESP   : %s", get_resp_string(actual));
                test_pass = test_pass + 1;
            end else begin
                $display("[FAIL] %s", msg);
                $display("- Expected RESP : %s", get_resp_string(expected));
                $display("- Actual RESP   : %s", get_resp_string(actual));
                test_fail = test_fail + 1;
            end
            $display("");
        end
    endtask

    // AW 먼저, W 나중에 보내는 write
    task write_aw_then_w;
        input [31:0] addr;
        input [31:0] data;
        input [3:0]  strb;
        output [1:0] resp;
        begin
            time_start    = $time;

            // AW 전송
            s_axi_awaddr  = addr;
            s_axi_awvalid = 1'b1;
            s_axi_bready  = 1'b1;
            @(posedge clk iff s_axi_awready);
            s_axi_awvalid = 1'b0;

            // W 전송
            s_axi_wdata   = data;
            s_axi_wstrb   = strb;
            s_axi_wvalid  = 1'b1;
            @(posedge clk iff s_axi_wready);
            s_axi_wvalid  = 1'b0;

            // B 응답 수신
            @(posedge clk iff s_axi_bvalid);
            resp = s_axi_bresp;
            s_axi_bready = 1'b0;
            time_end = $time;
        end
    endtask

    // W 먼저, AW 나중에 보내는 write
    task write_w_then_aw;
        input [31:0] addr;
        input [31:0] data;
        input [3:0]  strb;
        output [1:0] resp;
        begin
            time_start   = $time;

            // W 전송
            s_axi_wdata  = data;
            s_axi_wstrb  = strb;
            s_axi_wvalid = 1'b1;
            s_axi_bready = 1'b1;
            @(posedge clk iff s_axi_wready);
            s_axi_wvalid = 1'b0;

            // AW 전송
            s_axi_awaddr  = addr;
            s_axi_awvalid = 1'b1;
            @(posedge clk iff s_axi_awready);
            s_axi_awvalid = 1'b0;

            // B 응답 수신
            @(posedge clk iff s_axi_bvalid);
            resp = s_axi_bresp;
            s_axi_bready = 1'b0;
            time_end = $time;
        end
    endtask

    // AW와 W를 같은 cycle에 보내는 write
    task write_same_cycle;
        input [31:0] addr;
        input [31:0] data;
        input [3:0]  strb;
        output [1:0] resp;
        begin
            time_start    = $time;
            s_axi_awaddr  = addr;
            s_axi_awvalid = 1'b1;
            s_axi_wdata   = data;
            s_axi_wstrb   = strb;
            s_axi_wvalid  = 1'b1;
            s_axi_bready  = 1'b1;

            @(posedge clk iff (s_axi_awready && s_axi_wready));
            s_axi_awvalid = 1'b0;
            s_axi_wvalid  = 1'b0;

            @(posedge clk iff s_axi_bvalid);
            resp = s_axi_bresp;
            s_axi_bready = 1'b0;
            time_end = $time;
        end
    endtask

    // B 채널 backpressure를 주는 write
    task write_with_b_backpressure;
        input [31:0] addr;
        input [31:0] data;
        input [3:0]  strb;
        input integer delay_cycles;
        output [1:0] resp;
        begin
            time_start    = $time;
            s_axi_awaddr  = addr;
            s_axi_awvalid = 1'b1;
            s_axi_wdata   = data;
            s_axi_wstrb   = strb;
            s_axi_wvalid  = 1'b1;
            s_axi_bready  = 1'b0;

            // AW/W handshake
            @(posedge clk iff (s_axi_awready && s_axi_wready));
            s_axi_awvalid = 1'b0;
            s_axi_wvalid  = 1'b0;

            // BVALID가 올라온 뒤 일부러 ready를 늦게 줌
            @(posedge clk iff s_axi_bvalid);
            repeat(delay_cycles) @(posedge clk);
            resp = s_axi_bresp;
            s_axi_bready = 1'b1;
            @(posedge clk);
            s_axi_bready = 1'b0;
            time_end = $time;
        end
    endtask

    // 기본 read
    task read_test;
        input [31:0] addr;
        output [31:0] data;
        output [1:0]  resp;
        begin
            time_start    = $time;
            s_axi_araddr  = addr;
            s_axi_arvalid = 1'b1;
            s_axi_rready  = 1'b1;

            // AR handshake
            @(posedge clk iff s_axi_arready);
            s_axi_arvalid = 1'b0;

            // R 응답 수신
            @(posedge clk iff s_axi_rvalid);
            data = s_axi_rdata;
            resp = s_axi_rresp;
            s_axi_rready = 1'b0;
            time_end = $time;
        end
    endtask

    // R 채널 backpressure를 주는 read
    task read_with_r_backpressure;
        input [31:0] addr;
        input integer delay_cycles;
        output [31:0] data;
        output [1:0]  resp;
        begin
            time_start    = $time;
            s_axi_araddr  = addr;
            s_axi_arvalid = 1'b1;
            s_axi_rready  = 1'b0;

            // AR handshake
            @(posedge clk iff s_axi_arready);
            s_axi_arvalid = 1'b0;

            // RVALID가 올라온 뒤 ready를 늦게 줌
            @(posedge clk iff s_axi_rvalid);
            repeat(delay_cycles) @(posedge clk);
            data = s_axi_rdata;
            resp = s_axi_rresp;
            s_axi_rready = 1'b1;
            @(posedge clk);
            s_axi_rready = 1'b0;
            time_end = $time;
        end
    endtask

    initial begin
        reg [1:0] wr_resp;
        reg [1:0] rd_resp;

        // 초기화
        resetn = 0;

        s_axi_awaddr  = 0;
        s_axi_awvalid = 0;
        s_axi_wdata   = 0;
        s_axi_wstrb   = 0;
        s_axi_wvalid  = 0;
        s_axi_bready  = 0;
        s_axi_araddr  = 0;
        s_axi_arvalid = 0;
        s_axi_rready  = 0;

        test_pass   = 0;
        test_fail   = 0;
        test_number = 0;

        // reset 유지 후 해제
        repeat (10) @(posedge clk);
        resetn = 1;
        repeat (5) @(posedge clk);

        $display("\n========================================");
        $display("       AXI-Lite Verification TB");
        $display("========================================");

        // AW -> W 순서 write/read 테스트
        test_number = test_number + 1;
        $display("Test %0d: AW then W write/read", test_number);
        write_aw_then_w(ADDR_REG0, 32'h1234_5678, 4'b1111, wr_resp);
        check_resp(RESP_OKAY, wr_resp, "AW->W write response");
        read_test(ADDR_REG0, read_data, rd_resp);
        check_resp(RESP_OKAY, rd_resp, "Read response after AW->W write");
        check_data(32'h1234_5678, read_data, "Readback after AW->W write");

        // W -> AW 순서 write/read 테스트
        test_number = test_number + 1;
        $display("Test %0d: W then AW write/read", test_number);
        write_w_then_aw(ADDR_REG2, 32'h8765_4321, 4'b1111, wr_resp);
        check_resp(RESP_OKAY, wr_resp, "W->AW write response");
        read_test(ADDR_REG2, read_data, rd_resp);
        check_resp(RESP_OKAY, rd_resp, "Read response after W->AW write");
        check_data(32'h8765_4321, read_data, "Readback after W->AW write");

        // AW/W 동시 write 테스트
        test_number = test_number + 1;
        $display("Test %0d: Same-cycle write", test_number);
        write_same_cycle(ADDR_REG0, 32'hA5A5_5A5A, 4'b1111, wr_resp);
        check_resp(RESP_OKAY, wr_resp, "Same-cycle write response");
        read_test(ADDR_REG0, read_data, rd_resp);
        check_resp(RESP_OKAY, rd_resp, "Read response after same-cycle write");
        check_data(32'hA5A5_5A5A, read_data, "Readback after same-cycle write");

        // B 채널 backpressure 테스트
        test_number = test_number + 1;
        $display("Test %0d: B channel backpressure", test_number);
        write_with_b_backpressure(ADDR_REG0, 32'hCAFE_BABE, 4'b1111, 3, wr_resp);
        check_resp(RESP_OKAY, wr_resp, "Write response with B backpressure");

        // R 채널 backpressure 테스트
        test_number = test_number + 1;
        $display("Test %0d: R channel backpressure", test_number);
        read_with_r_backpressure(ADDR_STATUS, 3, read_data, rd_resp);
        check_resp(RESP_OKAY, rd_resp, "Read response with R backpressure");

        // 결과 요약
        $display("\n========================================");
        $display("    Test Execution Summary");
        $display("========================================");
        $display("Total Tests:    %0d", test_number);
        $display("Passed:         %0d", test_pass);
        $display("Failed:         %0d", test_fail);
        if (test_number != 0)
            $display("Pass Rate:      %0d%%", (test_pass * 100) / (test_pass + test_fail));
        $display("========================================\n");

        // 최종 종료
        if (test_fail == 0) begin
            $display("*** ALL TESTS PASSED ***");
            $finish(0);
        end else begin
            $display("*** SOME TESTS FAILED ***");
            $finish(1);
        end
    end

endmodule
