(import pe42582)
(import grf1-j-p-08-e-ra-th1-e)
(import sma-j-p-h-st-em1)
(import cap-0402)

(design-block "PE42582 1:8 RF Switch, DC-6GHz"

  ;; SP8T absorptive switch, 9kHz-8GHz
  (instance "U1" pe42582
    (pin 1 "LS")
    (pin 2 "RF2")
    (pin 3 5 14 16 18 21 23 25 "GND")
    (pin 4 "RF3")
    (pin 6 "RF4")
    (pin 7 "VSS_EXT")
    (pin 8 "VDD")
    (pin 9 "V1")
    (pin 10 "V2")
    (pin 11 "V3")
    (pin 12 "V4")
    (pin 13 "RF5")
    (pin 15 "RF6")
    (pin 17 "RF7")
    (pin 19 "RF8")
    (pin 20 "NC")
    (pin 22 "RFC")
    (pin 24 "RF1") (id ea6a128c))

  ;; Common port (RFC) SMA connector
  (instance "J1" sma-j-p-h-st-em1
    (pin 1 "RFC")
    (pin 2 3 "GND") (id c30f6080))

  ;; 8-port ganged MMCX for RF1-RF8
  ;; Each port has 1 signal pin (X.1) and 4 ground shield pins (X.2-X.5)
  (instance "J2" grf1-j-p-08-e-ra-th1-e
    (pin A1 "RF1")
    (pin A2 A3 A4 A5 "GND")
    (pin B1 "RF2")
    (pin B2 B3 B4 B5 "GND")
    (pin C1 "RF3")
    (pin C2 C3 C4 C5 "GND")
    (pin D1 "RF4")
    (pin D2 D3 D4 D5 "GND")
    (pin E1 "RF5")
    (pin E2 E3 E4 E5 "GND")
    (pin F1 "RF6")
    (pin F2 F3 F4 F5 "GND")
    (pin G1 "RF7")
    (pin G2 G3 G4 G5 "GND")
    (pin H1 "RF8")
    (pin H2 H3 H4 H5 "GND")
    (pin MH1 MH2 MH3 MH4 MH5 MH6 MH7 MH8 "GND") (id cf8187c8))

  ;; VDD decoupling - place close to pin 8
  (instance "C1" (cap-0402 "10uF")
    (pin 1 "VDD")
    (pin 2 "GND") (id acebe1e2))

  (instance "C2" (cap-0402 "100nF")
    (pin 1 "VDD")
    (pin 2 "GND") (id e363416c))

  (instance "C3" (cap-0402 "10nF")
    (pin 1 "VDD")
    (pin 2 "GND") (id b852547f))

  ;; VSS_EXT bypass - smooths the internal negative voltage generator.
  ;; For spur-free instrumentation use, replace with an external -3.3V rail.
  (instance "C4" (cap-0402 "100nF")
    (pin 1 "VSS_EXT")
    (pin 2 "GND") (id b23aaa77))

  ;; External ports
  (port "RFC" bidi)
  (port "RF1" bidi)
  (port "RF2" bidi)
  (port "RF3" bidi)
  (port "RF4" bidi)
  (port "RF5" bidi)
  (port "RF6" bidi)
  (port "RF7" bidi)
  (port "RF8" bidi)
  (port "VDD" in (rated 2.3 5.5))
  (port "V1"  in)
  (port "V2"  in)
  (port "V3"  in)
  (port "V4"  in)
  (port "LS"  in)
  (port "GND" bidi)

  ;; Notes
  (note "U1" "PE42582: SP8T absorptive, 9kHz-8GHz, 1.1dB IL @ 6GHz, 41dB isolation @ 6GHz, 33dBm CW. V1-V4 + LS select one of eight RF ports or all-off state. Exposed pad (pin 25) must be soldered to GND copper for thermal + RF grounding.")
  (note "J1" "SMA jack for the common (RFC) port. Keep the trace from RFC to this connector short; 50ohm grounded coplanar waveguide recommended.")
  (note "J2" "Samtec GRF1-J-P-08-E-RA-TH1-E: 8-way ganged MMCX (1 physical part = 8 RF outputs). X.1 is signal, X.2-X.5 are shield grounds. Route RF1..RF8 as symmetric, length-matched 50ohm GCPW traces.")
  (note "C1" "Bulk VDD decoupling, 10uF.")
  (note "C2" "VDD decoupling 100nF, place within ~2mm of pin 8.")
  (note "C3" "VDD decoupling 10nF, place within ~2mm of pin 8.")
  (note "C4" "VSS_EXT bypass 100nF. Keeps internal negative charge pump quiet. For best spur performance, drive VSS_EXT from an external low-noise -3.3V supply instead.")

  ;; Groups
  (group "VDD Decoupling" ("C1" "C2" "C3"))
  (group "VSS_EXT Bypass" ("C4"))
  (group "RF Connectors"  ("J1" "J2")))
