(import lp5907mfx-1-8-nopb)
(import cap-0402)

(defmodule lp5907-ldo ()
  "LP5907 1.8V fixed-output LDO with enable pin.
   VIN: 2.2V-5.5V, VOUT: 1.8V, IOUT: 250mA."

  (design-block "1.8V LDO (LP5907)"

    (instance "U1" lp5907mfx-1-8-nopb
      (pin IN "VIN")
      (pin EN "EN")
      (pin OUT "VOUT")
      (pin GND "GND") (id d1a7e0df))
    (decouple "VIN" (cap-0402 "1uF") 1 per-pin U1 IN (id e6988efe))
    (decouple "VOUT" (cap-0402 "1uF") 1 per-pin U1 OUT (id e9b79838))

    (port "VIN" in (rated 2.2 5.5))
    (port "EN" in)
    (port "VOUT" out (rated 1.7 1.9))
    (port "GND" bidi)

    (note "U1" "LP5907MFX-1.8: ultra-low noise (6.5uVrms), PSRR 82dB")))
