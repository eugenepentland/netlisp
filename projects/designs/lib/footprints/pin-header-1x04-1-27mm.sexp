(footprint "pin-header-1x04-1-27mm"
  (description "Through-hole 1x4 pin header, 1.27mm pitch, single row. Source: KiCad Connector_PinHeader_1.27mm PinHeader_1x04_P1.27mm_Vertical.")

  (pad 1 thru rect (pos 0.00 0.00) (size 1.00 1.00) (drill 0.65))
  (pad 2 thru circle (pos 0.00 1.27) (size 1.00 1.00) (drill 0.65))
  (pad 3 thru circle (pos 0.00 2.54) (size 1.00 1.00) (drill 0.65))
  (pad 4 thru circle (pos 0.00 3.81) (size 1.00 1.00) (drill 0.65))
  (courtyard (rect -1.55 -1.14 1.55 4.95))
  (silkscreen
    (line (-1.16 -0.81) (0.00 -0.81))
    (line (-1.16 0.00) (-1.16 -0.81))
    (line (-1.16 0.81) (-1.16 4.56))
    (line (-1.16 0.81) (-0.67 0.81))
    (line (-1.16 4.56) (-0.32 4.56))
    (line (0.32 4.56) (1.16 4.56))
    (line (0.67 0.81) (1.16 0.81))
    (line (1.16 0.81) (1.16 4.56))
  )
)
