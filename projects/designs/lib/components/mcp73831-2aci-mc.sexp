(component "mcp73831-2aci-mc"
  (description "Microchip MCP73831 500mA Li-Ion/Li-Poly charge controller, DFN-8")
  (pinout mcp73831-2aci-mc)
  (footprint son50p300x200x100-9n-d)
  (manufacturer "Microchip")
  (mpn "MCP73831-2ACI/MC")
  (note "Pin 7 (NC) left unconnected")
  (note "Exposed pad (pin 9) must be soldered to VSS for thermal dissipation")
  (datasheet "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf")
  (requirement "VDD input supply must be 3.75V to 6V; recommended [VREG+0.3V, 6V]"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 11)
         (quote "A supply voltage of"))
    (check (voltage-range (pin "VDD_1") (min 3.75) (max 6.0))))
  (requirement "Bypass VDD to VSS with a ceramic cap of ≥4.7 µF"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 11)
         (quote "Bypass to VSS with a minimum of"))
    (check (decoupling (pin "VDD_1") (pin "VSS") (min-uf 4.7))))
  (requirement "Bypass VBAT to VSS with a ceramic cap of ≥4.7 µF — required for loop stability when the battery is disconnected"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 11)
         (quote "loop stability"))
    (check (decoupling (pin "VBAT_1") (pin "VSS") (min-uf 4.7))))
  (requirement "PROG resistor must be 2 kΩ (500 mA) to 67 kΩ (15 mA); I_REG ≈ 1000 V / R_PROG"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 4)
         (quote "Charge Impedance"))
    (check (pullup-range (pin "PROG") (net "GND") (min-ohms 2000) (max-ohms 67000))))
  (requirement "Leave PROG floating or pull >200 kΩ to disable charging (acts as charge-enable)"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 13)
         (quote "manual shutdown")))
  (requirement "Size R_PROG so I_REG matches 1C of the Li-ion cell; 2C is the absolute max"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 17)
         (quote "1C rate")))
  (requirement "STAT pin needs a series current-limiting resistor when driving an LED, or a pull-up when driving a microcontroller GPIO (open-drain on MCP73832)"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 11)
         (quote "tri-state logic")))
  (requirement "Exposed Thermal Pad (EP) must be connected to VSS; add thermal vias from the EP land to a copper plane on the opposite layer"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 11)
         (quote "Exposed Thermal Pad"))
    (check (connected (pin "EP") (pin "VSS"))))
  (requirement "Impedance at VBAT before the cell is connected must exceed 7 MΩ so battery-insertion detection works (6 µA source, 0.6 µA min)"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 13)
         (quote "battery insertion")))
  (requirement "Add a TVS/transzorb (e.g. SMAJ5.0A) from VDD to VSS when the input is hot-pluggable (USB, wall adapters) to absorb cable-inductance transients"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 18)
         (quote "transzorb")))
  (requirement "VREG options are factory-set (4.20 / 4.35 / 4.40 / 4.50 V) — verify the suffix matches the cell chemistry before placing"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 3)
         (quote "Regulated Output Voltage")))
  (requirement "VSS (pin 6) is the 0V reference for both the battery and the input supply — tie both return paths to it"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 11)
         (quote "negative terminal of battery")))
  (requirement "Budget thermal dissipation: DFN θJA ≈ 76 °C/W (4-layer, large Cu); worst case is just after preconditioning→fast-charge transition at max VDD"
    (ref "MCP73831-Family-Data-Sheet-DS20001984H__1_.pdf" (page 5)
         (quote "4-Layer JC51-7"))))
