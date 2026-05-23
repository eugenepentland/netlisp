;; Verification log for cyclops-analog — autoloaded as a sibling of
;; cyclops-analog.sexp. Each (verifies …) targets a specific (ref_des,
;; requirement-id) pair; the IDs are the requirement IDs from
;; lib/components/<part>.sexp (explicit (id …) or CRC32 of the text), so
;; editing the library text invalidates the link until the next id-freeze.
;;
;; These are reviewer sign-offs for component requirements the netlist
;; already satisfies but that carry no machine (check …) clause — so the
;; review would otherwise leave them "n/a / reviewer-judged". Layout,
;; firmware-sequencing, thermal, RF-matching, abs-max and handling rules are
;; intentionally NOT signed off here: they need human/firmware/layout
;; judgment the schematic can't answer.

  ;; ── TPS63806 buck-boost (U4) ───────────────────────────────────────────
  (verifies (req "U4" 3c224cca)
    "FB divider implemented as R_FBT_BUCK33 (560k, top) / R_FBB_BUCK33 (100k, bottom): low-side resistor is exactly the 100k ceiling, and R1 = R2 × (VOUT/0.5 − 1) = 100k × (3.3/0.5 − 1) = 100k × 5.6 = 560k, so VFB regulates to 0.5 V → VOUT = 3.3 V. Matches the note on R_FBT_BUCK33.")

  (verifies (req "U4" 4e3c3230)
    "PG (E1) is pulled up by R_PG_BUCK33 (100k, id c88cdb3a) to V_RF_3P3 = 3.3 V — strictly below the 5.5 V ceiling, and to the buck's own regulated output rail rather than a boost node that could swing high under OVP. PG is used (routed to PG_BUCK33), so the 'leave unconnected if unused' branch does not apply.")

  ;; ── MAX7301 I/O expander (U7) ──────────────────────────────────────────
  (verifies (req "U7" c7146a70)
    "ISET (pin 36) is tied to GND through R_ISET_IOEXP (39k, res-0402) — the datasheet's recommended typical-operating value and inside the required 39k–120k window. See the R_ISET_IOEXP note re: short trace + local GND return.")

  ;; ── SiT5157 100 MHz TCXO (U6) ──────────────────────────────────────────
  (verifies (req "U6" 12b0ad58)
    "Close-in decoupling present: C_TCXO_VCC (100nF = 0.1µF, cap-0402) bridges U_TCXO Vdd (pin 9) to GND (pin 4). The 1–2 mm placement / shortest-loop part of the rule is a PCB-layout constraint, not a netlist property.")

  (verifies (req "U6" be5ce2c7)
    "Bulk capacitor present: C_TCXO_VCC_BULK (10µF, cap-0805) is paired with the 0.1µF C_TCXO_VCC on the TCXO Vdd rail, feeding the part's on-chip regulators (no external LDO ahead of the part). The 'within 2 inches' part is a layout constraint.")

  (verifies (req "U6" a2a99953)
    "Series source-termination present: R_TCXO_SER (24R9, res-0402) sits on the CLK output (pin 6) ahead of the 50 Ω RADAR_REF trace — matching the datasheet's ~25 Ω starting-point example for the part's ~17 Ω output buffer. Close-to-pin-6 placement is a layout constraint.")

  (verifies (req "U6" 707d370f)
    "OE (pin 1, net TCXO_EN) is driven by MAX7301 port P15 — a push-pull 3.3 V CMOS output, exactly the driver class the datasheet says meets VIH ≥ 2.31 V / VIL ≤ 0.99 V easily. R21 (10k pull-down on TCXO_EN) only sets the boot-default-disabled state before firmware drives P15; it does not affect the driven-state levels.")

  ;; ── ADF5901 TX VCO+PA ×2 (U8, U9) ──────────────────────────────────────
  (verifies (req "U8" 50dd8071)
    "RSET set by R_RSET_5901_1 (5.1k, res-0402, id c409b9ee) between the ADF5901 #1 RSET pin (net RSET_5901_1) and GND — the datasheet nominal (RSET sits at ~0.62 V).")

  (verifies (req "U9" 50dd8071)
    "RSET set by R_RSET_5901_2 (5.1k, res-0402, id b265207d) between the ADF5901 #2 RSET pin (net RSET_5901_2) and GND — the datasheet nominal (RSET sits at ~0.62 V).")
