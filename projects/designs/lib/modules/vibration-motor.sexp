;; Coin/pager vibration motor driven low-side by an AO3400A N-MOSFET.
;; PWM-capable: gate is driven by an external timer/PWM signal via PWM port.
;; SS14 Schottky flyback diode clamps motor back-EMF on turn-off.

(import connector-motor)
(import ao3400a)
(import diode-sod323)

(defmodule vibration-motor ()
  "Low-side N-FET driver for a 3.3V coin/pager vibration motor.
   Caller wires VDD (3.3V supply, ≤27 mA), GND, and PWM (logic-level gate drive).
   The N-FET, gate damper, gate pull-down, and Schottky flyback clamp are sealed."

  (design-block "Vibration Motor"

    (instance "motor" connector-motor
      (pin 1 "VDD")
      (pin 2 "DRAIN"))
    (instance "Q_VIB" ao3400a
      (pin 1 "GATE")
      (pin 2 "GND")
      (pin 3 "DRAIN"))
    (series "R_VIB_G"  (res-0402 "100R") "PWM"  "GATE")
    (series "R_VIB_PD" (res-0402 "100k") "GATE" "GND")
    (series "D_VIB"    (diode-sod323 "SS14") "VDD" "DRAIN")

    (port "VDD" in (rated 3.0 3.6))
    (port "GND" bidi)
    (port "PWM" in)

    (note "Q_VIB" "AO3400A is a logic-level N-MOSFET (5.8A / 30V, Vgs(th) 1.3V typ, Rds(on) ≈25mΩ @ Vgs=3V). At 27mA the drop is <1mV — effectively zero.")
    (note "D_VIB" "SS14 Schottky, cathode to VDD — clamps motor back-EMF when the FET turns off. Without it the drain node would fly above VDD and stress Q_VIB.")
    (note "R_VIB_G" "100Ω damps gate ringing.")
    (note "R_VIB_PD" "100k pull-down holds the gate low while the host MCU boots so the motor stays off until firmware drives PWM.")))
