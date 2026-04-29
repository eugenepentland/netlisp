;; TPS63806 buck-boost converter
;; FB divider: 511k/91k -> VOUT=3.306V (500mV ref)
;; VIN: 1.8V-5.5V, IOUT: 2A

(import tps63806)
(import cap-0603)
(import cap-0805)
(import res-0402)
(import xfl4012)

(design-block "3.3V Buck-Boost (TPS63806)"

  (instance "U1" tps63806
    (pin EN "EN")
    (pin VIN_1 VIN_2 "VIN")
    (pin MODE "GND")
    (pin L1_1 L1_2 "SW_L1")
    (pin AGND "AGND")
    (pin GND_1 GND_2 "GND")
    (pin FB "FB")
    (pin L2_1 L2_2 "SW_L2")
    (pin PG "PG")
    (pin VOUT_1 VOUT_2 "VOUT") (id d865e2a1))
  (decouple "VIN" (cap-0603 "10uF") 1 per-pin U1 VIN_1 (id ca9c1826))
  (decouple "VOUT" (cap-0805 "47uF") 2 per-pin U1 VOUT_1 (id b5477e53))
  (series "L1" (xfl4012 "0.47uH") "SW_L1" "SW_L2" (id c59d9c42))
  (series "R_FBT" (res-0402 "511k") "VOUT" "FB" (id d8c5e75f))
  (series "R_FBB" (res-0402 "91k") "FB" "GND" (id a5db8a06))
  (series "R_PG" (res-0402 "100k") "PG" "VOUT" (id cf6e4768))
  (net "GND" "AGND")

  ;; VIN datasheet range 1.3-5.5V; this design feeds it from VBATT (1S LiPo, 3.0-4.2V),
  ;; well inside the device envelope.
  (port "VIN" in (rated 1.3 5.5))
  (port "EN" in)
  ;; TPS63806 rated for 2A continuous at 3.3V out. Typical duty budget 1.5A.
  ;; Datasheet efficiency ~90% at 3.7 Vin → 3.3 Vout, mid-load.
  (port "VOUT" out (nominal 3.3) (current 1.5 2.0) (efficiency 0.9) (enable "EN"))
  (port "PG" out)
  (port "GND" bidi)

  (note "U1" "EN exposed as port — driven by external power-button controller (STM6601) in the parent design")
  (note "U1" "MODE tied to GND -- auto PFM/PWM, 13uA quiescent")
  (note "R_FBT" "FB divider: 511k/91k 1% -> VOUT=3.306V (500mV ref)")
  (note "L1" "XFL4015-471MEC (4x4x1.5mm, 5.4A sat, 7.6mOhm DCR)"))
