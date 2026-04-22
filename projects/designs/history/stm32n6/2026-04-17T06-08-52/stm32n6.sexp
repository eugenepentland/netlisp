(import stm32n657l0h3q
        cap-0201 cap-0402 cap-0603 cap-0805
        res-0402 ind-1616 ind-2016 led-0402 ferrite-0402
        abm8 fc-135 ecmf02-2amx6 connector-swd connector-battery usb4510-03-1-a-gct
        mx66uw1g45gxdi00 aps256xxn-ob9-bg diode-0402
        icm-20948 lsh-020-01-g-d-a-k-tr
        res-0201
        ltc2323-16
        a-wurth-wa-smsi-9774020633r)

(design-block "STM32N657L0H3Q Minimal Schematic"

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
    (instance "swd" connector-swd
      (pin SWDIO "SWDIO")
      (pin SWCLK "SWCLK")
      (pin SWO "SWO")
      (pin VDD "VDD")
      (pin GND "GND") (id d646a1e7)))

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

  (section "USB" "USB 2.0 High-Speed with Type-C connector"
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
    (instance "usb-c" usb4510-03-1-a-gct
      (pin A1-B12 B1-A12 "GND")
      (pin A4-B9 B4-A9 "VBUS")
      (pin A5 "CC1")
      (pin B5 "CC2")
      (pin A6 B6 "USB_CONN_DP")
      (pin A7 B7 "USB_CONN_DN") (id ca29d420))
    (series (res-0402 "5.1k") "CC1" "GND" "CC2" "GND" (id b9a29bc3))
    (series "R8" (res-0201 "200R") "TXRTUNE" "GND" (id b40b1319))
    (note "5.1k pull-downs on CC1/CC2 for UFP (device) role"))

  (section "Battery Connector" "JST-PH 2-pin LiPo battery"
    (role input)
    (instance "batt" connector-battery
      (pin 1 "VBATT")
      (pin 2 "GND") (id d8c4ba01)))

  (section "Debug LED"
    (port "VDD" in power 3.3)
    (series "R9" (res-0402 "330R") "PG10" "LED_NET" (id a4e0a83c))
    (series "D1" (led-0402 "green") "LED_NET" "GND" (id ec5477d8)))

  (section "XSPI2 NOR Flash" "MX66UW1G45G 1Gbit OctoSPI NOR"
    (protocol OctoSPI)
    (port "VDDIO3" in power 1.8)
    (port "NRST" in signal role reset)
    (pins "stm32"
      (pin PN1 "FLASH_NCS")
      (pin PN6 "FLASH_CLK")
      (pin PN7 "FLASH_NCLK")
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
      (pin G16 "PSRAM_NCLK")
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
      (pin V11 "IMU_SCK")
      (pin V12 "IMU_MOSI")
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
      (pin RESV_20 "GND")
      (pin AUX_CL "IMU_AUX_CL")
      (pin AUX_DA "IMU_AUX_DA") (id e8c00656))
    (series (cap-0201 "100nF" x7r) "VDD" "GND" "IMU_REGOUT" "GND" (id d22644cb))
    (note "FW: FSYNC config — DELAY_TIME_EN=1, EXT_SYNC_SET per sensor"))

  (section "Expansion Connector" "Samtec LSH 40-pin dual-row 0.635mm"
    (role output)
    (port "VDD" in power 3.3)
    (port "EXP" io data)
    (instance "expansion" lsh-020-01-g-d-a-k-tr
      (pin 1 2 "GND")
      (pin 3 4 "VBATT")
      (pin 5 6 "VDD") (id b543a309)))

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

  (section "LTC2323-16 ADC" "Dual 16-bit 2Msps SAR ADC, CMOS interface"
    (protocol SPI)
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "ADF_CH1P" in differential optional)
    (port "ADF_CH1N" in differential optional)
    (port "ADF_CH2P" in differential optional)
    (port "ADF_CH2N" in differential optional)
    (pins "stm32"
      (pin W16 "ADC_CNV")
      (pin V10 "ADC_SCK")
      (pin W15 "ADC_SDO1")
      (pin V16 "ADC_SDO2"))
    (instance "adc" ltc2323-16
      (pin VDD_1 VDD_2 "VDD")
      (pin GND_1 GND_2 GND_3 GND_4 "GND")
      (pin OVDD "V1P8")
      (pin OGND "GND")
      (pin REFINT "VDD")
      (pin REFOUT1 "ADC_REFOUT1")
      (pin REFRTN1 "ADC_REFRTN1")
      (pin REFOUT2 "ADC_REFOUT2")
      (pin REFRTN2 "ADC_REFRTN2")
      (pin VBYP1 "ADC_VBYP1")
      (pin VBYP2 "ADC_VBYP2")
      (pin "AIN1+" "ADC_AIN1P")
      (pin "AIN1-" "ADC_AIN1N")
      (pin "AIN2+" "ADC_AIN2P")
      (pin "AIN2-" "ADC_AIN2N")
      (pin "~{CNV}" "ADC_CNV")
      (pin "SCK+" "ADC_SCK")
      (pin "SDO1+" "ADC_SDO1")
      (pin "SDO2+" "ADC_SDO2")
      (pin "~{CMOS}/LVDS" "GND")
      (pin "CLKOUT-" "V1P8")
      (id a7c23d01))
    ;; VDD bypass: 10uF + 100nF at each VDD pin
    (decouple "VDD" (cap-0805 "10uF" x5r) 2 per-pin adc VDD_1 (id a7c23d02))
    (decouple "VDD" (cap-0402 "100nF" x7r) 2 per-pin adc VDD_1 (id a7c23d03))
    ;; OVDD bypass
    (series "C_OVDD" (cap-0402 "100nF" x7r) "V1P8" "GND" (id a7c23d04))
    ;; Reference bypass: 100nF + 10uF between REFOUT and REFRTN (not to GND)
    (series "C_REF1A" (cap-0402 "100nF" x7r) "ADC_REFOUT1" "ADC_REFRTN1" (id a7c23d05))
    (series "C_REF1B" (cap-0805 "10uF" x5r) "ADC_REFOUT1" "ADC_REFRTN1" (id a7c23d06))
    (series "C_REF2A" (cap-0402 "100nF" x7r) "ADC_REFOUT2" "ADC_REFRTN2" (id a7c23d07))
    (series "C_REF2B" (cap-0805 "10uF" x5r) "ADC_REFOUT2" "ADC_REFRTN2" (id a7c23d08))
    ;; VBYP bypass to GND
    (series "C_BYP1" (cap-0402 "1uF" x7r) "ADC_VBYP1" "GND" (id a7c23d09))
    (series "C_BYP2" (cap-0402 "1uF" x7r) "ADC_VBYP2" "GND" (id a7c23d0a))
    ;; Channel 1 anti-alias filter: 25R series + 330pF differential
    (series "R_F1P" (res-0402 "25R") "ADF_CH1P" "ADC_AIN1P" (id a7c23d0b))
    (series "R_F1N" (res-0402 "25R") "ADF_CH1N" "ADC_AIN1N" (id a7c23d0c))
    (series "C_F1" (cap-0402 "330pF" np0) "ADC_AIN1P" "ADC_AIN1N" (id a7c23d0d))
    ;; Channel 2 anti-alias filter: 25R series + 330pF differential
    (series "R_F2P" (res-0402 "25R") "ADF_CH2P" "ADC_AIN2P" (id a7c23d0e))
    (series "R_F2N" (res-0402 "25R") "ADF_CH2N" "ADC_AIN2N" (id a7c23d0f))
    (series "C_F2" (cap-0402 "330pF" np0) "ADC_AIN2P" "ADC_AIN2N" (id a7c23d10))
    (note "REFINT tied to VDD enables internal 2.048V reference")
    (note "REFRTN1/2 are NOT connected to GND — bypass caps go between REFOUT and REFRTN only")
    (note "CMOS/LVDS tied to GND selects CMOS output mode; CLKOUT- tied to OVDD disables CLKOUT")
    (note "CNV: TIM1_CH1 (PA8) — 2MHz PWM, ≥25ns high pulse, fast falling edge")
    (note "SCK: SPI1_SCK (PA5) — 36MHz, CPOL=0 CPHA=1, 16-bit frame")
    (note "SDO1: SPI1_MISO (PB4) — channel 1 data, MSB first")
    (note "SDO2: PG9 GPIO — channel 2 data, bit-bang in DMA ISR or second SPI")
    (note "Anti-alias RC: 25R + 330pF → ~1MHz cutoff with ADF5904 900R source impedance"))

  (section "Mounting" "PCB standoffs"
    (instance "H1" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10001))
    (instance "H2" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10002)))

  (port "VBATT" in (rated 3.0 4.2))
  (port "VBUS"  in (rated 4.0 5.5))
  (port "GND"   bidi))
