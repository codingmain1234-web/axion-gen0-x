# AXION Gen0-X

AXION Gen0-X는 GEN0-P보다 Lane 수와 이론상 INT8 처리량을 두 배로 높인
Tiny Tapeout용 연산 프로토타입입니다. 완성형 GPU가 아니라 8-Lane V-Core와
파이프라인 DOT8 SA-Core를 실제 실리콘에서 검증하기 위한 칩입니다.

## 목표 사양

- Tiny Tapeout TTGF26c / GF180MCU 공정
- `2x2` 타일, 최종 GDS 전 예상 할당 면적 약 0.22 mm²
- 보장 목표 16 MHz, 20 MHz는 signoff 이후 실험 목표
- SIMD8 V-Core 8 Lane
- 공유 Signed INT8 곱셈기 8개
- DOT8 MAC과 Signed 40-bit Accumulator
- 파이프라인이 채워진 뒤 매 클럭 DOT8 하나 접수
- 16 MHz에서 이론상 128 MMAC/s
- ReLU, INT8 Saturation, 자체진단 기능

## 성능 의미

`8 MAC × 16 MHz = 128 MMAC/s`입니다. 곱셈과 덧셈을 각각 한 연산으로
세면 256 MOPS입니다. DOT8 결과 하나의 지연시간은 5클럭이지만, 연속
명령은 파이프라인을 통해 매 클럭 접수할 수 있습니다.

## 사용 방식

`ui_in`으로 한 바이트 데이터를 넣고 `uio_in`으로 명령을 보냅니다.
A/B 레지스터는 각각 8바이트이며, SIMD 결과 8바이트와 누산기 5바이트를
명령으로 한 바이트씩 읽습니다. 전체 명령표는 `README.md`에 있습니다.

현재 상태는 RTL 후보입니다. RTL 테스트, 합성, `2x2` 면적, 16 MHz
타이밍, DRC/LVS, Gate-Level Test가 모두 통과하기 전에는 제작 가능하다고
판정하지 않습니다.
