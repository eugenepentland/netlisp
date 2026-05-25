(component "pma3-24323ln+"
  (description "RF Amplifier SMT Low Noise Amplifier, 24 - 32 GHz, 50 Ohm")
  (pinout "pma3-24323ln+")
  (footprint "pma324323ln")
  (manufacturer "Mini-Circuits")
  (mpn "PMA3-24323LN+")
  (datasheet "pma3-24323ln+.pdf")

  ;; --- Power supplies ----------------------------------------------------
  (requirement "VDD1 (pin 12) operating voltage must be +4.75 V to +5.25 V (+5 V nominal)"
    (ref "pma3-24323ln+.pdf" (page 2) (quote "Device Operating Voltage (VS) +4.75 +5 +5.25 V"))
    (check (voltage-range (pin "VDD1") (min 4.75) (max 5.25))))

  (requirement "VDD2 (pin 10) operating voltage must be +4.75 V to +5.25 V (+5 V nominal)"
    (ref "pma3-24323ln+.pdf" (page 2) (quote "Device Operating Voltage (VS) +4.75 +5 +5.25 V"))
    (check (voltage-range (pin "VDD2") (min 4.75) (max 5.25))))

  (requirement "VDD3 (pin 4) operating voltage must be +4.75 V to +5.25 V (+5 V nominal)"
    (ref "pma3-24323ln+.pdf" (page 2) (quote "Device Operating Voltage (VS) +4.75 +5 +5.25 V"))
    (check (voltage-range (pin "VDD3") (min 4.75) (max 5.25))))

  (requirement "VDD4 (pin 6) operating voltage must be +4.75 V to +5.25 V (+5 V nominal)"
    (ref "pma3-24323ln+.pdf" (page 2) (quote "Device Operating Voltage (VS) +4.75 +5 +5.25 V"))
    (check (voltage-range (pin "VDD4") (min 4.75) (max 5.25))))

  (requirement "Absolute maximum DC voltage at any VDD pin is +10 V; design must never exceed this"
    (ref "pma3-24323ln+.pdf" (page 6) (quote "DC Voltage at VDD1, VDD2, VDD3, VDD4 +10 V")))

  (requirement "Typical supply current is 128 mA at PIN = -25 dBm, increasing to 139 mA at P1dB; size the +5 V rail and any series bias resistors to deliver up to ~140 mA without dropping VDD below 4.75 V"
    (ref "pma3-24323ln+.pdf" (page 2) (quote "Device Operating Current (Is) 128 mA ... Current at PIN= -25 dBm. Increases to 139 mA at P1dB.")))

  ;; --- Bias network (from characterization test board, Figure 2) --------
  (requirement "Mini-Circuits characterization test board biases each VDD pin from +5 V through series resistors (R1, R3 = 39 Ω 0603; R2, R4 = 24 Ω 0603); replicate this bias topology for in-spec operation"
    (ref "pma3-24323ln+.pdf" (page 7) (quote "R1 , R3 KOA SG73P1JTTD39R0F 39 Ω 0603 R2 , R4 KOA SG73S1JTTD24R0F 24 Ω 0603")))

  ;; --- Decoupling --------------------------------------------------------
  (requirement "VDD1 (pin 12) requires a 100 pF decoupling capacitor to GND at the pin per the characterization test board (Murata GRM1555C1H101JA01D, 0402)"
    (ref "pma3-24323ln+.pdf" (page 7) (quote "C1, C2, C3,C4 Murata GRM1555C1H101JA01D 100 pF 0402"))
    (check (decoupling (pin "VDD1") (pin "GND_1") (min-uf 0.0001))))

  (requirement "VDD2 (pin 10) requires a 100 pF decoupling capacitor to GND at the pin per the characterization test board (Murata GRM1555C1H101JA01D, 0402)"
    (ref "pma3-24323ln+.pdf" (page 7) (quote "C1, C2, C3,C4 Murata GRM1555C1H101JA01D 100 pF 0402"))
    (check (decoupling (pin "VDD2") (pin "GND_1") (min-uf 0.0001))))

  (requirement "VDD3 (pin 4) requires a 100 pF decoupling capacitor to GND at the pin per the characterization test board (Murata GRM1555C1H101JA01D, 0402)"
    (ref "pma3-24323ln+.pdf" (page 7) (quote "C1, C2, C3,C4 Murata GRM1555C1H101JA01D 100 pF 0402"))
    (check (decoupling (pin "VDD3") (pin "GND_1") (min-uf 0.0001))))

  (requirement "VDD4 (pin 6) requires a 100 pF decoupling capacitor to GND at the pin per the characterization test board (Murata GRM1555C1H101JA01D, 0402)"
    (ref "pma3-24323ln+.pdf" (page 7) (quote "C1, C2, C3,C4 Murata GRM1555C1H101JA01D 100 pF 0402"))
    (check (decoupling (pin "VDD4") (pin "GND_1") (min-uf 0.0001))))

  ;; --- Grounding ---------------------------------------------------------
  (requirement "All ground pins (1, 3, 7, 9) and the exposed paddle (pin 13) must be tied to a single ground plane for RF return path and thermal dissipation"
    (ref "pma3-24323ln+.pdf" (page 7) (quote "GND Pads connect to Ground"))
    (check (pins-on-same-net (pins "GND_1" "GND_2" "GND_3" "GND_4" "GND_5"))))

  (requirement "NC pins 5 and 11 are not used internally and should be connected to ground on the PCB (per the Mini-Circuits characterization test board)"
    (ref "pma3-24323ln+.pdf" (page 7) (quote "Not used internally. Connected to ground on test board."))
    (check (pins-on-same-net (pins "NC_1" "NC_2" "GND_1"))))

  ;; --- RF interfaces ------------------------------------------------------
  (requirement "RF-IN (pin 2) is internally 50 Ω matched over 24 - 32 GHz; route as a 50 Ω controlled-impedance trace and minimize discontinuities, vias, and stubs"
    (ref "pma3-24323ln+.pdf" (page 1) (quote "as a 50Ω matched amplifier requiring no external matching")))

  (requirement "RF-OUT (pin 8) is internally 50 Ω matched over 24 - 32 GHz; route as a 50 Ω controlled-impedance trace and minimize discontinuities, vias, and stubs"
    (ref "pma3-24323ln+.pdf" (page 1) (quote "as a 50Ω matched amplifier requiring no external matching")))

  (requirement "Absolute maximum CW input power at RF-IN is +23 dBm at VS = +5 V; preceding stages and layout must guarantee this is never exceeded"
    (ref "pma3-24323ln+.pdf" (page 6) (quote "Input Power (CW), VS = +5 V +23 dBm")))

  ;; --- Thermal / environmental -------------------------------------------
  (requirement "Operating ambient temperature range is -45 °C to +85 °C"
    (ref "pma3-24323ln+.pdf" (page 6) (quote "Operating Temperature -45 °C to +85 °C")))

  (requirement "Junction temperature must remain below +150 °C; with ΘJC = 32.2 °C/W and typical Pdiss ≈ 0.64 W (5 V × 128 mA), ensure the exposed paddle has low-impedance thermal contact to the PCB ground plane"
    (ref "pma3-24323ln+.pdf" (page 6) (quote "Junction Temperature +150 °C ... Thermal Resistance (ΘJC) 32.2ºC/W")))

  (requirement "Total power dissipation must not exceed 1.62 W"
    (ref "pma3-24323ln+.pdf" (page 6) (quote "Total Power Dissipation 1.62 W")))

  ;; --- Handling ----------------------------------------------------------
  (requirement "ESD protection class is HBM 1A (250 V to <500 V); apply industry-standard ESD handling precautions during assembly"
    (ref "pma3-24323ln+.pdf" (page 6) (quote "Human Body Model (HBM) 1A 250V to <500V")))

  (requirement "Moisture sensitivity level is MSL1 per IPC/JEDEC J-STD-020E / J-STD-033C; no special pre-bake required, but follow standard reflow practice"
    (ref "pma3-24323ln+.pdf" (page 6) (quote "Moisture Sensitivity: MSL1 in accordance with IPC/JEDEC J-STD-020E/JEDEC J-STD-033C")))
  (datasheet "PMA3-24323LN_.pdf"))
