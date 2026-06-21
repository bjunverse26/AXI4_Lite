# AXI4-Lite Slave Design Project

## 프로젝트 개요

AXI4_Lite는 32-bit AXI4-Lite slave와 16-entry register map을 직접 구현하고, directed testbench와 SystemVerilog Assertions(SVA)로 기능과 프로토콜 안정성을 검증한 RTL 프로젝트입니다. AW/W 도착 순서가 다른 write transaction과 read/write backpressure 상황을 중점적으로 다룹니다.

## 주요 특징

- AXI4-Lite AW, W, B, AR, R 5개 채널 handshake를 구현했습니다.
- `AW -> W`, `W -> AW`, `AW + W` same-cycle write를 지원합니다.
- 16개 memory-mapped register와 `WSTRB` 기반 byte write를 구현했습니다.
- 기능 시나리오 testbench와 프로토콜 SVA를 분리했습니다.
- `VALID/READY` 유지, payload 안정성, bounded response assertion을 구성했습니다.

## 상세 스펙

| 항목 | 내용 |
| --- | --- |
| 데이터 폭 | 32-bit |
| 주소 폭 | 32-bit |
| Register 개수 | 16개 |
| Register 구성 | control, status, config, error, data[0:11] |
| Write response | OKAY |
| Read invalid address | `32'hDEAD_BEEF` 반환 |
| RTL | `rtl/AxiTop.sv`, `rtl/AxiLiteSlave.sv`, `rtl/AxiRegisterMap.sv` |
| 검증 | `tb/TbAxiSva.sv`, `tb/AxiProtocolSva.sv` |

## 검증 및 결과

- AW-first, W-first, same-cycle write와 B/R backpressure를 포함한 directed scenario 5종을 구성했습니다.
- Register readback checker로 write data와 status register 값을 자동 비교했습니다.
- SVA로 채널별 `VALID` 유지, payload hold, response 도착 시간과 response code 범위를 검증했습니다.
