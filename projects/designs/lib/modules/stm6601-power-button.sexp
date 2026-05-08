;; STM6601A push-button on/off controller. Gates the system buck for a
;; true off-state (~5 µA total system draw with a typical 1S LiPo charger).
;; Single-button design: SR/CSRD/VCCLO intentionally NC. Hang recovery
;; is delegated to the host MCU's watchdog.

(import stm6601aq2bdm6f)
(import sw-ws-tasu-436331045822)
(import cap-0402)
(import res-0402)

(defmodule stm6601-power-button ()
  "STM6601A power-button controller wrapping the IC, the side-push tact
   switch, mandatory caps, and required pull-ups. Caller wires VBATT
   (always-on), VDD (3.3 V — the open-drain pull-up reference), NRST
   (open-drain reset bus), PWR_EN (to buck EN), PSHOLD (driven HIGH by
   firmware to stay on), and PWR_BTN/PWR_INT (open-drain outputs to MCU)."

  (design-block "STM6601 Power Button"

    (instance "U_PWR" stm6601aq2bdm6f
      (pin 1 "VBATT")
      (pin 3 "VREF_PWR")
      (pin 4 "PSHOLD")
      (pin 6 "PB_RAW")
      (pin 8 "PWR_BTN")
      (pin 9 "PWR_EN")
      (pin 10 "NRST")
      (pin 11 "PWR_INT")
      (pin 12 "GND"))
    (instance "SW2" sw-ws-tasu-436331045822
      (pin 1 3 "PB_RAW")
      (pin 2 4 "GND"))

    (series "C_PB"        (cap-0402 "100nF") "PB_RAW"   "GND")
    (series "C_VREF_PWR"  (cap-0402 "1uF")   "VREF_PWR" "GND")
    (series "C_VCC_PWR"   (cap-0402 "100nF") "VBATT"    "GND")
    (series "R_PWR_BTN"   (res-0402 "10k")   "PWR_BTN"  "VDD")
    (series "C_PWR_BTN"   (cap-0402 "100nF") "PWR_BTN"  "GND")
    (series "R_NRST_PU"   (res-0402 "10k")   "NRST"     "VDD")
    (series "R_INT_PU"    (res-0402 "10k")   "PWR_INT"  "VDD")
    (series "R_PSHOLD_PD" (res-0402 "1M")    "PSHOLD"   "GND")

    (port "VBATT"   in (rated 3.0 4.2))
    (port "VDD"     in (rated 3.0 3.6))
    (port "GND"     bidi)
    (port "NRST"    io)
    (port "PWR_EN"  out)
    (port "PSHOLD"  in)
    (port "PWR_BTN" out)
    (port "PWR_INT" out)

    (note "U_PWR" "STM6601AQ2BDM6F variant: active-HIGH EN, drives a downstream regulator EN directly. VTH+ = 3.30V typ, VTH- = 3.10V typ (low-batt dropout), tON_BLANK = 1.4-3.0 s. VCC tied to VBATT (always-on, 3.0-4.2 V), quiescent typ 2.5 µA.")
    (note "U_PWR" "Single-button design: SR (pin 2), CSRD (pin 5) and VCCLO (pin 7) intentionally NC. SR floats high via the AQ2B internal 100 k pull-up; the chip's hardware long-press recovery (which requires PB+SR held simultaneously per datasheet p.13) is unreachable. Hang recovery is delegated to the host MCU watchdog.")
    (note "SW2"   "Press pulls ~PB to GND through STM6601 internal debounce. ~PB has an internal 100 k pull-up so no external pull-up is needed; C_PB is just EMI/ESD filtering.")
    (note "U_PWR" "PSHOLD contract: firmware MUST drive PSHOLD HIGH within tON_BLANK (1.4-3.0 s) of boot, or the STM6601 latches off. Drive LOW for clean software-initiated power-down.")
    (note "R_PSHOLD_PD" "1 MΩ pull-down provides the Hi-Z fallback during host-MCU reset (IWDG-triggered or otherwise). Without this, recovery depends on board leakage and reset-time GPIO behavior — bench-verifiable but not robust. 3.3 µA leak when PSHOLD is high — negligible against the 2.5 µA quiescent.")
    (note "U_PWR" "PWR_EN (pin 9): when HIGH = system on, when LOW = downstream regulator disabled. Off-state battery draw ≈ STM6601 quiescent (2.5 µA) plus whatever else is on the always-on VBATT rail.")
    (note "U_PWR" "PWR_INT (pin 11): asserts on button press AND on undervoltage detection. Firmware reads PWR_BTN to disambiguate — PWR_BTN low = button press; PWR_BTN high but PWR_INT low = undervoltage warning. With CSRD omitted the supervisory reset delay tSRD ≈ 0, so undervoltage shutdown must complete within ~50 ms.")
    (note "U_PWR" "PWR_BTN (pin 8) is open-drain — debounced button events. Short press = ≤2 s, long press > 2 s. Firmware times PWR_BTN low duration to distinguish app event vs. clean shutdown trigger.")))
