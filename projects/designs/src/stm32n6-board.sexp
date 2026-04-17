(board "STM32N6 Dev Board"
  (design "src/stm32n6.sexp")

  (outline (rect 60.0 35.6 82.6 80.0))

  (stackup
    (copper  "F.Cu"   0.035)
    (prepreg          0.2    (er 4.2))
    (copper  "In1.Cu" 0.035)
    (core             0.8    (er 4.5))
    (copper  "In2.Cu" 0.035)
    (prepreg          0.2    (er 4.2))
    (copper  "B.Cu"   0.035))

  (rules
    (clearance 0.15)
    (track-width 0.2)
    (via-drill 0.3)
    (via-size 0.6))

  (net-class "power"
    (track-width 0.4)
    (via-drill 0.4)
    (via-size 0.8)
    (nets "VDD" "GND" "VDDCORE" "VDDSMPS"))

  (net-class "high-speed"
    (track-width 0.15)
    (nets "USB_DP" "USB_DN" "PSRAM_CLK" "PSRAM_DQS0" "PSRAM_DQS1"))

  (diff-pair "USB"
    (positive "USB_DP")
    (negative "USB_DN")
    (impedance 90)
    (spacing 0.15))

  (zone "GND" "In1.Cu"
    (thermal-gap 0.3)
    (thermal-width 0.25))

  (zone "GND" "B.Cu"
    (thermal-gap 0.3)
    (thermal-width 0.25)))
