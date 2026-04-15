module axi_protocol_sva (
    input wire aclk,
    input wire aresetn,

    // AW 채널
    input wire [31:0] awaddr,
    input wire awvalid,
    input wire awready,

    // W 채널
    input wire [31:0] wdata,
    input wire [3:0]  wstrb,
    input wire wvalid,
    input wire wready,

    // B 채널
    input wire [1:0]  bresp,
    input wire bvalid,
    input wire bready,

    // AR 채널
    input wire [31:0] araddr,
    input wire arvalid,
    input wire arready,

    // R 채널
    input wire [31:0] rdata,
    input wire [1:0]  rresp,
    input wire rvalid,
    input wire rready
);

    // assertion 실패 횟수 카운트
    integer sva_error_count = 0;

    // AXI-Lite 응답 코드
    localparam [1:0] RESP_OKAY   = 2'b00;
    localparam [1:0] RESP_SLVERR = 2'b10;
    localparam [1:0] RESP_DECERR = 2'b11;

    // VALID는 READY 전까지 유지되어야 함
    property aw_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> awvalid;
    endproperty

    property w_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> wvalid;
    endproperty

    property b_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        bvalid && !bready |=> bvalid;
    endproperty

    property ar_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        arvalid && !arready |=> arvalid;
    endproperty

    property r_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        rvalid && !rready |=> rvalid;
    endproperty

    // VALID가 유지되는 동안 payload도 변하면 안 됨
    property aw_addr_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> $stable(awaddr);
    endproperty

    property w_data_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> ($stable(wdata) && $stable(wstrb));
    endproperty

    property ar_addr_stable;
        @(posedge aclk) disable iff (!aresetn)
        arvalid && !arready |=> $stable(araddr);
    endproperty

    property b_resp_stable;
        @(posedge aclk) disable iff (!aresetn)
        bvalid && !bready |=> $stable(bresp);
    endproperty

    property r_data_stable;
        @(posedge aclk) disable iff (!aresetn)
        rvalid && !rready |=> ($stable(rdata) && $stable(rresp));
    endproperty

    // reset 중에는 response valid가 꺼져 있어야 함
    property reset_clears_response_valid;
        @(posedge aclk)
        !aresetn |-> (!bvalid && !rvalid);
    endproperty

    // 각 채널 handshake 정의
    sequence aw_hs;
        awvalid && awready;
    endsequence

    sequence w_hs;
        wvalid && wready;
    endsequence

    sequence ar_hs;
        arvalid && arready;
    endsequence

    // write address/data가 수락되면 일정 시간 내 B 응답이 와야 함
    property write_eventually_gets_b;
        @(posedge aclk) disable iff (!aresetn)
        ((aw_hs ##[0:16] w_hs) or (w_hs ##[0:16] aw_hs))
        |-> ##[0:16] bvalid;
    endproperty

    // read address가 수락되면 일정 시간 내 R 응답이 와야 함
    property read_eventually_gets_r;
        @(posedge aclk) disable iff (!aresetn)
        ar_hs |-> ##[0:16] rvalid;
    endproperty

    // 응답값은 허용된 값만 사용해야 함
    property valid_bresp_values;
        @(posedge aclk) disable iff (!aresetn)
        bvalid |-> (bresp inside {RESP_OKAY, RESP_SLVERR, RESP_DECERR});
    endproperty

    property valid_rresp_values;
        @(posedge aclk) disable iff (!aresetn)
        rvalid |-> (rresp inside {RESP_OKAY, RESP_SLVERR, RESP_DECERR});
    endproperty

    // AWVALID 유지 확인
    assert_aw_valid_stable: assert property(aw_valid_stable)
        else begin sva_error_count++; $error("[SVA FAIL] AWVALID dropped before AWREADY"); end

    // WVALID 유지 확인
    assert_w_valid_stable: assert property(w_valid_stable)
        else begin sva_error_count++; $error("[SVA FAIL] WVALID dropped before WREADY"); end

    // BVALID 유지 확인
    assert_b_valid_stable: assert property(b_valid_stable)
        else begin sva_error_count++; $error("[SVA FAIL] BVALID dropped before BREADY"); end

    // ARVALID 유지 확인
    assert_ar_valid_stable: assert property(ar_valid_stable)
        else begin sva_error_count++; $error("[SVA FAIL] ARVALID dropped before ARREADY"); end

    // RVALID 유지 확인
    assert_r_valid_stable: assert property(r_valid_stable)
        else begin sva_error_count++; $error("[SVA FAIL] RVALID dropped before RREADY"); end

    // AWADDR 안정성 확인
    assert_aw_addr_stable: assert property(aw_addr_stable)
        else begin sva_error_count++; $error("[SVA FAIL] AWADDR changed while waiting"); end

    // WDATA/WSTRB 안정성 확인
    assert_w_data_stable: assert property(w_data_stable)
        else begin sva_error_count++; $error("[SVA FAIL] WDATA/WSTRB changed while waiting"); end

    // ARADDR 안정성 확인
    assert_ar_addr_stable: assert property(ar_addr_stable)
        else begin sva_error_count++; $error("[SVA FAIL] ARADDR changed while waiting"); end

    // BRESP 안정성 확인
    assert_b_resp_stable: assert property(b_resp_stable)
        else begin sva_error_count++; $error("[SVA FAIL] BRESP changed while waiting"); end

    // RDATA/RRESP 안정성 확인
    assert_r_data_stable: assert property(r_data_stable)
        else begin sva_error_count++; $error("[SVA FAIL] RDATA/RRESP changed while waiting"); end

    // reset 시 BVALID/RVALID 비활성 확인
    assert_reset_valid: assert property(reset_clears_response_valid)
        else begin sva_error_count++; $error("[SVA FAIL] BVALID/RVALID active during reset"); end

    // write 후 B 응답 도착 확인
    assert_write_eventually_gets_b: assert property(write_eventually_gets_b)
        else begin sva_error_count++; $error("[SVA FAIL] Write did not produce BVALID in time"); end

    // read 후 R 응답 도착 확인
    assert_read_eventually_gets_r: assert property(read_eventually_gets_r)
        else begin sva_error_count++; $error("[SVA FAIL] Read did not produce RVALID in time"); end

    // BRESP 값 범위 확인
    assert_valid_bresp_values: assert property(valid_bresp_values)
        else begin sva_error_count++; $error("[SVA FAIL] Invalid BRESP value"); end

    // RRESP 값 범위 확인
    assert_valid_rresp_values: assert property(valid_rresp_values)
        else begin sva_error_count++; $error("[SVA FAIL] Invalid RRESP value"); end

    // 기본 handshake coverage
    cover_aw_handshake: cover property(@(posedge aclk) awvalid && awready);
    cover_w_handshake : cover property(@(posedge aclk) wvalid  && wready);
    cover_b_handshake : cover property(@(posedge aclk) bvalid  && bready);
    cover_ar_handshake: cover property(@(posedge aclk) arvalid && arready);
    cover_r_handshake : cover property(@(posedge aclk) rvalid  && rready);

    // stall/backpressure coverage
    cover_aw_stall: cover property(@(posedge aclk) awvalid && !awready);
    cover_w_stall : cover property(@(posedge aclk) wvalid  && !wready);
    cover_b_stall : cover property(@(posedge aclk) bvalid  && !bready);
    cover_ar_stall: cover property(@(posedge aclk) arvalid && !arready);
    cover_r_stall : cover property(@(posedge aclk) rvalid  && !rready);

    // write 순서 coverage
    cover_aw_then_w: cover property(@(posedge aclk)
        (awvalid && awready) ##[0:16] (wvalid && wready));

    cover_w_then_aw: cover property(@(posedge aclk)
        (wvalid && wready) ##[0:16] (awvalid && awready));

    cover_aw_w_same_cycle: cover property(@(posedge aclk)
        (awvalid && awready && wvalid && wready));

    // write/read end-to-end coverage
    cover_write_to_b_aw_first: cover property(@(posedge aclk)
        ((awvalid && awready) ##[0:16] (wvalid && wready))
        ##[0:16] (bvalid && bready));

    cover_write_to_b_w_first: cover property(@(posedge aclk)
        ((wvalid && wready) ##[0:16] (awvalid && awready))
        ##[0:16] (bvalid && bready));

    cover_read_to_r: cover property(@(posedge aclk)
        (arvalid && arready) ##[0:16] (rvalid && rready));

    // 시뮬레이션 종료 시 결과 출력
    final begin
        if (sva_error_count == 0)
            $display("[SVA PASS] All required AXI-Lite assertions passed.");
        else
            $display("[SVA SUMMARY] Total assertion failures: %0d", sva_error_count);
    end

endmodule
