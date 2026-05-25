Here is the updated architecture and bill of materials, integrating the ESP32‑S3 co‑processor, galvanic DMM isolation, calibration EEPROM, DC barrel jack, DUT pin protection, and external trigger BNC.

---

# Bench Lab Multitool — Architecture & Bill of Materials (Revision 1.1)

A self‑contained bench instrument combining a programmable dual‑channel power supply, multi‑protocol logic analyzer/programmer, and an isolated 3½‑digit digital multimeter. Standalone‑capable through a large touchscreen UI driven by an ESP32‑S3, with Wi‑Fi networking built in. Connects to a host computer over USB‑C for scripting, data analysis, and additional remote access.

---

## 1. What the Device Does

**Same core functionality as v1.0** — two 0–18 V / 3 A PSU channels, 24 DUT GPIOs at programmable VCCIO, a logic analyzer and protocol bridge, and a DMM — with these enhancements:

- **Galvanically isolated DMM** (3 kV isolation barrier) so the probe leads can float safely relative to the rest of the instrument. No ground‑loop or sneak‑path concerns when probing circuits with different reference potentials.
- **ESP32‑S3 co‑processor** that drives a **5‑inch 800×480 capacitive touchscreen** and provides onboard Wi‑Fi. The device is fully usable standalone with a rich graphical UI, and can be accessed via a web dashboard without any host computer.
- **On‑device program storage & execution**: Test sequences (scripts) can be stored on the ESP32‑S3’s flash, selected and run from the touchscreen, enabling automated burn‑in, validation, or bring‑up flows without a host.
- **Calibration EEPROM** on the isolated DMM side, storing factory and user calibration constants for voltage and resistance ranges.
- **Alternative DC input** via a 5.5 mm barrel jack (9–24 V) to power the PSU channels from any lab bench supply, bypassing USB‑C PD.
- **Protected DUT I/O**: Each DUT pin includes series resistance and a TVS clamp, preventing damage from accidental over‑voltage or ESD during probing.
- **External trigger BNC** for synchronising the logic analyzer with oscilloscopes, signal generators, or external events.

---

## 2. Functional Split

Updated to reflect the two‑processor architecture.

| Function | Owner | Notes |
|---|---|---|
| PSU real‑time control loop | RP2350 (1 kHz) | Hardware OCP <1 ms response |
| PSU + VBUS telemetry sampling | RP2350 via I²C bus #1 | INA228s at 1 kHz |
| Logic analyzer & protocol engines | RP2350 PIO + DMA | Up to 25 MS/s; PIO‑based protocols |
| DMM ADC reads (isolated side) | RP2350 via isolated I²C bus #2 | ADS1115 at ~10 SPS, across isolation |
| DMM continuity beep | RP2350 (local, real‑time) | Threshold check & buzzer, no host |
| Touchscreen UI rendering | **ESP32‑S3** | Full LVGL GUI, touch, animations |
| Wi‑Fi networking & web server | **ESP32‑S3** | HTTP/WebSocket API, OTA updates |
| Program storage & execution | **ESP32‑S3** | Scripts in flash, send cmds to RP2350 |
| Encoder, buzzer, abort button | RP2350 GPIO/PIO | Hard real‑time, safety critical |
| Trigger BNC I/O | RP2350 GPIO (PIO) | Configurable input/output |
| Host USB command/control | USB CDC (RP2350) | Alternative remote path |
| Telemetry stream to host | USB bulk (RP2350) | Live V/I/temp/state |
| Capture data transfer | USB bulk (RP2350) | LA captures |
| Firmware update | RP2350 USB bootloader (UF2) | Both RP2350 and ESP32‑S3 updatable via USB |

**Communication between RP2350 and ESP32‑S3** occurs over a dedicated SPI bus (RP2350 as SPI peripheral, ESP32‑S3 as master) with a simple binary protocol for commands, telemetry, and display data.

---

## 3. Bill of Materials

All new or significantly changed sections are marked with **[NEW/REVISED]**.

### 3.1 USB‑C Host Interface (unchanged)

| Function | Part | Qty | Unit Price |
|---|---|---|---|
| USB‑C connector (host data) | GCT USB4105‑GF‑A | 1 | $0.75 |
| USB‑C connector (POWER port) | GCT USB4105‑GF‑A | 1 | $0.75 |
| USB ESD (×2 ports) | ST USBLC6‑2SC6 | 2 | $0.30 |
| CC pull‑downs | 5.1 kΩ 0402 | 4 | $0.01 |

### 3.2 RP2350 Subsystem (unchanged)

| Function | Part | Qty | Unit Price |
|---|---|---|---|
| MCU | RP2350B (QFN‑80) | 1 | $1.60 |
| QSPI flash | W25Q128JVSIQ 16 MB | 1 | $1.20 |
| 12 MHz crystal | 3.2×2.5 mm SMD | 1 | $0.30 |
| BOOTSEL switch | Tactile, panel access | 1 | $0.15 |
| Decoupling | 100 nF + 10 µF per pin | ~15 | $0.20 |

### 3.3 **[NEW]** ESP32‑S3 UI & Networking Co‑Processor

| Function | Part | Package | Qty | Unit Price |
|---|---|---|---|---|
| ESP32‑S3 module (16 MB flash, 8 MB PSRAM) | Espressif **ESP32‑S3‑WROOM‑1U‑N16R8** (U.FL antenna connector) | Module | 1 | $4.50 |
| External antenna | U.FL‑compatible 2.4 GHz PCB antenna or whip | – | 1 | $1.00 |
| Decoupling & enable passives | 100 nF, 10 µF, 1 µF, pull‑ups | 0402/0603 | ~8 | $0.30 |
| Level translator (RP2350 ↔ ESP32‑S3 SPI) | TXB0104 or 2× TXS0104E (3.3 V both sides, but safe) | VSSOP‑14 | 1 | $1.00 |

The ESP32‑S3 runs its own firmware (based on ESP‑IDF + LVGL) and communicates with the RP2350 over a 4‑wire SPI bus (clock, MOSI, MISO, CS) plus a ready/interrupt line. The RP2350 acts as an SPI peripheral, providing a structured register map for telemetry readout and command execution.

### 3.4 **[REVISED]** Touchscreen Display

| Function | Part | Package | Qty | Unit Price |
|---|---|---|---|---|
| 5″ IPS TFT, 800×480, capacitive touch | **Elecrow RC050S** or equivalent (RGB interface w/ SPI touch) | FPC/ZIF | 1 | $25 |
| Display interface converter (RGB → something the ESP32‑S3 can drive) | The ESP32‑S3 has a built‑in RGB LCD interface, so it can drive the panel directly if pin‑mux permits; otherwise use an external SSD1963 controller. We choose a panel with an **on‑board controller** (e.g., ILI6480/ST7262) that accepts **SPI + RGB** or **MIPI DSI**. The ESP32‑S3’s LCD peripheral supports i80/RGB, so a suitable 40‑pin FPC is used. | – | – | – |

Detailed integration note: The 5″ panel mounts on the front of the enclosure. The ESP32‑S3 drives it with its built‑in LCD controller using 16‑bit parallel RGB interface (16 data lines + HSYNC/VSYNC/DE/CLK). The touch controller communicates over a separate SPI bus.

### 3.5 DUT Level Shifters & **[NEW]** Input Protection

| Function | Part | Package | Qty | Unit Price |
|---|---|---|---|---|
| Level shifter (8‑ch, bidir) | TI **LSF0108PWR** | TSSOP‑24 | 3 | $1.50 |
| Bank‑voltage DAC | MCP4726A0T‑E/CH | SOT‑23‑6 | 2 | $1.20 |
| Bank‑voltage LDOs | TLV62568DBVR | SOT‑23‑6 | 2 | $0.80 |
| Bank V/I monitors | INA260AIPWR | TSSOP‑16 | 2 | $4.50 |
| DUT‑side pull‑up resistors | 4.7 kΩ 0402 | 0402 | 24 | $0.01 |
| MCU‑side pull‑up resistors | 4.7 kΩ 0402 | 0402 | 24 | $0.01 |
| **DUT series protection resistors** | 100 Ω ±1 % 0402 (one per DUT pin) | 0402 | 24 | $0.02 |
| **DUT TVS arrays (4‑ch)** | Nexperia **PESD5V0S2UAT** (5 V working, 4‑ch) or similar, per 4 pins | SOT‑457 | 6 | $0.30 |
| **DUT P‑channel polyfuse (optional, for power pins)** | Bourns MF‑MSMF005 (0.05 A hold) for any pin that might carry supply current | 0805 | 0–4 | $0.20 |
| DUT FIXTURE connector | Samtec FFSH‑25‑01‑L‑D‑K | SMT | 1 | $3.00 |
| DUT BENCH connector | 2×5 0.1″ pin header | TH | 1 | $1.00 |
| ESD on DUT lines (after protection) | TPD4E004DRYR | SON‑6 | 6 | $0.40 |

Each DUT signal path is now: connector → series 100 Ω → TVS to ground → LSF0108 B‑side. This clamps any over‑voltage to about 5 V before it reaches the level shifter, protecting it from sustained faults and ESD. The series resistor limits current, and the TVS handles short transients. For pins that might accidentally be connected to a low‑impedance supply, a tiny polyfuse in series adds self‑resetting overcurrent protection.

### 3.6 Power Supply Channels (unchanged)

No changes to the core PSU topology.

### 3.7 **[REVISED]** DMM Subsystem with Galvanic Isolation & Cal EEPROM

| Function | Part | Package | Qty | Unit Price |
|---|---|---|---|---|
| ADC + ref + PGA | TI **ADS1115IDGSR** | VSSOP‑10 | 1 | $4.00 |
| Input buffer op‑amp | MCP6V51T‑E/OT | SOT‑23‑5 | 1 | $1.00 |
| Input mux (V vs R) | TS5A23159 | MSOP‑10 | 1 | $0.80 |
| Voltage divider (11:1) | 0.1 % thin‑film 1 MΩ + 100 kΩ | 0207 | 2 | $0.30 |
| HV series resistor | CRHV2512AF1004FKE 1 MΩ | 2512 | 1 | $0.80 |
| R‑mode ref resistors | PTF 1k/10k/100k 0.1 % | 0805 | 3 | $0.40 |
| R‑range select mux | TS3A5018PWR | TSSOP‑16 | 1 | $1.00 |
| PTC fuse (input protect) | MF‑R016 | radial | 1 | $0.30 |
| TVS | SMAJ33CA | SMA | 1 | $0.30 |
| Diode clamps | BAV199 | SOT‑23 | 2 | $0.10 |
| **Isolated DC‑DC converter** | Murata **NKE0505SC** (5 V→5 V, 1 W, 3 kV isolation) | SIP‑4 | 1 | $4.50 |
| **Isolated 3.3 V LDO** | ADP7118AUJZ‑3.3 (on isolated side) | TSOT‑5 | 1 | $1.50 |
| **I²C isolator** | TI **ISO1640BDR** (bidirectional I²C, 3 kV) | SOIC‑8 | 1 | $2.80 |
| **Calibration EEPROM** | Microchip **24AA025UID** (2 Kbit, I²C, EUI‑48 unique ID) | SOT‑23‑5 | 1 | $0.40 |
| Isolated‑side passives | Decoupling caps, filter | 0402 | ~5 | $0.20 |
| Analog supply LDO (non‑isolated side) | ADP7118AUJZ‑3.3 (for RP2350 reference, etc.) | TSOT‑5 | 1 | $1.50 |
| DMM banana jacks | Hirschmann SLB4‑G (finger guard) | panel | 2 | $1.20 |

The isolated DC‑DC converter creates an isolated 5 V rail, regulated down to a clean 3.3 V for the ADS1115, op‑amp, muxes, and cal EEPROM. The I²C isolator (ISO1640) cleanly bridges the RP2350’s housekeeping I²C bus to the isolated side, allowing the RP2350 to read the ADC and write DMM mode/range commands. The calibration EEPROM stores offset/gain coefficients per range and a unique serial number; the RP2350 reads them at boot and applies corrections in firmware.

### 3.8 **[NEW]** DC Barrel Jack Input

| Function | Part | Package | Qty | Unit Price |
|---|---|---|---|---|
| DC jack (5.5×2.1 mm, centre positive) | CUI **PJ‑002A** or similar, panel mount | TH | 1 | $0.60 |
| Ideal diode OR’ing controller (or discrete diode) | For the DMM supply, a simple Schottky diode OR is sufficient. For the PSU high‑power input, we use a dual‑channel ideal diode controller | | | |
| **Ideal diode controller (high‑power)** | TI **LM66100** (single, reverse‑current blocking) | SOT‑23‑6 | 2 | $0.80 |
| Input protection | TVS on DC jack (SMAJ24A), ferrite bead, 100 µF electrolytic | – | – | $0.50 |

The DC barrel jack accepts 9–24 V from any lab bench supply. The input is OR’d with the USB‑C POWER port’s VBUS via ideal diodes, so whichever source has the higher voltage supplies the PSU regulators. This gives the user the flexibility to run from a low‑noise linear bench supply when ripple performance is critical, while keeping USB‑C PD for portability.

### 3.9 **[NEW]** External Trigger BNC

| Function | Part | Package | Qty | Unit Price |
|---|---|---|---|---|
| BNC jack (panel mount) | Amphenol **31‑5329** or similar, 50 Ω | panel | 1 | $2.00 |
| ESD protection & termination | TVS (CDSOT23‑SM712), 50 Ω series terminator, 100 nF AC coupling option (DNP) | – | – | $0.50 |

Connected to a spare RP2350 GPIO via a 50 Ω series resistor and TVS clamp. The PIO can be configured as either a trigger input (capturing external events with precise timestamps) or a trigger output (signalling PSU fault, capture start, etc.). A jumper or software setting selects the function.

### 3.10 USB‑C Power Delivery & System Rails (minor revision)

The system now has three possible power sources for the PSU rails: USB‑C POWER port (PD negotiated 5–20 V), DC barrel jack (9–24 V), or (if only using the digital side) the USB‑C HOST port (5 V). Ideal diode OR’ing selects the highest voltage. The AP33772 remains for USB‑C PD negotiation.

### 3.11 User Interface (major revision)

| Function | Part | Package | Qty | Unit Price |
|---|---|---|---|---|
| **5″ touchscreen display** | (see §3.4) | – | 1 | $25 |
| **ESP32‑S3 module** | (see §3.3) | – | 1 | $4.50 |
| **Rotary encoder + push** | Bourns PEC11R‑4215F‑S0024 | 12 mm PCB | 1 | $1.80 |
| **Emergency stop / abort button** | Large red illuminated tactile, N.C. contacts, panel mount | panel | 1 | $5.00 |
| Piezo buzzer | TDK PS1240P02BT | SMD | 1 | $0.50 |
| Buzzer drive FET | 2N7002 | SOT‑23 | 1 | $0.05 |
| NeoPixel chain (5 LEDs) | WS2812B‑2020 | 2×2 mm | 5 | $0.20 ea |
| PSU “ON” LEDs | Green 0603 LED + resistor (driven from TPS55289 EN line) | 0603 | 2 | $0.05 |
| I/O expander | TCA9555PWR (still used for DMM control, bank enables, RTC INT) | TSSOP‑24 | 1 | $1.50 |
| RTC | DS3231SN | SOIC‑16 | 1 | $4.00 |
| Temperature sensors | TMP1075NDRLR | SOT‑563 | 3 | $0.55 |
| Debug/SWD header | Tag‑Connect TC2030‑IDC‑NL footprint | pads | 1 | $0 |

The **ESP32‑S3** is the primary user interface controller. It drives the 5″ touchscreen, runs the full GUI, and hosts the web server. The **rotary encoder** remains directly connected to the RP2350 for fine voltage/current adjustments when the touchscreen is not convenient (e.g., with gloves) and for menu navigation in a fallback mode. A large **emergency stop button** directly cuts the PSU enable lines via a hardware path (controlling the TPS55289 ENABLE pins) so that both PSU outputs can be instantly disabled even if the touchscreen freezes or software crashes. The RP2350 monitors this button to alert the UI.

The RP2350 still drives the **buzzer** for continuity beep (real‑time) and the **NeoPixel** chain for status indication, because these must remain responsive even if the ESP32‑S3 is busy.

### 3.12 Mechanical / Misc (minor updates)

Enclosure size will likely increase to accommodate the 5″ display and additional connectors. Approx. dimensions: 180 × 130 × 60 mm.

### 3.13 Approximate Cost (revised)

| Block | Subtotal |
|---|---|
| USB‑C host interface | $3 |
| RP2350 subsystem | $3.50 |
| ESP32‑S3 + display + antenna | $32 |
| DUT level shifters + protection | $24 |
| 2× PSU channels | $30 |
| DMM front‑end + isolation + cal EEPROM | $25 |
| DC barrel jack + OR’ing | $4 |
| Trigger BNC | $3 |
| USB‑C PD + system rails | $7 |
| UI (encoder, buzzer, LEDs, RTC, expander) | $18 |
| Mechanical + PCB + passives | $50 |
| **Device subtotal** | **~$200** |

Host computer remains bring‑your‑own; the ESP32‑S3’s built‑in Wi‑Fi largely eliminates the need for a dedicated Pi host for many workflows.

---

## 4. Power Architecture

Updated rail tree showing the DC barrel jack input:

```
USB‑C POWER port (5/9/15/20 V) ───┐
DC barrel jack (9–24 V) ─────────┤
                                  │
                     ideal diode OR (LM66100 ×2)
                                  │
                                  ├── TPS55289 #1 ──► VOUT_CH1 (0–18 V / 3 A)
                                  ├── TPS55289 #2 ──► VOUT_CH2 (0–18 V / 3 A)
                                  │
                                  └── TPS62933 ──► +5V_SYS
                                                     │
                                                     ├── TPS62933 ──► +3V3_SYS (RP2350, ESP32‑S3, digital)
                                                     ├── ADP7118 ──► +3V3_ANA (RP2350 analog ref)
                                                     │
USB‑C HOST port (5 V) ── ideal diode OR ── into +5V_SYS
```

When only the HOST port is plugged in (and no high‑voltage source is present), the PSU channels are unpowered but the digital side and DMM still operate.

---

## 5. I²C Address Maps

I²C bus #2 (housekeeping) now includes the isolated DMM and calibration EEPROM. The ISO1640 isolator makes the isolated side appear transparent on the bus, but the isolated devices are physically separated.

| Address | Device | Side |
|---|---|---|
| 0x22 | AP33772 PD sink | non‑isolated |
| 0x45 / 0x46 | INA260 (bank V/I) | non‑isolated |
| 0x48 / 0x49 / 0x4A | TMP1075 temp sensors | non‑isolated |
| 0x4B | ADS1115 DMM ADC | **isolated** |
| 0x50 | 24AA025UID calibration EEPROM | **isolated** |
| 0x60 / 0x61 | MCP4726 bank DACs | non‑isolated |
| 0x68 | DS3231SN RTC | non‑isolated |
| 0x20 | TCA9555 I/O expander | non‑isolated |

---

## 6. GPIO Budget

Revised allocation now that the touchscreen is handled by the ESP32‑S3. The RP2350’s SPI bus #1 is dedicated to ESP communication. OLED SPI pins are freed. A trigger BNC is added.

| Group | Function | Count | Type |
|---|---|---|---|
| DUT signals | 24 DUT pins (MCU side of level shifters) | 24 | PIO/GPIO |
| I²C bus #1 (PSU) | SDA, SCL | 2 | I²C peripheral |
| I²C bus #2 (housekeeping) | SDA, SCL (includes isolated DMM) | 2 | I²C peripheral |
| SPI to ESP32‑S3 | SCK, MOSI, MISO, CS, READY | 5 | SPI peripheral + GPIO |
| NeoPixel chain | 1 data line | 1 | PIO |
| Rotary encoder | A, B, push | 3 | GPIO (PIO quad) |
| Buzzer | PWM output | 1 | PWM |
| TPS55289 ENABLE | CH1, CH2 (drive EN + LED) | 2 | GPIO |
| Connector detect | Fixture‑present, bench‑present | 2 | GPIO |
| USB VBUS sense | HOST, POWER port VBUS (ADC) | 2 | ADC |
| Emergency stop sense | Input from abort button (also hard‑wired to EN lines) | 1 | GPIO |
| Trigger BNC | One GPIO (configurable PIO) | 1 | GPIO |
| **Total used** | | **46** | |
| **Spare** | | **2** | |

The TCA9555 I/O expander still handles DMM mode/range selects, bank VCCIO enables, and RTC interrupt. The ESP32‑S3 does not use any RP2350 GPIOs for the display; instead it drives the panel entirely on its own.

---

## 7. Host Interface (unchanged)

The USB‑C HOST port remains available and functions identically to v1.0. With the ESP32‑S3, a host computer is no longer required for networking; the device itself can serve a web dashboard.

---

## 8. User Interface & Software Architecture

The ESP32‑S3 runs a **full LVGL‑based GUI** on the 5″ touchscreen. Primary screens:

- **Home:** Large dual‑channel PSU readout (set/actual V, I), DMM value, output enable toggles, quick preset buttons.
- **Numeric keypad:** Tap any setpoint to enter a precise value.
- **Programs:** List stored test scripts, with play/pause/stop controls. Scripts are stored as JSON instruction sequences in the ESP32‑S3’s flash.
- **Settings:** Wi‑Fi, calibration, trigger configuration.

The **physical rotary encoder** remains active for fine adjustment; pushing it can cycle through fields or confirm a selection. The **emergency stop button** immediately cuts PSU power regardless of software state.

The ESP32‑S3 provides a **WebSocket API** identical to the one previously hosted on a Pi, so any script or application can control the instrument over Wi‑Fi.

---

## 9. Accuracy & Performance Targets (unchanged)

Added note: the galvanic isolation does not degrade DMM accuracy; the ISO1640 and ADS1115 combination easily meets the 0.3 % specification.

---

## 10. Mechanical

Front panel layout (conceptual):

```
┌──────────────────────────────────────────────┐
│  [ 5" TOUCHSCREEN ]                          │
│                                              │
│  ┌───────────────────────┐  ◐ Encoder       │
│  │ HOME  STATUS  FAULTS  │  [🛑 ABORT]     │
│  └───────────────────────┘                  │
│                                              │
│ ⊙PSU1+ ⊙PSU1−  ⊙DMM+ ⊙DMM−  ⊙PSU2+ ⊙PSU2− │
│   ●        ●      (iso)       ●     ●        │
└──────────────────────────────────────────────┘
```

Back panel adds the BNC jack, DC barrel jack, and retains the USB, fixture, and bench connectors.

---

## 11. Risks & Mitigations (updated)

| Risk | Mitigation |
|---|---|
| ESP32‑S3 crash freezes UI | Emergency stop button operates independently; RP2350 continues PSU control and DMM; UI watchdog reboots ESP if unresponsive. |
| Touchscreen glare in lab | Matte film applied to display. |
| Isolated DC‑DC radiated noise | Careful layout, ground plane splits, ferrite bead on input. |
| DUT protection resistor affects signal integrity | 100 Ω in series with ≤30 pF load still allows >50 MHz bandwidth; verify during layout. |

---

## 12. Summary

The v1.1 device remains a single instrument that replaces a bench supply, logic analyzer, and multimeter, but now with a **self‑contained professional touchscreen interface, Wi‑Fi connectivity, and fully isolated measurements**. The RP2350 still handles all real‑time critical tasks, while the ESP32‑S3 elevates the user experience to that of a modern piece of lab equipment. The added protection and flexible power input make it resilient in a busy office lab, and the external trigger BNC makes it a team player alongside scopes and signal generators.

Estimated device cost rises to approximately $200, still far below an equivalent collection of separate instruments. The host computer is now optional; networking, scripting, and data logging can all be handled by the device itself.