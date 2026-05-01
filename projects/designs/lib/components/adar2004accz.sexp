(component "adar2004accz"
  (description "ADAR2004 10 GHz to 40 GHz 4-Channel Rx Mixer with 4x LO Multiplier/Filter")
  (pinout "adar2004accz")
  (footprint "lga-cc-48-2-adi")
  (manufacturer "Analog Devices")
  (mpn "ADAR2004ACCZ")
  (datasheet "adar2004.pdf")

  ;; --- Power supplies ----------------------------------------------------
  (requirement "Analog supply VPOS1 must be 2.25 V to 2.75 V (2.5 V typical)"
    (ref "adar2004.pdf" (page 4) (quote "Supply Voltage Range (VPOS1, VPOS2, VPOS4) 2.25 2.5 2.75 V"))
    (check (voltage-range (pin "VPOS1") (min 2.25) (max 2.75))))

  (requirement "Analog supply VPOS2 must be 2.25 V to 2.75 V (2.5 V typical)"
    (ref "adar2004.pdf" (page 4) (quote "Supply Voltage Range (VPOS1, VPOS2, VPOS4) 2.25 2.5 2.75 V"))
    (check (voltage-range (pin "VPOS2") (min 2.25) (max 2.75))))

  (requirement "Analog supply VPOS4 must be 2.25 V to 2.75 V (2.5 V typical)"
    (ref "adar2004.pdf" (page 4) (quote "Supply Voltage Range (VPOS1, VPOS2, VPOS4) 2.25 2.5 2.75 V"))
    (check (voltage-range (pin "VPOS4") (min 2.25) (max 2.75))))

  (requirement "Digital supply VPOS3 must be 1.6 V to 2.0 V (1.8 V typical)"
    (ref "adar2004.pdf" (page 4) (quote "Supply Voltage Range (VPOS3) 1.6 1.8 2 V"))
    (check (voltage-range (pin "VPOS3") (min 1.6) (max 2.0))))

  (requirement "VPOS3 must be connected directly to VREG (the on-chip 1.8 V LDO output)"
    (ref "adar2004.pdf" (page 7) (quote "Connect this supply directly to VREG"))
    (check (connected (pin "VPOS3") (pin "VREG"))))

  ;; --- Decoupling --------------------------------------------------------
  (requirement "Each VPOSx analog supply pin (VPOS1, VPOS2, VPOS4) needs a 10 nF + 100 pF decoupling pair to GND placed as close as possible to the pin"
    (ref "adar2004.pdf" (page 7) (quote "one 10 nF and one 100 pF on each pin"))
    (check (decoupling-per-pin (return-pin "GND1") (pins "VPOS1" "VPOS2" "VPOS4") (min-uf 0.01) (count 3))))

  (requirement "Add a 1 uF bulk capacitor to GND on the shared 2.5 V analog rail feeding VPOS1, VPOS2, VPOS4"
    (ref "adar2004.pdf" (page 7) (quote "1 uF for the rail")))

  (requirement "VPOS3 (1.8 V digital supply) requires a 1 uF decoupling capacitor to GND placed as close as possible to the pin"
    (ref "adar2004.pdf" (page 7) (quote "Place a 1 uF capacitor to ground as close as possible to VPOS3"))
    (check (decoupling (pin "VPOS3") (pin "GND1") (min-uf 0.9))))

  ;; --- Grounding ---------------------------------------------------------
  (requirement "All 18 GND pins must be connected to a single ground plane with low thermal and electrical impedance"
    (ref "adar2004.pdf" (page 7) (quote "Connect all ground pins to a ground plane with low thermal and electrical impedance"))
    (check (pins-on-same-net (pins "GND1" "GND2" "GND3" "GND4" "GND5" "GND6" "GND7" "GND8" "GND9" "GND10" "GND11" "GND12" "GND13" "GND14" "GND15" "GND16" "GND17" "GND18"))))

  (requirement "All four exposed-pad pins (EPAD1..EPAD4) must be tied to the ground plane for thermal and electrical grounding"
    (ref "adar2004.pdf" (page 8) (quote "The exposed pad must be connected to a ground plane with low thermal and electrical impedance"))
    (check (pins-on-same-net (pins "EPAD1" "EPAD2" "EPAD3" "EPAD4" "GND1"))))

  ;; --- SPI / digital control --------------------------------------------
  (requirement "Tie a 200 kohm pull-up resistor from *CS to 1.8 V (VREG) so the SPI port stays inactive when not addressed"
    (ref "adar2004.pdf" (page 7) (quote "Connect a 200 kohm pull-up resistor to 1.8 V to ensure that the SPI is shut off while not in use")))

  (requirement "SCLK maximum rate is 40 MHz for write-only transactions and 15 MHz when reads are interleaved"
    (ref "adar2004.pdf" (page 4) (quote "Maximum clock rate Write only 40 MHz Write and read 15 MHz")))

  (requirement "Digital inputs (SCLK, SDIO, *CS, MRST, MADV, RXRST, RXADV) are 1.8 V CMOS: VIL <= 0.3 V, VIH >= 1.0 V, do not exceed 2.0 V absolute max"
    (ref "adar2004.pdf" (page 3) (quote "Logic Low 0 0.3 V Logic High 1 1.8 V")))

  (requirement "MRST/MADV/RXRST/RXADV pulses require minimum 3 ns pulse width and minimum 10 ns pulse-start to pulse-start separation"
    (ref "adar2004.pdf" (page 3) (quote "Minimum Pulse Width MADV, MRST 3 ns")))

  ;; --- RF / IF / LO interfaces ------------------------------------------
  (requirement "RFINx+/- are 100 ohm differential pairs, ac-coupled on-die; usable RF input range 10-40 GHz"
    (ref "adar2004.pdf" (page 7) (quote "RFINx are 100 ohm differential pairs, ac-coupled internally")))

  (requirement "All eight RFIN traces (RFIN1+/-, RFIN2+/-, RFIN3+/-, RFIN4+/-) must be length-matched electrically and mechanically for channel-to-channel consistency"
    (ref "adar2004.pdf" (page 7) (quote "All eight lines must have equal electrical and mechanical lengths to ensure consistent performance from channel to channel")))

  (requirement "RF input absolute maximum CW power is +20 dBm; layout and any front-end gain must guarantee this is never exceeded"
    (ref "adar2004.pdf" (page 6) (quote "RFINx Power 20 dBm")))

  (requirement "IFOUTx+/- are 100 ohm differential pairs, dc-coupled on-die; usable IF output range 0-800 MHz, VOCM programmable 0.65-1.2 V"
    (ref "adar2004.pdf" (page 7) (quote "IFOUTx are 100 ohm differential pairs, dc-coupled internally")))

  (requirement "All eight IFOUT traces (IFOUT1+/-, IFOUT2+/-, IFOUT3+/-, IFOUT4+/-) must be length-matched electrically and mechanically"
    (ref "adar2004.pdf" (page 7) (quote "All eight lines must have equal electrical and mechanical lengths")))

  (requirement "LOIN is a 50 ohm single-ended input, ac-coupled on-die; nominal drive -20 dBm (range -25 to -10 dBm), 2.4-10.1 GHz"
    (ref "adar2004.pdf" (page 7) (quote "LOIN is a single-ended, 50 ohm input operating from 2.4 GHz to 10.1 GHz, ac-coupled internally")))

  (requirement "LOIN absolute maximum power is -5 dBm"
    (ref "adar2004.pdf" (page 6) (quote "LOIN Power -5 dBm")))

  ;; --- Environmental -----------------------------------------------------
  (requirement "Operating ambient temperature range is -40 degC to +85 degC; thermal design must keep junction below 135 degC"
    (ref "adar2004.pdf" (page 6) (quote "Operating Range -40 to +85 ... Junction 135"))))
