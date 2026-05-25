;; ===========================================================================
;; Bench Lab Multitool v1.1 — Standalone
;; ---------------------------------------------------------------------------
;; Self-contained bench instrument: dual-channel programmable PSU + RP2350
;; PIO-based logic analyzer/programmer + galvanically isolated 3.5-digit DMM.
;; Standalone UI driven by an ESP32-S3 on a 5" 800x480 capacitive touchscreen.
;; Wi-Fi built in via ESP32-S3; optional USB-C host port for scripting / data.
;; Power from USB-C PD (5-20V) or DC barrel jack (9-24V), ideal-diode OR'd.
;;
;; MAIN IC: RP2350B (QFN-80) — handles all real-time tasks: PSU control loop
;; (1 kHz, hardware OCP <1 ms), 16-channel LA via PIO+DMA (25 MS/s), protocol
;; engines (SPI/I2C/JTAG/SWD/UART), isolated DMM reads, and safety monitoring.
;; The ESP32-S3 is the UI co-processor: touchscreen, Wi-Fi, web dashboard,
;; script storage; communicates to RP2350 over a dedicated SPI link.
;;
;; PARTIAL IMPLEMENTATION — section skeleton, ports, notes, and passives are
;; in place. Library symbols for the RP2350, ESP32-S3, and other ICs still need
;; to be added to lib/ before sub-block modules can be fully instantiated.
;; TODOs identify exactly what remains. See design.md + design2.md for full BOM.
;; ===========================================================================

;; TODO: add library symbols for these parts before importing modules:
;;   rp2350b           — Raspberry Pi RP2350B, QFN-80, 48 GPIO, dual-core M33 + 8 PIO SM
;;   esp32-s3-wroom-1u — Espressif ESP32-S3-WROOM-1U-N16R8, U.FL antenna, 16MB flash + 8MB PSRAM
;;   w25q128jvsiq      — Winbond 16MB QSPI flash (SOIC-8) for RP2350 XIP
;;   ap33772           — Diodes Inc. AP33772 USB-C PD sink controller (TSSOP-16)
;;   lm66100           — TI LM66100 ideal diode controller (SOT-23-6), one per OR'd source
;;   tps55289wryqr     — TI TPS55289 4A buck-boost (VQFN-22), I2C-programmed PSU channel
;;   ina228aidgsr      — TI INA228 20-bit V/I monitor (VSSOP-10), Kelvin-sensed PSU telemetry
;;   tps62933drlr      — TI TPS62933 3A buck (SOT-563), 20V→5V and 5V→3.3V
;;   adp7118aujz-3p3   — ADI ADP7118 ultra-low-noise 3.3V LDO (TSOT-5)
;;   tlv62568dbvr      — TI TLV62568 adjustable buck (SOT-23-6), DUT bank VCCIO
;;   mcp4726a0t        — Microchip MCP4726 single-ch 12-bit I2C DAC (SOT-23-6), bank setpoint
;;   ina260aipwr       — TI INA260 V/I monitor (TSSOP-16), per-bank DUT rail monitoring
;;   lsf0108pwr        — TI LSF0108 8-ch auto-dir level shifter (TSSOP-24), DUT I/O
;;   pesd5v0s2uat      — Nexperia PESD5V0S2UAT 4-ch TVS array (SOT-457), DUT protection
;;   ads1115idgsr      — TI ADS1115 16-bit I2C ADC (VSSOP-10), DMM front-end
;;   nke0505sc         — Murata NKE0505SC 5V→5V 1W isolated DC-DC (SIP-4), DMM isolation
;;   iso1640bdr        — TI ISO1640 bidirectional I2C isolator 3kV (SOIC-8)
;;   24aa025uid        — Microchip 24AA025UID 2Kbit I2C EEPROM w/ EUI-48 (SOT-23-5), DMM cal
;;   mcp6v51t          — Microchip MCP6V51 zero-drift op-amp (SOT-23-5), DMM input buffer
;;   ts5a23159         — TI TS5A23159 2-ch SPDT analog switch (MSOP-10), DMM V/R mux
;;   ts3a5018pwr       — TI TS3A5018 4:1 analog mux (TSSOP-16), DMM R-range select
;;   tca9555pwr        — TI TCA9555 16-bit I2C I/O expander (TSSOP-24), housekeeping
;;   ds3231sn          — Maxim DS3231SN MEMS RTC (SOIC-16), I2C @ 0x68
;;   tmp1075ndrlr      — TI TMP1075 I2C temp sensor (SOT-563), thermal monitoring
;;   ws2812b-2020      — Worldsemi WS2812B-2020 addressable RGB LED (2x2mm)
;;   pec11r-4215f      — Bourns PEC11R rotary encoder (12mm), quadrature + pushbutton
;;   cj-002a-barrel    — CUI PJ-002A panel-mount DC barrel jack (5.5/2.1mm, 9-24V)
;;   bnc-31-5329       — Amphenol 31-5329 panel-mount BNC jack (50Ω)
;;   abort-button      — Large red illuminated tactile, N.C. contacts, panel mount
;;   ffsh-25-01-l-d-k  — Samtec 2x25 1.27mm latching shroud (DUT fixture connector)
;;   pin-header-2x5    — 2x5 0.1" keyed pin header (DUT bench connector)
;;   banana-jack       — Hirschmann SLB4-G finger-guarded banana jack
;;   mounting-standoff — M3 SMD standoff
;;   pj-002a           — CUI DC barrel jack
;;   smaj24a           — SMC TVS 24V for barrel jack protection

(import 2n7002
        a-wurth-wa-smsi-9774020633r
        fiducial-0p75-2p25
        testpoint
        connector-swd-6)

(design-block "Bench Lab Multitool v1.1 — Standalone"

  ;; TODO: instance the RP2350B once its symbol is in lib/
  ;; (instance "U1" rp2350b (id ........))

  ;; -------------------------------------------------------------------------
  ;; RP2350 Core System — main IC support: flash, crystal, USB, decoupling
  ;; Case 3: MCU support infrastructure → one section
  ;; -------------------------------------------------------------------------
  (section "RP2350 Core System" "RP2350B QFN-80 + W25Q128 16MB QSPI flash + 12MHz SMD crystal + USB-C HOST port (native USB2 FS/HS)"
    (row 0) (col 0)
    (port "VDD3V3"  in  power 3.3)
    (port "VDD_USB" in  power 3.3)
    (port "GND"     bidi)
    ;; TODO: (pins "U1" (group "Digital core VDD") ...)    ;; 3.3V supply pins — 100nF + 10uF decoupling per pin pair
    ;; TODO: (pins "U1" (group "QSPI flash") ...)          ;; CLK/D0-D3/CS to W25Q128 — RP2350 boots XIP from this flash
    ;; TODO: (pins "U1" (group "USB D+/D-") ...)           ;; native RP2350 USB DP/DM → USB-C HOST port J1
    ;; TODO: (pins "U1" (group "12MHz XOSC") ...)          ;; XI/XO to 12MHz SMD crystal (3.2x2.5mm)
    ;; TODO: (pins "U1" (group "BOOTSEL") ...)             ;; panel-accessible tactile switch → GND (UF2 boot mode)
    ;; TODO: (pins "U1" (group "SWD debug") ...)           ;; SWCLK/SWDIO → Tag-Connect TC2030 footprint
    ;; TODO: (pins "U1" (group "RUN/reset") ...)           ;; active-low reset, 10k pull-up to 3.3V + 100nF filter
    (note "RP2350B has 8 PIO state machines and dual DMA engines — the LA, all 5 protocol engines, and the buzzer PWM run in PIO without blocking the M33 cores. PSU PI loop runs on core 0 at 1 kHz; UI/communication on core 1.")
    (note "W25Q128JVSIQ: 16MB QSPI flash connected to RP2350 QSPI port (CLK/D0-D3/CS). The RP2350 XIP-boots directly from this flash; no separate config step needed. Re-flashable via USB UF2 bootloader (BOOTSEL button) or SWD.")
    (note "GPIO budget: 24 DUT signals + I2C×2 (4) + SPI-to-ESP32S3 (5) + NeoPixel (1) + encoder (3) + buzzer (1) + TPS55289 EN (2) + connector-detect (2) + VBUS sense ADC (2) + abort-sense (1) + trigger BNC (1) = 46 used, 2 spare out of 48 total."))
  ;; TODO: (sub-block "mcu" (rp2350b-core))   ;; RP2350B + W25Q128 + crystal + reset + BOOTSEL

  ;; -------------------------------------------------------------------------
  ;; USB-C Host Interface — data port, RP2350 native USB (CDC + bulk)
  ;; -------------------------------------------------------------------------
  (section "USB-C Host Interface" "GCT USB4105-GF-A mid-mount + USBLC6-2SC6 ESD + CC 5.1kΩ pull-downs — RP2350 native USB2 FS, USB CDC for scripting/capture/firmware update"
    (row 0) (col 1)
    (role bidi)
    (protocol USB)
    (port "VDD5"   in  power 5.0)
    (port "GND"    bidi)
    ;; TODO: (pins "U1" (group "USB D+/D-") ...)   ;; pin map declared under RP2350 Core System
    ;; TODO: (instance "J1" connector-usb-c (id ........))
    ;; TODO: (instance "U2" esd-usb ...)            ;; USBLC6-2SC6
    ;; TODO: CC pull-downs: 2x 5.1kΩ 0402 to GND (identify this port as UFP/device to host)
    (note "HOST port carries USB 2.0 full-speed CDC: labstation command/control + capture streaming. RP2350's USB bootloader uses this port for UF2 firmware update. VBUS from this port is OR'd into +5V_SYS via an ideal diode (LM66100) so a USB-only setup powers the digital side without the PSU rail.")
    (note "CC pull-downs (2x 5.1kΩ to GND on CC1+CC2) identify this port as a UFP (device) to the host's USB-PD controller — required by USB-C spec even when only using USB 2.0 data. Absence of pull-downs can prevent host enumeration on strict USB-C ports.")
    (note "No data lines on the POWER port (see USB-C Power Input section) — the two USB-C ports are dedicated: HOST=data+5V, POWER=PD high-voltage only."))
  ;; TODO: (sub-block "usb_host" (usbc-host-port))

  ;; -------------------------------------------------------------------------
  ;; ESP32-S3 UI & Networking — touchscreen co-processor, Wi-Fi, web server
  ;; -------------------------------------------------------------------------
  (section "ESP32-S3 UI" "ESP32-S3-WROOM-1U-N16R8 module (16MB flash, 8MB PSRAM, U.FL ant) + TXB0104 level shifter — LVGL GUI, Wi-Fi, WebSocket API, script storage, OTA updates"
    (row 1) (col 0)
    (role bidi)
    (protocol SPI)
    (port "VDD3V3" in  power 3.3)
    (port "GND"    bidi)
    ;; TODO: (instance "U3" esp32-s3-wroom-1u (id ........))
    ;; TODO: (pins "U3" (group "SPI to RP2350") ...)           ;; 4-wire SPI + READY/INT — RP2350 is SPI peripheral, ESP32-S3 is master
    ;; TODO: (pins "U3" (group "LCD RGB interface") ...)       ;; 16-bit parallel RGB + HSYNC/VSYNC/DE/CLK → display FPC
    ;; TODO: (pins "U3" (group "Touch SPI") ...)               ;; SPI to capacitive touch controller on the display panel
    ;; TODO: (pins "U3" (group "Wi-Fi antenna") ...)           ;; U.FL connector → external 2.4GHz antenna or PCB trace
    ;; TODO: (pins "U3" (group "STRAPPING / BOOT") ...)        ;; GPIO0 pull-up (auto-boot mode), GPIO3 JTAG, IO45/46
    ;; TODO: (pins "U3" (group "Power supply") ...)            ;; 3.3V + decoupling (100nF + 10uF per supply pin)
    ;; TODO: Level translator: TXB0104 (3.3V both sides, but safe for SPI) between RP2350 and ESP32-S3 SPI lines
    (note "Communication protocol: ESP32-S3 (SPI master) polls RP2350 (SPI peripheral) via a structured register map — PSU setpoints, telemetry readback, LA trigger commands, encoder position, button state. A READY line (RP2350→ESP32-S3) signals when new telemetry is available to avoid unnecessary polling.")
    (note "ESP32-S3 firmware: ESP-IDF + LVGL. Primary screens: Home (dual PSU readout + DMM, enable toggles, presets), Numeric keypad (tap any setpoint), Programs (run stored JSON test sequences), Settings (Wi-Fi, cal, trigger). The web dashboard exposes a WebSocket API identical to the web server interface — any Python script or browser can control the instrument over Wi-Fi.")
    (note "Script storage: JSON test sequences stored in the ESP32-S3's 16MB flash, selected from the touchscreen Programs screen and sent as commands to the RP2350. OTA gateware updates can be pushed over Wi-Fi by downloading a new UF2 and triggering RP2350's USB bootloader via the SPI control link."))
  ;; TODO: (sub-block "esp32" (esp32-s3-ui))

  ;; -------------------------------------------------------------------------
  ;; Touchscreen Display — 5" IPS 800x480 capacitive, ESP32-S3 RGB interface
  ;; -------------------------------------------------------------------------
  (section "Touchscreen Display" "5\" IPS TFT 800x480 cap-touch (Elecrow RC050S or equiv, ILI6480/ST7262 controller) — ESP32-S3 16-bit RGB + SPI touch, front-panel mounted"
    (row 1) (col 1)
    (role output)
    (port "VDD3V3" in power 3.3)
    (port "GND"    bidi)
    ;; TODO: 40-pin FPC/ZIF connector to the 5" panel (ESP32-S3 LCD peripheral, 16-bit parallel RGB)
    ;; TODO: Separate SPI bus for touch controller (XPT2046 or STMPE610 or FT5x06 — panel-dependent)
    ;; TODO: Display backlight: PWM-dimmed LED string, boost converter if panel needs >5V BL rail
    ;; TODO: (instance "LCD1" panel-fpc-40p ...)    ;; 40-pin FPC connector for display + touch
    (note "ESP32-S3 drives the panel directly via its built-in LCD controller (i80 / RGB parallel mode). The panel must have an on-board display controller that accepts parallel RGB + HSYNC/VSYNC/DE/CLK; source panels specifying ILI6480 or ST7262. The touch controller (typically on a separate SPI bus over the same FPC) is also driven by the ESP32-S3.")
    (note "Enclosure: the 5\" panel mounts on the front face of the instrument; the FPC cable routes internally to the carrier PCB. Matte anti-glare film recommended for bench environments with overhead fluorescent lighting."))
  ;; TODO: (sub-block "display" (touchscreen-5in))

  ;; -------------------------------------------------------------------------
  ;; USB-C Power Input — PD power port, AP33772 PD sink, 5-20V → VPWR_IN
  ;; -------------------------------------------------------------------------
  (section "USB-C Power Input" "GCT USB4105-GF-A + AP33772 PD sink (I2C2 @ 0x22, auto 20V/3A primary, 15/9/5V fallback) + USBLC6-2SC6 ESD — power-only, no data lines"
    (row 2) (col 0)
    (role input)
    (protocol USB-PD)
    (port "VBUS_USBC" in  (rated 4.0 5.5))
    (port "VPWR_IN"   out power 20.0)
    (port "GND"       bidi)
    (note "Power-only USB-C port: D+/D- are NOT routed to any data interface. CC1/CC2 go only to the AP33772 for PD negotiation. The RP2350 reads the negotiated PDO over I2C bus #2 @ 0x22.")
    (note "AP33772 negotiates autonomously at power-on. Once a PDO is selected, VBUS rises to the negotiated voltage (20V primary, falling back to 15/9/5V). The LM66100 ideal diode OR controller combines this VBUS with the DC barrel jack output before the TPS62933 system buck — whichever source is higher wins.")
    (note "ESD: USBLC6-2SC6 across VBUS / CC1 / CC2. Quiescent draw: AP33772 ~100uA — only the PD controller is alive before the system buck enables."))
  ;; TODO: (sub-block "usbc_pwr" (usbc-power-port))

  ;; -------------------------------------------------------------------------
  ;; DC Barrel Jack Input — 9-24V lab supply, OR'd with USB-C POWER port
  ;; -------------------------------------------------------------------------
  (section "DC Barrel Jack Input" "CUI PJ-002A 5.5/2.1mm panel-mount jack (centre +ve, 9-24V, 5A) + SMAJ24A TVS + LM66100 ideal diode → VPWR_IN"
    (row 2) (col 1)
    (role input)
    (port "VPWR_IN" out (rated 9.0 24.0))
    (port "GND"     bidi)
    ;; TODO: (instance "J3" pj-002a (id ........))              ;; panel-mount barrel jack
    ;; TODO: (instance "D1" diode-sod323 "SMAJ24A" ...)         ;; TVS on barrel jack input
    ;; TODO: (instance "FB1" ferrite-0402 ...)                  ;; ferrite bead on barrel jack output
    ;; TODO: bulk decoupling: 100uF electrolytic at barrel jack output before ideal diode
    ;; TODO: (instance "U4" lm66100 (id ........))              ;; ideal diode for barrel jack → VPWR_IN
    ;; TODO: (instance "U5" lm66100 (id ........))              ;; ideal diode for USB-C POWER VBUS → VPWR_IN
    (note "Accepts 9-24V from any lab bench supply (linear or switching). Centre-positive standard (IEC 60130-10 Type A). Rated 5A continuous — sufficient for both PSU channels at 3A each plus system overhead.")
    (note "Ideal diode OR'ing (2x LM66100): barrel jack and USB-C PD VBUS are OR'd together with near-zero forward drop. The higher-voltage source wins; both can be plugged in simultaneously. When running from a low-noise linear bench supply, the barrel jack path feeds the PSU channels directly and the USB-C VBUS sense (via AP33772) can still be monitored for system awareness.")
    (note "Input protection: SMAJ24A bidirectional TVS clamps voltage transients from inductive loads on the bench supply. Ferrite bead attenuates conducted switching noise. 100uF electrolytic provides holdup for brief supply droop."))

  ;; -------------------------------------------------------------------------
  ;; DUT Level Shifters & Protection — LSF0108 + 100Ω series R + TVS arrays
  ;; -------------------------------------------------------------------------
  (section "DUT Level Shifters & Protection" "3x TI LSF0108PWR 8-ch auto-dir level shifter (TSSOP-24) + 24x 100Ω 0402 series R + 6x Nexperia PESD5V0S2UAT 4-ch TVS (SOT-457) — DUT I/O protection and VCCIO translation"
    (row 3) (col 0)
    (role bidi)
    (port "VDD_BANK_A" in (rated 1.8 3.3))   ;; DUT-side VCCIO (Bank A, 8 pins)
    (port "VDD_BANK_B" in (rated 1.8 3.3))   ;; DUT-side VCCIO (Bank B, 8 pins)
    (port "VDD_BANK_C" in (rated 1.8 3.3))   ;; DUT-side VCCIO (Bank C — bench header 8 pins)
    (port "VDD3V3"     in power 3.3)          ;; MCU-side reference
    (port "GND"        bidi)
    ;; TODO: (instance "U6"  lsf0108pwr (id ........))  ;; LSF0108 #1: 8 DUT fixture ch, Bank A
    ;; TODO: (instance "U7"  lsf0108pwr (id ........))  ;; LSF0108 #2: 8 DUT fixture ch, Bank B
    ;; TODO: (instance "U8"  lsf0108pwr (id ........))  ;; LSF0108 #3: 8 DUT bench header ch
    ;; DUT series protection resistors (24 total, one per DUT pin, MCU side of TVS)
    ;; Fixture connector — Bank A (8 pins)
    (instance "R1"  (res-0402 "100R") (pin 1 "DUT_FIX_A0_MCU") (pin 2 "DUT_FIX_A0_TVS") (id ff42975d))
    (instance "R2"  (res-0402 "100R") (pin 1 "DUT_FIX_A1_MCU") (pin 2 "DUT_FIX_A1_TVS") (id a1c3eaf2))
    (instance "R3"  (res-0402 "100R") (pin 1 "DUT_FIX_A2_MCU") (pin 2 "DUT_FIX_A2_TVS") (id f54b6e95))
    (instance "R4"  (res-0402 "100R") (pin 1 "DUT_FIX_A3_MCU") (pin 2 "DUT_FIX_A3_TVS") (id df0078c5))
    (instance "R5"  (res-0402 "100R") (pin 1 "DUT_FIX_A4_MCU") (pin 2 "DUT_FIX_A4_TVS") (id ce1a4194))
    (instance "R6"  (res-0402 "100R") (pin 1 "DUT_FIX_A5_MCU") (pin 2 "DUT_FIX_A5_TVS") (id a5e7e782))
    (instance "R7"  (res-0402 "100R") (pin 1 "DUT_FIX_A6_MCU") (pin 2 "DUT_FIX_A6_TVS") (id b1f6fbb7))
    (instance "R8"  (res-0402 "100R") (pin 1 "DUT_FIX_A7_MCU") (pin 2 "DUT_FIX_A7_TVS") (id aa3e9720))
    ;; Fixture connector — Bank B (8 pins)
    (instance "R9"  (res-0402 "100R") (pin 1 "DUT_FIX_B0_MCU") (pin 2 "DUT_FIX_B0_TVS") (id a3c90bf6))
    (instance "R10" (res-0402 "100R") (pin 1 "DUT_FIX_B1_MCU") (pin 2 "DUT_FIX_B1_TVS") (id bad40ddb))
    (instance "R11" (res-0402 "100R") (pin 1 "DUT_FIX_B2_MCU") (pin 2 "DUT_FIX_B2_TVS") (id a38b44da))
    (instance "R12" (res-0402 "100R") (pin 1 "DUT_FIX_B3_MCU") (pin 2 "DUT_FIX_B3_TVS") (id dbac722d))
    (instance "R13" (res-0402 "100R") (pin 1 "DUT_FIX_B4_MCU") (pin 2 "DUT_FIX_B4_TVS") (id a7406114))
    (instance "R14" (res-0402 "100R") (pin 1 "DUT_FIX_B5_MCU") (pin 2 "DUT_FIX_B5_TVS") (id b01356c9))
    (instance "R15" (res-0402 "100R") (pin 1 "DUT_FIX_B6_MCU") (pin 2 "DUT_FIX_B6_TVS") (id bf314c05))
    (instance "R16" (res-0402 "100R") (pin 1 "DUT_FIX_B7_MCU") (pin 2 "DUT_FIX_B7_TVS") (id b168f647))
    ;; Bench header (8 pins)
    (instance "R17" (res-0402 "100R") (pin 1 "DUT_BENCH0_MCU") (pin 2 "DUT_BENCH0_TVS") (id fcb7d433))
    (instance "R18" (res-0402 "100R") (pin 1 "DUT_BENCH1_MCU") (pin 2 "DUT_BENCH1_TVS") (id f58ead23))
    (instance "R19" (res-0402 "100R") (pin 1 "DUT_BENCH2_MCU") (pin 2 "DUT_BENCH2_TVS") (id f43430db))
    (instance "R20" (res-0402 "100R") (pin 1 "DUT_BENCH3_MCU") (pin 2 "DUT_BENCH3_TVS") (id b987a181))
    (instance "R21" (res-0402 "100R") (pin 1 "DUT_BENCH4_MCU") (pin 2 "DUT_BENCH4_TVS") (id f7f28a07))
    (instance "R22" (res-0402 "100R") (pin 1 "DUT_BENCH5_MCU") (pin 2 "DUT_BENCH5_TVS") (id a8541ca4))
    (instance "R23" (res-0402 "100R") (pin 1 "DUT_BENCH6_MCU") (pin 2 "DUT_BENCH6_TVS") (id da4998eb))
    (instance "R24" (res-0402 "100R") (pin 1 "DUT_BENCH7_MCU") (pin 2 "DUT_BENCH7_TVS") (id d23145bf))
    ;; TODO: 6x PESD5V0S2UAT 4-ch TVS arrays — one per 4 DUT pins (connector side, before LSF0108 B-side)
    ;; Protection path: connector pin → 100Ω series R → TVS to GND → LSF0108 B-side
    ;; The 100Ω limits fault current; TVS clamps to ~5V before the level shifter.
    (note "LSF0108 is a passive auto-direction 8-ch level shifter requiring no direction-control signal. VCCA = 3.3V (RP2350 side), VCCB = bank rail (1.8/2.5/3.3V DUT side). Suitable for GPIO / protocol bridge use up to ~100 MHz.")
    (note "Protection per DUT pin: connector → 100Ω (0402, 1%, limits fault current) → PESD5V0S2UAT TVS (5V working voltage, 4-ch per SOT-457 package, clamps ESD/accidental over-voltage before it reaches the LSF0108) → LSF0108 B-side. The level shifter itself is protected from sustained faults.")
    (note "100Ω series R gives >50 MHz bandwidth with ≤30pF load — well above the 25 MS/s LA limit. Verify signal integrity on long fixture cables at 25 MS/s; derate to 12 MS/s for >12\" FFSD cables with heavy capacitive loading."))

  ;; -------------------------------------------------------------------------
  ;; DUT Fixture Connector — 1.27mm 2x25 latching shroud (16 ch)
  ;; -------------------------------------------------------------------------
  (section "DUT Fixture Connector" "Samtec FFSH-25-01-L-D-K 1.27mm 2x25 latching shroud — 16 DUT signals (8 Bank A + 8 Bank B) + 16 dedicated GNDs + 4 PSU CH1 + 4 PSU CH2 + 4 GND guards + 2 bank Vrefs + 4 aux"
    (row 4) (col 0)
    (role bidi)
    (port "VDD_BANK_A" in (rated 1.8 3.3))
    (port "VDD_BANK_B" in (rated 1.8 3.3))
    (port "VOUT_CH1"   in (rated 0.0 18.0))
    (port "VOUT_CH2"   in (rated 0.0 18.0))
    (port "GND"        bidi)
    ;; TODO: (instance "J4" ffsh-25-01-l-d-k (id ........))
    ;; TODO: connector-detect pin: one fixture pin shorted to GND on fixture side → RP2350 GPIO (detects cable plugged in)
    (note "Primary fixture interface for production test / repeatable bring-up. Latching shroud prevents accidental disconnects mid-test. Mates with off-the-shelf Samtec FFSD ribbon assemblies (6\"/12\"/18\"/24\" stocked at Digi-Key/Mouser).")
    (note "DUT signal path: fixture pin → 100Ω R → TVS → LSF0108 B-side → LSF0108 A-side → RP2350 GPIO (via PIO sampler). All 24 physical DUT pins are sampled by pin_monitor regardless of which connector is active in the PIO connector_mux.")
    (note "Single-cable integration: 16 signals + PSU rails + GND guards on one connector, so a custom fixture PCB plugs in with one cable instead of four. Interleaved GNDs (one per signal) maintain clean LA captures at 25 MS/s."))
  ;; TODO: (sub-block "dut_fixture" (dut-fixture-50p))

  ;; -------------------------------------------------------------------------
  ;; DUT Bench Header — 2x5 0.1" pin header (jumper/scope friendly)
  ;; -------------------------------------------------------------------------
  (section "DUT Bench Header" "2x5 0.1\" keyed pin header — 8 DUT signals (Bank A/B mixed) + interleaved GNDs + 2 bank Vref pins"
    (row 4) (col 1)
    (role bidi)
    (port "VDD_BANK_A" in (rated 1.8 3.3))
    (port "VDD_BANK_B" in (rated 1.8 3.3))
    (port "GND"        bidi)
    ;; TODO: (instance "J5" pin-header-2x5 (id ........))
    ;; TODO: connector-detect pin: one bench header pin shorted to GND when a connector is plugged in
    (note "Ad-hoc bring-up interface: 0.1\" pitch for jumper wires, scope probe ground clips, and alligator clips. PSU rails are NOT brought out on this connector — bench PSU access remains the front-panel banana jacks.")
    (note "8 DUT signals share the same bank rails as the fixture connector. The RP2350 PIO connector_mux register selects which connector's pins the 16-channel LA / protocol engines see at any moment. pin_monitor samples all 24 physical DUT pins continuously."))
  ;; TODO: (sub-block "dut_bench" (dut-bench-10p))

  ;; -------------------------------------------------------------------------
  ;; External Trigger BNC — RP2350 PIO GPIO, input or output, 50Ω
  ;; -------------------------------------------------------------------------
  (section "External Trigger BNC" "Amphenol 31-5329 panel-mount BNC + CDSOT23-SM712 TVS + 50Ω series terminator — RP2350 PIO GPIO, configurable trigger input or output"
    (row 3) (col 1)
    (role bidi)
    (port "VDD3V3" in power 3.3)
    (port "GND"    bidi)
    ;; TODO: (instance "J6" bnc-31-5329 (id ........))
    ;; TODO: TVS: CDSOT23-SM712 across BNC center pin to GND (bidirectional ±7V clamp)
    ;; 50Ω series terminator between BNC center pin and RP2350 GPIO
    (instance "R25" (res-0402 "49.9R") (pin 1 "BNC_CENTER") (pin 2 "TRIG_MCU") (id dd509f7f))
    ;; Optional AC coupling cap DNP by default; footprint only — install if trigger source has DC offset
    ;; TODO: (instance "C1" (cap-0402 "100nF") (pin 1 "BNC_CENTER") (pin 2 "TRIG_MCU"))  ;; AC coupling, bridges to TRIG_MCU
    (note "Connected to a dedicated RP2350 PIO state machine. Software-configurable as: (a) trigger INPUT — external event (scope trigger out, signal gen, DUT GPIO) starts an LA capture with precise timestamp; (b) trigger OUTPUT — LA capture-ready, OCP fault, or test-pass/fail signal sent to scope or external equipment.")
    (note "50Ω series resistor matches the BNC to 50Ω coax. Input mode: 50Ω to GND is achieved by enabling RP2350's internal pull-down (weak; add external 49.9Ω to GND for proper 50Ω termination when driven from a 50Ω source). Output mode: 50Ω series + RP2350 drive strength gives a clean edge into 50Ω load."))

  ;; -------------------------------------------------------------------------
  ;; DMM Analog Front-End — 3.5-digit, galvanically isolated (3kV), I2C2
  ;; -------------------------------------------------------------------------
  (section "DMM Analog Front-End" "ADS1115IDGSR 16-bit I2C ADC + MCP6V51 zero-drift op-amp + TS5A23159 V/R mux + TS3A5018 R-range mux + 11:1 voltage divider + Murata NKE0505SC isolated DC-DC + TI ISO1640 I2C isolator (3kV) + 24AA025UID cal EEPROM — probes isolated from chassis GND"
    (row 5) (col 0)
    (role input)
    (protocol I2C)
    (port "VDD5"       in  power 5.0)   ;; feeds NKE0505SC isolated DC-DC
    (port "VDD3V3_ANA" in  power 3.3)   ;; RP2350 analog reference (non-isolated side)
    (port "GND"        bidi)
    ;; Isolated side (3kV barrier):
    ;;   NKE0505SC → ADP7118-3.3 → VDD3V3_ISO (powers ADS1115, op-amp, muxes, cal EEPROM)
    ;;   ISO1640BDR bridges I2C bus #2 (RP2350 side) to isolated side
    ;; TODO: (instance "U9"  nke0505sc (id ........))     ;; 5V→5V 1W isolated DC-DC, SIP-4
    ;; TODO: (instance "U10" adp7118aujz-3p3 (id ........)) ;; 5V_ISO → 3.3V_ISO low-noise LDO
    ;; TODO: (instance "U11" iso1640bdr (id ........))     ;; ISO1640 I2C isolator, 3kV
    ;; TODO: (instance "U12" ads1115idgsr (id ........))   ;; ADS1115 ADC, isolated side, I2C @ 0x4B
    ;; TODO: (instance "U13" mcp6v51t (id ........))       ;; zero-drift input buffer op-amp
    ;; TODO: (instance "U14" ts5a23159 (id ........))      ;; 2-ch SPDT: routes V or R signal to ADS1115
    ;; TODO: (instance "U15" ts3a5018pwr (id ........))    ;; 4:1 R-range mux (1k/10k/100k reference resistors)
    ;; TODO: (instance "U16" 24aa025uid (id ........))     ;; cal EEPROM, isolated side, I2C @ 0x50
    ;; TODO: voltage divider: 0.1% thin-film 1MΩ + 100kΩ (11:1), ±20V range (±60V optional via HV divider)
    ;; TODO: HV series resistor: CRHV2512AF1004FKE 1MΩ 2512 (primary input protection / HV division)
    ;; TODO: R-mode reference resistors: PTF series 1kΩ/10kΩ/100kΩ 0.1% (ratiometric measurement)
    ;; TODO: PTC fuse MF-R016 (self-resetting input protection)
    ;; TODO: TVS SMAJ33CA (bidirectional clamp)
    ;; TODO: diode clamps BAV199 (low-leakage post-divider clamps)
    ;; TODO: banana jacks: 2x Hirschmann SLB4-G (red + black, floating/isolated, separate from PSU)
    (note "Galvanic isolation: the NKE0505SC creates a separate 5V rail on the isolated side. The ADS1115, op-amp, muxes, and cal EEPROM all run from this isolated rail (regulated to 3.3V by an ADP7118). The ISO1640 bridges I2C bus #2 transparently — the RP2350 reads/writes the isolated I2C devices (ADS1115 @ 0x4B, EEPROM @ 0x50) as if they were on the main bus. 3kV isolation means the DMM probe leads can float safely relative to the instrument chassis.")
    (note "Accuracy target: 3.5-digit (±2 counts), 0.3% DCV at ±20V input range. The ADS1115 has 16-bit resolution (15-bit effective after sign); with the 11:1 input divider and 2.048V FSR PGA setting, the LSB = 2.048V / 32768 × 11 ≈ 0.69mV — adequate for 3.5-digit class. An external reference is NOT needed; the ADS1115 internal 2.048V reference is ±0.1% which contributes <0.1% to the DMM error budget.")
    (note "Resistance measurement: ratiometric. ADS1115 measures voltage across the DUT resistance (R_DUT) and across a precision reference resistor (R_ref, selected by TS3A5018 mux). Ratio R_DUT/R_ref cancels the excitation current accuracy. Three R_ref values (1kΩ/10kΩ/100kΩ) cover 0-~1MΩ with 0.1% accuracy. Higher resistance (1-10MΩ) measured with HV divider + 1MΩ series R, ~0.5% accuracy.")
    (note "Cal EEPROM (24AA025UID @ 0x50, isolated side): stores per-unit offset/gain/zero coefficients for each measurement range, factory cal date, and a unique 48-bit serial number (EUI-48). The RP2350 reads coefficients at boot and applies correction in firmware. A re-cal procedure is exposed via the ESP32-S3 Settings screen."))
  ;; TODO: (sub-block "dmm" (dmm-frontend-isolated))

  ;; -------------------------------------------------------------------------
  ;; PSU Channel 1 — programmable 0-18V / 3A buck-boost, source-only
  ;; -------------------------------------------------------------------------
  (section "Channel 1 PSU (Buck-Boost)" "TPS55289WRYQR buck-boost (I2C1 @ 0x74) + INA228AIDGSR V/I telemetry (0x40) + WSL2512 10mΩ shunt + DMP3056L disconnect FET → banana jacks"
    (row 5) (col 1)
    (role output)
    (protocol I2C)
    (port "VPWR_IN" in  (rated 9.0 24.0))
    (port "VOUT_CH1" out (rated 0.0 18.0))
    (port "GND"      bidi)
    (note "Setpoint commanded by the RP2350 PSU control task over I2C bus #1 @ 0x74. INA228 @ 0x40 does Kelvin-sensed V/I telemetry across the WSL2512 10mΩ shunt at 1 kHz; the RP2350 PI loop closes around this measurement. DMP3056L P-FET gives a true 0V off state and reverse-polarity protection on the banana-jack output.")
    (note "Hardware OCP: <50us from threshold to foldback, <1ms total to safe state. Both PSU channels are also cut instantly by the emergency stop (abort) button, which directly pulls both TPS55289 ENABLE lines low via a dedicated hardware path — bypasses software entirely.")
    (note "Source-only (no current sink). 4.7uH Wurth 74438336047 inductor + 2x 22uF/35V 1210 X7R output caps per the TPS55289 EVM."))
  ;; TODO: (sub-block "psu1" (psu-channel 1))

  ;; -------------------------------------------------------------------------
  ;; PSU Channel 2 — second independent programmable channel
  ;; -------------------------------------------------------------------------
  (section "Channel 2 PSU (Buck-Boost)" "TPS55289WRYQR buck-boost (I2C1 @ 0x75) + INA228AIDGSR V/I telemetry (0x41) + WSL2512 10mΩ shunt + DMP3056L disconnect FET → banana jacks"
    (row 5) (col 2)
    (role output)
    (protocol I2C)
    (port "VPWR_IN"  in  (rated 9.0 24.0))
    (port "VOUT_CH2" out (rated 0.0 18.0))
    (port "GND"      bidi)
    (note "Identical to Channel 1 but on I2C bus #1 @ 0x75 / INA228 @ 0x41. Two channels are fully independent — separate RP2350 PIO instances, separate setpoints, separate OCP.")
    (note "A third INA228 @ 0x44 on I2C bus #1 monitors VPWR_IN (after the ideal diode OR) for source-voltage droop detection and telemetry."))
  ;; TODO: (sub-block "psu2" (psu-channel 2))

  ;; -------------------------------------------------------------------------
  ;; DUT Bank Power — programmable 1.8/2.5/3.3V VCCIO for DUT banks A & B
  ;; -------------------------------------------------------------------------
  (section "DUT Bank Power" "2x TLV62568DBVR adjustable buck + 2x MCP4726A0T DAC (I2C2 @ 0x60 / 0x61) + 2x INA260AIPWR V/I monitor (0x45 / 0x46) — generates VDD_BANK_A / VDD_BANK_B"
    (row 6) (col 0)
    (role output)
    (protocol I2C)
    (port "VDD5"       in  power 5.0)
    (port "VDD_BANK_A" out (rated 1.8 3.3))
    (port "VDD_BANK_B" out (rated 1.8 3.3))
    (port "GND"        bidi)
    (note "Each bank: TLV62568 adjustable buck with FB pin steered by an MCP4726 single-channel 12-bit I2C DAC. RP2350 commands the DAC over I2C bus #2; software snaps to 1.8/2.5/3.3V canonical setpoints.")
    (note "Per-bank INA260 (0x45 / 0x46) reports actual rail voltage and current drawn by the DUT. Combined with digital readback from the RP2350 PIO pin_monitor, this gives two independent layers of DUT activity detection.")
    (note "Both banks feed both DUT connectors simultaneously; the LSF0108 level shifters reference VDD_BANK_A/B on the DUT side. The RP2350 connector_mux PIO register selects which connector's pins are sampled/driven."))
  ;; TODO: (sub-block "bank_a" (bank-rail "A"))
  ;; TODO: (sub-block "bank_b" (bank-rail "B"))

  ;; -------------------------------------------------------------------------
  ;; UX & Indicators — encoder, abort button, buzzer, NeoPixel chain, PSU LEDs
  ;; -------------------------------------------------------------------------
  (section "UX & Indicators" "Bourns PEC11R encoder + large red illuminated abort button (N.C.) + TDK PS1240 piezo + 5x WS2812B-2020 NeoPixel chain + 2x green PSU ON LEDs — all RP2350-driven from main digital rail"
    (row 6) (col 1)
    (role output)
    (port "VDD3V3" in power 3.3)
    (port "VDD5"   in power 5.0)
    (port "GND"    bidi)
    ;; TODO: (instance "ENC1" pec11r-4215f (id ........))        ;; rotary encoder, quadrature + push
    ;; TODO: (instance "BTN1" abort-button  (id ........))        ;; N.C. contacts: one path → RP2350 GPIO (abort-sense); one path hard-wired to cut TPS55289 ENABLE lines
    ;; TODO: (instance "BZ1"  piezo-ps1240  (id ........))        ;; piezo buzzer
    ;; Buzzer drive FET (2N7002 N-ch, low-side switch)
    (instance "Q1" 2n7002
      (pin 1 "BUZZER_PWM")   ;; gate → RP2350 GPIO (PIO PWM)
      (pin 2 "GND")          ;; source
      (pin 3 "BZ1_NEG") (id a6780cf6))     ;; drain → buzzer negative terminal
    ;; Gate pull-down (keeps FET off during RP2350 boot before GPIO is driven)
    (instance "R26" (res-0402 "100k") (pin 1 "BUZZER_PWM") (pin 2 "GND") (id a3d616f2))
    ;; Gate series resistor (damps ringing on Ciss)
    (instance "R27" (res-0402 "100R") (pin 1 "BUZZER_PWM_MCU") (pin 2 "BUZZER_PWM") (id bd3c8ddd))
    ;; TODO: 5x WS2812B-2020 NeoPixel chain — single data wire from RP2350 PIO, daisy-chained
    ;; PSU channel "ON" LEDs (green, 0603, driven by TPS55289 ENABLE signal via current-limiting R)
    (instance "LED1" (led-0402 "green") (pin 1 "VOUT_CH1_LED") (pin 2 "GND") (id abd1b5ae))   ;; PSU CH1 ON indicator
    (instance "LED2" (led-0402 "green") (pin 1 "VOUT_CH2_LED") (pin 2 "GND") (id f089b02d))   ;; PSU CH2 ON indicator
    (instance "R28" (res-0402 "1k")  (pin 1 "PSU1_EN") (pin 2 "VOUT_CH1_LED") (id cf70b69c))
    (instance "R29" (res-0402 "1k")  (pin 1 "PSU2_EN") (pin 2 "VOUT_CH2_LED") (id b644bbf7))
    (note "Emergency abort button: illuminated red tactile with N.C. contacts. TWO parallel signal paths: (1) digital path → RP2350 GPIO so software can detect abort and update the UI; (2) direct hardware path pulls both TPS55289 ENABLE lines low through a diode — no software involvement, no propagation delay, cannot be disabled by a software fault or MCU lockup. The RP2350 monitors this pin and logs the event; the ESP32-S3 displays an abort overlay on the touchscreen.")
    (note "Rotary encoder is directly connected to the RP2350 (two quadrature GPIOs + push switch), decoded in firmware. Fine voltage/current adjustment without the touchscreen — useful when wearing gloves or for rapid numeric entry. Encoder push confirms numeric keypad selection.")
    (note "NeoPixel chain: 5x WS2812B-2020 — system-status RGB bar. The RP2350 drives the single-wire protocol via PIO (timing-exact). LED 1: power state; LED 2: PSU CH1; LED 3: PSU CH2; LED 4: DMM; LED 5: LA/trigger. The ESP32-S3 can also request specific patterns over SPI."))

  ;; -------------------------------------------------------------------------
  ;; Housekeeping Sensors — RTC, temps, I2C I/O expander (Pi I2C2)
  ;; -------------------------------------------------------------------------
  (section "Housekeeping Sensors" "DS3231SN MEMS RTC (I2C2 @ 0x68, CR2032 backup) + 3x TMP1075 temps (0x48/0x49/0x4A) + TCA9555PWR 16-bit I/O expander (0x20) — all on RP2350 I2C bus #2 @ 400 kHz"
    (row 6) (col 2)
    (role input)
    (protocol I2C)
    (port "VDD3V3" in power 3.3)
    (port "GND"    bidi)
    ;; TODO: (instance "U17" ds3231sn (id ........))          ;; RTC SOIC-16, I2C @ 0x68, CR2032 VBAT
    ;; TODO: (instance "U18" tmp1075ndrlr (id ........))      ;; temp sensor #1, near TPS55289 #1
    ;; TODO: (instance "U19" tmp1075ndrlr (id ........))      ;; temp sensor #2, near TPS55289 #2
    ;; TODO: (instance "U20" tmp1075ndrlr (id ........))      ;; temp sensor #3, near RP2350
    ;; TODO: (instance "U21" tca9555pwr (id ........))        ;; I2C I/O expander @ 0x20
    ;; TODO: RTC battery: CR2032 coin cell + holder (preserves DS3231SN time across power-off)
    (note "I2C bus #2 (RP2350 master, housekeeping): I2C1 and I2C2 addresses — 0x20 TCA9555, 0x22 AP33772, 0x45/0x46 INA260 (bank V/I), 0x48/0x49/0x4A TMP1075, 0x4B ADS1115 DMM (isolated via ISO1640), 0x50 cal EEPROM (isolated), 0x60/0x61 MCP4726 (bank DACs), 0x68 DS3231SN RTC.")
    (note "TCA9555 I/O expander (@ 0x20) handles the slower control signals that don't need direct RP2350 GPIO: DMM mode/range selects (TS5A23159 + TS3A5018 control lines), DUT bank VCCIO enable signals, RTC interrupt routing. Frees 6-8 RP2350 GPIOs for latency-sensitive paths.")
    (note "DS3231SN: SOIC-16 (higher-accuracy MEMS variant of DS3231M, ±2ppm). Backed by CR2032 coin cell — clock continues through full power-off cycles. Critical for timestamped LA captures in offline/portable use. RP2350 reads time at boot and sets the software RTC; subsequent captures use the software counter synced at boot.")
    (note "TMP1075 placements: #1 adjacent to TPS55289 #1, #2 adjacent to TPS55289 #2, #3 adjacent to RP2350. The RP2350 reads all three at 1 Hz; if any zone exceeds 70°C, the PSU channels are throttled and the abort button LED flashes amber."))

  ;; -------------------------------------------------------------------------
  ;; Bring-up & Debug — Tag-Connect SWD footprint (RP2350 SWD + UART)
  ;; -------------------------------------------------------------------------
  (section "Bring-up & Debug" "Tag-Connect TC2030-IDC-NL footprint — RP2350 SWD (SWCLK/SWDIO) + UART0 (TX/RX) + 3.3V + GND — no connector, spring-pin cable mates directly with pads"
    (row 7) (col 0)
    (port "VDD3V3" in power 3.3)
    (port "GND"    bidi)
    ;; TODO: (instance "DBG1" connector-swd-6 (id ........))   ;; TC2030 footprint pads
    (note "Tag-Connect TC2030 footprint exposes RP2350 SWD interface (SWCLK/SWDIO) + UART0 console (TX/RX) + 3.3V + GND for hardware bring-up and gateware debugging. No physical connector is populated in production — the spring-pin cable mates directly with the 6 pads. A 10-pin TC2030 variant that also exposes the USB D+/D- lines is optional (useful for USB protocol debugging before the HOST port is validated)."))

  ;; -------------------------------------------------------------------------
  ;; Test Points — bring-up / debug probe points
  ;; -------------------------------------------------------------------------
  (section "Test Points" "1mm SMD probe points for bring-up and debug"
    (row 7) (col 1)
    ;; TODO: update ref-des IDs once sub-blocks are assigned
    (instance "TP1"  testpoint (pin 1 "VPWR_IN") (id fcd26c97))
    (instance "TP2"  testpoint (pin 1 "VDD5") (id ad25b688))
    (instance "TP3"  testpoint (pin 1 "VDD3V3") (id b4c8ce3b))
    (instance "TP4"  testpoint (pin 1 "VDD3V3_ANA") (id f4023ea5))
    (instance "TP5"  testpoint (pin 1 "VDD3V3_ISO") (id a725b71c))
    (instance "TP6"  testpoint (pin 1 "VDD_BANK_A") (id d971f9f9))
    (instance "TP7"  testpoint (pin 1 "VDD_BANK_B") (id bcc2e94f))
    (instance "TP8"  testpoint (pin 1 "VOUT_CH1") (id f749f34f))
    (instance "TP9"  testpoint (pin 1 "VOUT_CH2") (id a02c6824))
    (instance "TP10" testpoint (pin 1 "GND") (id ffe2d5d3)))

  ;; -------------------------------------------------------------------------
  ;; Mounting — standoffs + assembly fiducials
  ;; -------------------------------------------------------------------------
  (section "Mounting" "4x Wurth M3 SMD standoffs (corner positions) + 3x assembly fiducials"
    (row 7) (col 2)
    (instance "H1"   a-wurth-wa-smsi-9774020633r (pin 1 "GND") (id b17db2a5))
    (instance "H2"   a-wurth-wa-smsi-9774020633r (pin 1 "GND") (id a11c0726))
    (instance "H3"   a-wurth-wa-smsi-9774020633r (pin 1 "GND") (id b70124e5))
    (instance "H4"   a-wurth-wa-smsi-9774020633r (pin 1 "GND") (id b952f047))
    (instance "FID1" fiducial-0p75-2p25 (id d772400f))
    (instance "FID2" fiducial-0p75-2p25 (id ebde1d46))
    (instance "FID3" fiducial-0p75-2p25 (id bbe4e4bd)))

  ;; ==========================================================================
  ;; Power chain (case 4: rail-only blocks — top-level sub-blocks, no section)
  ;; ==========================================================================
  ;;
  ;; VPWR_IN = ideal-diode OR of USB-C POWER port (AP33772 PD, up to 20V)
  ;;           and DC barrel jack (9-24V, panel supply)
  ;;
  ;; VPWR_IN ─┬─► TPS55289 #1 ──► VOUT_CH1 (0-18V/3A) ──► banana jacks (red/black pair)
  ;;          ├─► TPS55289 #2 ──► VOUT_CH2 (0-18V/3A) ──► banana jacks (red/black pair)
  ;;          └─► TPS62933 #1 ──► +5V_SYS (3A continuous)
  ;;                               │
  ;;                               ├─► TPS62933 #2 ──► +3V3_SYS (RP2350, ESP32-S3, digital)
  ;;                               │                     └── ADP7118 ──► +3V3_ANA (RP2350 analog ref)
  ;;                               ├─► NKE0505SC ──► VDD5_ISO ──► ADP7118 ──► +3V3_ISO (DMM isolated)
  ;;                               ├─► TLV62568 #1 (+ MCP4726 #1) ──► VDD_BANK_A (1.8/2.5/3.3V)
  ;;                               └─► TLV62568 #2 (+ MCP4726 #2) ──► VDD_BANK_B (1.8/2.5/3.3V)
  ;;
  ;; USB-C HOST port 5V ──► LM66100 ideal diode ──► +5V_SYS (digital-only fallback)
  ;; CR2032 coin cell (~3V) ──► DS3231SN VBAT (preserves time across power-off)
  ;;
  ;; TODO: (sub-block "or_vpwr"  (ideal-diode-or))    ;; 2x LM66100: USB-C POWER VBUS + barrel jack → VPWR_IN
  ;; TODO: (sub-block "or_5v"    (ideal-diode))        ;; LM66100: USB-C HOST 5V → +5V_SYS
  ;; TODO: (sub-block "buck_5v"  (system-buck 20.0 5.0))  ;; VPWR_IN → 5V, 3A
  ;; TODO: (sub-block "buck_3v3" (system-buck 5.0 3.3))   ;; 5V → 3V3 digital
  ;; TODO: (sub-block "ldo_ana"  (analog-ldo 3.3))         ;; 5V → 3V3 analog (ADP7118)
  ;; TODO: (sub-block "buck_5v_iso" (system-buck 5.0 5.0)) ;; NKE0505SC 1W isolated DC-DC (internal to dmm sub-block)
  ;; TODO: (sub-block "ldo_iso"  (analog-ldo 3.3))         ;; 5V_ISO → 3V3_ISO for DMM isolated side (internal to dmm)

  ;; ==========================================================================
  ;; Rail nets — one consolidated (net ...) per rail
  ;; ==========================================================================
  ;; TODO: (net "GND"          ...)
  ;; TODO: (net "VPWR_IN"      "or_vpwr/VOUT" "psu1/VPWR_IN" "psu2/VPWR_IN" "buck_5v/VIN" "usbc_pwr/VPWR_IN")
  ;; TODO: (net "VDD5"         "buck_5v/VOUT" "or_5v/VOUT" "buck_3v3/VIN" "ldo_ana/VIN" "bank_a/VIN" "bank_b/VIN" "ux/VDD5" "dmm/VDD5")
  ;; TODO: (net "VDD3V3"       "buck_3v3/VOUT" "mcu/VDD3V3" "esp32/VDD3V3" "display/VDD3V3" "lev_shift/VDD3V3" "ux/VDD3V3" "housekeeping/VDD3V3" "trigger/VDD3V3")
  ;; TODO: (net "VDD3V3_ANA"   "ldo_ana/VOUT" "dmm/VDD3V3_ANA")
  ;; TODO: (net "VDD3V3_ISO"   internal to dmm sub-block)
  ;; TODO: (net "VDD_BANK_A"   "bank_a/VOUT" "lev_shift/VDD_BANK_A" "dut_fixture/VDD_BANK_A" "dut_bench/VDD_BANK_A")
  ;; TODO: (net "VDD_BANK_B"   "bank_b/VOUT" "lev_shift/VDD_BANK_B" "dut_fixture/VDD_BANK_B" "dut_bench/VDD_BANK_B")
  ;; TODO: (net "VOUT_CH1"     "psu1/VOUT" "dut_fixture/VOUT_CH1")
  ;; TODO: (net "VOUT_CH2"     "psu2/VOUT" "dut_fixture/VOUT_CH2")

  ;; -------------------------------------------------------------------------
  ;; Design boundary ports
  ;; -------------------------------------------------------------------------
  (port "VBUS_USBC_HOST"  in (rated 4.5 5.5))   ;; USB-C HOST port VBUS (5V, data+power)
  (port "VBUS_USBC_POWER" in (rated 4.5 5.5))   ;; USB-C POWER port VBUS (pre-PD negotiation)
  (port "VPWR_BARREL"     in (rated 9.0 24.0))   ;; DC barrel jack input (9-24V)
  (port "GND"             bidi)

)
