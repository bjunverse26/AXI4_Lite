# AXI4-Lite Slave Design Project

32-bit AXI4-Lite Slave와 Register Map을 설계하고, Directed Testbench와 SVA로 기능 및 프로토콜 동작을 검증한 RTL 프로젝트입니다.

## 프로젝트 개요

이 프로젝트는 AXI4-Lite 기반의 메모리 맵 인터페이스를 직접 설계하고, 읽기/쓰기 동작이 정상적으로 수행되는지 검증하는 것을 목표로 합니다.  
단순 기능 확인에 그치지 않고, Assertion 기반 검증을 추가해 프로토콜 안정성까지 함께 확인할 수 있도록 구성했습니다.

## 한눈에 보기

| 항목 | 내용 |
| --- | --- |
| 프로젝트 유형 | RTL 설계 + 기능 검증 + 프로토콜 검증 |
| 인터페이스 | AXI4-Lite |
| 데이터 폭 | 32-bit |
| 레지스터 공간 | 총 16개 |
| 주요 검증 자산 | Directed Testbench, SVA |
| 정량 성과 | 11 Assertions, 6 Coverage Points, 4개 주요 시나리오, 5개 데이터 체크 |

## 핵심 성과

### 1. AXI4-Lite Slave 서브시스템 직접 설계
- Before: 단순 인터페이스 이해 수준
- After: [`src/axi_lite_slave.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_lite_slave.sv), [`src/axi_register_map.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_register_map.sv), [`src/axi_top.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_top.sv)로 분리된 32-bit AXI4-Lite Slave 구조 설계

### 2. 확장 가능한 16개 레지스터 맵 구현
- Before: 소수 레지스터 중심의 단순 구조
- After: 4개 주요 레지스터와 12개 데이터 레지스터를 포함한 총 16개 주소 공간 구성

### 3. 다양한 쓰기 타이밍 케이스를 처리하는 FSM 구현
- Before: 주소와 데이터가 항상 같은 순서로 도착한다고 가정할 가능성 존재
- After: `AW->W`, `W->AW`, `AW+W 동시`의 3가지 쓰기 시나리오를 처리하도록 Write FSM 설계

### 4. 설계 결과를 정량적으로 검증
- Before: 단순 읽기/쓰기 결과 확인 중심
- After: [`sim/tb_axi.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/tb_axi.sv)의 4개 주요 시나리오, 5개 데이터 검증 케이스와 [`sim/axi_sva.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/axi_sva.sv)의 11개 Assertion, 6개 Coverage Point로 검증 범위를 수치화

## 기능

- 32-bit AXI4-Lite Slave 인터페이스 설계
- AW, W, B, AR, R 채널 분리 기반 트랜잭션 처리
- Read FSM / Write FSM 기반 제어 로직 구현
- `WSTRB`를 이용한 Byte-enable Write 지원
- Control, Status, Config, Error, Data Register를 포함한 16개 레지스터 맵 구성
- 주소와 데이터의 순차, 역순, 동시 도착을 처리하는 쓰기 경로 지원
- Directed Testbench 기반 기능 검증
- SVA 기반 프로토콜 Assertion 및 Coverage 수집

## 기술 스택

| 구분 | 내용 |
| --- | --- |
| 언어 | SystemVerilog |
| 설계 방식 | RTL Design, Parameterized Module |
| 프로토콜 | AXI4-Lite |
| 검증 방식 | Directed Testbench, SystemVerilog Assertions (SVA) |

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

## 주요 파일

- [`src/axi_top.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_top.sv): AXI Slave와 Register Map을 연결하는 Top Module
- [`src/axi_lite_slave.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_lite_slave.sv): AXI4-Lite 읽기/쓰기 제어 로직
- [`src/axi_register_map.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/src/axi_register_map.sv): 레지스터 맵 및 데이터 저장 구조
- [`sim/tb_axi.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/tb_axi.sv): Directed 기능 검증용 테스트벤치
- [`sim/axi_sva.sv`](/c:/Users/rlaqj/Project/AXI4_Lite/sim/axi_sva.sv): AXI4-Lite 프로토콜 Assertion 및 Coverage

## 결과

- AXI4-Lite Slave, Register Map, Top Module로 구성된 설계 자산 구축
- Testbench와 SVA Monitor로 구성된 검증 자산 구축
- 32-bit 데이터 폭과 16개 레지스터 공간을 갖는 Register-mapped 구조 구현
- 11개 Assertion으로 VALID 유지, 데이터 안정성, Reset 동작, Write 순서 제약 검증
- 6개 Coverage Point로 주요 handshake 및 back-to-back write 시나리오 관찰 가능

## 참고

- 보드 제약 파일: [`constraints/Zybo-Z7-Master.xdc`](/c:/Users/rlaqj/Project/AXI4_Lite/constraints/Zybo-Z7-Master.xdc)
- 프로젝트 문서: [`docs/0. AXI4-Lite Portfolio.pdf`](/c:/Users/rlaqj/Project/AXI4_Lite/docs/0.%20AXI4-Lite%20Portfolio.pdf)