(symbol "TPSM84338"
  (description "3.8-28V 3A Synchronous Buck Power Module")

  (pin 6 "VIN"      power-in  left 1)
  (pin 1 "EN"       input     left 2)
  (pin 7 "MODE"     input     left 4)
  (pin 9 "RT/SYNC"  input     left 5)
  (pin 2 "FB"       input     left 6)

  (pin 4 "VOUT"     power-out right 1)
  (pin 5 "SW"       passive   right 2)
  (pin 8 "SS/PG"    output    right 4)

  (pin 3 "GND"      power-in  bottom 1)

  (body
    (min-width 8)
    (min-height 6)
    (label "TPSM84338")))
