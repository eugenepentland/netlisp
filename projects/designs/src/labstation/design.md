# Bench Lab Multitool — Architecture & Bill of Materials

A bench-class lab tool combining a programmable dual-channel power supply,
multi-protocol logic analyzer / programmer, and 4½-digit digital multimeter.
Built as a **carrier board with a Raspberry Pi 5** plugged into the 40-pin
header for compute.

---

## 1. Design Goals

- **Form factor:** bench-friendly chassis sized to accept a Raspberry Pi 5
  on top, ~120 × 100 × 40 mm with the Pi installed.
- **Power:** USB-C Power Delivery input (5 V / 9 V / 15 V / 20 V).
  Wall-powered by default with a 65 W USB-C PD adapter; runs from a USB-C
  battery bank when portable use is wanted.
- **Compute:** Raspberry Pi 5 plugs into a standard 40-pin GPIO header on
  the carrier. Full Linux, SSH access, Python ecosystem (NumPy, SciPy,
  PyVISA), wired/wireless networking.
- **Connectivity:** Wi-Fi + Gigabit Ethernet built into the Pi 5; Pi 5's
  USB-A ports remain accessible for USB peripherals.
- **Power supplies:** two independent 0–18 V / 3 A programmable channels,
  source-only. **Hardware overcurrent protection with sub-millisecond
  response time, enforced by the FPGA regardless of Pi state — including
  during Pi boot or after a Pi crash.**
- **Logic interface:** 24 GPIO at native 1.8–3.3 V LVCMOS (no level
  shifters), split across two connectors for two distinct workflows:
  a **16-pin 1.27mm latching fixture connector** carrying signals +
  PSU rails + ground guards for single-cable test-fixture integration,
  and an **8-pin 0.1″ bench header** for ad-hoc debug with jumper
  wires and scope probes. The FPGA's 16-channel sampler is mux'd
  between the two connectors (one active at a time) — same capture
  bandwidth and BRAM budget as a 16-channel design.
- **Multimeter:** 4½-digit DC voltage and resistance measurement on
  separate probes, 0.05 % accuracy class, 0 Ω – 10 MΩ resistance, ±20 V
  (extendable to ±60 V) DC voltage.
- **Carrier-autonomous FPGA:** carrier-side SPI flash holds the FPGA
  bitstream so the FPGA boots and starts enforcing PSU safety in ~300 ms
  at power-on, independent of Pi boot state (~15–20 s for Linux).
- **Instrument-class UX:** rotary encoder for precise numeric entry,
  piezo buzzer for audible feedback, per-channel LEDs at the PSU output
  jacks, RGB status LED, user-programmable status LEDs, haptic vibration
  motor, and tap-to-wake via IMU.
- **Offline-accurate timekeeping:** dedicated DS3231M MEMS RTC with
  battery backup gives timestamped captures that stay accurate across
  power-cycles and disconnected operation.
- **Toolchain:** every piece of firmware/gateware buildable from open-
  source tools (no proprietary IDE required).

### 1.1 Control architecture

```
                  ┌──────────────────────────────────┐
                  │  Raspberry Pi 5 (8 GB)           │
                  └──────────────┬───────────────────┘
                                 │ 40-pin header
                                 │ (standard Pi pinout)
                  ┌──────────────┴───────────────────┐
                  │                                  │
                  │  CARRIER BOARD                   │
                  │  - FPGA (iCE40 HX8K)             │
                  │  - SPI flash for FPGA bitstream  │
                  │  - PSU subsystem (2× channels)   │
                  │  - DMM front-end                 │
                  │  - All UX peripherals            │
                  │  - USB-C PD input                │
                  │  - microSD slot                  │
                  │  - Banana jacks, DUT header      │
                  │                                  │
                  └──────────────────────────────────┘
```

**Functional split.** The FPGA owns everything time-critical (PSU control
loop, OCP safety, logic analyzer, protocol engines). The Pi 5 is on the
control plane — sending high-level commands and receiving telemetry over
Quad-SPI.

The FPGA bitstream itself lives on a carrier-side SPI flash, so the
FPGA boots autonomously at power-on. The Pi can re-flash this for
gateware updates but isn't responsible for loading the bitstream at
every boot. **The carrier's safety-critical functions are independent
of Pi state.**

---

## 2. System Architecture

### 2.1 Block diagram

```
        ╔══════════════════════════════╗
        ║  USB-C PD source             ║
        ║  (wall adapter / battery)    ║
        ╚════════════╤═════════════════╝
                     │ USB-C
              ┌──────┴──────┐
              │ USB-C recpt │
              └────┬────────┘
                   │ VBUS (CC negotiated)
            ┌──────▼────────┐
            │  STUSB4500    │
            │  PD Sink      │
            │  20 V / 3 A   │
            └──────┬────────┘
                   │ 20 V VBUS
                   │
                   │      ┌─────────────────────────────┐
                   │      │ 40-pin header → Raspberry   │
                   │      │ Pi 5 (Quad-SPI + I²C + GPIO)│
                   │      └──────────────┬──────────────┘
                   │                     │
                   │                     │ Quad-SPI @ 40 MHz
                   │                     ▼
                   │              ┌──────────────┐
                   │              │ iCE40 HX8K   │
                   │              │ Logic engine │◄────┐
                   │              │ + PSU ctrl   │     │ Bitstream
                   │              │ + protocols  │     │ at boot
                   │              └──┬───────┬───┘     │
                   │                 │       │         │
                   │                 │       │   ┌─────┴────────┐
                   │                 │       │   │ W25Q32 SPI   │
                   │                 │       │   │ flash (4 MB) │
                   │                 │       │   └──────────────┘
                   │                 │       │
                   │            ┌────┘       └────┐
                   │            │ I²C_FPGA       │ DUT
                   │            │ 400 kHz        │ pins
                   │            ▼                ▼
                   │      ┌────────────┐  ┌─────────────────────┐
                   │      │  PSU       │  │ Connector mux       │
                   │      │  subsystem │  │ (in FPGA gateware)  │
                   │      │  (TPS55289 │  │ Selects active DUT  │
                   │      │  + INA228) │  │ connector           │
                   │      └─────┬──────┘  └──┬──────────────┬───┘
                   │            │            │              │
                   │ 20 V VBUS ─┘            ▼              ▼
                   │                  ┌─────────────┐  ┌──────────────┐
                   │                  │ 16-pin DUT  │  │ 8-pin DUT    │
                   │                  │ FIXTURE     │  │ BENCH header │
                   │                  │ (1.27mm     │  │ (0.1″ 2×?,   │
                   │                  │  latching   │  │  jumper      │
                   │                  │  + PSU      │  │  friendly)   │
                   │                  │  + GND      │  │ Bank A/B at  │
                   │                  │  guards)    │  │ 1.8/2.5/3.3V │
                   │                  │ Bank A/B at │  └──────────────┘
                   │                  │ 1.8/2.5/3.3V│
                   │                  └─────────────┘
                   │
                ┌──┴──────────────────────────────────────┐
                │ Power tree:                              │
                │  - TPS62933: 20→5 V buck (3 A)          │
                │  - TPS62933: 5→3.3 V buck (digital)     │
                │  - ADP7118:  3.3 V analog LDO (low noise)│
                │  - 5 V to Pi 5 via 40-pin header pins 2/4│
                └──────────────────────────────────────────┘

                     ┌──────────────────────────────────┐
                     │  AD7124-4 DMM Front-End          │
                     │  (ADR4525 + ADG5412F + RG divider)│
                     │  driven by Pi 5 over SPI1        │
                     └────────────────┬─────────────────┘
                                      │
                            ┌─────────▼───────┐
                            │ DMM probes      │
                            │ (separate jacks)│
                            └─────────────────┘
```

### 2.2 Functional split

| Function | Owner | Notes |
|---|---|---|
| **DUT connector selection (mux)** | **FPGA, Pi-controlled** | 1-bit register selects whether the 16-wide sampler & protocol engines see the fixture (1.27mm) or bench (0.1″) connector |
| **Logic analyzer real-time sampling** | **FPGA** | 16 ch @ 25 MS/s sustained, 96 MS/s burst — true real-time. Sampled pins are the active connector's pins (16 from fixture or 8 from bench + 8 zero-padded). |
| **PSU real-time control loop** | **FPGA (1 kHz)** | Hardware OCP <1 ms response, survives Pi crashes/reboots |
| **PSU + VBUS telemetry sampling** | **FPGA via dedicated I²C master** | Reads INA228s at 1 kHz, buffers latest values |
| **Protocol engines** (SPI/I²C/JTAG/SWD/UART) | **FPGA gateware** | Bit-level timing in FPGA, frames over Quad-SPI to Pi |
| **PSU setpoint commands** | **Pi → FPGA over Quad-SPI** | High-level "set V/I limit" commands |
| **Capture streaming** | **FPGA → Pi over Quad-SPI** | 40 MHz quad-SPI ≈ 20 MB/s with in-fabric compression |
| **DMM ADC reads** | **Pi → AD7124-4 via SPI1** | Low rate (≤2 kSPS) |
| **Bank V/I monitoring (INA260)** | **Pi over I²C1** | 10 Hz polling sufficient |
| **Bank-voltage setpoint (MCP4726/TLV62568)** | **Pi over I²C1** | Slow control |
| **USB-C PD negotiation** | **STUSB4500 (autonomous)** | No host firmware required |
| **FPGA bitstream load** | **Carrier-side SPI flash (autonomous)** | FPGA self-boots at power-on; Pi can re-flash |
| **Gateware update (re-flash bitstream)** | **Pi 5 via standard iceprog protocol** | FPGA held in reset; Pi drives flash directly |
| **Web UI / SSH / scripting** | **Pi 5** | Full Linux stack |
| **Networking (Wi-Fi, Ethernet)** | **Pi 5** | Both built-in |
| **USB peripheral support** | **Pi 5 native USB-A ports** | Full Linux USB stack |

---

## 3. Bill of Materials — Top Level

### 3.1 Carrier — Compute Interface

| Function | Part | Package | Qty | Unit Price | Notes |
|---|---|---|---|---|---|
| 40-pin GPIO header (to Pi 5) | Samtec **SSW-120-01-T-D** or equivalent | through-hole, 0.1" | 1 | $2.50 | Standard Pi-compatible 2×20 pinout |
| USB-C connector (power input) | GCT **USB4105-GF-A** mid-mount | SMD + through-hole | 1 | $0.75 | Power input; no data lines used |
| USB ESD (VBUS / CC) | ST **USBLC6-2SC6** | SOT-23-6 | 1 | $0.30 | Standard USB-C ESD protection |

### 3.2 Carrier — FPGA Subsystem

| Function | Part | Package | Qty | Unit Price | Notes |
|---|---|---|---|---|---|
| FPGA | Lattice **ICE40HX8K-CT256** | caBGA-256, 0.8 mm | 1 | $20 | 7,680 LUT4, 4 independent VCCIO banks. Configured at every power-on from on-carrier SPI flash. |
| FPGA config flash | Winbond **W25Q32JVSSIQ** | SOIC-8 | 1 | $0.80 | 4 MB SPI flash. Holds primary bitstream (~135 KB) plus recovery bitstream and ~3 MB free space. Re-flashable from Pi. |
| Bank-voltage DAC | Microchip **MCP4726A0T-E/CH** | SOT-23-6 | 2 | $1.20 | Single-channel 12-bit I²C DAC, one per bank |
| Bank-voltage LDOs | TI **TLV62568DBVR** | SOT-23-6 | 2 | $0.80 | Adjustable 1.8–3.3 V buck for each DUT bank |
| Bank V/I monitors | TI **INA260AIPWR** | TSSOP-16 | 2 | $4.50 | One per DUT bank — V, I, power. Integrated 2 mΩ shunt |
| I²C_FPGA pullups | 2.2 kΩ 0402 | 0402 | 2 | $0.02 | SDA/SCL pull-ups for FPGA-mastered PSU bus |
| DUT FIXTURE connector | Samtec **FFSH-25-01-L-D-K** or similar 2×25 1.27mm latching | 1.27 mm SMT shrouded + latch | 1 | $3.00 | **Primary fixture interface.** Sample pinout: 16 DUT signals + 16 dedicated GNDs (one per signal for clean LA captures) + 4 PSU CH1 pins (2 V+, 2 return) + 4 PSU CH2 pins + 4 GND guards around PSU rails + 2 bank V refs + 4 aux/sync lines. Pre-made cables (Samtec FFSD assemblies) stocked at Digi-Key/Mouser in 6"/12"/18"/24" lengths. Latching shroud prevents accidental disconnects mid-test. |
| DUT BENCH connector | 2×5 0.1″ pin header w/ keying | through-hole | 1 | $1.00 | **Ad-hoc bench debug interface.** 8 DUT signals + interleaved GNDs + 2 bank V refs. Jumper-wire friendly, scope-probe friendly. No PSU rails on this connector — banana jacks remain the bench PSU interface. |
| ESD on DUT lines | TI **TPD4E004DRYR** | SON-6 | 6 | $0.40 | 4-channel ESD per pack — covers all 24 DUT pins (16 fixture + 8 bench) |

> **FPGA self-boot from carrier SPI flash.** The W25Q32 on the carrier
> means the FPGA configures itself at every power-on independent of the
> Pi. Boot sequence: power applied → 5 V rail stable → FPGA CRESET_B
> released → FPGA reads bitstream from W25Q32 over SPI (~270 ms at
> 25 MHz single-bit) → CDONE high → FPGA in user mode. Total: ~300 ms
> from power-on. **No Pi intervention required.**
>
> **Flash sharing for OTA updates.** The W25Q32 sits on the FPGA's
> SPI_SS_B / SCK / SDI / SDO config pins. During normal operation the
> FPGA ignores these pins (it's already configured). For a bitstream
> update, the Pi asserts CRESET_B to hold the FPGA in reset (which
> tristates the FPGA's SPI pins), then drives the same SPI lines as a
> master to read/write the W25Q32 using standard `flashrom` or `iceprog`
> protocol. Releasing CRESET_B reconfigures the FPGA from the new
> bitstream. ~1 second total for a gateware update.
>
> **Estimated LUT utilization (HX8K = 7,680 LUTs):**
> - Logic analyzer (sampler + trigger + compressor + streamer): ~1,200
> - Protocol engines (SPI/I²C/JTAG/SWD/UART masters): ~1,500
> - PSU controller (I²C master + PI loop + safety + telemetry): ~1,200
> - Pin monitor + io_pad_ctrl (24 pins): ~480
> - User LED driver (4 channels, PWM): ~50
> - Connector mux (selects fixture vs. bench pins into sampler): ~100
> - SPI slave (Quad-SPI to Pi) + command router + glue: ~500
> - **Total: ~5,030 LUTs (65 % utilization), comfortable margin.**
>
> **DUT-side organization: 2 programmable-voltage banks feeding two connectors.**
> The iCE40 HX8K-CT256 has 4 independently-VCCIO-programmable banks; this
> design uses **2** for the DUT side, each settable 1.8 / 2.5 / 3.3 V via
> its own MCP4726 DAC + TLV62568 LDO. Each bank carries **12 FPGA pins**:
> - **8 pins → 1.27mm fixture connector** (16 total across both banks)
> - **4 pins → 0.1″ bench connector** (8 total across both banks)
>
> The remaining 2 FPGA banks are at fixed 3.3 V for signaling toward the
> Pi and the PSU subsystem.
>
> **Two connectors, one sampler.** The FPGA has 24 distinct DUT pins
> wired to the banks (no fan-out — each FPGA pin lands on exactly one
> connector position). The 16-channel sampler, trigger logic, and
> protocol engines see an abstract `DUT[0..15]` bus that the
> `connector_mux` module routes from either the 16 fixture pins or the
> 8 bench pins (with 8 channels zero-padded). The Pi sets the mux via a
> 1-bit register; switching is glitchless and instantaneous. Use cases:
> - **Fixture mode:** `connector_mux = fixture`. Plug a custom-PCB
>   fixture cable into the 1.27mm header; 16 channels available with
>   PSU rails included on the same cable.
> - **Bench mode:** `connector_mux = bench`. Hook up jumper wires to
>   the 0.1″ header for ad-hoc bring-up; 8 channels available, PSU
>   outputs accessed via banana jacks as usual.
>
> Both connectors can be physically populated at once — only the
> active connector's pins are sampled/driven. The pin_monitor still
> reads back all 24 pins so the Pi can detect unexpected activity on
> the inactive connector.
>
> **Two layers of pin diagnostics** are built in:
> 1. **Digital readback** (free, in-gateware): every output's actual pin
>    state is sampled and compared to the commanded state — instantly
>    flags shorts, contention, or missing connections. Covers all 24
>    physical DUT pins, not just the 16 active.
> 2. **Per-bank V/I monitoring** (via 2× INA260): the Pi sees the actual
>    voltage on each DUT bank rail and the current the target is sinking
>    or sourcing. Unusual current on a supposedly-idle connector flags
>    that something is plugged in and powered there.

### 3.3 Power Supply Channels

| Function | Part | Package | Qty | Unit Price | Notes |
|---|---|---|---|---|---|
| Buck-boost regulator | TI **TPS55289WRYQR** | VQFN-22, 3.5×4.5 mm | 2 | $4.00 | 0.8–22 V output, 8 A, I²C-programmable, 0x74 / 0x75 |
| Power inductor | Würth **74438336047** 4.7 µH 5 A | 7×7×4 mm | 2 | $2.50 | Match to TPS55289 EVM design |
| Output shunt | Vishay **WSL2512R0100FEA** 10 mΩ 1 % | 2512 | 2 | $1.20 | Kelvin connection to INA228 |
| V/I telemetry | TI **INA228AIDGSR** | VSSOP-10 | 3 | $3.00 | Ch.1 + Ch.2 + VBUS (PD monitor) |
| Output disconnect FET | Diodes **DMP3056L-7** | SOT-23-3 | 2 | $0.50 | True 0 V off state, reverse-pol protect |
| Output filter caps | 22 µF / 35 V X7R | 1210 | 4 | $0.30 | 2 per channel output |
| Banana jacks | Hirschmann **SLB4-G** | panel | 4 | $1.20 | Pairs: red + black per channel |

### 3.4 DMM Subsystem

| Function | Part | Package | Qty | Unit Price | Notes |
|---|---|---|---|---|---|
| ADC + ref + PGA + mux + Iexc | Analog Devices **AD7124-4BCPZ** | LFCSP-24 | 1 | $7.50 | 24-bit, 4-ch, integrated current sources — 4 channels exactly cover DMM voltage + resistance |
| External reference | Analog Devices **ADR4525BRZ** | SOIC-8 | 1 | $4.00 | 2.5 V, 2 ppm/°C, ±0.02 % |
| Input buffer op-amp | TI **OPA189IDBVR** (or LTC2057) | SOT-23-5 | 1 | $3.50 | Zero-drift, 0.4 µV/°C |
| Fault-protected mux | Analog Devices **ADG5412FBRUZ** | TSSOP-16 | 1 | $5.00 | ±55 V continuous, range switch |
| Range mux for R_ref | Analog Devices **ADG1404BRMZ** | MSOP-10 | 1 | $2.50 | 4:1 switch for resistance ranges |
| Matched divider | Susumu **RG3216N-104-W-T5** | matched array | 1 | $1.50 | 0.05 %, 2 ppm/°C ratio |
| HV series resistor | Vishay **CRHV2512AF1004FKE** 10 MΩ | 2512, 1 kV | 1 | $0.80 | Primary input protection |
| Ratiometric R_ref | Vishay **PTF series** 100 Ω / 1 k / 10 k / 100 k / 1 M | 0805 | 5 | $0.60 | 0.05 %, 10 ppm/°C |
| PTC fuse | Bourns **MF-R016** | radial | 1 | $0.30 | Self-resetting input protect |
| TVS | **SMAJ33CA** | SMA | 1 | $0.30 | Bidirectional clamp |
| Diode clamps | **BAV199** | SOT-23 | 2 | $0.10 | Low-leakage post-divider clamp |
| Cal EEPROM | Microchip **24LC256-I/SN** | SOIC-8 | 1 | $0.40 | Stores per-unit cal constants |
| Analog supply LDO | Analog Devices **ADP7118AUJZ-3.3** | TSOT-5 | 1 | $1.50 | Ultra-low-noise 3.3 V for ADC |
| DMM banana jacks | Hirschmann **SLB4-G** (finger guard) | panel | 2 | $1.20 | Red + black, separate from PSU |

### 3.5 USB-C Power Delivery & System Rails

The carrier has **one USB-C receptacle** used for power input only. Data
to/from the Pi 5 happens over Wi-Fi, Ethernet, or via the Pi 5's own
USB-A ports.

| Function | Part | Package | Qty | Unit Price | Notes |
|---|---|---|---|---|---|
| USB-C PD sink | ST **STUSB4500QTR** | QFN-24 | 1 | $1.50 | NVM-programmed 20 V / 3 A primary, 15/9/5 V fallback |
| 5 V system buck | TI **TPS62933DRLR** | SOT-563 | 1 | $0.80 | 20 V → 5 V, 3 A. Powers Pi 5 + carrier digital. |
| 3.3 V digital buck | TI **TPS62933DRLR** | SOT-563 | 1 | $0.80 | 5 V → 3.3 V, separate from analog rail |
| Analog 3.3 V LDO | Analog Devices **ADP7118AUJZ-3.3** | TSOT-5 | 1 | $1.50 | Ultra-low-noise rail for AD7124-4 and DMM AFE |
| Master power supervisor | TI **TPS3808G33DBVR** | SOT-23-5 | 1 | $0.80 | Holds Pi 5 power off until rails stable |
| Bulk decoupling at 40-pin power | Polymer cap 470 µF / 10 V | SMD | 1 | $1.20 | Critical for Pi 5 transient response — handles Pi PMIC dips |

### 3.6 Carrier — User Interface & Sensors

The features in this section are individually small additions, but
collectively they're what separates "engineering project that works"
from "instrument that feels good to use." Total cost adder: ~$9.

These all live on the carrier and are accessed by the Pi via I²C1 or via
the FPGA.

| Function | Part | Package | Qty | Unit Price | Notes |
|---|---|---|---|---|---|
| Rotary encoder + click | Bourns **PEC11R-4215F-S0024** | 12 mm panel mount | 1 | $1.80 | 24 detents, quadrature output, push-button. Primary numeric-entry device for PSU voltage/current setpoints. **Decoded by FPGA** via dedicated GPIO + sampler — works during Pi boot and across Pi crashes. |
| Piezo buzzer | TDK **PS1240P02BT** | SMD 12.2 mm | 1 | $0.50 | Driven from FPGA PWM via small N-FET. Audible feedback for OCP trips, capture trigger fired, script completion. |
| Buzzer drive FET | Diodes **2N7002** | SOT-23 | 1 | $0.05 | Low-side switch for piezo |
| RGB status LED | Worldsemi **WS2812B-2020** | SMD 2×2 mm | 1 | $0.20 | Single-wire addressable. Driven by FPGA — works during Pi boot and shows system state (booting/idle/active/fault). |
| Per-channel PSU "ON" LEDs | Generic green LED + resistor | 0603 | 2 | $0.05 | One green LED next to each PSU output jack pair, **driven directly by FPGA** from the same internal signal that gates TPS55289 ENABLE. Instant on/off, accurate. |
| User-programmable status LEDs | Generic LEDs (mixed colors) + resistors | 0603 | 4 | $0.05 | Four LEDs (e.g., red/green/yellow/blue) on the front face, driven by FPGA outputs. Exposed to Pi scripts as FPGA registers writable over Quad-SPI. Useful for glanceable test progress / pass-fail indication from across the bench. |
| Vibration motor (LRA) | Jinlong **G1040003D** | 10 × 4 mm | 1 | $0.90 | Linear resonant actuator. Driven by DRV2603. Haptic feedback on encoder clicks, alerts. |
| LRA driver | TI **DRV2603RUNT** | UQFN-10 | 1 | $1.20 | Gives proper braking, overdrive, and crisp haptic feel. |
| RTC + battery backup | Maxim **DS3231M** (MEMS oscillator) | SOIC-8 | 1 | $2.00 | I²C, ±5 ppm temperature-compensated. Connected to I²C1 at 0x68. CR1220 holds it across full power-off. |
| Internal temperature sensors | TI **TMP1075NDRLR** | SOT-563 | 3 | $0.55 | Digital I²C, ±0.5 °C. Placed near TPS55289 #1, TPS55289 #2, FPGA. Used by FPGA's safety_monitor for thermal throttling. |
| IMU (6-axis) | ST **LSM6DSO** | LGA-14 | 1 | $1.50 | I²C, 3-axis accel + 3-axis gyro. Useful for drop-detection logging and bench-orientation features. |
| NFC dynamic tag | ST **ST25DV04K-IER6T3** | TSSOP-8 | 1 | $0.80 | I²C-accessible NFC EEPROM. Phone-tap for Wi-Fi credentials, serial number, fleet management. Energy-harvesting passive — readable when device unpowered. |
| Debug / SWD header | Tag-Connect **TC2030-IDC-NL** footprint | — | 1 | $0.00 (just pads) | 6-pin footprint exposing FPGA SPI, UART, 3.3 V, GND. Used during bring-up. |
| Reed switch (case-open detect) | Standex-Meder **MK24** | SMD axial | 1 | $0.40 | Enclosure tamper detection. Drives an FPGA GPIO. |
| Buzzer + LED passives | Various R/C | 0402/0603 | ~10 | $0.10 | Series resistors for LEDs, snubber for buzzer, etc. |

> **Why these are FPGA-driven, not Pi-driven.** The buzzer, LEDs, and
> encoder live on the FPGA for three reasons: (1) they work during Pi
> boot (15–20 s window before Linux services come up), (2) they work
> across Pi crashes or reboots, (3) the FPGA can give true instant
> response (OCP trip → immediate buzzer beep in <1 ms, regardless of
> what the Pi is doing). Costs a few FPGA pins; the iCE40 has plenty
> of free pins on the housekeeping bank, so cost is zero.

### 3.7 Mechanical / Misc

| Function | Part | Qty | Unit Price | Notes |
|---|---|---|---|---|
| Carrier PCB | 4-layer FR-4, 1 oz outer / 1 oz inner, ENIG, ~85 × 95 mm | 1 | ~$10 | Sized to match Pi 5 footprint with mounting holes in standard Pi positions |
| Enclosure | Custom or modified Hammond 1455 series | 1 | $20–30 | Cutouts for HDMI/USB on Pi 5 side, banana jacks on carrier side panel |
| Standoffs for Pi 5 | M2.5, 11 mm | 4 | $0.40 | Mounts Pi 5 to carrier |
| RTC backup | CR1220 coin cell + Keystone 1058 holder | 1 | $0.80 | Preserves DS3231M clock across power-off |
| DUT bench cable (16-pin ribbon w/ probe leads) | 0.1″ IDC ribbon → grabber clips | 1 | $10 | Bundled accessory for the 0.1″ bench header |
| DUT fixture cable (sample) | Samtec **FFSD-25-D-12.00-01-N** (12" cable, 2×25, latching) | 1 | $15 | Pre-made fixture cable; one end mates with the carrier's 1.27mm latching connector. Sold as a standard catalog item — users can spec the same part number in their custom fixture BOMs. |
| Passives (resistors, caps, ferrites, inductors) | various 0402/0603/0805 | ~70 | ~$0.04 | Aggregate ~$3 |

### 3.8 Pi 5 module

| Function | Part | Qty | Unit Price | Notes |
|---|---|---|---|---|
| SBC | Raspberry Pi 5 8GB | 1 | $80 | Drops onto the 40-pin header with 4× M2.5 standoffs |
| Optional NVMe HAT | Pineboards HatDrive! Bottom or similar | 1 | $15 | Fits under Pi 5 between Pi and carrier |
| Optional NVMe SSD | M.2 2230 / 2242, 256GB | 1 | $30 | Boot drive, much more reliable than SD card |
| Optional active cooler | Raspberry Pi Active Cooler | 1 | $5 | Required for sustained high CPU; useful if enclosure is tight |

### 3.9 Total approximate cost

**Carrier board:**

| Block | Subtotal |
|---|---|
| Compute interface (40-pin header, USB-C, ESD) | $3.50 |
| FPGA subsystem (including config flash and both DUT connectors) | $42 |
| 2 × power supply channels | $30 |
| DMM front end | $33 |
| USB-C PD + system rails | $6 |
| UI, sensors, RTC, debug header (§3.6) | $9 |
| Mechanical + PCB + passives | $40 |
| **Carrier subtotal** | **≈ $164** |

**Total cost:**

| Config | Compute parts | Total |
|---|---|---|
| Pi 5 8GB, SD only | $80 | **$244** |
| Pi 5 8GB + NVMe HAT + 256GB SSD | $125 | **$289** |
| Pi 5 8GB + NVMe HAT + 256GB SSD + active cooler | $130 | **$294** |

The carrier cost is dominated by the FPGA, the analog hardware, and the
DMM front-end. The Pi 5 + NVMe upgrade is +$45 over SD-only and worth
it for reliability.

---

## 4. Power Architecture

### 4.1 Rail tree

```
USB-C VBUS (5/9/15/20 V, ≤3 A, negotiated by STUSB4500)
│ always on (≤50 µA quiescent via STUSB4500)
│
├── TPS55289 #1 ──► VOUT_CH1 (0–18 V / 3 A)  ──► P-FET ──► Banana jacks
├── TPS55289 #2 ──► VOUT_CH2 (0–18 V / 3 A)  ──► P-FET ──► Banana jacks
│
└── TPS62933 ──► +5V_SYS (3 A continuous, 5 A peak)
                  │
                  ├──► 40-pin header pins 2 + 4 (parallel)
                  │    to Pi 5
                  │    + 470 µF bulk decoupling for Pi PMIC transients
                  │
                  └── TPS62933 ──► +3V3_SYS (digital)
                                    │
                                    ├── FPGA VCC (1.2 V via separate LDO)
                                    ├── FPGA VCCIO_DUT_A (TLV62568 #1)
                                    ├── FPGA VCCIO_DUT_B (TLV62568 #2)
                                    ├── FPGA VCCIO_CONTROL (3.3 V → +3V3_SYS)
                                    ├── W25Q32 config flash
                                    └── Housekeeping I²C peripherals
                  │
                  └── ADP7118 ──► +3V3_ANA (low noise)
                                    └── AD7124-4, ADR4525, OPA189, ADG5412F

CR1220 coin cell (~3 V) ──► DS3231M VBAT
                            (preserves time across power-off)
```

The carrier delivers 5 V to the Pi 5 via the 40-pin header pins 2 and 4
(paralleled). Modern Pi 5 firmware needs `usb_max_current_enable=1` in
`/boot/firmware/config.txt` to unlock full peripheral power on this path,
since there's no PD negotiation on the header. The Pi 5's own USB-C port
is left unconnected.

In **off** state, only the STUSB4500 (~50 µA) and DS3231M backup (from
CR1220) remain — VBUS itself is gated by the user unplugging the USB-C
cable, which is the simplest possible "off."

### 4.2 Power budget

| State | Estimate | Notes |
|---|---|---|
| Active: Pi 5 + carrier + 2 PSU channels @ 12 V × 1 A | ~28 W | Pi ~5 W + PSUs ~24 W |
| Pi 5 idle, FPGA idle, PSUs off | ~3 W | Pi 5 dominates idle |
| Pi 5 idle + active SSH session | ~3.5 W | |
| Pi 5 booting | ~6 W (peak) | First ~5 s |
| Pi 5 + heavy LA capture | ~6.5 W | All BRAMs and clocks active |

### 4.3 Power source recommendations

| Use case | Recommended source | Notes |
|---|---|---|
| Bench-permanent (default) | **65 W USB-C PD wall adapter** | Always-on, no power management complexity |
| Occasional portable use | 20,000 mAh USB-C PD battery bank | ~6 hours of active use; recharge between uses |

Daily-bench use should run from wall power. Battery operation is fine
for moving the device between locations, but isn't the design center.

---

## 5. 40-pin Header Pin Allocation

The carrier exposes a standard Raspberry Pi 2×20 header with the pinout
designed to make Pi 5 peripherals work natively.

### 5.1 Reference pinout (BCM GPIO numbering)

| Header Pin | BCM GPIO | Carrier Function | Notes |
|---|---|---|---|
| 1 | — | 3.3 V (low current reference) | |
| 2 | — | **5 V power from carrier** | Primary Pi power input |
| 3 | GPIO 2 | I²C1 SDA — housekeeping bus | Routes to all I²C1 devices in §6.1 |
| 4 | — | **5 V power from carrier** | Parallel with pin 2 |
| 5 | GPIO 3 | I²C1 SCL — housekeeping bus | |
| 6 | — | GND | |
| 7 | GPIO 4 | Power button input | Wake source / soft-power |
| 8 | GPIO 14 | UART0 TX (debug console) | |
| 9 | — | GND | |
| 10 | GPIO 15 | UART0 RX (debug console) | |
| 11 | GPIO 17 | FPGA `CRESET_B` | Pi can reset FPGA / take flash ownership |
| 12 | GPIO 18 | FPGA `CDONE` | Read FPGA config-done state |
| 13 | GPIO 27 | FPGA `INT` | FPGA fault / capture-ready notification |
| 14 | — | GND | |
| 15 | GPIO 22 | Reserved | Spare |
| 16 | GPIO 23 | Reserved | Spare |
| 17 | — | 3.3 V | |
| 18 | GPIO 24 | Reserved | Spare |
| 19 | GPIO 10 | **SPI0 MOSI / IO0** (Quad-SPI to FPGA) | Bit 0 of Quad-SPI |
| 20 | — | GND | |
| 21 | GPIO 9 | **SPI0 MISO / IO1** (Quad-SPI to FPGA) | Bit 1 of Quad-SPI |
| 22 | GPIO 25 | Reserved | Spare |
| 23 | GPIO 11 | **SPI0 SCLK** (Quad-SPI to FPGA) | |
| 24 | GPIO 8 | **SPI0 CE0** (FPGA chip select) | |
| 25 | — | GND | |
| 26 | GPIO 7 | **SPI1 CE0** (DMM ADC chip select) | AD7124-4 |
| 27 | GPIO 0 | I²C0 SDA (HAT EEPROM) | **Reserved for Pi HAT detection** — do not repurpose |
| 28 | GPIO 1 | I²C0 SCL (HAT EEPROM) | **Reserved** |
| 29 | GPIO 5 | DMM `nDRDY` IRQ | AD7124-4 data ready |
| 30 | — | GND | |
| 31 | GPIO 6 | Reserved | Spare |
| 32 | GPIO 12 | **SPI0 IO2** (Quad-SPI bit 2) | |
| 33 | GPIO 13 | **SPI0 IO3** (Quad-SPI bit 3) | |
| 34 | — | GND | |
| 35 | GPIO 19 | **SPI1 MISO** | |
| 36 | GPIO 16 | Reserved | Spare |
| 37 | GPIO 26 | Reserved | Spare |
| 38 | GPIO 20 | **SPI1 MOSI** | |
| 39 | — | GND | |
| 40 | GPIO 21 | **SPI1 SCLK** | |

### 5.2 Pi 5 GPIO functional mapping

Standard libgpiod / gpiozero / pinctrl tools work directly:

- **`/dev/spidev0.0`** at SCLK/MOSI/MISO/CE0 → FPGA Quad-SPI (single-bit
  mode initially; Pi 5's SPI peripheral supports Quad mode via SPI0
  multi-IO when configured)
- **`/dev/spidev1.0`** at SCLK1/MOSI1/MISO1/CE1 → AD7124-4 DMM
- **`/dev/i2c-1`** at I²C1 → housekeeping bus (DS3231M, IMU, NFC, temps,
  EEPROM, INA260, MCP4726, STUSB4500)
- **GPIO inputs** for FPGA CDONE, INT, DMM nDRDY, power button
- **GPIO outputs** for FPGA CRESET_B

The Pi 5's RP1 PIO is available (4 state machines, 28 GPIOs) for small
auxiliary tasks. Not used for primary FPGA communication (PCIe latency
makes it suboptimal for that).

### 5.3 FPGA capture bandwidth

The FPGA streams capture data over **Quad-SPI at 40 MHz**, delivering
~20 MB/s sustained — enough for 16-channel logic capture at 25 MS/s with
light compression. With the iCE40 HX8K's 128 kbit BRAM as a ring buffer:

- **16 channels at 25 MS/s** sustained streaming
- **16 channels at 96 MS/s** burst captures (BRAM-buffered, ~80 µs)
- All typical embedded-debug protocols with substantial headroom

The Pi 5's SPI0 in Quad mode at 40 MHz matches the FPGA, and the Pi has
ample RAM and SSD for storing captures.

---

## 6. I²C Address Maps (two independent buses)

The two-bus split (one Pi-mastered for housekeeping, one FPGA-mastered
for PSU real-time control) keeps the time-critical PSU loop independent
of Pi scheduling.

### 6.1 I²C1 — Pi-mastered (housekeeping)

Routes to header pins 3 (SDA) / 5 (SCL) → BCM GPIO 2/3 on Pi 5.

| Address | Device | Purpose |
|---|---|---|
| 0x28 | STUSB4500 | USB-C PD sink — read negotiated PDO |
| 0x45 | INA260 #1 | FPGA Bank A V/I telemetry |
| 0x46 | INA260 #2 | FPGA Bank B V/I telemetry |
| 0x48 | TMP1075 #1 | Temperature near TPS55289 #1 |
| 0x49 | TMP1075 #2 | Temperature near TPS55289 #2 |
| 0x4A | TMP1075 #3 | Temperature near FPGA |
| 0x50 | 24LC256 | Cal EEPROM (DMM constants, serial number) |
| 0x53 | ST25DV04K | NFC dynamic tag (user data area) |
| 0x57 | ST25DV04K | NFC dynamic tag (system area) |
| 0x60 | MCP4726 #1 | DAC for Bank A voltage setpoint |
| 0x61 | MCP4726 #2 | DAC for Bank B voltage setpoint |
| 0x68 | DS3231M | Real-time clock with battery backup |
| 0x6A | LSM6DSO | IMU (accelerometer + gyroscope) |

The bus is populated but not problematically — 13 devices at 400 kHz.
Worst-case telemetry refresh (INA260 × 2 + TMP1075 × 3 + IMU + RTC) is
~3 ms, well within any reasonable housekeeping loop budget.

### 6.2 I²C_FPGA — FPGA-mastered (PSU real-time control)

| Address | Device | Purpose |
|---|---|---|
| 0x40 | INA228 #1 | PSU Ch.1 V/I telemetry (1 kHz sample rate) |
| 0x41 | INA228 #2 | PSU Ch.2 V/I telemetry (1 kHz sample rate) |
| 0x44 | INA228 #3 | USB-C VBUS monitor (10 Hz, drives PD-droop detection) |
| 0x74 | TPS55289 #1 | PSU Ch.1 buck-boost setpoint |
| 0x75 | TPS55289 #2 | PSU Ch.2 buck-boost setpoint |

Both buses run at **400 kHz fast-mode** with 2.2 kΩ pull-ups.

---

## 7. Software Architecture

Standard Linux software stack on the Pi 5:

```
┌──────────────────────────────────────────────────────────┐
│  Raspberry Pi 5 (Pi OS Lite 64-bit, headless)            │
│  ┌────────────────────────────────────────────────────┐  │
│  │  User Python scripts (NumPy, SciPy, pandas, etc.) │  │
│  └─────────────────────┬──────────────────────────────┘  │
│  ┌─────────────────────┴──────────────────────────────┐  │
│  │  labstation-py library (apt or pip install)        │  │
│  │   - PSU / DMM / LA APIs                            │  │
│  └─────────────────────┬──────────────────────────────┘  │
│  ┌─────────────────────┴──────────────────────────────┐  │
│  │  HTTP/WebSocket server (FastAPI, port 80)          │  │
│  │  SCPI-over-TCP (port 5025)                         │  │
│  │  SSH for development (port 22)                     │  │
│  │  Optional: Chromium kiosk for HDMI display         │  │
│  └─────────────────────┬──────────────────────────────┘  │
│  ┌─────────────────────┴──────────────────────────────┐  │
│  │  Linux kernel: /dev/spidev0.0 (FPGA Quad-SPI),    │  │
│  │   /dev/spidev1.0 (DMM), /dev/i2c-1, GPIO via      │  │
│  │   libgpiod, NVMe/SD filesystem, networking         │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### 7.1 Software setup workflow

1. Flash Pi OS Lite 64-bit to SD card or NVMe SSD via Raspberry Pi
   Imager. Pre-configure Wi-Fi credentials, SSH key, hostname via
   imager's customization options.
2. First boot: Pi auto-expands filesystem, joins Wi-Fi, advertises as
   `labstation-<serial>.local`.
3. SSH in, run `curl -fsSL https://github.com/.../install.sh | sudo bash`
   which: installs `labstation-py`, sets up systemd services for the
   HTTP and SCPI servers, configures `usb_max_current_enable=1`, enables
   SPI/I²C in `/boot/firmware/config.txt`.
4. Optionally clone the SD card to make multiple identical units
   (`dd | pishrink` workflow).

### 7.2 Python API

```python
from labstation import psu, dmm, logic, dut

# Select which DUT connector is active. Defaults to 'bench' on boot.
dut.select('fixture')   # or 'bench'

# Configure DUT bank voltages (applies regardless of which connector
# is active — both connectors share the same bank rails).
dut.bank_a.set_voltage(3.3)
dut.bank_b.set_voltage(1.8)

# Now DUT[0..15] refers to the active connector's pins.
# In 'fixture' mode: 16 pins available (8 from Bank A + 8 from Bank B)
# In 'bench' mode: 8 pins available (4 from Bank A + 4 from Bank B)

psu.set(channel=1, voltage=3.3, current_limit=0.5, enabled=True)
v = dmm.read_voltage()
capture = logic.capture(channels=[0,1,2,3], rate=25_000_000, duration_ms=10)
```

### 7.3 SCPI-over-TCP

The device exposes a SCPI server on port 5025, immediately compatible
with PyVISA:

```
*IDN?              → "Labstation,v1.0,SN-001"
SOUR1:VOLT 3.3     → set Ch.1 to 3.3 V
SOUR1:CURR 0.5     → set current limit
OUTP1 ON           → enable channel 1
MEAS1:VOLT?        → return measured voltage
MEAS:VOLT? DMM     → return DMM reading
DUT:CONN FIXTURE   → route DUT pins to the 1.27mm fixture connector
DUT:CONN BENCH     → route DUT pins to the 0.1″ bench header
DUT:CONN?          → return active connector
```

### 7.4 Script storage and execution

Scripts run on the Pi (full Python ecosystem), uploaded via SSH/SCP/git,
scheduled via cron, exposed via HTTP API. Linux filesystem semantics —
anything you can do with Python on a laptop, you can do on the device.

### 7.5 Boot time

| Event | Time after power-on |
|---|---|
| FPGA ready (configured from carrier flash) | ~300 ms |
| PSU subsystem including hardware OCP active | ~300 ms |
| Linux boot complete, SCPI/HTTP servers up | 15–20 s |

The FPGA is ready in ~300 ms and PSU safety is enforced from then on.
The API/SCPI servers don't bind until Linux finishes booting, but the
hardware is safe immediately.

---

## 8. FPGA Architecture (iCE40 HX8K)

### 8.1 Toolchain

- **Synthesis:** Yosys
- **Place & route:** nextpnr-ice40
- **Bitstream:** Project IceStorm (`icepack`)
- **HDL:** Amaranth HDL (Python) — first-class platform support
- **Build runner:** Standard `Makefile` or Amaranth `Build` API
- **No vendor IDE required**

### 8.2 Bank assignment

| Bank | VCCIO source | Pins | Purpose |
|---|---|---|---|
| **Bank A (DUT)** | TLV62568 #1 (MCP4726 #1) | 12 | 8 → 1.27mm fixture connector, 4 → 0.1″ bench connector. Voltage-programmable 1.8/2.5/3.3 V. |
| **Bank B (DUT)** | TLV62568 #2 (MCP4726 #2) | 12 | 8 → 1.27mm fixture connector, 4 → 0.1″ bench connector. Voltage-programmable 1.8/2.5/3.3 V. |
| **Bank C (Control)** | 3.3 V fixed | — | Quad-SPI to Pi, FPGA control/status pins |
| **Bank D (PSU + housekeeping)** | 3.3 V fixed | — | I²C_FPGA master, UX peripherals (encoder, buzzer, LEDs, reed switch) |

### 8.3 Gateware modules

```
top.v / top.py
├── pll                  (12 MHz → 96 MHz fabric clock)
├── spi_slave            (Quad-SPI from Pi @ 40 MHz)
├── command_router       (decode opcodes from Pi)
├── psu_controller       (real-time PSU control)
│   ├── i2c_master       (400 kHz, dedicated I²C_FPGA bus)
│   ├── ina228_reader    (1 kHz polling of Ch.1, Ch.2, VBUS)
│   ├── tps55289_writer  (commands buck-boost setpoint per channel)
│   ├── current_limit    (per-channel PI loop, OCP shutdown <50 µs)
│   ├── safety_monitor   (VBUS droop, overtemp, output short detection)
│   └── telemetry_buffer (latest V/I/state values, Pi reads via SPI)
├── logic_analyzer
│   ├── sampler          (16-channel @ up to 96 MS/s into BRAM ring)
│   ├── trigger          (programmable pattern + edge)
│   ├── compressor       (RLE / delta encoding for sustained streaming)
│   └── streamer         (push captured data to Pi)
├── connector_mux        (1-bit Pi-controlled register selects whether
│                         sampler/protocol_engines see fixture or bench
│                         pins; ~100 LUTs)
├── protocol_engines     (DUT-side interfaces — operate on the muxed
│                         active connector's pins)
│   ├── spi_master       (configurable mode/speed for DUT SPI)
│   ├── i2c_master       (100 k / 400 k / 1 M for DUT)
│   ├── jtag_master      (TCK up to 10 MHz)
│   ├── swd_master       (ARM SWD for Cortex-M)
│   └── uart             (50 baud – 4 Mbaud, configurable)
├── pin_monitor          (digital readback + mismatch detection; covers
│                         all 24 physical DUT pins regardless of mux state)
├── ux_peripherals       (carrier-side UI driven by FPGA:
│   ├── encoder_decoder    rotary encoder via quadrature counter)
│   ├── buzzer_pwm
│   ├── ws2812_driver      (RGB status LED, single-wire timing)
│   ├── psu_status_leds    (per-channel "ON" LEDs, mirror real PSU enable state)
│   └── user_leds          (4 front-panel LEDs, Pi-writable register;
│                          hardware PWM for pulse/breathe patterns)
└── io_pad_ctrl          (per-pin direction, pull, output enable)
```

### 8.4 Pin diagnostics — two layers

Both digital readback (free, in-gateware comparison of commanded vs.
actual pin state) and per-bank V/I monitoring (via 2× INA260) work
continuously and stream to the Pi on request.

### 8.5 PSU real-time control loop

The FPGA's `psu_controller` module polls INA228s at 1 kHz, runs the PI
loop, writes TPS55289 setpoints, enforces OCP/OVP in <50 µs, and
survives Pi crashes/reboots independently.

**Critical property: the PSU control loop works during Pi boot and
across Pi crashes.** The FPGA gets its bitstream from the carrier-side
W25Q32 at every power-on, and the control loop starts running before
Linux finishes booting. The Pi just adds setpoint commands once it's
up.

A 5-second host heartbeat watchdog applies: if the Pi doesn't send any
command within 5 seconds, the FPGA holds outputs in their last state.
This protects against Pi crashes during PSU operation.

### 8.6 Configuration source: carrier-side SPI flash

The iCE40 boots from the carrier's W25Q32 SPI flash. **The Pi is not
required for FPGA configuration.**

Boot sequence:

```
1. USB-C power applied
2. STUSB4500 negotiates 20 V PD profile
3. TPS62933 produces 5 V system rail (~10 ms)
4. TPS62933 #2 produces 3.3 V digital (~5 ms)
5. FPGA POR releases, CRESET_B asserts
6. FPGA reads bitstream from W25Q32 over single-bit SPI at 25 MHz
   (~270 ms for ~135 KB compressed bitstream)
7. CDONE high → FPGA in user mode
8. FPGA's psu_controller begins polling INA228s
9. PSU enable signals stay LOW (TPS55289 ENABLE pulled down) until
   explicit command from Pi
10. FPGA listens on Quad-SPI for incoming commands from Pi
```

**Total: ~300 ms from power-on to "FPGA ready, awaiting commands."**

**Bitstream updates from Pi.** The W25Q32 sits on the same SPI lines
used for FPGA configuration. To update the bitstream:

```
Pi 5 asserts GPIO 17 (CRESET_B) low:
  - FPGA enters reset, tristates its SPI config pins
  - Pi now drives those same SPI lines and talks directly to W25Q32
  - Standard flashrom / iceprog protocol works
  - Pi writes new bitstream to W25Q32

Pi releases CRESET_B:
  - FPGA reconfigures from new bitstream (~300 ms)
  - System back online with new gateware
```

~1 second total for a gateware update.

> **Power-on PSU safety.** TPS55289 ENABLE pins are pulled down by
> default. The FPGA explicitly asserts ENABLE only after its control
> loop is running and the Pi has issued an explicit "enable channel"
> command. During the ~300 ms FPGA configuration window, ENABLE is
> guaranteed low (FPGA outputs are high-impedance when unconfigured),
> so PSU outputs are off.
>
> **Recovery bitstream.** The W25Q32 has 4 MB of space. Primary
> bitstream takes 135 KB; a known-good "recovery" bitstream occupies a
> separate region. The Pi can re-flash the primary region with an
> experimental bitstream; if the new bitstream misbehaves, the Pi can
> re-flash the primary back from the recovery.

---

## 9. Accuracy & Performance Targets

| Subsystem | Target | Limiting factor |
|---|---|---|
| **PSU voltage setpoint** | ±50 mV + 0.5 % of setpoint | TPS55289 DAC + INA228 cal |
| **PSU current limit accuracy** | ±5 % | 10 mΩ shunt tolerance |
| **PSU OCP response time** | <1 ms from threshold to foldback | FPGA 1 kHz control loop |
| **PSU load regulation** | <100 mV @ 0–3 A step | TPS55289 closed loop |
| **PSU ripple** | <50 mV pk-pk @ 1 A | Output cap selection |
| **PSU command latency (Pi → output)** | <2 ms | Quad-SPI write + FPGA tick + I²C write |
| **PSU telemetry refresh** | 1 kHz internal, 10 Hz to Pi | FPGA-buffered, polled by Pi |
| **DMM DCV (20 V range)** | 0.05 % + 2 counts | ADR4525 drift + divider TCR |
| **DMM DCV (±60 V range)** | 0.05 % + 3 counts | HV divider |
| **DMM resistance (1 kΩ – 1 MΩ)** | 0.05 % + 2 counts | Ratiometric |
| **DMM resistance (10 MΩ)** | ~0.5 % | Leakage / bias currents |
| **Logic analyzer** | 16 ch @ 25 MS/s sustained, 96 MS/s burst | BRAM size for burst depth |
| **Protocol bridges** | SPI ≤25 MHz, I²C ≤1 MHz, JTAG ≤10 MHz, UART ≤4 Mbaud | Standard FPGA limits |

---

## 10. Mechanical

The carrier is sized to match the Raspberry Pi 5 footprint with the
standard Pi 5 mounting hole pattern, so a Pi 5 sits directly on the
carrier with 11 mm M2.5 standoffs.

### 10.1 Dimensions

- **Carrier PCB:** ~85 × 95 mm, 4-layer (Pi 5 mounts cleanly on top)
- **Pi 5 mounting hole pattern:** 58 × 49 mm at corner positions
  (standard Pi 4 / Pi 5 hole spacing)
- **40-pin header:** at standard Pi position relative to mounting holes
- **External enclosure:** ~120 × 100 × 50 mm with Pi 5 installed,
  Hammond 1455-series or custom
- **Banana jacks:** 4 × ⌀4 mm panel jacks (2 PSU outputs, 2 DMM probes,
  finger-guarded), mounted on carrier's edge connector to the enclosure's side panel
- **DUT fixture connector:** Samtec 1.27mm 2×25 latching shroud on the back panel
- **DUT bench header:** 2×5 0.1″ pin header adjacent to the fixture connector on the back panel, keyed

### 10.2 Thermal

Worst-case dissipation:

- TPS55289 #1 (3 A out): ~1.5 W
- TPS55289 #2 (3 A out): ~1.5 W
- FPGA (full LA capture): ~0.2 W
- Pi 5 idle: ~3 W
- Pi 5 CPU loaded: ~6–8 W
- **Total: ~11 W worst case (Pi 5 fully loaded, both PSUs at 3 A out)**

Mitigations:

- 2 oz copper pours on internal layers under the switching regulators
- Thermal vias under TPS55289 thermal pads
- Pi 5 with active cooler recommended for sustained CPU load
- Ventilation slots in enclosure top (over the Pi 5)
- 3 × TMP1075 temperature sensors enable FPGA-side thermal monitoring
  and automatic PSU foldback if any region exceeds 70 °C

### 10.3 Display

The Pi 5 has an HDMI port. Connect to any bench monitor (or a small
~7" HDMI display mounted in the enclosure for a more integrated look).
Pi 5's DSI port can also drive a DSI display mounted in the enclosure's
top.

For headless deployment (SSH + Wi-Fi only), no display is needed at
all — the carrier itself has no display-related hardware.

### 10.4 Connectors & enclosure layout

```
Enclosure top view (looking down at Pi 5):

          ┌─────────── USB-C (power input) ────────────┐
                                                    │
        ┌─┴──────────────────────────────────────────┐
        │  ╔════════════════════════════════════╗    │
        │  ║                                    ║    │
        │  ║      Raspberry Pi 5                ║    │
        │  ║                                    ║    │  ← top
        │  ║  visible HDMI/USB ports on edge    ║    │
        │  ║                                    ║    │
        │  ╚════════════════════════════════════╝    │
        │      4× M2.5 standoffs to carrier below    │
        │                                            │
        │      40-pin header connects up to Pi 5     │
        └────────────────────────────────────────────┘

Front panel:

        ┌──────────────────────────────────────────┐
        │ [RGB] ●  ◐ Encoder  ● ● ● ●  user LEDs   │
        │                                          │
        │ ⊙PSU1+ ⊙PSU1−  ⊙DMM+ ⊙DMM−  ⊙PSU2+ ⊙PSU2−│
        │   ●        ●                    ●     ● │  ← per-channel ON LEDs
        │                                          │
        │ [microSD slot]    [POWER button]         │
        └──────────────────────────────────────────┘

Back panel:

        ┌──────────────────────────────────────────┐
        │  ╔════════════════════════════════════╗  │
        │  ║ 1.27mm 2×25 FIXTURE connector       ║  │
        │  ║ (latching, accepts pre-made Samtec  ║  │
        │  ║  FFSD cable for custom fixtures)    ║  │
        │  ╚════════════════════════════════════╝  │
        │                                          │
        │  ●●●●● 0.1″ BENCH header (2×5) ●●●●●     │
        │  (jumper wires, scope probes,            │
        │   ad-hoc debug)                          │
        │                                          │
        │ Pi 5 HDMI / USB-A access cutouts         │
        │                                          │
        │ [Tag-Connect debug footprint]            │
        │ (accessible with back panel removed)     │
        │                                          │
        │ ┌─NFC zone─┐                             │
        │ │    📶    │  ← tap phone here           │
        │ └──────────┘                             │
        │                                          │
        │ Serial: SN-NNNNNN  Cal: YYYY-MM-DD       │
        └──────────────────────────────────────────┘
```

The two DUT connectors are placed adjacent on the back panel and
share the same FPGA bank breakout area on the PCB. This keeps trace
lengths short and routing clean. Only one connector is active at a
time (selected by the `connector_mux` software setting); the other
can be left empty or have a fixture plugged in but idle.

Carrier-side panel elements:
- **Rotary encoder + click**: primary numeric-entry device, FPGA-decoded
- **RGB status LED**: top-left, system state at a glance, FPGA-driven
- **4 user-programmable LEDs**: front face, FPGA-driven, exposed to Pi
  scripts as FPGA registers
- **PSU "ON" LEDs**: small green LEDs adjacent to each PSU jack pair,
  FPGA-driven from the same signal that gates TPS55289 ENABLE
- **POWER button**: passes through to Pi 5's power input
- **Banana jacks** (front): PSU1 pair, DMM pair (center), PSU2 pair
- **1.27mm fixture connector** (back): primary interface for custom
  test fixtures. Latching shroud, carries 16 signals + PSU rails + GND
  guards on a single cable.
- **0.1″ bench header** (back): 8 signals for jumper-wire/scope-probe
  work. PSU outputs are reached via banana jacks in this mode.
- **microSD slot**: removable storage; not used as boot media
- **Piezo buzzer**: behind a small grille, FPGA PWM
- **Vibration motor, reed switch, IMU, RTC, NFC, temps**: internal,
  no panel features (NFC zone marked on back)

---

## 11. Development Workflow

```bash
# SSH into the Pi 5
ssh pi@labstation-<serial>.local

# Edit scripts directly, or use sshfs / vscode-remote / git
$ vim /home/pi/labstation-scripts/my_test.py
$ python3 my_test.py

# Or develop locally with full IDE and push via git
$ git push      # on laptop
$ ssh pi@... 'cd ~/labstation && git pull && systemctl restart labstation'
```

The Pi 5 gives the best development UX possible: full Linux, SSH,
package managers, debuggers, profilers, Jupyter notebooks running on
the device, etc.

### 11.1 Tooling stack

| Layer | Tooling |
|---|---|
| **labstation-py** | Python 3 library; pytest for unit tests |
| **FPGA gateware** | Amaranth HDL (Python) → Yosys + nextpnr-ice40 + icepack |
| **FPGA bitstream upload** | `iceprog` via Pi's SPI lines with FPGA in reset |
| **Pi 5 software deployment** | Debian package (`apt install labstation`) + systemd; or pip + venv |
| **CI** | GitHub Actions: lint Python, run pytest, build gateware bitstream, verify it loads |

### 11.2 Repo layout

```
labstation/
├── hardware/
│   ├── carrier-pcb/          KiCad project
│   ├── enclosure/            STEP + STL files
│   └── bom/                  CSV BOM, Mouser/Digi-Key cart links
├── gateware/
│   ├── top.py                Amaranth top-level
│   ├── modules/              LA, protocol engines, PSU controller
│   ├── tests/                Amaranth simulation tests
│   └── Makefile              yosys → nextpnr → icepack
├── labstation-py/            Host library (runs on Pi)
│   ├── labstation/
│   │   ├── __init__.py
│   │   ├── psu.py
│   │   ├── dmm.py
│   │   ├── logic.py
│   │   ├── programmer.py
│   │   └── scpi.py
│   ├── tests/
│   └── setup.py
├── examples/                 Example scripts
└── docs/
    ├── architecture.md       (this file)
    ├── api.md
    ├── scripting.md
    └── calibration.md
```

### 11.3 First-time hardware bring-up workflow

1. Assemble carrier PCB
2. Power via USB-C from a PD-capable supply (laptop USB-C or PD wall
   adapter)
3. Connect to a Pi 5 via the 40-pin header
4. Boot Pi 5 with pre-imaged SD/NVMe
5. SSH in: `ssh pi@labstation-<serial>.local`
6. Load development bitstream: `iceprog build/top.bin`
7. From Python: `from labstation import diag; diag.self_test()`
8. Iterate gateware: edit Amaranth → `make` → `iceprog` → test

Once gateware is solid, write the carrier flash with production
bitstream: `iceprog build/top.bin`. Subsequent power-cycles boot the
FPGA from this flash autonomously.

---

## 12. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| TPS55289 thermal in compact enclosure | Low | Medium | Thermal vias + copper pour; software current cap. ~3 W max for PSU section, well within reason. |
| EMI from buck-boost coupling into Pi 5 Wi-Fi radio | Medium | Medium | Spread-spectrum mode on TPS55289; ground stitching; keep Pi's antenna area away from PSU section. Use Ethernet if Wi-Fi is problematic. |
| iCE40 HX8K-CT256 BGA assembly difficulty | Medium | Low | 4-layer board with 0.8 mm pitch is routine; HX1K-VQ100 is a TQFP fallback |
| **Pi 5 power transients pulling down 5 V rail** | Medium | Medium | 470 µF polymer cap at header power input; TPS62933 has ample margin. Verify with scope during bring-up. |
| **Pi 5 USB peripheral current limit (default 600 mA)** | Medium | Low | `usb_max_current_enable=1` in `/boot/firmware/config.txt`; this is a documented Pi 5 setting. |
| **Pi 5 SD card corruption from unclean power-off** | Medium | High | Use NVMe SSD (via PCIe HAT) instead of SD for boot. Industrial SD if SD must be used. |
| **Carrier W25Q32 wear from frequent gateware updates** | Low | Low | W25Q32 rated for 100,000 erase cycles; even daily updates would take 274 years to wear out. |
| iCE40 fabric utilization with PSU controller | Medium | Medium | Estimated ~63 % LUT use; comfortable margin. If tight, drop one protocol engine or move to ECP5 LFE5U-25F |
| PSU control loop bug locks output | Low | High | Watchdog timer in gateware forces safe-state; W25Q32 holds a known-good "recovery" bitstream the Pi can revert to |
| 4½-digit DMM accuracy over temperature | Low | Medium | Per-unit cal at manufacture; ADR4525 + matched divider; 3× TMP1075 for thermal compensation |
| **Pi 5 boot time slow (15-20 s)** vs. instant FPGA | None | None | The FPGA is up in <300 ms and PSUs are safe immediately. Only the network/SSH interface waits for Linux boot. Acceptable for a bench tool. |
| **Pi 5 availability / supply chain** | Low | Medium | Pi 5 is in steady production. CM5 module is a fallback for a more compact respin if needed. |

---

## 13. Roadmap

### v1.0 — Carrier board (this document)
- Carrier with FPGA, PSUs, DMM, carrier-side bitstream flash, all UX
  peripherals, 40-pin Pi-compatible header
- Pi 5 software validated (labstation-py on Linux + SCPI server)

### v1.1 — Software refinements
- HTTP/WebSocket dashboard
- SCPI compatibility audit with bench scripting tools (PyVISA)
- Built-in JTAG/SWD programmer for popular MCUs
- Scheduled scripts via cron
- Multi-device coordination (one labstation orchestrates others over
  network)

### v2.0 — Possible upgrades (carrier PCB respin)
- **ECP5 (LFE5U-25F)** instead of iCE40 — 3× fabric, hard DSP, deeper
  BRAM for capture; same DUT-side topology
- **Per-pin analog readback** — ADG706 16:1 mux + spare AD7124 channel
  (requires AD7124-8). Enables precise per-pin voltage measurement
- **External AD-class signal-conditioning add-on** for a future high-
  speed ADC (spectrum analyzer add-on, ≤10 MHz BW)
- **AC voltage / true-RMS DMM mode** — no hardware change, software
  using AD7124-4 sampled fast
- **Higher-current PSU channels** — up to 5 A by upgrading TPS55289 to
  a more capable buck-boost
- **CM5-style integration** — eliminate the standoffs/header and put a
  CM5 directly on the carrier (much more complex but yields a more
  compact device)

---

## 14. Open Questions to Resolve Before PCB Layout

1. **Pi 5 power feedback path:** when the Pi 5's own USB-C is unused,
   should pin 2/4 of the header definitely drive bidirectional? Verify
   that powering Pi via header doesn't backfeed into a stowed USB-C
   port through any internal path. (Likely fine — Pi 5 architecture
   gates this — but confirm with Pi 5 schematic before committing.)

2. **SPI signal integrity at 40 MHz Quad-SPI** between Pi 5 and FPGA
   on the 40-pin header. Trace length matching, series termination,
   ground stitching all matter. Validate with scope during bring-up;
   fall back to 25 MHz if needed.

3. **Pi 5 USB peripheral routing:** the Pi 5's USB-A ports are
   physically on the Pi 5 board itself. Either leave cutouts in the
   enclosure for them, or accept that USB peripherals require the
   back of the case to be accessible.

4. **HDMI on Pi 5:** include a cutout for Pi 5's micro-HDMI ports in
   the enclosure (so a bench monitor can be connected), or not? For
   a "headless" deployment, HDMI access is unnecessary. For
   development, it's useful.

5. **NVMe HAT routing:** the Pi 5's PCIe connector is on the Pi 5
   bottom. An NVMe HAT typically sits between Pi 5 and the carrier
   in a sandwich. This requires longer standoffs (~25 mm instead of
   11 mm) and may affect enclosure height. Validate with mechanical
   mockup.

6. **Encoder mounting:** Panel-mount or PCB-mounted with knob through
   panel? PCB-mounted is easier for the carrier-only assembly.

7. **LRA driver: DRV2603 or simple FET?** $1.20 extra for proper
   haptic feel vs. a $0.05 FET. For a bench tool that's mostly
   stationary, haptic feedback matters less than for a handheld.
   Could DNP the DRV2603 and use a FET for v1.

8. **NFC antenna keep-out:** ST25DV needs ~10 × 10 mm of copper
   keep-out and a clear path through the enclosure (works through
   plastic, not metal). If the enclosure is metal, NFC must be
   omitted or relocated to a plastic cutout.

9. **Reed switch + magnet placement:** Magnet glued to one case half,
   reed switch on PCB near the seam. Verify with enclosure mockup.

10. **User LED count and color:** 4 LEDs is a reasonable default.
    Consider mixed colors (red/green/yellow/blue) vs. uniform white.

11. **Carrier dimensions vs. Pi 5 footprint:** the carrier could be
    exactly Pi 5-sized (85 × 56 mm) or larger. Larger gives more PCB
    area for the analog hardware and banana jacks. Verify enclosure
    is sized for the larger option.

12. **Pi 5 boot trigger:** Pi 5 sometimes needs the power button
    pulsed when powered via header. Wire a GPIO from FPGA to Pi's
    PWR button line so the FPGA can pulse it after a clean power-on?

13. **Fixture connector pin count and exact pinout:** the spec calls
    for a 2×25 (50-pin) 1.27mm latching connector with 16 signals +
    16 GNDs + 4 PSU CH1 pins + 4 PSU CH2 pins + 4 GND guards + 2 bank
    Vrefs + 4 aux lines. Finalize the exact pin assignment during
    layout — specifically (a) which signals get which positions to
    minimize trace crossings from the FPGA bank breakout, (b) whether
    to expose any FPGA-controlled aux signals (trigger out, fixture
    detect, indicator LED control), and (c) whether to dedicate a pin
    or two to fixture-side power (e.g. a 3.3 V or 5 V rail for fixture
    glue logic).

14. **Series resistors on DUT signal pins:** optional 33–47 Ω series
    resistors at the FPGA-side of each DUT signal would damp
    reflections on long fixture cables (important for the LA at higher
    sample rates) and limit fault current. Cost: ~$0.30 for 24 of
    them. Worth the BOM line; could be DNP'd in v1.

15. **Fixture cable length spec:** Samtec FFSD ribbon cables come in
    6"/12"/18"/24" stock lengths. The 12" is a reasonable default for
    bundled accessory. Longer cables degrade LA signal integrity at
    25 MS/s — note this in the docs.

16. **Connector mode detection vs. explicit user select:** could the
    FPGA auto-detect which connector has a fixture plugged in (via a
    "fixture-present" pin shorted to GND on the fixture side)? Cheap
    to add, helps prevent user error. Alternative: keep it strictly
    software-selected and have the Pi remember the last setting.

---

## 15. Summary

### What lives on the carrier:

- iCE40 HX8K FPGA + carrier-side W25Q32 SPI flash for autonomous boot
- All analog: 2× TPS55289 PSU channels with INA228 telemetry, AD7124-4
  DMM
- USB-C PD input (STUSB4500) — power only
- All UX peripherals (encoder, buzzer, RGB LED, per-channel LEDs, 4
  user LEDs, vibration motor, RTC, IMU, NFC, temps, reed switch)
- microSD slot, banana jacks
- **Two DUT connectors, mux'd in the FPGA:** a 1.27mm latching fixture
  connector (16 signals + PSU rails + GND guards, single-cable
  integration for custom test fixtures) and a 0.1″ bench header
  (8 signals, jumper-wire-friendly bring-up)
- 40-pin GPIO header in standard Pi position

### What lives on the Pi 5:

- Linux (Pi OS Lite 64-bit, headless)
- `labstation-py` Python library
- HTTP/WebSocket API server (FastAPI on port 80)
- SCPI-over-TCP server (port 5025)
- SSH for development
- Wi-Fi + Gigabit Ethernet networking
- USB-A ports for peripherals
- Optional NVMe SSD for reliable storage

### What this design buys you:

- **Working device in weeks** — Pi 5 mode with full Python ecosystem
  is the minimum-viable-path.
- **Real Linux for development** — SSH in, `apt install` whatever you
  need, debug naturally.
- **Carrier-side autonomous FPGA boot** — even during the 15–20 s Pi
  boot window or after a Pi crash, the analog hardware is functional
  and safe.
- **Single-cable fixture integration** — design custom test fixtures
  for your PCBs that mate with one Samtec FFSD cable (specced once,
  reusable across every project).
- **Cost:** $244 with SD-only Pi 5; $289 with NVMe HAT + 256 GB SSD.

The total commitment is one carrier board design plus a stock Pi 5.