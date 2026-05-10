(import stm32n657l0h3q
        abm8 fc-135
        connector-swd-6
        a-wurth-wa-smsi-9774020633r
        204928-0601
        fiducial-0p75-2p25
        testpoint
        ;; peripheral modules — implementation details sealed inside
        usb-c-hs
        mx66uw-flash aps256-psram
        bno08x-imu
        ad7380-channel ad7380-channel-2ch
        ltc6655-vref
        st7735s-display
        vibration-motor
        stm6601-power-button)

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

  (section "Power Button Controller" "STM6601A power button — chip details sealed in stm6601-power-button module"
    (pins "stm32"
      (group "Power Button Handshake")
      (pin N1  (as "PG6") "PSHOLD")
      (pin V16 (as "PG9") "PWR_INT"))
    (note "PG6 → PSHOLD: firmware MUST drive HIGH within tON_BLANK (1.4-3.0s) of boot or the STM6601 latches off. On IWDG reset, PG6 returns to Hi-Z and the module's internal R_PSHOLD_PD pulls PSHOLD low, causing the STM6601 to deassert EN and power-cycle cleanly.")
    (note "PWR_BTN (PC13/PWR_WKUP3): debounced button events wake MCU from Standby. PC13 is in the backup domain — firmware must disable RTC tamper functions before using as a GPIO input.")
    (note "Off-state battery draw ≈ STM6601 (2.5 µA) + MCP73831 charger quiescent (≈3 µA) ≈ 5 µA total — system buck is fully disabled, only the always-on VBATT rail leaks.")
    (note "Firmware contract: (1) IWDG enabled early in main(), refreshed only from main loop (never from ISR), 4-8 s timeout. (2) PSHOLD driven HIGH within 1.4 s of NRST release. (3) PBOUT timer distinguishes short (app event) vs long (>2s, drop PSHOLD) press. (4) PC13 RTC tamper disabled before use as GPIO. (5) On clean shutdown, drive PSHOLD low and stop driving — let it stay low while STM6601 deasserts EN."))
  (sub-block "pwr_btn" (stm6601-power-button))

  (section "USB" "USB 2.0 HS via USB-C — chip details sealed in usb-c-hs module"
    (role input)
    (protocol USB2.0-HS)
    (pins "stm32"
      (group "USB 2.0 HS PHY")
      (pin D4 "VDDA18USB" (i-typ 0.025) (i-max 0.04))
      (pin C3 "VDD33USB" (i-typ 0.025) (i-max 0.04))
      (pin C1 (as "USB2_OTG_HS_DP") "USB_DP")
      (pin C2 (as "USB2_OTG_HS_DM") "USB_DN")
      (pin E2 "TXRTUNE")))
  (sub-block "usb" (usb-c-hs))

  (section "XSPI2 NOR Flash" "MX66UW1G45G 1Gbit OctoSPI NOR — chip details sealed in mx66uw-flash module"
    (protocol OctoSPI)
    (pins "stm32"
      (group "XSPI2 NOR Flash")
      (pin PN1 (as "XSPIM_P2_NCS1") "FLASH_NCS")
      (pin PN6 (as "XSPIM_P2_CLK")  "FLASH_CLK")
      (pin PN0 (as "XSPIM_P2_DQS0") "FLASH_DQS")
      (bus "FLASH_IO" (as-prefix "XSPIM_P2_IO") PN2 PN3 PN4 PN5 PN8 PN9 PN10 PN11)))
  (sub-block "flash" (mx66uw-flash))

  (section "XSPI1 PSRAM" "APS256XXN 256Mbit OctoSPI PSRAM — chip details sealed in aps256-psram module"
    (protocol OctoSPI)
    (pins "stm32"
      (group "XSPI1 PSRAM")
      (pin PO0 (as "XSPIM_P1_NCS1") "PSRAM_NCS")
      (pin PO4 (as "XSPIM_P1_CLK")  "PSRAM_CLK")
      (pin PO2 (as "XSPIM_P1_DQS0") "PSRAM_DQS0")
      (pin PO3 (as "XSPIM_P1_DQS1") "PSRAM_DQS1")
      (bus "PSRAM_IO" (as-prefix "XSPIM_P1_IO")
                      PP0 PP1 PP2 PP3 PP4 PP5 PP6 PP7
                      PP8 PP9 PP10 PP11 PP12 PP13 PP14 PP15)))
  (sub-block "psram" (aps256-psram))

  (section "IMU" "BNO08x 9-axis IMU on SPI5 — chip details sealed in bno08x-imu module"
    (protocol SPI)
    (pins "stm32"
      (group "IMU SPI5")
      (pin R1 (as "SPI5_SCK")  "IMU_SCK")
      (pin T1 (as "SPI5_MOSI") "IMU_MOSI")
      (pin U2 (as "SPI5_MISO") "IMU_MISO")
      (pin V1 (as "SPI5_NSS")  "IMU_NCS")
      (pin T4 (as "PG4")       "IMU_INT")
      (pin R4 (as "PF8")       "IMU_NRST")))
  (sub-block "imu" (bno08x-imu))

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
      ;; DDM-MIMO phase code outputs — plain GPIO (primary function).
      ;; Placed on VDDIO4 (currently tied to VDD = 3.3V) so the bank can be
      ;; switched to V1P8 in a future revision if the daughterboard needs
      ;; 1.8V drive for the ADAR2001 TXDATA inputs without re-pinning.
      ;; Note: VDDIO4 also powers the SPI3 lines (PC10/PC11/PC12) and three
      ;; PSSI data pins (PC1/PC6/PH9), so any future bank-voltage change
      ;; affects those signals too — see review notes.
      (pin F6 (as "PC8") "TXDATA_1")
      (pin D5 (as "PC9") "TXDATA_2")
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
                "motor/GND"   "imu/GND"     "vref/GND"
                "flash/GND"   "psram/GND"   "usb/GND"
                "disp/GND"    "pwr_btn/GND"
                (id fd3769fb) (id a3355d70) (id c1d107cc))
  (net "VBUS"   "charger/VBUS" "usb/VBUS")
  (net "VBATT"  "battery/VBATT" "charger/VBATT" "buck/VIN" "pwr_btn/VBATT")
  (net "VDD"    "buck/VOUT" "ldo/VIN" "VDD33USB" "VDDIO4"
                "adc1/VCC"    "adc2/VCC"    "adc3/VCC"
                "adc1/VLOGIC" "adc2/VLOGIC" "adc3/VLOGIC"
                "motor/VDD"   "imu/VDD"     "vref/VDD"
                "disp/VDD"    "pwr_btn/VDD")
  (net "VIB_PWM"  "motor/PWM")
  (net "IMU_SCK"  "imu/SCK")
  (net "IMU_MOSI" "imu/MOSI")
  (net "IMU_MISO" "imu/MISO")
  (net "IMU_NCS"  "imu/CS")
  (net "IMU_INT"  "imu/INT")
  (net "IMU_NRST" "imu/NRST")
  (net "NRST"      "flash/NRST" "pwr_btn/NRST")
  (net "FLASH_NCS" "flash/CS")
  (net "FLASH_CLK" "flash/CLK")
  (net "FLASH_DQS" "flash/DQS")
  (net "FLASH_IO0" "flash/FLASH_IO0") (net "FLASH_IO1" "flash/FLASH_IO1")
  (net "FLASH_IO2" "flash/FLASH_IO2") (net "FLASH_IO3" "flash/FLASH_IO3")
  (net "FLASH_IO4" "flash/FLASH_IO4") (net "FLASH_IO5" "flash/FLASH_IO5")
  (net "FLASH_IO6" "flash/FLASH_IO6") (net "FLASH_IO7" "flash/FLASH_IO7")
  (net "PSRAM_NCS"  "psram/CS")
  (net "PSRAM_CLK"  "psram/CLK")
  (net "PSRAM_DQS0" "psram/DQS0")
  (net "PSRAM_DQS1" "psram/DQS1")
  (net "PSRAM_IO0"  "psram/PSRAM_IO0")  (net "PSRAM_IO1"  "psram/PSRAM_IO1")
  (net "PSRAM_IO2"  "psram/PSRAM_IO2")  (net "PSRAM_IO3"  "psram/PSRAM_IO3")
  (net "PSRAM_IO4"  "psram/PSRAM_IO4")  (net "PSRAM_IO5"  "psram/PSRAM_IO5")
  (net "PSRAM_IO6"  "psram/PSRAM_IO6")  (net "PSRAM_IO7"  "psram/PSRAM_IO7")
  (net "PSRAM_IO8"  "psram/PSRAM_IO8")  (net "PSRAM_IO9"  "psram/PSRAM_IO9")
  (net "PSRAM_IO10" "psram/PSRAM_IO10") (net "PSRAM_IO11" "psram/PSRAM_IO11")
  (net "PSRAM_IO12" "psram/PSRAM_IO12") (net "PSRAM_IO13" "psram/PSRAM_IO13")
  (net "PSRAM_IO14" "psram/PSRAM_IO14") (net "PSRAM_IO15" "psram/PSRAM_IO15")
  (net "USB_DP"  "usb/USB_DP")
  (net "USB_DN"  "usb/USB_DN")
  (net "TXRTUNE" "usb/TXRTUNE")
  (net "DISP_SCK"   "disp/SCK")
  (net "DISP_MOSI"  "disp/MOSI")
  (net "DISP_NCS"   "disp/CS")
  (net "DISP_DC"    "disp/DC")
  (net "DISP_NRST"  "disp/NRST")
  (net "DISP_BL_EN" "disp/BL_EN")
  (net "PSHOLD"  "pwr_btn/PSHOLD")
  (net "PWR_BTN" "pwr_btn/PWR_BTN")
  (net "PWR_INT" "pwr_btn/PWR_INT")
  (net "PWR_EN" "buck/EN" "pwr_btn/PWR_EN")
  (net "PG_3V3" "buck/PG" "ldo/EN")
  (net "V1P8"   "ldo/VOUT" "VDDA18PMU" "VDDSMPS" "VDDIO2" "VDDIO3" "flash/VDDIO" "psram/VDD")
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

  ;; LTC6655-2.5 ultra-low-noise 2.5V precision reference shared by 3x AD7380 ADCs.
  ;; Star-node placement: bulk cap belongs at the star pour under adc2, not at pin 7 of vref.
  ;; Three branches from the star fan out to adc1/adc2/adc3 REFIN — do not daisy-chain.
  ;; Per-ADC REFIN bypass: each ad7380-channel module has a 100nF ceramic close to pin 17.
  (sub-block "vref" (ltc6655-vref))

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
    (note "Each ADC: VCC (pin 4) = 3.3V, VLOGIC (pin 2) = 3.3V (tied to VDD; AD7380 VLOGIC operating range is 1.7V..VCC, so the digital interface is 3.3V end-to-end and matches the STM32's VDD-bank GPIOs without level shifting), REGCAP (pin 3) = 1µF to GND only, REFIN (pin 17) tied to VDD via 0R (upgrade to ADR4533 in future rev for full ENOB).")
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
  (net "VREF_2V5" "vref/VREF" "adc1/REFIN" "adc2/REFIN" "adc3/REFIN")
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

  (section "Display" "ST7735S 80×160 TFT — chip details sealed in st7735s-display module"
    (role output)
    (protocol SPI)
    (pins "stm32"
      (group "Display SPI4 + Backlight")
      (pin D10 (as "SPI4_SCK")  "DISP_SCK")
      (pin E16 (as "SPI4_MOSI") "DISP_MOSI")
      (pin F10 (as "PE15")      "DISP_NCS")
      (pin D11 (as "PD10")      "DISP_NRST")
      (pin D14 (as "PE10")      "DISP_DC")
      (pin D16 (as "TIM4_CH2")  "DISP_BL_EN"))
    (note "DISP_BL_EN is on TIM4_CH2 (D16). Drive high for full brightness or configure TIM4 for PWM to dim — 1–20 kHz is fine."))
  (sub-block "disp" (st7735s-display))

  (section "Vibration Motor" "Coin/pager vibration motor — low-side AO3400A driver sealed in vibration-motor module"
    (pins "stm32"
      (pin B16 (as "PB2" "TIM1_CH1") "VIB_PWM"))
    (note "VIB_PWM on TIM1_CH1 (PB2) — firmware can PWM at 1–20 kHz to modulate intensity. Hard on/off also works fine."))
  ;; sub-block placed at design-block top level — sub-block forms aren't evaluated inside sections.
  (sub-block "motor" (vibration-motor))

  (section "Mounting" "PCB standoffs"
    (instance "H1" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10001))
    (instance "H2" a-wurth-wa-smsi-9774020633r
      (pin 1 "GND") (id d3a10002)))

  (section "Fiducials" "0.75mm copper / 2.25mm mask fiducials for pick-and-place vision alignment — 3 on top side as primary alignment triangle, 1 on bottom for back-side flip-and-fly"
    (instance "FID1" fiducial-0p75-2p25 (id b6f1d101))
    (instance "FID2" fiducial-0p75-2p25 (id b6f1d102))
    (instance "FID3" fiducial-0p75-2p25 (id b6f1d103))
    (instance "FID4" fiducial-0p75-2p25 (id b6f1d104))
    (note "FID1/FID2/FID3 should be placed near the corners of the top side forming a non-collinear triangle (typically L-shape, 3-5 mm in from board edge). FID4 mirrors FID1's position on the bottom layer for back-side assembly registration."))

  (port "VBATT" in (rated 3.0 4.2))
  (port "VBUS"  in (rated 4.0 5.5))
  (port "GND"   bidi)

)
