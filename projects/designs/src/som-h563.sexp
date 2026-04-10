;; STM32H562 System-on-Module — Concept Design
;; Compact SOM with Ethernet, locking 12V power input, eFuse protection,
;; and dual B2B connectors for carrier board.
;; Input: 12V nominal, 30W max system draw (~2.5A).

(design-block "STM32H562 SOM"

  ;; ── Central MCU ────────────────────────────────────────────
  (section "STM32H562" "ARM Cortex-M33 @ 250MHz, UFQFPN-100"
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "NRST" out signal role reset)
    (note "STM32H562IGK6 — 1MB flash, 640KB RAM, UFQFPN-100 (11x11mm)")
    (note "Internal flash sufficient — no external memory needed")

    (section "Ethernet" "RMII to external PHY"
      (protocol RMII)
      (port "VDD" in power 3.3))

    (section "USB FS" "USB 2.0 Full-Speed for programming/debug"
      (protocol USB2.0-FS))

    (section "SPI1"
      (protocol SPI))

    (section "I2C1"
      (protocol I2C))

    (section "SWD Debug"
      (protocol SWD))

    (section "GPIO / Peripherals" "UART, timers, ADC, DAC exposed via B2B"
      (port "VDD" in power 3.3)))

  ;; ── Ethernet PHY ───────────────────────────────────────────
  (section "Ethernet PHY" "LAN8742A 10/100 RMII PHY"
    (protocol RMII)
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (note "LAN8742A-CZ-TR — QFN-24 (4x4mm), RMII, 3.3V, integrated 1.2V core regulator")
    (note "Shares 25MHz HSE crystal with MCU via REF_CLK output")
    (note "ESDA6V1BC6 (x2) — TVS protection on RMII + MDI lines"))

  ;; ── RJ45 Connector ─────────────────────────────────────────
  (section "RJ45 Connector" "MagJack with integrated magnetics"
    (role output)
    (port "VDD" in power 3.3)
    (port "GND" bidi)
    (note "HR911105A — RJ45 with integrated magnetics + activity/link LEDs")
    (note "Through-hole tab-down, connects to LAN8742A MDI+/MDI- pairs")
    (note "LED anodes driven by PHY LED0/LED1 outputs"))

  ;; ── USB-C (Programming / Debug) ─────────────────────────────
  (section "USB-C" "USB 2.0 FS for firmware programming and debug"
    (role input)
    (protocol USB2.0-FS)
    (port "VDD" in power 3.3)
    (port "GND" bidi)
    (note "USB4110-GF-A — USB-C 2.0 receptacle, mid-mount SMD, 5A VBUS rating")
    (note "5.1k CC pulldowns for UFP (device) role — no PD, bus-powered not used")
    (note "USBLC6-2SC6 — SOT-23-6, ESD on D+/D- (1.2pF/line)")
    (note "Used for DFU bootloader programming and CDC/VCP serial debug"))

  ;; ── Locking Power Connector ────────────────────────────────
  (section "Locking Power Input" "Molex Micro-Fit 3.0, 12V external DC"
    (role input)
    (port "VIN" out power 12.0)
    (port "GND" bidi)
    (note "0430450200 — Molex Micro-Fit 3.0 vertical header, 2-pin, 5A/contact")
    (note "Mating housing: 0430250200, crimp terminals: 0430300001"))

  ;; ── eFuse (Programmable Protection) ────────────────────────
  (section "eFuse" "TPS25940 programmable protection, 12V/2.7A"
    (port "VIN" in power 12.0)
    (port "VSYS" out power 12.0)
    (port "GND" bidi)
    (note "TPS25940LRVCR — WQFN-20 (3.5x3.5mm), 2.7-18V input")
    (note "Current limit: 2.7A via ILIM resistor (30W @ 12V + margin)")
    (note "UVLO: ~10V, OVLO: ~14V via resistor dividers")
    (note "dV/dt slew rate control for inrush limiting")
    (note "Built-in reverse polarity protection")
    (note "FAULT# output to MCU GPIO for monitoring")
    (note "100uF bulk cap on output for transient response"))

  ;; ── Voltage Regulators ─────────────────────────────────────
  (section "3.3V Buck" "TPS62823 12V-to-3.3V, 2A"
    (port "VSYS" in power 12.0)
    (port "VDD" out power 3.3)
    (port "GND" bidi)
    (note "TPS62823DLCR — SOT-563 (1.6x1.2mm), 4-22V input, 2A, 2.2MHz")
    (note "~90% efficiency at 12V->3.3V, 3 external components (L, Cin, Cout)"))

  (section "1.8V LDO" "LP5907 ultra-low-noise, 250mA"
    (port "VDD" in power 3.3)
    (port "V1P8" out power 1.8)
    (port "GND" bidi)
    (note "LP5907MFX-1.8/NOPB — SOT-23-5, 6.5uVrms noise, PSRR 82dB")
    (note "Powers Ethernet PHY analog and MCU analog rails"))

  ;; ── Power Supervisor ──────────────────────────────────────
  (section "Power Supervisor" "Hold NRST until rails stable"
    (port "VDD" in power 3.3)
    (port "NRST" out signal role reset)
    (port "GND" bidi)
    (note "TPS3840DL30 — SOT-5X3, monitors 3.3V rail, open-drain RESET output")
    (note "Threshold 2.93V (3.3V - 11%), 200ms power-on delay")
    (note "Holds NRST low until VDD is stable — ensures clean MCU + PHY startup"))

  ;; ── Board-to-Board Connectors ──────────────────────────────
  (section "B2B Connector 1" "Power + control signals, Hirose DF40 60-pin"
    (role output)
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "VSYS" in power 12.0)
    (port "GND" bidi)
    (note "DF40HC(3.0)-60DS-0.4V(51) — plug on SOM, 0.4mm pitch, 3mm stack")
    (note "Carrier: DF40C-60DP-0.4V(51) receptacle")
    (note "Pinout: VSYS (x2), VDD (x4), V1P8 (x2), GND (x10)")
    (note "  NRST, FAULT#, BOOT0, SPI (x4), I2C (x2)")
    (note "Bottom-mount, mating with carrier board"))

  (section "B2B Connector 2" "GPIO, UART, ADC, Hirose DF40 60-pin"
    (role output)
    (port "VDD" in power 3.3)
    (port "GND" bidi)
    (note "DF40HC(3.0)-60DS-0.4V(51) — plug on SOM, 0.4mm pitch, 3mm stack")
    (note "Carrier: DF40C-60DP-0.4V(51) receptacle")
    (note "Pinout: UART1 (x2), UART2 (x2), GPIO (x20), ADC (x4)")
    (note "  SWD (x4), GND (x10)")
    (note "Bottom-mount, matching connector 1 footprint"))

  ;; ── Misc ───────────────────────────────────────────────────
  (section "Clocking" "25MHz HSE + 32.768kHz LSE"
    (port "VDD" in power 3.3)
    (note "NX2520SA-25.000000MHZ-A-G (NDK) — 2.5x2.0mm, 8pF load, HSE for MCU + PHY")
    (note "ABS05-32.768KHZ-T (Abracon) — 1.6x1.0mm, 6pF load, LSE for RTC"))

  (section "Boot / Reset" "Reset circuit + boot config"
    (port "VDD" in power 3.3)
    (port "NRST" in signal role reset)
    (note "NRST driven by TPS3840 supervisor — clean POR with 200ms delay")
    (note "BOOT0 pulled to GND via 10k — default boot from internal flash")
    (note "Reset button option exposed via B2B to carrier board"))

  (section "SWD Debug" "Tag-Connect footprint"
    (role output)
    (protocol SWD)
    (port "VDD" in power 3.3)
    (note "TC2050-IDC-NL — no-legs Tag-Connect, pogo-pin footprint only (~7.6x2.5mm)")
    (note "Zero board space for connector — just pads on PCB"))

  (section "Power LED" "VSYS indicator"
    (port "VSYS" in power 12.0)
    (port "GND" bidi)
    (note "Green 0402 LED + current limit resistor from VSYS")
    (note "Quick visual indicator that protected power is present"))

  (section "I2C EEPROM" "MAC address + carrier board ID"
    (protocol I2C)
    (port "VDD" in power 3.3)
    (note "M24C02-FDW6TP (ST) — SOT-23-5, 2Kbit I2C EEPROM")
    (note "Stores unique MAC address for Ethernet, carrier board identification")
    (note "Shared I2C bus with B2B connector 2"))

  (port "GND" bidi))
