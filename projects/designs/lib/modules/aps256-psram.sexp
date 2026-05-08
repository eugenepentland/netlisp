;; AP Memory APS256XXN-OB9 256 Mbit OctoSPI PSRAM in BGA-24.
;; 16-bit IO with 2 DQS/DM strobes. Refresh-burst peaks (~25 mA on
;; periodic Halfsleep refreshes) handled by bulk cap on VDD.

(import aps256xxn-ob9-bg)
(import cap-0201)
(import cap-0603)
(import res-0201)

(defmodule aps256-psram ()
  "APS256XXN PSRAM module on OctoSPI. Caller wires VDD (1.8 V), GND, CS,
   CLK, DQS0/DQS1, and the 16-bit IO bus. Decoupling and the CS pull-up
   are sealed inside."

  (design-block "APS256 PSRAM"

    (instance "psram" aps256xxn-ob9-bg
      (pin VDD_1 VDD_2 "VDD")
      (pin VSS_1 VSS_2 "GND")
      (pin "CE#" "CS")
      (pin CLK "CLK")
      (pin "DQS/_DM0" "DQS0")
      (pin "DQS/_DM1" "DQS1")
      (bus "PSRAM_IO" "IO"))
    (decouple "VDD" (cap-0201 "100nF") 1 per-pin psram)
    (decouple "VDD" (cap-0603 "4.7uF") 1 per-pin psram VDD_1)
    (series "R12" (res-0201 "10k") "CS" "VDD")

    (port "VDD"  in (rated 1.7 1.95))
    (port "GND"  bidi)
    (port "CS"   in)
    (port "CLK"  in)
    (port "DQS0" io)
    (port "DQS1" io)
    (port "PSRAM_IO0" io)  (port "PSRAM_IO1" io)  (port "PSRAM_IO2" io)  (port "PSRAM_IO3" io)
    (port "PSRAM_IO4" io)  (port "PSRAM_IO5" io)  (port "PSRAM_IO6" io)  (port "PSRAM_IO7" io)
    (port "PSRAM_IO8" io)  (port "PSRAM_IO9" io)  (port "PSRAM_IO10" io) (port "PSRAM_IO11" io)
    (port "PSRAM_IO12" io) (port "PSRAM_IO13" io) (port "PSRAM_IO14" io) (port "PSRAM_IO15" io)

    (note "psram" "APS256: 4.7 µF–10 µF bulk cap on VDD smooths refresh-burst current peaks (~25 mA during periodic Halfsleep refresh).")
    (note "psram" "If VDD is 1.8V on the host MCU, set OTP124 bit 16 (HSLV) and PWR_SVMCRx VDDIOxVRSEL on the MCU side.")))
