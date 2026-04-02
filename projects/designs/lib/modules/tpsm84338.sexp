(import tpsm84338rcjr)
(import n2n7002)
(import east1410rgbw01)
(import res-0402)
(import cap-0402)
(import cap-0805)

(defmodule tpsm84338 (rfbt rfbb rled)
  "3A Buck Converter with Power Good LED.
   VIN: 3.8V-28V, VOUT: 0.6V-16V, IOUT: 3A."

  ;; Computed values
  (let vout (* 0.6 (+ 1.0 (/ rfbt rfbb))))
  (let led-current (/ (- vout 2.8) rled))
  (let rfbt-str (fmt "~R" rfbt))
  (let rfbb-str (fmt "~R" rfbb))
  (let rled-str (fmt "~R" rled))
  (let vout-str (fmt "~V" vout))

  ;; Validation
  (assert-range vout 0.6 16.0 "VOUT")
  (assert-range led-current 0.0 0.01 "LED current")

  (design-block (fmt "~V Buck (TPSM84338)" vout)

    ;; Components
    (instance "U1" tpsm84338rcjr
      (pin 1 "EN")
      (pin 2 "FB")
      (pin 3 "GND")
      (pin 4 vout-str)
      (pin 6 "VIN")
      (pin 7 "MODE")
      (pin 8 "SS_PG")
      (pin 9 "RT"))
    (instance "R4" (res-0402 rfbt-str)
      (pin 1 vout-str)
      (pin 2 "FB"))
    (instance "R5" (res-0402 rfbb-str)
      (pin 1 "FB")
      (pin 2 "GND"))
    (instance "C7" (cap-0402 "22pF")
      (pin 1 vout-str)
      (pin 2 "FB"))
    (instance "R6" (res-0402 "0R")
      (pin 1 "RT")
      (pin 2 "GND"))
    (instance "C1" (cap-0805 "10uF")
      (pin 1 "VIN")
      (pin 2 "GND"))
    (instance "C2" (cap-0805 "10uF")
      (pin 1 "VIN")
      (pin 2 "GND"))
    (instance "C3" (cap-0805 "10uF")
      (pin 1 "VIN")
      (pin 2 "GND"))
    (instance "C8" (cap-0402 "100nF")
      (pin 1 "VIN")
      (pin 2 "GND"))
    (instance "C4" (cap-0805 "22uF")
      (pin 1 vout-str)
      (pin 2 "GND"))
    (instance "C5" (cap-0805 "22uF")
      (pin 1 vout-str)
      (pin 2 "GND"))
    (instance "R7" (res-0402 "18k")
      (pin 1 "MODE")
      (pin 2 "GND"))
    (instance "R8" (res-0402 "100k")
      (pin 1 "SS_PG")
      (pin 2 vout-str))
    (instance "Q1" n2n7002
      (pin 1 "SS_PG")
      (pin 2 "GND")
      (pin 3 "PG_DRV"))
    (instance "R9" (res-0402 rled-str)
      (pin 1 vout-str)
      (pin 2 "LED_A"))
    (instance "D1" east1410rgbw01
      (pin 1 "LED_A")
      (pin 2 "PG_DRV"))

    ;; Ports
    (port "VIN"  in   (rated 3.8 28.0))
    (port "VOUT" vout-str  out  (rated 0.6 16.0))
    (port "EN"   in   (rated 0.0 28.0))
    (port "GND"  bidi)

    ;; Annotations
    (note "U1" "TPSM84338RCJR: 3.8-28V, 3A synchronous buck module.")
    (note "R4" (fmt "RFBT = ~R. VOUT = 0.6V x (1 + ~R/~R) = ~V."
                    rfbt rfbt rfbb vout))
    (note "R5" (fmt "RFBB = ~R (1%%). Bottom resistor of FB divider." rfbb))
    (note "C7" "CFF = 22pF. Feedforward cap across RFBT.")
    (note "R6" "RT = 0R. Sets fSW = 1000kHz per Table 6-2.")
    (note "R7" "RMODE = 18k. PFM + PG + spread spectrum per Table 6-1.")
    (note "R9" (fmt "RLED = ~R. IF = (~V - 2.8V) / ~R." rled vout rled))

    ;; Visual groups
    (group "Power Good Indicator" ("Q1" "D1" "R9"))
    (group "Input Decoupling" ("C1" "C2" "C3" "C8"))
    (group "Output Filtering" ("C4" "C5"))
    (group "Feedback Divider" ("R4" "R5" "C7"))))
