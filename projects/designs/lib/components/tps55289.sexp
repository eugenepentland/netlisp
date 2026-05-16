(component "tps55289"
  (description "TI TPS55289 30-V, 8-A buck-boost converter with I²C interface, 21-pin VQFN-HR")
  (pinout "tps55289qwryqrq1")
  (footprint "tps552892qwryqrq1")
  (manufacturer "Texas Instruments")
  (mpn "TPS55289RYQR")
  (note "Commercial (non-automotive) variant — VIN abs max 35 V, op 3.0–30 V. For AEC-Q100 use tps55289qwryqrq1 instead.")
  (note "TI reference design at 9–30 V → 3.3–21 V uses 4.7 µH inductor, 4×22 µF output caps, 49.9 kΩ FSW resistor (≈400 kHz).")
  (note "PPS-style programmable output: REF (regs 00h/01h) sets internal VREF 45 mV–1.2 V; INTFB (reg 04h) sets internal divider 0.2256/0.1128/0.0752/0.0564 → 5/10/15/20 V full-scale.")
  (datasheet "tps55289.pdf")

  ;; --- Supply ratings ---
  (requirement "VIN (pin 7) recommended operating range is 3.0 V to 30 V. Absolute maximum on VIN and SW1 is 35 V — any input transient from the source (cold-crank, hot-plug ringing, cable inductance kick) must be clamped below this limit. Start-up UVLO is 2.9 V rising / 2.65 V falling"
    (ref "tps55289.pdf" (page 5) (quote "VIN, SW1 –0.3 35"))
    (check (voltage-range (pin "VIN") (min 3.0) (max 30.0))))

  (requirement "VOUT (pin 11) programmable range is 0.8 V to 22 V; absolute maximum on VOUT, SW2, ISP, and ISN is 25 V. Output OVP trips at 22.5–24.5 V (typ 23.5 V), so the programmed VOUT plus worst-case load-step overshoot must stay below 22.5 V"
    (ref "tps55289.pdf" (page 5) (quote "VOUT, SW2, ISP, ISN –0.3 25"))
    (check (voltage-range (pin "VOUT") (min 0.8) (max 22.0))))

  (requirement "EN/UVLO (pin 1) absolute maximum is 20 V — unlike most digital pins on this device, EN/UVLO is NOT limited to VCC + 0.3 V and can be driven directly from VIN through a resistor divider (the typical UVLO programming method)"
    (ref "tps55289.pdf" (page 5) (quote "EN/UVLO –0.3 20")))

  (requirement "VCC, SCL, SDA, FSW, COMP, FB/INT, MODE, CDC, DITH/SYNC, and EXTVCC are absolute-max rated to the LOWER of 6 V or VCC + 0.3 V. Any pull-up on these pins must come from a rail bounded by both limits — never pull these pins directly to VIN or VOUT"
    (ref "tps55289.pdf" (page 5) (quote "SCL, SDA, FSW, COMP, FB/INT, MODE, CDC, DITH/SYNC, EXTVCC –0.3 VCC + 0.3")))

  ;; --- Pin termination (must-not-float) ---
  (requirement "EN/UVLO (pin 1) must be terminated — never left floating. The pin has two thresholds: 1.15 V enables the IC into standby (I²C live, no switching), and 1.23 V starts switching with ~5 µA hysteresis source current. Drive from logic, use a divider from VIN to program input-side UVLO, or pull directly to VIN if no UVLO is needed"
    (ref "tps55289.pdf" (page 16) (quote "EN/UVLO pin is pulled above 1.15 V but less than the enable UVLO threshold of 1.23 V"))
    (check (pin-not-floating (pin "EN/UVLO"))))

  (requirement "MODE (pin 2) must be terminated — never floating. Sampled at startup to choose the I²C target address: tie LOW (≤0.4 V, to AGND) for 75h, tie HIGH (≥1.2 V, typically to VCC) for 74h. The strap must match the address the host firmware uses"
    (ref "tps55289.pdf" (page 16) (quote "By configuring the MODE pin logic status, the TPS55289 selects two different I"))
    (check (pin-not-floating (pin "MODE"))))

  (requirement "EXTVCC (pin 21) must be terminated — never floating. Tie HIGH (to VCC) to use the internal LDO from VIN/VOUT (works at any input voltage, but dissipates significant power at high VIN). Tie LOW (to AGND) to supply VCC externally from a 4.75–5.5 V rail capable of ≥100 mA — that rail must be present whenever VIN is. For most designs without a 5 V rail handy, tie EXTVCC HIGH"
    (ref "tps55289.pdf" (page 16) (quote "external 5-V power source can be applied at the VCC pin to supply the TPS55289. The external 5-V power supply must have at least 100-mA output current capability and must be within the 4.75-V to 5.5-V regulation range"))
    (check (pin-not-floating (pin "EXTVCC"))))

  ;; --- VCC and bootstrap capacitors ---
  (requirement "VCC (pin 18) requires a ceramic capacitor of more than 4.7 µF (X5R/X7R) from VCC to AGND, placed close to the IC. This is both the internal-LDO output filter and the MOSFET gate-driver supply — under-sizing it causes gate-drive collapse during switching transients"
    (ref "tps55289.pdf" (page 4) (quote "A ceramic capacitor of more than 4.7 μF is required between this pin and the AGND pin"))
    (check (decoupling (pin "VCC") (pin "AGND") (min-uf 4.7))))

  (requirement "BOOT1 (pin 20) requires a 0.1 µF ceramic capacitor between BOOT1 and SW1 — high-side bootstrap for the buck-leg gate driver. Place close to the IC with short, wide traces; long routing here causes gate-drive ringing on SW1 and reduced efficiency"
    (ref "tps55289.pdf" (page 4) (quote "A 0.1-µF ceramic capacitor must be connected between this pin and the SW1 pin"))
    (check (decoupling (pin "BOOT1") (pin "SW1") (min-uf 0.1))))

  (requirement "BOOT2 (pin 19) requires a 0.1 µF ceramic capacitor between BOOT2 and SW2 — high-side bootstrap for the boost-leg gate driver. Place close to the IC with short, wide traces"
    (ref "tps55289.pdf" (page 4) (quote "A 0.1-µF ceramic capacitor must be connected between this pin and the SW2 pin"))
    (check (decoupling (pin "BOOT2") (pin "SW2") (min-uf 0.1))))

  ;; --- FSW resistor and DITH/SYNC ---
  (requirement "FSW (pin 6) requires a resistor to AGND to set the switching frequency. Valid resistance is 8.4 kΩ (≈2.2 MHz) to 100 kΩ (≈200 kHz); fSW = 1000 / (0.05 × RFSW + 35). The pin is held by an internal 1 V clamp — leaving FSW floating, shorting to ground, or pulling above 1 V prevents normal switching. Use a 1% resistor for frequency accuracy and EMI compliance. Below 500 kHz is preferred at high-current operating points to reduce switching loss"
    (ref "tps55289.pdf" (page 18) (quote "The setting resistance is between maximum of 100 kΩ and minimum of 8.4 kΩ"))
    (check (pin-not-floating (pin "FSW"))))

  (requirement "DITH/SYNC (pin 5) has three valid configurations and must be deliberately set: (a) tie to AGND or pull above 1.2 V to disable both dithering and external sync; (b) place a capacitor to AGND for ±7% spread-spectrum dithering, sized as CDITH = 1/(2.8·RFSW·FMOD) with FMOD typically <1 kHz; (c) drive with an external clock at 30–70% duty within ±30% of the FSW-set frequency to synchronize switching. Do not leave the pin floating"
    (ref "tps55289.pdf" (page 18) (quote "Connecting the DITH/SYNC pin below 0.4 V or above 1.2 V disables switching frequency dithering")))

  ;; --- Inductor ---
  (requirement "Inductor between SW1 (pin 8) and SW2 (pin 10) must be 1 µH to 10 µH effective; nominal 4.7 µH for the TI reference design at 400 kHz. Saturation current rating must exceed the calculated peak inductor current at the worst-case operating point — maximum IOUT at minimum VIN with maximum VOUT in boost mode (Equations 11–13 in §8.2.2.3) — with additional margin for tolerance and DC-bias derating. The IC's own peak-current limit is typ 13 A; the inductor must handle this current during transients without saturating"
    (ref "tps55289.pdf" (page 5) (quote "L Effective inductance range 1 4.7 10"))
    (check (connected (pin "SW1") (pin "SW2"))))

  ;; --- Input and output bulk caps ---
  (requirement "Input capacitor: place ≥20 µF effective ceramic capacitance (X5R/X7R, post-DC-bias derating) from VIN (pin 7) to PGND. Additionally place a 0.1 µF/0402 ceramic right at the VIN pin — this controls the high-dV/dt commutation loop and is the primary radiated-EMI source; it must sit as close to the VIN and PGND pins as physically possible. If the input source is more than a few inches from the converter, add a 100 µF bulk (aluminum or polymer) electrolytic in addition to the ceramics"
    (ref "tps55289.pdf" (page 36) (quote "A total of 20 µF effective capacitance is a good starting point for this application. Add a 0.1-µF/0402 package ceramic capacitor and place it close to VIN pin and GND pin to suppress high frequency noise"))
    (check (decoupling (pin "VIN") (pin "PGND_1") (min-uf 10.0))))

  (requirement "Output capacitor: recommended-operating effective capacitance is 10–1000 µF (nominal 100 µF). The TI 9–30 V → 3.3–21 V reference design uses 4 × 22 µF ceramic from VOUT (pin 11) to PGND. Required value depends on ripple target, load-step magnitude, and operating range — calculate from Equations 16–17 in §8.2.2.5 for the worst case (max IOUT at min VIN, max VOUT). Add a 0.1 µF/0402 ceramic right at the VOUT pin for high-frequency bypass"
    (ref "tps55289.pdf" (page 5) (quote "COUT Effective output capacitance range 10 100 1000"))
    (check (decoupling (pin "VOUT") (pin "PGND_1") (min-uf 22.0))))

  ;; --- ISP / ISN current sense ---
  (requirement "ISP (pin 12) and ISN (pin 13) are differential current-sense inputs. Two valid topologies: (a) place a current-sense resistor in series with VOUT (typically 10 mΩ for the 6.35 A maximum limit setting; size as RSNS = VSNS / IOUT_LIMIT where VSNS comes from the IOUT_LIMIT register), with ISP on the VOUT-side and ISN on the load-side, both Kelvin-connected to the resistor pads; (b) short ISP and ISN together AND to VOUT to disable output current limiting (also clear Current_Limit_EN in register 02h, or the loop will see 0 mV and never trigger). Never leave ISP or ISN floating. The sense resistor must be sized for the dissipation it will see — at 6 A through 10 mΩ that is 0.36 W, so a 1206 or larger package is needed"
    (ref "tps55289.pdf" (page 21) (quote "Connecting the ISP and the ISN pin together to the VOUT pin disables the output current limit because the sensed voltage is always 0"))
    (check (pin-not-floating (pin "ISP"))))

  (requirement "ISN (pin 13) — see ISP requirement above for paired wiring. Must not float; either Kelvin-connect to the load-side of an output sense resistor, or tie to ISP and VOUT to disable current sensing"
    (ref "tps55289.pdf" (page 4) (quote "An optional current sense resistor connected between the ISP pin and the ISN pin can limit the output current"))
    (check (pin-not-floating (pin "ISN"))))

  ;; --- I²C bus ---
  (requirement "SCL (pin 3) and SDA (pin 4) are open-drain I²C lines and require pull-up resistors to the bus voltage rail. The I/O rail must be 1.7–5.5 V (independent of VCC), so pull-ups can run from a 1.8 V, 3.3 V, or 5 V logic rail to match the host MCU. Size for bus capacitive load: 4.7 kΩ typical for ≤100 pF at 400 kHz; 1–2 kΩ for fast-mode-plus (1 MHz). The TPS55289 supports standard mode through fast-mode-plus"
    (ref "tps55289.pdf" (page 9) (quote "VI2C_IO IO voltage range for I2C 1.7 5.5")))

  ;; --- FB/INT dual-function pin ---
  (requirement "FB/INT (pin 14) has two functions selected by the FB bit in register 04h, and the hardware wiring must match the firmware setting: (a) FB=0 (default) — internal feedback divider used; FB/INT becomes an open-drain fault indicator that asserts LOW on SCP/OCP/OVP (mask bits in register 05h gate which faults assert it) — pull up to a logic rail if used, or leave open if not; (b) FB=1 — connect FB/INT to the center tap of an external resistor divider from VOUT, with top resistor recommended 100 kΩ; output voltage = VREF × (1 + R_FB_UP / R_FB_BT), where VREF is programmable 45 mV–1.2 V via the REF register. Do not connect both a fault-indicator pull-up AND a feedback divider on the same design"
    (ref "tps55289.pdf" (page 4) (quote "When the device is set to use external output voltage feedback, connect to the center tap of a resistor divider to program the output voltage. When the device is set to use internal feedback, this pin is a fault indicator output")))

  ;; --- COMP loop compensation ---
  (requirement "COMP (pin 15) is the error-amplifier output and requires an external loop-compensation network to AGND — a series RC (RC, CC) in parallel with an optional CP. Values are derived from the boost-mode power-stage transfer function (Equations 19–26 in §8.2.2.7) and depend on VIN/VOUT range, output capacitance, and chosen crossover frequency (≤ min(fSW/10, fRHPZ/5)). Compensate for the WORST case — maximum VOUT at minimum VIN in boost mode — where the right-half-plane zero is lowest. Target ≥45° phase margin and ≥10 dB gain margin. Place RC/CC/CP physically close to the COMP pin with a short return to AGND"
    (ref "tps55289.pdf" (page 4) (quote "Output of the internal error amplifier. Connect the loop compensation network between this pin and the AGND pin"))
    (check (pin-not-floating (pin "COMP"))))

  ;; --- CDC cable-drop compensation ---
  (requirement "CDC (pin 16) outputs a voltage proportional to (VISP − VISN) × 20, used for output current monitoring or cable-drop compensation. Two valid uses, which must match the CDC_OPTION bit in register 05h: (a) when using internal feedback (FB=0) leave CDC floating or tie through a resistor to AGND; configure compensation via the CDC[2:0] bits with CDC_OPTION=0; (b) when using external feedback (FB=1), place a resistor between CDC and AGND for external compensation and set CDC_OPTION=1 — VOUT lift = 3 × R_FB_UP × (VISP−VISN) / RCDC (Equation 7)"
    (ref "tps55289.pdf" (page 4) (quote "Use a resistor between this pin and AGND to increase the output voltage to compensate voltage droop across the cable caused by the cable resistance")))

  ;; --- Grounding ---
  (requirement "All three PGND pads — PGND_1 (pin 9), PGND_2 and PGND_3 (the two thermal-pad subpads) — must be tied together on the PCB and connected to the PGND plane through multiple vias placed directly under the package. The thermal pads are not optional: they carry the high-current return AND are the primary thermal path. Omitting vias on these pads triggers both thermal shutdown and ground bounce during switching"
    (ref "tps55289.pdf" (page 41) (quote "Use multiple GND vias near PGND pin to connect the PGND to the internal ground plane. This also improves thermal performance"))
    (check (connected (pin "PGND_1") (pin "PGND_2"))))

  (requirement "AGND (pin 17) and PGND must form a star ground: join them at a single point, at the return terminal of the VCC capacitor (pin 18). Do NOT pour AGND continuous with PGND under the IC — the PGND plane carries the switching-current return, and the resulting ripple corrupts the analog reference and FB/COMP loop if AGND shares copper directly. Place AGND as a separate island, tied to PGND only at the VCC cap return"
    (ref "tps55289.pdf" (page 41) (quote "Isolate the power ground from the analog ground. The PGND plane and AGND plane are connected at the terminal of the VCC capacitor"))
    (check (connected (pin "AGND") (pin "PGND_1"))))

  ;; --- Switching node layout ---
  (requirement "Minimize the SW1 (pin 8) and SW2 (pin 10) loop areas — these are high-dV/dt nodes (tens of V/ns). Keep the SW copper just large enough to carry the inductor current; oversized SW pours act as EMI antennas. Place a ground pour on the adjacent layer to minimize interplane coupling, and do not route sensitive analog signals (FB, COMP, CDC, ISP, ISN) under or near SW polygons"
    (ref "tps55289.pdf" (page 41) (quote "Minimize the SW1 and SW2 loop areas as these are high dv/dt nodes")))

  (requirement "ISP/ISN must use Kelvin connections to the current-sense resistor — the ISP and ISN traces branch off the resistor's terminal pads, NOT off the high-current copper carrying load current (which would inject IR drop into the sense). Route ISP and ISN as a closely-coupled differential pair from the sense resistor back to the IC. Place an optional differential filter capacitor (typically 1 nF) right at the IC pins between ISP and ISN to reject switching noise"
    (ref "tps55289.pdf" (page 41) (quote "Use Kelvin connections to RSENSE for the current sense signals ISP and ISN and run lines in parallel from the RSENSE terminals to the IC pins")))

  ;; --- Startup sequence ---
  (requirement "After EN/UVLO crosses 1.23 V the device enters standby with I²C active but no switching. All configuration registers — REF (00h/01h), IOUT_LIMIT (02h), VOUT_SR (03h), VOUT_FS (04h), CDC (05h), MODE (06h non-OE bits) — must be written BEFORE the OE bit (06h bit 7) is set, otherwise the device ramps to default register values. Default REF after power-up is 282 mV which corresponds to 5 V output with INTFB=11b (default). Soft-start ramp time is ~3.6 ms (typ)"
    (ref "tps55289.pdf" (page 17) (quote "An I2C controller device can configure the internal registers of the TPS55289 before setting the OE bit of the register 06h. Once an I2C controller device sets the OE bit to 1, the TPS55289 starts to ramp up the output voltage")))

  ;; --- Thermal ---
  (requirement "Junction temperature must remain within −40 °C to +125 °C; thermal shutdown trips at 175 °C (typ) with 20 °C hysteresis. RθJA on the standard 4-layer EVM is 27.5 °C/W; on a minimum-copper board it rises to 43.4 °C/W. For sustained operation above ~3 A output, copper pour on VIN, VOUT, and PGND across multiple layers is mandatory as a heatsink — the thermal pad alone is insufficient at high power"
    (ref "tps55289.pdf" (page 6) (quote "TJ Operating junction temperature –40 125")))
)
