;; AD7380-4 quad 16-bit 4MSPS SAR ADC channel — full replicated unit.
;; Includes the ADC, decoupling, REFIN/REGCAP caps, 33R+68pF anti-alias
;; RC filters on all 4 differential inputs, and 100R SDO dampers.
;; Intended to be sub-blocked 3x for a 12-channel array.

(import ad7380-4bcpz)
(import res-0201)
(import cap-0201)

(defmodule ad7380-channel (idx)
  "AD7380-4 4-channel 16-bit 4MSPS simultaneous-sampling ADC with analog front-end.
   idx is a placeholder parameter (pass any integer); kept for consistency with
   other modules. All three channel instances share the same internal topology."

  (design-block "AD7380-4 Channel"

    (instance "U1" ad7380-4bcpz
      (pin 1 5 14 16 25 "GND")
      (pin 4 "VCC")
      (pin 2 "VLOGIC")
      (pin 3 "REGCAP")
      (pin 17 "REFIN")
      (pin 18 "CS")
      (pin 22 "SCK")
      (pin 21 "SDI")
      (pin 19 "SDOA_RAW") (pin 20 "SDOB_RAW")
      (pin 23 "SDOC_RAW") (pin 24 "SDOD_RAW")
      (pin 13 "AINA_P") (pin 12 "AINA_N")
      (pin 11 "AINB_P") (pin 10 "AINB_N")
      (pin 9  "AINC_P") (pin 8  "AINC_N")
      (pin 7  "AIND_P") (pin 6  "AIND_N"))

    ;; Power decoupling — close to each pin
    (instance "C_VCC"    (cap-0201 "1uF")  (pin 1 "VCC")    (pin 2 "GND"))
    (instance "C_VLOG"   (cap-0201 "1uF")  (pin 1 "VLOGIC") (pin 2 "GND"))
    (instance "C_REGCAP" (cap-0201 "1uF")  (pin 1 "REGCAP") (pin 2 "GND"))
    (instance "C_REFIN"  (cap-0201 "100nF") (pin 1 "REFIN")  (pin 2 "GND"))

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
    ;; Channel C
    (instance "R_FCP" (res-0201 "33R")  (pin 1 "AINC_EXT_P") (pin 2 "AINC_P"))
    (instance "R_FCN" (res-0201 "33R")  (pin 1 "AINC_EXT_N") (pin 2 "AINC_N"))
    (instance "C_FCP" (cap-0201 "68pF") (pin 1 "AINC_P")     (pin 2 "GND"))
    (instance "C_FCN" (cap-0201 "68pF") (pin 1 "AINC_N")     (pin 2 "GND"))
    ;; Channel D
    (instance "R_FDP" (res-0201 "33R")  (pin 1 "AIND_EXT_P") (pin 2 "AIND_P"))
    (instance "R_FDN" (res-0201 "33R")  (pin 1 "AIND_EXT_N") (pin 2 "AIND_N"))
    (instance "C_FDP" (cap-0201 "68pF") (pin 1 "AIND_P")     (pin 2 "GND"))
    (instance "C_FDN" (cap-0201 "68pF") (pin 1 "AIND_N")     (pin 2 "GND"))

    ;; SDO 100Ω series dampers (place close to ADC)
    (instance "R_SDA" (res-0201 "100R") (pin 1 "SDOA_RAW") (pin 2 "SDOA"))
    (instance "R_SDB" (res-0201 "100R") (pin 1 "SDOB_RAW") (pin 2 "SDOB"))
    (instance "R_SDC" (res-0201 "100R") (pin 1 "SDOC_RAW") (pin 2 "SDOC"))
    (instance "R_SDD" (res-0201 "100R") (pin 1 "SDOD_RAW") (pin 2 "SDOD"))

    ;; External-facing ports (bridged to parent nets via (net ...) ties)
    (port "VCC"       in  (rated 3.15 3.45))
    (port "VLOGIC"    in  (rated 1.65 1.95))
    (port "REFIN"     in  (rated 2.45 3.35))
    (port "GND"       bidi)
    (port "SCK"       in)
    (port "SDI"       in)
    (port "CS"        in)
    (port "SDOA"      out)
    (port "SDOB"      out)
    (port "SDOC"      out)
    (port "SDOD"      out)
    (port "AINA_EXT_P" in differential)
    (port "AINA_EXT_N" in differential)
    (port "AINB_EXT_P" in differential)
    (port "AINB_EXT_N" in differential)
    (port "AINC_EXT_P" in differential)
    (port "AINC_EXT_N" in differential)
    (port "AIND_EXT_P" in differential)
    (port "AIND_EXT_N" in differential)

    (note "U1" "AD7380-4BCPZ — 4-input 16-bit 4MSPS simultaneous-sampling SAR ADC.")
    (note "C_REGCAP" "REGCAP: 1uF ceramic to GND only (internal 1.9V regulator bypass).")
    (note "C_REFIN" "REFIN driven externally (LTC6655-2.5 precision reference) — 100nF local bypass per datasheet, close to pin 17.")
    (note "R_FAP" "Anti-alias: 33Ω + 68pF per leg, matched within 2 mm over solid GND.")
    (note "R_SDA" "SDO 100Ω dampers suppress digital coupling into the analog section.")))
