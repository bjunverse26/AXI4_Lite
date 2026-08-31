# AXI4-Lite Slave with Register Map

32-bit AXI4-Lite slave와 16-word register map을 SystemVerilog로 구현한 RTL 프로젝트입니다. 주소와 데이터가 독립적으로 전달되는 AXI write 특성을 상태기계로 처리하고, directed testbench와 SystemVerilog Assertions(SVA)로 handshake와 backpressure 동작을 검증합니다.

## 설계 핵심

- AW와 W 채널을 독립적으로 수락해 `AW → W`, `W → AW`, same-cycle write를 모두 지원합니다.
- Read와 write 경로를 별도 상태기계로 구성해 두 방향이 독립적으로 진행됩니다.
- `BVALID`과 `RVALID`은 상대 채널의 `READY`가 들어올 때까지 유지됩니다.
- 32-bit register write에 4-bit `WSTRB` byte enable을 적용합니다.
- 기능 checker와 AXI protocol SVA를 분리해 데이터와 protocol rule을 각각 확인합니다.

## Architecture

```text
AXI4-Lite Master
  ├─ AW / W / B ──> AxiLiteSlave ──> write data · strobe · one-hot enable
  └─ AR / R     <── AxiLiteSlave <── register read-data array
                                      │
                                      ▼
                               AxiRegisterMap
                         control / status / config / error
                              + 12 data registers
```

`AxiLiteSlave`는 channel ordering과 response를 담당하고, `AxiRegisterMap`은 register access와 byte write를 담당합니다. 한 방향당 한 transaction을 처리하며, write response와 read response는 서로 독립적입니다.

## 기본 사양

| 항목 | 내용 |
| --- | --- |
| AXI data/address width | 32-bit / 32-bit |
| Register 수 | 16 words |
| Write response | `OKAY` |
| Invalid read | `32'hDEAD_BEEF`, `OKAY` |
| Write granularity | `WSTRB[3:0]` 기반 byte write |
| RTL top | `rtl/AxiTop.sv` |
| Testbench top | `tb/TbAxiSva.sv` |

## Register Map

| Offset | 이름 | Access | 동작 |
| ---: | --- | :---: | --- |
| `0x00` | `CONTROL` | R/W | Byte strobe가 적용되는 control register |
| `0x04` | `STATUS` | R | Top input으로 들어오는 status 값 |
| `0x08` | `CONFIG` | R/W | Byte strobe가 적용되는 config register |
| `0x0C` | `ERROR` | R | Top input으로 들어오는 error 값 |
| `0x10`–`0x3C` | `DATA[0:11]` | R/W | 범용 32-bit data registers |

Read-only register에 대한 write와 map 밖의 write는 상태를 바꾸지 않으며 response는 `OKAY`입니다. Map 밖의 read는 `DEAD_BEEF`를 반환합니다.

## Verification

| 검증 항목 | Stimulus | 확인 내용 |
| --- | --- | --- |
| AW-first write | AW handshake 후 W 전달 | `CONTROL` write/readback, `OKAY` |
| W-first write | W handshake 후 AW 전달 | `CONFIG` write/readback, `OKAY` |
| Same-cycle write | AW와 W 동시 전달 | Data와 response 일치 |
| B backpressure | `BREADY`를 3 cycle 지연 | `BVALID`과 `BRESP` 유지 |
| R backpressure | `RREADY`를 3 cycle 지연 | `RVALID`, `RDATA`, `RRESP` 유지 |

`tb/AxiProtocolSva.sv`는 다음 protocol property를 검사합니다.

- `VALID`이 handshake 전에 내려가지 않는지 확인
- Wait 상태에서 address, data, strobe, response payload가 유지되는지 확인
- 수락된 read/write에 bounded response가 발생하는지 확인
- `BRESP`와 `RRESP`가 정의된 response code인지 확인

Testbench는 self-checking 방식이며 directed checker가 모두 통과하면 `*** ALL TESTS PASSED ***`를 출력하고 종료 코드 0으로 끝납니다. SVA는 별도의 failure count와 최종 summary를 출력합니다. 검증 범위는 현재 directed simulation과 SVA이며 formal 또는 synthesis 결과를 의미하지 않습니다.

## Simulation

SystemVerilog interface, queue, SVA를 지원하는 simulator가 필요합니다.

1. `rtl/AxiRegisterMap.sv`, `rtl/AxiLiteSlave.sv`, `rtl/AxiTop.sv`를 design source로 추가합니다.
2. `tb/AxiProtocolSva.sv`, `tb/TbAxiSva.sv`를 simulation source로 추가합니다.
3. Simulation top을 `TbAxiSva`로 지정하고 testbench가 `$finish`할 때까지 실행합니다.

도구별 실행 script는 포함되어 있지 않으므로 compile/elaboration option은 사용하는 simulator에 맞게 지정해야 합니다.

## Repository Guide

| 경로 | 내용 |
| --- | --- |
| `rtl/AxiLiteSlave.sv` | AXI4-Lite read/write protocol engine |
| `rtl/AxiRegisterMap.sv` | 16-word register bank와 byte write |
| `rtl/AxiTop.sv` | Protocol engine과 register map 통합 |
| `tb/TbAxiSva.sv` | Directed self-checking testbench |
| `tb/AxiProtocolSva.sv` | AXI channel assertions와 coverage |
| [`docs/0. AXI4-Lite Portfolio.pdf`](docs/0.%20AXI4-Lite%20Portfolio.pdf) | 설계 설명 자료 |

## License

This project is distributed under the [MIT License](LICENSE).
