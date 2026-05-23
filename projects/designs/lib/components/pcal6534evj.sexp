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
)