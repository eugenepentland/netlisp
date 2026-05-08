;; 0.96" 80×160 TFT on a 10-pin 0.5 mm FPC (FH12-10S-0.5SH compatible).
;; ST7735S controller in 4-wire SPI mode. Backlight is gated low-side by
;; an AO3400A driven by an external PWM signal.

(import fh12-10s-0-5sh-55-)
(import cap-0603)
(import res-0402)
(import ao3400a)

(defmodule st7735s-display ()
  "ST7735S 80×160 SPI TFT module. Caller wires VDD (3.3 V), GND, write-only
   SPI4 (SCK/MOSI/CS), DC, NRST, and a PWM-capable BL_EN. Display VDD
   bypass cap and the backlight current-limit resistor + N-FET driver
   are sealed."

  (design-block "ST7735S Display"

    (instance "disp" fh12-10s-0-5sh-55-
      (pin 1 "LEDK")
      (pin 2 "LEDA")
      (pin 3 "VDD")
      (pin 4 "VDD")
      (pin 5 "GND")
      (pin 6 "CS")
      (pin 7 "NRST")
      (pin 8 "MOSI")
      (pin 9 "SCK")
      (pin 10 "DC")
      (pin MP_1 MP_2 "GND"))
    (instance "C_DISP" (cap-0603 "100nF")
      (pin 1 "VDD")
      (pin 2 "GND"))
    (series "R_BL"    (res-0402 "15R")  "VDD"   "LEDA")
    (instance "Q_BL" ao3400a
      (pin 1 "BL_EN")
      (pin 2 "GND")
      (pin 3 "LEDK"))
    (series "R_BL_PD" (res-0402 "10k")  "BL_EN" "GND")

    (port "VDD"   in (rated 3.0 3.6))
    (port "GND"   bidi)
    (port "SCK"   in)
    (port "MOSI"  in)
    (port "CS"    in)
    (port "DC"    in)
    (port "NRST"  in)
    (port "BL_EN" in)

    (note "disp" "ST7735S is write-only from the host side — no MISO routed. SPI mode 0 (CPOL=0, CPHA=0), MSB first, up to ~15 MHz write clock.")
    (note "disp" "80×160 panel variant: firmware must apply column +26 / row +1 offsets and correct MADCTL, otherwise the image shifts or tears. Most common bring-up gotcha on this panel.")
    (note "disp" "FPC pin 3 (SPI4W) tied to VDD selects 4-wire SPI mode (D/C line distinguishes command from data bytes).")
    (note "disp" "MP_1/MP_2 FPC board-lock tabs tied to GND.")
    (note "R_BL"    "15Ω sets ~20 mA backlight at 3.3V with LED Vf ≈ 3.0V typ — unit-to-unit brightness may vary at worst-case Vf=3.3V. Move R_BL to a 5V rail + ~100Ω if uniform brightness matters.")
    (note "R_BL_PD" "10k pull-down keeps Q_BL gate low while the host MCU boots, so backlight stays off until firmware drives BL_EN.")))
