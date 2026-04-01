(import stm32n657l0h3q
        cap-0201 cap-0402 cap-0603 cap-0805
        res-0402 ind-1616 ind-2016 led-0402
        abm8 fc-135 ecmf02-2amx6 connector-swd amphenol-10164986
        mx66uw1g45gxdi00 aps256xxn-ob9-bg diode-0402
        icm-20948 lsh-020-01-g-d-a-k-tr
        tps63806 lp5907mfx-1-8-nopb res-0201)

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
      (net "GND" "VSSA")
      (net "GND" "VSSAON")
      (net "GND" "VSSAPMU")
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
      (note "G2 (VFBSMPS) tied to VDDCORE — SMPS feedback sense (AN5967 Fig 4)")
      (note "W6 (VDDCSI) tied to VDDCORE per AN5967 section 3.2"))

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
        "VDDA18PLL" "VDDA18USB" "VDDA18ADC" "VDDA18CSI" "VDDIO2" "VDDIO3" "VDDIO4" (id bf344845))
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
    (port "VDD" in power 3.3)
    (port "SWDIO" io protocol SWD)
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
    (port "VDDA18USB" in power 1.8)
    (port "VDD33USB" in power 3.3)
    (port "USB_DP" io protocol USB2.0-HS)
    (pins "stm32"
      (pin D4 "VDDA18USB")
      (pin C3 "VDD33USB")
      (pin C1 "USB_DP")
      (pin C2 "USB_DM")
      (pin E2 "TXRTUNE"))
    (instance "usb-esd" ecmf02-2amx6
      (pin D_1 "USB_DP")
      (pin D_2 "USB_DM")
      (pin GND "GND")
      (pin "D-" "USB_DM_CONN")
      (pin "D+" "USB_DP_CONN") (id e6a1a21e))
    (instance "usb-c" amphenol-10164986
      (pin GND_A GND_A__1 GND_B GND_B__1 "GND")
      (pin VBUS_A VBUS_A__1 VBUS_B VBUS_B__1 "VBUS")
      (pin CC1 "CC1")
      (pin CC2 "CC2")
      (pin "D1+" "D2+" "USB_DP_CONN")
      (pin "D1-" "D2-" "USB_DM_CONN")
      (pin SHIELD SHIELD__1 SHIELD__2 SHIELD__3 "GND") (id ca29d420))
    (series (res-0402 "5.1k") "CC1" "GND" "CC2" "GND" (id b9a29bc3))
    (series "R8" (res-0402 "200R") "TXRTUNE" "GND" (id b40b1319))
    (note "5.1k pull-downs on CC1/CC2 for UFP (device) role"))

  (section "Debug LED"
    (port "VDD" in power 3.3)
    (series "R9" (res-0402 "330R") "PG10" "LED_NET" (id a4e0a83c))
    (series "D1" (led-0402 "green") "LED_NET" "GND" (id ec5477d8)))

  (section "XSPI2 NOR Flash" "MX66UW1G45G 1Gbit OctoSPI NOR"
    (port "VDDIO3" in power 1.8)
    (port "NRST" in signal role reset)
    (port "FLASH_IO" io data protocol OctoSPI)
    (port "FLASH_CLK" in clock)
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
    (series "R10" (res-0402 "10k") "FLASH_RESET" "VDDIO3" (id c734428e))
    (series "R11" (res-0402 "10k") "FLASH_NCS" "VDDIO3" (id ce543c3a))
    (series "D2" (diode-0402 "PMEG2005AEA") "NRST" "FLASH_RESET" (id ab720208))
    (note "D2: reverse diode NRST->FLASH_RESET for simultaneous reset (AN5967 14.4.3)")
    (note "FW: If VDDIO3=1.8V, set OTP124 bit 15 (HSLV) + PWR_SVMCRx VDDIOxVRSEL"))

  (section "XSPI1 PSRAM" "APS256XXN 256Mbit OctoSPI PSRAM"
    (port "VDDIO2" in power 1.8)
    (port "PSRAM_IO" io data protocol OctoSPI)
    (port "PSRAM_CLK" in clock)
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
    (series "R12" (res-0402 "10k") "PSRAM_NCS" "VDDIO2" (id bfd3a713))
    (note "FW: If VDDIO2=1.8V, set OTP124 bit 16 (HSLV) + PWR_SVMCRx VDDIOxVRSEL"))

  (section "IMU" "ICM-20948 9-axis IMU via SPI2"
    (port "VDD" in power 3.3)
    (port "IMU_SCK" io protocol SPI)
    (port "IMU_INT1" out signal role interrupt)
    (port "IMU_FSYNC" in signal role sync)
    (pins "stm32"
      (pin A16 "IMU_SCK")
      (pin A14 "IMU_MOSI")
      (pin C17 "IMU_MISO")
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
    (port "VDD" in power 3.3)
    (port "EXP" io data)
    (instance "expansion" lsh-020-01-g-d-a-k-tr (id b543a309)))

  (section "3.3V Buck-Boost" "TPS63806 from single-cell LiPo to 3.3V"
    (port "VBATT" in power)
    (port "VDD" out power 3.3)
    (port "PG_3V3" out signal role enable)
    (calc "Output voltage"
      (let vout (* 0.5 (+ 1.0 (/ 511000.0 91000.0))))
      (assert-range vout 3.2 3.4 "VDD target"))
    (instance "buck" tps63806
      (pin EN "VBATT")
      (pin VIN_1 VIN_2 "VBATT")
      (pin MODE "GND")
      (pin L1_1 L1_2 "SW_L1")
      (pin AGND "AGND")
      (pin GND_1 GND_2 "GND")
      (pin FB "FB_3V3")
      (pin L2_1 L2_2 "SW_L2")
      (pin PG "PG_3V3")
      (pin VOUT_1 VOUT_2 "VDD") (id d865e2a1))
    (decouple "VBATT" (cap-0603 "10uF") 1 per-pin buck VIN_1 (id ca9c1826))
    (decouple "VDD" (cap-0805 "47uF") 2 per-pin buck VOUT_1 (id b5477e53))
    (series "L2" (ind-1616 "0.47uH") "SW_L1" "SW_L2" (id c59d9c42))
    (series "R_FBT" (res-0402 "511k") "VDD" "FB_3V3" (id d8c5e75f))
    (series "R_FBB" (res-0402 "91k") "FB_3V3" "GND" (id a5db8a06))
    (series "R_PG" (res-0402 "100k") "PG_3V3" "VDD" (id cf6e4768))
    (net "GND" "AGND")
    (net "VDD" "VDDSMPS" "VDD33USB" "VREF+" "VDDIO4")
    (note "EN (A1) tied to VBATT — converter always on when battery present")
    (note "MODE (B1) tied to GND — auto PFM/PWM, 13uA quiescent")
    (note "FB divider: 511k/91k 1% → VOUT=3.306V (500mV ref)")
    (note "L2: XFL4015-471MEC (4x4x1.5mm, 5.4A sat, 7.6mOhm DCR)"))

  (section "1.8V LDO" "LP5907 1.8V from 3.3V, sequenced by PG"
    (port "VDD" in power 3.3)
    (port "PG_3V3" in signal role enable)
    (port "V1P8" out power 1.8)
    (instance "ldo" lp5907mfx-1-8-nopb
      (pin IN "VDD")
      (pin EN "PG_3V3")
      (pin OUT "V1P8")
      (pin GND "GND") (id d1a7e0df))
    (decouple "VDD" (cap-0201 "1uF") 1 per-pin ldo IN (id e6988efe))
    (decouple "V1P8" (cap-0201 "1uF") 1 per-pin ldo OUT (id e9b79838))
    (net "V1P8" "VDDA18AON" "VDDA18PMU" "VDDA18PLL" "VDDA18USB" "VDDA18ADC" "VDDA18CSI" "VDDIO2" "VDDIO3")
    (note "EN driven by TPS63806 PG — 1.8V sequences after 3.3V stable"))

  (port "VBATT"    "VBATT"    in  (rated 3.0 4.2))
  (port "VBUS"     "VBUS"     in  (rated 4.0 5.5))
  (port "GND"      "GND"      bidi))
