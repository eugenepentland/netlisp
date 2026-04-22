(import stm32n657l0h3q
        cap-0201 cap-0402 cap-0603 cap-0805
        res-0402 ind-1616 ind-2016 led-0402 ferrite-0402
        abm8 fc-135 ecmf02-2amx6 usb4235-03-c
        mx66uw1g45gxdi00 aps256xxn-ob9-bg diode-0402
        icm-20948 204928-0301
        res-0201
        ad7380-4bcpz
        aptf1616lseezgkqbkc
        a-wurth-wa-smsi-9774020633r
        connector-swd connector-battery
        testpoint)

(design-block "Cyclops Digital"

  (instance "stm32" stm32n657l0h3q (id b22d91d5))

  (section "STM32N657L0H3Q" "ARM Cortex-M55 MCU"
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "NRST" out signal role reset)

    (section "VDD Power"
      (pins "stm32"
        (pin J14 K14 L14 "VDD")
        (pin F1 "VDD")
        (pin H6 "VDDA18AON")
        (pin A19 F12 H14 N16 P8 P12 P14 W1 W19 "GND")
        (pin N6 "VSSA")
        (pin G6 "VSSAON")
        (pin H2 "VSSAPMU"))
      (decouple (cap-0201 "100nF") 1 per-pin stm32 "VDD" "VDDA18AON" (id f619c531))
      (net "GND" "VSSA" "VSSAON" "VSSAPMU")
      (note "F1 (VBAT) tied to VDD — LiPo 4.2V exceeds VBAT max (3.6V), so backup domain only active when VDD is up"))

    (section "SMPS Power" "Internal 0.8V core regulator"
      (port "VDD" in power 3.3)
      (port "VDDCORE" out power 0.8)
      (pins "stm32"
        (pin H1 "VDDA18PMU")
        (pin L1 L2 L3 L4 L5 "VDDSMPS")
        (pin K1 K2 K3 K4 K5 "VLXSMPS")
        (pin G2 "VDDCORE")
        (pin J1 J2 J3 J4 J5 "VSSSMPS")
        (pin P7 P9 P10 P11 P13 "VDDCORE")
        (pin W6 "VDDCORE")
        (pin G4 "PWR_ON"))
      (net "GND" "VSSSMPS")
      (decouple "VDDCORE" (cap-0603 "15uF") 4 per-pin stm32 P7 (id cfc02418))
      (decouple "VDDCORE" (cap-0201 "1uF") 1 per-pin stm32 (id f1113d21))
      (decouple "VDDSMPS" (cap-0603 "10uF")  2 per-pin stm32 L1 (id e05df5aa))
      (decouple "VDDSMPS" (cap-0201 "1uF")   2 per-pin stm32 L1 (id a741dad6))
      (decouple "VDDSMPS" (cap-0201 "100nF")  2 per-pin stm32 L1 (id c4293f16))
      (series "L1" (ind-2016 "1uH") "VLXSMPS" "VDDCORE" (id f130c61b))
      (series "C18" (cap-0402 "2.2nF" x7r) "VLXSMPS" "SNUB1" (id aa2c3eda))
      (series "R1" (res-0402 "2R") "SNUB1" "GND" (id fbbc4c8b))
      (decouple "VDDA18PMU" (cap-0201 "100nF") 1 per-pin stm32 (id ee3d56f0))
      (series "R2" (res-0201 "10k") "PWR_ON" "VDDSMPS" (id f2a0c001))
      (note "G2 (VFBSMPS) tied to VDDCORE — SMPS feedback sense (AN5967 Fig 4)")
      (note "W6 (VDDCSI) tied to VDDCORE per AN5967 section 3.2")
      (note "G4 (PWR_ON) pulled to VDDSMPS via 10k — enables SMPS at power-up (AN5967 Table 5)"))

    (section "Analog & I/O Rails"
      (port "V1P8" in power 1.8)
      (port "VDD" in power 3.3)
      (pins "stm32"
        (pin M6 "VDDA18PLL")
        (pin P6 "VDDA18ADC")
        (pin V6 "VDDA18CSI")
        (pin W2 "VREF+")
        (pin V2 "VSSA")
        (pin H16 J16 K16 L16 "VDDIO2")
        (pin M14 M16 "VDDIO3")
        (pin F7 F8 "VDDIO4")
        (pin G1 "V08CAP"))
      (decouple (cap-0201 "100nF") 1 per-pin stm32
        "VDDIO2" "VDDIO3" "VDDIO4" (id bf344845))
      ;; Analog 1.8V: caps on filtered side of ferrite beads (no per-pin split)
      (series (cap-0201 "100nF") "VDDA18PLL" "GND" "VDDA18USB" "GND" "VDDA18ADC" "GND" "VDDA18CSI" "GND" (id bf344846))
      (decouple "VDD33USB" (cap-0201 "1uF") 1 per-pin stm32 (id c6c9160e))
      (decouple "VDDCORE" (cap-0201 "1uF") 1 per-pin stm32 W6 (id e50059e2))
      (decouple "V08CAP" (cap-0603 "4.7uF") 1 per-pin stm32 (id b897a15f))
      (decouple "VREF+" (cap-0201 "1uF")   1 per-pin stm32 (id e4c292f6))
      (decouple "VREF+" (cap-0201 "100nF") 1 per-pin stm32 (id cf78bc5e)))

    (section "Boot & Reset"
      (port "V1P8" in power 1.8)
      (port "NRST" out signal role reset)
      (pins "stm32"
        (pin F2 "NRST")
        (pin A1 "VDDA18AON")
        (pin F4 "BOOT0")
        (pin T10 "PA6")
        (pin T12 "PG10"))
      (series "C35" (cap-0201 "100nF") "NRST" "GND" (id e0668c9a))
      (series (res-0201 "10k") "BOOT0" "GND" "PA6" "GND" (id d44c84c9))
      (instance "SW1" (res-0402 "0R")
        (pin 1 "NRST")
        (pin 2 "GND") (id f8bfd5d5))
      (note "A1 (PDR_ON) must be tied to VDDA18AON per AN5967 Table 5")
      (note "FW: I/O compensation cells — RAPSRC=0x8, RANSRC=0x7 (AN5967 12.4)")))

  (section "SWD Debug"
    (role output)
    (protocol SWD)
    (port "VDD" in power 3.3)
    (pins "stm32"
      (pin W7 "SWDIO_MCU")
      (pin V7 "SWCLK_MCU")
      (pin T14 "SWO_MCU"))
    (series "R4" (res-0402 "33R") "SWDIO_MCU" "SWDIO" (id f66085ff))
    (series "R5" (res-0402 "33R") "SWCLK_MCU" "SWCLK" (id e624ddcc))
    (series "R6" (res-0402 "33R") "SWO_MCU" "SWO" (id cf985c4e))
    (instance "swd-hdr" connector-swd
      (pin 1 "VDD")
      (pin 2 "SWDIO")
      (pin 3 "SWCLK")
      (pin 4 "SWO")
      (pin 5 "GND") (id c0de5wd5)))

  (section "HSE (Main Clock)" "24 MHz crystal for USB HS PHY"
    (port "V1P8" in power 1.8)
    (port "OSC_IN" out clock)
    (calc "Load capacitors"
      (let cl 10.0)
      (let cstray 5.0)
      (let cload (* 2.0 (- cl cstray))))
    (pins "stm32"
      (pin A5 "OSC_IN")
      (pin B5 "OSC_OUT"))
    (instance "hse" abm8
      (pin X1 "OSC_IN")
      (pin GND_1 GND_2 "GND")
      (pin X2 "OSC_OUT") (id a4b23ed4))
    (series (cap-0402 "10pF" np0) "OSC_IN" "GND" "OSC_OUT" "GND" (id b5986a13)))

  (section "LSE (RTC Clock)" "32.768 kHz crystal"
    (port "V1P8" in power 1.8)
    (port "OSC32_IN" out clock)
    (calc "Load capacitors"
      (let cl 7.0)
      (let cstray 3.0)
      (let cload (* 2.0 (- cl cstray))))
    (pins "stm32"
      (pin E1 "OSC32_IN")
      (pin D1 "OSC32_OUT"))
    (instance "lse" fc-135
      (pin 1 "OSC32_IN")
      (pin 2 "OSC32_OUT") (id b2a39445))
    (series (cap-0402 "6.8pF" np0) "OSC32_IN" "GND" "OSC32_OUT" "GND" (id e6ab5b54)))

  (section "USB" "USB 2.0 High-Speed with Type-C connector (USB4235-03-C)"
    (role input)
    (protocol USB2.0-HS)
    (port "VDDA18USB" in power 1.8)
    (port "VDD33USB" in power 3.3)
    (pins "stm32"
      (pin D4 "VDDA18USB")
      (pin C3 "VDD33USB")
      (pin C1 "USB_DP")
      (pin C2 "USB_DN")
      (pin E2 "TXRTUNE"))
    (instance "usb-esd" ecmf02-2amx6
      (pin D_1 "USB_DP")
      (pin D_2 "USB_DN")
      (pin GND "GND")
      (pin "D-" "USB_CONN_DN")
      (pin "D+" "USB_CONN_DP") (id e6a1a21e))
    (instance "usb-c" usb4235-03-c
      (pin A1 A12 B1 B12 17 18 "GND")
      (pin A4 A9 B4 B9 "VBUS")
      (pin A5 "CC1")
      (pin B5 "CC2")
      (pin A6 B6 "USB_CONN_DP")
      (pin A7 B7 "USB_CONN_DN") (id ca29d420))
    (series (res-0402 "5.1k") "CC1" "GND" "CC2" "GND" (id b9a29bc3))
    (series "R8" (res-0201 "200R") "TXRTUNE" "GND" (id b40b1319))
    (note "5.1k pull-downs on CC1/CC2 for UFP (device) role")
    (note "SBU1 (A8) and SBU2 (B8) left unconnected — unused in USB 2.0 device mode")
    (note "Pins 17/18 are shield/shell GND (mid-mount tabs)"))

  (section "Debug LED"
    (port "VDD" in power 3.3)
    (series "R9" (res-0402 "330R") "PG10" "LED_NET" (id a4e0a83c))
    (series "D1" (led-0402 "green") "LED_NET" "GND" (id ec5477d8)))

  (section "User RGB LEDs" "2x APTF1616 RGB, common-anode, GPIO-driven (active-low)"
    (port "VDD" in power 3.3)
    (pins "stm32"
      (pin B12 "PD0")
      (pin D12 "PD1")
      (pin B10 "PD2")
      (pin D13 "PD3")
      (pin B13 "PD4")
      (pin A15 "PD5"))
    ;; Current-limit resistors on each cathode leg, sized for ~1.5-2 mA @ 3.3V:
    ;;   Red  (Vf~1.8V): 1k  -> ~1.5 mA
    ;;   Green (Vf~2.8V): 330R -> ~1.5 mA
    ;;   Blue  (Vf~2.8V): 330R -> ~1.5 mA
    (series "R13" (res-0402 "1k")   "PD0" "LED1_R_K" (id aa110001))
    (series "R14" (res-0402 "330R") "PD1" "LED1_G_K" (id aa110002))
    (series "R15" (res-0402 "330R") "PD2" "LED1_B_K" (id aa110003))
    (series "R16" (res-0402 "1k")   "PD3" "LED2_R_K" (id aa110004))
    (series "R17" (res-0402 "330R") "PD4" "LED2_G_K" (id aa110005))
    (series "R18" (res-0402 "330R") "PD5" "LED2_B_K" (id aa110006))
    (instance "LED1" (aptf1616lseezgkqbkc "")
      (pin 1 "VDD")
      (pin 2 "LED1_R_K")
      (pin 3 "LED1_G_K")
      (pin 4 "LED1_B_K") (id aa110010))
    (instance "LED2" (aptf1616lseezgkqbkc "APTF1616LSEEZGKQBKC")
      (pin 1 "VDD")
      (pin 2 "LED2_R_K")
      (pin 3 "LED2_G_K")
      (pin 4 "LED2_B_K") (id aa110011))
    (note "Common anode -> drive GPIO low to light each color. Use TIM PWM channels for dimming/color mixing.")
    (note "PD0-PD5 chosen as a contiguous free block; none conflict with flash, PSRAM, SPI, ADC, or IMU."))

  (section "XSPI2 NOR Flash" "MX66UW1G45G 1Gbit OctoSPI NOR"
    (protocol OctoSPI)
    (port "VDDIO3" in power 1.8)
    (port "NRST" in signal role reset)
    (pins "stm32"
      (pin PN1 "FLASH_NCS")
      (pin PN6 "FLASH_CLK")
      (pin PN0 "FLASH_DQS")
      (bus "FLASH_IO" PN2 PN3 PN4 PN5 PN8 PN9 PN10 PN11))
    (instance "flash" mx66uw1g45gxdi00
      (pin VCC VCCQ__1 VCCQ "VDDIO3")
      (pin GND VSSQ VSSQ__1 "GND")
      (pin "~{CS}" "FLASH_NCS")
      (pin SCLK "FLASH_CLK")
      (pin DQS "FLASH_DQS")
      (bus "FLASH_IO" "SIO")
      (pin "~{RESET}" "FLASH_RESET") (id e5833220))
    (decouple "VDDIO3" (cap-0201 "100nF") 1 per-pin flash (id da033de3))
    (series "R10" (res-0201 "10k") "FLASH_RESET" "VDDIO3" (id c734428e))
    (series "R11" (res-0201 "10k") "FLASH_NCS" "VDDIO3" (id ce543c3a))
    (series "D2" (diode-0402 "PMEG2005AEA") "NRST" "FLASH_RESET" (id ab720208))
    (note "D2: reverse diode NRST->FLASH_RESET for simultaneous reset (AN5967 14.4.3)")
    (note "FW: If VDDIO3=1.8V, set OTP124 bit 15 (HSLV) + PWR_SVMCRx VDDIOxVRSEL"))

  (section "XSPI1 PSRAM" "APS256XXN 256Mbit OctoSPI PSRAM"
    (protocol OctoSPI)
    (port "VDDIO2" in power 1.8)
    (pins "stm32"
      (pin PO0 "PSRAM_NCS")
      (pin PO4 "PSRAM_CLK")
      (pin PO2 "PSRAM_DQS0")
      (pin PO3 "PSRAM_DQS1")
      (bus "PSRAM_IO" PP0 PP1 PP2 PP3 PP4 PP5 PP6 PP7
                      PP8 PP9 PP10 PP11 PP12 PP13 PP14 PP15))
    (instance "psram" aps256xxn-ob9-bg
      (pin VDD_1 VDD_2 "VDDIO2")
      (pin VSS_1 VSS_2 "GND")
      (pin "CE#" "PSRAM_NCS")
      (pin CLK "PSRAM_CLK")
      (pin "DQS/_DM0" "PSRAM_DQS0")
      (pin "DQS/_DM1" "PSRAM_DQS1")
      (bus "PSRAM_IO" "IO") (id f66182fb))
    (decouple "VDDIO2" (cap-0201 "100nF") 1 per-pin psram (id b162a181))
    (series "R12" (res-0201 "10k") "PSRAM_NCS" "VDDIO2" (id bfd3a713))
    (note "FW: If VDDIO2=1.8V, set OTP124 bit 16 (HSLV) + PWR_SVMCRx VDDIOxVRSEL"))

  (section "IMU" "ICM-20948 9-axis IMU via SPI5"
    (protocol SPI)
    (port "VDD" in power 3.3)
    (port "IMU_INT1" out signal role interrupt)
    (port "IMU_FSYNC" in signal role sync)
    (pins "stm32"
      (pin R1 "IMU_SCK")
      (pin P2 "IMU_MOSI")
      (pin W14 "IMU_MISO")
      (pin W13 "IMU_NCS")
      (pin T13 "IMU_INT1")
      (pin V13 "IMU_FSYNC"))
    (instance "imu" icm-20948
      (pin SCLK "IMU_SCK")
      (pin SDI "IMU_MOSI")
      (pin SDO "IMU_MISO")
      (pin nCS "IMU_NCS")
      (pin INT1 "IMU_INT1")
      (pin FSYNC "IMU_FSYNC")
      (pin VDD "VDD")
      (pin VDDIO "VDD")
      (pin REGOUT "IMU_REGOUT")
      (pin GND "GND")
      (pin RESV_20 "GND") (id e8c00656))
    (series (cap-0201 "100nF" x7r) "VDD" "GND" "IMU_REGOUT" "GND" (id d22644cb))
    (note "FW: FSYNC config — DELAY_TIME_EN=1, EXT_SYNC_SET per sensor"))

  (section "Expansion Connector" "Molex SlimStack 204928-0301, 30-pin 0.4mm BTB"
    (role output)
    (protocol SPI)
    (port "VDD" in power 3.3)
    (port "EXP" io data)
    (pins "stm32"
      (pin D6 "EXP_SPI_SCK")
      (pin B6 "EXP_SPI_MISO")
      (pin A6 "EXP_SPI_MOSI")
      (pin W17 "EXP_SPI_NCS"))
    (instance "expansion" 204928-0301
      (pin 1 2 "GND")
      (pin 4 6 8 10 12 "VBATT")
      (pin 3 "EXP_SPI_SCK")
      (pin 5 "EXP_SPI_MISO")
      (pin 7 "EXP_SPI_MOSI")
      (pin 9 "EXP_SPI_NCS")
      (pin 13 14 "GND")
      (pin 16 18 "V1P8")
      (pin 15 "ADF_CH1P")
      (pin 17 "ADF_CH1N")
      (pin 19 20 "GND")
      (pin 21 "ADF_CH2N")
      (pin 22 "GND")
      (pin 23 "ADF_CH2P")
      (pin 24 "GND")
      (pin 25 "ADF_CH3P")
      (pin 26 "GND")
      (pin 27 "ADF_CH3N")
      (pin 28 "ADF_CH4P")
      (pin 29 "GND")
      (pin 30 "ADF_CH4N")
      (pin MP1 MP2 MP3 MP4 "GND") (id b543a309))
    (note "SPI3 routed to expansion: PC10=SCK (D6), PC11=MISO (B6), PC12=MOSI (A6), PA4=NCS (W17). Free of SPI1 (ADC) and SPI5 (IMU) conflicts.")
    (note "MP1–MP4 board-lock tabs tied to GND.")
    (note "ADF differential pairs flanked by GND: pins 14/16 around CH1P(15), 16/18 around CH1N(17), 20/22 around CH2N(21), 22/24 around CH2P(23), 24/26 around CH3P(25), 26 around CH3N(27), 29 between CH4P(28) and CH4N(30)."))

  ;; === Power Chain (design blocks) ===
  ;; VBUS -> charger -> VBATT -> buck -> VDD (3.3V) -> ldo -> V1P8 (1.8V)
  (sub-block "charger" "blocks/charger.sexp")
  (sub-block "buck" "blocks/buck-boost.sexp")
  (sub-block "ldo" "blocks/ldo.sexp")

  ;; Connect power module ports to design nets
  (net "GND" "charger/GND" "buck/GND" "ldo/GND")
  (net "VBUS" "charger/VBUS")
  (net "VBATT" "charger/VBATT" "buck/VIN")
  (net "VDD" "buck/VOUT" "ldo/VIN" "VDDSMPS" "VDD33USB" "VREF+" "VDDIO4")
  (net "PG_3V3" "buck/PG" "ldo/EN")
  (net "V1P8" "ldo/VOUT" "VDDA18PMU" "VDDIO2" "VDDIO3")
  (net "CHG_EN" "charger/EN")

  ;; STM32 GPIO for charger enable control
  (pins "stm32"
    (pin T11 "CHG_EN"))
  ;; 1.8V analog supplies — ferrite bead filtered
  (series "FB1" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18AON" (id a1fb0001))
  (series "FB2" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18PLL" (id a1fb0002))
  (series "FB3" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18USB" (id a1fb0003))
  (series "FB4" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18ADC" (id a1fb0004))
  (series "FB5" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18CSI" (id a1fb0005))

  (section "AD7380-4 ADC" "Quad 16-bit 4Msps simultaneous-sampling SAR ADC with 4-wire SPI"
    (protocol SPI)
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "ADF_CH1P" in differential optional)
    (port "ADF_CH1N" in differential optional)
    (port "ADF_CH2P" in differential optional)
    (port "ADF_CH2N" in differential optional)
    (port "ADF_CH3P" in differential optional)
    (port "ADF_CH3N" in differential optional)
    (port "ADF_CH4P" in differential optional)
    (port "ADF_CH4N" in differential optional)
    (pins "stm32"
      (pin W16 "ADC_CS")
      (pin V10 "ADC_SCK_MCU")
      (pin V15 "ADC_SDI")
      (pin W15 "ADC_SDOA")
      (pin V16 "ADC_SDOB")
      (pin V17 "ADC_SDOC")
      (pin T9  "ADC_SDOD")
      (pin W11 "ADC_SCK_MCU")
      (pin W12 "ADC_SCK_MCU")
      (pin T7  "ADC_SCK_MCU"))
    (instance "adc" ad7380-4bcpz
      ;; Power
      (pin 4 "VDD")
      (pin 2 "V1P8")
      (pin 3 "ADC_REGCAP")
      ;; Reference
      (pin 17 "ADC_REFIN")
      ;; Ground (GND pins + exposed pad)
      (pin 1 5 14 16 25 "GND")
      ;; Analog inputs
      (pin 13 "ADC_AINA_P")
      (pin 12 "ADC_AINA_N")
      (pin 11 "ADC_AINB_P")
      (pin 10 "ADC_AINB_N")
      (pin 9  "ADC_AINC_P")
      (pin 8  "ADC_AINC_N")
      (pin 7  "ADC_AIND_P")
      (pin 6  "ADC_AIND_N")
      ;; Digital (post-series-damping nets at ADC side)
      (pin 18 "ADC_CS")
      (pin 22 "ADC_SCK")
      (pin 21 "ADC_SDI")
      (pin 19 "ADC_SDOA_RAW")
      (pin 20 "ADC_SDOB_RAW")
      (pin 23 "ADC_SDOC_RAW")
      (pin 24 "ADC_SDOD_RAW")
      ;; Pin 15 (DNC) intentionally unmapped — datasheet requires no connection
      (id a7c23d01))
    ;; Power decoupling (1 µF 0201, close to each pin)
    (series "C_VCC"    (cap-0201 "1uF")   "VDD"         "GND" (id a7c23d02))
    (series "C_VLOG"   (cap-0201 "1uF")   "V1P8"        "GND" (id a7c23d03))
    (series "C_REGCAP" (cap-0201 "1uF")   "ADC_REGCAP"  "GND" (id a7c23d04))
    (series "C_REFIN"  (cap-0201 "1uF")   "ADC_REFIN"   "GND" (id a7c23d05))
    ;; Reference: REFIN tied to VDD analog 3.3V (deviation from ADC.md — see note)
    (series "R_REF"    (res-0201 "0R")    "VDD"         "ADC_REFIN" (id a7c23d06))
    ;; Channel A (Rx1) — 33Ω series + 68pF to GND per leg
    (series "R_F1P" (res-0201 "33R")   "ADF_CH1P"   "ADC_AINA_P" (id a7c23d10))
    (series "R_F1N" (res-0201 "33R")   "ADF_CH1N"   "ADC_AINA_N" (id a7c23d11))
    (series "C_F1P" (cap-0201 "68pF")  "ADC_AINA_P" "GND"        (id a7c23d12))
    (series "C_F1N" (cap-0201 "68pF")  "ADC_AINA_N" "GND"        (id a7c23d13))
    ;; Channel B (Rx2)
    (series "R_F2P" (res-0201 "33R")   "ADF_CH2P"   "ADC_AINB_P" (id a7c23d14))
    (series "R_F2N" (res-0201 "33R")   "ADF_CH2N"   "ADC_AINB_N" (id a7c23d15))
    (series "C_F2P" (cap-0201 "68pF")  "ADC_AINB_P" "GND"        (id a7c23d16))
    (series "C_F2N" (cap-0201 "68pF")  "ADC_AINB_N" "GND"        (id a7c23d17))
    ;; Channel C (Rx3)
    (series "R_F3P" (res-0201 "33R")   "ADF_CH3P"   "ADC_AINC_P" (id a7c23d18))
    (series "R_F3N" (res-0201 "33R")   "ADF_CH3N"   "ADC_AINC_N" (id a7c23d19))
    (series "C_F3P" (cap-0201 "68pF")  "ADC_AINC_P" "GND"        (id a7c23d1a))
    (series "C_F3N" (cap-0201 "68pF")  "ADC_AINC_N" "GND"        (id a7c23d1b))
    ;; Channel D (Rx4)
    (series "R_F4P" (res-0201 "33R")   "ADF_CH4P"   "ADC_AIND_P" (id a7c23d1c))
    (series "R_F4N" (res-0201 "33R")   "ADF_CH4N"   "ADC_AIND_N" (id a7c23d1d))
    (series "C_F4P" (cap-0201 "68pF")  "ADC_AIND_P" "GND"        (id a7c23d1e))
    (series "C_F4N" (cap-0201 "68pF")  "ADC_AIND_N" "GND"        (id a7c23d1f))
    ;; SDO 100Ω series dampers (place close to ADC)
    (series "R_SDA" (res-0201 "100R") "ADC_SDOA_RAW" "ADC_SDOA" (id a7c23d20))
    (series "R_SDB" (res-0201 "100R") "ADC_SDOB_RAW" "ADC_SDOB" (id a7c23d21))
    (series "R_SDC" (res-0201 "100R") "ADC_SDOC_RAW" "ADC_SDOC" (id a7c23d22))
    (series "R_SDD" (res-0201 "100R") "ADC_SDOD_RAW" "ADC_SDOD" (id a7c23d23))
    ;; SCK 22Ω damping at STM32 driver side (tuneable during bring-up)
    (series "R_SCK" (res-0201 "22R") "ADC_SCK_MCU" "ADC_SCK" (id a7c23d24))
    (note "VCC (pin 4) = 3.3V VDD; VLOGIC (pin 2) = 1.8V V1P8 — directly compatible with STM32N6 1.8V I/O, no level shifter needed.")
    (note "REGCAP (pin 3) = internal 1.9V regulator bypass — 1µF to GND ONLY; do not connect externally.")
    (note "REFIN (pin 17) = 3.3V tied to VDD analog rail through 0R jumper R_REF. ADC.md spec calls for an ADR4533 precision 3.3V reference (needs a 5V rail) for full 16-bit ENOB — defer to a future revision.")
    (note "DNC (pin 15) left unconnected.")
    (note "GND pins 1, 5, 14, 16 and exposed pad (25) tie to solid ground plane with ≥4 thermal vias on the EP.")
    (note "SPI topology: SPI1 master drives SCK + MOSI (SDI) and captures SDOA on MISO. SPI2/4/6 are slave RX only, each capturing SDOB/SDOC/SDOD on their MISO pins while sharing the star-routed SPI1_SCK. TIM1 (or TIM8) generates the 2 MHz CS pulse train in hardware — no software CS.")
    (note "SCK star routing (critical): single driver at STM32N6 V10 (SPI1_SCK), 5 branches to AD7380-4 SCLK + SPI2_SCK (W11) + SPI4_SCK (W12) + SPI6_SCK (T7). 50Ω controlled impedance, no branch >30 mm, no daisy-chaining. 22Ω series damping at the SPI1_SCK pin on the STM32N6 side (R_SCK).")
    (note "100Ω series on each SDO line placed close to the ADC suppresses digital-to-analog coupling per AD7380-4 Applications Information.")
    (note "4-wire SDO mode (firmware CONFIG 2 SDO = 0b10) enables 2 MSPS per channel. SDOD carries data (not ALERT); out-of-range detection is done in firmware on captured samples.")
    (note "Per-channel anti-alias: 33Ω 1% 0402 series in each differential leg + 68pF C0G/NP0 to GND at each ADC input pin. Place close to the ADC, matched within 2 mm pair-to-pair, over solid GND.")
    (note "Firmware: set GPIO speed = Very High on all SPI pins and the TIM CS output pin (affects edge rates and matches the 22Ω SCK damping assumption).")
    (note "Level compatibility: STM32N6 I/O at 1.8V matches AD7380-4 VLOGIC at 1.8V — no level shifter between host and ADC."))

  (section "Test Points" "1mm SMD probe points for bring-up and debug"
    (instance "TP1" testpoint (pin 1 "VBATT")   (id aabbcc01))
    (instance "TP2" testpoint (pin 1 "VDD")     (id aabbcc02))
    (instance "TP3" testpoint (pin 1 "V1P8")    (id aabbcc03))
    (instance "TP4" testpoint (pin 1 "VDDCORE") (id aabbcc04))
    (instance "TP5" testpoint (pin 1 "NRST")    (id aabbcc05))
    (instance "TP6" testpoint (pin 1 "PG_3V3")  (id aabbcc06))
    (instance "TP7" testpoint (pin 1 "BOOT0")   (id aabbcc07))
    (instance "TP8" testpoint (pin 1 "PWR_ON")  (id aabbcc08)))

  (section "Battery Connector" "Solder pads with strain relief for LiPo wires"
    (port "VBATT" out (rated 3.0 4.2))
    (instance "batt" connector-battery
      (pin 1 "VBATT")
      (pin 2 "GND") (id ba77e12a)))

  (section "Mounting" "PCB standoffs"
    (instance "H1" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10001))
    (instance "H2" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10002)))

  (port "VBATT" in (rated 3.0 4.2))
  (port "VBUS"  in (rated 4.0 5.5))
  (port "GND"   bidi))
