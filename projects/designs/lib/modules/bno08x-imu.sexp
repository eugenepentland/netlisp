;; BNO08x 9-axis IMU with on-chip sensor fusion (Hillcrest SH-2 over SHTP).
;; Configured for SPI mode with internal RC oscillator. Caller wires one
;; SPI master + INT + NRST + 3.3V supply.

(import bno08x)

(defmodule bno08x-imu ()
  "BNO08x 9-axis IMU module — SPI mode, internal-RC clock, normal boot.
   Exposes abstract SPI master + INT + NRST ports; the chip's strap pins
   (PS1/PS0/BOOTN/CLKSEL0) and unused interfaces (I2C, UART, reserved)
   are configured/tied internally so the host MCU only sees a clean SPI
   peripheral."

  (design-block "BNO08x IMU"

    (instance "imu" bno08x
      (pin 2 25 "GND")
      (pin 3 28 "VDD")
      (pin 4 "VDD")
      (pin 5 "VDD")
      (pin 6 "WAKE")
      (pin 9 "IMU_CAP")
      (pin 10 "VDD")
      (pin 11 "NRST")
      (pin 14 "INT")
      (pin 15 "ENV_SCL")
      (pin 16 "ENV_SDA")
      (pin 17 "MOSI")
      (pin 18 "CS")
      (pin 19 "SCK")
      (pin 20 "MISO")
      (pin 26 "GND"))
    (decouple "VDD" (cap-0201 "100nF") 1 per-pin imu)
    (series (cap-0201 "100nF" x7r) "IMU_CAP" "GND")
    (series "R_NRST" (res-0201 "10k") "NRST" "VDD")
    (series "R_WAKE" (res-0201 "10k") "WAKE" "VDD")
    (series "R_ENV_SCL" (res-0201 "10k") "ENV_SCL" "VDD")
    (series "R_ENV_SDA" (res-0201 "10k") "ENV_SDA" "VDD")

    (port "VDD"  in (rated 3.0 3.6))
    (port "GND"  bidi)
    (port "SCK"  in)
    (port "MOSI" in)
    (port "MISO" out)
    (port "CS"   in)
    (port "INT"  out)
    (port "NRST" in)
    (port "WAKE" in)

    (note "imu" "BNO08x SPI mode: PS1=1 (tied to VDD), PS0/WAKE=1 at reset via R_WAKE pull-up (selects SPI), BOOTN=1 (normal boot)")
    (note "imu" "PS0/WAKE (pin 6) is the host wake line: pulled to VDD so the SPI strap reads 1 during the MCU's own reset window, then driven low by the host GPIO to wake the IMU from sleep before a SPI transaction")
    (note "imu" "Clock select: CLKSEL0=1 (VDD) selects the internal oscillator; XOUT32/CLKSEL1=GND, XIN32 NC — no external 32 kHz clock on this board")
    (note "imu" "ENV_SCL/ENV_SDA (15/16) pulled up 10k to VDD — the boot ROM probes this bus at reset regardless of whether an environmental sensor is populated. RESV_NC (1,7,8,12,13,21-24,27) left unconnected")
    (note "imu" "Uses SH-2 protocol over SHTP — wait for INT after NRST release before SPI traffic")))
