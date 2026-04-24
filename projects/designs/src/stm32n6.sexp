(import stm32n657l0h3q
        cap-0201 cap-0402 cap-0603 cap-0805
        res-0402 ind-1616 ind-2016 ferrite-0402
        abm8 fc-135 ecmf02-2amx6 usb4235-03-c
        mx66uw1g45gxdi00 aps256xxn-ob9-bg diode-0402
        diode-sod323
        icm-20948 204928-0601
        res-0201
        ad7380-channel
        ad7380-channel-2ch
        a-wurth-wa-smsi-9774020633r
        connector-swd-6
        connector-motor
        sw-ws-tasu-436331045822
        fh12-10s-0-5sh-55-
        ao3400a
        ltc6655bhms8-2-5#pbf
        testpoint)

(design-block "Cyclops Digital"

  (instance "stm32" stm32n657l0h3q (id b22d91d5))

  (section "STM32N657L0H3Q Core System" "ARM Cortex-M55 MCU - Minimum Hardware Requirements"
    (port "VDD" in power 3.3)
    (port "V1P8" in power 1.8)
    (port "VDDCORE" out power 0.8)
    (port "NRST" out signal role reset)

    (calc "HSE load capacitors"
      (let cl 10.0)
      (let cstray 5.0)
      (let cload (* 2.0 (- cl cstray))))
    (calc "LSE load capacitors"
      (let cl 7.0)
      (let cstray 3.0)
      (let cload (* 2.0 (- cl cstray))))

    ;; VDD Power
    (pins "stm32"
      (group "VDD Power")
      (pin J14 K14 L14 "VDD" (i-typ 0.08) (i-max 0.15))
      (pin F1 "VDD" (i-typ 0.0001) (i-max 0.001))
      (pin H6 "VDDA18AON" (i-typ 0.0001) (i-max 0.005))
      (pin A19 F12 H14 N16 P8 P12 P14 W1 W19 "GND")
      (pin N6 "VSSA")
      (pin G6 "VSSAON")
      (pin H2 "VSSAPMU"))

    ;; SMPS Power — internal 0.8V core regulator
    (pins "stm32"
      (group "SMPS Power")
      (pin H1 "VDDA18PMU" (i-typ 0.005) (i-max 0.01))
      (pin L1 L2 L3 L4 L5 "VDDSMPS" (i-typ 0.08) (i-max 0.2))
      (pin K1 K2 K3 K4 K5 "VLXSMPS")
      (pin G2 "VDDCORE")
      (pin J1 J2 J3 J4 J5 "VSSSMPS")
      (pin P7 P9 P10 P11 P13 "VDDCORE")
      (pin W6 "VDDCORE")
      (pin G4 "PWR_ON"))

    ;; Analog & I/O Rails
    (pins "stm32"
      (group "Analog & I/O Rails")
      (pin M6 "VDDA18PLL" (i-typ 0.005) (i-max 0.01))
      (pin P6 "VDDA18ADC" (i-typ 0.002) (i-max 0.005))
      (pin V6 "VDDA18CSI" (i-typ 0.01) (i-max 0.02))
      (pin W2 "VREF+")
      (pin V2 "VSSA")
      (pin H16 J16 K16 L16 "VDDIO2" (i-typ 0.02) (i-max 0.05))
      (pin M14 M16 "VDDIO3" (i-typ 0.02) (i-max 0.05))
      (pin F7 F8 "VDDIO4" (i-typ 0.02) (i-max 0.05))
      (pin G1 "V08CAP"))

    ;; Boot & Reset
    (pins "stm32"
      (group "Boot & Reset")
      (pin F2 "NRST")
      (pin A1 "VDDA18AON")
      (pin F4 "BOOT0")
      (pin H4 (as "PC13" "PWR_WKUP3") "PWR_BTN"))

    ;; SWD Debug
    (pins "stm32"
      (group "SWD Debug")
      (pin W7 (as "DEBUG_JTMS-SWDIO") "SWDIO_MCU")
      (pin V7 (as "DEBUG_JTCK-SWCLK") "SWCLK_MCU")
      (pin T14 (as "DEBUG_JTDO-SWO") "SWO_MCU"))

    ;; HSE (Main Clock) — 24 MHz crystal for USB HS PHY
    (pins "stm32"
      (group "HSE Clock")
      (pin A5 (as "RCC_OSC_IN") "OSC_IN")
      (pin B5 (as "RCC_OSC_OUT") "OSC_OUT"))

    ;; LSE (RTC Clock) — 32.768 kHz crystal
    (pins "stm32"
      (group "LSE Clock")
      (pin E1 (as "RCC_OSC32_IN") "OSC32_IN")
      (pin D1 (as "RCC_OSC32_OUT") "OSC32_OUT"))

    ;; Decoupling and filters
    (decouple (cap-0201 "100nF") 1 per-pin stm32 "VDD" "VDDA18AON" (id f619c531))
    (decouple "VDDCORE" (cap-0603 "15uF") 4 per-pin stm32 P7 (id cfc02418 (id b422d7a1) (id a60c6e44) (id abe074be) (id ac98150c)))
    (decouple "VDDCORE" (cap-0201 "1uF") 1 per-pin stm32 (id f1113d21))
    (decouple "VDDSMPS" (cap-0603 "10uF")  2 per-pin stm32 L1 (id e05df5aa))
    (decouple "VDDSMPS" (cap-0201 "1uF")   2 per-pin stm32 L1 (id a741dad6))
    (decouple "VDDSMPS" (cap-0201 "100nF")  2 per-pin stm32 L1 (id c4293f16))
    (series "L1" (ind-2016 "1uH") "VLXSMPS" "VDDCORE" (id f130c61b))
    (series "C18" (cap-0402 "2.2nF" x7r) "VLXSMPS" "SNUB1" (id aa2c3eda))
    (series "R1" (res-0402 "2R") "SNUB1" "GND" (id fbbc4c8b))
    (decouple "VDDA18PMU" (cap-0201 "100nF") 1 per-pin stm32 (id ee3d56f0))
    (decouple (cap-0201 "100nF") 1 per-pin stm32
      "VDDIO2" "VDDIO3" "VDDIO4" (id bf344845))
    ;; Analog 1.8V: caps on filtered side of ferrite beads (no per-pin split)
    (series (cap-0201 "100nF") "VDDA18PLL" "GND" "VDDA18USB" "GND" "VDDA18ADC" "GND" "VDDA18CSI" "GND" (id bf344846))
    (decouple "VDD33USB" (cap-0201 "1uF") 1 per-pin stm32 (id c6c9160e))
    (decouple "VDDCORE" (cap-0201 "1uF") 1 per-pin stm32 W6 (id e50059e2))
    (decouple "V08CAP" (cap-0603 "4.7uF") 1 per-pin stm32 (id b897a15f))
    (decouple "VREF+" (cap-0201 "1uF")   1 per-pin stm32 (id e4c292f6))
    (decouple "VREF+" (cap-0201 "100nF") 1 per-pin stm32 (id cf78bc5e))

    ;; Boot & Reset passives and switch
    (series "C35" (cap-0201 "100nF") "NRST" "GND" (id e0668c9a))
    (series "R_BOOT0" (res-0201 "10k") "BOOT0" "GND" (id d44c84c9))

    ;; Power button — SPST side-push tact switch on PC13/PWR_WKUP3.
    ;; COM tied to GND via switch closure; GPIO pulled up to VDD with RC debounce.
    (instance "SW2" sw-ws-tasu-436331045822
      (pin 1 3 "PWR_BTN")
      (pin 2 4 "GND") (id f8bfd5d6))
    (series "R_PWR_BTN" (res-0402 "10k") "PWR_BTN" "VDD" (id f8bfd5d7))
    (series "C_PWR_BTN" (cap-0402 "100nF") "PWR_BTN" "GND" (id f8bfd5d8))
    (note "SW2 wired as active-low: press pulls PC13 to GND. PC13=PWR_WKUP3 can wake from Standby.")
    (note "PC13 is in the backup domain — firmware must disable RTC tamper functions before using as GPIO input.")

    ;; SWD series dampers and header
    (series "R4" (res-0402 "33R") "SWDIO_MCU" "SWDIO" (id f66085ff))
    (series "R5" (res-0402 "33R") "SWCLK_MCU" "SWCLK" (id e624ddcc))
    (series "R6" (res-0402 "33R") "SWO_MCU" "SWO" (id cf985c4e))
    (instance "swd-hdr" connector-swd-6
      (pin 1 "VDD")
      (pin 2 "SWDIO")
      (pin 3 "SWCLK")
      (pin 4 "SWO")
      (pin 5 "NRST")
      (pin 6 "GND") (id c0de5wd6))

    ;; HSE — 24 MHz crystal
    (instance "hse" abm8
      (pin X1 "OSC_IN")
      (pin GND_1 GND_2 "GND")
      (pin X2 "OSC_OUT") (id a4b23ed4))
    (series (cap-0402 "10pF" np0) "OSC_IN" "GND" "OSC_OUT" "GND" (id b5986a13))

    ;; LSE — 32.768 kHz crystal
    (instance "lse" fc-135
      (pin 1 "OSC32_IN")
      (pin 2 "OSC32_OUT") (id b2a39445))
    (series (cap-0402 "6.8pF" np0) "OSC32_IN" "GND" "OSC32_OUT" "GND" (id e6ab5b54))

    (note "F1 (VBAT) tied to VDD — LiPo 4.2V exceeds VBAT max (3.6V), so backup domain only active when VDD is up")
    (note "G2 (VFBSMPS) tied to VDDCORE — SMPS feedback sense (AN5967 Fig 4)")
    (note "W6 (VDDCSI) tied to VDDCORE per AN5967 section 3.2" (id db0a04fb) (id c4ca02d6))
    (note "G4 (PWR_ON) is an STM32 output — drives enables for downstream regulators, not the internal SMPS. No external pull needed; TP8 gives bring-up visibility.")
    (note "A1 (PDR_ON) must be tied to VDDA18AON per AN5967 Table 5")
    (note "FW: I/O compensation cells — RAPSRC=0x8, RANSRC=0x7 (AN5967 12.4)"))

  (section "USB" "USB 2.0 High-Speed with Type-C connector (USB4235-03-C)"
    (role input)
    (protocol USB2.0-HS)
    (port "VDDA18USB" in power 1.8)
    (port "VDD33USB" in power 3.3)
    (pins "stm32"
      (pin D4 "VDDA18USB" (i-typ 0.025) (i-max 0.04))
      (pin C3 "VDD33USB" (i-typ 0.025) (i-max 0.04))
      (pin C1 (as "USB2_OTG_HS_DP") "USB_DP")
      (pin C2 (as "USB2_OTG_HS_DM") "USB_DN")
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
      (pin PN1 (as "XSPIM_P2_NCS1") "FLASH_NCS")
      (pin PN6 (as "XSPIM_P2_CLK")  "FLASH_CLK")
      (pin PN0 (as "XSPIM_P2_DQS0") "FLASH_DQS")
      (bus "FLASH_IO" (as-prefix "XSPIM_P2_IO") PN2 PN3 PN4 PN5 PN8 PN9 PN10 PN11))
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
      (pin PO0 (as "XSPIM_P1_NCS1") "PSRAM_NCS")
      (pin PO4 (as "XSPIM_P1_CLK")  "PSRAM_CLK")
      (pin PO2 (as "XSPIM_P1_DQS0") "PSRAM_DQS0")
      (pin PO3 (as "XSPIM_P1_DQS1") "PSRAM_DQS1")
      (bus "PSRAM_IO" (as-prefix "XSPIM_P1_IO")
                      PP0 PP1 PP2 PP3 PP4 PP5 PP6 PP7
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
      (pin T4 (as "PG4") "IMU_INT1")
      (pin R4 (as "PF8") "IMU_FSYNC"))
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

  (section "Expansion Connector" "Molex SlimStack 204928-0601, 60-pin 0.4mm BTB — 10 analog channels + radar front-end control"
    (role output)
    (protocol SPI)
    (port "VDD" in power 3.3)
    (port "EXP" io data)
    (pins "stm32"
      (pin D6 (as "SPI3_SCK") "EXP_SPI_SCK")
      (pin B6 (as "SPI3_MISO") "EXP_SPI_MISO")
      (pin A6 (as "SPI3_MOSI") "EXP_SPI_MOSI")
      (pin T15 (as "SPI3_NSS") "EXP_SPI_NCS")
      ;; Radar timing (TIM2 — 32-bit general timer, CH2/CH3 phase-locked)
      (pin W12 (as "TIM2_CH2")  "CNV_MASTER")
      (pin W10 (as "TIM2_CH3")  "CHIRP_START")
      ;; Shared RF configuration bus (SPI6) — PLLs, VCOs, mixers, I/O expander
      (pin V10 (as "SPI6_SCK")  "RF_SPI_SCK")
      (pin T7  (as "SPI6_MOSI") "RF_SPI_MOSI")
      (pin W15 (as "SPI6_MISO") "RF_SPI_MISO")
      (pin T8  (as "PA11") "CS_IO_EXP")
      ;; DDM-MIMO phase code outputs — plain GPIO (primary function)
      (pin W18 (as "PN12") "TXDATA_1")
      (pin W17 (as "PA4")  "TXDATA_2")
      ;; BPSK loop-filter gate drives — plain GPIO
      (pin W16 (as "PG11") "BPSK_GATE_1")
      (pin W14 (as "PG2")  "BPSK_GATE_2")
      ;; ADAR2004 multiplier + receiver hardware step lines — plain GPIO
      (pin W13 (as "PB12") "MRST")
      (pin W11 (as "PG13") "MADV")
      (pin W9  (as "PA10") "RxRST")
      (pin W8  (as "PG15") "RxADV"))
    (instance "expansion" 204928-0601
      ;; Even pins — power, SPI3, radar control, GND
      (pin 4 6 8 10 "VBATT")
      (pin 14 16 "V1P8")
      (pin 18 "EXP_SPI_SCK")
      (pin 20 "EXP_SPI_MISO")
      (pin 22 "EXP_SPI_MOSI")
      (pin 24 "EXP_SPI_NCS")
      ;; Radar front-end control block (pins 26-52)
      (pin 52 "CNV_MASTER")
      (pin 56 "CHIRP_START")
      (pin 30 "RF_SPI_SCK")
      (pin 32 "RF_SPI_MOSI")
      (pin 34 "RF_SPI_MISO")
      (pin 26 "CS_IO_EXP")
      (pin 38 "TXDATA_1")
      (pin 40 "TXDATA_2")
      (pin 42 "BPSK_GATE_1")
      (pin 44 "BPSK_GATE_2")
      (pin 46 "MRST")
      (pin 58 "MADV")
      (pin 50 "RxRST")
      (pin 54 "RxADV")
      (pin 2 12 36 28 48 60 "GND")
      ;; Odd pins — 10 differential analog channels, each pair preceded by a GND shield
      (pin 1 7 13 19 25 31 37 43 49 55 "GND")
      (pin 3 "ADF_CH1P")   (pin 5 "ADF_CH1N")
      (pin 9 "ADF_CH2P")   (pin 11 "ADF_CH2N")
      (pin 15 "ADF_CH3P")  (pin 17 "ADF_CH3N")
      (pin 21 "ADF_CH4P")  (pin 23 "ADF_CH4N")
      (pin 27 "ADF_CH5P")  (pin 29 "ADF_CH5N")
      (pin 33 "ADF_CH6P")  (pin 35 "ADF_CH6N")
      (pin 39 "ADF_CH7P")  (pin 41 "ADF_CH7N")
      (pin 45 "ADF_CH8P")  (pin 47 "ADF_CH8N")
      (pin 51 "ADF_CH9P")  (pin 53 "ADF_CH9N")
      (pin 57 "ADF_CH10P") (pin 59 "ADF_CH10N")
      (pin MP1 MP2 MP3 MP4 "GND") (id b543a309))
    (note "SPI3 routed to expansion: PC10=SCK (D6), PC11=MISO (B6), PC12=MOSI (A6), PA15=NCS (T15). Free of SPI1 (internal ADC array) and SPI5 (IMU) conflicts.")
    (note "MP1–MP4 board-lock tabs tied to GND.")
    (note "Pin map: odd pins carry 10 differential ADC pairs (CH1..CH10) with a GND shield odd pin between each pair; even pins 4–24 carry power + SPI3, even pins 26–52 carry the radar front-end control block, even pins 2/16/54–60 are GND.")
    (note "ADC routing: CH1-4 → adc1, CH5-8 → adc2, CH9-10 → adc3 AINA/AINB. adc3 AINC/AIND have no expansion source (only 10 channels fit on this 60-pin pinout).")
    (note "Radar timing (CNV_MASTER, CHIRP_START) uses TIM2_CH2/CH3 — both channels on the same 32-bit timer give microsecond-precise phase alignment between the 2 MHz conversion clock and the 28.6 kHz chirp trigger.")
    (note "Radar config bus is SPI6 (not the existing EXP_SPI/SPI3). Separate bus lets firmware run radar PLL/VCO config and I/O expander traffic without contending with anything already on SPI3.")
    (note "CS_IO_EXP, TXDATA_1/2, BPSK_GATE_1/2, MRST/MADV, RxRST/RxADV are plain GPIOs — firmware must be able to toggle between chirps but no hardware timer needed."))

  ;; === Power Chain (design blocks) ===
  ;; battery -> VBATT -> buck -> VDD (3.3V) -> ldo -> V1P8 (1.8V)
  ;; charger trickle-charges VBATT from VBUS when USB is plugged in.
  (sub-block "battery" "blocks/battery-1s-lipo.sexp")
  (sub-block "charger" "blocks/charger.sexp")
  (sub-block "buck" "blocks/buck-boost.sexp")
  (sub-block "ldo" "blocks/ldo.sexp")

  ;; Connect power module ports to design nets. Each rail is declared in
  ;; one consolidated (net ...) form so the validator doesn't flag them as
  ;; split across multiple sections.
  (net "GND"    "VSSA" "VSSAON" "VSSAPMU" "VSSSMPS"
                "battery/GND" "charger/GND" "buck/GND" "ldo/GND"
                "adc1/GND"    "adc2/GND"    "adc3/GND"
                (id fd3769fb) (id a3355d70) (id c1d107cc))
  (net "VBUS"   "charger/VBUS")
  (net "VBATT"  "battery/VBATT" "charger/VBATT" "buck/VIN")
  (net "VDD"    "buck/VOUT" "ldo/VIN" "VDD33USB" "VDDIO4"
                "adc1/VCC"    "adc2/VCC"    "adc3/VCC")
  (net "PG_3V3" "buck/PG" "ldo/EN")
  (net "V1P8"   "ldo/VOUT" "VDDA18PMU" "VDDSMPS" "VDDIO2" "VDDIO3"
                "adc1/VLOGIC" "adc2/VLOGIC" "adc3/VLOGIC")
  (net "CHG_EN" "charger/EN")

  ;; STM32 GPIO for charger enable control
  (pins "stm32"
    (pin T11 (as "PG1") "CHG_EN"))
  ;; 1.8V analog supplies — ferrite bead filtered
  (series "FB1" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18AON" (id a1fb0001))
  (series "FB2" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18PLL" (id a1fb0002))
  (series "FB3" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18USB" (id a1fb0003))
  (series "FB4" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18ADC" (id a1fb0004))
  (series "FB5" (ferrite-0402 "600R@100MHz") "V1P8" "VDDA18CSI" (id a1fb0005))
  ;; VREF+ (W2) tied to filtered VDDA18ADC — STM32N6 VREF+ max is VDDA18ADC (1.8V), not VDD (AN5967 §3.3).
  (net "VDDA18ADC" "VREF+")

  (section "ADC Voltage Reference" "LTC6655-2.5 ultra-low-noise 2.5V precision reference shared by 3x AD7380 ADCs"
    (port "VDD" in power 3.3)
    (port "VREF_2V5" out power 2.5)
    (instance "vref" ltc6655bhms8-2-5#pbf
      ;; SHDN tied to VIN — datasheet warns against floating (weak internal pullup).
      (pin 1 "VDD")
      (pin 2 "VDD")
      ;; All four GND pins to the plane; pin 4 is the datasheet star-ground return.
      (pin 3 4 5 8 "GND")
      ;; Force + sense are one net electrically (Kelvin); separation is a PCB layout concern.
      (pin 6 "VREF_2V5")
      (pin 7 "VREF_2V5") (id a4525001))
    (instance "C_VREF_IN"  (cap-0201 "100nF") (pin 1 "VDD")      (pin 2 "GND") (id a4525002))
    (instance "C_VREF_OUT" (cap-0603 "10uF")  (pin 1 "VREF_2V5") (pin 2 "GND") (id a4525003))
    (note "LTC6655B: 2ppm/°C, ±0.025%, 0.625µVp-p 0.1–10Hz noise. Far lower noise than ADR4525 — worth the cost for full ENOB on 3x AD7380.")
    (note "C_VREF_OUT (10µF) is the star-node bulk cap: on PCB it must sit at the star pour under adc2, not at pin 7.")
    (note "Layout: VOUT_F (pin 7) and VOUT_S (pin 6) route as separate traces to a common star pour. Three branches from the star fan out to adc1/adc2/adc3 REFIN — do not daisy-chain (SAR sampling kicks couple between ADCs).")
    (note "Pin 4 needs its own direct via to GND plane within ~1mm of the pad — it's where LTC6655 return current physically exits.")
    (note "Per-ADC REFIN bypass: each ad7380-channel module has a 100nF ceramic close to pin 17 per LTC6655 datasheet recommendation."))

  (section "ADC Array" "3x AD7380-4 quad 16-bit 4MSPS ADCs — 12 channels total via bit-banged config + PSSI parallel readout"
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
    (pins "stm32"
      ;; T9 is the sole ADC_SCK driver: bit-banged GPIO during Phase-1 config,
      ;; TIM1_CH1 PWM during Phase-2 4 MSPS streaming.
      ;; Dual-role: bit-banged GPIO (PA8) during Phase-1, TIM1_CH1 PWM during Phase-2.
      (pin T9  (as "PA8" "TIM1_CH1")  "ADC_SCK_DRV")
      ;; Shared config path: V15 bit-banged as GPIO fans out to all three ADC SDI pins.
      (pin V15 (as "PA7") "ADC_SDI")
      ;; PSSI clock input — externally looped back from ADC_SCK.
      (pin T10 (as "PSSI_PDCK") "ADC_PDCK")
      ;; Per-ADC CS lines: Phase-1 GPIO output, Phase-2 TIM1_CHx hardware pulse.
      (pin D8  (as "PE11" "TIM1_CH2")  "ADC1_CS")
      (pin A9  (as "PE13" "TIM1_CH3")  "ADC2_CS")
      (pin F9  (as "PE14" "TIM1_CH4")  "ADC3_CS")
      ;; PSSI data lanes. SDOA of each ADC doubles as GPIO input for Phase-1 register readback.
      ;; ADC1 + ADC2 SDOs are on row A/B BGA edge balls for short fanout; lanes are
      ;; non-contiguous (D0/D5 don't exist on A/B), so firmware must demux by lane index.
      (pin A8  (as "PSSI_D1")   "ADC1_SDOA")
      (pin A7  (as "PSSI_D7")   "ADC1_SDOB")
      (pin B7  (as "PSSI_D6")   "ADC1_SDOC")
      (pin A13 (as "PSSI_D4")   "ADC1_SDOD")
      (pin A18 (as "PSSI_D2")   "ADC2_SDOA")
      (pin A17 (as "PSSI_D15")  "ADC2_SDOB")
      (pin B14 (as "PSSI_D11")  "ADC2_SDOC")
      (pin B15 (as "PSSI_D3")   "ADC2_SDOD")
      (pin B18 (as "PSSI_D8")   "ADC3_SDOA")
      (pin C17 (as "PSSI_D10")  "ADC3_SDOB"))

    ;; Clock tie: T9 driver (through 22Ω damper) feeds ADC_SCK; PDCK loops back via 0R.
    (series "R_SCK"  (res-0201 "22R") "ADC_SCK_DRV" "ADC_SCK"  (id b7c00002))
    (series "R_PDCK" (res-0201 "0R")  "ADC_SCK"     "ADC_PDCK" (id b7c00003))

    (note "3x AD7380-4: adc1/adc2 use all 4 channels, adc3 uses 2 — 10 simultaneous 16-bit channels at 4MSPS total. Instances are sub-blocks at the top level.")
    (note "Phase 1 (boot/config): T9 (clock) and V15 (data) bit-banged as GPIO to shift config bytes into each ADC's SDI; firmware pulses ADC1_CS/ADC2_CS/ADC3_CS one at a time via GPIO. Register readback via GPIO-input read of ADC1_SDOA/ADC2_SDOA/ADC3_SDOA (PSSI_D1/D6/D8).")
    (note "Phase 2 (4 MSPS streaming): T9 switched to TIM1_CH1 AF to PWM the shared ADC_SCK net; TIM1_CH2/CH3/CH4 simultaneously pulse all three CS lines. PSSI latches all 10 active SDO lanes in parallel on PDCK edges into DMA'd RAM (adc3 SDOC/SDOD unused).")
    (note "Clock topology: T9 is the sole driver of ADC_SCK — bit-banged GPIO during config, TIM1_CH1 PWM during streaming. PSSI_PDCK on T10 loops back to sample the same net.")
    (note "SCK damping: single 22Ω series on T9 at the STM32 side. PDCK uses 0R (input only).")
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
  ;; adc3 uses the 2-channel variant — saves 10 passives (8 anti-alias R/C on C/D
  ;; + R_SDC/R_SDD dampers). Only SDOA/SDOB land on PSSI; SDOC/SDOD unrouted.
  (sub-block "adc3" (ad7380-channel-2ch 3))

  ;; Bridge the module's internal ports to the parent board nets.
  ;; Shared power (VDD/V1P8/GND) is tied in the consolidated rail forms above.
  (net "VREF_2V5" "adc1/REFIN" "adc2/REFIN" "adc3/REFIN")
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
  ;; adc3 SDOC/SDOD intentionally unrouted — only 2 of 4 channels used on adc3.
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
  ;; adc3 AINC/AIND are unrouted to the expansion connector — only 10 of 12 channels
  ;; fit on the 60-pin BTB with the current GND-shielded odd-pin layout.

  (section "Test Points" "1mm SMD probe points for bring-up and debug"
    (instance "TP1" testpoint (pin 1 "VBATT")   (id aabbcc01))
    (instance "TP2" testpoint (pin 1 "VDD")     (id aabbcc02))
    (instance "TP3" testpoint (pin 1 "V1P8")    (id aabbcc03))
    (instance "TP4" testpoint (pin 1 "VDDCORE") (id aabbcc04))
    (instance "TP5" testpoint (pin 1 "NRST")    (id aabbcc05))
    (instance "TP6" testpoint (pin 1 "PG_3V3")  (id aabbcc06))
    (instance "TP7" testpoint (pin 1 "BOOT0")   (id aabbcc07))
    (instance "TP8" testpoint (pin 1 "PWR_ON")  (id aabbcc08)))

  (note "TP1" "Battery voltage — expect 3.0–4.2V when LiPo attached")
  (note "TP2" "3.3V main rail from buck — first probe point when bring-up fails")
  (note "TP3" "1.8V analog/PLL rail from LDO — only live once PG_3V3 asserts")
  (note "TP4" "0.8V core from STM32 internal SMPS — comes up only after VDD is stable")
  (note "TP5" "MCU reset line — low during reset, high when MCU is running")
  (note "TP6" "Buck power-good — high means VDD is in regulation and LDO is enabled")
  (note "TP7" "Boot mode select — pull high to force system bootloader on power-up")
  (note "TP8" "STM32 PWR_ON output — drives downstream regulator enables")

  (section "Display" "0.96\" ST7735S 80×160 TFT on 10-pin 0.5mm FPC — 4-wire SPI (write-only), PWM-dimmable backlight"
    (role output)
    (protocol SPI)
    (port "VDD" in power 3.3)
    (pins "stm32"
      (pin D10 (as "SPI4_SCK")  "DISP_SCK")
      (pin E16 (as "SPI4_MOSI") "DISP_MOSI")
      (pin F10 (as "PE15") "DISP_NCS")
      (pin D11 (as "PD10") "DISP_NRST")
      (pin D14 (as "PE10") "DISP_DC")
      (pin D16 (as "TIM4_CH2") "DISP_BL_EN"))
    (instance "disp" fh12-10s-0-5sh-55-
      (pin 1 "DISP_LEDK")
      (pin 2 "DISP_LEDA")
      (pin 3 "VDD")
      (pin 4 "VDD")
      (pin 5 "GND")
      (pin 6 "DISP_NCS")
      (pin 7 "DISP_NRST")
      (pin 8 "DISP_MOSI")
      (pin 9 "DISP_SCK")
      (pin 10 "DISP_DC")
      (pin MP_1 MP_2 "GND") (id d15p0001))
    (instance "C_DISP" (cap-0603 "100nF")
      (pin 1 "VDD")
      (pin 2 "GND") (id d15p0002))
    (series "R_BL" (res-0402 "15R") "VDD" "DISP_LEDA" (id d15p0003))
    (instance "Q_BL" ao3400a
      (pin 1 "DISP_BL_EN")
      (pin 2 "GND")
      (pin 3 "DISP_LEDK") (id d15p0004))
    (series "R_BL_PD" (res-0402 "10k") "DISP_BL_EN" "GND" (id d15p0005))
    (note "ST7735S is write-only from the STM32 side — no MISO routed. SPI mode 0 (CPOL=0, CPHA=0), MSB first, up to ~15 MHz write clock.")
    (note "80×160 panel variant: firmware must apply column +26 / row +1 offsets and correct MADCTL, otherwise the image shifts or tears. Most common bring-up gotcha on this panel.")
    (note "DISP_BL_EN is on TIM4_CH2 (D16/PD13). Drive high for full brightness or configure TIM4 for PWM to dim — 1–20 kHz is fine, AO3400A switches fast enough.")
    (note "FPC pin 3 (SPI4W) tied to VDD selects 4-wire SPI mode (D/C line distinguishes command from data bytes).")
    (note "Backlight current: R_BL (15Ω) sets ~20 mA at 3.3V with LED Vf≈3.0V typ — unit-to-unit brightness may vary at worst-case Vf=3.3V. Move R_BL to a 5V rail + ~100Ω if uniform brightness matters.")
    (note "R_BL_PD (10k pull-down) keeps Q_BL gate low while the STM32 boots, so backlight stays off until firmware drives it.")
    (note "MP_1/MP_2 FPC board-lock tabs tied to GND."))

  (section "Vibration Motor" "Coin/pager vibration motor (3.3V, ≤27mA) driven low-side by AO3400A N-MOSFET with Schottky flyback clamp"
    (role output)
    (port "VDD" in power 3.3)
    (pins "stm32"
      (pin D9 (as "PE5" "TIM4_CH1") "VIB_PWM"))
    (instance "motor" connector-motor
      (pin 1 "VDD")
      (pin 2 "VIB_DRAIN") (id v1b10001))
    (instance "Q_VIB" ao3400a
      (pin 1 "VIB_GATE")
      (pin 2 "GND")
      (pin 3 "VIB_DRAIN") (id v1b10002))
    (series "R_VIB_G"  (res-0402 "100R") "VIB_PWM"  "VIB_GATE" (id v1b10003))
    (series "R_VIB_PD" (res-0402 "100k") "VIB_GATE" "GND"      (id v1b10004))
    (series "D_VIB" (diode-sod323 "SS14") "VDD" "VIB_DRAIN" (id v1b10005))
    (note "AO3400A is a logic-level N-MOSFET (5.8A / 30V, Vgs(th) 1.3V typ, Rds(on) ≈25mΩ @ Vgs=3V). At 27mA the drop is <1mV — effectively zero.")
    (note "Flyback diode D_VIB (SS14 Schottky, cathode to VDD) clamps the motor's back-EMF when the FET turns off. Without it the drain node would fly above VDD and stress Q_VIB.")
    (note "R_VIB_G (100Ω) damps gate ringing; R_VIB_PD (100k) holds the gate low while the STM32 boots so the motor stays off until firmware drives it.")
    (note "VIB_PWM on TIM4_CH1 (PE5) — firmware can PWM at 1–20 kHz to modulate intensity. Hard on/off also works fine."))

  (section "Mounting" "PCB standoffs"
    (instance "H1" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10001))
    (instance "H2" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10002)))

  (port "VBATT" in (rated 3.0 4.2))
  (port "VBUS"  in (rated 4.0 5.5))
  (port "GND"   bidi))