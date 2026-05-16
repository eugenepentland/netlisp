;; ===========================================================================
;; Bench Lab Multitool — Pi 5 Carrier
;; ---------------------------------------------------------------------------
;; Bench-class lab tool: dual-channel programmable PSU + iCE40 logic
;; analyzer/programmer + 4.5-digit DMM. Compute is supplied by a Raspberry
;; Pi 5 that drops onto the carrier via a 40-pin GPIO header. USB-C PD
;; (20V/3A) powers the carrier, which in turn delivers 5V to the Pi 5 via
;; header pins 2/4. The FPGA self-boots from a carrier-side W25Q32 SPI
;; flash, so PSU safety is enforced ~300 ms after power-on — independent
;; of the Pi (which takes 15-20 s to finish Linux boot) and resilient to
;; Pi crashes via a 5 s host-heartbeat watchdog.
;;
;; SCAFFOLDING ONLY — section skeleton, names, subtitles, ports and design
;; notes are in place. Footprints, pinouts, pin maps, instances and the
;; peripheral sub-block modules still need to be imported/authored. Each
;; placeholder is marked `;; TODO`. See design.md for the full BOM, pin
;; allocation, and I2C address maps.
;;
;; Main IC: Lattice iCE40HX8K-CT256 — the carrier's compute hub. The Pi 5
;; is a *removable external module* that lands on a 40-pin GPIO header
;; (J1) and talks to the FPGA over Quad-SPI, to the DMM ADC over SPI1,
;; and to the housekeeping I2C1 bus directly.
;; ===========================================================================

;; TODO: import the FPGA module, Pi 5 header, peripheral modules and
;; discrete parts once their symbols/footprints are in lib/. Expected:
;; (import fpga-module             ;; iCE40HX8K-CT256 + W25Q32 config flash + 12 MHz osc + core LDO
;;         pi-5-header             ;; 2x20 0.1" Pi-standard GPIO header (Samtec SSW-120-01-T-D)
;;         dut-fixture-50p         ;; Samtec FFSH-25-01 2x25 1.27mm latching shroud
;;         dut-bench-10p           ;; 2x5 0.1" keyed pin header
;;         psu-channel             ;; TPS55289 buck-boost + INA228 + shunt + disconnect FET
;;         dmm-frontend            ;; AD7124-4 + ADR4525 + OPA189 + ADG5412F/ADG1404 + dividers + protection
;;         usbc-pd-input           ;; STUSB4500 + USB-C recept (power-only) + USBLC6 ESD
;;         system-buck             ;; TPS62933
;;         analog-ldo              ;; ADP7118-3.3 (low noise)
;;         bank-rail               ;; TLV62568 + MCP4726 DAC + INA260 monitor (programmable VCCIO)
;;         power-supervisor        ;; TPS3808
;;         ux-peripherals          ;; encoder + buzzer + RGB LED + PSU "ON" LEDs + user LEDs + LRA driver
;;         housekeeping-i2c        ;; DS3231M RTC + LSM6DSO IMU + ST25DV NFC + 3x TMP1075 + 24LC256
;;         microsd-slot
;;         tagconnect-swd
;;         reed-switch
;;         mounting-standoff fiducial testpoint)

(design-block "Bench Lab Multitool — Pi 5 Carrier"

  ;; TODO: instance the FPGA and Pi header once their symbols exist.
  ;; (instance "fpga" fpga-module (id ........))
  ;; (instance "J1"   pi-5-header (id ........))

  ;; -------------------------------------------------------------------------
  ;; FPGA Core System — main IC support infrastructure (case 3: one section)
  ;; -------------------------------------------------------------------------
  (section "FPGA Core System" "iCE40HX8K-CT256 + W25Q32 4MB config flash + 12 MHz osc + 1.2V core LDO + per-bank programmable VCCIO"
    (port "VDD3V3"  in power 3.3)
    (port "VDD1V2"  in power 1.2)
    (port "GND"     bidi)
    ;; TODO: (pins "fpga" (group "VCC core 1.2V") ...)
    ;; TODO: (pins "fpga" (group "VCCIO Bank A — DUT") ...)         ;; 12 pins, programmable 1.8/2.5/3.3V
    ;; TODO: (pins "fpga" (group "VCCIO Bank B — DUT") ...)         ;; 12 pins, programmable 1.8/2.5/3.3V
    ;; TODO: (pins "fpga" (group "VCCIO Bank C — Pi control") ...)  ;; fixed 3.3V (Quad-SPI + CRESET_B/CDONE/INT)
    ;; TODO: (pins "fpga" (group "VCCIO Bank D — PSU/UX") ...)      ;; fixed 3.3V (I2C_FPGA master + UX peripherals)
    ;; TODO: (pins "fpga" (group "Boot SPI flash") ...)             ;; SPI_SS_B / SCK / SDI / SDO → W25Q32
    ;; TODO: (pins "fpga" (group "Config control") ...)             ;; CRESET_B / CDONE (driven by Pi GPIO 17/18)
    ;; TODO: (pins "fpga" (group "Pi INT") ...)                     ;; FPGA → Pi GPIO 27 fault/capture-ready
    ;; TODO: (pins "fpga" (group "PLL reference") ...)              ;; 12 MHz osc → fabric PLL → 96 MHz
    (note "FPGA self-configures from the carrier-side W25Q32 at every power-on (~270 ms at 25 MHz single-bit SPI). CRESET_B is driven by the Pi (BCM GPIO 17) so the Pi can hold the FPGA in reset and re-flash the W25Q32 over the *same* SPI lines using standard iceprog/flashrom protocol — ~1 s for a full gateware update.")
    (note "4 independent VCCIO banks. Banks A/B feed the DUT pins at 1.8/2.5/3.3V via TLV62568 adjustable LDOs commanded by MCP4726 single-channel I2C DACs (Pi I2C1 @ 0x60 / 0x61). Bank C is fixed 3.3V for the Pi-facing Quad-SPI and control pins. Bank D is fixed 3.3V for the FPGA-mastered I2C_FPGA bus and the on-carrier UX peripherals.")
    (note "LUT budget: ~5,030 / 7,680 LUTs (~65% utilization) — logic analyzer + 5 protocol engines + PSU controller + pin monitor + UX drivers + Quad-SPI slave + connector mux."))
  ;; TODO: (sub-block "fpga_sys" (fpga-module))

  ;; -------------------------------------------------------------------------
  ;; Pi 5 Header — 40-pin GPIO interface to the external Raspberry Pi 5
  ;; -------------------------------------------------------------------------
  (section "Pi 5 Header" "Samtec SSW-120-01-T-D 2x20 0.1\" Pi-standard header — Pi 5 plugs on top; carries Quad-SPI to FPGA, SPI1 to DMM, I2C1 housekeeping, FPGA control GPIO, 5V power up to the Pi"
    (role bidi)
    (port "VDD5"      out power 5.0)        ;; carrier → Pi via pins 2/4 paralleled
    (port "VDD3V3_PI" in  power 3.3)        ;; Pi exposes 3.3V on pins 1/17 (reference only, low current)
    (port "GND"       bidi)
    ;; TODO: (pins "J1" (group "5V Power to Pi") ...)         ;; pins 2, 4 paralleled, 470 uF bulk decap at the header
    ;; TODO: (pins "J1" (group "GND") ...)                    ;; pins 6, 9, 14, 20, 25, 30, 34, 39
    ;; TODO: (pins "J1" (group "I2C1 housekeeping") ...)      ;; pins 3/5 → BCM GPIO 2/3 (SDA/SCL) — shared bus, 2.2k pull-ups
    ;; TODO: (pins "J1" (group "Quad-SPI to FPGA") ...)       ;; pins 19/21/23/24/32/33 → BCM 10/9/11/8/12/13 (SPI0 + IO2/IO3)
    ;; TODO: (pins "J1" (group "SPI1 to DMM ADC") ...)        ;; pins 26/35/38/40 → BCM 7/19/20/21 (CE0/MISO/MOSI/SCLK)
    ;; TODO: (pins "J1" (group "FPGA control") ...)           ;; pins 11/12/13 → BCM 17/18/27 (CRESET_B / CDONE / INT)
    ;; TODO: (pins "J1" (group "DMM nDRDY IRQ") ...)          ;; pin 29 → BCM 5
    ;; TODO: (pins "J1" (group "Power button input") ...)     ;; pin 7 → BCM 4
    ;; TODO: (pins "J1" (group "UART0 debug console") ...)    ;; pins 8/10 → BCM 14/15 (TX/RX)
    ;; TODO: (pins "J1" (group "HAT I2C0 (reserved)") ...)    ;; pins 27/28 → BCM 0/1, reserved by spec for Pi HAT EEPROM
    (note "Pi 5 is powered through header pins 2/4 (paralleled 5V). Modern Pi 5 firmware needs `usb_max_current_enable=1` in /boot/firmware/config.txt to unlock full USB-A current on this path. The Pi 5's own USB-C is left unconnected.")
    (note "Quad-SPI on SPI0 runs at 40 MHz (~20 MB/s sustained) — initialised single-bit at boot, switched to 4-bit via SPI0 multi-IO once Linux is up. Fall back to 25 MHz if signal integrity at 40 MHz is marginal on the 40-pin header (see design.md §14.2).")
    (note "Bulk decoupling: 470 uF polymer cap at the header's 5V pins handles Pi 5 PMIC transient draws (>2 A spikes during boot). Critical — without it the 5V rail dips into TPS62933 UV territory.")
    (note "Pi 5 mounting: 4x M2.5 standoffs at 58 x 49 mm corner positions (standard Pi 4/5 hole spacing). 11 mm standoffs for SD-only; ~25 mm if an NVMe HAT is sandwiched between Pi and carrier."))
  ;; TODO: (sub-block "pi_header" (pi-5-header))

  ;; -------------------------------------------------------------------------
  ;; USB-C Power Input — STUSB4500 PD sink, power-only (no data lines used)
  ;; -------------------------------------------------------------------------
  (section "USB-C Power Input" "GCT USB4105-GF-A mid-mount recept + STUSB4500QTR PD sink (NVM-programmed 20V/3A primary, 15/9/5V fallback) + USBLC6-2SC6 ESD"
    (role input)
    (protocol USB-PD)
    (port "VBUS_USBC" in (rated 4.0 5.5))
    (port "VBUS_PD"   out power 20.0)
    (port "GND"       bidi)
    ;; TODO: STUSB4500 status: I2C1 @ 0x28 — pin map declared under the Pi 5 Header section
    (note "Power-only USB-C: D+/D- are NOT routed anywhere on the carrier. The Pi 5's own USB-A ports are the system's USB host interface; Wi-Fi/Ethernet on the Pi handle data. Removes the TS3USB221A and the entire host-vs-device USB-OTG complication from the previous CM4 design.")
    (note "STUSB4500 negotiates autonomously over CC; the Pi reads the negotiated PDO over I2C1 @ 0x28 for diagnostics. Quiescent draw ~50 uA, so VBUS gating is implicit — \"off\" means \"USB-C unplugged\".")
    (note "ESD: USBLC6-2SC6 across VBUS / CC1 / CC2."))
  ;; TODO: (sub-block "usbc" (usbc-pd-input))

  ;; -------------------------------------------------------------------------
  ;; DUT Fixture Connector — primary 1.27mm 2x25 latching shroud (16 ch)
  ;; -------------------------------------------------------------------------
  (section "DUT Fixture Connector" "Samtec FFSH-25-01-L-D-K 1.27mm 2x25 latching shroud — 16 DUT signals (8 Bank A + 8 Bank B) + 16 dedicated GNDs + 4 PSU CH1 + 4 PSU CH2 + 4 GND guards + 2 bank Vrefs + 4 aux"
    (role bidi)
    (port "VDD_BANK_A" in (rated 1.8 3.3))
    (port "VDD_BANK_B" in (rated 1.8 3.3))
    (port "VOUT_CH1"   in (rated 0.0 18.0))
    (port "VOUT_CH2"   in (rated 0.0 18.0))
    (port "GND"        bidi)
    ;; TODO: (pins "fpga" (group "DUT fixture Bank A") ...)   ;; 8 FPGA bank A pins → fixture positions
    ;; TODO: (pins "fpga" (group "DUT fixture Bank B") ...)   ;; 8 FPGA bank B pins → fixture positions
    (note "Primary fixture interface for production test / repeatable bring-up. Latching shroud prevents accidental disconnects mid-test. Mates with off-the-shelf Samtec FFSD ribbon assemblies (6\"/12\"/18\"/24\" stocked at Digi-Key/Mouser) — same part number is repeatable across customer fixture BOMs.")
    (note "Single-cable integration: 16 signals + PSU rails + GND guards on one connector, so a custom fixture PCB plugs in with one cable instead of four (DUT ribbon + 2 PSU pairs + sense lead).")
    (note "Interleaved 16 GNDs (one per signal) give a clean signal-ground pattern for the LA at 25 MS/s sustained / 96 MS/s burst. GND guards around the PSU rails keep switching noise out of the LA channels.")
    (note "ESD: TPD4E004 4-channel ESD packs cover all 16 fixture signal lines (4 chips). Optional 33-47 ohm series R at the FPGA pad damps reflections on long fixture cables — DNP in v1, populate if SI on >12\" cables is marginal."))
  ;; TODO: (sub-block "dut_fixture" (dut-fixture-50p))

  ;; -------------------------------------------------------------------------
  ;; DUT Bench Header — secondary 2x5 0.1" pin header (jumper/scope friendly)
  ;; -------------------------------------------------------------------------
  (section "DUT Bench Header" "2x5 0.1\" keyed pin header — 8 DUT signals (4 Bank A + 4 Bank B) + interleaved GNDs + 2 bank Vref pins"
    (role bidi)
    (port "VDD_BANK_A" in (rated 1.8 3.3))
    (port "VDD_BANK_B" in (rated 1.8 3.3))
    (port "GND"        bidi)
    ;; TODO: (pins "fpga" (group "DUT bench Bank A") ...)   ;; 4 FPGA bank A pins → bench header
    ;; TODO: (pins "fpga" (group "DUT bench Bank B") ...)   ;; 4 FPGA bank B pins → bench header
    (note "Ad-hoc bring-up interface: 0.1\" pitch for jumper wires, scope probe ground clips, and alligator clips. PSU rails are NOT brought out on this connector — bench PSU access remains the front-panel banana jacks (this keeps high-current PSU traces off the 0.1\" header and avoids accidental contact).")
    (note "Banks A & B are *shared* with the fixture connector — only one connector is active at a time, chosen by a 1-bit FPGA `connector_mux` register written by the Pi. The 16-ch sampler / trigger / protocol engines see an abstract DUT[0..15] bus; the mux routes from 16 fixture pins or 8 bench pins (with the upper 8 channels zero-padded). pin_monitor still samples all 24 physical pins so the Pi can flag unexpected activity on the inactive connector.")
    (note "ESD: TPD4E004 on the bench signal lines (2 chips)."))
  ;; TODO: (sub-block "dut_bench" (dut-bench-10p))

  ;; -------------------------------------------------------------------------
  ;; DMM Analog Front-End — 4.5-digit DCV / resistance, Pi-mastered via SPI1
  ;; -------------------------------------------------------------------------
  (section "DMM Analog Front-End" "AD7124-4 24-bit ADC (4 ch) + ADR4525 2.5V reference + OPA189 zero-drift buffer + ADG5412F/ADG1404 fault-protected muxes + HV divider + 24LC256 cal EEPROM"
    (role input)
    (protocol SPI)
    (port "VDD3V3_ANA" in power 3.3)
    (port "GND"        bidi)
    ;; TODO: (pins "J1" (group "DMM SPI1") ...)   ;; AD7124-4 on /dev/spidev1.0 — header pins 26/35/38/40 (CE0/MISO/MOSI/SCLK), <= 5 MHz
    ;; TODO: (pins "J1" (group "DMM nDRDY") ...)  ;; data-ready IRQ on header pin 29 → BCM GPIO 5
    (note "Targets: DCV 20V range 0.05% + 2 counts (extends to ±60V via HV divider), resistance 1k-1M 0.05% + 2 counts ratiometric, 10M ~0.5%. Probes are *separate* banana jacks from the PSU outputs, finger-guarded — no accidental cross-connection.")
    (note "Input protection chain: MF-R016 PTC fuse, SMAJ33CA TVS, CRHV2512 10M HV series R, BAV199 low-leakage post-divider clamps. ADG5412F is fault-protected to ±55V continuous, so misconnection to the PSU output won't damage the AFE.")
    (note "AD7124-4 is the 4-channel variant (down from AD7124-8 in earlier revisions): 1 ch DCV input, 1 ch ratiometric R_ref, 1 ch current-source return, 1 ch cold-junction / spare. Sufficient for v1 DCV + resistance; AC-V / true-RMS is a software addition in v1.1 and per-pin DUT analog readback (which would need AD7124-8) is a v2 carrier respin.")
    (note "ADP7118-3.3 ultra-low-noise LDO supplies the analog 3.3V (AVDD, ref, opamp, mux) from the 5V rail — *separate* from the digital 3.3V rail to keep buck switching noise out of the ADC. Per-unit cal constants stored in the 24LC256 EEPROM on I2C1 @ 0x50."))
  ;; TODO: (sub-block "dmm" (dmm-frontend))

  ;; -------------------------------------------------------------------------
  ;; PSU Channel 1 — programmable 0-18V / 3A buck-boost, source-only
  ;; -------------------------------------------------------------------------
  (section "Channel 1 PSU (Buck-Boost)" "TPS55289WRYQR buck-boost (I2C_FPGA @ 0x74) + INA228 V/I telemetry (0x40) + WSL2512 10mOhm shunt + DMP3056L disconnect FET → banana jacks"
    (role output)
    (protocol I2C)
    (port "VBUS_PD"  in power 20.0)
    (port "VOUT_CH1" out (rated 0.0 18.0))
    (port "GND"      bidi)
    (note "Setpoint commanded by the FPGA's psu_controller over the dedicated I2C_FPGA bus @ 0x74 (independent of Pi scheduling). INA228 @ 0x40 does Kelvin-sensed V/I telemetry across the WSL2512 10mOhm shunt at 1 kHz; the FPGA PI loop closes around this measurement. DMP3056L P-FET gives a true 0V off state and reverse-polarity protection on the banana-jack output.")
    (note "Hardware OCP runs in gateware: <50 us from threshold crossing to foldback, <1 ms total to safe state — survives Pi crashes and the entire Pi-boot window. A 5 s host-heartbeat watchdog in the FPGA holds outputs in their last state if the Pi stops issuing commands, so a crashed Pi doesn't strand a powered DUT.")
    (note "Source-only (no current sink). 4.7uH Wurth 74438336047 inductor + 2x 22uF/35V 1210 X7R output caps per the TPS55289 EVM."))
  ;; TODO: (sub-block "psu1" (psu-channel 1))

  ;; -------------------------------------------------------------------------
  ;; PSU Channel 2 — second independent programmable channel
  ;; -------------------------------------------------------------------------
  (section "Channel 2 PSU (Buck-Boost)" "TPS55289WRYQR buck-boost (I2C_FPGA @ 0x75) + INA228 V/I telemetry (0x41) + WSL2512 10mOhm shunt + DMP3056L disconnect FET → banana jacks"
    (role output)
    (protocol I2C)
    (port "VBUS_PD"  in power 20.0)
    (port "VOUT_CH2" out (rated 0.0 18.0))
    (port "GND"      bidi)
    (note "Identical to Channel 1 but on I2C_FPGA @ 0x75 / INA228 @ 0x41. Two channels are fully independent — separate FPGA controller instances, separate setpoints, separate OCP.")
    (note "A third INA228 @ 0x44 monitors USB-C VBUS for PD-droop detection — declared in the USB-C section's sub-block, not here."))
  ;; TODO: (sub-block "psu2" (psu-channel 2))

  ;; -------------------------------------------------------------------------
  ;; FPGA Bank Power — programmable 1.8/2.5/3.3V VCCIO for DUT banks A & B
  ;; -------------------------------------------------------------------------
  (section "FPGA Bank Power" "2x TLV62568DBVR adjustable buck + 2x MCP4726A0T DAC (Pi I2C1 @ 0x60 / 0x61) + 2x INA260AIPWR V/I monitor (0x45 / 0x46) — generates VDD_BANK_A / VDD_BANK_B"
    (role output)
    (protocol I2C)
    (port "VDD5"        in  power 5.0)
    (port "VDD_BANK_A"  out (rated 1.8 3.3))
    (port "VDD_BANK_B"  out (rated 1.8 3.3))
    (port "GND"         bidi)
    ;; TODO: I2C1 SDA/SCL is shared with housekeeping — pin map declared under the Pi 5 Header section.
    (note "Each bank: TLV62568 adjustable buck with its FB pin steered by an MCP4726 single-channel 12-bit I2C DAC. Pi commands the DAC over I2C1; software snaps to the 1.8 / 2.5 / 3.3V canonical setpoints (intermediate values are permitted but rounded to safe values for LVCMOS compliance).")
    (note "Per-bank INA260 (0x45 / 0x46) reports actual V on the rail and I sourced or sunk by the DUT. Combined with the FPGA's free digital pin-state readback, this is the second of two diagnostic layers — unusual current on an idle connector immediately flags that something is plugged in and powered.")
    (note "Banks A and B feed both DUT connectors simultaneously (the connector_mux selects which connector's *pins* are sampled/driven, but both connectors physically share the same bank rails)."))
  ;; TODO: (sub-block "bank_a" (bank-rail "A"))
  ;; TODO: (sub-block "bank_b" (bank-rail "B"))

  ;; -------------------------------------------------------------------------
  ;; UX & Indicators — encoder, buzzer, RGB LED, PSU "ON" LEDs, user LEDs, LRA
  ;; -------------------------------------------------------------------------
  (section "UX & Indicators" "Bourns PEC11R rotary encoder + TDK PS1240 piezo + WS2812B RGB LED + 2x green PSU \"ON\" LEDs + 4x user-programmable LEDs + Jinlong G1040 LRA via TI DRV2603 — all FPGA-driven from bank D"
    (role output)
    (port "VDD3V3" in power 3.3)
    (port "VDD5"   in power 5.0)
    (port "GND"    bidi)
    ;; TODO: (pins "fpga" (group "Encoder quadrature") ...)    ;; A / B / SW into FPGA bank D
    ;; TODO: (pins "fpga" (group "Buzzer PWM") ...)            ;; one pin → 2N7002 low-side FET
    ;; TODO: (pins "fpga" (group "WS2812 data") ...)           ;; single-wire timing-critical to the RGB LED
    ;; TODO: (pins "fpga" (group "PSU ON LEDs") ...)           ;; 2 pins, mirror TPS55289 ENABLE state
    ;; TODO: (pins "fpga" (group "User LEDs") ...)             ;; 4 pins, hardware-PWM capable for pulse/breathe
    ;; TODO: (pins "fpga" (group "LRA via DRV2603") ...)       ;; PWM + INH to DRV2603
    (note "All UX is FPGA-driven so it stays alive during the 15-20 s Pi-boot window and across Pi crashes/reboots. RGB status LED shows system state at a glance (booting / idle / active / fault); PSU \"ON\" LEDs mirror the same internal signal that gates TPS55289 ENABLE so they're instantaneous and impossible to disagree with the actual output state.")
    (note "Encoder is decoded by a tiny quadrature-counter in gateware — works during Pi boot so the user can pre-arm a PSU setpoint before Linux finishes coming up. The encoder push-switch is the primary numeric-entry confirm. 24 detents × Pi 5 latency means software smoothing is unnecessary.")
    (note "User LEDs are exposed to Pi scripts as FPGA registers writable over Quad-SPI — useful for glanceable pass/fail across the bench. Color suggestion: red/green/yellow/blue mixed (see design.md §14.10).")
    (note "Buzzer drive: 2N7002 N-FET low-side switch with snubber across the piezo. LRA driver: DRV2603 gives proper braking/overdrive for crisp haptic feel — could be DNP'd and replaced with a bare FET in v1 to save $1.20."))
  ;; TODO: (sub-block "ux" (ux-peripherals))

  ;; -------------------------------------------------------------------------
  ;; Housekeeping Sensors — RTC + IMU + NFC + temps + cal EEPROM (Pi I2C1)
  ;; -------------------------------------------------------------------------
  (section "Housekeeping Sensors" "DS3231M RTC (0x68, CR1220 backup) + LSM6DSO IMU (0x6A) + ST25DV04K NFC (0x53 / 0x57) + 3x TMP1075 temps (0x48 / 0x49 / 0x4A) + 24LC256 cal EEPROM (0x50) — all on Pi I2C1 @ 400 kHz"
    (role input)
    (protocol I2C)
    (port "VDD3V3" in power 3.3)
    (port "GND"    bidi)
    ;; TODO: I2C1 SDA/SCL pin map declared under the Pi 5 Header section.
    (note "Single Pi-mastered I2C1 bus at 400 kHz with 2.2k pull-ups. 13 devices total (sensors + 2x INA260 + 2x MCP4726 + STUSB4500); addresses are unique. Worst-case telemetry sweep is ~3 ms — well within any housekeeping loop budget.")
    (note "DS3231M MEMS RTC keeps timestamps accurate (±5 ppm temperature-compensated) across power-cycles via a CR1220 coin cell on VBAT. Critical for capture timestamping in offline/portable use.")
    (note "TMP1075 placements: #1 next to TPS55289 #1, #2 next to TPS55289 #2, #3 next to FPGA. Feeds the FPGA's safety_monitor for thermal foldback (PSUs throttle if any zone exceeds 70 °C).")
    (note "ST25DV04K is an energy-harvesting passive NFC EEPROM — readable when the device is unpowered (phone-tap for Wi-Fi credentials, serial number, fleet management). Needs a ~10x10 mm copper keep-out under the antenna and a non-metallic enclosure path; if the case is metal, NFC has to be relocated or omitted (see design.md §14.8).")
    (note "24LC256 cal EEPROM stores per-unit DMM calibration constants, serial number, and manufacturing date. Read once at boot by labstation-py."))
  ;; TODO: (sub-block "housekeeping" (housekeeping-i2c))

  ;; -------------------------------------------------------------------------
  ;; Bring-up & Debug — Tag-Connect SWD footprint + reed switch + microSD slot
  ;; -------------------------------------------------------------------------
  (section "Bring-up & Debug" "Tag-Connect TC2030-IDC-NL footprint (FPGA SPI + UART + 3V3 + GND, no connector) + Standex MK24 reed switch (case-open detect) + microSD removable storage slot"
    (port "VDD3V3" in power 3.3)
    (port "GND"    bidi)
    ;; TODO: (pins "fpga" (group "Reed switch GPIO") ...)
    ;; TODO: (pins "fpga" (group "microSD card-detect") ...)
    ;; TODO: (instance "TAG1" tagconnect-swd ...)
    ;; TODO: (instance "SW1"  reed-switch   ...)
    ;; TODO: (instance "SD1"  microsd-slot  ...)
    (note "Tag-Connect TC2030 footprint exposes FPGA SPI master + UART + 3V3 + GND for first-time bring-up; no physical connector populated in production — the spring-pin Tag-Connect cable mates directly with the pads.")
    (note "Reed switch + a magnet glued to the enclosure half = case-open detection. Drives an FPGA GPIO so case-open is logged even with the Pi off; labstation-py reads it at boot to optionally zero the cal EEPROM on tamper.")
    (note "microSD slot is *removable user storage* — Pi 5 boots from its own SD/NVMe (mounted under the Pi itself), this carrier-side slot is for capture exports and script storage."))

  ;; -------------------------------------------------------------------------
  ;; Test Points — bring-up / debug probe points (case 2: direct instances)
  ;; -------------------------------------------------------------------------
  (section "Test Points" "1mm SMD probe points for bring-up and debug"
    ;; TODO: (instance "TP1" testpoint (pin 1 "VBUS_PD")    (id ........))
    ;; TODO: (instance "TP2" testpoint (pin 1 "VDD5")       (id ........))
    ;; TODO: (instance "TP3" testpoint (pin 1 "VDD3V3")     (id ........))
    ;; TODO: (instance "TP4" testpoint (pin 1 "VDD3V3_ANA") (id ........))
    ;; TODO: (instance "TP5" testpoint (pin 1 "VDD1V2")     (id ........))
    ;; TODO: (instance "TP6" testpoint (pin 1 "VDD_BANK_A") (id ........))
    ;; TODO: (instance "TP7" testpoint (pin 1 "VDD_BANK_B") (id ........))
    ;; TODO: (instance "TP8" testpoint (pin 1 "VOUT_CH1")   (id ........))
    ;; TODO: (instance "TP9" testpoint (pin 1 "VOUT_CH2")   (id ........))
    )

  ;; -------------------------------------------------------------------------
  ;; Mounting — Pi 5 standoffs + assembly fiducials (case 2: self-contained)
  ;; -------------------------------------------------------------------------
  (section "Mounting" "4x M2.5 standoffs at Pi 5 mounting positions (58 x 49 mm pattern) + 3x assembly fiducials"
    ;; TODO: (instance "H1"  mounting-standoff (pin 1 "GND") (id ........))   ;; Pi 5 corner #1
    ;; TODO: (instance "H2"  mounting-standoff (pin 1 "GND") (id ........))   ;; Pi 5 corner #2
    ;; TODO: (instance "H3"  mounting-standoff (pin 1 "GND") (id ........))   ;; Pi 5 corner #3
    ;; TODO: (instance "H4"  mounting-standoff (pin 1 "GND") (id ........))   ;; Pi 5 corner #4
    ;; TODO: (instance "FID1" fiducial (id ........))
    ;; TODO: (instance "FID2" fiducial (id ........))
    ;; TODO: (instance "FID3" fiducial (id ........))
    )

  ;; ==========================================================================
  ;; Power chain (case 4: rail-only blocks — top-level sub-blocks, no section)
  ;; ==========================================================================
  ;; USB-C VBUS_PD (20V) ─► TPS62933 ─► +5V_SYS ─► Pi header pins 2/4 (Pi 5 power)
  ;;                                            ├► TPS62933 ─► +3V3_SYS (digital)
  ;;                                            ├► ADP7118  ─► +3V3_ANA (low-noise, DMM)
  ;;                                            ├► (TLV62568 #1 + MCP4726 #1) ─► VDD_BANK_A
  ;;                                            └► (TLV62568 #2 + MCP4726 #2) ─► VDD_BANK_B
  ;; +3V3_SYS ─► ADP7118 ─► +1V2_FPGA (FPGA core)
  ;; CR1220 coin cell ─► DS3231M VBAT (RTC backup, preserves time across power-off)
  ;; TODO: (sub-block "buck_5v"    (system-buck 20.0 5.0))    ;; 20V → 5V, 3A continuous / 5A peak
  ;; TODO: (sub-block "buck_3v3"   (system-buck 5.0 3.3))     ;; 5V → 3V3 digital
  ;; TODO: (sub-block "ldo_ana"    (analog-ldo))              ;; 5V → 3V3 analog, ultra-low-noise
  ;; TODO: (sub-block "ldo_core"   (core-ldo))                ;; 3V3 → 1V2 FPGA core
  ;; TODO: (sub-block "supervisor" (power-supervisor))        ;; TPS3808G33 — holds Pi 5 power off until rails stable

  ;; ==========================================================================
  ;; Rail nets — one consolidated (net ...) per rail so the validator doesn't
  ;; flag a rail as split across sections. Fill in once sub-blocks land.
  ;; ==========================================================================
  ;; TODO: (net "GND"         ...)
  ;; TODO: (net "VBUS_PD"     "usbc/VBUS_PD" "psu1/VIN" "psu2/VIN" "buck_5v/VIN")
  ;; TODO: (net "VDD5"        "buck_5v/VOUT" "pi_header/VDD5" "buck_3v3/VIN" "ldo_ana/VIN" "bank_a/VIN" "bank_b/VIN" "ux/VDD5")
  ;; TODO: (net "VDD3V3"      "buck_3v3/VOUT" "fpga_sys/VDD3V3" "ldo_core/VIN" "ux/VDD3V3" "housekeeping/VDD3V3")
  ;; TODO: (net "VDD3V3_ANA"  "ldo_ana/VOUT"  "dmm/VDD3V3_ANA")
  ;; TODO: (net "VDD1V2"      "ldo_core/VOUT" "fpga_sys/VDD1V2")
  ;; TODO: (net "VDD_BANK_A"  "bank_a/VOUT" "dut_fixture/VDD_BANK_A" "dut_bench/VDD_BANK_A")
  ;; TODO: (net "VDD_BANK_B"  "bank_b/VOUT" "dut_fixture/VDD_BANK_B" "dut_bench/VDD_BANK_B")
  ;; TODO: (net "VOUT_CH1"    "psu1/VOUT"   "dut_fixture/VOUT_CH1")
  ;; TODO: (net "VOUT_CH2"    "psu2/VOUT"   "dut_fixture/VOUT_CH2")

  ;; -------------------------------------------------------------------------
  ;; Design boundary ports
  ;; -------------------------------------------------------------------------
  (port "VBUS_USBC" in (rated 4.0 5.5))
  (port "GND"       bidi)

)
