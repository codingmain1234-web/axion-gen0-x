# AXION Gen0-X

AXION Gen0-X는 GEN0-P보다 Lane 수와 이론상 INT8 처리량을 두 배로 높인
Tiny Tapeout용 연산 프로토타입입니다. 완성형 GPU가 아니라 8-Lane V-Core와
파이프라인 DOT8 SA-Core를 실제 실리콘에서 검증하기 위한 칩입니다.

## 확정 사양

- Tiny Tapeout TTGF26c / GF180MCU 공정
- `2x2` 타일, 최종 다이 면적 0.231396 mm²
- 보장 목표 15.5 MHz, 16 MHz 이상은 signoff 이후 실험 목표
- SIMD8 V-Core 8 Lane
- 공유 Signed INT8 곱셈기 8개
- DOT8 MAC과 Signed 40-bit Accumulator
- 파이프라인이 채워진 뒤 매 클럭 DOT8 하나 접수
- 15.5 MHz에서 이론상 124 MMAC/s
- ReLU, INT8 Saturation, 자체진단 기능

## 성능 의미

`8 MAC × 15.5 MHz = 124 MMAC/s`입니다. 곱셈과 덧셈을 각각 한 연산으로
세면 248 MOPS입니다. 입력 명령 등록 단계를 포함한 DOT8 결과 하나의
지연시간은 6클럭이지만, 연속
명령은 파이프라인을 통해 매 클럭 접수할 수 있습니다.

## 사용 방식

`ui_in`으로 한 바이트 데이터를 넣고 `uio_in`으로 명령을 보냅니다.
A/B 레지스터는 각각 8바이트이며, SIMD 결과 8바이트와 누산기 5바이트를
명령으로 한 바이트씩 읽습니다. 전체 명령표는 `README.md`에 있습니다.

## 최종 검증 결과

공식 GitHub Actions에서 RTL Test, GDS Build, Tiny Tapeout Precheck와
Gate-Level Test가 모두 통과했습니다. 15.5 MHz 기준 최악 Setup 여유는
1.075 ns, Hold 여유는 0.470 ns이며 타이밍 위반은 0개입니다. 최종 배선
DRC, Magic DRC, LVS, 안테나 위반도 모두 0개입니다. 표준 셀은 9,117개,
사용률은 85.73%입니다.

따라서 v0.1은 물리 검증을 통과한 테이프아웃 후보입니다. 아직 Tiny
Tapeout 제출 양식 작성, 결제 또는 실제 제작 주문까지 완료된 것은 아닙니다.
