(component "adar2001accz"
  (description "ADAR2001 10 GHz to 40 GHz 1:4 Channel 4x Frequency Multiplier/Filter Tx")
  (pinout "adar2001accz")
  (footprint "lga-cc-40-7-adi")
  (manufacturer "Analog Devices")
  (mpn "ADAR2001ACCZ")
  (datasheet "adar2001.pdf")

  ;; --- Power supplies ----------------------------------------------------
  ;; The 2.5 V analog rail feeds VPOS1 (pin 1), VPOS3 (pin 21), VPOS4 (pin 31),
  ;; and VPOS5 (pin 40 - exposed in the pinout as "VPOS" because of an
  ;; auto-generation truncation; checks below use the pinout name).
  (requirement "Analog supply VPOS1 must be 2.25 V to 2.75 V (2.5 V typical)"
    (ref "adar2001.pdf" (page 4) (quote "Supply Voltage Range (VPOS1, VPOS3, VPOS4, VPOS5) 2.25 2.5 2.75 V"))
    (check (voltage-range (pin "VPOS1") (min 2.25) (max 2.75))))

  (requirement "Analog supply VPOS3 must be 2.25 V to 2.75 V (2.5 V typical)"
    (ref "adar2001.pdf" (page 4) (quote "Supply Voltage Range (VPOS1, VPOS3, VPOS4, VPOS5) 2.25 2.5 2.75 V"))
    (check (voltage-range (pin "VPOS3") (min 2.25) (max 2.75))))

  (requirement "Analog supply VPOS4 must be 2.25 V to 2.75 V (2.5 V typical)"
    (ref "adar2001.pdf" (page 4) (quote "Supply Voltage Range (VPOS1, VPOS3, VPOS4, VPOS5) 2.25 2.5 2.75 V"))
    (check (voltage-range (pin "VPOS4") (min 2.25) (max 2.75))))

  (requirement "Analog supply VPOS5 (pin 40, exposed in the pinout as VPOS) must be 2.25 V to 2.75 V (2.5 V typical)"
    (ref "adar2001.pdf" (page 4) (quote "Supply Voltage Range (VPOS1, VPOS3, VPOS4, VPOS5) 2.25 2.5 2.75 V"))
    (check (voltage-range (pin "VPOS") (min 2.25) (max 2.75))))

  (requirement "Digital supply VPOS2 (pin 7) must be 1.6 V to 2.0 V (1.8 V typical)"
    (ref "adar2001.pdf" (page 4) (quote "Supply Voltage Range (VPOS2) 1.6 1.8 2 V"))
    (check (voltage-range (pin "VPOS2") (min 1.6) (max 2.0))))

  (requirement "VPOS2 must be connected directly to VREG (the on-chip 1.8 V LDO output on pin 6)"
    (ref "adar2001.pdf" (page 7) (quote "Directly connect this supply to Pin 6 (VREG)"))
    (check (connected (pin "VPOS2") (pin "VREG"))))

  ;; --- Decoupling --------------------------------------------------------
  (requirement "Each VPOSx 2.5 V analog supply pin (VPOS1, VPOS3, VPOS4, VPOS5) needs a 10 nF + 100 pF decoupling pair to GND placed as close as possible to the pin"
    (ref "adar2001.pdf" (page 7) (quote "one 10 nF and one 100 pF on each pin"))
    (check (decoupling-per-pin (return-pin "GND1") (pins "VPOS1" "VPOS3" "VPOS4" "VPOS") (min-uf 0.01) (count 4))))

  (requirement "Add a 1 uF bulk capacitor to GND on the shared 2.5 V analog rail feeding VPOS1, VPOS3, VPOS4, VPOS5"
    (ref "adar2001.pdf" (page 7) (quote "1 uF for the rail")))

  (requirement "VPOS2 (1.8 V digital supply) requires a 1 uF decoupling capacitor to GND placed as close as possible to the pin"
    (ref "adar2001.pdf" (page 7) (quote "Place a 1 uF capacitor to ground as close as possible to VPOS2"))
    (check (decoupling (pin "VPOS2") (pin "GND1") (min-uf 0.9))))

  ;; --- Grounding ---------------------------------------------------------
  (requirement "All 17 GND pins must be connected to a single ground plane with low thermal and electrical impedance"
    (ref "adar2001.pdf" (page 7) (quote "Connect all ground pins to a ground plane with low thermal and electrical impedance"))
    (check (pins-on-same-net (pins "GND1" "GND2" "GND3" "GND4" "GND5" "GND6" "GND7" "GND8" "GND9" "GND10" "GND11" "GND12" "GND13" "GND14" "GND15" "GND16" "GND17"))))

  (requirement "All four exposed-pad pins (EPAD1..EPAD4) must be tied to the ground plane for thermal and electrical grounding"
    (ref "adar2001.pdf" (page 7) (quote "The exposed pad must be connected to a ground plane with low thermal and electrical impedance"))
    (check (pins-on-same-net (pins "EPAD1" "EPAD2" "EPAD3" "EPAD4" "GND1"))))

  ;; --- SPI / digital control --------------------------------------------
  (requirement "Tie a 200 kohm pull-up resistor from *CS to 1.8 V (VREG) so the SPI port stays inactive when not addressed"
    (ref "adar2001.pdf" (page 7) (quote "Connect a 200 kohm pull-up resistor to 1.8 V from CS to ensure that the SPI interface is deactivated when not in use")))

  (requirement "SCLK maximum rate is 40 MHz for write-only transactions and 15 MHz when reads are interleaved"
    (ref "adar2001.pdf" (page 4) (quote "Maximum clock rate Write only 40 MHz Write and read 15 MHz")))

  (requirement "Digital inputs (SCLK, SDIO, *CS, MRST, MADV, TXRST, TXADV) are 1.8 V CMOS: VIL <= 0.3 V, VIH >= 1.0 V; absolute max +2.1 V"
    (ref "adar2001.pdf" (page 4) (quote "Logic Low 0 0.3 V Logic High 1 1.8 V")))

  (requirement "MRST/MADV/TXRST/TXADV pulses require minimum 3 ns pulse width and minimum 10 ns pulse-start to pulse-start separation"
    (ref "adar2001.pdf" (page 3) (quote "Minimum Pulse Width MADV, MRST 3 ns")))

  ;; --- RF input ----------------------------------------------------------
  (requirement "RFIN is a 50 ohm single-ended input, ac-coupled on-die; usable RF input range 2.5 to 10 GHz"
    (ref "adar2001.pdf" (page 7) (quote "RFIN is a single-ended, 50 ohm input operating from 2.5 GHz to 10 GHz, ac-coupled internally")))

  (requirement "RFIN nominal drive level is -20 dBm (operating range -25 to -10 dBm)"
    (ref "adar2001.pdf" (page 3) (quote "Power Range -25 -20 -10 dBm")))

  (requirement "RFIN absolute maximum CW power is -5 dBm; do not exceed under any condition"
    (ref "adar2001.pdf" (page 6) (quote "RFIN Power -5 dBm")))

  ;; --- RF outputs --------------------------------------------------------
  (requirement "RFOUTx+/- are 100 ohm differential pairs, ac-coupled on-die, operating 10-40 GHz with 5 dBm typical differential output power at -20 dBm RFIN"
    (ref "adar2001.pdf" (page 7) (quote "RFOUTx are 100 ohm differential pairs, ac-coupled internally")))

  (requirement "All eight RFOUT traces (RFOUT1+/-, RFOUT2+/-, RFOUT3+/-, RFOUT4+/-) must be length-matched electrically and mechanically"
    (ref "adar2001.pdf" (page 7) (quote "All eight lines must have equal electrical and mechanical lengths")))

  (requirement "If a single-ended RFOUT is required, terminate the unused leg to GND through a 50 ohm resistor; expect 3 dB lower output power (about 2 dBm) and some harmonic-rejection degradation"
    (ref "adar2001.pdf" (page 13) (quote "the unused output can be terminated to ground using a 50 ohm resistor")))

  ;; --- Environmental -----------------------------------------------------
  (requirement "Operating ambient temperature range is -40 degC to +85 degC; thermal design must keep junction below 135 degC"
    (ref "adar2001.pdf" (page 6) (quote "Operating Temperature Range -40 to +85 ... Maximum Junction Temperature 135"))))
