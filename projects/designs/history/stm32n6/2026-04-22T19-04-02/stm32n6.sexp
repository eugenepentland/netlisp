(import stm32n657l0h3q
        cap-0201 cap-0402 cap-0603 cap-0805
        res-0402 ind-1616 ind-2016 ferrite-0402
        abm8 fc-135 ecmf02-2amx6 usb4235-03-c
        mx66uw1g45gxdi00 aps256xxn-ob9-bg diode-0402
        icm-20948 204928-0601
        res-0201
        ad7380-channel
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
      (net "GND" "VSSSMPS" (id fd3769fb) (id a3355d70) (id c1d107cc))
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
      (note "G4 (PWR_ON) pulled to VDDSMPS via 10k — enables SMPS at power-up (AN5967 Table 5 (id e1b65814) (id b3a25f35) (id bedc9c01) (id c56aebde) (id ab513798) (id e57d9c08) (id eb944c22) (id a756b2f6) (id ede7e21e) (id be3a4645) (id e1a373d8) (id b551c8a1) (id fa9b9f5d) (id aab89556) (id f44f907b) (id c8e93186) (id e6bb0af8) (id ca9d63b0) (id e46052ec) (id f81e863f) (id bfad5adf))"))

    (section "Analog & I/O Rails"
      (port "V1P8" in power 1.8)
      (port "VDD" in power 3.3)
      (pins "stm32"
        (pin M6 "VDDA18PLL" (id f53e4887) (id b359d9c7) (id ea90d4da))
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
        (pin F4 "BOOT0"))
      (series "C35" (cap-0201 "100nF") "NRST" "GND" (id e0668c9a))
      (series "R_BOOT0" (res-0201 "10k") "BOOT0" "GND" (id d44c84c9))
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
      (pin R1 (as "SPI5_SCK")  "IMU_SCK")
      (pin T1 (as "SPI5_MOSI") "IMU_MOSI")
      (pin U2 (as "SPI5_MISO") "IMU_MISO")
      (pin V1 (as "SPI5_NSS")  "IMU_NCS")
      (pin T4 "IMU_INT1")
      (pin R4 "IMU_FSYNC"))
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

  (section "Expansion Connector" "Molex SlimStack 204928-0601, 60-pin 0.4mm BTB — 12 analog channels to ADC array"
    (role output)
    (protocol SPI)
    (port "VDD" in power 3.3)
    (port "EXP" io data)
    (pins "stm32"
      (pin D6 (as "SPI3_SCK") "EXP_SPI_SCK")
      (pin B6 (as "SPI3_MISO") "EXP_SPI_MISO")
      (pin A6 (as "SPI3_MOSI") "EXP_SPI_MOSI")
      (pin T15 (as "SPI3_NSS") "EXP_SPI_NCS"))
    (instance "expansion" 204928-0601
      ;; Power / control
      (pin 1 2 "GND")
      (pin 3 "EXP_SPI_SCK")
      (pin 4 6 8 10 "VBATT")
      (pin 5 "EXP_SPI_MISO")
      (pin 7 "EXP_SPI_MOSI")
      (pin 9 "EXP_SPI_NCS")
      (pin 11 12 "V1P8")
      ;; 12 differential analog channels, each pair preceded by a GND shield
      (pin 13 16 19 22 25 28 31 34 37 40 43 46 "GND")
      (pin 14 "ADF_CH1P")  (pin 15 "ADF_CH1N")
      (pin 17 "ADF_CH2P")  (pin 18 "ADF_CH2N")
      (pin 20 "ADF_CH3P")  (pin 21 "ADF_CH3N")
      (pin 23 "ADF_CH4P")  (pin 24 "ADF_CH4N")
      (pin 26 "ADF_CH5P")  (pin 27 "ADF_CH5N")
      (pin 29 "ADF_CH6P")  (pin 30 "ADF_CH6N")
      (pin 32 "ADF_CH7P")  (pin 33 "ADF_CH7N")
      (pin 35 "ADF_CH8P")  (pin 36 "ADF_CH8N")
      (pin 38 "ADF_CH9P")  (pin 39 "ADF_CH9N")
      (pin 41 "ADF_CH10P") (pin 42 "ADF_CH10N")
      (pin 44 "ADF_CH11P") (pin 45 "ADF_CH11N")
      (pin 47 "ADF_CH12P") (pin 48 "ADF_CH12N")
      ;; Remaining pins reserved for additional ground return
      (pin 49 50 51 52 53 54 55 56 57 58 59 60 "GND")
      (pin MP1 MP2 MP3 MP4 "GND") (id b543a309))
    (note "SPI3 routed to expansion: PC10=SCK (D6), PC11=MISO (B6), PC12=MOSI (A6), PA15=NCS (T15). Free of SPI1 (ADC) and SPI5 (IMU) conflicts.")
    (note "MP1–MP4 board-lock tabs tied to GND.")
    (note "12 differential pairs ADF_CH1..CH12 fan out to the 3x AD7380-4 ADC array (4 channels each). Each pair has a dedicated GND shield pin to its left."))

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

  (section "ADC Array" "3x AD7380-4 quad 16-bit 4MSPS ADCs — 12 channels total via shared SPI1 config + PSSI parallel readout"
    (protocol SPI)
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "ADF_CH1P"  in differential) (port "ADF_CH1N"  in differential)
    (port "ADF_CH2P"  in differential) (port "ADF_CH2N"  in differential)
    (port "ADF_CH3P"  in differential) (port "ADF_CH3N"  in differential)
    (port "ADF_CH4P"  in differential) (port "ADF_CH4N"  in differential)
    (port "ADF_CH5P"  in differential) (port "ADF_CH5N"  in differential)
    (port "ADF_CH6P"  in differential) (port "ADF_CH6N"  in differential)
    (port "ADF_CH7P"  in differential) (port "ADF_CH7N"  in differential)
    (port "ADF_CH8P"  in differential) (port "ADF_CH8N"  in differential)
    (port "ADF_CH9P"  in differential) (port "ADF_CH9N"  in differential)
    (port "ADF_CH10P" in differential) (port "ADF_CH10N" in differential)
    (port "ADF_CH11P" in differential) (port "ADF_CH11N" in differential)
    (port "ADF_CH12P" in differential) (port "ADF_CH12N" in differential)
    (pins "stm32"
      ;; Phase-1 SPI clock (SPI1_SCK) and Phase-2 PWM clock (TIM1_CH1) are two separate
      ;; STM32 pins tied together externally at the ADC_SCK net; firmware puts the
      ;; inactive driver in high-Z. (No single pin on this package has both AFs.)
      (pin V10 (as "SPI1_SCK")  "ADC_SCK_MCU")
      (pin T9  (as "TIM1_CH1")  "ADC_SCK_PWM")
      ;; Shared config path: MOSI fans out to all three ADC SDI pins.
      (pin V15 (as "SPI1_MOSI") "ADC_SDI")
      ;; PSSI clock input — externally looped back from ADC_SCK.
      (pin T10 (as "PSSI_PDCK") "ADC_PDCK")
      ;; Per-ADC CS lines: Phase-1 GPIO output, Phase-2 TIM1_CHx hardware pulse.
      (pin D8  (as "TIM1_CH2")  "ADC1_CS")
      (pin A9  (as "TIM1_CH3")  "ADC2_CS")
      (pin F9  (as "TIM1_CH4")  "ADC3_CS")
      ;; PSSI data lanes. SDOA of each ADC doubles as GPIO input for Phase-1 register readback.
      (pin V9  (as "PSSI_D0")   "ADC1_SDOA")
      (pin W9  (as "PSSI_D1")   "ADC1_SDOB")
      (pin F6  (as "PSSI_D2")   "ADC1_SDOC")
      (pin D14 (as "PSSI_D3")   "ADC1_SDOD")
      (pin C19 (as "PSSI_D4")   "ADC2_SDOA")
      (pin D9  (as "PSSI_D5")   "ADC2_SDOB")
      (pin D19 (as "PSSI_D6")   "ADC2_SDOC")
      (pin E16 (as "PSSI_D7")   "ADC2_SDOD")
      (pin B18 (as "PSSI_D8")   "ADC3_SDOA")
      (pin U3  (as "PSSI_D9")   "ADC3_SDOB")
      (pin C17 (as "PSSI_D10")  "ADC3_SDOC")
      (pin B14 (as "PSSI_D11")  "ADC3_SDOD"))

    ;; Clock tie: SCK_MCU (SPI1_SCK, Phase 1) + SCK_PWM (TIM1_CH1, Phase 2) + PDCK all ride the same ADC_SCK net.
    (series "R_SCK_MCU" (res-0201 "22R") "ADC_SCK_MCU" "ADC_SCK"  (id b7c00001))
    (series "R_SCK_PWM" (res-0201 "22R") "ADC_SCK_PWM" "ADC_SCK"  (id b7c00002))
    (series "R_PDCK"    (res-0201 "0R")  "ADC_SCK"     "ADC_PDCK" (id b7c00003))

    (note "3x AD7380-4 = 12 simultaneous 16-bit channels at 4MSPS each. Instances are sub-blocks at the top level.")
    (note "Phase 1 (boot/config): SPI1_SCK (V10) drives shared clock; SPI1_MOSI (V15) sends config to all three ADC SDI pins; firmware pulses ADC1_CS/ADC2_CS/ADC3_CS one at a time via GPIO. Register readback via GPIO-input read of ADC1_SDOA/ADC2_SDOA/ADC3_SDOA (PSSI_D0/D4/D8).")
    (note "Phase 2 (4 MSPS streaming): firmware Hi-Z's V10 (SPI1_SCK), enables TIM1_CH1 on T9 to PWM the shared ADC_SCK net, and TIM1_CH2/CH3/CH4 simultaneously pulse all three CS lines. PSSI latches all 12 SDO lanes in parallel on PDCK edges into DMA'd RAM.")
    (note "Clock topology: V10 (SPI1_SCK) and T9 (TIM1_CH1) are two STM32 output pins tied externally at the ADC_SCK net. Whichever is driving must be output; the other in Hi-Z GPIO input. PSSI_PDCK on T10 (PA6) samples the same net.")
    (note "SCK damping: 22Ω series on both SCK_MCU and SCK_PWM at the STM32 side. PDCK uses 0R (input only).")
    (note "Each ADC: VCC (pin 4) = 3.3V, VLOGIC (pin 2) = 1.8V, REGCAP (pin 3) = 1µF to GND only, REFIN (pin 17) tied to VDD via 0R (upgrade to ADR4533 in future rev for full ENOB).")
    (note "Per-channel anti-alias: 33Ω series + 68pF to GND on each differential leg at the ADC pin. Keep pair-matched within 2 mm over solid GND.")
    (note "SDO 100Ω dampers close to each ADC suppress digital coupling back into the analog section.")
    (note "Pin 15 (DNC) unmapped on all three. GND pins 1,5,14,16 + exposed pad (25) need ≥4 thermal vias to the plane."))

  ;; Three identical ADC channels — module layout gets replicated in KiCad
  ;; via pcb_update.py (see projects/designs/lib/modules/ad7380-channel.sexp).
  ;; Declared at design-block top level because sub-block forms aren't
  ;; evaluated inside sections.
  (sub-block "adc1" (ad7380-channel 1))
  (sub-block "adc2" (ad7380-channel 2))
  (sub-block "adc3" (ad7380-channel 3))

  ;; Bridge the module's internal ports to the parent board nets.
  ;; Power (shared across all 3 channels).
  (net "VDD"  "adc1/VCC"    "adc2/VCC"    "adc3/VCC")
  (net "V1P8" "adc1/VLOGIC" "adc2/VLOGIC" "adc3/VLOGIC")
  (net "GND"  "adc1/GND"    "adc2/GND"    "adc3/GND")
  ;; Shared SPI buses (MCU side → all 3 ADCs).
  (net "ADC_SCK" "adc1/SCK" "adc2/SCK" "adc3/SCK")
  (net "ADC_SDI" "adc1/SDI" "adc2/SDI" "adc3/SDI")
  ;; Per-channel CS lines (from STM32 TIM1_CH2/3/4).
  (net "ADC1_CS" "adc1/CS")
  (net "ADC2_CS" "adc2/CS")
  (net "ADC3_CS" "adc3/CS")
  ;; Per-channel SDO lanes (to STM32 PSSI_D0..D11).
  (net "ADC1_SDOA" "adc1/SDOA") (net "ADC1_SDOB" "adc1/SDOB")
  (net "ADC1_SDOC" "adc1/SDOC") (net "ADC1_SDOD" "adc1/SDOD")
  (net "ADC2_SDOA" "adc2/SDOA") (net "ADC2_SDOB" "adc2/SDOB")
  (net "ADC2_SDOC" "adc2/SDOC") (net "ADC2_SDOD" "adc2/SDOD")
  (net "ADC3_SDOA" "adc3/SDOA") (net "ADC3_SDOB" "adc3/SDOB")
  (net "ADC3_SDOC" "adc3/SDOC") (net "ADC3_SDOD" "adc3/SDOD")
  ;; Analog inputs from the expansion connector (12 differential pairs).
  (net "ADF_CH1P"  "adc1/AINA_EXT_P") (net "ADF_CH1N"  "adc1/AINA_EXT_N")
  (net "ADF_CH2P"  "adc1/AINB_EXT_P") (net "ADF_CH2N"  "adc1/AINB_EXT_N")
  (net "ADF_CH3P"  "adc1/AINC_EXT_P") (net "ADF_CH3N"  "adc1/AINC_EXT_N")
  (net "ADF_CH4P"  "adc1/AIND_EXT_P") (net "ADF_CH4N"  "adc1/AIND_EXT_N")
  (net "ADF_CH5P"  "adc2/AINA_EXT_P") (net "ADF_CH5N"  "adc2/AINA_EXT_N")
  (net "ADF_CH6P"  "adc2/AINB_EXT_P") (net "ADF_CH6N"  "adc2/AINB_EXT_N")
  (net "ADF_CH7P"  "adc2/AINC_EXT_P") (net "ADF_CH7N"  "adc2/AINC_EXT_N")
  (net "ADF_CH8P"  "adc2/AIND_EXT_P") (net "ADF_CH8N"  "adc2/AIND_EXT_N")
  (net "ADF_CH9P"  "adc3/AINA_EXT_P") (net "ADF_CH9N"  "adc3/AINA_EXT_N")
  (net "ADF_CH10P" "adc3/AINB_EXT_P") (net "ADF_CH10N" "adc3/AINB_EXT_N")
  (net "ADF_CH11P" "adc3/AINC_EXT_P") (net "ADF_CH11N" "adc3/AINC_EXT_N")
  (net "ADF_CH12P" "adc3/AIND_EXT_P") (net "ADF_CH12N" "adc3/AIND_EXT_N")

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
