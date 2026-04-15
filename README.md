# AXI4-Lite Slave Design Project

32-bit AXI4-Lite Slave와 Register Map을 직접 설계하고, Directed Testbench와 SystemVerilog Assertions(SVA)로 기능 동작과 protocol 안정성을 검증한 RTL 프로젝트입니다.

## 프로젝트 개요

이 프로젝트는 AXI4-Lite 기반의 memory-mapped slave 구조를 구현하는 것을 목표로 합니다.  
AW, W, B, AR, R channel을 분리해서 처리하고, AXI4-Lite write transaction에서 발생할 수 있는 `AW->W`, `W->AW`, `AW+W` same-cycle case를 모두 처리하도록 설계했습니다.

검증은 testbench와 SVA를 분리한 구조로 구성했습니다. Testbench는 directed scenario와 결과 summary를 담당하고, SVA는 AXI4-Lite protocol 규칙과 coverage를 독립적으로 확인합니다.

## 한눈에 보기

| 항목 | 내용 |
| --- | --- |
| 프로젝트 유형 | RTL 설계 + 기능 검증 + protocol 검증 |
| 인터페이스 | AXI4-Lite |
| 데이터 폭 | 32-bit |
| Register 공간 | 16개 register |
| 검증 방식 | Directed Testbench, SVA |
| 주요 검증 항목 | write ordering, backpressure, register readback |

## 핵심 성과

- AXI4-Lite Slave, Register Map, Top Module로 구성된 RTL 구조 구현
- `AW->W`, `W->AW`, `AW+W` same-cycle write transaction 처리
- `BREADY`, `RREADY` backpressure 상황에서 response/data 안정성 검증
- SVA를 별도 모듈로 분리해 protocol assertion과 coverage 관리
- Directed test 5개 scenario와 AXI4-Lite 필수 assertion을 통해 검증 흐름 정리

## 기능

- 32-bit AXI4-Lite Slave interface
- AW, W, B, AR, R channel 기반 transaction 처리
- Write FSM / Read FSM 기반 제어 logic
- 16-entry memory-mapped register space
- `WSTRB` 기반 byte-enable write
- Register readback 및 status read 지원
- SVA 기반 `VALID/READY`, payload stability, bounded response 검증

## 기술 스택

| 구분 | 내용 |
| --- | --- |
| 언어 | SystemVerilog |
| 설계 방식 | RTL Design |
| Protocol | AXI4-Lite |
| 검증 방식 | Directed Testbench, SystemVerilog Assertions |
| 시뮬레이터 | Vivado XSIM |

## 프로젝트 구조

```text
AXI4_Lite/
+-- constraints/
|   +-- Zybo-Z7-Master.xdc
+-- docs/
|   +-- 0. AXI4-Lite Portfolio.pdf
+-- rtl/
|   +-- axi_lite_slave.sv
|   +-- axi_register_map.sv
|   +-- axi_top.sv
+-- tb/
|   +-- axi_protocol_sva.sv
|   +-- tb_axi_sva.sv
+-- LICENSE
+-- README.md
```

## 결과

- [`rtl/axi_lite_slave.sv`](rtl/axi_lite_slave.sv), [`rtl/axi_register_map.sv`](rtl/axi_register_map.sv), [`rtl/axi_top.sv`](rtl/axi_top.sv)로 AXI4-Lite Slave 구조 구현
- [`tb/tb_axi_sva.sv`](tb/tb_axi_sva.sv)에서 5개 directed scenario 검증
- [`tb/axi_protocol_sva.sv`](tb/axi_protocol_sva.sv)에서 AXI4-Lite 필수 protocol assertion 및 coverage 확인
- 시뮬레이션 결과 기준 test fail 없이 전체 scenario 통과

예상 시뮬레이션 결과:

```text
Total Tests:    5
Passed:         11
Failed:         0
Pass Rate:      100%
*** ALL TESTS PASSED ***
[SVA PASS] All required AXI-Lite assertions passed.
```

## 참고

- Board constraint file: [`constraints/Zybo-Z7-Master.xdc`](constraints/Zybo-Z7-Master.xdc)
- Project document: [`docs/0. AXI4-Lite Portfolio.pdf`](docs/0.%20AXI4-Lite%20Portfolio.pdf)
