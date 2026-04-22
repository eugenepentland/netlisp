(footprint "battery-wire-pad"
  (description "2-pin through-hole solder pad for battery wires (~22-24 AWG), with strain-relief anchor holes for zip-tie. Source: KiCad Connector_Wire SolderWire-0.25sqmm_1x02_P4.2mm_D0.65mm_OD1.7mm_Relief.")

  (pad  npth circle (pos 0.00 10.20) (size 2.20 2.20) (drill 2.20))
  (pad  npth circle (pos 4.20 10.20) (size 2.20 2.20) (drill 2.20))
  (pad 1 thru roundrect (pos 0.00 0.00) (size 1.85 1.85) (drill 0.85))
  (pad 2 thru circle (pos 4.20 0.00) (size 1.85 1.85) (drill 0.85))
  (courtyard (rect -1.60 -1.42 1.60 11.80))
  (silkscreen
    (line (-0.96 1.19) (-0.96 9.24))
    (line (0.96 1.19) (0.96 9.24))
    (line (3.24 1.19) (3.24 9.24))
    (line (5.16 1.19) (5.16 9.24))
  )
)
