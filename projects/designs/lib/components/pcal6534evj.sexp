(component "pcal6534evj"
  (description "Interface - I/O Expanders ULV 34-bit Fm+, I2C- I/O Expander")
  (pinout "pcal6534evj")
  (footprint "bga42c40p6x7-260x300x100")
  (manufacturer "NXP")
  (mpn "PCAL6534EVJ")
  (requirement "I2C-bus supply voltage (VDD(I2C-bus)): 0.8V to 3.6V"
    (check-kind voltage-range)
    (refs
      (pdf "datasheet" 2 "Recommended operating conditions, VDD(I2C-bus)")))
  (requirement "Port supply voltage (VDD(P)): 1.65V to 5.5V (0.22µF bypass capacitor required near package)"
    (check-kind voltage-range)
    (refs
      (pdf "datasheet" 2 "Recommended operating conditions, VDD(P)")))
  (requirement "I2C-bus interface: Fast-mode Plus (Fm+) compliant, up to 1 MHz clock frequency"
    (check-kind i2c)
    (refs
      (pdf "datasheet" 1 "General description")))
  (requirement "Bidirectional voltage-level translation between 0.8V-3.6V (I2C side) and 1.65V-5.5V (Port side)"
    (check-kind voltage-range)
    (refs
      (pdf "datasheet" 1-2 "General description and Features")))
  (requirement "Pull-up resistors required on SCL and SDA lines (connect to VDD(I2C-bus))"
    (check-kind pullup-range)
    (refs
      (pdf "datasheet" 6 "Pin description and typical application")))
  (requirement "Pull-up resistor required on INT output (open-drain, connect to VDD(P) or VDD(I2C-bus))"
    (check-kind pullup-range)
    (refs
      (pdf "datasheet" 6 "Pin description")))
  (requirement "Pull-up resistor required on RESET input if no active connection used (connect to VDD(I2C-bus))"
    (check-kind pullup-range)
    (refs
      (pdf "datasheet" 6 "Pin description")))
  (requirement "0.22µF bypass capacitor must be placed on VDD(P) pin as close to package as practical"
    (check-kind decoupling)
    (refs
      (pdf "datasheet" 6 "Pin description")))
  (requirement "ADDR pin configuration: connect to VDD(I2C-bus), GND, SCL, or SDA to select device I2C address (0x40/0x42/0x44/0x46)"
    (check-kind other)
    (refs
      (pdf "datasheet" 7 "Device address and address map")))
  (requirement "Maximum input voltage on Port pins (P0_0 to P4_1): VDD(P) + 0.5V (max 6.5V absolute)"
    (check-kind voltage-range)
    (refs
      (pdf "datasheet" 47 "Limiting values")))
  (requirement "Maximum output current per pin: 25 mA source, 25 mA sink; per octal (Port 0,1): 100 mA max"
    (check-kind current)
    (refs
      (pdf "datasheet" 49 "Static characteristics")))
  (requirement "Schmitt trigger inputs on SCL and SDA for slow signal transition and noise immunity"
    (check-kind other)
    (refs
      (pdf "datasheet" 2 "Features and benefits")))
  (requirement "Open-drain interrupt output (INT) - requires external pull-up resistor"
    (check-kind other)
    (refs
      (pdf "datasheet" 32 "Interrupt output (INT)")))
  (requirement "Operating temperature range: -40°C to +85°C (Tamb)"
    (check-kind other)
    (refs
      (pdf "datasheet" 48 "Recommended operating conditions")))
  (requirement "Standby current: typical 2.0µA at 3.3V VDD(P) with no I/O activity"
    (check-kind other)
    (refs
      (pdf "datasheet" 2 "Features and benefits")))
  (requirement "All I/Os are configured as high-impedance inputs at power-on reset"
    (check-kind other)
    (refs
      (pdf "datasheet" 4 "Block diagram note")))
  (requirement "Internal 100kΩ ±50% pull-up/pull-down resistors available on each I/O pin"
    (check-kind pullup-range)
    (refs
      (pdf "datasheet" 21 "Static characteristics, Rpu(int) and Rpd(int)")))
)