(symbol "usb-c-2.0"
  (description "USB Type-C Receptacle, USB 2.0 signals only")

  ;; Pin numbers are sequential; component pin-map translates to pad names
  ;; GND: pins 1, 8 (A1, A12, B1, B12, SH1-SH4 all tied)
  ;; VBUS: pins 2, 7 (A4, A9, B4, B9 all tied)
  ;; CC1: pin 3 (A5)
  ;; D+: pin 4 (A6, B6 shorted for USB 2.0)
  ;; D-: pin 5 (A7, B7 shorted for USB 2.0)
  ;; CC2: pin 6 (B5)

  (pin 1 "GND"  power-in left 1)
  (pin 2 "VBUS" power-in left 2)
  (pin 3 "CC1"  bidi     left 3)
  (pin 4 "D+"   bidi     right 1)
  (pin 5 "D-"   bidi     right 2)
  (pin 6 "CC2"  bidi     right 3)

  (body (label "USB-C")))
