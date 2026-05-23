(component "adf5901acpz-rl7"
  (description "24 GHz VCO and PGA with 2-Channel PA Output")
  (pinout "adf5901acpz-rl7")
  (footprint "qfn50p500x500x80-33n-d")
  (manufacturer "Analog Devices")
  (mpn "ADF5901ACPZ-RL7")
  (datasheet "adf5901__2_.pdf")

  ;; --- Power supplies ----------------------------------------------------
  (requirement "Analog supply AHI must be 3.135 V to 3.465 V (3.3 V +/- 5%)"
    (ref "adf5901__2_.pdf" (page 3) (quote "AHI, TX_AHI, RF_AHI, VCO_AHI, DVDD 3.135 3.3 3.465 V"))
    (check (voltage-range (pin "AHI") (min 3.135) (max 3.465))))

  (requirement "Tx supply TX_AHI_1 must be 3.135 V to 3.465 V and equal to AHI (max +/- 0.3 V offset)"
    (ref "adf5901__2_.pdf" (page 6) (quote "AHI to TX_AHI -0.3 V to +0.3 V"))
    (check (voltage-range (pin "TX_AHI_1") (min 3.135) (max 3.465))))

  (requirement "Tx supply TX_AHI_2 must be 3.135 V to 3.465 V and equal to AHI"
    (ref "adf5901__2_.pdf" (page 6) (quote "AHI to TX_AHI -0.3 V to +0.3 V"))
    (check (voltage-range (pin "TX_AHI_2") (min 3.135) (max 3.465))))

  (requirement "RF supply RF_AHI must be 3.135 V to 3.465 V and equal to AHI"
    (ref "adf5901__2_.pdf" (page 6) (quote "AHI to RF_AHI -0.3 V to +0.3 V"))
    (check (voltage-range (pin "RF_AHI") (min 3.135) (max 3.465))))

  (requirement "VCO supply VCO_AHI must be 3.135 V to 3.465 V and equal to AHI"
    (ref "adf5901__2_.pdf" (page 6) (quote "AHI to VCO_AHI -0.3 V to +0.3 V"))
    (check (voltage-range (pin "VCO_AHI") (min 3.135) (max 3.465))))

  (requirement "Digital supply DVDD must be 3.135 V to 3.465 V and equal to AHI"
    (ref "adf5901__2_.pdf" (page 6) (quote "AHI to DVDD -0.3 V to +0.3 V"))
    (check (voltage-range (pin "DVDD") (min 3.135) (max 3.465))))

  (requirement "All five 3.3 V supply rails (AHI, TX_AHI_1, TX_AHI_2, RF_AHI, VCO_AHI, DVDD) must be tied to the same 3.3 V net; the data sheet limits the rail-to-rail offset to +/- 0.3 V"
    (ref "adf5901__2_.pdf" (page 6) (quote "AHI to TX_AHI -0.3 V to +0.3 V; AHI to RF_AHI -0.3 V to +0.3 V; AHI to VCO_AHI -0.3 V to +0.3 V; AHI to DVDD -0.3 V to +0.3 V"))
    (check (pins-on-same-net (pins "AHI" "TX_AHI_1" "TX_AHI_2" "RF_AHI" "VCO_AHI" "DVDD"))))

  (requirement "Typical total supply current is 170 mA at AHI = 3.3 V, fREFIN = 100 MHz, RF = 24.125 GHz; size the 3.3 V rail for >= 200 mA peak to cover calibration and tolerance"
    (ref "adf5901__2_.pdf" (page 3) (quote "Total Current, ITOTAL 170 mA")))

  ;; --- Decoupling --------------------------------------------------------
  (requirement "Decouple AHI to GND with a 100 nF + 1 nF + 10 pF triplet placed as close as possible to the pin"
    (ref "adf5901__2_.pdf" (page 7) (quote "Connect decoupling capacitors (0.1 uF, 1 nF, and 10 pF) to the ground plane as close as possible to this pin"))
    (check (decoupling (pin "AHI") (pin "GND_1") (min-uf 0.09))))

  (requirement "Decouple each TX_AHI pin (TX_AHI_1, TX_AHI_2) with a 100 nF + 1 nF + 10 pF triplet placed as close as possible"
    (ref "adf5901__2_.pdf" (page 7) (quote "Voltage Supply for the Tx Section. Connect decoupling capacitors (0.1 uF, 1 nF, and 10 pF) to the ground plane as close as possible to this pin. TX_AHI must be the same value as AHI"))
    (check (decoupling-per-pin (return-pin "GND_1") (pins "TX_AHI_1" "TX_AHI_2") (min-uf 0.09) (count 2))))

  (requirement "Decouple RF_AHI to GND with a 100 nF + 1 nF + 10 pF triplet placed as close as possible to the pin"
    (ref "adf5901__2_.pdf" (page 7) (quote "Voltage Supply for the RF Section. Connect decoupling capacitors (0.1 uF, 1 nF, and 10 pF) to the ground plane as close as possible to this pin"))
    (check (decoupling (pin "RF_AHI") (pin "GND_1") (min-uf 0.09))))

  (requirement "Decouple VCO_AHI to GND with a 100 nF + 1 nF + 10 pF triplet placed as close as possible to the pin"
    (ref "adf5901__2_.pdf" (page 8) (quote "Voltage Supply for the VCO Section. Connect decoupling capacitors (0.1 uF, 1 nF, and 10 pF) to the ground plane as close as possible to this pin"))
    (check (decoupling (pin "VCO_AHI") (pin "GND_1") (min-uf 0.09))))

  (requirement "Decouple DVDD to GND with a 100 nF + 1 nF + 10 pF triplet placed as close as possible to the pin"
    (ref "adf5901__2_.pdf" (page 7) (quote "Place decoupling capacitors (0.1 uF, 1 nF, and 10 pF) to the ground plane as close as possible to this pin. DVDD must be the same value as AHI"))
    (check (decoupling (pin "DVDD") (pin "GND_1") (min-uf 0.09))))

  (requirement "VREG (internal 1.8 V regulator output) requires a 220 nF capacitor to GND placed as close as possible to the pin"
    (ref "adf5901__2_.pdf" (page 7) (quote "Internal 1.8 V Regulator Output. Connect a 220 nF capacitor to ground as close as possible to this pin"))
    (check (decoupling (pin "VREG") (pin "GND_1") (min-uf 0.2))))

  (requirement "C1 pin requires a 47 nF decoupling capacitor to GND placed as close as possible"
    (ref "adf5901__2_.pdf" (page 8) (quote "Decoupling Capacitor 1. Place a 47 nF capacitor to ground as close as possible to this pin"))
    (check (decoupling (pin "C1") (pin "GND_1") (min-uf 0.04))))

  (requirement "C2 pin requires a 220 nF decoupling capacitor to GND placed as close as possible"
    (ref "adf5901__2_.pdf" (page 8) (quote "Decoupling Capacitor 2. Place a 220 nF capacitor to ground as close as possible to this pin"))
    (check (decoupling (pin "C2") (pin "GND_1") (min-uf 0.2))))

  ;; --- Grounding ---------------------------------------------------------
  (requirement "All 8 GND pins and the exposed pad (EP) must be tied to the ground plane"
    (ref "adf5901__2_.pdf" (page 7) (quote "RF Ground. Tie all ground pins together. The LFCSP has an exposed pad that must be connected to GND"))
    (check (pins-on-same-net (pins "GND_1" "GND_2" "GND_3" "GND_4" "GND_5" "GND_6" "GND_7" "GND_8" "EP"))))

  ;; --- Bias --------------------------------------------------------------
  (requirement "Tie a 5.1 kohm resistor between RSET and GND to set the internal reference current; nominal voltage at RSET is 0.62 V"
    (ref "adf5901__2_.pdf" (page 7) (quote "Connecting a 5.1 kohm resistor between this pin and GND sets an internal current. The nominal voltage potential at the RSET pin is 0.62 V")))

  ;; --- VTUNE -------------------------------------------------------------
  (requirement "VTUNE operating range is 1 V to 2.8 V to cover the 24 GHz to 24.25 GHz band; the data sheet absolute maximum is -0.3 V to +3.6 V"
    (ref "adf5901__2_.pdf" (page 3) (quote "VTUNE 1 2.8 V; VTUNE Impedance 100 kohm"))
    (check (voltage-range (pin "VTUNE") (min 1.0) (max 2.8))))

  (requirement "VTUNE input impedance is 100 kohm; size the loop filter source impedance accordingly (the ADF4159 reference design uses ~510 ohm series with shunt RC)"
    (ref "adf5901__2_.pdf" (page 3) (quote "VTUNE Impedance 100 kohm")))

  ;; --- REFIN -------------------------------------------------------------
  (requirement "REFIN frequency range is 10 MHz to 260 MHz; for frequencies below 10 MHz a dc-coupled CMOS square wave with slew rate > 25 V/us is required"
    (ref "adf5901__2_.pdf" (page 4) (quote "REFIN Input Frequency 10 260 MHz; for frequencies < 10 MHz, use a dc-coupled, CMOS-compatible square wave with a slew rate > 25 V/us")))

  (requirement "REFIN input power must be -5 dBm minimum to +9 dBm maximum; the input is ac-coupled internally and biased at AHI/2"
    (ref "adf5901__2_.pdf" (page 4) (quote "-5 dBm minimum to +9 dBm maximum biased at AHI/2 (ac coupling ensures 1.8/2 bias)")))

  (requirement "When the on-chip REFIN doubler is enabled (R7 bit DB10), the maximum REFIN frequency drops to 50 MHz"
    (ref "adf5901__2_.pdf" (page 21) (quote "The maximum allowable REFIN frequency when the doubler is enabled is 50 MHz")))

  ;; --- RF outputs --------------------------------------------------------
  (requirement "TXOUT1 and TXOUT2 are 50 ohm single-ended outputs with 8 dBm typical (range -20 dBm to +10 dBm via PGA); only one Tx channel may be powered up at a time"
    (ref "adf5901__2_.pdf" (page 3) (quote "Output Power 2 8 10 dBm; Output Impedance 50 ohm")))

  (requirement "LOOUT is a 50 ohm single-ended output, typical -1 dBm (range -7 dBm to +5 dBm); intended to drive the LO input of a companion receiver such as the ADF5904"
    (ref "adf5901__2_.pdf" (page 3) (quote "LO OUTPUT Output Power -7 -1 +5 dBm; Output Impedance 50 ohm")))

  (requirement "AUX and ~AUX form a 200 ohm differential auxiliary output running at VCO/2 (~12 GHz) or VCO/4 (~6 GHz), selected by R0 bit DB20"
    (ref "adf5901__2_.pdf" (page 3) (quote "AUX PIN OUTPUT Output Impedance 200 ohm Differential; Divide by 2 Output 12 12.125 GHz; Divide by 4 Output 6 6.0625 GHz")))

  ;; --- SPI / digital control --------------------------------------------
  (requirement "SPI is a 4-wire interface (CE, CLK, DATA, LE); data is clocked in MSB first on the rising edge of CLK and latched into one of the 12 registers on the rising edge of LE"
    (ref "adf5901__2_.pdf" (page 7) (quote "Serial Clock Input. This serial clock input clocks in the serial data to the registers. The data is latched into the 32-bit shift register on the CLK rising edge")))

  (requirement "SPI write timing: LE setup 20 ns min, DATA-to-CLK setup 10 ns min, DATA-to-CLK hold 10 ns min, CLK high/low 25 ns min each, LE pulse width 20 ns min"
    (ref "adf5901__2_.pdf" (page 4) (quote "t1 20 ns min LE setup time; t2 10 ns min DATA to CLK setup time; t3 10 ns min DATA to CLK hold time; t4 25 ns min CLK high duration; t5 25 ns min CLK low duration; t7 20 ns min LE pulse width")))

  (requirement "DOUT logic level is selectable 1.8 V or 3.3 V via Register 3 bit DB11 (IOL); when 3.3 V is selected DOUT swings to DVDD"
    (ref "adf5901__2_.pdf" (page 4) (quote "VDD selected from IO level bit (DB11 in Register 3)")))

  (requirement "SPI/CE/LE input levels are CMOS: VIH >= 1.4 V, VIL <= 0.6 V; outputs source/sink 500 uA with VOH >= VDD - 0.4 V, VOL <= 0.4 V"
    (ref "adf5901__2_.pdf" (page 4) (quote "Input Voltage High (VIH) 1.4 V Low (VIL) 0.6 V")))

  (requirement "CE must be driven high to power up the device; a logic low forces hardware power-down (typ 200 uA)"
    (ref "adf5901__2_.pdf" (page 7) (quote "Chip Enable. A logic low on this pin powers down the device. Taking the pin high powers up the device")))

  ;; --- Calibration -------------------------------------------------------
  (requirement "After power-up the host must run the initialization sequence in the data sheet (VCO calibration ~800 us, then Tx1 amplitude cal ~400 us, then Tx2 amplitude cal ~400 us) before useful Tx output is available"
    (ref "adf5901__2_.pdf" (page 23) (quote "INITIALIZATION SEQUENCE After powering up the device, administer the following programming sequence")))

  (requirement "Re-run the recalibration sequence for every 10 degC ambient change; the on-chip temperature sensor on ATEST or via the ADC on DOUT can be used to track this"
    (ref "adf5901__2_.pdf" (page 23) (quote "The recalibration sequence must be run for every 10 degC temperature change; the temperature can be monitored using the temperature sensor")))

  ;; --- Environmental and reliability -------------------------------------
  (requirement "Operating ambient temperature range is -40 degC to +105 degC; max junction 150 degC, theta_JA 40.83 degC/W (paddle soldered); the exposed pad must have a low-impedance thermal path to the ground plane via copper pours and stitching vias"
    (ref "adf5901__2_.pdf" (page 6) (quote "Operating Temperature Range -40 to +105; Maximum Junction Temperature 150; theta_JA Thermal Impedance (Paddle Soldered) 40.83")))

  (requirement "Absolute maximum supply: AHI to GND -0.3 V to +3.9 V; VTUNE to GND -0.3 V to +3.6 V; digital I/O to GND -0.3 V to DVDD + 0.3 V"
    (ref "adf5901__2_.pdf" (page 6) (quote "AHI to GND -0.3 V to +3.9 V; VTUNE to GND -0.3 V to +3.6 V; Digital Input/Output Voltage to GND -0.3 V to DVDD + 0.3 V")))

  (requirement "ESD rating: HBM 2000 V, CDM 250 V; handle and assemble per AEC-Q100 / JEDEC ESD precautions"
    (ref "adf5901__2_.pdf" (page 6) (quote "Charged Device Model 250 V; Human Body Model 2000 V"))))
