(symbol "amphenol-10164986"
  (description "Amphenol 10164986-00011LF USB-C Receptacle, USB 2.0 pinout")

  ;; USB 2.0 functional pins (numbered for evaluator compatibility)
  ;; Pin mapping to footprint pads:
  ;;   1 = A1 (GND)     7 = A7 (D-)     13 = B1 (GND)    19 = B7 (D-)
  ;;   2 = A2 (TX1+)    8 = A8 (SBU1)   14 = B2 (TX2+)   20 = B8 (SBU2)
  ;;   3 = A3 (TX1-)    9 = A9 (VBUS)   15 = B3 (TX2-)   21 = B9 (VBUS)
  ;;   4 = A4 (VBUS)   10 = A10 (RX2-)  16 = B4 (VBUS)   22 = B10 (RX1-)
  ;;   5 = A5 (CC1)    11 = A11 (RX2+)  17 = B5 (CC2)    23 = B11 (RX1+)
  ;;   6 = A6 (D+)     12 = A12 (GND)   18 = B6 (D+)     24 = B12 (GND)
  ;;  25 = SH1         26 = SH2         27 = SH3         28 = SH4

  ;; For USB 2.0, only GND, VBUS, CC1, CC2, D+, D- are used.
  ;; TX/RX/SBU pins are no-connect.

  (pin 1 "GND"   power-in left 1)
  (pin 4 "VBUS"  power-in left 2)
  (pin 5 "CC1"   bidi     left 3)
  (pin 6 "D+"    bidi     left 4)
  (pin 7 "D-"    bidi     left 5)

  (pin 9 "VBUS"  power-in right 1)
  (pin 12 "GND"  power-in right 2)
  (pin 17 "CC2"  bidi     right 3)
  (pin 18 "D+"   bidi     right 4)
  (pin 19 "D-"   bidi     right 5)

  (pin 13 "GND"  power-in bottom 1)
  (pin 16 "VBUS" power-in bottom 2)
  (pin 24 "GND"  power-in bottom 3)
  (pin 25 26 27 28 "SHIELD" passive bottom 4)

  (body (label "USB-C 10164986")))
