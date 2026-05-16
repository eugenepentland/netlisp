;; MCP73831 500mA single-cell LiPo charger
;; RPROG=2k -> IREG=500mA charge current

(import mcp73831-2aci-mc)
(import cap-0402)
(import res-0402)
(import led-0402)

(design-block "LiPo Charger (500mA)"

  (instance "U1" mcp73831-2aci-mc
    (pin VDD_1 VDD_2 "VBUS")
    (pin VBAT_1 VBAT_2 "VBATT")
    (pin VSS "GND")
    (pin EP "GND")
    (pin PROG "CHG_PROG")
    (pin STAT "CHG_STAT") (id e3a20001))
  (decouple "VBUS" (cap-0402 "4.7uF") 1 per-pin U1 VDD_1 (id e3a20002))
  (decouple "VBATT" (cap-0402 "4.7uF") 1 per-pin U1 VBAT_1 (id e3a20003))
  (series "R_PROG" (res-0402 "2k") "CHG_PROG" "GND" (id e3a20004))
  (series "R_CHG" (res-0402 "1k") "VBUS" "CHG_LED" (id e3a20005))
  (series "D_CHG" (led-0402 "orange") "CHG_LED" "CHG_STAT" (id e3a20006))

  (port "VBUS" in (rated 4.0 5.5))
  ;; Charge current set by RPROG=2k → 500mA. Datasheet allows up to 500mA.
  (port "VBATT" out (nominal 4.2) (current 0.5 0.5))
  (port "GND" bidi)

  (note "U1" "RPROG=2k -> IREG=500mA charge current")
  (note "D_CHG" "STAT is open-drain: LED on during charge, off/hi-Z when complete"))
