// ============================================
// AXI-Lite Protocol Assertions (SVA)
// ============================================
// 목적: AXI-Lite 프로토콜 준수 여부를 자동으로 검증
// 
// SVA (SystemVerilog Assertions)란?
// - 설계의 동작을 형식적으로 명세하고 검증하는 방법
// - 시뮬레이션 중 프로토콜 위반을 자동으로 감지
// - 버그를 조기에 발견하여 디버깅 시간 단축
//
// AXI-Lite 프로토콜의 핵심 규칙:
// 1. VALID Stability: VALID는 READY가 1이 될 때까지 유지
// 2. Data Stability: VALID 동안 데이터도 안정적으로 유지
// 3. Reset Behavior: 리셋 시 모든 VALID는 0
// 4. Transaction Order: 올바른 트랜잭션 순서 유지
// ============================================

module axi_protocol_sva (
    // ========================================
    // 글로벌 신호
    // ========================================
    input wire aclk,      // AXI 클럭 - 모든 신호는 이 클럭에 동기화됨
    input wire aresetn,   // Active-Low 비동기 리셋
                          // 0: 리셋 활성화 (시스템 초기화)
                          // 1: 정상 동작
    
    // ========================================
    // Write Address Channel (AW)
    // Master가 Slave에게 "어디에 쓸 것인지" 알려주는 채널
    // ========================================
    input wire [31:0] awaddr,   // 쓰기 주소 (32비트 주소 공간)
    input wire awvalid,         // Master → Slave: "주소가 유효합니다"
    input wire awready,         // Slave → Master: "주소를 받을 준비가 됐습니다"
    
    // ========================================
    // Write Data Channel (W)
    // Master가 Slave에게 "무엇을 쓸 것인지" 알려주는 채널
    // ========================================
    input wire [31:0] wdata,    // 쓰기 데이터 (32비트)
    input wire [3:0] wstrb,     // Write Strobe - 바이트별 쓰기 활성화
                                // wstrb[0]=1: 바이트 0 (비트 7:0) 쓰기
                                // wstrb[1]=1: 바이트 1 (비트 15:8) 쓰기
                                // wstrb[2]=1: 바이트 2 (비트 23:16) 쓰기
                                // wstrb[3]=1: 바이트 3 (비트 31:24) 쓰기
    input wire wvalid,          // Master → Slave: "데이터가 유효합니다"
    input wire wready,          // Slave → Master: "데이터를 받을 준비가 됐습니다"
    
    // ========================================
    // Write Response Channel (B)
    // Slave가 Master에게 "쓰기 결과"를 알려주는 채널
    // ========================================
    input wire [1:0] bresp,     // 쓰기 응답 코드:
                                // 2'b00 (OKAY):   정상 완료
                                // 2'b01 (EXOKAY): Exclusive 접근 성공
                                // 2'b10 (SLVERR): Slave 에러
                                // 2'b11 (DECERR): 디코드 에러 (잘못된 주소)
    input wire bvalid,          // Slave → Master: "응답이 유효합니다"
    input wire bready,          // Master → Slave: "응답을 받을 준비가 됐습니다"
    
    // ========================================
    // Read Address Channel (AR)
    // Master가 Slave에게 "어디서 읽을 것인지" 알려주는 채널
    // ========================================
    input wire [31:0] araddr,   // 읽기 주소 (32비트 주소 공간)
    input wire arvalid,         // Master → Slave: "주소가 유효합니다"
    input wire arready,         // Slave → Master: "주소를 받을 준비가 됐습니다"
    
    // ========================================
    // Read Data Channel (R)
    // Slave가 Master에게 "읽은 데이터"를 보내는 채널
    // ========================================
    input wire [31:0] rdata,    // 읽기 데이터 (32비트)
    input wire [1:0] rresp,     // 읽기 응답 코드 (bresp와 동일한 인코딩)
    input wire rvalid,          // Slave → Master: "데이터가 유효합니다"
    input wire rready           // Master → Slave: "데이터를 받을 준비가 됐습니다"
);

    integer sva_error_count = 0;

    // ========================================
    // Rule 1: VALID Stability (VALID 안정성)
    // ========================================
    // AXI 프로토콜의 가장 기본적이고 중요한 규칙!
    //
    // 규칙: VALID 신호가 1이 되면, 상대방이 READY를 1로 
    //       만들어 handshake가 완료될 때까지 VALID를 
    //       계속 1로 유지해야 합니다.
    //
    // 왜 중요한가?
    // - VALID를 중간에 내리면 상대방이 데이터를 놓칠 수 있음
    // - 프로토콜 데드락 방지
    // - 신뢰할 수 있는 데이터 전송 보장
    //
    // SVA 문법 설명:
    // - property: 검증할 속성을 정의
    // - @(posedge aclk): 클럭 상승 엣지에서 검사
    // - disable iff (!aresetn): 리셋 중에는 검사 비활성화
    // - |=> : "implies next cycle" (다음 사이클에서 ~이어야 함)
    // ========================================
    
    // AW Channel: awvalid 안정성 검사
    // 조건: awvalid=1 이고 awready=0 이면 (handshake 미완료)
    // 검증: 다음 사이클에도 awvalid=1 이어야 함
    property aw_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> awvalid;
        // 해석: "awvalid가 1이고 awready가 0인 상태에서,
        //        다음 클럭에도 awvalid는 1이어야 한다"
    endproperty
    
    // assert property: 이 속성이 위반되면 시뮬레이션에서 에러 출력
    assert_aw_valid_stable: assert property(aw_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AW: valid dropped before ready");
        end
        // 에러 메시지: "AW 채널에서 ready 받기 전에 valid가 내려감"
    
    // W Channel: wvalid 안정성 검사
    property w_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> wvalid;
    endproperty
    
    assert_w_valid_stable: assert property(w_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] W: valid dropped before ready");
        end
    
    // B Channel: bvalid 안정성 검사
    // 참고: B 채널은 Slave가 Master에게 응답을 보내는 채널
    //       Slave도 동일한 규칙을 따라야 함
    property b_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        bvalid && !bready |=> bvalid;
    endproperty
    
    assert_b_valid_stable: assert property(b_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] B: valid dropped before ready");
        end
    
    // AR Channel: arvalid 안정성 검사
    property ar_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        arvalid && !arready |=> arvalid;
    endproperty
    
    assert_ar_valid_stable: assert property(ar_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AR: valid dropped before ready");
        end
    
    // R Channel: rvalid 안정성 검사
    property r_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        rvalid && !rready |=> rvalid;
    endproperty
    
    assert_r_valid_stable: assert property(r_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] R: valid dropped before ready");
        end
    
    // ========================================
    // Rule 2: Data Stability (데이터 안정성)
    // ========================================
    // 규칙: VALID가 1인 동안 관련 데이터도 변경되면 안 됨
    //
    // 왜 중요한가?
    // - Slave가 데이터를 샘플링하는 시점이 다를 수 있음
    // - 데이터가 중간에 바뀌면 잘못된 값이 저장될 수 있음
    //
    // SVA 문법:
    // - $stable(signal): 신호가 이전 사이클과 동일한지 검사
    // ========================================
    
    // AW Channel: awaddr 안정성
    // VALID 동안 주소가 바뀌면 안 됨
    property aw_addr_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> $stable(awaddr);
        // 해석: "awvalid=1, awready=0 상태에서
        //        다음 클럭의 awaddr는 현재와 동일해야 함"
    endproperty
    
    assert_aw_addr_stable: assert property(aw_addr_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AW: addr changed during handshake");
        end
    
    // W Channel: wdata와 wstrb 안정성
    // 데이터와 스트로브 모두 안정되어야 함
    property w_data_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> ($stable(wdata) && $stable(wstrb));
        // 두 조건을 AND로 결합: 둘 다 안정되어야 함
    endproperty
    
    assert_w_data_stable: assert property(w_data_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] W: data changed during handshake");
        end
    
    // AR Channel: araddr 안정성
    property ar_addr_stable;
        @(posedge aclk) disable iff (!aresetn)
        arvalid && !arready |=> $stable(araddr);
    endproperty
    
    assert_ar_addr_stable: assert property(ar_addr_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AR: addr changed during handshake");
        end
    
    // R Channel: rdata와 rresp 안정성
    property r_data_stable;
        @(posedge aclk) disable iff (!aresetn)
        rvalid && !rready |=> ($stable(rdata) && $stable(rresp));
    endproperty
    
    assert_r_data_stable: assert property(r_data_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] R: data changed during handshake");
        end
    
    // ========================================
    // Rule 3: Reset Behavior (리셋 동작)
    // ========================================
    // 규칙: 리셋이 활성화되면 모든 VALID 신호는 0이어야 함
    //
    // 왜 중요한가?
    // - 시스템 시작 시 예측 가능한 상태 보장
    // - 리셋 후 잘못된 트랜잭션 방지
    // - 안전한 초기화
    //
    // SVA 문법:
    // - |-> : "implies" (만약 ~이면 ~이어야 함, 같은 사이클)
    // - disable iff 없음: 리셋 중에도 검사해야 하므로!
    // ========================================
    
    property reset_clears_valid;
        @(posedge aclk)
        // disable iff 없음! 리셋 상태를 검사하는 것이므로
        !aresetn |-> (!awvalid && !wvalid && !bvalid && !arvalid && !rvalid);
        // 해석: "aresetn=0 (리셋 중)이면,
        //        모든 VALID 신호가 0이어야 함"
    endproperty
    
    assert_reset_valid: assert property(reset_clears_valid)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] Valid signals not cleared during reset");
        end
    
    // ========================================
    // Rule 4: Write Transaction Order (쓰기 순서)
    // ========================================
    // 규칙: 쓰기 주소가 전송되면 데이터도 곧 전송되어야 함
    //
    // 왜 중요한가?
    // - 불완전한 트랜잭션 감지
    // - 시스템 행(hang) 방지
    //
    // SVA 문법:
    // - ##[0:10]: 0~10 사이클 이내에 발생해야 함
    // ========================================
    
    property aw_then_w;
        @(posedge aclk) disable iff (!aresetn)
        (awvalid && awready) |-> ##[0:10] (wvalid && wready);
        // 해석: "AW handshake가 완료되면,
        //        0~10 사이클 이내에 W handshake도 완료되어야 함"
    endproperty
    
    assert_aw_then_w: assert property(aw_then_w)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] Write data not received after address");
        end
    
    // ========================================
    // Coverage Points (커버리지 포인트)
    // ========================================
    // 목적: 테스트가 충분히 다양한 시나리오를 커버하는지 측정
    //
    // cover property vs assert property:
    // - assert: 위반 시 에러 (버그 검출)
    // - cover: 발생 여부만 기록 (테스트 완전성 측정)
    //
    // 시뮬레이션 후 커버리지 리포트에서 확인 가능:
    // - 각 handshake가 실제로 발생했는지
    // - 테스트가 충분한지 판단하는 기준
    // ========================================
    
    // 각 채널의 handshake가 발생했는지 커버
    cover_aw_handshake: cover property(@(posedge aclk) awvalid && awready);
    cover_w_handshake: cover property(@(posedge aclk) wvalid && wready);
    cover_b_handshake: cover property(@(posedge aclk) bvalid && bready);
    cover_ar_handshake: cover property(@(posedge aclk) arvalid && arready);
    cover_r_handshake: cover property(@(posedge aclk) rvalid && rready);
    
    // Back-to-back 쓰기: 연속 트랜잭션 테스트
    // 고성능 시스템에서 중요한 시나리오
    cover_back_to_back_write: cover property(
        @(posedge aclk) (awvalid && awready) ##1 (awvalid && awready)
        // 해석: "AW handshake 직후(1 사이클 후) 다시 AW handshake"
    );

    final begin
        if (sva_error_count == 0) begin
            $display("[SVA PASS] All AXI protocol assertions passed.");
        end else begin
            $display("[SVA SUMMARY] Total assertion failures: %0d", sva_error_count);
        end
    end

endmodule
