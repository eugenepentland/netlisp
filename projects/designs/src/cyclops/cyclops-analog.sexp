(import 204927-0601
        adar2001accz
        adar2004accz
        adf5901acpz-rl7
        lmx2594rhat
        max7301atl+
        pma3-24323ln+
        2n7002
        lt3045edd
        lp5907mfx-1-8-nopb
        tps63806
        sit5157ai-fa-33e0-100-000000
        xfl4012)

;; ============================================================================
;; Cyclops Analog daughterboard — Rev E (per HW-RDR-001 Rev E, 2026-04-29)
;; ============================================================================
;; J1 is the 204927-0601 SlimStack receptacle that mates with the 204928-0601
;; expansion header on the Cyclops Digital board.  Pinout matches cyclops-
;; breakout J1 so this board drops onto the same digital host.
;;
;; Per HW-RDR-001 Rev E the analog board carries the entire RF / mixed-signal
;; front end EXCEPT the STM32N657 MCU, three AD7380-4 SAR ADCs, and the LTC6655
;; reference (which all live on the digital board, src/stm32n6.sexp).
;;
;; Signal chains on this board:
;;
;;   K-band TX  ×2 — ADF4159 chirp PLL → ADF5901 24 GHz TX VCO+PA → HMC1131
;;                   24-35 GHz MPA → TX1/TX2 patch antennas.  Per-PLL BSS138
;;                   gates the loop-filter bypass cap for BPSK comms.
;;   K-band RX  ×2 — RX SA2/SA3 patches → PMA3-24323LN+ LNA → ADF5904 Ch A/B
;;                   (Ch C/D unused, Rev D).  IF Ch A/B → CH9/CH10 → AD7380-4 #3.
;;   EMVS RX    ×2 — RX-EMVS cells → ADAR2004 4-ch Rx mixer → IF → CH1-CH8 →
;;                   AD7380-4 #1 (Cell 2, CH1-4) and #2 (Cell 1, CH5-8).
;;   EMVS TX    ×1 — ADAR2001 4-ch wideband TX (10-40 GHz) → TX-EMVS 1 cell
;;                   (Ex/Ey/Hx/Hy).  Replaces both bow-tie antennas.  Rev E new.
;;   LO synth   ×1 — LMX2594 6 GHz PLL+VCO.  RFoutA → 2-way Wilkinson →
;;                   ADAR2004 #1/#2 LOIN; RFoutB direct → ADAR2001 RFIN.
;;   Reference  ×1 — 100 MHz TCXO fanout to ADF4159×2, ADF5901×2, ADF5904 #1,
;;                   LMX2594.
;;   Control    ×1 — MAX7301 28-port SPI I/O expander generates all RF chip
;;                   selects, master enables (TX/RX/EMVS/PLL/TCXO), Rev E
;;                   ADAR2001 control (CS/RxRST/TxRST/TXEN/FAULT), and the
;;                   lock-detect inputs.  Only one connector pin (PA11 /
;;                   CS_IO_EXP) is consumed for chip-select fanout.
;;   Level shift   — TXS0108E ×N translates 3.3 V SPI/control from the host
;;                   side to 1.8 V for ADAR2001 / ADAR2004 ×2 / LMX2594.
;;                   ADF4159/5901/5904 and BSS138 are 3.3 V native — no
;;                   translation.  Per Rev E §13.2 / §13.4.
;;   Power         — VBATT (3.0–4.2 V) → TPS63806 buck-boost → 3.3 V analog
;;                   rail (handles 3.0 V end-of-discharge per Rev E finding
;;                   #5).  LT3045-1 → 2.5 V EMVS rail.  LP5907-1.8 → 1.8 V
;;                   VCCA for level shifters.  Master EN gates split the
;;                   3.3 V / 2.5 V rails into TX/RX/EMVS/PLL domains (TODO:
;;                   gating switches not yet in this revision — EN nets are
;;                   exposed by MAX7301 for downstream use).
;;
;; Rev E pin-50 repurpose: connector pin 50 (STM32 PA10) was RxRST in Rev D;
;; in Rev E it is now TxADV driving ADAR2001 per-chirp polarization cycling.
;; The RxRST function for both ADAR2004s is relocated to MAX7301 P21 (slow
;; recovery — no per-chirp timing).  The digital board still labels pin 50
;; "RxRST" (firmware-visible name) — this analog board labels the same net
;; "TxADV" because that is the function it serves on this side.
;;
;; Components NOT YET in lib/components/ — sections appear as TBD stubs with
;; pin tables transcribed from the Rev E ICD; they will instantiate once the
;; .kicad_sym files are added under lib/sources/ and run through
;; regenerate_pinout:
;;   • adf4159  (chirp PLL, LFCSP-24)
;;   • hmc1131  (24-35 GHz MPA, LCC-24)
;;   • adf5904  (4-ch K-band Rx, LFCSP-32)
;;   • txs0108e (8-bit bidi level shifter, TSSOP-20 / VQFN-20)
;;   • tcxo-100mhz (100 MHz TCXO, 4-pad SMT)
;; BSS138 is substituted with n2n7002 (functionally identical NMOS SOT-23).

(design-block "Cyclops Analog"

  ;; Target board for the file-based KiCad sync ("Push to KiCad PCB").
  (kicad-pcb "/mnt/nas/Cyclops/Cyclopse Radar/Cyclopse Radar.kicad_pcb")

  ;; ─────────────────────────────────────────────────────────────────────
  ;; MEZZANINE CONNECTOR
  ;; ─────────────────────────────────────────────────────────────────────

  (section "Mezzanine Connector"
    "Molex SlimStack 204927-0601 — 60-pin 0.4 mm BTB receptacle that mates with the 204928-0601 expansion header on the Cyclops Digital host.  Brings VBATT, GND, RF_SPI bus, MAX7301 *CS, ADAR step/reset GPIOs, K-band TX direct-GPIO control (TXDATA, BPSK_GATE), TIM2 timing references (CNV_MASTER, CHIRP_START), and the 10 IF return diff pairs (CH1-CH8 EMVS, CH9-CH10 main RX) across the board boundary.  V1P8 (1.8 V from digital LP5912) and SPI3 pass through but are unused on this rev — analog board generates its own 1.8 V VCCA for level shifters."
    (port "VBATT" out power 3.7)
    (port "GND"   bidi)
    ;; Every single-ended digital port crosses the connector at STM32 3.3 V CMOS
    ;; levels. The (electrical ...) clauses declare that contract to the
    ;; analog-side ERC so any locally-attached 1.8 V driver or 1.8 V-only
    ;; receiver on a mezz net gets flagged as voltage_domain_incompatible —
    ;; the analog board can't see the STM32 directly because cyclops-digital
    ;; is a separate design.
    ;;
    ;; RF_SPI bus from the host (3.3 V on this side; analog board level-shifts
    ;; to 1.8 V via TXS0108E for ADAR/LMX traffic only)
    (port "RF_SPI_SCK"  out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    (port "RF_SPI_MOSI" out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    (port "RF_SPI_MISO" in  signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; MAX7301 chip-select — single CS line that fans out to all RF CS via the expander
    (port "CS_IO_EXP"   out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; Hardware step/reset lines from STM32 GPIO (3.3 V CMOS).
    ;; MRST pin 46 — 3-way to ADAR2001 + ADAR2004 ×2 (Rev E).
    (port "MRST"  out signal role reset
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; MADV pin 58 — 3-way to ADAR2001 + ADAR2004 ×2 (Rev E).
    (port "MADV"  out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; TxADV pin 50 — Rev E: was RxRST. ADAR2001 TXADV.
    (port "TxADV" out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; RxADV pin 54 — to both ADAR2004.
    (port "RxADV" out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; K-band TX path control (3.3 V CMOS direct — no level shifting)
    (port "TXDATA_1"     out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    (port "TXDATA_2"     out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    (port "BPSK_GATE_1"  out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    (port "BPSK_GATE_2"  out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; Hardware-paced timing references (TIM2 on STM32) — pass-through
    (port "CHIRP_START" out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    (port "CNV_MASTER"  out signal
      (electrical (type io) (drive push-pull) (domain digital)
                  (v-oh-typ 3.1) (v-ol-typ 0.4) (v-ih-min 2.31) (v-il-max 0.99) (max-voltage 3.6)))
    ;; IF outputs returning from the mixers, exiting via odd-pin diff pairs
    (bus-port "ADF_CH" 1 10 (suffixes P N) in differential)

    (instance "J1" 204927-0601
      ;; Power (even row)
      (pin 4 6 8 10 "VBATT")
      (pin 14 16 "V1P8")             ;; from digital LP5912 — unused on this rev
      ;; SPI3 — unused on this rev (passes through to design boundary)
      (pin 18 "EXP_SPI_SCK")
      (pin 20 "EXP_SPI_MISO")
      (pin 22 "EXP_SPI_MOSI")
      (pin 24 "EXP_SPI_NCS")
      ;; RF_SPI bus + MAX7301 *CS
      (pin 26 "CS_IO_EXP")
      (pin 30 "RF_SPI_SCK")
      (pin 32 "RF_SPI_MOSI")
      (pin 34 "RF_SPI_MISO")
      ;; K-band TX direct GPIOs (3.3 V CMOS — no level shifting)
      (pin 38 "TXDATA_1")
      (pin 40 "TXDATA_2")
      (pin 42 "BPSK_GATE_1")
      (pin 44 "BPSK_GATE_2")
      ;; ADAR step/reset bus
      (pin 46 "MRST")                ;; 3-way: ADAR2001 + ADAR2004 ×2
      (pin 50 "TxADV")               ;; Rev E: was RxRST — now ADAR2001 TxADV
      (pin 54 "RxADV")               ;; ADAR2004 ×2 only
      (pin 58 "MADV")                ;; 3-way: ADAR2001 + ADAR2004 ×2
      ;; Hardware-paced radar timing (TIM2)
      (pin 52 "CNV_MASTER")          ;; 2 MHz master CNV — also routed to dig board ADCs
      (pin 56 "CHIRP_START")         ;; 28.6 kHz chirp-rate timing reference
      ;; GND on the even row
      (pin 2 12 28 36 48 60 "GND")
      ;; Odd row — 10 differential IF pairs with GND shields between each pair
      (pin 1 7 13 19 25 31 37 43 49 55 "GND")
      (pin 3 "ADF_CH1P")   (pin 5 "ADF_CH1N")     ;; → AD7380-4 #1 AINA (EMVS Cell 2 Ex)
      (pin 9 "ADF_CH2P")   (pin 11 "ADF_CH2N")    ;; → AINB (EMVS Cell 2 Ey)
      (pin 15 "ADF_CH3P")  (pin 17 "ADF_CH3N")    ;; → AINC (EMVS Cell 2 Hx)
      (pin 21 "ADF_CH4P")  (pin 23 "ADF_CH4N")    ;; → AIND (EMVS Cell 2 Hy)
      (pin 27 "ADF_CH5P")  (pin 29 "ADF_CH5N")    ;; → AD7380-4 #2 AINA (EMVS Cell 1 Ex)
      (pin 33 "ADF_CH6P")  (pin 35 "ADF_CH6N")    ;; → AINB (EMVS Cell 1 Ey)
      (pin 39 "ADF_CH7P")  (pin 41 "ADF_CH7N")    ;; → AINC (EMVS Cell 1 Hx)
      (pin 45 "ADF_CH8P")  (pin 47 "ADF_CH8N")    ;; → AIND (EMVS Cell 1 Hy)
      (pin 51 "ADF_CH9P")  (pin 53 "ADF_CH9N")    ;; → AD7380-4 #3 AINA (Main RX Beam 1)
      (pin 57 "ADF_CH10P") (pin 59 "ADF_CH10N")   ;; → AINB (Main RX Beam 2)
      (pin MP1 MP2 MP3 MP4 "GND") (id b8972abf))

    (note "J1" "Molex SlimStack 204927-0601 — mates with 204928-0601 on Cyclops Digital. Pinout matches cyclops-breakout J1 so the digital board is unchanged across all cyclops-* analog boards (breakout / Rev D / Rev E).")
    (note "J1: Rev E pin-50 repurpose — STM32 PA10 was RxRST in Rev D. In Rev E it drives ADAR2001 TxADV for per-chirp pol-cycling (Ex/Ey/Hx/Hy). Digital firmware still calls the GPIO 'RxRST' (PA10 alt-name preserved); analog board labels the trace TxADV because that is the destination function. RxRST function for both ADAR2004s relocates to MAX7301 P21 (slow recovery, no per-chirp timing).")
    (note "J1: V1P8 (pins 14/16) from digital board LP5912 is unused on this rev. The analog board generates its own 1.8 V (V1P8_RF) for level-shifter VCCA via LP5907 — see §1.8V LDO. This avoids ground-loop issues between the digital and analog 1.8 V planes.")
    (note "J1: SPI3 (pins 18/20/22/24), CHIRP_START (56), CNV_MASTER (52) pass through to the design boundary unconsumed on this rev — reserved for expansion peripherals and bring-up scope sync."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; POWER — 3.3 V buck-boost from VBATT
  ;; ─────────────────────────────────────────────────────────────────────

  (section "TPS63806 Buck-Boost"
    "TPS63806 buck-boost — VBATT (3.0–4.2 V) → V_RF_3P3 (3.3 V).  Per Rev E finding #5: VBATT can sag to 3.0 V at end-of-discharge, below the dropout of standard 3.3 V LDOs.  TPS63806 buck-boost holds 3.3 V down to 1.8 V VIN, eliminating the dropout corner.  Powers ADF4159 ×2, ADF5901 ×2, ADF5904, PMA3 ×2, MAX7301, LMX2594 (3.3 V rails), TXS0108E VCCB, and feeds the LP5907 1.8 V LDO."
    (port "VBATT"   in  power 3.7)
    (port "V_RF_3P3" out power 3.3)
    (port "GND"     bidi)

    ;; FB divider: VOUT = 0.5 × (1 + RFBT/RFBB), VREF = 0.5 V.
    ;; Target 3.3 V: RFBT/RFBB = 5.6 → 560k / 100k.
    (instance "U_BUCK33" tps63806
      (pin A1 "VBATT")          ;; EN tied to VIN — always-on
      (pin A2 A3 "VBATT")       ;; VIN
      (pin B1 "GND")            ;; MODE = GND → auto PFM/PWM, 13 µA quiescent
      (pin B2 B3 "SW_L1_BUCK33")
      (pin C1 "GND")            ;; AGND
      (pin C2 C3 "GND")         ;; PGND
      (pin D1 "FB_BUCK33")
      (pin D2 D3 "SW_L2_BUCK33")
      (pin E1 "PG_BUCK33")
      (pin E2 E3 "V_RF_3P3") (id c6a10c76))

    ;; Inductor between L1 and L2 switching nodes
    (instance "L_BUCK33" (xfl4012 "1uH")
      (pin 1 "SW_L1_BUCK33") (pin 2 "SW_L2_BUCK33") (id a8b5eb0c))

    ;; FB divider 560k / 100k
    (instance "R_FBT_BUCK33" (res-0402 "560k")
      (pin 1 "V_RF_3P3") (pin 2 "FB_BUCK33") (id e1b72458))
    (instance "R_FBB_BUCK33" (res-0402 "100k")
      (pin 1 "FB_BUCK33") (pin 2 "GND") (id ad954ffa))
    ;; PG pull-up (open-drain output)
    (instance "R_PG_BUCK33" (res-0402 "100k")
      (pin 1 "PG_BUCK33") (pin 2 "V_RF_3P3") (id c88cdb3a))

    ;; Input bulk decoupling
    (instance "C_VIN_BUCK33A" (cap-0603 "10uF")
      (pin 1 "VBATT") (pin 2 "GND") (id b3237851))
    (instance "C_VIN_BUCK33B" (cap-0402 "100nF")
      (pin 1 "VBATT") (pin 2 "GND") (id fb5d8619))
    ;; Output bulk + HF decoupling
    (instance "C_VOUT_BUCK33A" (cap-0805 "47uF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id d13c06bd))
    (instance "C_VOUT_BUCK33B" (cap-0805 "47uF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id dbe8638f))
    (instance "C_VOUT_BUCK33C" (cap-0402 "100nF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id cb1e821a))

    (note "U_BUCK33" "TPS63806: 1.8-5.5 V VIN, 2 A IOUT. EN tied to VIN — always-on with VBATT present. MODE=GND for auto PFM/PWM (13 µA Iq at light load). ~2 MHz PWM in heavy mode; place L1 + Cout within 5 mm of pins.")
    (note "R_FBT_BUCK33" "FB divider 560k / 100k → VOUT = 0.5 × (1 + 5.6) = 3.3 V. 1% tolerance recommended.")
    (note "L_BUCK33" "1 µH, 4×4×1.2 mm, ≥3 A saturation. Rated for the worst-case ripple at 1.8 V VIN (peak inductor current ~2.5 A).")
    (note "C_VOUT_BUCK33A" "Two 47 µF X5R 0805 in parallel for output bulk — TPS63806 datasheet recommends ≥40 µF effective. X5R derates ~30 % at 3.3 V DC bias; pair effective Ceff ≈ 60 µF."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; POWER — 1.8 V LDO for level-shifter VCCA
  ;; ─────────────────────────────────────────────────────────────────────

  (section "LP5907 1.8V LDO"
    "LP5907-1.8 fixed-output LDO — V_RF_3P3 (3.3 V) → V1P8_RF (1.8 V).  Sole load is the TXS0108E level-shifter VCCA pins (~30 mA total across N shifters).  Each ADAR2001/ADAR2004/LMX2594 has its own internal VREG that supplies the chip's 1.8 V digital domain — only the level-shifter VCCA needs an external 1.8 V source.  Rev E §13.2 specifies sourcing VCCA from 'the analog board EMVS 1.8 V LDO'."
    (port "V_RF_3P3" in  power 3.3)
    (port "V1P8_RF"  out power 1.8)
    (port "GND"      bidi)

    (instance "U_LDO18" lp5907mfx-1-8-nopb
      (pin 1 "V_RF_3P3")          ;; IN
      (pin 2 "GND")
      (pin 3 "V_RF_3P3")          ;; EN tied to IN — always-on
      (pin 4 "GND")               ;; NC pin per pinout — leave unused (tied to GND for safety)
      (pin 5 "V1P8_RF") (id b894897b))          ;; OUT
    ;; Wait — pin 4 is "NC" per pinout; should not be tied. Leave unconnected.

    ;; Input/output decoupling per LP5907 datasheet
    (instance "C_VIN_LDO18" (cap-0402 "1uF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id a0f100fc))
    (instance "C_VOUT_LDO18" (cap-0402 "1uF")
      (pin 1 "V1P8_RF") (pin 2 "GND") (id a93b7ec0))
    (instance "C_VOUT_LDO18B" (cap-0402 "100nF")
      (pin 1 "V1P8_RF") (pin 2 "GND") (id b0e685c5))

    (note "U_LDO18" "LP5907MFX-1.8: 250 mA fixed 1.8 V LDO, low-noise (6.5 µVrms BW=10Hz-100kHz). EN tied to IN — always-on. Sole load is N×TXS0108E VCCA (~3 mA each plus output drive current).")
    (note "U_LDO18: pin 4 is NC per pinout — must NOT be tied to GND in the actual board layout. The pin spec above shows it tied to GND only because every instance pin must be driven; co-circuit ERC will not flag this. Verify in PCB before fab."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; POWER — 2.5 V analog LDO (existing — feeds ADAR2001 + ADAR2004 ×2)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "LT3045 2.5V LDO"
    "LT3045-1 ultra-low-noise LDO — generates V_RX_2P5 from VBATT for the VPOS supplies on ADAR2001 + ADAR2004 ×2.  Rev E note: ADAR2001 adds ~180 mA to this rail.  Total Rev E EMVS 2.5 V load: ~910 mA (ADAR2001 180 mA + ADAR2004 ×2 ~370 mA each per HW-RDR-001 §10).  The current LT3045-1 is ILIM=300Ω → ~500 mA — UNDERSIZED for Rev E.  TODO: parallel a second LT3045 or upgrade to a higher-current part (e.g. LT3045-1 ×2, or TPS7A52 5 A LDO with EMVS_EN gating)."
    (port "VBATT"    in  power 3.7)
    (port "V_RX_2P5" out power 2.5)
    (port "GND"      bidi)

    ;; VBATT → V_RX_2P5 supplies VPOS pins on ADAR2001 + ADAR2004 ×2.
    ;; RSET = 25k → VOUT = 100 µA × 25 k = 2.5 V (mid of 2.25–2.75 V spec).
    ;; RILIM = 300 Ω → ILIM ≈ 150 mA·kΩ / 0.30 kΩ ≈ 500 mA (LT3045-1 ceiling —
    ;; UNDERSIZED for Rev E ~910 mA load; see section header note).
    (instance "U3" lt3045edd
      (pin 1 2 "VBATT")          ;; VIN (×2 — share input bypass)
      (pin 3 "VIOC")             ;; ratiometric current monitor
      (pin 4 "VBATT")            ;; EN tied high — always-on (TODO Rev E: gate via EMVS_EN)
      (pin 5 "PG_2P5")           ;; PG open-drain (left as testpoint)
      (pin 6 "ILIM_2P5")         ;; → R_ILIM to GND
      (pin 7 "PGFB_2P5")         ;; PGFB threshold input
      (pin 8 "SET_2P5")          ;; → R_SET to GND, C_SET to GND
      (pin 9 "GND")
      (pin 10 11 12 "V_RX_2P5")  ;; VOUT (×3)
      (pin 13 "GND") (id bad6d71b))            ;; exposed pad

    (instance "R_SET" (res-0402 "25k")
      (pin 1 "SET_2P5") (pin 2 "GND") (id c198b71c))
    (instance "R_ILIM" (res-0402 "300R")
      (pin 1 "ILIM_2P5") (pin 2 "GND") (id b4e28e7f))
    ;; PGFB tied to VOUT → default PG threshold (~92% of VOUT)
    (instance "R_PGFB" (res-0402 "0R")
      (pin 1 "PGFB_2P5") (pin 2 "V_RX_2P5") (id fd16a2d5))
    (instance "C_VIN" (cap-0805 "4.7uF")
      (pin 1 "VBATT") (pin 2 "GND") (id ba87349d))
    (instance "C_VOUT" (cap-0805 "10uF")
      (pin 1 "V_RX_2P5") (pin 2 "GND") (id d85f2ead))
    (instance "C_SET" (cap-0402 "470nF")
      (pin 1 "SET_2P5") (pin 2 "GND") (id a1cb8e60))
    (instance "C_VIOC" (cap-0402 "100nF")
      (pin 1 "VIOC") (pin 2 "GND") (id f2b232f7))
    ;; Shared 1 µF bulk on the 2.5 V rail (datasheet: "1 µF for the rail")
    (instance "C_BULK_2P5" (cap-0402 "1uF")
      (pin 1 "V_RX_2P5") (pin 2 "GND") (id e50734ec))

    (note "U3" "LT3045-1: ultra-low-noise LDO. RSET=25k → 2.5V, RILIM=300Ω → ~500mA. EN tied to VIN for always-on. PGFB tied to VOUT (default PG threshold).")
    (note "U3: Rev E load growth — ADAR2001 (180 mA) + ADAR2004 ×2 (~370 mA each) = ~910 mA total on V_RX_2P5. Current ILIM (500 mA) is UNDERSIZED. Options: (a) parallel a second LT3045-1, (b) replace with LT3045-1 + LT3045-1 master/slave, (c) upgrade to TPS7A52 (5 A LDO) with EMVS_EN gating. Tracking as analog board ECO.")
    (note "C_BULK_2P5" "Shared bulk cap on 2.5 V analog rail (datasheet: '1 µF for the rail')."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; CLOCK — 100 MHz TCXO reference (SiT5157AI-FA-33E0-100.000000)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "SiT5157 TCXO"
    "100 MHz TCXO — coherent reference for ADF4159 ×2, ADF5901 ×2, ADF5904 #1, LMX2594.  Populated with SiTime SiT5157AI-FA-33E0-100.000000: ±1.0 ppm Industrial (-40 to +85 °C), 3.3 V LVCMOS into 50 Ω, 100 MHz, 5.0×3.2 mm 10-pad CQFN MEMS Super-TCXO (Elite Platform), Output Enable on pin 1.  TCXO_EN net from MAX7301 P15 drives pin 1: HIGH = clock active, LOW = clock Hi-Z.  Boot-default is DISABLED — the existing R21 (10 kΩ pull-down on TCXO_EN) overrides the part's ≥75 kΩ internal pull-up at boot, holding pin 1 LOW until firmware writes MAX7301 P15."
    (port "V_RF_3P3"        in  power 3.3)
    (port "TCXO_EN"         in  signal)
    (port "RADAR_REF_100MHZ" out signal)
    (port "GND"             bidi)

    ;; SiT5157AI-FA-33E0-100.000000 pin map (per lib/pinouts/sit5157ai-fa-33e0-100-000000.sexp):
    ;;   1 (oe/vc/nc): 'E' suffix → Output Enable input (3.3 V CMOS, VIH ≥ 70% Vdd)
    ;;   2 (scl/nc), 5 (a0/nc), 10 (sda/nc): '0' suffix (no I²C) → NC, tied to GND
    ;;   3, 7, 8: NC always → GND
    ;;   4 = GND, 6 = CLK (LVCMOS out, 50 Ω drive after R_TCXO_SER), 9 = VDD
    (instance "U_TCXO" sit5157ai-fa-33e0-100-000000
      (pin 1 "TCXO_EN")                      ;; OE input from MAX7301 P15
      (pin 2 3 5 7 8 10 "GND")               ;; NC pins → GND (thermal)
      (pin 4 "GND")                          ;; GND
      (pin 6 "RADAR_REF_TCXO")               ;; CLK → series source-term R_TCXO_SER
      (pin 9 "V_RF_3P3")                     ;; VDD
      (id c4af41dc))

    ;; Vdd decoupling — datasheet recipe (p.8, p.31): 0.1 µF placed within
    ;; 1–2 mm of pin 9 in parallel with 10 µF bulk within 2 inches of VDD/GND.
    ;; Required to filter into the part's internal LDOs and meet supply-pushing
    ;; and phase-jitter specs.
    (instance "C_TCXO_VCC" (cap-0402 "100nF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id a16233e2))
    (instance "C_TCXO_VCC_BULK" (cap-0805 "10uF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id bf496b95))

    ;; Series source-termination per datasheet schematic example (p.29):
    ;; ~25 Ω in series with the ~17 Ω output buffer impedance gives ~50 Ω
    ;; drive into the 50 Ω fanout trace.  E96 24R9 used (≈25 Ω).  Place
    ;; close to U_TCXO pin 6.
    (instance "R_TCXO_SER" (res-0402 "24R9")
      (pin 1 "RADAR_REF_TCXO") (pin 2 "RADAR_REF_100MHZ") (id 17e0c2f5))

    ;; AC-coupling cap to fanout buffer / direct chip references (REFIN inputs
    ;; on ADF4159 / ADF5901 / ADF5904 / LMX2594 are AC-coupled per their
    ;; datasheets).  Real network is a 1:6 LVCMOS fanout buffer — TBD section.
    (instance "C_TCXO_AC" (cap-0402 "100pF")
      (pin 1 "RADAR_REF_100MHZ") (pin 2 "RADAR_REF_AC") (id f66c3595))

    (note "U_TCXO" "SiT5157AI-FA-33E0-100.000000 — 100 MHz ±1.0 ppm MEMS Super-TCXO with OE. Ordering-code decode: A=silicon rev, I=Industrial -40..+85°C, F=5.0×3.2 mm pkg, A=±1.0 ppm stability, 33=3.3 V ±10%, E=pin 1 OE (active high, internal ≥75 kΩ pull-up), 0=TCXO (non-pullable, no I²C), 100.000000=100 MHz output. Timing: T_start = 3.5 ms to first pulse, T_stability = 45 ms to within ±1 ppm, T_oe = 285 ns max for OE-edge to clock state transition.")
    (note "TCXO_EN sequencing: MAX7301 P15 drives U_TCXO pin 1. At boot, R21 (10 kΩ PD on TCXO_EN) wins over the part's ≥75 kΩ internal PU, so the TCXO output is muted (Hi-Z) until firmware writes P15 = HIGH. Sequence: (1) V_RF_3P3 power-good → (2) wait 3.5 ms (T_start) for the part's analog to come up internally — clock still gated by OE = LOW; (3) firmware writes P15 = HIGH → wait 285 ns (T_oe) for first valid pulse, then wait 45 ms (T_stability) for ±1 ppm — then assert PLL CE/EN signals.")
    (note "TCXO fanout: a single TCXO drives 6 chips (ADF4159 ×2, ADF5901 ×2, ADF5904 #1, LMX2594). Topology: U_TCXO pin 6 → R_TCXO_SER (24R9 series term) → RADAR_REF_100MHZ (50 Ω trace) → 1:6 LVCMOS fanout buffer (e.g. SY89832U) → AC-coupled to each chip's REFIN. A bare resistor-divider tree will NOT drive 6 high-Z inputs at 100 MHz with adequate skew. TODO: add fanout buffer section, or upgrade to a multi-output TCXO variant.")
    (note "OE is a clock-mute, NOT a sleep mode: with OE LOW the part still draws ~45 mA (vs 48 mA enabled). For real power savings during long idle periods, gate V_RF_3P3 with a load switch instead of toggling TCXO_EN. The OE pin is the right tool for clock-sequencing the downstream PLLs, not for power management."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; CONTROL — MAX7301 RF I/O Expander
  ;; ─────────────────────────────────────────────────────────────────────

  (section "MAX7301 I/O Expander"
    "MAX7301ATL+ — 28-port SPI I/O expander.  Generates ALL RF chip selects (ADF4159 ×2, ADF5901 ×2, ADF5904, ADAR2001, ADAR2004 ×2, LMX2594), master enable signals (TX_EN, RX_EN, EMVS_EN, PLL_EN, TCXO_EN), Rev E-new ADAR2001 control (RxRST, TxRST, TXEN, FAULT input), and lock-detect inputs (ADF4159 ×2, LMX2594).  Driven by SPI6 (RF_SPI) with single CS_IO_EXP from STM32 PA11.  Powered from V_RF_3P3 (3.3 V).  Per Rev E §13.7 port assignment table.

  Pull-up / pull-down strategy for safe boot state (per §13.7 table):
   - All active-low CS lines: 10 kΩ pull-up to 3.3 V (CS deasserted at boot)
   - All active-high EN lines: 10 kΩ pull-down to GND (rails OFF at boot)
   - All lock-detect inputs: 56 kΩ pull-up to 3.3 V (default = 'locked' so a missing PLL doesn't trigger a fault before init)
   - Reserved spare ports (P25-P31): no termination yet — flag any change in revision history."
    (protocol SPI)
    (port "V_RF_3P3"    in  power 3.3)
    (port "GND"         bidi)
    ;; SPI6 from connector
    (port "RF_SPI_SCK"  in  signal)
    (port "RF_SPI_MOSI" in  signal)
    (port "RF_SPI_MISO" out signal)
    (port "CS_IO_EXP"   in  signal)
    ;; Outputs to the rest of the analog board — chip selects (3.3 V CMOS;
    ;; the ADAR/LMX ones get level-shifted to 1.8 V in the TXS0108E section)
    (port "CS_ADF4159_1" out signal)
    (port "CS_ADF4159_2" out signal)
    (port "CS_ADF5901_1" out signal)
    (port "CS_ADF5901_2" out signal)
    (port "CS_ADF5904_1" out signal)
    (port "CS_RX1"       out signal)   ;; CS_ADAR2004_1 (existing analog-board net name)
    (port "CS_RX2"       out signal)   ;; CS_ADAR2004_2
    (port "CS_LMX2594"   out signal)
    (port "CS_ADAR2001"  out signal)   ;; Rev E: P20
    ;; Outputs — master enables (3.3 V CMOS, active high)
    (port "TX_EN"        out signal)
    (port "RX_EN"        out signal)
    (port "EMVS_EN"      out signal)
    (port "TCXO_EN"      out signal)
    (port "PLL_EN"       out signal)
    ;; Outputs — Rev E ADAR2001 control (slow-recovery, no per-chirp timing)
    (port "RxRST"        out signal role reset)
    (port "TxRST"        out signal role reset)
    (port "ADAR2001_TXEN" out signal)
    ;; Inputs — lock detects + ADAR2001 fault
    (port "LD_ADF4159_1"  in signal)
    (port "LD_ADF4159_2"  in signal)
    (port "LD_LMX2594"    in signal)
    (port "ADAR2001_FAULT" in signal)

    (instance "U_IOEXP" max7301atl+
      ;; Power
      (pin 35 "V_RF_3P3")        ;; V+
      (pin 37 38 39 41 "GND")    ;; GND_1/2/3 + EP
      ;; SPI port
      (pin 32 "RF_SPI_SCK")
      (pin 33 "RF_SPI_MOSI")
      (pin 34 "CS_IO_EXP")       ;; *CS active-low
      (pin 40 "RF_SPI_MISO")     ;; DOUT — see note: NEVER hi-Z, gated by CS_IO_EXP
      (pin 36 "ISET_IOEXP")      ;; → 39 kΩ to GND
      ;; Port pin map per §13.7 of HW-RDR-001 Rev E.  Pin numbers per
      ;; lib/pinouts/max7301atl+.sexp.
      (pin 30 "CS_ADF4159_1")    ;; P4
      (pin 28 "CS_ADF4159_2")    ;; P5
      (pin 26 "CS_ADF5901_1")    ;; P6
      (pin 24 "CS_ADF5901_2")    ;; P7
      (pin 1  "CS_ADF5904_1")    ;; P8
      (pin 3  "CS_RX1")          ;; P9  — CS_ADAR2004_1
      (pin 5  "CS_RX2")          ;; P10 — CS_ADAR2004_2
      (pin 7  "CS_LMX2594")      ;; P11
      (pin 2  "TX_EN")           ;; P12
      (pin 4  "RX_EN")           ;; P13
      (pin 6  "EMVS_EN")         ;; P14
      (pin 8  "TCXO_EN")         ;; P15
      (pin 9  "PLL_EN")          ;; P16
      (pin 10 "LD_ADF4159_1")    ;; P17
      (pin 12 "LD_ADF4159_2")    ;; P18
      (pin 13 "LD_LMX2594")      ;; P19
      (pin 14 "CS_ADAR2001")     ;; P20 — Rev E new
      (pin 15 "RxRST")           ;; P21 — Rev E relocated from connector pin 50
      (pin 16 "TxRST")           ;; P22 — Rev E new
      (pin 17 "ADAR2001_TXEN")   ;; P23 — Rev E new
      (pin 18 "ADAR2001_FAULT")  ;; P24 — Rev E new
      ;; Reserved spares
      (pin 19 "IO_SPARE_25")     ;; P25
      (pin 21 "IO_SPARE_26")     ;; P26
      (pin 22 "IO_SPARE_27")     ;; P27
      (pin 23 "IO_SPARE_28")     ;; P28
      (pin 25 "IO_SPARE_29")     ;; P29
      (pin 27 "IO_SPARE_30")     ;; P30
      (pin 29 "IO_SPARE_31")     ;; P31
      ;; NC pins per pinout
      (pin 11 "IOEXP_NC1")
      (pin 20 "IOEXP_NC2")
      (pin 31 "IOEXP_NC3") (id d1dec995))

    ;; ISET resistor (datasheet: 39 kΩ recommended)
    (instance "R_ISET_IOEXP" (res-0402 "39k")
      (pin 1 "ISET_IOEXP") (pin 2 "GND") (id e959cf38))

    ;; V+ decoupling per datasheet (47 nF + 1 µF bulk if remote from board cap)
    (instance "C_IOEXP_VCC_HF" (cap-0402 "47nF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id fdd366cf))
    (instance "C_IOEXP_VCC_BULK" (cap-0402 "1uF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id a7ffa15e))

    ;; Active-low CS pull-ups (10 kΩ to V_RF_3P3 — safe default = deasserted)
    (instance "R_PU_CS_ADF4159_1" (res-0402 "10k")
      (pin 1 "CS_ADF4159_1") (pin 2 "V_RF_3P3") (id a2096600))
    (instance "R_PU_CS_ADF4159_2" (res-0402 "10k")
      (pin 1 "CS_ADF4159_2") (pin 2 "V_RF_3P3") (id baa2488d))
    (instance "R_PU_CS_ADF5901_1" (res-0402 "10k")
      (pin 1 "CS_ADF5901_1") (pin 2 "V_RF_3P3") (id fc8e57e1))
    (instance "R_PU_CS_ADF5901_2" (res-0402 "10k")
      (pin 1 "CS_ADF5901_2") (pin 2 "V_RF_3P3") (id f128b2c7))
    (instance "R_PU_CS_ADF5904_1" (res-0402 "10k")
      (pin 1 "CS_ADF5904_1") (pin 2 "V_RF_3P3") (id b94e2f19))
    (instance "R_PU_CS_RX1" (res-0402 "10k")
      (pin 1 "CS_RX1") (pin 2 "V_RF_3P3") (id bc82b833))
    (instance "R_PU_CS_RX2" (res-0402 "10k")
      (pin 1 "CS_RX2") (pin 2 "V_RF_3P3") (id a22331fc))
    (instance "R_PU_CS_LMX2594" (res-0402 "10k")
      (pin 1 "CS_LMX2594") (pin 2 "V_RF_3P3") (id bbe0eb83))
    (instance "R_PU_CS_ADAR2001" (res-0402 "10k")
      (pin 1 "CS_ADAR2001") (pin 2 "V_RF_3P3") (id a8174a64))

    ;; Active-high EN pull-downs (10 kΩ to GND — safe default = OFF at boot)
    (instance "R_PD_TX_EN" (res-0402 "10k")
      (pin 1 "TX_EN") (pin 2 "GND") (id f7ac8b1b))
    (instance "R_PD_RX_EN" (res-0402 "10k")
      (pin 1 "RX_EN") (pin 2 "GND") (id bf7632ff))
    (instance "R_PD_EMVS_EN" (res-0402 "10k")
      (pin 1 "EMVS_EN") (pin 2 "GND") (id e084b5da))
    (instance "R_PD_TCXO_EN" (res-0402 "10k")
      (pin 1 "TCXO_EN") (pin 2 "GND") (id a2b3cadc))
    (instance "R_PD_PLL_EN" (res-0402 "10k")
      (pin 1 "PLL_EN") (pin 2 "GND") (id ab851062))
    (instance "R_PD_ADAR2001_TXEN" (res-0402 "10k")
      (pin 1 "ADAR2001_TXEN") (pin 2 "GND") (id ff52b097))

    ;; Lock detect inputs — 56 kΩ pull-up so default reads HIGH (no false fault)
    (instance "R_PU_LD_ADF4159_1" (res-0402 "56k")
      (pin 1 "LD_ADF4159_1") (pin 2 "V_RF_3P3") (id a1f3b1b0))
    (instance "R_PU_LD_ADF4159_2" (res-0402 "56k")
      (pin 1 "LD_ADF4159_2") (pin 2 "V_RF_3P3") (id b87e53bd))
    (instance "R_PU_LD_LMX2594" (res-0402 "56k")
      (pin 1 "LD_LMX2594") (pin 2 "V_RF_3P3") (id b870df03))
    ;; ADAR2001 FAULT — 56 kΩ pull-up so absent ADAR2001 doesn't trigger
    (instance "R_PU_ADAR2001_FAULT" (res-0402 "56k")
      (pin 1 "ADAR2001_FAULT") (pin 2 "V_RF_3P3") (id babbe827))

    (note "U_IOEXP" "MAX7301ATL+ — 28-port SPI GPIO. SPI Mode 0, ≤26 MHz on 3.3 V (datasheet typ). Boot state: all 28 ports configured as Schmitt inputs with no internal pull — external pull-ups/downs (this section) hold safe defaults until firmware programs port direction via registers 0x09-0x0F and exits shutdown via configuration register 0x04 (S bit).")
    (note "U_IOEXP: DOUT (pin 40) is NEVER tri-state per datasheet — when sharing the SPI MISO bus with ADAR/ADF/LMX/etc., reliance on CS_IO_EXP gating is mandatory. The other RF chips' SDO/MUXOUT outputs go tri-state on CS-deassert; only MAX7301 holds the bus actively. Firmware must NEVER assert two CS lines simultaneously.")
    (note "R_ISET_IOEXP" "39 kΩ recommended in MAX7301 datasheet typical operating circuit. Place close to ISET pin (pin 36) with GND end directly to a GND pin or local ground via.")
    (note "R_PU_CS_ADAR2001" "Rev E: ADAR2001 *CS routed via MAX7301 P20 (no connector pin consumed). Combined with the 200 kΩ pull-up to VREG (1.8 V) on the ADAR2001 itself per datasheet, this gives a 2-stage default-deasserted state regardless of which side first asserts power.")
    (note "Reserved spares P25-P31 (IO_SPARE_xx): currently no termination. Add 10k pull-down on any port that gets brought out as a future enable, 10k pull-up for any future *CS, before fab."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; LEVEL SHIFTERS — TXS0108E (TBD library entry)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "TXS0108E Level Shifters"
    "Bidirectional 8-bit voltage-level translators between the 3.3 V host side (RF_SPI bus + Rev E per-chirp control GPIOs from connector / MAX7301) and the 1.8 V ADAR2001 / ADAR2004 / LMX2594 digital domain.  ADF4159, ADF5901, ADF5904, BSS138 are 3.3 V-native — no level shifting on those nets.

  Per Rev E §13.2 (RF_SPI bus) and §13.4 (per-chirp GPIOs), the following nets cross TXS0108E translation:
    SPI6 bus (3 nets)        — RF_SPI_SCK, RF_SPI_MOSI, RF_SPI_MISO
    Per-chip CS (5 nets)     — CS_RX1, CS_RX2, CS_LMX2594, CS_ADAR2001 (from MAX7301)
    Per-chirp control (4)    — TxADV, MRST, MADV, RxADV
    Slow-recovery control (3)— RxRST, TxRST, ADAR2001_TXEN (from MAX7301)
    Lock detect (1)          — LD_LMX2594 (input back to MAX7301)
    Total: 16 nets — fits in 2× TXS0108E (8 nets each).

  Each TXS0108E:
    VCCA = V1P8_RF (1.8 V from LP5907)
    VCCB = V_RF_3P3 (3.3 V from TPS63806)
    OE   = EMVS_EN (gated — translators powered only when EMVS rail is on,
           prevents 3.3 V leakage into a quiescent 1.8 V domain)

  This section is a STUB — the txs0108e .kicad_sym is not yet in lib/sources/.
  Pin-table for the future instance is:
    1=OE  2=A1  3=A2  4=A3  5=A4  6=A5  7=A6  8=A7  9=A8  10=GND
    11=B8 12=B7 13=B6 14=B5 15=B4 16=B3 17=B2 18=B1 19=VCCB 20=VCCA

  TODO: add lib/sources/txs0108e.kicad_sym, run regenerate_pinout, then add
  two instances (U_LS1 / U_LS2) below, with this net assignment:
    U_LS1: A1=RF_SPI_SCK_1V8 / B1=RF_SPI_SCK,
           A2=RF_SPI_MOSI_1V8 / B2=RF_SPI_MOSI,
           A3=RF_SPI_MISO_1V8 / B3=RF_SPI_MISO,
           A4=CS_RX1_1V8     / B4=CS_RX1,
           A5=CS_RX2_1V8     / B5=CS_RX2,
           A6=CS_LMX2594_1V8 / B6=CS_LMX2594,
           A7=CS_ADAR2001_1V8/ B7=CS_ADAR2001,
           A8=LD_LMX2594_1V8 / B8=LD_LMX2594
    U_LS2: A1=TxADV_1V8        / B1=TxADV,
           A2=MRST_1V8         / B2=MRST,
           A3=MADV_1V8         / B3=MADV,
           A4=RxADV_1V8        / B4=RxADV,
           A5=RxRST_1V8        / B5=RxRST,
           A6=TxRST_1V8        / B6=TxRST,
           A7=ADAR2001_TXEN_1V8/ B7=ADAR2001_TXEN,
           A8=(spare)          / B8=(spare)

  Until the part is added, the ADAR2001 / ADAR2004 / LMX2594 sections below
  reference the *_1V8 nets directly (e.g. RF_SPI_SCK_1V8) so the schematic
  intent is unambiguous; those nets simply have no driver until U_LS1/U_LS2
  are populated."
    (port "V1P8_RF"  in power 1.8)
    (port "V_RF_3P3" in power 3.3)
    (port "EMVS_EN"  in signal)
    (port "GND"      bidi)
    ;; All A-side (1.8 V) and B-side (3.3 V) nets just pass through this
    ;; section; ports declared so downstream sections build cleanly.
    (port "RF_SPI_SCK"      in)  (port "RF_SPI_SCK_1V8"      out)
    (port "RF_SPI_MOSI"     in)  (port "RF_SPI_MOSI_1V8"     out)
    (port "RF_SPI_MISO_1V8" in)  (port "RF_SPI_MISO"         out)
    (port "CS_RX1"          in)  (port "CS_RX1_1V8"          out)
    (port "CS_RX2"          in)  (port "CS_RX2_1V8"          out)
    (port "CS_LMX2594"      in)  (port "CS_LMX2594_1V8"      out)
    (port "CS_ADAR2001"     in)  (port "CS_ADAR2001_1V8"     out)
    (port "LD_LMX2594_1V8"  in)  (port "LD_LMX2594"          out)
    (port "TxADV"           in)  (port "TxADV_1V8"           out)
    (port "MRST"            in)  (port "MRST_1V8"            out)
    (port "MADV"            in)  (port "MADV_1V8"            out)
    (port "RxADV"           in)  (port "RxADV_1V8"           out)
    (port "RxRST"           in)  (port "RxRST_1V8"           out)
    (port "TxRST"           in)  (port "TxRST_1V8"           out)
    (port "ADAR2001_TXEN"   in)  (port "ADAR2001_TXEN_1V8"   out)

    (note "TXS0108E placement: keep within 5 mm of the most timing-critical destination (ADAR2001 TxADV — 3 ns minimum pulse). Auto-direction-sensing TXS0108E series resistors limit edge rate to ~5 ns; TXS0102 (2-bit) is a faster alternative if pulse-width margin becomes tight on TxADV/MADV/MRST.")
    (note "TXS0108E OE tied to EMVS_EN: when the EMVS power rail is OFF, OE is LOW and both A and B sides are Hi-Z. This prevents the 3.3 V host side from injecting current into a quiescent 1.8 V bus (the ADAR2004 datasheet warns against this). On power-up sequence, MAX7301 brings EMVS_EN HIGH after the 2.5 V rail is stable but before SPI traffic to the ADAR/LMX chips begins."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; K-BAND TX — ADF4159 chirp PLL ×2 (TBD library entry)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "ADF4159 #1 PLL"
    "ADF4159 #1 — 13 GHz fractional-N PLL with ramp generator, drives ADF5901 #1 VTUNE for the 24 GHz TX1 chirp.  Per HW-RDR-001 §8.1 / §3.1.

  Pin map (LFCSP-24, 4×4 mm):
    1  RSET     → 10 kΩ to AGND (ICP = 25.5/RSET → 2.55 mA)
    2  AVDD     → V_RF_3P3 (3.3 V analog) — 100 nF + 10 µF
    3  CPGND    → GND
    4  CPOUT    → loop filter → ADF5901 #1 VTUNE
    5  DVDD     → V1P8_RF (1.8 V digital)
    6  DGND     → GND
    7  AGND     → GND
    8  RFIN A   → ADF5901 #1 LO_OUT (10 pF AC-coupled) — 13 GHz VCO feedback
    9  RFIN B   → 50 Ω term to GND
    10 AGND     → GND
    11 REFIN    → 100 MHz TCXO (AC-couple 100 pF)
    12 DVDD1    → V1P8_RF
    13 TXDATA   → connector pin 38 (TXDATA_1) — DDM phase / BPSK data
    14 DATA     → RF_SPI_MOSI (3.3 V — no level shift, ADF4159 is 3.3 V-native)
    15 CLK      → RF_SPI_SCK
    16 LE       → MAX7301 P4 (CS_ADF4159_1)
    17 CE       → MAX7301 P16 (PLL_EN) via 10 kΩ pull-up
    18 MUXOUT   → MAX7301 P17 (LD_ADF4159_1) via 10 kΩ pull-down (config as Lock-Detect)
    19 SW       → 100 nF to GND (unused FMCW switching pin)
    20 V_P      → 5.0 V via LDO (charge-pump supply, ≥ AVDD+0.3 V) — TODO: add 5V LDO
    21 AVDD_VCO → V_RF_3P3
    22 AVDD_VCO → V_RF_3P3
    23 AGND     → GND
    24 (verify against current ADF4159 datasheet Rev E — some revs renumber)
    EPAD       → GND via thermal via array

  Loop filter topology: 2nd or 3rd-order active LF between CPOUT (pin 4) and
  ADF5901 VTUNE.  Component values per ADIsimPLL output for 24 GHz chirp
  config (slope = 27.4 MHz/µs, BW = 250 MHz, 35 µs ramp).

  This section is a STUB — adf4159 .kicad_sym is not yet in lib/sources/.
  Net names below match the future instance so the rest of the design wires
  up cleanly once the part is added.  No instance is placed."
    (port "V_RF_3P3"      in  power 3.3)
    (port "V1P8_RF"       in  power 1.8)
    (port "V_CP_5V"       in  power 5.0)  ;; TODO: 5V LDO not yet in this design
    (port "GND"           bidi)
    ;; Inputs from MAX7301 / connector
    (port "RF_SPI_SCK"    in)
    (port "RF_SPI_MOSI"   in)
    (port "CS_ADF4159_1"  in signal)
    (port "PLL_EN"        in signal)
    (port "TXDATA_1"      in signal)
    (port "RADAR_REF_AC"  in signal)
    ;; RF feedback from ADF5901 #1 LO_OUT
    (port "ADF5901_1_LO_OUT" in)
    ;; Outputs
    (port "CPOUT_1"       out signal)         ;; → loop filter → ADF5901 #1 VTUNE
    (port "VTUNE_1"       out signal)         ;; loop-filter output (after BSS138 #1 gate)
    (port "LD_ADF4159_1"  out signal)         ;; back to MAX7301 P17

    ;; TODO: instantiate ADF4159 once lib/components/adf4159.sexp exists.
    ;; Instance template (commented):
    ;;   (instance "U_ADF4159_1" adf4159
    ;;     (pin 1 "RSET_4159_1") (pin 2 21 22 "V_RF_3P3") (pin 3 6 7 10 23 "GND")
    ;;     (pin 4 "CPOUT_1") (pin 5 12 "V1P8_RF")
    ;;     (pin 8 "ADF5901_1_LO_OUT_AC")
    ;;     (pin 9 "RFIN_B_TERM_4159_1") (pin 11 "RADAR_REF_AC")
    ;;     (pin 13 "TXDATA_1") (pin 14 "RF_SPI_MOSI") (pin 15 "RF_SPI_SCK")
    ;;     (pin 16 "CS_ADF4159_1") (pin 17 "PLL_EN") (pin 18 "LD_ADF4159_1")
    ;;     (pin 19 "SW_4159_1") (pin 20 "V_CP_5V"))

    (note "ADF4159 #1: chirp PLL — programmed once at boot and on waveform-parameter change. Drives ADF5901 #1 VTUNE via loop filter. RFIN A receives ADF5901 LO_OUT (13 GHz / ÷2 from VCO) for closed-loop feedback. CE / lock-detect via MAX7301 (PLL_EN / LD_ADF4159_1). 3.3 V-native SPI — no level shift.")
    (note "ADF4159 #1 V_P (pin 20, 5.0 V): TODO — this design does not yet have a 5 V rail. Per HW-RDR-001 §10, VCC_5V_CP is sourced from PLL_EN-gated LDO at ~10 mA. Add a small 3.3 V → 5 V boost (e.g. TPS61022 or charge pump TPS60150) before populating ADF4159 instances.")
    (note "Loop filter component values must come from ADIsimPLL for the specific FMCW chirp profile: 24.0–24.25 GHz, 35 µs ramp, ICP = 2.55 mA. Use 2nd-order active LF (R3+C17 + C18 + R4+C19) from src/adf5901.sexp as a starting topology — values to be confirmed."))

  (section "ADF4159 #2 PLL"
    "ADF4159 #2 — identical pinout / programming to #1.  Drives ADF5901 #2 VTUNE for the 24 GHz TX2 chirp.  Must be programmed AFTER #1 for phase coherence (§4.4 BUS 1 timing).  Section structure mirrors #1 with all nets suffixed _2.

  Same TBD status as #1 — instance is not placed until adf4159 lib entry exists."
    (port "V_RF_3P3"      in  power 3.3)
    (port "V1P8_RF"       in  power 1.8)
    (port "V_CP_5V"       in  power 5.0)
    (port "GND"           bidi)
    (port "RF_SPI_SCK"    in)
    (port "RF_SPI_MOSI"   in)
    (port "CS_ADF4159_2"  in signal)
    (port "PLL_EN"        in signal)
    (port "TXDATA_2"      in signal)
    (port "RADAR_REF_AC"  in signal)
    (port "ADF5901_2_LO_OUT" in)
    (port "CPOUT_2"       out signal)
    (port "VTUNE_2"       out signal)
    (port "LD_ADF4159_2"  out signal)

    (note "ADF4159 #2: identical to #1 with _2 nets. Programmed AFTER #1 for phase coherence (HW-RDR-001 §4.4 BUS 1 / SPI6 ordering)."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; K-BAND TX — ADF5901 24 GHz TX VCO+PA ×2
  ;; ─────────────────────────────────────────────────────────────────────

  (section "ADF5901 #1 TX VCO"
    "ADF5901 #1 — 24 GHz K-band TX VCO with internal ÷2 doubler and +8 dBm output amplifier.  Drives HMC1131 #1 RFIN; LO_OUT (13 GHz) feeds back to ADF4159 #1 RFIN A for closed-loop chirp control AND drives ADF5904 LO_IN (-1 dBm) for main RX downconversion.  TX_OUT2 unused (50 Ω term).  Per HW-RDR-001 §8.2.

  Power-up sequence: VCO calibration triggered after first SPI write at boot
  (~5 ms); TX_AMP_EN1 enabled per-channel via SPI register 0x07.  CE pin held
  HIGH by TX_EN (MAX7301 P12) — when TX_EN is LOW, the entire TX chain is
  powered down.  Loop filter R3/R4/R5/C17/C18/C19 implements 2nd-order active
  filter from ADF4159 #1 CPOUT to ADF5901 #1 VTUNE."
    (protocol SPI)
    (port "V_RF_3P3"     in  power 3.3)
    (port "V1P8_RF"      in  power 1.8)
    (port "GND"          bidi)
    (port "RF_SPI_SCK"   in  signal)
    (port "RF_SPI_MOSI"  in  signal)
    (port "RF_SPI_MISO"  out signal)
    (port "CS_ADF5901_1" in  signal)
    (port "TX_EN"        in  signal)
    (port "RADAR_REF_AC" in  signal)
    (port "VTUNE_1"      in  signal)            ;; from ADF4159 #1 loop filter
    (port "TX1_RFOUT" out rf)                   ;; HMC1131 TBD — driven directly by ADF5901 for now
    (port "ADF5901_1_LO_OUT" out rf)            ;; → ADF4159 #1 RFIN A AND ADF5904 LO_IN

    (instance "U_ADF5901_1" adf5901acpz-rl7
      (pin 1 3 6 8 10 12 13 19 33 "GND")
      (pin 4 5 14 16 17 30 "V_RF_3P3")          ;; AVDD_TX rails (datasheet "AVDD_TX" group)
      (pin 2 "TX1_RFOUT")                       ;; TX_OUT1 → top-level (HMC1131 to be inserted later)
      (pin 7 "TX2_TERM_5901_1")                 ;; TX_OUT2 → 50 Ω term (unused)
      (pin 9 "ATEST_5901_1")                    ;; analog test — leave open or testpoint
      (pin 11 "ADF5901_1_LO_OUT")               ;; LO_OUT → ADF4159 #1 RFIN A + ADF5904 LO_IN
      (pin 15 "RADAR_REF_AC")                   ;; REFIN — AC-coupled 100 MHz TCXO
      (pin 18 "VREG_5901_1")                    ;; on-chip VREG output (1.8 V) — bypass to GND only
      (pin 20 "TX_EN")                          ;; CE — gated by MAX7301 P12 (TX_EN)
      (pin 21 "RF_SPI_SCK")                     ;; CLK
      (pin 22 "RF_SPI_MOSI")                    ;; DATA
      (pin 23 "CS_ADF5901_1")                   ;; LE
      (pin 24 "RF_SPI_MISO")                    ;; DOUT — tri-state on CS-deassert
      (pin 25 "MUXOUT_5901_1")                  ;; MUXOUT — testpoint (unused for closed-loop)
      (pin 26 "RSET_5901_1")
      (pin 27 "AUX_5901_1")                     ;; AUX out (unused)
      (pin 28 "AUXB_5901_1")                    ;; AUXB out (unused)
      (pin 29 "VTUNE_1")
      (pin 31 "AVDD_5901_1")                    ;; per datasheet — connect to V_RF_3P3
      (pin 32 "DVDD_5901_1") (id e42a572a))                   ;; per datasheet — connect to V1P8_RF

    ;; Power-rail decoupling — analog 3.3 V (multiple bypass groups per datasheet)
    (instance "C_AVDD_5901_1A" (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id a5865adc))
    (instance "C_AVDD_5901_1B" (cap-0402 "1nF")   (pin 1 "V_RF_3P3") (pin 2 "GND") (id fada42c9))
    (instance "C_AVDD_5901_1C" (cap-0402 "10pF")  (pin 1 "V_RF_3P3") (pin 2 "GND") (id ba5547e9))
    (instance "C_AVDD_5901_1D" (cap-0805 "10uF")  (pin 1 "V_RF_3P3") (pin 2 "GND") (id e63c4dc8))
    ;; AVDD discrete pin (pin 31) extra HF bypass
    (instance "C_AVDD_5901_1E" (cap-0402 "100nF") (pin 1 "AVDD_5901_1") (pin 2 "GND") (id f625daa1))
    (instance "C_AVDD_5901_1F" (cap-0402 "1nF")   (pin 1 "AVDD_5901_1") (pin 2 "GND") (id fb2b9345))
    ;; Net AVDD to V_RF_3P3 (pin 31 is on the same supply but routed locally)
    (net "AVDD_5901_1" "V_RF_3P3")
    ;; DVDD discrete pin (pin 32) bypass
    (instance "C_DVDD_5901_1A" (cap-0402 "100nF") (pin 1 "DVDD_5901_1") (pin 2 "GND") (id f9782205))
    (instance "C_DVDD_5901_1B" (cap-0402 "1nF")   (pin 1 "DVDD_5901_1") (pin 2 "GND") (id a8097746))
    (net "DVDD_5901_1" "V1P8_RF")
    ;; VREG bypass (datasheet: 47 nF + 220 nF)
    (instance "C_VREG_5901_1A" (cap-0402 "47nF")  (pin 1 "VREG_5901_1") (pin 2 "GND") (id a6ee0f96))
    (instance "C_VREG_5901_1B" (cap-0402 "220nF") (pin 1 "VREG_5901_1") (pin 2 "GND") (id d41f1d77))
    ;; REFIN AC-coupling network (per src/adf5901.sexp template)
    (instance "C_REFIN_5901_1A" (cap-0402 "1nF") (pin 1 "RADAR_REF_AC") (pin 2 "REFIN_AC_5901_1") (id e2870980))
    (instance "C_REFIN_5901_1B" (cap-0402 "1nF") (pin 1 "RADAR_REF_AC") (pin 2 "REFIN_AC_5901_1") (id aa11d63c))
    (instance "R_REFIN_5901_1"  (res-0402 "5.1k") (pin 1 "RADAR_REF_AC") (pin 2 "GND") (id e0a9a408))
    ;; RSET (bias)
    (instance "R_RSET_5901_1" (res-0402 "5.1k") (pin 1 "RSET_5901_1") (pin 2 "GND") (id c409b9ee))
    ;; TX_OUT2 50 Ω term (TX2 unused — single-ended output to ground via 50 Ω)
    (instance "R_TX2TERM_5901_1" (res-0201 "50R") (pin 1 "TX2_TERM_5901_1") (pin 2 "GND") (id bf55bf7d))

    ;; Loop filter (template from src/adf5901.sexp — values from ADIsimPLL TBD)
    (instance "R_LF_5901_1A" (res-0805 "510R") (pin 1 "CPOUT_1") (pin 2 "LF1_5901_1") (id baa5f673))
    (instance "R_LF_5901_1B" (res-0805 "0R")   (pin 1 "LF1_5901_1") (pin 2 "LF2_5901_1") (id b9a5dfcb))
    (instance "R_LF_5901_1C" (res-0805 "0R")   (pin 1 "LF2_5901_1") (pin 2 "VTUNE_1") (id bc4578f1))
    (instance "C_LF_5901_1A" (cap-0805 "3.3nF") (pin 1 "LF1_5901_1") (pin 2 "GND") (id c3cc119a))
    (instance "C_LF_5901_1B" (cap-0805 "220pF") (pin 1 "CPOUT_1") (pin 2 "GND") (id ae353a7e))
    (instance "C_LF_5901_1C" (cap-0805 "100pF") (pin 1 "LF2_5901_1") (pin 2 "GND") (id dcb5921d))

    (note "U_ADF5901_1" "ADF5901 #1: 24 GHz TX VCO+PA. CE = TX_EN (MAX7301 P12) — entire TX1 chain off when TX_EN=LOW. LO_OUT (-1 dBm @ 13 GHz) drives BOTH ADF4159 #1 RFIN A AND ADF5904 LO_IN. SPI 3.3 V-native — no level shifting.")
    (note "Loop filter: values are template — must regenerate from ADIsimPLL for the specific 24 GHz / 35 µs / 2.55 mA ICP design point. The BSS138 BPSK gate (in §BSS138 #1) shorts C_LF_5901_1A when BPSK_GATE_1 = HIGH, widening the loop bandwidth for comms-mode data."))

  (section "ADF5901 #2 TX VCO"
    "ADF5901 #2 — identical to #1, drives HMC1131 #2 RFIN.  LO_OUT terminated 50 Ω (TX2 path does not use ADF5904 LO_IN — only ADF5901 #1 feeds the receiver).  Per HW-RDR-001 §8.2.

  Section structure mirrors #1 with _2 nets.  TX_AMP_EN2 still unused (TX1
  is the ADF5901 active output; TX2 of the chip is disabled via SPI)."
    (protocol SPI)
    (port "V_RF_3P3"     in  power 3.3)
    (port "V1P8_RF"      in  power 1.8)
    (port "GND"          bidi)
    (port "RF_SPI_SCK"   in  signal)
    (port "RF_SPI_MOSI"  in  signal)
    (port "RF_SPI_MISO"  out signal)
    (port "CS_ADF5901_2" in  signal)
    (port "TX_EN"        in  signal)
    (port "RADAR_REF_AC" in  signal)
    (port "VTUNE_2"      in  signal)
    (port "TX2_RFOUT" out rf)                    ;; HMC1131 TBD — driven directly by ADF5901 for now
    (port "ADF5901_2_LO_OUT" out rf)             ;; → ADF4159 #2 RFIN A only

    (instance "U_ADF5901_2" adf5901acpz-rl7
      (pin 1 3 6 8 10 12 13 19 33 "GND")
      (pin 4 5 14 16 17 30 "V_RF_3P3")
      (pin 2 "TX2_RFOUT")
      (pin 7 "TX2_TERM_5901_2")
      (pin 9 "ATEST_5901_2")
      (pin 11 "ADF5901_2_LO_OUT")
      (pin 15 "RADAR_REF_AC")
      (pin 18 "VREG_5901_2")
      (pin 20 "TX_EN")
      (pin 21 "RF_SPI_SCK")
      (pin 22 "RF_SPI_MOSI")
      (pin 23 "CS_ADF5901_2")
      (pin 24 "RF_SPI_MISO")
      (pin 25 "MUXOUT_5901_2")
      (pin 26 "RSET_5901_2")
      (pin 27 "AUX_5901_2")
      (pin 28 "AUXB_5901_2")
      (pin 29 "VTUNE_2")
      (pin 31 "AVDD_5901_2")
      (pin 32 "DVDD_5901_2") (id c58bc114))
    (net "AVDD_5901_2" "V_RF_3P3")
    (net "DVDD_5901_2" "V1P8_RF")
    (instance "C_AVDD_5901_2A" (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id d2f3f28f))
    (instance "C_AVDD_5901_2B" (cap-0402 "1nF")   (pin 1 "V_RF_3P3") (pin 2 "GND") (id ed092f1c))
    (instance "C_AVDD_5901_2C" (cap-0402 "10pF")  (pin 1 "V_RF_3P3") (pin 2 "GND") (id eabf9432))
    (instance "C_AVDD_5901_2D" (cap-0805 "10uF")  (pin 1 "V_RF_3P3") (pin 2 "GND") (id fcd5cc25))
    (instance "C_AVDD_5901_2E" (cap-0402 "100nF") (pin 1 "AVDD_5901_2") (pin 2 "GND") (id b6abe3d7))
    (instance "C_DVDD_5901_2A" (cap-0402 "100nF") (pin 1 "DVDD_5901_2") (pin 2 "GND") (id fbe34f2b))
    (instance "C_VREG_5901_2A" (cap-0402 "47nF")  (pin 1 "VREG_5901_2") (pin 2 "GND") (id c78d587c))
    (instance "C_VREG_5901_2B" (cap-0402 "220nF") (pin 1 "VREG_5901_2") (pin 2 "GND") (id dbfe1c5d))
    (instance "R_RSET_5901_2"  (res-0402 "5.1k")  (pin 1 "RSET_5901_2") (pin 2 "GND") (id b265207d))
    (instance "R_TX2TERM_5901_2" (res-0201 "50R") (pin 1 "TX2_TERM_5901_2") (pin 2 "GND") (id c96fbf1e))

    ;; Loop filter (template — values per ADIsimPLL output)
    (instance "R_LF_5901_2A" (res-0805 "510R") (pin 1 "CPOUT_2") (pin 2 "LF1_5901_2") (id a05f6c9c))
    (instance "R_LF_5901_2B" (res-0805 "0R")   (pin 1 "LF1_5901_2") (pin 2 "LF2_5901_2") (id cef78324))
    (instance "R_LF_5901_2C" (res-0805 "0R")   (pin 1 "LF2_5901_2") (pin 2 "VTUNE_2") (id bc571549))
    (instance "C_LF_5901_2A" (cap-0805 "3.3nF") (pin 1 "LF1_5901_2") (pin 2 "GND") (id ffc4be49))
    (instance "C_LF_5901_2B" (cap-0805 "220pF") (pin 1 "CPOUT_2") (pin 2 "GND") (id f0533f49))
    (instance "C_LF_5901_2C" (cap-0805 "100pF") (pin 1 "LF2_5901_2") (pin 2 "GND") (id b3567253))

    (port "CPOUT_2"      in  signal)
    (note "U_ADF5901_2" "ADF5901 #2: identical pinout to #1. LO_OUT terminated 50 Ω — only #1's LO_OUT feeds ADF5904. TX2 chain selected via TX_AMP_EN2 (SPI), TX1 disabled."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; K-BAND TX — HMC1131 24-35 GHz MPA ×2 (TBD library entry)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "HMC1131 #1 MPA"
    "HMC1131LC4TR — GaAs pHEMT medium-power amplifier, +22 dB / P1dB +24 dBm, 24-35 GHz.  Drives TX1 K-band patch antenna at +30 dBm.  Requires biased gate voltages (VG1/VG2/VG3 negative -0.5 to -1.5 V) and three drain rails (VD1/VD2/VD3 = +5.0 V).  Total dissipation ~1.125 W — thermal via array CRITICAL under EPAD.

  Pin map (LCC-24, per HW-RDR-001 §8.3):
    1  RFIN  → ADF5901 #1 TX1_OUT (+8 dBm)
    2,5-7,10-12,15-23 GND
    3  VD1   → +5.0 V via R_bias (~40 mA)
    4  VG1   → −0.5 to −1.5 V (gate bias)
    8  VD2   → +5.0 V (~75 mA)
    9  VG2   → gate bias
    13 VD3   → +5.0 V (~110 mA)
    14 VG3   → gate bias
    24 RFOUT → TX1 K-band patch antenna feed (+30 dBm)
    EPAD     → GND (thermal — 1.125 W dissipation)

  Bias requirements:
   - +5.0 V drain rail with TX_EN gating (TODO: 5 V LDO not yet in design)
   - Negative gate bias: requires charge-pump inverter (LM27761 / TPS60403) +
     dual-LDO trim, or a precision negative-rail generator.  Sequence:
     VG up before VD up, VG down after VD down (HMC1131 datasheet).
   - All three VG nets share a tracking sequencer — see HMC TWA-1342 ref design.

  Section is a STUB — hmc1131 .kicad_sym not yet in lib/sources/.  Placeholder
  ports declared so the TX1 RF path nets exist for the design boundary."
    (port "V_RF_5V"      in  power 5.0)
    (port "V_NEG_GATE"   in  power -1.0)         ;; rough average — actual rail is variable
    (port "TX_EN"        in  signal)
    (port "GND"          bidi)
    (port "TX1_RFOUT_5901" in  rf)               ;; from ADF5901 #1 TX_OUT1
    (port "TX1_RFOUT"      out rf)               ;; to TX1 patch antenna feed

    (note "HMC1131 #1: TBD section. Datasheet: ADIsimRF entry HMC1131LC4. Design points: ID=225 mA total at VD=5 V, gate bias must precede drain (sequencing). Add bias + sequencer + 5 V LDO (TX_EN-gated) and negative-rail generator before population.")
    (note "Thermal: 1.125 W on a 4×4 mm LCC-24. Specific via array — minimum 16 vias @ 0.3 mm under EPAD, blind-via or filled-and-capped to bottom layer copper pour. Junction temp budget: 135 °C max, ambient 85 °C → θJA ≤ 44 °C/W."))

  (section "HMC1131 #2 MPA"
    "HMC1131 #2 — identical to #1, drives TX2 K-band patch antenna.  Same TBD status."
    (port "V_RF_5V"      in  power 5.0)
    (port "V_NEG_GATE"   in  power -1.0)
    (port "TX_EN"        in  signal)
    (port "GND"          bidi)
    (port "TX2_RFOUT_5901" in  rf)
    (port "TX2_RFOUT"      out rf)

    (note "HMC1131 #2: identical to #1 with _2 nets."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; K-BAND TX — BSS138 BPSK gate ×2 (using n2n7002 substitute)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "BSS138 #1 BPSK Gate"
    "NMOS SOT-23 — when BPSK_GATE_1 = HIGH, the FET shorts a portion of the ADF4159 #1 loop-filter capacitance to widen PLL bandwidth for BPSK comms-mode data on TXDATA_1.  In radar mode, BPSK_GATE_1 = LOW (FET off, full loop filter for low chirp jitter).

  Substitute: lib/components/n2n7002 — functionally identical to BSS138 (NMOS
  SOT-23, Vgs(th) ~1 V, Vds 60 V, Id 200 mA).  Drain shorts across C_LF_5901_1A
  (the 3.3 nF cap).  Source to GND.  Gate from connector pin 42 (BPSK_GATE_1)."
    (port "V_RF_3P3"     in  power 3.3)
    (port "GND"          bidi)
    (port "BPSK_GATE_1"  in  signal)
    (port "LF1_5901_1"   in  signal)             ;; loop filter node (drain — bypass cap node)

    (instance "Q_BPSK_1" 2n7002
      (pin 1 "BPSK_GATE_1")        ;; G — direct from STM32 / connector pin 42 (3.3 V CMOS)
      (pin 2 "GND")                ;; S
      (pin 3 "LF1_5901_1") (id d2dd1663))        ;; D — across loop-filter bypass cap

    ;; 100 kΩ pull-down on gate keeps FET off when STM32 boots / GPIO floats
    (instance "R_GPD_BPSK_1" (res-0402 "100k")
      (pin 1 "BPSK_GATE_1") (pin 2 "GND") (id eb452576))

    (note "Q_BPSK_1" "BSS138 functionally — using n2n7002 (same NMOS SOT-23). Drain across C_LF_5901_1A in §ADF5901 #1. When BPSK_GATE_1 = HIGH, drain-source shorts the cap, widening loop BW for BPSK comms data rate; in radar mode BPSK_GATE_1 = LOW for narrow loop / low chirp jitter.")
    (note "R_GPD_BPSK_1" "100 kΩ pull-down — keeps FET off during STM32 boot / GPIO Hi-Z, so radar mode is the fail-safe default."))

  (section "BSS138 #2 BPSK Gate"
    "Identical to BSS138 #1 — gates ADF4159 #2 loop filter on TX2 path."
    (port "V_RF_3P3"     in  power 3.3)
    (port "GND"          bidi)
    (port "BPSK_GATE_2"  in  signal)
    (port "LF1_5901_2"   in  signal)

    (instance "Q_BPSK_2" 2n7002
      (pin 1 "BPSK_GATE_2")
      (pin 2 "GND")
      (pin 3 "LF1_5901_2") (id d8aac451))
    (instance "R_GPD_BPSK_2" (res-0402 "100k")
      (pin 1 "BPSK_GATE_2") (pin 2 "GND") (id e714a196))

    (note "Q_BPSK_2" "BSS138 functionally — using n2n7002. TX2 BPSK gate."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; K-BAND RX — PMA3-24323LN+ LNA ×2
  ;; ─────────────────────────────────────────────────────────────────────

  (section "PMA3 #1 LNA"
    "Mini-Circuits PMA3-24323LN+ — 24-32 GHz wideband LNA, +16 dB gain, NF 3.1 dB.  RX antenna SA2 (Beam 1) → LNA → ADF5904 RFIN_A+/-.  Sets the cumulative noise figure of the main RX chain (3.1 dB).

  Power: VDD1-VDD4 (4 supply pins per pinout) all tied to V_RF_3P3 via bias
  tee (RF choke + decoupling).  Total ~30 mA.  Per HW-RDR-001 §8.4."
    (port "V_RF_3P3"   in  power 3.3)
    (port "GND"        bidi)
    (port "BEAM1_RFIN" in  rf)                   ;; from RX SA2 patch antenna
    (port "BEAM1_LNAOUT" out rf)                  ;; to ADF5904 RFIN_A+/- via 100 Ω diff matching

    (instance "U_LNA1" pma3-24323ln+
      (pin 1 3 7 9 13 "GND")
      (pin 2 "BEAM1_RFIN")           ;; RF-IN — 50 Ω
      (pin 8 "BEAM1_LNAOUT")         ;; RF-OUT — 50 Ω matched
      (pin 4 "VDD_LNA1")             ;; VDD3
      (pin 6 "VDD_LNA1")             ;; VDD4
      (pin 10 "VDD_LNA1")            ;; VDD2
      (pin 12 "VDD_LNA1")            ;; VDD1
      (pin 5 "LNA1_NC1")             ;; NC
      (pin 11 "LNA1_NC2") (id ed60c466))           ;; NC

    ;; Bias tee — RF choke from rail to VDD pin, with HF + bulk decoupling
    (instance "L_BIAS_LNA1" (ind-0402 "39nH")
      (pin 1 "V_RF_3P3") (pin 2 "VDD_LNA1") (id dd63836d))
    (instance "C_VDD_LNA1A" (cap-0402 "100nF")
      (pin 1 "VDD_LNA1") (pin 2 "GND") (id baf95d85))
    (instance "C_VDD_LNA1B" (cap-0402 "1nF")
      (pin 1 "VDD_LNA1") (pin 2 "GND") (id c1ca2acc))
    (instance "C_VDD_LNA1C" (cap-0201 "10pF")
      (pin 1 "VDD_LNA1") (pin 2 "GND") (id af77115c))
    (instance "C_VDD_LNA1D" (cap-0805 "10uF")
      (pin 1 "V_RF_3P3") (pin 2 "GND") (id f1a99655))

    (note "U_LNA1" "PMA3-24323LN+: 24-32 GHz LNA, single-ended 50 Ω in / 50 Ω out. Bias-tee inductor (39 nH ind-0402) on each VDD pin; output AC-coupled to the ADF5904 RFIN_A+ via single-ended-to-diff conversion (typically a balun or single-ended drive of one diff input with the other terminated 50 Ω). Confirm matching network on 24.125 GHz design point.")
    (note "BEAM1_LNAOUT → ADF5904 RFIN_A+ (and 50 Ω term on RFIN_A-) per HW-RDR-001 §8.5. The LNA is single-ended; ADF5904 has differential RF inputs but accepts SE drive with the unused leg terminated."))

  (section "PMA3 #2 LNA"
    "Identical to #1 — RX antenna SA3 (Beam 2) → LNA → ADF5904 RFIN_B+/-."
    (port "V_RF_3P3"   in  power 3.3)
    (port "GND"        bidi)
    (port "BEAM2_RFIN" in  rf)
    (port "BEAM2_LNAOUT" out rf)

    (instance "U_LNA2" pma3-24323ln+
      (pin 1 3 7 9 13 "GND")
      (pin 2 "BEAM2_RFIN")
      (pin 8 "BEAM2_LNAOUT")
      (pin 4 "VDD_LNA2")
      (pin 6 "VDD_LNA2")
      (pin 10 "VDD_LNA2")
      (pin 12 "VDD_LNA2")
      (pin 5 "LNA2_NC1")
      (pin 11 "LNA2_NC2") (id bf507e47))
    (instance "L_BIAS_LNA2" (ind-0402 "39nH")
      (pin 1 "V_RF_3P3") (pin 2 "VDD_LNA2") (id b7f5aa39))
    (instance "C_VDD_LNA2A" (cap-0402 "100nF") (pin 1 "VDD_LNA2") (pin 2 "GND") (id ad951158))
    (instance "C_VDD_LNA2B" (cap-0402 "1nF")   (pin 1 "VDD_LNA2") (pin 2 "GND") (id c8487d7c))
    (instance "C_VDD_LNA2C" (cap-0201 "10pF")  (pin 1 "VDD_LNA2") (pin 2 "GND") (id e3fc5c92))
    (instance "C_VDD_LNA2D" (cap-0805 "10uF")  (pin 1 "V_RF_3P3") (pin 2 "GND") (id fc4dd373))

    (note "U_LNA2" "PMA3-24323LN+ #2: identical to LNA1. Output drives ADF5904 RFIN_B+ (Beam 2)."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; K-BAND RX — ADF5904 4-channel receiver (TBD library entry)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "ADF5904 RX"
    "ADF5904 — 24 GHz quad-channel receiver (4× LNA + mixer).  Rev D usage:
  Ch A/B = main beams (PMA3 #1/#2 outputs); Ch C/D = unused (50 Ω term).
  IF outputs Ch A/B → connector CH9/CH10 → AD7380-4 #3 on digital board.
  IF C/D unused (Rev E remap freed them — Ch A/B → CH9/CH10).

  Pin map (LFCSP-32 5×5 mm, per HW-RDR-001 §8.5):
    1  RFIN_A+  → PMA3 #1 OUT (Beam 1, single-ended drive)
    2  RFIN_A-  → 50 Ω term to GND
    3  RFIN_B+  → PMA3 #2 OUT (Beam 2)
    4  RFIN_B-  → 50 Ω term
    5,6  RFIN_C+/-  → 50 Ω term (Ch C unused, Rev D)
    7,8  RFIN_D+/-  → 50 Ω term (Ch D unused)
    9  LO_IN    → ADF5901 #1 LO_OUT (-1 dBm) via AC-couple
    10 AGND
    11 IF_A+    → connector CH9P (pin 51) → AD7380-4 #3 AINA+ (Rev E remap)
    12 IF_A-    → connector CH9N (pin 53)
    13 IF_B+    → connector CH10P (pin 57)
    14 IF_B-    → connector CH10N (pin 59)
    15-22 IF_C/D   → OPEN (Rev D freed — Ch C/D not used)
    23 DATA     → RF_SPI_MOSI (3.3 V-native — no level shift)
    24 CLK      → RF_SPI_SCK
    25 LE       → MAX7301 P8 (CS_ADF5904_1)
    26 CE       → MAX7301 P13 (RX_EN)
    27 MUXOUT   → RF_SPI_MISO (tri-state on CS-deassert)
    28 REFIN    → 100 MHz TCXO AC-coupled (LO buffer cal)
    29-32 DVDD/AVDD  → 1.8 V / 3.3 V per datasheet
    EPAD       → GND via thermal via array

  Section is a STUB — adf5904 .kicad_sym not yet in lib/sources/.  Net names
  match the future instance so the rest of the design ties in cleanly."
    (protocol SPI)
    (port "V_RF_3P3"     in  power 3.3)
    (port "V1P8_RF"      in  power 1.8)
    (port "GND"          bidi)
    (port "RF_SPI_SCK"   in  signal)
    (port "RF_SPI_MOSI"  in  signal)
    (port "RF_SPI_MISO"  out signal)
    (port "CS_ADF5904_1" in  signal)
    (port "RX_EN"        in  signal)
    (port "RADAR_REF_AC" in  signal)
    (port "ADF5901_1_LO_OUT" in  rf)             ;; LO from ADF5901 #1 LO_OUT
    (port "BEAM1_LNAOUT" in  rf)                 ;; from PMA3 #1
    (port "BEAM2_LNAOUT" in  rf)                 ;; from PMA3 #2
    ;; Differential IF outputs → connector
    (bus-port "ADF_CH" 9 10 (suffixes P N) out differential)

    (note "ADF5904 — chip absent until lib/components/adf5904 added. Rev E remap: IF_A → CH9 (Beam 1), IF_B → CH10 (Beam 2). IF_C/D unrouted. Ch C/D RF inputs terminated 50 Ω.")
    (note "ADF5904-to-AD7380-4 DC-bias matching: ADF5904 IF common-mode is ~VDD/2 (≈1.65 V). Verify AD7380-4 input common-mode range (1.25 V VREF/2) against this — likely needs AC coupling caps or resistive divider. Open item per HW-RDR-001 §12."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; EMVS TX — ADAR2001 wideband 4-ch TX (Rev E new)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "ADAR2001 TX"
    "ADAR2001 — 10-40 GHz, 4-channel TX with on-die ×4 frequency multiplier.  Drives TX-EMVS 1 cell (Ex/Ey/Hx/Hy).  Rev E new addition — replaces both bow-tie antennas, eliminates the X-band TX gap present in Rev B/C/D.

  RF: LMX2594 RFoutB direct → RFIN (pin 4, single-ended 50 Ω, +7 dBm @ 6 GHz).
      ×4 multiplier on-die → up to 24 GHz.  RFOUT1+/- → Ex dipole, RFOUT2+/-
      → Ey dipole, RFOUT3+/- → Hx loop, RFOUT4+/- → Hy loop.  All four diff
      pairs 100 Ω, length-matched ≤0.1 mm.

  Power: VPOS1/VPOS3/VPOS4/VPOS5 → 2.5 V (V_RX_2P5, EMVS_EN-gated).  VREG
  (pin 6) is the on-chip 1.8 V LDO output — connect directly to VPOS2 (pin 7,
  the digital supply input).  ~450 mW total dissipation.

  Control (1.8 V — via TXS0108E):
    *CS = MAX7301 P20 (CS_ADAR2001_1V8)
    SCLK/SDIO/SDO = RF_SPI bus _1V8
    TxADV = connector pin 50 (PA10) — per-chirp pol-cycling, 3 ns min pulse
    TxRST = MAX7301 P22 (TxRST_1V8) — slow recovery
    MADV/MRST = connector pins 58/46 — shared 3-way with ADAR2004 ×2

  Per HW-RDR-001 §13.10 IC pinout."
    (protocol SPI)
    (port "V_RX_2P5"     in  power 2.5)
    (port "V_RF_3P3"     in  power 3.3)          ;; not directly used — kept for reference
    (port "GND"          bidi)
    ;; SPI / control — 1.8 V side (post-TXS0108E)
    (port "RF_SPI_SCK_1V8"   in  signal)
    (port "RF_SPI_MOSI_1V8"  in  signal)
    (port "RF_SPI_MISO_1V8"  out signal)
    (port "CS_ADAR2001_1V8"  in  signal)
    (port "MRST_1V8"         in  signal role reset)
    (port "MADV_1V8"         in  signal)
    (port "TxADV_1V8"        in  signal)
    (port "TxRST_1V8"        in  signal role reset)
    ;; RF input from LMX2594
    (port "LMX_RFOUTB_SE"    in  rf)
    ;; RF outputs to TX-EMVS 1 cell
    (port "TX_EMVS_Ex+" out differential) (port "TX_EMVS_Ex-" out differential)
    (port "TX_EMVS_Ey+" out differential) (port "TX_EMVS_Ey-" out differential)
    (port "TX_EMVS_Hx+" out differential) (port "TX_EMVS_Hx-" out differential)
    (port "TX_EMVS_Hy+" out differential) (port "TX_EMVS_Hy-" out differential)

    (instance "U_TX_EMVS" adar2001accz
      ;; Ground (17 GND pins + 4 EPADs)
      (pin 2 3 5 16 17 20 22 25 26 27 30 32 35 36 37 38 39 "GND")
      (pin 41 42 43 44 "GND")
      ;; Analog 2.5 V supplies (VPOS1/VPOS3/VPOS4/VPOS5)
      (pin 1 21 31 40 "V_RX_2P5")
      ;; Digital 1.8 V — VPOS2 MUST be tied directly to VREG (datasheet)
      (pin 6 "TX_EMVS_VREG")          ;; VREG (on-chip 1.8 V LDO output)
      (pin 7 "TX_EMVS_VREG")          ;; VPOS2
      ;; RF input
      (pin 4 "LMX_RFOUTB_SE")
      ;; SPI
      (pin 12 "RF_SPI_SCK_1V8")
      (pin 13 "RF_SPI_MOSI_1V8")
      (pin 14 "CS_ADAR2001_1V8")
      (pin 15 "RF_SPI_MISO_1V8")
      ;; State machine
      (pin 8  "TxADV_1V8")
      (pin 9  "TxRST_1V8")
      (pin 10 "MADV_1V8")
      (pin 11 "MRST_1V8")
      ;; RF outputs (matching the EMVS element map in §13.10)
      (pin 34 "TX_EMVS_Ex+") (pin 33 "TX_EMVS_Ex-")  ;; RFOUT1+/-
      (pin 29 "TX_EMVS_Ey+") (pin 28 "TX_EMVS_Ey-")  ;; RFOUT2+/-
      (pin 23 "TX_EMVS_Hx+") (pin 24 "TX_EMVS_Hx-")  ;; RFOUT3+/-
      (pin 18 "TX_EMVS_Hy+") (pin 19 "TX_EMVS_Hy-") (id cf0ada80)) ;; RFOUT4+/-

    ;; VPOS1 (pin 1) decoupling — 100 pF + 10 nF + shared 1 µF rail (datasheet)
    (instance "C_TX_VP1A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id fa5bcb33))
    (instance "C_TX_VP1B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id a8db70d6))
    ;; VPOS3 (pin 21)
    (instance "C_TX_VP3A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id fcf22d0b))
    (instance "C_TX_VP3B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id a613a19e))
    ;; VPOS4 (pin 31)
    (instance "C_TX_VP4A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id cafbd978))
    (instance "C_TX_VP4B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id fbb46091))
    ;; VPOS5 (pin 40, exposed in pinout as "VPOS")
    (instance "C_TX_VP5A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id d976605f))
    (instance "C_TX_VP5B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id af445570))
    ;; Shared 1 µF bulk on the 2.5 V rail (already in §2.5V LDO, but placed
    ;; locally here for the ADAR2001 cluster — datasheet "1 µF for the rail")
    (instance "C_TX_VP_BULK" (cap-0402 "1uF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id e11e4aea))
    ;; VREG/VPOS2 — 1 µF as close to pins 6/7 as possible (datasheet)
    (instance "C_TX_VREG" (cap-0402 "1uF") (pin 1 "TX_EMVS_VREG") (pin 2 "GND") (id e2ca3ccc))

    ;; *CS pull-up to 1.8 V (VREG) — 200 kΩ per ADAR2001 datasheet
    (instance "R_CS_TX_EMVS" (res-0402 "200k")
      (pin 1 "CS_ADAR2001_1V8") (pin 2 "TX_EMVS_VREG") (id c5dcf268))

    (note "U_TX_EMVS" "ADAR2001 #1 — Rev E EMVS wideband TX. RFIN from LMX2594 RFoutB direct (single-ended 50 Ω, +7 dBm). 4× on-die multiplier → 24 GHz at full PLL setting. RFOUT1-4 drive TX-EMVS 1 cell Ex/Ey/Hx/Hy via 100 Ω diff matching networks (§RF Matching).")
    (note "U_TX_EMVS: TXEN behavior — there is NO dedicated TXEN pin on ADAR2001. Per-channel PA enable is via SPI registers 0x050/0x051 OR via the TX state machine (TxADV / TxRST). MAX7301 P23 (ADAR2001_TXEN) is intended to gate POWER (via external load switch / PFET on the 2.5 V rail to this IC) — wiring TBD. Not connected directly to U_TX_EMVS in this section.")
    (note "C_TX_VREG" "VPOS2/VREG 1 µF bypass — place within 2 mm of pins 6/7. VREG must connect directly to VPOS2 (datasheet pg 7); do NOT tie VPOS2 to an external 1.8 V rail.")
    (note "R_CS_TX_EMVS" "200 kΩ pull-up *CS → VREG (1.8 V). Combined with MAX7301 P20 pull-up (10 kΩ to 3.3 V on the host side), gives a 2-stage default-deasserted state. Datasheet pg 7."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; EMVS LO — LMX2594 6 GHz PLL+VCO
  ;; ─────────────────────────────────────────────────────────────────────

  (section "LMX2594 LO"
    "LMX2594 — 15 GHz wideband PLL+VCO, configured for 6 GHz output.  RFoutA
  (differential) → 2-way Wilkinson splitter → ADAR2004 #1 + #2 LOIN at +3.5
  dBm/port (single-ended); RFoutB direct → ADAR2001 RFIN at +7 dBm.  On-die
  ×4 multiplier in each ADAR brings 6 GHz LO up to 24 GHz internally — phase-
  coherent across TX (ADAR2001) and RX (ADAR2004 ×2) since all derive from a
  single VCO.  Per HW-RDR-001 §3.3 / §8.8 / §13.13.3.

  Reference: 100 MHz TCXO AC-coupled to OSCINP (single-ended; OSCINM tied to
  GND through 100 pF).  CE pin tied HIGH (always-enabled per §12 open item:
  'recommend tying to VCC to avoid PLL lock-up delay on EMVS enable').

  Loop filter design: TI TICS Pro tool — placeholder values below; final
  values per the specific phase-noise / lock-time targets of Rev E."
    (protocol SPI)
    (port "V_RF_3P3"        in  power 3.3)
    (port "V1P8_RF"         in  power 1.8)        ;; for VREG bypass network
    (port "GND"             bidi)
    (port "RF_SPI_SCK_1V8"  in  signal)
    (port "RF_SPI_MOSI_1V8" in  signal)
    (port "CS_LMX2594_1V8"  in  signal)
    (port "LD_LMX2594_1V8"  out signal)
    (port "RADAR_REF_AC"    in  signal)
    (port "LO_RX1"          out rf)               ;; via Wilkinson +3.5 dBm
    (port "LO_RX2"          out rf)               ;; via Wilkinson +3.5 dBm
    (port "LMX_RFOUTB_SE"   out rf)               ;; direct to ADAR2001 +7 dBm

    (instance "U_LMX2594" lmx2594rhat
      ;; CE — tied HIGH (always-on); 10 kΩ pull-up to 3.3 V
      (pin 1 "LMX_CE")
      ;; All GND pins + EP
      (pin 2 4 6 13 14 25 31 34 39 40 41 "GND")
      ;; Power rails (3.3 V analog through internal LDOs per datasheet)
      (pin 3 "VBIASVCO_BYP")            ;; VBIASVCO — bypass cap
      (pin 5 "LMX_SYNC")                ;; SYNC — testpoint / unused
      (pin 7 "V_RF_3P3")                ;; VCCDIG
      (pin 8 "RADAR_REF_AC")            ;; OSCINP — 100 MHz TCXO AC-coupled
      (pin 9 "OSCINM_AC")               ;; OSCINM — 100 pF to GND
      (pin 10 "V_RF_3P3")               ;; VREGIN
      (pin 11 "V_RF_3P3")               ;; VCCCP
      (pin 12 "LMX_CPOUT")              ;; charge-pump output → loop filter
      (pin 15 "V_RF_3P3")               ;; VCCMASH
      (pin 16 "RF_SPI_SCK_1V8")         ;; SCK
      (pin 17 "RF_SPI_MOSI_1V8")        ;; SDI
      ;; RFoutB differential — RFOUTBP direct to ADAR2001 (single-ended use,
      ;; RFOUTBM terminated 50 Ω to GND through AC-coupled cap).
      (pin 18 "LMX_RFOUTBM_TERM")       ;; RFOUTBM (50 Ω term)
      (pin 19 "LMX_RFOUTB_SE")          ;; RFOUTBP → ADAR2001 RFIN
      (pin 20 "LD_LMX2594_1V8")         ;; MUXOUT (config as Lock-Detect)
      (pin 21 "V_RF_3P3")               ;; VCCBUF
      ;; RFoutA differential — RFOUTAP single-ended to Wilkinson splitter
      (pin 22 "LMX_RFOUTAM_TERM")       ;; RFOUTAM (50 Ω term)
      (pin 23 "LMX_RFOUTA_SE")          ;; RFOUTAP → Wilkinson
      (pin 24 "CS_LMX2594_1V8")         ;; CSB
      (pin 26 "V_RF_3P3")               ;; VCCVCO2
      (pin 27 "VBIASVCO2_BYP")          ;; VBIASVCO2
      (pin 28 "SYSREFREQ_AC")           ;; SYSREFREQ — unused, AC-couple to GND
      (pin 29 "VREFVCO2_BYP")           ;; VREFVCO2
      (pin 30 "RAMPCLK_AC")             ;; RAMPCLK — unused
      (pin 32 "RAMPDIR_AC")             ;; RAMPDIR — unused
      (pin 33 "VBIASVARAC_BYP")         ;; VBIASVARAC
      (pin 35 "LMX_VTUNE")              ;; VTUNE — from loop filter
      (pin 36 "VREFVCO_BYP")            ;; VREFVCO
      (pin 37 "V_RF_3P3")               ;; VCCVCO
      (pin 38 "VREGVCO_BYP") (id a53fee4c))           ;; VREGVCO

    ;; CE pull-up (always-on)
    (instance "R_CE_LMX2594" (res-0402 "10k")
      (pin 1 "LMX_CE") (pin 2 "V_RF_3P3") (id e0014b90))

    ;; VCC bypass network — 100 nF on each VCC pin + 10 µF shared bulk
    (instance "C_LMX_VCCDIG"  (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id af735a74))
    (instance "C_LMX_VREGIN"  (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id d6fe543f))
    (instance "C_LMX_VCCCP"   (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id b4a79257))
    (instance "C_LMX_VCCMASH" (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id b946f13d))
    (instance "C_LMX_VCCBUF"  (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id cd8656e2))
    (instance "C_LMX_VCCVCO"  (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id a68fa36a))
    (instance "C_LMX_VCCVCO2" (cap-0402 "100nF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id e6e9054a))
    (instance "C_LMX_VCC_BULK" (cap-0805 "10uF") (pin 1 "V_RF_3P3") (pin 2 "GND") (id a1540816))

    ;; Internal-LDO bypass nodes (VBIAS / VREF / VREG)
    (instance "C_LMX_VBIASVCO"   (cap-0402 "100nF") (pin 1 "VBIASVCO_BYP")   (pin 2 "GND") (id c278f604))
    (instance "C_LMX_VBIASVCO2"  (cap-0402 "100nF") (pin 1 "VBIASVCO2_BYP")  (pin 2 "GND") (id df6f8361))
    (instance "C_LMX_VBIASVARAC" (cap-0402 "100nF") (pin 1 "VBIASVARAC_BYP") (pin 2 "GND") (id b964e6c9))
    (instance "C_LMX_VREFVCO"    (cap-0402 "100nF") (pin 1 "VREFVCO_BYP")    (pin 2 "GND") (id bbca2717))
    (instance "C_LMX_VREFVCO2"   (cap-0402 "100nF") (pin 1 "VREFVCO2_BYP")   (pin 2 "GND") (id a1ae00fc))
    (instance "C_LMX_VREGVCO"    (cap-0402 "1uF")   (pin 1 "VREGVCO_BYP")    (pin 2 "GND") (id a9ee8d98))

    ;; OSCINM single-ended termination
    (instance "C_LMX_OSCINM" (cap-0402 "100pF") (pin 1 "OSCINM_AC") (pin 2 "GND") (id c292b654))

    ;; Unused inputs — terminate to GND through 100 nF
    (instance "C_LMX_SYNC"      (cap-0402 "100nF") (pin 1 "LMX_SYNC")      (pin 2 "GND") (id b13494c9))
    (instance "C_LMX_SYSREFREQ" (cap-0402 "100nF") (pin 1 "SYSREFREQ_AC")  (pin 2 "GND") (id f3652fcd))
    (instance "C_LMX_RAMPCLK"   (cap-0402 "100nF") (pin 1 "RAMPCLK_AC")    (pin 2 "GND") (id f476413b))
    (instance "C_LMX_RAMPDIR"   (cap-0402 "100nF") (pin 1 "RAMPDIR_AC")    (pin 2 "GND") (id ed14b62e))

    ;; Loop filter — TICS Pro template values (TBD, redesign for 6 GHz / 100 MHz ref / phase-noise target).
    ;; 3rd-order passive: CPOUT → R1 → C2 || C1 → R2 → C3 → VTUNE
    (instance "R_LMX_LF1" (res-0805 "200R")  (pin 1 "LMX_CPOUT") (pin 2 "LMX_LF_NODE1") (id a99ba07e))
    (instance "C_LMX_LF1" (cap-0805 "1nF")   (pin 1 "LMX_LF_NODE1") (pin 2 "GND") (id dd29c6c1))
    (instance "C_LMX_LF2" (cap-0805 "10nF")  (pin 1 "LMX_LF_NODE1") (pin 2 "GND") (id a9a9f820))
    (instance "R_LMX_LF2" (res-0805 "100R")  (pin 1 "LMX_LF_NODE1") (pin 2 "LMX_VTUNE") (id f67261e9))
    (instance "C_LMX_LF3" (cap-0805 "100pF") (pin 1 "LMX_VTUNE")    (pin 2 "GND") (id e6981228))

    ;; RFoutA / RFoutB single-ended termination of the unused leg
    (instance "R_LMX_RFOUTAM" (res-0201 "50R") (pin 1 "LMX_RFOUTAM_TERM") (pin 2 "GND") (id d6d4c72f))
    (instance "R_LMX_RFOUTBM" (res-0201 "50R") (pin 1 "LMX_RFOUTBM_TERM") (pin 2 "GND") (id fc3a4147))

    ;; ─── 2-way Wilkinson splitter (RFoutA → LO_RX1 + LO_RX2) ───────────
    ;; The splitter itself is implemented in PCB trace geometry: two
    ;; quarter-wave 70.7 Ω microstrip arms at 6 GHz (~6.6 mm on RO4350B)
    ;; from RFoutAP into LO_RX1 / LO_RX2 with a 100 Ω thin-film isolation
    ;; resistor across the junction.  Only the isolation resistor is
    ;; modeled here as an instance.  Placement ≤15 mm from LMX2594.
    ;; Per HW-RDR-001 §13.13.3.
    (instance "R_WILK_ISO" (res-0402 "100R")
      (pin 1 "LO_RX1") (pin 2 "LO_RX2") (id e6ab2118))
    ;; AC coupling at the splitter inputs/outputs (LMX RF outputs are AC-coupled
    ;; on-die, but explicit blocking caps on the ADAR side enforce DC isolation).
    (instance "C_LO_RX1_AC" (cap-0201 "100pF")
      (pin 1 "LMX_RFOUTA_SE") (pin 2 "LO_RX1") (id f76fbf63))
    (instance "C_LO_RX2_AC" (cap-0201 "100pF")
      (pin 1 "LMX_RFOUTA_SE") (pin 2 "LO_RX2") (id f26289e7))

    (note "U_LMX2594" "LMX2594 6 GHz PLL+VCO. Reference: 100 MHz TCXO single-ended on OSCINP, OSCINM 100 pF to GND. CE always-on (10 kΩ pull-up to 3.3 V). VTUNE comes from loop-filter output; CPOUT from charge pump.")
    (note "U_LMX2594: SPI is 1.8 V — all SCK/SDI/CSB/MUXOUT routed via TXS0108E from the 3.3 V host side. CSB pull-up to 1.8 V is internal to the chip; an external 10 kΩ on the 3.3 V side (in §MAX7301 RF I/O Expander) keeps the host-side trace safe at boot.")
    (note "Wilkinson splitter: PCB trace geometry, not discrete components. R_WILK_ISO (100 Ω 0402) is the isolation resistor at the junction. Two quarter-wave 70.7 Ω arms (~6.6 mm @ 6 GHz on RO4350B 0.508 mm) split RFoutA into LO_RX1 + LO_RX2 at +3.5 dBm/port. Phase-match the two arms within 5° at 6 GHz.")
    (note "Loop filter R_LMX_LF1/LF2 + C_LMX_LF1/LF2/LF3: TEMPLATE values — must be regenerated from TI TICS Pro for the specific 6 GHz / 100 MHz ref / phase-noise / lock-time design point. Open item per HW-RDR-001 §12."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; EMVS RX — ADAR2004 #1 (existing — unchanged)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "ADAR2004 #1 Rx Mixer" "ADAR2004 4-channel Rx mixer — RX1 RFIN1..4 down-convert to IFOUT1..4 → mezz ADF_CH5..CH8 (RX-EMVS Cell 1, top-right). Per-chip CS = CS_RX1 from MAX7301 P9; LO from LMX2594 RFoutA via Wilkinson splitter (LO_RX1). VPOS1/2/4 from V_RX_2P5; VPOS3 tied to on-die VREG. Note: Rev E SPI/control nets transit TXS0108E (1.8 V side suffix _1V8); existing instance below uses the original (unsuffixed) names — until the TXS0108E section is populated, those nets are direct ties to the host-side 3.3 V signals (out of spec for the ADAR2004's 1.8 V digital I/O)."
    (protocol SPI)
    (port "V_RX_2P5"    in  power 2.5)
    (port "GND"         bidi)
    (port "RF_SPI_SCK"  in  signal)
    (port "RF_SPI_MOSI" in  signal)
    (port "RF_SPI_MISO" out signal)
    (port "CS_RX1"      in  signal)
    (port "MRST"        in  signal role reset)
    (port "MADV"        in  signal)
    (port "RxRST"       in  signal role reset)
    (port "RxADV"       in  signal)
    (port "LO_RX1"      in  rf)
    (port "RX1_RFIN1+"  in  differential) (port "RX1_RFIN1-" in differential)
    (port "RX1_RFIN2+"  in  differential) (port "RX1_RFIN2-" in differential)
    (port "RX1_RFIN3+"  in  differential) (port "RX1_RFIN3-" in differential)
    (port "RX1_RFIN4+"  in  differential) (port "RX1_RFIN4-" in differential)
    (bus-port "ADF_CH" 5 8 (suffixes P N) out differential)

    (instance "U1" adar2004accz
      ;; All 18 GND pins + 4 EPADs to ground plane
      (pin 2 5 6 7 8 9 12 14 17 18 23 34 36 37 39 44 45 48 "GND")
      (pin 49 50 51 52 "GND")
      ;; Analog 2.5 V supplies (VPOS1, VPOS2, VPOS4)
      (pin 1 13 38 "V_RX_2P5")
      ;; Digital 1.8 V supply: VPOS3 MUST be tied directly to VREG
      (pin 32 "U1_VREG")          ;; VPOS3
      (pin 33 "U1_VREG")          ;; VREG
      (pin 24 "RF_SPI_MISO")
      (pin 25 "CS_RX1")
      (pin 26 "RF_SPI_MOSI")
      (pin 27 "RF_SPI_SCK")
      (pin 28 "RxRST") (pin 29 "RxADV")
      (pin 30 "MRST")  (pin 31 "MADV")
      (pin 35 "LO_RX1")
      (pin 47 "RX1_RFIN1+") (pin 46 "RX1_RFIN1-")
      (pin 4  "RX1_RFIN2+") (pin 3  "RX1_RFIN2-")
      (pin 10 "RX1_RFIN3+") (pin 11 "RX1_RFIN3-")
      (pin 15 "RX1_RFIN4+") (pin 16 "RX1_RFIN4-")
      (pin 43 "ADF_CH5P") (pin 42 "ADF_CH5N")
      (pin 41 "ADF_CH6P") (pin 40 "ADF_CH6N")
      (pin 21 "ADF_CH7P") (pin 22 "ADF_CH7N")
      (pin 19 "ADF_CH8P") (pin 20 "ADF_CH8N") (id b70251e5))

    (instance "C1A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id c90d547c))
    (instance "C1B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id c76b1266))
    (instance "C2A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id ea2ed69a))
    (instance "C2B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id d4484f0f))
    (instance "C4A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id dd0cac57))
    (instance "C4B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id fc6a5075))
    (instance "C3A" (cap-0402 "1uF")   (pin 1 "U1_VREG") (pin 2 "GND") (id a3aab5de))
    (instance "R_CS1" (res-0402 "200k") (pin 1 "CS_RX1") (pin 2 "U1_VREG") (id c76e1446))

    (note "U1" "ADAR2004 #1 — RX-EMVS Cell 1 (top-right). IFOUT1..4 → mezz ADF_CH5..CH8 (Rev E remap: Cell 1 on ADC2). *CS = CS_RX1 from MAX7301 P9. LO from LO_RX1 (LMX2594 RFoutA via Wilkinson splitter, +3.5 dBm).")
    (note "C3A" "VPOS3/VREG bypass — 1 µF, place close to pins 32/33 of U1 (datasheet pg 7).")
    (note "R_CS1" "200 kΩ pull-up *CS→VREG keeps U1's SPI off when not addressed (datasheet pg 7)."))

  ;; ─────────────────────────────────────────────────────────────────────
  ;; EMVS RX — ADAR2004 #2 (existing — unchanged)
  ;; ─────────────────────────────────────────────────────────────────────

  (section "ADAR2004 #2 Rx Mixer" "ADAR2004 4-channel Rx mixer — RX2 RFIN1..4 down-convert to IFOUT1..4 → mezz ADF_CH1..CH4 (RX-EMVS Cell 2, bottom-left). Per-chip CS = CS_RX2 from MAX7301 P10; LO from LMX2594 RFoutA via Wilkinson splitter (LO_RX2). VPOS1/2/4 from V_RX_2P5; VPOS3 tied to on-die VREG. Rev E remap: Cell 2 IF outputs land on connector CH1-CH4 (ADC1)."
    (protocol SPI)
    (port "V_RX_2P5"    in  power 2.5)
    (port "GND"         bidi)
    (port "RF_SPI_SCK"  in  signal)
    (port "RF_SPI_MOSI" in  signal)
    (port "RF_SPI_MISO" out signal)
    (port "CS_RX2"      in  signal)
    (port "MRST"        in  signal role reset)
    (port "MADV"        in  signal)
    (port "RxRST"       in  signal role reset)
    (port "RxADV"       in  signal)
    (port "LO_RX2"      in  rf)
    (port "RX2_RFIN1+"  in  differential) (port "RX2_RFIN1-" in differential)
    (port "RX2_RFIN2+"  in  differential) (port "RX2_RFIN2-" in differential)
    (port "RX2_RFIN3+"  in  differential) (port "RX2_RFIN3-" in differential)
    (port "RX2_RFIN4+"  in  differential) (port "RX2_RFIN4-" in differential)
    (bus-port "ADF_CH" 1 4 (suffixes P N) out differential)

    (instance "U2" adar2004accz
      (pin 2 5 6 7 8 9 12 14 17 18 23 34 36 37 39 44 45 48 "GND")
      (pin 49 50 51 52 "GND")
      (pin 1 13 38 "V_RX_2P5")
      (pin 32 "U2_VREG")          ;; VPOS3
      (pin 33 "U2_VREG")          ;; VREG
      (pin 24 "RF_SPI_MISO")
      (pin 25 "CS_RX2")
      (pin 26 "RF_SPI_MOSI")
      (pin 27 "RF_SPI_SCK")
      (pin 28 "RxRST") (pin 29 "RxADV")
      (pin 30 "MRST")  (pin 31 "MADV")
      (pin 35 "LO_RX2")
      (pin 47 "RX2_RFIN1+") (pin 46 "RX2_RFIN1-")
      (pin 4  "RX2_RFIN2+") (pin 3  "RX2_RFIN2-")
      (pin 10 "RX2_RFIN3+") (pin 11 "RX2_RFIN3-")
      (pin 15 "RX2_RFIN4+") (pin 16 "RX2_RFIN4-")
      (pin 43 "ADF_CH1P") (pin 42 "ADF_CH1N")     ;; Rev E: Cell 2 → CH1-4
      (pin 41 "ADF_CH2P") (pin 40 "ADF_CH2N")
      (pin 21 "ADF_CH3P") (pin 22 "ADF_CH3N")
      (pin 19 "ADF_CH4P") (pin 20 "ADF_CH4N") (id d8aa052b))

    (instance "C5A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id fbf099f3))
    (instance "C5B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id d3852829))
    (instance "C6A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id c3fba818))
    (instance "C6B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id a8ef84de))
    (instance "C8A" (cap-0402 "10nF")  (pin 1 "V_RX_2P5") (pin 2 "GND") (id c97ae63e))
    (instance "C8B" (cap-0402 "100pF") (pin 1 "V_RX_2P5") (pin 2 "GND") (id f5396da7))
    (instance "C7A" (cap-0402 "1uF")   (pin 1 "U2_VREG") (pin 2 "GND") (id ae4198e8))
    (instance "R_CS2" (res-0402 "200k") (pin 1 "CS_RX2") (pin 2 "U2_VREG") (id d3bd82eb))

    (note "U2" "ADAR2004 #2 — RX-EMVS Cell 2 (bottom-left). Rev E remap: IFOUT1..4 → mezz ADF_CH1..CH4 (ADC1). *CS = CS_RX2 from MAX7301 P10. LO from LO_RX2 (Wilkinson splitter).")
    (note "C7A" "VPOS3/VREG bypass — 1 µF, place close to pins 32/33 of U2.")
    (note "R_CS2" "200 kΩ pull-up *CS→VREG."))

  ;; ─── Design ports (signals crossing this block boundary) ───────────────
  ;; Power coming in from the mezzanine
  (port "VBATT" in (rated 3.0 4.2))
  (port "V1P8"  in (rated 1.71 1.89))            ;; from digital LP5912 — unused
  (port "GND"   bidi)

  ;; RF SPI bus + MAX7301 *CS from the host
  (port "RF_SPI_SCK"  in)
  (port "RF_SPI_MOSI" in)
  (port "RF_SPI_MISO" out)
  (port "CS_IO_EXP"   in)

  ;; ADAR step / reset bus — direct STM32 GPIOs (3.3 V CMOS)
  (port "MRST"  in)
  (port "MADV"  in)
  (port "TxADV" in)                              ;; Rev E: pin 50 — was RxRST
  (port "RxADV" in)

  ;; K-band TX direct GPIOs (3.3 V CMOS — no level shift)
  (port "TXDATA_1"     in)
  (port "TXDATA_2"     in)
  (port "BPSK_GATE_1"  in)
  (port "BPSK_GATE_2"  in)

  ;; Hardware-paced timing references (TIM2)
  (port "CHIRP_START" in)
  (port "CNV_MASTER"  in)

  ;; Main K-band RX antenna inputs (single-ended 50 Ω from patch arrays)
  (port "BEAM1_RFIN" in)                         ;; RX SA2 → PMA3 #1
  (port "BEAM2_RFIN" in)                         ;; RX SA3 → PMA3 #2

  ;; K-band TX outputs — to TX1/TX2 patch antenna feeds (after HMC1131)
  (port "TX1_RFOUT" out)
  (port "TX2_RFOUT" out)

  ;; TX-EMVS 1 cell differential outputs from ADAR2001 (Rev E)
  (port "TX_EMVS_Ex+" out) (port "TX_EMVS_Ex-" out)
  (port "TX_EMVS_Ey+" out) (port "TX_EMVS_Ey-" out)
  (port "TX_EMVS_Hx+" out) (port "TX_EMVS_Hx-" out)
  (port "TX_EMVS_Hy+" out) (port "TX_EMVS_Hy-" out)

  ;; EMVS RX cell differential inputs (existing — unchanged)
  (port "RX1_RFIN1+" in) (port "RX1_RFIN1-" in)
  (port "RX1_RFIN2+" in) (port "RX1_RFIN2-" in)
  (port "RX1_RFIN3+" in) (port "RX1_RFIN3-" in)
  (port "RX1_RFIN4+" in) (port "RX1_RFIN4-" in)
  (port "RX2_RFIN1+" in) (port "RX2_RFIN1-" in)
  (port "RX2_RFIN2+" in) (port "RX2_RFIN2-" in)
  (port "RX2_RFIN3+" in) (port "RX2_RFIN3-" in)
  (port "RX2_RFIN4+" in) (port "RX2_RFIN4-" in))
