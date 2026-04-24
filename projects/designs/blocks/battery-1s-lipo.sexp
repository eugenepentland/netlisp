;; 1S LiPo battery (drone-grade, 80C continuous discharge)
;; Wraps the 2-pin solder-pad connector so the power-budget analyzer sees
;; VBATT as a declared source with real capacity. Actual pack is far above
;; declared — 80C on even a 300 mAh cell is 24 A — so values here are a
;; conservative ceiling for the review, not the battery's true limit.

(import connector-battery)

(design-block "1S LiPo Battery"

  (instance "batt" connector-battery
    (pin 1 "VBATT")
    (pin 2 "GND") (id ba77e12a))

  (port "VBATT" out (nominal 3.7) (rated 3.0 4.2) (current 5.0 10.0))
  (port "GND" bidi)

  (note "batt" "LiPo wires solder to through-hole pads with strain relief"))
