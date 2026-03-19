# AXI4-Lite Slave Design and Verification Project

32-bit AXI4-Lite Slave, Register Map, Testbench, 그리고 SVA 기반 프로토콜 검증까지 포함한 RTL 설계 및 검증 프로젝트입니다.

## 헤더

**프로젝트 제목**  
AXI4-Lite Slave Design and Verification Project

**한줄 설명**  
32-bit AXI4-Lite Slave와 16개 레지스터 맵을 직접 설계하고, Directed Testbench와 SVA를 통해 기능 동작과 프로토콜 준수 여부를 함께 검증한 프로젝트입니다.

## 핵심 성과

### 1. 단순 검증 대상이 아니라 AXI4-Lite Slave 자체를 설계
- Before: AXI 인터페이스 동작을 부분적으로만 다루는 수준
- After: [`src/axi_lite_slave.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_lite_slave.sv), [`src/axi_register_map.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_register_map.sv), [`src/axi_top.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_top.sv)로 분리된 구조의 **32-bit AXI4-Lite Slave 서브시스템**을 설계

### 2. 16개 레지스터 맵 기반의 확장 가능한 메모리 맵 구조 구현
- Before: 소수의 제어 레지스터만 다루는 단순 구조
- After: **4개 주요 레지스터**와 **12개 데이터 레지스터**를 포함한 **총 16개 주소 공간**을 구성해 제어/상태/데이터 저장 구조를 명확히 분리

### 3. AXI4-Lite 쓰기 채널의 다양한 도착 순서를 처리하도록 FSM 설계
- Before: 주소와 데이터가 항상 같은 순서로 도착한다고 가정할 가능성 존재
- After: **3가지 쓰기 케이스**(`AW->W`, `W->AW`, `AW+W 동시`)를 처리하도록 Write FSM을 설계해 실제 AXI4-Lite 동작에 가깝게 구현

### 4. 설계 결과를 기능 검증과 프로토콜 검증으로 이중 확인
- Before: 읽기/쓰기 결과 확인 중심의 제한적인 검증
- After: [`sim/tb_axi.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/tb_axi.sv)의 **4개 주요 시나리오**, **5개 데이터 검증 케이스**와 [`sim/axi_sva.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/axi_sva.sv)의 **11개 Assertion**, **6개 Coverage Point**를 통해 설계 결과를 정량적으로 검증

## 기능

- 32-bit AXI4-Lite Slave 인터페이스 설계
- AW, W, B, AR, R 채널 분리 기반 트랜잭션 처리
- Read FSM / Write FSM 기반 제어 로직 구현
- `WSTRB`를 이용한 Byte-enable Write 지원
- Control, Status, Config, Error 및 Data Register를 포함한 16개 레지스터 맵 구성
- 주소와 데이터의 순차/역순/동시 도착을 처리하는 쓰기 경로 설계
- Directed Testbench 기반 기능 검증
- SVA 기반 프로토콜 Assertion 및 Coverage 수집

## 기술 스택

- **언어**: SystemVerilog
- **설계 방식**: RTL Design, Parameterized Module, `always_ff`, `always_comb`
- **프로토콜**: AXI4-Lite
- **검증 방식**: Directed Testbench, SystemVerilog Assertions (SVA)
- **타깃 보드 제약 파일**: [`constraints/Zybo-Z7-Master.xdc`](/c:/Users/rlaqj/Project/AXI4_Lite/constraints/Zybo-Z7-Master.xdc)

## 프로젝트 구조

```text
AXI4_Lite/
+-- constraints/
|   +-- Zybo-Z7-Master.xdc
+-- docs/
|   +-- 0. AXI4-Lite Portfolio.pdf
+-- sim/
|   +-- axi_sva.sv
|   +-- tb_axi.sv
+-- src/
|   +-- axi_lite_slave.sv
|   +-- axi_register_map.sv
|   +-- axi_top.sv
+-- LICENSE
+-- README.md
```

## 결과

- AXI4-Lite Slave, Register Map, Top Module로 구성된 **설계 자산**과 Testbench, SVA Monitor로 구성된 **검증 자산**을 모두 구축
- **32-bit 데이터 폭**, **16개 레지스터 공간**을 갖는 AXI4-Lite 기반 Register-mapped 구조 구현
- **11개 Assertion**으로 VALID 유지, 데이터 안정성, Reset 동작, Write 순서 제약을 검증
- **6개 Coverage Point**로 주요 handshake 및 back-to-back write 시나리오를 관찰 가능하게 구성
- 설계와 검증을 함께 설명할 수 있는 형태로 README를 정리하여 포트폴리오 활용도를 높임

## 파일 설명

- [`src/axi_top.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_top.sv): AXI Slave와 Register Map을 연결하는 Top Module
- [`src/axi_lite_slave.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_lite_slave.sv): AXI4-Lite 읽기/쓰기 제어 로직
- [`src/axi_register_map.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_register_map.sv): 레지스터 맵 및 데이터 저장 구조
- [`sim/tb_axi.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/tb_axi.sv): Directed 기능 검증용 테스트벤치
- [`sim/axi_sva.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/axi_sva.sv): AXI4-Lite 프로토콜 Assertion 및 Coverage
