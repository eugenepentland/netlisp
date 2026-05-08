;; STM32H562 System-on-Module — Concept Design
;; Compact SOM with Ethernet, locking 12V power input, eFuse protection,
;; and dual B2B connectors for carrier board.
;; Input: 12V nominal, 30W max system draw (~2.5A).

;; Imports — uncomment / extend as each section moves from concept to
;; implemented. Component library files in lib/components/, modules in
;; lib/modules/.
;; (import stm32h562igk6
;;         cap-0201 cap-0402 cap-0603 cap-0805
;;         res-0201 res-0402
;;         ;; power chain
;;         tps25940lrvcr tps62823dlcr lp5907mfx-1-8-nopb tps3840dl30
;;         ;; clocks
;;         nx2520sa abs05
;;         ;; phy + magjack
;;         lan8742a-cz-tr hr911105a esda6v1bc6
;;         ;; usb
;;         usb4110-gf-a usblc6-2sc6
;;         ;; b2b
;;         df40hc-3-0-60ds-0-4v
;;         ;; misc
;;         m24c02-fdw6tp connector-tag-connect)

(design-block "STM32H562 SOM"

  ;; ── Central MCU ────────────────────────────────────────────
  ;; Note: peripheral interfaces (Ethernet/USB/SPI/I2C/SWD/GPIO) are
  ;; declared as separate top-level sections below. When the MCU instance
  ;; is filled in (Phase 3 step 7), use (pins "stm32" (group "...")) for
  ;; per-rail pin grouping rather than nested sub-sections — see
  ;; stm32n6.sexp lines 42–108 for the canonical pattern.
  (section "STM32H562" "ARM Cortex-M33 @ 250MHz, BGA201 (10x10mm)"
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "NRST" in signal role reset)
    (port "BOOT0" in signal)
    (port "FAULT_N" in signal)
    (port "USB_DP" io differential)
    (port "USB_DM" io differential)
    (port "I2C_SDA" io signal protocol I2C)
    (port "I2C_SCL" io signal protocol I2C)
    (port "OSC_IN" in clock)
    (port "OSC_OUT" out clock)
    (note "STM32H562IGK6 — 1MB flash, 640KB RAM, BGA201 0.65mm pitch")
    (note "Internal flash sufficient — no external memory needed")
    (note "Library component is BGA201 (lib/components/stm32h562igk6.sexp); revise here if a UFQFPN-100 variant is sourced instead")
    (note "RMII (TXD0/1, TX_EN, RXD0/1, CRS_DV, REF_CLK) + MDC/MDIO buses go to Ethernet PHY")
    (note "SPI1, SPI2, USART1, USART2, ADC1 routed to B2B Connectors via MCU GPIO"))

  ;; ── Ethernet PHY ───────────────────────────────────────────
  (section "Ethernet PHY" "LAN8742A 10/100 RMII PHY"
    (protocol RMII)
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "NRST" in signal role reset)
    (port "NINT" out signal)
    (port "MDI_TX_P" out differential)
    (port "MDI_TX_N" out differential)
    (port "MDI_RX_P" in differential)
    (port "MDI_RX_N" in differential)
    (port "LED0" out signal)
    (port "LED1" out signal)
    (note "LAN8742A-CZ-TR — QFN-24 (4x4mm), RMII, 3.3V, integrated 1.2V core regulator")
    (note "Shares 25MHz HSE crystal with MCU via REF_CLK output")
    (note "ESDA6V1BC6 (x2) — TVS protection on RMII + MDI lines"))

  ;; ── RJ45 Connector ─────────────────────────────────────────
  (section "RJ45 Connector" "MagJack with integrated magnetics"
    (role output)
    (port "VDD" in power 3.3)
    (port "GND" bidi)
    (port "MDI_TX_P" in differential)
    (port "MDI_TX_N" in differential)
    (port "MDI_RX_P" out differential)
    (port "MDI_RX_N" out differential)
    (port "LED0" in signal)
    (port "LED1" in signal)
    (note "HR911105A — RJ45 with integrated magnetics + activity/link LEDs")
    (note "Through-hole tab-down, connects to LAN8742A MDI+/MDI- pairs")
    (note "LED anodes driven by PHY LED0/LED1 outputs"))

  ;; ── USB-C (Programming / Debug) ─────────────────────────────
  (section "USB-C" "USB 2.0 FS for firmware programming and debug"
    (role input)
    (protocol USB2.0-FS)
    (port "VDD" in power 3.3)
    (port "VBUS" out power 5.0)
    (port "USB_DP" out differential)
    (port "USB_DM" out differential)
    (port "GND" bidi)
    (note "USB4110-GF-A — USB-C 2.0 receptacle, mid-mount SMD, 5A VBUS rating")
    (note "5.1k CC pulldowns for UFP (device) role — no PD, bus-powered not used")
    (note "USBLC6-2SC6 — SOT-23-6, ESD on D+/D- (1.2pF/line)")
    (note "Used for DFU bootloader programming and CDC/VCP serial debug")
    (note "VBUS is connector-only — not used to power the SOM (12V input via Locking Power)"))

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
    (port "FAULT_N" out signal)
    (port "EN_N" in signal)
    (port "GND" bidi)
    (note "TPS25940LRVCR — WQFN-20 (3.5x3.5mm), 2.7-18V input")
    (note "Current limit: 2.7A via ILIM resistor (30W @ 12V + margin)")
    (note "UVLO: ~10V, OVLO: ~14V via resistor dividers")
    (note "dV/dt slew rate control for inrush limiting")
    (note "Built-in reverse polarity protection")
    (note "FAULT# output to MCU GPIO for monitoring")
    (note "100uF bulk cap on output for transient response")

    ;; System power budget gate — the eFuse is the chokepoint for the
    ;; entire SOM, so total downstream current at 12V is asserted here.
    (calc "System current budget at VIN=12V"
      (let i_3v3_max 2.0)        ;; Buck max load (LAN8742 + MCU + B2B)
      (let i_1v8_max 0.25)       ;; LDO max load (PHY analog + MCU analog)
      (let v_3v3 3.3)
      (let v_1v8 1.8)
      (let v_in 12.0)
      (let eff_buck 0.90)
      ;; Power into 12V rail = sum of (V*I) loads divided by stage efficiency
      (let p_3v3 (* v_3v3 i_3v3_max))                   ;; ~6.6 W
      (let p_1v8 (* v_1v8 i_1v8_max))                   ;; ~0.45 W
      (let p_total_out (+ p_3v3 p_1v8))                 ;; ~7.05 W rail load
      (let p_total_in (/ p_total_out eff_buck))          ;; ~7.83 W into 12V
      (let i_in_total (/ p_total_in v_in))               ;; ~0.65 A nominal
      ;; Plus carrier-board allowance via VSYS pass-through (B2B Conn 1)
      (let i_carrier 1.5)
      (let i_total (+ i_in_total i_carrier))             ;; ~2.15 A
      (assert-range i_total 0.0 2.7 "Total VIN current vs eFuse 2.7A limit"))

    ;; ILIM resistor calc — TPS25940 sets I_LIMIT via Kilim/Rilim.
    ;; Datasheet: I_LIMIT(A) ~= 4490 / R_ILIM(ohm) for the LRV variant.
    (calc "ILIM resistor"
      (let i_limit_target 2.7)
      (let kilim 4490.0)                                 ;; ohm-amp constant
      (let r_ilim_calc (/ kilim i_limit_target))         ;; ~1663 ohm
      (let r_ilim_e96 1620.0)                            ;; nearest E96
      (let i_limit_actual (/ kilim r_ilim_e96))          ;; ~2.77 A
      (assert-range i_limit_actual 2.5 3.0 "Actual ILIM"))

    ;; UVLO/OVLO divider — TPS25940 EN/UVLO and OVP rising thresholds = 1.34 V.
    ;; Pick R3 (top) = 1M, then bottoms set ratios.
    (calc "UVLO divider (10V trip)"
      (let v_uvlo 10.0)
      (let v_ref 1.34)
      (let r_top 1000000.0)                              ;; 1M ohm top
      (let r_bot_calc (/ (* r_top v_ref) (- v_uvlo v_ref)))  ;; ~154.7k
      (let r_bot_e96 154000.0)
      (let v_uvlo_actual (* v_ref (/ (+ r_top r_bot_e96) r_bot_e96)))
      (assert-range v_uvlo_actual 9.5 10.5 "UVLO trip"))

    (calc "OVLO divider (14V trip)"
      (let v_ovlo 14.0)
      (let v_ref 1.34)
      (let r_top 1000000.0)
      (let r_bot_calc (/ (* r_top v_ref) (- v_ovlo v_ref)))  ;; ~106k
      (let r_bot_e96 105000.0)
      (let v_ovlo_actual (* v_ref (/ (+ r_top r_bot_e96) r_bot_e96)))
      (assert-range v_ovlo_actual 13.5 14.5 "OVLO trip")))

  ;; ── Voltage Regulators ─────────────────────────────────────
  (section "3.3V Buck" "TPS62823 12V-to-3.3V, 2A"
    (port "VSYS" in power 12.0)
    (port "VDD" out power 3.3)
    (port "EN" in signal)
    (port "GND" bidi)
    (note "TPS62823DLCR — SOT-563 (1.6x1.2mm), 4-22V input, 2A, 2.2MHz")
    (note "~90% efficiency at 12V->3.3V, 3 external components (L, Cin, Cout)")

    ;; 3.3V rail budget — sum of consumers (rough estimates; refine when
    ;; components are placed and (i-typ ...)/(i-max ...) annotations appear).
    ;; Note: arithmetic builtins are strictly binary, so multi-term sums
    ;; are accumulated via successive (let ...) bindings.
    (calc "3.3V load budget"
      (let i_mcu_typ 0.20)            ;; STM32H562 typical at 250 MHz
      (let i_mcu_max 0.40)            ;; with peripherals + Ethernet active
      (let i_phy_typ 0.06)            ;; LAN8742 digital + LED
      (let i_phy_max 0.10)
      (let i_eeprom 0.005)            ;; M24C02 active
      (let i_misc 0.05)               ;; pull-ups, indicators, supervisor
      (let i_carrier 0.50)            ;; allowance via B2B to carrier
      (let i_typ_a (+ i_mcu_typ i_phy_typ))
      (let i_typ_b (+ i_typ_a i_eeprom))
      (let i_typ_c (+ i_typ_b i_misc))
      (let i_total_typ (+ i_typ_c i_carrier))
      (let i_max_a (+ i_mcu_max i_phy_max))
      (let i_max_b (+ i_max_a i_eeprom))
      (let i_max_c (+ i_max_b i_misc))
      (let i_total_max (+ i_max_c i_carrier))
      (assert-range i_total_max 0.0 2.0 "3.3V load vs TPS62823 2A limit"))

    ;; Power dissipation in the buck IC at full load.
    (calc "Buck IC dissipation"
      (let v_in 12.0)
      (let v_out 3.3)
      (let i_out 1.5)                 ;; nominal full load
      (let eff 0.90)
      (let p_in (/ (* v_out i_out) eff))
      (let p_diss (- p_in (* v_out i_out)))   ;; ~0.55 W
      (assert-range p_diss 0.0 1.0 "TPS62823 SOT-563 dissipation budget")))

  (section "1.8V LDO" "LP5907 ultra-low-noise, 250mA"
    (port "VDD" in power 3.3)
    (port "V1P8" out power 1.8)
    (port "EN" in signal)
    (port "GND" bidi)
    (note "LP5907MFX-1.8/NOPB — SOT-23-5, 6.5uVrms noise, PSRR 82dB")
    (note "Powers Ethernet PHY analog and MCU analog rails")
    (note "Reuse via lib/modules/lp5907-ldo.sexp when implementing")

    ;; Dropout headroom and IC dissipation at full load.
    (calc "1.8V LDO budget"
      (let v_in 3.3)
      (let v_out 1.8)
      (let i_max 0.20)                ;; 200 mA worst-case load
      (let v_dropout 0.12)            ;; LP5907 typical at 250 mA
      (let v_headroom (- (- v_in v_out) v_dropout))   ;; ~1.38 V
      (let p_diss (* (- v_in v_out) i_max))           ;; ~0.30 W
      (assert-range v_headroom 0.10 5.00 "Dropout headroom (must be > 0)")
      (assert-range p_diss 0.0 0.40 "SOT-23-5 thermal budget")
      (assert-range i_max 0.0 0.25 "Load vs LP5907 250 mA limit")))

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
    (port "NRST" out signal role reset)
    (port "FAULT_N" out signal)
    (port "BOOT0" out signal)
    (port "SPI1_SCK" out signal protocol SPI)
    (port "SPI1_MISO" in signal protocol SPI)
    (port "SPI1_MOSI" out signal protocol SPI)
    (port "SPI1_CS_N" out signal protocol SPI)
    (port "I2C2_SDA" io signal protocol I2C)
    (port "I2C2_SCL" io signal protocol I2C)
    (note "DF40HC(3.0)-60DS-0.4V(51) — plug on SOM, 0.4mm pitch, 3mm stack")
    (note "Carrier: DF40C-60DP-0.4V(51) receptacle")
    (note "Pin budget: VSYS(2) + VDD(4) + V1P8(2) + GND(10) = 18 power/ground")
    (note "  + NRST, FAULT_N, BOOT0 = 21")
    (note "  + SPI1(4) + I2C2(2) = 27 used; 33 spare for future signals")
    (note "Bottom-mount, mating with carrier board"))

  (section "B2B Connector 2" "GPIO, UART, ADC, Hirose DF40 60-pin"
    (role output)
    (port "VDD" in power 3.3)
    (port "GND" bidi)
    (port "USART1_TX" out signal)
    (port "USART1_RX" in signal)
    (port "USART2_TX" out signal)
    (port "USART2_RX" in signal)
    (port "I2C1_SDA" io signal protocol I2C)
    (port "I2C1_SCL" io signal protocol I2C)
    (port "SWDIO" io signal protocol SWD)
    (port "SWCLK" in signal protocol SWD)
    (port "SWO" out signal protocol SWD)
    (note "DF40HC(3.0)-60DS-0.4V(51) — plug on SOM, 0.4mm pitch, 3mm stack")
    (note "Carrier: DF40C-60DP-0.4V(51) receptacle")
    (note "Pin budget: VDD(4) + GND(10) = 14 power/ground")
    (note "  + USART1(2) + USART2(2) = 18")
    (note "  + I2C1(2) + SWD(3) = 23")
    (note "  + GPIO(20) + ADC(4) + 4 spare = 51 + ~9 reserved = 60")
    (note "Bottom-mount, matching connector 1 footprint"))

  ;; ── Misc ───────────────────────────────────────────────────
  (section "Clocking" "25MHz HSE + 32.768kHz LSE"
    (port "VDD" in power 3.3)
    (port "OSC_IN" out clock)
    (port "OSC_OUT" in clock)
    (port "OSC32_IN" out clock)
    (port "OSC32_OUT" in clock)
    (note "NX2520SA-25.000000MHZ-A-G (NDK) — 2.5x2.0mm, 8pF load, HSE for MCU + PHY")
    (note "ABS05-32.768KHZ-T (Abracon) — 1.6x1.0mm, 6pF load, LSE for RTC")

    ;; Crystal load capacitor calc (mirrors stm32n6.sexp lines 32–39).
    ;; CL_load = 2 * (CL_crystal - C_stray)
    (calc "HSE load capacitors (25 MHz, 8 pF)"
      (let cl 8.0)
      (let cstray 5.0)
      (let cload (* 2.0 (- cl cstray)))     ;; 6 pF — pick standard 5.6 pF
      (assert-range cload 1.0 30.0 "HSE load cap"))

    (calc "LSE load capacitors (32.768 kHz, 6 pF)"
      (let cl 6.0)
      (let cstray 3.0)
      (let cload (* 2.0 (- cl cstray)))     ;; 6 pF — pick standard 5.6 pF
      (assert-range cload 1.0 30.0 "LSE load cap")))

  (section "Boot / Reset" "Reset circuit + boot config"
    (port "VDD" in power 3.3)
    (port "NRST" io signal role reset)
    (port "BOOT0" out signal)
    (note "NRST driven by TPS3840 supervisor — clean POR with 200ms delay")
    (note "BOOT0 pulled to GND via 10k — default boot from internal flash")
    (note "Reset button option exposed via B2B to carrier board"))

  (section "SWD Debug" "Tag-Connect footprint"
    (role output)
    (protocol SWD)
    (port "VDD" in power 3.3)
    (port "GND" bidi)
    (port "SWDIO" io signal protocol SWD)
    (port "SWCLK" out signal protocol SWD)
    (port "SWO" in signal protocol SWD)
    (port "NRST" out signal role reset)
    (note "TC2050-IDC-NL — no-legs Tag-Connect, pogo-pin footprint only (~7.6x2.5mm)")
    (note "Zero board space for connector — just pads on PCB"))

  (section "Power LED" "VSYS indicator"
    (port "VSYS" in power 12.0)
    (port "GND" bidi)
    (note "Green 0402 LED + current limit resistor from VSYS")
    (note "Quick visual indicator that protected power is present")

    ;; LED current-limit resistor sizing.
    (calc "LED current-limit resistor"
      (let v_sys 12.0)
      (let v_led 2.1)                 ;; green 0402 typical Vf
      (let i_led 0.002)               ;; 2 mA — visible, low draw
      (let r_calc (/ (- v_sys v_led) i_led))   ;; ~4950 ohm
      (let r_e96 4990.0)
      (let i_actual (/ (- v_sys v_led) r_e96)) ;; ~1.98 mA
      (assert-range i_actual 0.0005 0.005 "LED current vs 0402 LED rating")))

  (section "I2C EEPROM" "MAC address + carrier board ID"
    (protocol I2C)
    (port "VDD" in power 3.3)
    (port "GND" bidi)
    (port "I2C_SDA" io signal protocol I2C)
    (port "I2C_SCL" io signal protocol I2C)
    (note "M24C02-FDW6TP (ST) — SOT-23-5, 2Kbit I2C EEPROM")
    (note "Stores unique MAC address for Ethernet, carrier board identification")
    (note "Shared I2C bus with B2B connector 2 (I2C1)"))

  ;; Top-level GND port: every section declares its own GND, so this
  ;; design-level port exists only to expose GND as a board-edge net for
  ;; the carrier (B2B connectors). The unconnected_pin warning is
  ;; expected until B2B sections wire it through.
  (port "GND" bidi))
