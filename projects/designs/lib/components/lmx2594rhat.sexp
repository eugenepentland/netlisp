(component "lmx2594rhat"
  (description "15 GHz Wideband PLLatinum&#153; RF Synthesizer with Phase Synchronization and JESD204B support")
  (pinout "lmx2594rhat")
  (footprint "qfn50p600x600x100-41n-d")
  (manufacturer "Texas Instruments")
  (mpn "LMX2594RHAT")
  (datasheet "lmx2594.pdf")

  ;; --- Power supplies (3.3 V single supply, 3.15-3.45 V) -----------------
  (requirement "VCCDIG digital supply must be 3.15 V to 3.45 V (3.3 V typical)"
    (ref "lmx2594.pdf" (page 8) (quote "VCC Power supply voltage 3.15 3.3 3.45 V"))
    (check (voltage-range (pin "VCCDIG") (min 3.15) (max 3.45))))

  (requirement "VCCCP charge-pump supply must be 3.15 V to 3.45 V (3.3 V typical)"
    (ref "lmx2594.pdf" (page 8) (quote "VCC Power supply voltage 3.15 3.3 3.45 V"))
    (check (voltage-range (pin "VCCCP") (min 3.15) (max 3.45))))

  (requirement "VCCMASH digital supply must be 3.15 V to 3.45 V (3.3 V typical)"
    (ref "lmx2594.pdf" (page 8) (quote "VCC Power supply voltage 3.15 3.3 3.45 V"))
    (check (voltage-range (pin "VCCMASH") (min 3.15) (max 3.45))))

  (requirement "VCCBUF output-buffer supply must be 3.15 V to 3.45 V (3.3 V typical); this rail also feeds the external pullups on RFoutA/B"
    (ref "lmx2594.pdf" (page 8) (quote "VCC Power supply voltage 3.15 3.3 3.45 V"))
    (check (voltage-range (pin "VCCBUF") (min 3.15) (max 3.45))))

  (requirement "VCCVCO2 supply must be 3.15 V to 3.45 V (3.3 V typical)"
    (ref "lmx2594.pdf" (page 8) (quote "VCC Power supply voltage 3.15 3.3 3.45 V"))
    (check (voltage-range (pin "VCCVCO2") (min 3.15) (max 3.45))))

  (requirement "VCCVCO supply must be 3.15 V to 3.45 V (3.3 V typical)"
    (ref "lmx2594.pdf" (page 8) (quote "VCC Power supply voltage 3.15 3.3 3.45 V"))
    (check (voltage-range (pin "VCCVCO") (min 3.15) (max 3.45))))

  ;; --- VCC bypass (values not mandated by TI as of Rev C; just require a cap per pin) ---
  (requirement "Each VCC supply pin (VCCDIG, VCCCP, VCCMASH, VCCBUF, VCCVCO2, VCCVCO) needs a decoupling capacitor to GND placed close to the pin; exact values are left to the user (TI deleted the recommended values in Rev C)"
    (ref "lmx2594.pdf" (page 2) (quote "Deleted the recommended bypass capacitor values for Vcc pins 7, 11, 15, 21, 26 and 37, as these capacitor values are not mandatory"))
    (check (decoupling-per-pin (return-pin "GND_1") (pins "VCCDIG" "VCCCP" "VCCMASH" "VCCBUF" "VCCVCO2" "VCCVCO") (min-uf 0.05) (count 6))))

  ;; --- Internal-bias / regulator bypass pins (mandatory values, place close to pin) ---
  (requirement "VBIASVCO requires a 10 uF capacitor to VCO ground, placed close to the pin"
    (ref "lmx2594.pdf" (page 7) (quote "VCO bias. Requires a 10-uF capacitor connected to VCO ground. Place close to pin."))
    (check (decoupling (pin "VBIASVCO") (pin "GND_1") (min-uf 8.0))))

  (requirement "VREGIN (input reference-path regulator output) requires a 1 uF capacitor to GND placed close to the pin"
    (ref "lmx2594.pdf" (page 7) (quote "Input reference path regulator output. Requires a 1-uF capacitor connected to ground. Place close to pin."))
    (check (decoupling (pin "VREGIN") (pin "GND_1") (min-uf 0.9))))

  (requirement "VBIASVCO2 requires a 1 uF capacitor to VCO ground"
    (ref "lmx2594.pdf" (page 7) (quote "VCO bias. Requires a 1-uF capacitor connected to VCO ground."))
    (check (decoupling (pin "VBIASVCO2") (pin "GND_1") (min-uf 0.9))))

  (requirement "VREFVCO2 requires a 10 uF capacitor to VCO ground"
    (ref "lmx2594.pdf" (page 7) (quote "VCO supply reference. Requires a 10-uF capacitor connected to VCO ground."))
    (check (decoupling (pin "VREFVCO2") (pin "GND_1") (min-uf 8.0))))

  (requirement "VBIASVARAC (VCO varactor bias) requires a 10 uF capacitor to VCO ground"
    (ref "lmx2594.pdf" (page 7) (quote "VCO Varactor bias. Requires a 10-uF capacitor connected to VCO ground."))
    (check (decoupling (pin "VBIASVARAC") (pin "GND_1") (min-uf 8.0))))

  (requirement "VREFVCO requires a 10 uF capacitor to VCO ground"
    (ref "lmx2594.pdf" (page 7) (quote "VCO supply reference. Requires a 10-uF capacitor connected to VCO ground."))
    (check (decoupling (pin "VREFVCO") (pin "GND_1") (min-uf 8.0))))

  (requirement "VREGVCO (VCO regulator node) requires a 1 uF capacitor to ground"
    (ref "lmx2594.pdf" (page 7) (quote "VCO regulator node. Requires a 1-uF capacitor connected to ground."))
    (check (decoupling (pin "VREGVCO") (pin "GND_1") (min-uf 0.9))))

  ;; --- Reference oscillator input (OSCin) -------------------------------
  (requirement "OSCINP must be AC-coupled (typically 0.1 uF series cap); pin is high-impedance and self-biasing"
    (ref "lmx2594.pdf" (page 7) (quote "Reference input clock (+). High-impedance self-biasing pin. Requires AC-coupling capacitor. (0.1 uF recommended)")))

  (requirement "OSCINM must be AC-coupled (typically 0.1 uF series cap); pin is high-impedance and self-biasing"
    (ref "lmx2594.pdf" (page 7) (quote "Reference input clock (-). High impedance self-biasing pin. Requires AC-coupling capacitor. (0.1 uF recommended)")))

  (requirement "Reference input frequency must be 5-1400 MHz with OSC_2X=0, or 5-200 MHz with OSC_2X=1 (doubler enabled)"
    (ref "lmx2594.pdf" (page 9) (quote "Reference input frequency OSC_2X = 0 5 1400 OSC_2X = 1 5 200")))

  (requirement "Reference input voltage swing must be 0.2 to 2 Vpp (AC-coupled); higher slew rate and lower amplitude (e.g. LVDS) generally give best phase noise"
    (ref "lmx2594.pdf" (page 9) (quote "Reference input voltage AC-coupled required 0.2 2 Vpp")))

  (requirement "If unused, leave OSCINM AC-coupled to a 50 ohm termination to ground; differential OSCin layout must be length-matched"
    (ref "lmx2594.pdf" (page 59) (quote "The OSCin and OSCin* side should be matched in layout")))

  ;; --- Charge pump and loop filter --------------------------------------
  (requirement "CPOUT (charge-pump output) drives an external loop filter; place loop filter C1 as close as possible to the CPOUT pin"
    (ref "lmx2594.pdf" (page 7) (quote "Charge pump output. TI recommends connecting C1 of loop filter close to pin.")))

  (requirement "VTUNE is the VCO tuning-voltage input from the loop filter; place a loop-filter capacitor as close as possible to the VTUNE pin (separate from the rest of the loop filter if necessary)"
    (ref "lmx2594.pdf" (page 65) (quote "For the Vtune pin, try to place a loop filter capacitor as close as possible to the pin. This may mean separating the capacitor from the rest of the loop filter.")))

  ;; --- RF outputs (open-collector, require external pullups) ------------
  (requirement "RFOUTAP requires an external pullup to VCC (typically a 50 ohm resistor) placed as close to the pin as possible; the buffer is open-collector and will not produce output without it"
    (ref "lmx2594.pdf" (page 7) (quote "Differential output A (+). Requires connecting a 50-ohm resistor pullup to Vcc as close to the pin as possible.")))

  (requirement "RFOUTAM requires an external pullup to VCC (typically a 50 ohm resistor) placed as close to the pin as possible; the buffer is open-collector and will not produce output without it"
    (ref "lmx2594.pdf" (page 7) (quote "Differential output A (-). Requires connecting a 50-ohm resistor pullup to Vcc as close to the pin as possible.")))

  (requirement "RFOUTBP requires an external pullup to VCC (typically a 50 ohm resistor) placed as close to the pin as possible; can be used as a normal output or as the SYSREF output"
    (ref "lmx2594.pdf" (page 7) (quote "Differential output B (+). Requires a pullup (typically 50-ohm resistor) connected to Vcc as close to the pin as possible. Can be used as an output signal or SYSREF output.")))

  (requirement "RFOUTBM requires an external pullup to VCC (typically a 50 ohm resistor) placed as close to the pin as possible; can be used as a normal output or as the SYSREF output"
    (ref "lmx2594.pdf" (page 7) (quote "Differential output B (-). Requires a pullup (typically 50-ohm resistor) connected to Vcc as close to the pin as possible. Can be used as an output signal or SYSREF output.")))

  (requirement "Differential RFout pairs must use the same pullup component on both sides (P and M); if running single-ended, the complementary side still needs the same load and pullup so the buffer sees a balanced load"
    (ref "lmx2594.pdf" (page 65) (quote "For the outputs, keep the pullup component as close as possible to the pin and use the same component on each side of the differential pair.")))

  (requirement "Above 13.3 GHz output power can drop at hot temperature; TI recommends OUTx_PWR <= 15 for 13.3-14.3 GHz, OUTx_PWR up to 31 for 14.3-15 GHz, and OUTx_PWR = 50 below 13.3 GHz when using a 50 ohm resistor pullup"
    (ref "lmx2594.pdf" (page 25) (quote "13.3 GHz <= fOUT <= 14.3 GHz OUTx_PWR = 15 OUTx_PWR = 15 TI recommends to set OUTx_PWR <= 15 to avoid the power drop at hot temperature.")))

  ;; --- Grounding --------------------------------------------------------
  (requirement "All GND pins (pins 2, 4, 6, 13, 14, 25, 31, 34, 39, 40) and the DAP (pin 41) must be tied to a single low-impedance ground plane; the package back can route ground from these pins to the DAP"
    (ref "lmx2594.pdf" (page 65) (quote "GND pins may be routed on the package back to the DAP."))
    (check (pins-on-same-net (pins "GND_1" "GND_2" "GND_3" "GND_4" "GND_5" "GND_6" "GND_7" "GND_8" "GND_9" "GND_10" "GND_11"))))

  (requirement "Die-attach pad (pin 41, labeled DAP/GND_11) is the RFout ground; use a copper-filled thermal pad with many vias to maximize thermal and electrical performance"
    (ref "lmx2594.pdf" (page 65) (quote "Ensure that DAP on device is well-grounded with many vias, preferably copper filled. Have a thermal pad that is as large as the LMX2594 exposed pad. Add vias to the thermal pad to maximize thermal performance.")))

  ;; --- SPI digital interface --------------------------------------------
  (requirement "SCK is an SPI clock CMOS input (1.8 V to 3.3 V logic, high-impedance); VIH min 1.4 V, VIL max 0.4 V, do not exceed VCC"
    (ref "lmx2594.pdf" (page 7) (quote "SPI clock. High impedance CMOS input. 1.8-V to 3.3-V logic.")))

  (requirement "SDI is an SPI data CMOS input (1.8 V to 3.3 V logic, high-impedance); VIH min 1.4 V, VIL max 0.4 V"
    (ref "lmx2594.pdf" (page 7) (quote "SPI data. High impedance CMOS input. 1.8-V to 3.3-V logic.")))

  (requirement "CSB is the SPI chip-select-bar CMOS input (1.8 V to 3.3 V logic, high-impedance); must be driven, not floating, since the device only clocks data when CSB is low"
    (ref "lmx2594.pdf" (page 7) (quote "SPI latch. Chip Select Bar. High-impedance CMOS input. 1.8-V to 3.3-V logic."))
    (check (pin-not-floating (pin "CSB"))))

  (requirement "SPI write rate is limited to 75 MHz (tCWL + tCWH > 13.333 ns); SPI readback rate is limited to 50 MHz"
    (ref "lmx2594.pdf" (page 11) (quote "SPI write speed tCWL + tCWH > 13.333 ns 75 MHz")))

  (requirement "MUXOUT is a multiplexed CMOS output (lock-detect, readback, diagnostics, ramp status); VOH = VCC-0.4 V at -10 mA, VOL = 0.4 V at +10 mA"
    (ref "lmx2594.pdf" (page 11) (quote "High-level output voltage MUXout pin Load current = -10 mA VCC - 0.4 V")))

  ;; --- Chip enable and control inputs -----------------------------------
  (requirement "CE is the chip-enable input; active HIGH powers on the device. Must not float; tie to a logic-high net or driven GPIO"
    (ref "lmx2594.pdf" (page 7) (quote "Chip enable input. Active HIGH powers on the device."))
    (check (pin-not-floating (pin "CE"))))

  (requirement "If SYNC mode is not used, the SYNC pin must be ignored in software (INPIN_IGNORE=1) to avoid spurious lock-detect behavior; the pin itself can be left floating, grounded, or driven"
    (ref "lmx2594.pdf" (page 29) (quote "if not using SYNC mode (VCO_PHASE_SYNC = 0), then the INPIN_IGNORE bit must be set to one, otherwise it causes issues with lock detect.")))

  (requirement "If unused, RAMPCLK, RAMPDIR, and SYSREFREQ can be tied to the DAP (ground); otherwise drive them to defined logic levels"
    (ref "lmx2594.pdf" (page 65) (quote "If not used, RampClk, RampDir, and SysRefReq can be grounded to the DAP.")))

  ;; --- Loop filter / phase detector frequency constraints (informational) ---
  (requirement "Phase detector frequency: up to 400 MHz in integer mode (MASH_ORDER=0), up to 300 MHz in fractional mode (MASH_ORDER=1-3), up to 240 MHz with MASH_ORDER=4"
    (ref "lmx2594.pdf" (page 9) (quote "Phase detector frequency Integer mode MASH_ORDER = 0 0.125 400 Fractional mode MASH_ORDER= 1, 2, 3 5 300 MASH_ORDER = 4 5 240")))

  (requirement "VCO frequency range is 7.5-15 GHz internally; combined with the channel divider the device covers 10 MHz to 15 GHz output"
    (ref "lmx2594.pdf" (page 18) (quote "The VCO operates from 7.5 GHz to 15 GHz, and this can be combined with the output divider to produce any frequency in the range of 10 MHz to 15 GHz")))

  ;; --- Environmental ----------------------------------------------------
  (requirement "Operating ambient temperature range is -40 degC to +85 degC; recommended max junction temperature is 125 degC (absolute max 150 degC)"
    (ref "lmx2594.pdf" (page 8) (quote "TA Ambient temperature -40 25 85 TJ Junction temperature 125")))

  ;; --- Layout / RF substrate -------------------------------------------
  (requirement "Use a low-loss dielectric (e.g. Rogers 4003) for the layer carrying the RF outputs to preserve output power at high frequencies"
    (ref "lmx2594.pdf" (page 65) (quote "Use a low loss dielectric material, such as Rogers 4003, for optimal output power."))))
