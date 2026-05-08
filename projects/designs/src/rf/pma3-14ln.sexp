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
    (pin 8 "RF_OUTPUT") (id f2146cc1))

  ;; DC blocking caps
  (instance "C1" (cap-0402 "10nF")
    (pin 1 "RF_IN")
    (pin 2 "RF_INPUT") (id caf05472))

  (instance "C2" (cap-0402 "10nF")
    (pin 1 "RF_OUT")
    (pin 2 "RF_OUTPUT") (id c18fcbfa))

  ;; RF shunt caps
  (instance "C3" (cap-0402 "0.2pF")
    (pin 1 "GND")
    (pin 2 "RF_INPUT") (id de817bcb))

  (instance "C4" (cap-0402 "0.1pF")
    (pin 1 "GND")
    (pin 2 "RF_OUTPUT") (id d8f5e323))

  ;; Input bias decoupling
  (instance "C5" (cap-0402 "100pF")
    (pin 1 "INPUT_BIAS")
    (pin 2 "GND") (id ec01a9ce))

  (instance "C7" (cap-0402 "100nF")
    (pin 1 "INPUT_BIAS")
    (pin 2 "GND") (id b1572ee5))

  ;; Output bias decoupling
  (instance "C6" (cap-0402 "100pF")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "GND") (id eef0b80e))

  (instance "C8" (cap-0402 "100nF")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "GND") (id e56159b4))

  ;; RF chokes
  (instance "L1" (ind-0402 "900nH")
    (pin 1 "INPUT_BIAS")
    (pin 2 "RF_INPUT") (id b092e08f))

  (instance "L2" (ind-0402 "900nH")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "RF_OUTPUT") (id f9bbfcf5))

  ;; Bias resistor
  (instance "R1" (res-0402 "510R")
    (pin 1 "GND")
    (pin 2 "INPUT_BIAS") (id a95b832c))

  ;; VDD filter
  (instance "FB1" (ferrite-0402 "FB")
    (pin 1 "OUTPUT_BIAS")
    (pin 2 "VDD") (id b7c03163))

  ;; Ports
  (port "RF_IN"  in)
  (port "RF_OUT" out)
  (port "VDD"    in (rated 5.75 6.25))
  (port "GND"    bidi)

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
