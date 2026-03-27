(import pma3-14ln)
(import cap-0402)
(import ind-0402)
(import res-0402)
(import ferrite-0402)

(design-block "PMA3-14LN+ Wideband LNA"

  (instance "U1" pma3-14ln
    (pin 1 "INPUT_BIAS")
    (pin 2 "RF_INPUT")
    (pin 3 4 5 6 7 9 10 11 12 13 "GND")
    (pin 8 "RF_OUTPUT"))

  ;; DC blocking caps
  (instance "C1" (cap-0402 "10nF")
    (pin 1 "RF_IN")
    (pin 2 "RF_INPUT"))

  (instance "C2" (cap-0402 "10nF")
    (pin 1 "RF_OUT")
    (pin 2 "RF_OUTPUT"))

  ;; RF shunt caps
  (instance "C3" (cap-0402 "0.2pF")
    (pin 1 "GND")
    (pin 2 "RF_INPUT"))

  (instance "C4" (cap-0402 "0.1pF")
    (pin 1 "GND")
    (pin 2 "RF_OUTPUT"))

  ;; Input bias decoupling
  (instance "C5" (cap-0402 "100pF")
    (pin 1 "INPUT_BIAS")
    (pin 2 "GND"))

  (instance "C7" (cap-0402 "100nF")
    (pin 1 "INPUT_BIAS")
    (pin 2 "GND"))

  ;; Output bias decoupling
  (instance "C6" (cap-0402 "100pF")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "GND"))

  (instance "C8" (cap-0402 "100nF")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "GND"))

  ;; RF chokes
  (instance "L1" (ind-0402 "900nH")
    (pin 1 "INPUT_BIAS")
    (pin 2 "RF_INPUT"))

  (instance "L2" (ind-0402 "900nH")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "RF_OUTPUT"))

  ;; Bias resistor
  (instance "R1" (res-0402 "510R")
    (pin 1 "GND")
    (pin 2 "INPUT_BIAS"))

  ;; VDD filter
  (instance "FB1" (ferrite-0402 "FB")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "VDD"))

  ;; Ports
  (port "RF_IN"  "RF_IN"  in)
  (port "RF_OUT" "RF_OUT" out)
  (port "VDD"    "VDD"    in (rated 5.75 6.25))
  (port "GND"    "GND"    bidi)

  ;; Notes
  (note "U1" "PMA3-14LN+: 50MHz-10GHz, 22.6dB gain, 1.1dB NF, IP3=25dBm")
  (note "C1" "DC blocking cap, RF input. 10nF 0402.")
  (note "C2" "DC blocking cap, RF output. 10nF 0402.")
  (note "C3" "RF shunt to GND, 0.5pF. Tuning for input match.")
  (note "C4" "RF shunt to GND, 0.1pF. Tuning for output match.")
  (note "L1" "RF choke 900nH. Provides DC bias to pin 1 while blocking RF.")
  (note "L2" "RF choke 900nH. Provides DC bias to pin 8 while blocking RF.")
  (note "R1" "Current mirror bias resistor. 510R sets ~6.3mA per mirror.")
  (note "FB1" "Ferrite bead on VDD. Filters high-frequency noise from supply.")

  ;; Groups
  (group "Input Bias Network" ("L1" "R1" "C5" "C7"))
  (group "Output Bias Network" ("L2" "C6" "C8" "FB1")))
