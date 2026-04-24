# STM32N6 Module — System Requirements

Design-level requirements for the STM32N657L0H3Q module. Use this page as
the rubric when walking through each section during review.

## Power

- **VDD rail** must be 1.71–1.90 V under all load conditions (per datasheet §4.6).
- At least 1× 100 nF decoupling capacitor within 2 mm of every VDD pin.
- VBAT must be tied to VDD when no RTC backup battery is fitted.
- Inrush limited via soft-start on the input buck; peak < 2 A.

## Clocking

- HSE crystal: 24 MHz ±20 ppm, loading caps per AN2867.
- LSE crystal: 32.768 kHz, low-ESR footprint (2012 or smaller).
- MCO1 pin reserved for future PLL debug pad.

## USB

- USB-C receptacle with CC1/CC2 resistors to advertise default (5 V, 500 mA).
- ESD protection on D+/D- (e.g. USBLC6-2SC6 or equivalent).
- Shield tied to chassis ground through a 1 MΩ bleed + 100 nF (hybrid).

## Debug & Boot

- SWD header (4-pin) exposed on board edge.
- BOOT0 pulled down with option strap to bring to BOOT1 for DFU.
- UART1 TX/RX broken out to a Tag-Connect footprint.

## Compliance

- Conforms to IPC-2221 clearances for Class 2 boards.
- Trace widths sized for 1 A / 20 °C rise per IPC-2152.
