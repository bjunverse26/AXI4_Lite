# AXI4-Lite Slave Design Project

32-bit AXI4-Lite Slave, Register Map, Testbench, 그리고 SVA 기반 프로토콜 검증을 포함한 RTL 설계 프로젝트입니다.

## 헤더

**프로젝트 제목**  
AXI4-Lite Slave Verification Project

**한줄 설명**  
32-bit AXI4-Lite Slave와 16개 레지스터 맵을 설계하고, Directed Testbench와 SVA를 통해 읽기/쓰기 동작 및 프로토콜 준수를 검증한 프로젝트입니다.

## 핵심 성과

### 1. 기능 검증 중심에서 프로토콜 검증까지 확장
- Before: 읽기/쓰기 결과 확인 위주의 기능 검증에 의존
- After: `sim/axi_sva.sv`에 **11개의 Assertion**과 **6개의 Coverage Point**를 추가해 handshake, stability, reset, transaction order를 자동 검증

### 2. 단순 레지스터 접근에서 구조화된 16개 레지스터 맵으로 확장
- Before: 핵심 제어/상태 레지스터 중심의 제한적인 검증 구조
- After: `src/axi_register_map.sv`에 **4개의 주요 레지스터**와 **12개의 데이터 레지스터**를 포함한 **총 16개 주소 공간** 구현

### 3. 쓰기 경로를 다양한 AXI4-Lite 타이밍 케이스까지 대응하도록 개선
- Before: 단일 쓰기 순서만 가정할 경우 정상적인 버스 시나리오 일부를 놓칠 수 있음
- After: `src/axi_lite_slave.sv`에서 **3가지 쓰기 도착 케이스**(`AW->W`, `W->AW`, `AW+W 동시`)를 처리하도록 FSM 구성

### 4. 검증 결과를 수치로 설명 가능한 형태로 구체화
- Before: 프로젝트 설명만으로는 검증 범위와 결과를 한눈에 파악하기 어려움
- After: `sim/tb_axi.sv`에서 **4개 주요 시나리오**, **5개 데이터 검증 케이스**를 수행하도록 구성해 검증 범위를 명확히 제시

## 기능

- 32-bit AXI4-Lite Slave 인터페이스 구현
- AW, W, B, AR, R 채널 분리 기반의 표준 AXI4-Lite 트랜잭션 처리
- `WSTRB`를 이용한 Byte-enable Write 지원
- Read FSM / Write FSM 기반 제어 로직 구현
- Control, Status, Config, Error 및 Data Register를 포함한 16개 레지스터 맵 구성
- 주소와 데이터가 순차적 또는 역순으로 도착하는 쓰기 시나리오 지원
- Directed Testbench 기반 읽기/쓰기 검증
- SVA 기반 프로토콜 체크 및 Coverage 수집

## 기술 스택

- **언어**: SystemVerilog
- **설계 방식**: RTL Design, Parameterized Module
- **프로토콜**: AXI4-Lite
- **검증 방식**: Directed Testbench, SystemVerilog Assertions (SVA)

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