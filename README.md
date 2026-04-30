# AXI4-Lite Slave Design Project

## 프로젝트 개요

AXI4_Lite는 32-bit AXI4-Lite slave와 16-entry register map을 직접 구현하고, directed testbench와 SystemVerilog Assertions(SVA)로 기능 및 protocol 안정성을 검증하는 RTL 프로젝트입니다. AW/W 도착 순서가 다른 write transaction과 read/write backpressure 상황을 중점적으로 다룹니다.

## 주요 특징

- AXI4-Lite AW, W, B, AR, R 5개 채널 handshake 구현
- `AW -> W`, `W -> AW`, `AW + W` same-cycle write 지원
- 16개 memory-mapped register와 `WSTRB` 기반 byte write 지원
- 기능 시나리오 TB와 protocol SVA를 분리한 검증 구조
- `VALID/READY` 유지, payload 안정성, bounded response assertion 포함

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

## 검증 결과 요약

- Directed scenario 5종: AW-first write, W-first write, same-cycle write, B backpressure, R backpressure
- Register readback checker로 write data와 status register 값을 자동 비교
- SVA로 AXI4-Lite channel별 valid 유지, payload hold, response 도착 시간, response code 범위 확인
- 기존 검증 시나리오 기준 모든 directed test와 SVA 통과를 목표로 구성
