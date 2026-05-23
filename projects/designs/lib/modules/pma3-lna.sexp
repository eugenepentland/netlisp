(import pma3-24323ln+)

;; PMA3-24323LN+ — 24-32 GHz wideband K-band LNA (+16 dB gain, NF 3.1 dB),
;; single-ended 50 Ω in / 50 Ω out. Sealed as a module because both RX beams
;; use an electrically identical LNA; only the antenna-side (RFIN) and
;; ADF5904-side (LNAOUT) nets differ, which the parent supplies via the bridge.
;;
;; Per-pin VDD bias — each of the four VDD pins is fed from V5P0 through its
;; own series resistor with a 100pF decoupling cap to GND:
;;   pins 6 & 10 → 24R 0402 + 100pF 0201
;;   pins 4 & 12 → 39R 0201 + 100pF 0402
(defmodule pma3-lna ()
  "PMA3-24323LN+ K-band LNA: 24-32 GHz, +16 dB, NF 3.1 dB. Per-pin VDD bias."
  (design-block "PMA3-24323LN+ LNA"

    (instance "U1" pma3-24323ln+
      (pin 1 3 7 9 13 "GND")
      (pin 2 "RFIN")                 ;; RF-IN — 50 Ω
      (pin 8 "LNAOUT")               ;; RF-OUT — 50 Ω matched
      (pin 4 "VDD_4")                ;; VDD3 — 39R bias
      (pin 6 "VDD_6")                ;; VDD4 — 24R bias
      (pin 10 "VDD_10")              ;; VDD2 — 24R bias
      (pin 12 "VDD_12")              ;; VDD1 — 39R bias
      (pin 5 "NC1")                  ;; NC
      (pin 11 "NC2"))                ;; NC

    ;; Per-pin VDD bias: series R from V5P0 + HF decoupling cap to GND.
    (series "R_VDD_6"  (res-0402 "24R")   "V5P0" "VDD_6")
    (series "C_VDD_6"  (cap-0201 "100pF") "VDD_6"    "GND")
    (series "R_VDD_10" (res-0402 "24R")   "V5P0" "VDD_10")
    (series "C_VDD_10" (cap-0201 "100pF") "VDD_10"   "GND")
    (series "R_VDD_4"  (res-0201 "39R")   "V5P0" "VDD_4")
    (series "C_VDD_4"  (cap-0402 "100pF") "VDD_4"    "GND")
    (series "R_VDD_12" (res-0201 "39R")   "V5P0" "VDD_12")
    (series "C_VDD_12" (cap-0402 "100pF") "VDD_12"   "GND")

    (port "V5P0" in  power 5.0)
    (port "GND"      bidi)
    (port "RFIN"     in  rf)
    (port "LNAOUT"   out rf)

    (note "U1" "PMA3-24323LN+: 24-32 GHz LNA, single-ended 50 Ω in / 50 Ω out. Per-pin VDD bias: series resistor from V5P0 to each VDD pin (24R on pins 6/10, 39R on pins 4/12) with a 100pF decoupling cap per pin (0201 on 6/10, 0402 on 4/12). Output AC-coupled to the ADF5904 RFIN via single-ended-to-diff conversion (a balun, or single-ended drive of one diff input with the other terminated 50 Ω). Confirm matching network on the 24.125 GHz design point.")))
