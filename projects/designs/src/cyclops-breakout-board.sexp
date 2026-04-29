(board "Cyclops Expansion Breakout"
  (design "src/cyclops-breakout.sexp")

  ;; 80mm x 25mm 2-layer board: 30-pin headers along each long edge
  ;; (~73.7mm), with the SlimStack mezzanine receptacle centred between
  ;; them. Standard 1.6mm FR4 stackup.
  (outline (rect 0.0 0.0 80.0 25.0))

  (stackup
    (copper "F.Cu" 0.035)
    (core            1.510  (er 4.5))
    (copper "B.Cu" 0.035))

  (rules
    (clearance 0.2)
    (track-width 0.25)
    (via-drill 0.3)
    (via-size 0.6))

  (net-class "power"
    (track-width 0.5)
    (via-drill 0.4)
    (via-size 0.8)
    (nets "VBATT" "V1P8" "GND"))

  (zone "GND" "B.Cu"
    (thermal-gap 0.3)
    (thermal-width 0.3)))
