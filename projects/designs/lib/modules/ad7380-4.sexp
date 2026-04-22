(import ad7380-4bcpz)
(import cap-0402)
(import cap-0805)

(defmodule ad7380-4 (ch)
  "AD7380-4 Quad 16-bit SAR ADC channel.
   4 simultaneous-sampling differential inputs (AINA..AIND),
   quad SDO SPI data out, shared SCLK/SDI/~CS, external VREF."

  (let ch-str   (fmt "~A" ch))
  (let cs-net   (fmt "CS~A" ch))
  (let sdoa     (fmt "SDOA~A" ch))
  (let sdob     (fmt "SDOB~A" ch))
  (let sdoc     (fmt "SDOC~A" ch))
  (let sdod     (fmt "SDOD~A" ch))
  (let aina-p   (fmt "CH~A_AINA+" ch))
  (let aina-n   (fmt "CH~A_AINA-" ch))
  (let ainb-p   (fmt "CH~A_AINB+" ch))
  (let ainb-n   (fmt "CH~A_AINB-" ch))
  (let ainc-p   (fmt "CH~A_AINC+" ch))
  (let ainc-n   (fmt "CH~A_AINC-" ch))
  (let aind-p   (fmt "CH~A_AIND+" ch))
  (let aind-n   (fmt "CH~A_AIND-" ch))

  (design-block (fmt "AD7380-4 Channel ~A" ch)

    (instance "U1" ad7380-4bcpz
      (pin 1 5 14 16 25 "GND")
      (pin 4 "VCC")
      (pin 2 "VLOGIC")
      (pin 3 "REGCAP")
      (pin 17 "VREF")
      (pin 18 cs-net)
      (pin 19 sdoa)
      (pin 20 sdob)
      (pin 23 sdoc)
      (pin 24 sdod)
      (pin 21 "SDI")
      (pin 22 "SCLK")
      (pin 6 aind-n)  (pin 7 aind-p)
      (pin 8 ainc-n)  (pin 9 ainc-p)
      (pin 10 ainb-n) (pin 11 ainb-p)
      (pin 12 aina-n) (pin 13 aina-p))

    ;; VCC (3.3V analog) decoupling
    (instance "C1" (cap-0402 "100nF") (pin 1 "VCC") (pin 2 "GND"))
    (instance "C2" (cap-0805 "10uF")  (pin 1 "VCC") (pin 2 "GND"))

    ;; VLOGIC (1.8V logic) decoupling
    (instance "C3" (cap-0402 "100nF") (pin 1 "VLOGIC") (pin 2 "GND"))

    ;; REGCAP internal regulator bypass (datasheet: 1uF)
    (instance "C4" (cap-0402 "1uF")   (pin 1 "REGCAP") (pin 2 "GND"))

    ;; VREF buffer cap (datasheet: 10uF close to REFIO)
    (instance "C5" (cap-0805 "10uF")  (pin 1 "VREF") (pin 2 "GND"))

    ;; Public interface — shared across channels unless fmt-suffixed
    (port "VCC"    in (rated 3.15 3.45))
    (port "VLOGIC" in (rated 1.65 1.95))
    (port "VREF"   in)
    (port "SCLK"   in)
    (port "SDI"    in)
    (port cs-net   in)
    (port sdoa     out)
    (port sdob     out)
    (port sdoc     out)
    (port sdod     out)
    (port aina-p   in) (port aina-n in)
    (port ainb-p   in) (port ainb-n in)
    (port ainc-p   in) (port ainc-n in)
    (port aind-p   in) (port aind-n in)
    (port "GND"    bidi)

    (note "U1" (fmt "AD7380-4BCPZ channel ~A — 4-input differential SAR ADC, 4MSPS." ch))
    (note "C4" "REGCAP: 1uF ceramic, close to pin 3.")
    (note "C5" "VREF: 10uF external reference buffer cap, close to pin 17.")

    (group "VCC Decoupling" ("C1" "C2"))
    (group "VLOGIC Decoupling" ("C3"))))
