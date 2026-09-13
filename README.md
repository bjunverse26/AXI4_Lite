# AXI4-Lite Slave와 Register Map

32-bit AXI4-Lite slave와 16-word register bank를 SystemVerilog로 구현한 프로젝트입니다. 독립적으로 전달되는 write address와 write data를 하나의 write transaction으로 처리합니다.

## 설계 핵심

- AW와 W를 순서와 관계없이 독립적으로 수락
- Read와 write에 별도 state machine 적용
- Backpressure 동안 `BVALID`, `RVALID`, response payload 유지
- `WSTRB[3:0]` 기반 byte write 지원

`AxiLiteSlave`는 channel ordering과 response를 처리하고, `AxiRegisterMap`은 16개 register의 read/write 동작을 담당합니다.

## Register Map

| Offset | 이름 | 접근 | 동작 |
| ---: | --- | :---: | --- |
| `0x00` | `CONTROL` | R/W | Byte write를 지원하는 control register |
| `0x04` | `STATUS` | R | `AxiTop`에서 고정한 sample status 값 |
| `0x08` | `CONFIG` | R/W | Byte write를 지원하는 configuration register |
| `0x0C` | `ERROR` | R | `AxiTop`에서 고정한 sample error 값 |
| `0x10` to `0x3C` | `DATA[0:11]` | R/W | 범용 data register |

## 파일 구성

| 경로 | 내용 |
| --- | --- |
| `rtl/axi_lite_slave.sv` | AXI4-Lite protocol engine |
| `rtl/axi_register_map.sv` | 16-word register bank |
| `rtl/axi_top.sv` | 통합 예제 |
| [설계 설명 자료](docs/axi4_lite_portfolio.pdf) | Portfolio PDF |

## 라이선스

이 프로젝트는 [MIT License](LICENSE)를 따릅니다.
