# Cyclops Digital — Board Bring-Up

First-power and validation checklist for the freshly assembled board.
Work top-to-bottom; do not skip ahead until each phase passes.

The power topology is:

```
USB-C (VBUS, 5V) ──► MCP73831 charger ──► VBATT (LiPo, 3.0–4.2 V)
                                            │
                                            ▼
                                   STM6601 power button
                                     (gates buck EN)
                                            │
                                            ▼
                                   TPS63806 buck-boost ──► VDD (3.3 V)
                                            │                   │
                                       PG_3V3 ──► LP5912 LDO ──► V1P8 (1.8 V)
                                                                 │
                                            STM32 internal SMPS  ▼
                                            (L1 1 µH + snubber)
                                                                 │
                                                                 ▼
                                                           VDDCORE (0.8 V)
```

Test points (1 mm SMD probe pads, in the "Test Points" section of the
schematic):

| TP  | Net      | Expected            | Lives when…                          |
| --- | -------- | ------------------- | ------------------------------------ |
| TP1 | VBATT    | 3.0–4.2 V           | Battery or USB present               |
| TP2 | VDD      | 3.30 V (±1 %)       | Buck enabled (button pressed)        |
| TP3 | V1P8     | 1.80 V (±1 %)       | After PG_3V3 asserts                 |
| TP4 | VDDCORE  | 0.80 V (±5 %)       | STM32 SMPS up (after NRST releases)  |
| TP5 | NRST     | low in reset, else 3.3 V | Always meaningful                |
| TP6 | PG_3V3   | 3.3 V when in regulation | Buck running                     |
| TP7 | BOOT0    | 0 V normal, 3.3 V to enter ST bootloader | Always meaningful   |
| TP8 | PWR_ON   | 3.3 V after MCU boots | STM32 firmware drives this        |

---

## Phase 0 — Pre-power inspection (no power applied)

Do this *before* connecting USB or battery. Catches assembly faults that
would otherwise vent magic smoke.

1. **Continuity / short checks with DMM (resistance mode).**
   With board un-powered, probe between each rail and GND. Looking for
   shorts, not exact resistance.
   - VBATT ↔ GND: > 100 kΩ (charger bypass caps will show a few seconds
     of charge then settle high).
   - VDD ↔ GND: > 10 kΩ. A dead short here is the #1 first-assembly
     failure (solder ball under the buck or under a 47 µF cap).
   - V1P8 ↔ GND: > 10 kΩ.
   - VDDCORE ↔ GND: > 1 kΩ (15 µF + 1 µF + 4× 0603s on this node, so
     allow some bleed time).
   - VREF_2V5 ↔ GND: > 10 kΩ.
   - USB_DP ↔ USB_DN: open circuit (> 1 MΩ).

2. **BOOT0 / NRST defaults.**
   - BOOT0 (TP7): pulled to GND via R_BOOT0 10 k — DMM should read ~0 Ω
     to GND.
   - NRST (TP5): pulled to VDD via R_NRST_PU 10 k inside the STM6601
     module — should be open or high-impedance when nothing is driving
     it, not shorted to GND.


---

## Phase 1 — First power, no MCU activity

Goal: confirm the analog power chain comes up cleanly *before* the MCU
gets a chance to run firmware. Hold the board in reset throughout this
phase (jumper TP5 → GND, or keep BOOT0 high so the ROM bootloader runs
and does nothing).

### 1a. Bench supply on VBATT (preferred over LiPo for first power)

1. Set bench PSU to **3.7 V, current limit 200 mA**.
2. Connect + to VBATT (TP1), – to a GND pad. **Do not yet press the
   power button.**
3. Read current: should idle at **≤ 10 µA** (STM6601 quiescent 2.5 µA +
   charger leakage ≈ 3 µA). Anything > 100 µA in the off state means
   something downstream of the buck is leaking through.
4. Probe TP1 — must read 3.70 V.

### 1b. Button press → buck → VDD

1. Press the power button (SW2 on the STM6601 module).
2. Buck output (TP2) should snap to **3.30 V ± 0.05 V** within ~1 ms.
3. PG_3V3 (TP6) should follow ~1 ms after VDD is in regulation.
4. LDO output V1P8 (TP3) should come up to **1.80 V ± 0.02 V** within
   ~1 ms of PG_3V3.
5. Current draw at this point: **~5–15 mA** with MCU in reset (just
   regulator quiescent + ferrite-bead leakage + analog rail caps).

If TP2 doesn't come up:
- Probe SW_L1/SW_L2 with a scope — should see ~1 MHz switching. No
  switching → check EN at U1 of the buck block (should be high when
  PWR_EN asserts).
- TP_PG_3V3 (TP6) staying low while VDD looks correct → R_PG (100 k
  pull-up to VOUT) is missing, or PG transistor inside U1 is stuck.
- VDD overshoots > 3.5 V or oscillates: check feedback divider
  R_FBT (511 k) / R_FBB (91 k) — a wrong value or missing R_FBB drives
  VOUT to the rails.

If TP3 doesn't come up after TP6 asserts:
- LDO EN port on the ldo block is tied to PG_3V3. If TP6 is high but
  TP3 is 0 V, suspect a cold joint on U1 of the ldo block or its EN.

### 1c. STM32 internal SMPS → VDDCORE

The STM32N657 generates its own 0.8 V core rail through an internal
SMPS, with the 1 µH `L1` inductor between **VLXSMPS** (pins K1–K5) and
**VDDCORE** (pins P7,P9–P13,W6, plus G2 feedback). This rail only comes
up once VDD is stable *and* NRST is released long enough for the SMPS
controller to start.

1. Release NRST (remove the TP5↔GND jumper if you installed one).
2. Probe TP4 — must read **0.80 V ± 0.04 V**. The 4× 15 µF + 1 µF bulk
   means it ramps in ~100 µs.
3. With a scope on TP4: ripple should be < 20 mV pk-pk. If you see
   > 100 mV ripple, the snubber (C18 2.2 nF + R1 2 Ω across VLXSMPS to
   GND) is likely missing or wrong value.
4. **NRST must release within tON_BLANK ≈ 1.4–3.0 s of pressing the
   button**, or the STM6601 will latch the rail back off. If you keep
   the MCU in reset for too long during bench probing, expect the
   board to power-cycle itself — this is by design.

### 1d. PSHOLD handshake (very important — do this before flashing)

The STM6601 is a latching controller. After the user presses the
button, the chip drives PWR_EN HIGH, but it will drop the rail again
unless firmware drives **PSHOLD** HIGH within **tON_BLANK (1.4–3.0 s)**.
Out of the box, the MCU has no firmware, so:

- Either flash a stub firmware (Phase 2) that immediately drives PG6
  high, **or**
- Tack a temporary 10 kΩ from PSHOLD (probe the STM6601 module's
  PSHOLD net) to VDD to force the board on while you do initial
  flashing. Remove this jumper as soon as real firmware is on the
  chip — the 1 MΩ pull-down to GND (R_PSHOLD_PD in the module) is the
  intentional fallback during MCU resets.

### 1e. Switch to LiPo

Once 1a–1d pass on bench supply, repeat with the real LiPo. The buck
is rated 1.3–5.5 V VIN so 3.0–4.2 V is well inside the envelope. If
the board behaves on bench but not on battery, suspect a cold joint on
the LiPo solder pads (re-flow the strain relief), not the chemistry.

### 1f. USB charging

1. Plug USB-C with **no battery installed**: VBUS (USB connector
   shield/pins) should be 5 V, VBATT should sit at ~4.2 V via the
   MCP73831 if it sees no load, charge LED off.
2. With battery installed and partly discharged, plug USB-C: charge
   LED (D_CHG, orange, off the charger block) lights, charge current
   should be ~500 mA (RPROG = 2 k). Confirm by inline ammeter on the
   battery wire if you want a precise number.
3. Charging completes → LED off, VBATT settles at ~4.2 V.

---

## Phase 2 — SWD / initial flashing

The SWD header `swd-hdr` is a 6-pin connector with VDD, SWDIO, SWCLK,
SWO, NRST, GND. Series 33 Ω dampers (R4/R5/R6) sit between the MCU and
the header.

1. Connect ST-Link V3 (or J-Link) **with the board powered** — never
   hot-plug SWD into an unpowered target; it can phantom-power the I/O
   bank and confuse the SMPS startup.
2. Verify the target IDCODE matches STM32N657 in your toolchain.
3. Read out flash (option-byte read) — confirm the chip responds and
   read protection is at level 0 from the factory.
4. **Flash the minimal bring-up firmware** described in Phase 3 before
   doing anything else. The board cannot stay on without it.

If SWD does not enumerate:
- Confirm BOOT0 is low (TP7 ≈ 0 V) — the chip won't expose the SWD
  IDCODE cleanly while it's also trying to run the ROM bootloader.
- Probe SWCLK at TP5/header side: should see clock activity while the
  debugger is in "connect" mode. No clock at the MCU pin (W7/V7) but
  clock at the header = bad reflow on R4/R5.
- Try "connect under reset" — hold NRST low via ST-Link while issuing
  the connect.

---

## Phase 3 — Minimum bring-up firmware

Before validating any peripheral, flash a stub that satisfies the
hardware contract. Without this, the board will power-cycle every 2 s.

Required behaviours, in order, from `main()`:

1. **Drive PG6 (PSHOLD) HIGH immediately.** Set MODER/ODR before
   anything else in `main()`. This must happen well inside the
   tON_BLANK window (1.4–3.0 s from NRST release), so don't put it
   after a slow clock-config routine — push the clock config to after
   this.
2. **Configure HSE = 24 MHz crystal**, lock the main PLL. Read
   RCC_CR.HSERDY — should be set within ~2 ms. If HSE never locks,
   probe TP_OSC_IN (or scope OSC_OUT on the ABM8 X2 pad): sine
   ~24 MHz, ~1 V pk-pk. No oscillation → check the 10 pF load caps
   (formula `2 × (CL − Cstray) = 2 × (10 − 5) = 10 pF` per leg) and
   reflow the crystal pads.
3. **Enable IWDG, 4–8 s timeout.** Per the schematic firmware contract,
   IWDG must be running early and refreshed *only from the main loop*,
   never from an ISR. This is what saves the board if firmware hangs.
4. **Disable PC13 RTC tamper** (`TAMP_CR1`/`CR2` clear) before using
   PC13 as a GPIO input for the power button (PWR_BTN net).
5. **Configure LSE = 32.768 kHz crystal**, RTC clock source, confirm
   LSERDY.
6. **Drive PG1 (CHG_EN) appropriately** — high to enable charging,
   low if firmware wants to disable charging (e.g. low temp). The
   MCP73831 itself has no EN pin; this GPIO must drive whatever your
   stub firmware decides is the default (high = always charge when USB
   is present is the safe default).
7. **Loop: refresh IWDG, blink GPIO** so you can confirm the chip is
   alive with no debugger attached.

Sanity check with a logic analyzer on PG6 (PSHOLD) after pressing the
button: should go high within ~10 ms of NRST release and stay high
indefinitely. Sanity check the button: short press (< 2 s) → PWR_BTN
pulse on PC13; long press (> 2 s) is the user's "force off" signal —
firmware should drop PSHOLD low to gracefully release the rail.

---

## Phase 4 — Peripheral validation

Order: simplest / safest first; the radar expansion connector last.

### 4.1 Clocks
- **HSE 24 MHz**: confirmed in Phase 3. Required by the USB HS PHY.
- **LSE 32.768 kHz**: confirmed in Phase 3. Required by RTC.

### 4.2 USB 2.0 HS
- Configure USB2 OTG HS in device mode, descriptor as CDC ACM
  (cheapest virtual COM port).
- Plug into a host PC — should enumerate. If it does not:
  - Scope USB_DP / USB_DN at the MCU side; expect ~3.3 V idle on DP
    after pull-up enables.
  - Confirm VDDA18USB (D4) is at 1.8 V (filtered via FB3) and
    VDD33USB (C3) is at 3.3 V.
  - TXRTUNE (E2) is the USB PHY trim — handled internally by the
    `usb-c-hs` module; nothing to do at runtime.

### 4.3 XSPI2 NOR flash (MX66UW1G45G, 1 Gbit)
- Issue READ-ID over single-SPI to confirm the JEDEC ID before
  switching to OctoSPI mode.
- Run a small read/program/erase loop on a sacrificial sector.
- DQS / data lanes are 8 IOs (PN2–PN5, PN8–PN11). Failure here is
  usually one cold-joined ball — read-back the failing lane via
  single-SPI and you'll see which one.

### 4.4 XSPI1 PSRAM (APS256, 256 Mbit)
- Standard OctoSPI PSRAM bring-up: issue read-register, confirm
  device ID, then run a march-pattern (0x55/0xAA/0xFF/0x00) across
  the full 32 MB.
- DQS0/DQS1 are both used — the APS256 needs both edges aligned.

### 4.5 BNO08x IMU (SPI5)
- Pulse IMU_NRST low for ≥ 10 ms, release, wait for the BOOT pin /
  INT line to come ready.
- Read SHTP product-ID-request response over SPI5. If you get
  zeros, scope IMU_NCS (V1) — first-power issues are almost always
  a stuck CS.

### 4.6 Vibration motor (TIM1_CH1 on PB2)
- PWM at 1 kHz, 50 % duty for 200 ms — should buzz audibly.
- Watch VBATT droop on a scope — a strong pulse will sag VBATT ~50 mV
  on a fresh cell; > 200 mV means the cell is tired.

### 4.7 LTC6655 voltage reference + 3× AD7380 ADCs
- VREF_2V5 net at the ADCs: scope with AC coupling — noise should be
  < 1 µVrms in the 10 Hz–1 kHz band. If you see hum, suspect the bulk
  cap on the star node under adc2 is missing or cold-joined.
- Phase-1 (GPIO bit-bang) config: shift register-config bytes into
  each ADC's SDI individually via per-ADC CS pulses. Read back the
  config register through ADC1_SDOA / ADC2_SDOA / ADC3_SDOA (these
  are PSSI_D1 / D2 / D8 used as GPIO inputs during Phase-1).
- Phase-2 (4 MSPS PSSI streaming): only attempt this *after* Phase-1
  read-back confirms all three ADCs respond. T9 (ADC_SCK_DRV) flips
  to TIM1_CH1 AF, CS1/CS2/CS3 to TIM1_CH2/3/4 AF, PSSI captures the
  10 active SDO lanes.

### 4.8 Power button events
- Short press while running: PWR_BTN (PC13) should go low for the
  duration of the press, then release. PWR_INT pulses too — firmware
  reads PWR_BTN to disambiguate button-press from undervoltage.
- Long press (> 2 s): firmware sees the long press, drops PSHOLD
  → STM6601 deasserts PWR_EN → buck disables → board powers down
  cleanly. Off-state battery draw should drop to ≈ 5 µA.

### 4.9 IWDG recovery
- Deliberately hang the firmware in a tight loop without refreshing
  IWDG. The board must reset within the configured timeout (4–8 s).
  On reset, PG6 goes Hi-Z, R_PSHOLD_PD (1 MΩ) pulls PSHOLD low, the
  STM6601 power-cycles the rail. Verify the board comes back up
  rather than latching off.

### 4.10 Expansion connector (60-pin BTB) — do this *last*
- With no daughterboard mated: confirm VBATT (pins 4/6/8/10), V1P8
  (14/16), and GND (multiple) are at the right voltages on the
  connector pads.
- Toggle each radar-control GPIO (TXDATA_1/2, BPSK_GATE_1/2,
  MRST/MADV, RxRST/RxADV, CS_IO_EXP, CNV_MASTER, CHIRP_START) and
  probe with a scope at the connector — establishes that all 60 pins
  reach the connector before any expensive RF board sees them.
- Only then mate the radar daughterboard.

---

## Failure-mode quick reference

| Symptom                                  | First thing to probe                         |
| ---------------------------------------- | -------------------------------------------- |
| Board powers off ~2 s after button press | PSHOLD — firmware not driving it HIGH in time |
| Button does nothing                      | VBATT at TP1, then STM6601 VBATT pin         |
| VDD low or oscillating                   | Buck FB divider (R_FBT 511 k / R_FBB 91 k)   |
| V1P8 missing                             | PG_3V3 at TP6 — LDO EN depends on it         |
| VDDCORE missing                          | Snubber C18 / R1, then VLXSMPS switching     |
| SWD won't connect                        | BOOT0 high? Try "connect under reset"        |
| HSE won't oscillate                      | 10 pF load caps on OSC_IN / OSC_OUT          |
| LSE won't oscillate                      | 6.8 pF load caps; LSE is most sensitive to flux residue |
| USB enumerates as low-speed              | HSE not at 24 MHz                            |
| One ADC lane reads zero                  | Cold joint on that PSSI_Dx ball              |
| Off-state current > 50 µA                | Something on VBATT is leaking — usually the charger or a stranded cap from rework |

---

## Sign-off

Board is considered "brought up" when all of the following are true:

- All four rails (VBATT, VDD, V1P8, VDDCORE) are in spec at the test
  points.
- IWDG-induced reset cleanly recovers (no latch-off).
- USB enumerates as a CDC ACM device.
- NOR flash, PSRAM, IMU, display, ADCs all respond to their lightest
  identification command.
- Off-state battery draw measured ≤ 10 µA on a calibrated bench
  ammeter.
- One charge cycle from empty to full has completed without
  thermal events.
