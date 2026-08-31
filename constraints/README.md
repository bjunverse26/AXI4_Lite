# Constraints

이 저장소는 AXI4-Lite RTL과 프로토콜 검증을 중심으로 정리되어 있으며, 특정 FPGA 보드의 pin assignment는 포함하지 않습니다.

FPGA implementation을 수행할 때는 대상 top module과 보드에 맞춰 다음 항목을 별도로 정의해야 합니다.

- `i_aclk`의 clock period
- `i_aresetn`의 reset timing policy
- AXI interface I/O 또는 상위 SoC block 연결 조건

Target design이 확정되면 해당 구성에서 사용한 timing constraints와 implementation report를 함께 관리합니다.
