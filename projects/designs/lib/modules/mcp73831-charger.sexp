(import mcp73831-2aci-mc)

(defmodule mcp73831-charger (rprog)
  "MCP73831 single-cell LiPo charger.
   RPROG sets charge current: I = 1000/RPROG mA."

  (let icharge (/ 1000.0 rprog))
  (let rprog-str (fmt "~R" rprog))

  (assert-range icharge 0.1 1.0 "Charge current")

  (design-block (fmt "LiPo Charger (~A)" icharge)

    (instance "U1" mcp73831-2aci-mc
      (pin VDD_1 VDD_2 "VBUS")
      (pin VBAT_1 VBAT_2 "VBATT")
      (pin VSS "GND")
      (pin EP "GND")
      (pin PROG "CHG_PROG")
      (pin STAT "CHG_STAT") (id e3a20001))
    (decouple "VBUS" (cap-0402 "4.7uF") 1 per-pin U1 VDD_1 (id e3a20002))
    (decouple "VBATT" (cap-0402 "4.7uF") 1 per-pin U1 VBAT_1 (id e3a20003))
    (series "R_PROG" (res-0402 rprog-str) "CHG_PROG" "GND" (id e3a20004))
    (series "R_CHG" (res-0402 "1k") "VBUS" "CHG_LED" (id e3a20005))
    (series "D_CHG" (led-0402 "orange") "CHG_LED" "CHG_STAT" (id e3a20006))

    (port "VBUS" in (rated 4.0 5.5))
    (port "VBATT" out)
    (port "GND" bidi)

    (note "U1" (fmt "RPROG=~R -> IREG=~A charge current" rprog icharge))
    (note "D_CHG" "STAT is open-drain: LED on during charge, off/hi-Z when complete")))
