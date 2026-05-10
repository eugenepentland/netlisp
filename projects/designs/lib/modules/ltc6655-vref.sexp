;; LTC6655-2.5 ultra-low-noise 2.5V precision reference.
;; 2 ppm/°C, ±0.025%, 0.625 µVp-p 0.1–10 Hz noise. SHDN tied to VIN
;; internally; force/sense are bonded as one net (Kelvin separation
;; is a PCB layout concern, not a schematic one). Caller routes the
;; VREF_2V5 net as a star fan-out to each downstream load.

(import ltc6655bhms8-2-5#pbf)

(defmodule ltc6655-vref ()
  "LTC6655B-2.5 precision 2.5V reference with input bypass and 10 µF
   NP0 star-node bulk output cap. Place the bulk cap at the star
   pour on the PCB, not at the part — see note."

  (design-block "LTC6655 2.5V Reference"

    (instance "vref" ltc6655bhms8-2-5#pbf
      (pin 1 "VDD")
      (pin 2 "VDD")
      (pin 3 4 5 8 "GND")
      (pin 6 "VREF")
      (pin 7 "VREF"))
    (instance "C_VREF_IN"  (cap-0201 "100nF")     (pin 1 "VDD")  (pin 2 "GND"))
    (instance "C_VREF_OUT" (cap-0603 "10uF" np0)  (pin 1 "VREF") (pin 2 "GND"))

    (port "VDD"  in (rated 3.0 3.6))
    (port "GND"  bidi)
    (port "VREF" out)

    (note "vref" "LTC6655B-2.5: 2 ppm/°C, ±0.025%, 0.625 µVp-p (0.1–10 Hz) noise. Far lower noise than ADR4525 — worth the cost for full ENOB on multiple SAR ADCs.")
    (note "vref" "SHDN tied to VIN per datasheet — pin floats high via weak internal pull-up but explicit tie is required.")
    (note "vref" "Pin 4 needs its own direct via to GND plane within ~1 mm of the pad — it is where LTC6655 return current physically exits.")
    (note "C_VREF_OUT" "10 µF NP0 is the star-node bulk cap. On the PCB it must sit at the star pour, not at pin 7. Force/sense (pins 6/7) route as separate traces to that pour; downstream loads fan out from the star — never daisy-chain.")
    (note "C_VREF_OUT" "10 µF NP0 0603 is at the edge of commercial availability — sourcing may require 1206/1210; verify on BOM resolve.")))
