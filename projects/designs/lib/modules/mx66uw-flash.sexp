;; Macronix MX66UW1G45G 1 Gbit OctoSPI NOR flash. 8-bit data + DQS.
;; Module assumes 1.8V supply on VDDIO. Reset is OR-ed with the host MCU's
;; NRST via reverse diode so a system reset also pulses the flash.

(import mx66uw1g45gxdi00)
(import diode-0402)

(defmodule mx66uw-flash ()
  "MX66UW1G45G 1 Gbit OctoSPI NOR. Caller wires VDDIO (1.8V), GND, CS,
   CLK, DQS, the 8-bit IO bus, and an open-drain NRST input that mirrors
   the host MCU reset. The pull-up on NRST + the NRST→RESET reverse
   diode are sealed inside this module."

  (design-block "MX66UW Flash"

    (instance "flash" mx66uw1g45gxdi00
      (pin VCC VCCQ__1 VCCQ "VDDIO")
      (pin GND VSSQ VSSQ__1 "GND")
      (pin "~{CS}" "CS")
      (pin SCLK "CLK")
      (pin DQS "DQS")
      (bus "FLASH_IO" "SIO")
      (pin "~{RESET}" "FLASH_RESET"))
    (decouple "VDDIO" (cap-0201 "100nF") 1 per-pin flash)
    (series "R10" (res-0201 "10k") "FLASH_RESET" "VDDIO")
    (series "R11" (res-0201 "10k") "CS"          "VDDIO")
    (series "D2"  (diode-0402 "PMEG2005AEA") "NRST" "FLASH_RESET")

    (port "VDDIO" in (rated 1.7 1.95))
    (port "GND"   bidi)
    (port "NRST"  in)
    (port "CS"    in)
    (port "CLK"   in)
    (port "DQS"   io)
    (port "FLASH_IO0" io) (port "FLASH_IO1" io) (port "FLASH_IO2" io) (port "FLASH_IO3" io)
    (port "FLASH_IO4" io) (port "FLASH_IO5" io) (port "FLASH_IO6" io) (port "FLASH_IO7" io)

    (note "D2" "Reverse diode NRST→FLASH_RESET for simultaneous reset (AN5967 §14.4.3). Caller's NRST is pulled high externally; D2 lets a low NRST pull RESET low, but NRST is otherwise isolated from the flash's internal reset domain.")
    (note "flash" "If VDDIO is 1.8V on the host MCU, set OTP124 bit 15 (HSLV) and PWR_SVMCRx VDDIOxVRSEL on the MCU side.")))
