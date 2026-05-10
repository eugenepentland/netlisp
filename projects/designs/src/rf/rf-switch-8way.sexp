(import pe42582)
(import sma-j-p-h-st-em1)
(import w5500-evb-pico)

(design-block "PE42582 1:8 RF Switch, DC-6GHz"

  ;; SP8T absorptive switch, 9kHz-8GHz.
  ;; Compliance vs. lib/components/pe42582.sexp requirements:
  ;;   - VDD pin 8 → 3V3 from W5500-EVB-PICO (within 2.3-5.5V)
  ;;   - VSS_EXT pin 7 → GND directly (normal mode, internal -V gen)
  ;;   - V1..V4 (pins 9-12) and LS (pin 1) driven by RP2040 GPIO (3.3V CMOS,
  ;;     clears VIH=1.17V / VIL=0.6V; well under 3.6V abs-max)
  ;;   - NC pin 20 → GND (datasheet permits "open or GND only")
  ;;   - All seven GND pins (3,5,14,16,18,21,23) plus EP (pin 25) → GND
  (instance "U1" pe42582
    (pin 1 "LS")
    (pin 2 "RF2")
    (pin 3 5 14 16 18 21 23 25 "GND")
    (pin 4 "RF3")
    (pin 6 "RF4")
    (pin 7 "GND")
    (pin 8 "VDD")
    (pin 9 "V1")
    (pin 10 "V2")
    (pin 11 "V3")
    (pin 12 "V4")
    (pin 13 "RF5")
    (pin 15 "RF6")
    (pin 17 "RF7")
    (pin 19 "RF8")
    (pin 20 "GND")
    (pin 22 "RFC")
    (pin 24 "RF1") (id ea6a128c))

  ;; Host controller — supplies the 3V3 VDD rail and drives the SP8T's
  ;; control bus over GPIO. USB-C on the module is the user-facing power
  ;; and command interface, so this board has no separate power port.
  (instance "U2" w5500-evb-pico
    (pin 4 "V1")           ;; GP2 → V1
    (pin 5 "V2")           ;; GP3 → V2
    (pin 6 "V3")           ;; GP4 → V3
    (pin 7 "V4")           ;; GP5 → V4
    (pin 9 "LS")           ;; GP6 → LS
    (pin 14 "LED1_DRV")    ;; GP10 → RF1 active LED
    (pin 15 "LED2_DRV")    ;; GP11 → RF2 active LED
    (pin 16 "LED3_DRV")    ;; GP12 → RF3 active LED
    (pin 17 "LED4_DRV")    ;; GP13 → RF4 active LED
    (pin 19 "LED5_DRV")    ;; GP14 → RF5 active LED
    (pin 20 "LED6_DRV")    ;; GP15 → RF6 active LED
    (pin 21 "LED7_DRV")    ;; GP16 → RF7 active LED
    (pin 22 "LED8_DRV")    ;; GP17 → RF8 active LED
    (pin 36 "VDD")         ;; 3V3 out → PE42582 VDD
    (pin 3 8 13 18 23 28 33 38 42 "GND") (id a56ef308))

  ;; Common port (RFC) SMA jack
  (instance "J1" sma-j-p-h-st-em1
    (pin 1 "RFC")
    (pin 2 3 "GND") (id c30f6080))

  ;; Per-port output SMAs — RF1..RF8
  (instance "J2" sma-j-p-h-st-em1
    (pin 1 "RF1")
    (pin 2 3 "GND") (id e45ab954))

  (instance "J3" sma-j-p-h-st-em1
    (pin 1 "RF2")
    (pin 2 3 "GND") (id da0db92b))

  (instance "J4" sma-j-p-h-st-em1
    (pin 1 "RF3")
    (pin 2 3 "GND") (id b2a90b6b))

  (instance "J5" sma-j-p-h-st-em1
    (pin 1 "RF4")
    (pin 2 3 "GND") (id a771dba2))

  (instance "J6" sma-j-p-h-st-em1
    (pin 1 "RF5")
    (pin 2 3 "GND") (id b7398e3d))

  (instance "J7" sma-j-p-h-st-em1
    (pin 1 "RF6")
    (pin 2 3 "GND") (id ec3d33c8))

  (instance "J8" sma-j-p-h-st-em1
    (pin 1 "RF7")
    (pin 2 3 "GND") (id a5a680be))

  (instance "J9" sma-j-p-h-st-em1
    (pin 1 "RF8")
    (pin 2 3 "GND") (id c7a6b264))

  ;; VDD decoupling — place close to U1 pin 8
  (instance "C1" (cap-0603 "10uF")
    (pin 1 "VDD")
    (pin 2 "GND") (id acebe1e2))

  (instance "C2" (cap-0402 "100nF")
    (pin 1 "VDD")
    (pin 2 "GND") (id e363416c))

  (instance "C3" (cap-0402 "10nF")
    (pin 1 "VDD")
    (pin 2 "GND") (id b852547f))

  ;; Per-port active indicators — one LED per output SMA, driven high by
  ;; the matching RP2040 GPIO. ~1.3 mA each at 3.3V (green Vf ~2.0V),
  ;; well under the RP2040 12 mA/pin source limit. Firmware mirrors the
  ;; selected truth-table state onto the LED bus.
  (instance "R1" (res-0402 "1k")
    (pin 1 "LED1_DRV")
    (pin 2 "LED1_A") (id fd1d39b3))
  (instance "D1" (led-0402 "green")
    (pin 1 "LED1_A")
    (pin 2 "GND") (id ae65ad86))

  (instance "R2" (res-0402 "1k")
    (pin 1 "LED2_DRV")
    (pin 2 "LED2_A") (id c18e270a))
  (instance "D2" (led-0402 "green")
    (pin 1 "LED2_A")
    (pin 2 "GND") (id b9f7c8ad))

  (instance "R3" (res-0402 "1k")
    (pin 1 "LED3_DRV")
    (pin 2 "LED3_A") (id dbc9e8a1))
  (instance "D3" (led-0402 "green")
    (pin 1 "LED3_A")
    (pin 2 "GND") (id afab3266))

  (instance "R4" (res-0402 "1k")
    (pin 1 "LED4_DRV")
    (pin 2 "LED4_A") (id b8efe993))
  (instance "D4" (led-0402 "green")
    (pin 1 "LED4_A")
    (pin 2 "GND") (id b716abdb))

  (instance "R5" (res-0402 "1k")
    (pin 1 "LED5_DRV")
    (pin 2 "LED5_A") (id a13fe012))
  (instance "D5" (led-0402 "green")
    (pin 1 "LED5_A")
    (pin 2 "GND") (id ac7d447c))

  (instance "R6" (res-0402 "1k")
    (pin 1 "LED6_DRV")
    (pin 2 "LED6_A") (id c65aece8))
  (instance "D6" (led-0402 "green")
    (pin 1 "LED6_A")
    (pin 2 "GND") (id da1599e7))

  (instance "R7" (res-0402 "1k")
    (pin 1 "LED7_DRV")
    (pin 2 "LED7_A") (id f70d23ab))
  (instance "D7" (led-0402 "green")
    (pin 1 "LED7_A")
    (pin 2 "GND") (id d5bd89a5))

  (instance "R8" (res-0402 "1k")
    (pin 1 "LED8_DRV")
    (pin 2 "LED8_A") (id c26ae656))
  (instance "D8" (led-0402 "green")
    (pin 1 "LED8_A")
    (pin 2 "GND") (id d29741c3))

  ;; External ports — RF I/O terminates at SMA connectors and control/power
  ;; are supplied internally by U2, so only GND is exposed for chassis bonding.
  (port "GND" bidi)

  ;; Notes
  (note "U1" "PE42582: SP8T absorptive, 9kHz-8GHz, 1.1dB IL @ 6GHz, 41dB isolation @ 6GHz, 33dBm CW. V1-V4 + LS select one of eight RF ports or all-off. EP (pin 25) tied to GND for thermal + RF grounding (theta_JA = 63 C/W). VSS_EXT (pin 7) tied directly to GND for normal mode (internal negative voltage generator). NC (pin 20) tied to GND. Hot-switching power must stay <=20 dBm above 100 MHz; mute the source before changing port selection if it can exceed that.")
  (note "U2" "W5500-EVB-PICO: RP2040 + W5500 module. Drives PE42582 control: V1=GP2, V2=GP3, V3=GP4, V4=GP5, LS=GP6 (3.3V CMOS, clears VIH=1.17V / VIL=0.6V; well below the 3.6V abs-max on the control inputs). Per-port active LEDs are driven by GP10..GP17 (LED1..LED8) — firmware mirrors the truth-table selection onto these outputs. Pin 36 (3V3 out, ~300mA budget) supplies the PE42582 VDD rail (only a few mA quiescent). Powered from the on-module USB-C, which doubles as the host control interface.")
  (note "J1" "SMA jack for the RFC common port. Keep the trace from U1 pin 22 to this connector short; 50ohm grounded coplanar waveguide recommended.")
  (note "J2" "SMA jack for RF1 (U1 pin 24). Length-match RF1..RF8 traces if relative phase between ports matters in the application.")
  (note "J3" "SMA jack for RF2 (U1 pin 2).")
  (note "J4" "SMA jack for RF3 (U1 pin 4).")
  (note "J5" "SMA jack for RF4 (U1 pin 6).")
  (note "J6" "SMA jack for RF5 (U1 pin 13).")
  (note "J7" "SMA jack for RF6 (U1 pin 15).")
  (note "J8" "SMA jack for RF7 (U1 pin 17).")
  (note "J9" "SMA jack for RF8 (U1 pin 19).")
  (note "C1" "Bulk VDD decoupling, 10uF.")
  (note "C2" "VDD decoupling 100nF, place within ~2mm of U1 pin 8.")
  (note "C3" "VDD decoupling 10nF, place within ~2mm of U1 pin 8.")
  (note "D1" "RF1 active indicator. Place near J2.")
  (note "D2" "RF2 active indicator. Place near J3.")
  (note "D3" "RF3 active indicator. Place near J4.")
  (note "D4" "RF4 active indicator. Place near J5.")
  (note "D5" "RF5 active indicator. Place near J6.")
  (note "D6" "RF6 active indicator. Place near J7.")
  (note "D7" "RF7 active indicator. Place near J8.")
  (note "D8" "RF8 active indicator. Place near J9.")

  ;; Groups
  (group "RF Switch"       ("U1"))
  (group "VDD Decoupling"  ("C1" "C2" "C3"))
  (group "Host Controller" ("U2"))
  (group "RF Connectors"   ("J1" "J2" "J3" "J4" "J5" "J6" "J7" "J8" "J9"))
  (group "RF Indicators"   ("D1" "D2" "D3" "D4" "D5" "D6" "D7" "D8"
                            "R1" "R2" "R3" "R4" "R5" "R6" "R7" "R8")))
