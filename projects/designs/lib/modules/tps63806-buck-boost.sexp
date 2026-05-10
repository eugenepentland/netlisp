(import tps63806)
(import xfl4012)

(defmodule tps63806-buck-boost (rfbt rfbb)
  "TPS63806 buck-boost converter.
   VIN: 1.8V-5.5V, VOUT = 0.5 * (1 + RFBT/RFBB), IOUT: 2A."

  (let vout (* 0.5 (+ 1.0 (/ rfbt rfbb))))
  (let rfbt-str (fmt "~R" rfbt))
  (let rfbb-str (fmt "~R" rfbb))
  (let vout-str (fmt "~V" vout))

  (assert-range vout 1.8 5.5 "Output voltage")

  (design-block (fmt "~V Buck-Boost (TPS63806)" vout)

    (instance "U1" tps63806
      (pin EN "VIN")
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
    (series "R_FBT" (res-0402 rfbt-str) "VOUT" "FB" (id d8c5e75f))
    (series "R_FBB" (res-0402 rfbb-str) "FB" "GND" (id a5db8a06))
    (series "R_PG" (res-0402 "100k") "PG" "VOUT" (id cf6e4768))
    (net "GND" "AGND")

    (port "VIN" in)
    (port "VOUT" vout-str out)
    (port "PG" out)
    (port "GND" bidi)

    (note "U1" "EN tied to VIN -- converter always on when input present")
    (note "U1" "MODE tied to GND -- auto PFM/PWM, 13uA quiescent")
    (note "R_FBT" (fmt "FB divider: ~R/~R 1%% -> VOUT=~V (500mV ref)" rfbt rfbb vout))
    (note "L1" "XFL4015-471MEC (4x4x1.5mm, 5.4A sat, 7.6mOhm DCR)")))
