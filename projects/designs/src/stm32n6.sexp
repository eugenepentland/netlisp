(import stm32n657l0h3q)
(import cap-0201)
(import cap-0402)
(import cap-0402-np0)
(import cap-0402-x7r)
(import cap-0805)
(import res-0402)
(import ind-2016)
(import crystal)
(import esd-usb)
(import led-0402)
(import connector-swd)
(import amphenol-10164986)

(design-block "STM32N657L0H3Q Minimal Schematic"

  ;; Grid layout
  (section "VDD Power"          (row 0) (col 0))
  (section "SMPS Power"         (row 0) (col 1))
  (section "Analog & I/O Rails" (row 1) (col 0))
  (section "Boot & Reset"       (row 1) (col 1))
  (section "SWD Debug"          (row 2) (col 0))
  (section "HSE (Main Clock)"   (row 2) (col 1))
  (section "LSE (RTC Clock)"    (row 3) (col 0))
  (section "USB"                (row 3) (col 1))

  ;; ============================================================
  ;; MCU Instance
  ;; ============================================================
  (instance "U1" stm32n657l0h3q

    (part "VDD Power" (row 0) (col 0)
      (pin 1 2 3 4 5 "VDD")
      (pin 26 "VBAT")
      (pin 15 "VDDA18AON")
      (pin 27 28 29 30 31 32 33 34 35 36 37 38 39 40 "GND"))

    (part "SMPS" (row 0) (col 1)
      (pin 16 "VDDA18PMU")
      (pin 12 "VDDSMPS")
      (pin 13 "VLXSMPS")
      (pin 14 "VFBSMPS")
      (pin 41 "VSSSMPS")
      (pin 6 7 8 9 10 11 "VDDCORE")
      (pin 23 "VDDCSI"))

    (part "Analog & IO" (row 1) (col 0)
      (pin 17 "VDDA18PLL")
      (pin 19 "VDDA18ADC")
      (pin 25 "VREF+")
      (pin 20 "VDDIO2")
      (pin 21 "VDDIO3")
      (pin 24 "V08CAP"))

    (part "System" (row 1) (col 1)
      (pin 42 "NRST")
      (pin 43 "PDR_ON")
      (pin 44 "BOOT0")
      (pin 45 "PA6")
      (pin 55 "PG10"))

    (part "SWD Debug" (row 2) (col 0)
      (pin 46 "PA13")
      (pin 47 "PA14"))

    (part "HSE" (row 2) (col 1)
      (pin 48 "OSC_IN")
      (pin 49 "OSC_OUT"))

    (part "LSE" (row 3) (col 0)
      (pin 50 "OSC32_IN")
      (pin 51 "OSC32_OUT"))

    (part "USB" (row 3) (col 1)
      (pin 18 "VDDA18USB")
      (pin 22 "VDD33USB")
      (pin 52 "USB_DP")
      (pin 53 "USB_DM")
      (pin 54 "TXRTUNE")))

  ;; ============================================================
  ;; Section 1: Power Supply Decoupling
  ;; ============================================================

  ;; --- VDD: 100nF per pin (5 pins) ---
  (instance "C1" (cap-0402 "100nF")
    (pin 1 "VDD")
    (pin 2 "GND"))
  (instance "C2" (cap-0402 "100nF")
    (pin 1 "VDD")
    (pin 2 "GND"))
  (instance "C3" (cap-0402 "100nF")
    (pin 1 "VDD")
    (pin 2 "GND"))
  (instance "C4" (cap-0402 "100nF")
    (pin 1 "VDD")
    (pin 2 "GND"))
  (instance "C5" (cap-0402 "100nF")
    (pin 1 "VDD")
    (pin 2 "GND"))

  ;; --- VDDCORE: 1uF per pin (6 pins) ---
  (instance "C6" (cap-0201 "1uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C7" (cap-0201 "1uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C8" (cap-0201 "1uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C9" (cap-0201 "1uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C10" (cap-0201 "1uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C11" (cap-0201 "1uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))

  ;; --- VDDSMPS: 2x10uF + 2x1uF + 2x100nF ---
  (instance "C12" (cap-0805 "10uF")
    (pin 1 "VDDSMPS")
    (pin 2 "GND"))
  (instance "C13" (cap-0805 "10uF")
    (pin 1 "VDDSMPS")
    (pin 2 "GND"))
  (instance "C14" (cap-0402 "1uF")
    (pin 1 "VDDSMPS")
    (pin 2 "GND"))
  (instance "C15" (cap-0402 "1uF")
    (pin 1 "VDDSMPS")
    (pin 2 "GND"))
  (instance "C16" (cap-0402 "100nF")
    (pin 1 "VDDSMPS")
    (pin 2 "GND"))
  (instance "C17" (cap-0402 "100nF")
    (pin 1 "VDDSMPS")
    (pin 2 "GND"))

  ;; --- VLXSMPS: 1uH inductor + RC snubber + 4x15uF output ---
  (instance "L1" (ind-2016 "1uH")
    (pin 1 "VLXSMPS")
    (pin 2 "VDDCORE"))
  (instance "C18" (cap-0402-x7r "2.2nF")
    (pin 1 "VLXSMPS")
    (pin 2 "SNUB1"))
  (instance "R1" (res-0402 "2R")
    (pin 1 "SNUB1")
    (pin 2 "GND"))
  (instance "C19" (cap-0805 "15uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C20" (cap-0805 "15uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C21" (cap-0805 "15uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))
  (instance "C22" (cap-0805 "15uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))

  ;; --- VFBSMPS: short to VDDCORE ---
  ;; (VFBSMPS pin connects directly to VDDCORE net via U1 pin assignment)

  ;; --- Analog 1.8V domains: 100nF each ---
  (instance "C23" (cap-0402 "100nF")
    (pin 1 "VDDA18AON")
    (pin 2 "GND"))
  (instance "C24" (cap-0402 "100nF")
    (pin 1 "VDDA18PMU")
    (pin 2 "GND"))
  (instance "C25" (cap-0402 "100nF")
    (pin 1 "VDDA18PLL")
    (pin 2 "GND"))
  (instance "C26" (cap-0402 "100nF")
    (pin 1 "VDDA18USB")
    (pin 2 "GND"))
  (instance "C27" (cap-0402 "100nF")
    (pin 1 "VDDA18ADC")
    (pin 2 "GND"))

  ;; --- VDDIO2, VDDIO3: 100nF each ---
  (instance "C28" (cap-0402 "100nF")
    (pin 1 "VDDIO2")
    (pin 2 "GND"))
  (instance "C29" (cap-0402 "100nF")
    (pin 1 "VDDIO3")
    (pin 2 "GND"))

  ;; --- VDD33USB: 1uF ---
  (instance "C30" (cap-0402 "1uF")
    (pin 1 "VDD33USB")
    (pin 2 "GND"))

  ;; --- VDDCSI: 1uF (to VDDCORE net) ---
  (instance "C31" (cap-0201 "1uF")
    (pin 1 "VDDCORE")
    (pin 2 "GND"))

  ;; --- V08CAP: 4.7uF ---
  (instance "C32" (cap-0402 "4.7uF")
    (pin 1 "V08CAP")
    (pin 2 "GND"))

  ;; --- VREF+: 1uF + 100nF ---
  (instance "C33" (cap-0402 "1uF")
    (pin 1 "VREF+")
    (pin 2 "GND"))
  (instance "C34" (cap-0402 "100nF")
    (pin 1 "VREF+")
    (pin 2 "GND"))

  ;; --- VBAT: tied to VDD ---
  ;; (VBAT pin is on VDD net via U1 pin assignment - see note)

  ;; ============================================================
  ;; Section 2: System Pins
  ;; ============================================================

  ;; NRST: 100nF to GND
  (instance "C35" (cap-0402 "100nF")
    (pin 1 "NRST")
    (pin 2 "GND"))

  ;; PDR_ON: connect to VDDA18AON
  ;; (PDR_ON pin assigned to VDDA18AON net in U1 instance)

  ;; BOOT0: 10k pull-down
  (instance "R2" (res-0402 "10k")
    (pin 1 "BOOT0")
    (pin 2 "GND"))

  ;; BOOT1 (PA6): 10k pull-down
  (instance "R3" (res-0402 "10k")
    (pin 1 "BOOT1")
    (pin 2 "GND"))

  ;; ============================================================
  ;; Section 3: SWD Debug
  ;; ============================================================

  ;; PA13 (SWDIO): 33R series resistor
  (instance "R4" (res-0402 "33R")
    (pin 1 "SWDIO_MCU")
    (pin 2 "SWDIO"))

  ;; PA14 (SWCLK): 33R series resistor
  (instance "R5" (res-0402 "33R")
    (pin 1 "SWCLK_MCU")
    (pin 2 "SWCLK"))

  ;; SWD connector
  (instance "J1" connector-swd
    (row 2) (col 0)
    (pin 1 "SWDIO")
    (pin 2 "SWCLK")
    (pin 3 "SWO")
    (pin 4 "VDD")
    (pin 5 "GND"))

  ;; ============================================================
  ;; Section 4: HSE Crystal
  ;; ============================================================

  (instance "Y1" crystal
    (row 2) (col 1)
    (pin 1 "OSC_IN")
    (pin 2 "OSC_OUT"))
  (instance "C36" (cap-0402-np0 "20pF")
    (pin 1 "OSC_IN")
    (pin 2 "GND"))
  (instance "C37" (cap-0402-np0 "20pF")
    (pin 1 "OSC_OUT")
    (pin 2 "GND"))

  ;; ============================================================
  ;; Section 5: LSE Crystal
  ;; ============================================================

  (instance "Y2" crystal
    (row 3) (col 0)
    (pin 1 "OSC32_IN")
    (pin 2 "OSC32_OUT"))
  (instance "C38" (cap-0402-np0 "6.8pF")
    (pin 1 "OSC32_IN")
    (pin 2 "GND"))
  (instance "C39" (cap-0402-np0 "6.8pF")
    (pin 1 "OSC32_OUT")
    (pin 2 "GND"))

  ;; ============================================================
  ;; Section 6: USB
  ;; ============================================================

  ;; ESD protection filter
  (instance "U2" esd-usb
    (row 3) (col 1)
    (pin 1 "USB_DP")
    (pin 2 "USB_DM")
    (pin 3 "USB_DP_CONN")
    (pin 4 "USB_DM_CONN"))

  ;; USB-C connector (Amphenol 10164986-00011LF)
  ;; Pin mapping: 1=A1(GND) 4=A4(VBUS) 5=A5(CC1) 6=A6(D+) 7=A7(D-)
  ;;              9=A9(VBUS) 12=A12(GND) 13=B1(GND) 16=B4(VBUS) 17=B5(CC2)
  ;;              18=B6(D+) 19=B7(D-) 21=B9(VBUS) 24=B12(GND) 25-28=SHIELD
  (instance "J2" amphenol-10164986
    (row 3) (col 1)
    (pin 1 12 13 24 "GND")
    (pin 4 9 16 21 "VBUS")
    (pin 5 "CC1")
    (pin 17 "CC2")
    (pin 6 18 "USB_DP_CONN")
    (pin 7 19 "USB_DM_CONN")
    (pin 25 26 27 28 "GND"))

  ;; CC pull-down resistors (for device mode)
  (instance "R6" (res-0402 "5.1k")
    (pin 1 "CC1")
    (pin 2 "GND"))
  (instance "R7" (res-0402 "5.1k")
    (pin 1 "CC2")
    (pin 2 "GND"))

  ;; TXRTUNE: 200R 1% to GND
  (instance "R8" (res-0402 "200R")
    (pin 1 "TXRTUNE")
    (pin 2 "GND"))

  ;; ============================================================
  ;; Section 7: Debug LED
  ;; ============================================================

  (instance "R9" (res-0402 "330R")
    (pin 1 "LED_ANODE")
    (pin 2 "LED_NET"))
  (instance "D1" (led-0402 "green")
    (pin 1 "LED_NET")
    (pin 2 "GND"))

  ;; ============================================================
  ;; Net Assignments (aliases for MCU pin connections)
  ;; ============================================================

  ;; VFBSMPS shorted to VDDCORE
  (net-tie "VFBSMPS" "VDDCORE")

  ;; VBAT tied to VDD
  (net-tie "VBAT" "VDD")

  ;; PDR_ON connected to VDDA18AON
  (net-tie "PDR_ON" "VDDA18AON")

  ;; VDDCSI powered from VDDCORE
  (net-tie "VDDCSI" "VDDCORE")

  ;; BOOT1 is PA6
  (net-tie "BOOT1" "PA6")

  ;; SWD MCU-side nets
  (net-tie "SWDIO_MCU" "PA13")
  (net-tie "SWCLK_MCU" "PA14")

  ;; Debug LED driven from PG10
  (net-tie "LED_ANODE" "PG10")

  ;; VSSSMPS to GND
  (net-tie "VSSSMPS" "GND")

  ;; ============================================================
  ;; Ports (external connections)
  ;; ============================================================

  (port "VDD"       "VDD"       in  (rated 3.0 3.6))
  (port "VDDCORE"   "VDDCORE"   in  (rated 0.78 0.95))
  (port "VDDSMPS"   "VDDSMPS"   in  (rated 1.62 3.6))
  (port "VDDA18AON" "VDDA18AON" in  (rated 1.62 1.98))
  (port "VDDA18PMU" "VDDA18PMU" in  (rated 1.62 1.98))
  (port "VDDA18PLL" "VDDA18PLL" in  (rated 1.62 1.98))
  (port "VDDA18USB" "VDDA18USB" in  (rated 1.62 1.98))
  (port "VDDA18ADC" "VDDA18ADC" in  (rated 1.62 1.98))
  (port "VDDIO2"    "VDDIO2"    in  (rated 1.62 3.6))
  (port "VDDIO3"    "VDDIO3"    in  (rated 1.62 3.6))
  (port "VDD33USB"  "VDD33USB"  in  (rated 3.0 3.6))
  (port "VREF+"     "VREF+"     in  (rated 1.62 3.6))
  (port "VBUS"      "VBUS"      in  (rated 4.0 5.5))
  (port "GND"       "GND"       bidi)

  ;; ============================================================
  ;; Notes
  ;; ============================================================

  (note "U1" "STM32N657L0H3Q VFBGA223, ARM Cortex-M55 800MHz")
  (note "L1" "1uH SMPS inductor, >1A saturation current required")
  (note "R1" "Snubber resistor for VLXSMPS switching node")
  (note "C18" "Snubber cap for VLXSMPS, X7R dielectric")
  (note "Y1" "HSE crystal, 8-25MHz range per datasheet")
  (note "Y2" "32.768kHz LSE crystal")
  (note "U2" "ECMF02-2AMX6 USB ESD filter, place close to connector")
  (note "R8" "TXRTUNE 200R 1% sets USB HS driver impedance")
  (note "C32" "V08CAP internal regulator output capacitor, 4.7uF required")

  ;; ============================================================
  ;; Groups (visual organization)
  ;; ============================================================

  (group "VDD Decoupling" ("C1" "C2" "C3" "C4" "C5"))
  (group "VDDCORE Decoupling" ("C6" "C7" "C8" "C9" "C10" "C11"))
  (group "SMPS Input" ("C12" "C13" "C14" "C15" "C16" "C17"))
  (group "SMPS Output" ("L1" "C18" "R1" "C19" "C20" "C21" "C22"))
  (group "Analog 1.8V Decoupling" ("C23" "C24" "C25" "C26" "C27"))
  (group "IO Decoupling" ("C28" "C29" "C30" "C31"))
  (group "V08CAP / VREF+" ("C32" "C33" "C34"))
  (group "System Pins" ("C35" "R2" "R3"))
  (group "SWD Debug" ("R4" "R5" "J1"))
  (group "HSE Crystal" ("Y1" "C36" "C37"))
  (group "LSE Crystal" ("Y2" "C38" "C39"))
  (group "USB" ("U2" "J2" "R6" "R7" "R8"))
  (group "Debug LED" ("R9" "D1")))
