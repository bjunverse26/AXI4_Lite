# AXI4_Lite

간단한 AXI4-Lite Slave + Register Map + Testbench 연습 프로젝트입니다.

## 구성
- `src/axi_lite_slave.sv`: AXI4-Lite read/write FSM
- `src/axi_register_map.sv`: 레지스터 맵
- `src/axi_top.sv`: 상위 통합 모듈
- `sim/tb_axi.sv`: 테스트벤치
- `constraints/Zybo-Z7-Master.xdc`: 보드 제약 파일

## 참고
- TB 클럭: 100MHz (`#5` 토글, 10ns 주기)