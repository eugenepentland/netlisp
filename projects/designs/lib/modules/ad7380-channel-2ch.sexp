;; AD7380-4 used as a 2-channel variant — only channels A and B populated.
;; Saves 10 passives vs the full ad7380-channel (8 anti-alias + 2 SDO dampers).
;; Unused AINC/AIND inputs are shorted to GND (standard practice for unused
;; differential SAR inputs). Unused SDOC/SDOD outputs are left floating.
;; Used by the stm32n6 design on adc3, which only needs 2 of its 4 channels
;; to make the 10-channel expansion connector pinout fit.

(import ad7380-4bcpz)
(import res-0201)
(import cap-0201)

(defmodule ad7380-channel-2ch (idx)
  "AD7380-4 2-channel variant — A/B populated; AINC/AIND tied to GND; SDOC/SDOD unrouted."

  (design-block "AD7380-4 Channel (2ch)"

    (instance "U1" ad7380-4bcpz
      (pin 1 5 14 16 25 "GND")
      (pin 4 "VCC")
      (pin 2 "VLOGIC")
      (pin 3 "REGCAP")
      (pin 17 "VREF")
      (pin 18 "CS")
      (pin 22 "SCK")
      (pin 21 "SDI")
      (pin 19 "SDOA_RAW") (pin 20 "SDOB_RAW")
      ;; Pins 23, 24 (SDOC, SDOD) intentionally unconnected — unused outputs.
      (pin 13 "AINA_P") (pin 12 "AINA_N")
      (pin 11 "AINB_P") (pin 10 "AINB_N")
      ;; AINC/AIND shorted to GND — unused differential inputs.
      (pin 9 8 7 6 "GND"))

    ;; Power decoupling — close to each pin
    (instance "C_VCC"    (cap-0201 "1uF")  (pin 1 "VCC")    (pin 2 "GND"))
    (instance "C_VLOG"   (cap-0201 "1uF")  (pin 1 "VLOGIC") (pin 2 "GND"))
    (instance "C_REGCAP" (cap-0201 "1uF")  (pin 1 "REGCAP") (pin 2 "GND"))
    (instance "C_REFIN"  (cap-0201 "1uF")  (pin 1 "VREF")   (pin 2 "GND"))
    ;; REFIN tied to VCC through 0R jumper (future: precision VREF)
    (instance "R_REF"    (res-0201 "0R")   (pin 1 "VCC")    (pin 2 "VREF"))

    ;; Anti-alias filters per differential leg: 33R series + 68pF to GND
    ;; Channel A
    (instance "R_FAP" (res-0201 "33R")  (pin 1 "AINA_EXT_P") (pin 2 "AINA_P"))
    (instance "R_FAN" (res-0201 "33R")  (pin 1 "AINA_EXT_N") (pin 2 "AINA_N"))
    (instance "C_FAP" (cap-0201 "68pF") (pin 1 "AINA_P")     (pin 2 "GND"))
    (instance "C_FAN" (cap-0201 "68pF") (pin 1 "AINA_N")     (pin 2 "GND"))
    ;; Channel B
    (instance "R_FBP" (res-0201 "33R")  (pin 1 "AINB_EXT_P") (pin 2 "AINB_P"))
    (instance "R_FBN" (res-0201 "33R")  (pin 1 "AINB_EXT_N") (pin 2 "AINB_N"))
    (instance "C_FBP" (cap-0201 "68pF") (pin 1 "AINB_P")     (pin 2 "GND"))
    (instance "C_FBN" (cap-0201 "68pF") (pin 1 "AINB_N")     (pin 2 "GND"))

    ;; SDO 100Ω series dampers (only A/B populated; C/D omitted).
    (instance "R_SDA" (res-0201 "100R") (pin 1 "SDOA_RAW") (pin 2 "SDOA"))
    (instance "R_SDB" (res-0201 "100R") (pin 1 "SDOB_RAW") (pin 2 "SDOB"))

    ;; External-facing ports (C/D ports omitted — no external connection)
    (port "VCC"        in  (rated 3.15 3.45))
    (port "VLOGIC"     in  (rated 1.65 1.95))
    (port "GND"        bidi)
    (port "SCK"        in)
    (port "SDI"        in)
    (port "CS"         in)
    (port "SDOA"       out)
    (port "SDOB"       out)
    (port "AINA_EXT_P" in differential)
    (port "AINA_EXT_N" in differential)
    (port "AINB_EXT_P" in differential)
    (port "AINB_EXT_N" in differential)

    (note "U1" "AD7380-4BCPZ — 4-channel IC used in 2-channel mode; AINC/AIND to GND, SDOC/SDOD floating.")
    (note "C_REGCAP" "REGCAP: 1uF ceramic to GND only (internal 1.9V regulator bypass).")
    (note "R_REF" "VREF tied to VCC via 0R — replace with ADR4533 for full ENOB.")
    (note "R_FAP" "Anti-alias: 33Ω + 68pF per leg, matched within 2 mm over solid GND.")
    (note "R_SDA" "SDO 100Ω dampers suppress digital coupling into the analog section.")))
