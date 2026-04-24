(footprint "motor-wire-pad-smt"
  (description "2-pin SMT solder pad for thin vibration-motor wires (~30 AWG). 1.5mm pitch, no through-hole, no strain relief.")

  (pad 1 smd roundrect (pos -0.75 0.00) (size 1.00 1.80))
  (pad 2 smd roundrect (pos 0.75 0.00) (size 1.00 1.80))
  (courtyard (rect -1.45 -1.15 1.45 1.15))
  (silkscreen
    (line (-1.35 -1.05) (-1.35 1.05))
  )
)
