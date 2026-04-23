;; LP5912-1.8 ultra-low-noise LDO (WSON-6 with exposed pad)
;; VIN: 2.2V-5.5V, VOUT: 1.8V, IOUT: 500mA
;; Noise: 6.5uVrms, PSRR 82dB (same spec as LP5907, 2x the current)

(import lp5912-1-8drvr)
(import cap-0402)

(design-block "1.8V LDO (LP5912)"

  (instance "U1" lp5912-1-8drvr
    (pin IN "VIN")
    (pin EN "EN")
    (pin OUT "VOUT")
    (pin GND "GND")
    (pin EP "GND")
    (pin NC "GND")
    (pin PG "LDO_PG") (id d1a7e0df))
  (decouple "VIN" (cap-0402 "1uF") 1 per-pin U1 IN (id e6988efe))
  (decouple "VOUT" (cap-0402 "1uF") 1 per-pin U1 OUT (id e9b79838))

  (port "VIN" in (rated 2.2 5.5))
  (port "EN" in)
  ;; LP5912: 500mA max continuous. Typical headroom ~400mA to stay inside thermal budget.
  (port "VOUT" out (nominal 1.8) (rated 1.7 1.9) (current 0.4 0.5))
  (port "LDO_PG" out optional)
  (port "GND" bidi)

  (note "U1" "LP5912-1.8DRVR: 500mA ultra-low-noise LDO, WSON-6 with thermal pad")
  (note "U1" "NC tied to GND per datasheet (GND/IN/OUT/open all allowed)"))
