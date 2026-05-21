;; Nested hierarchical-id coverage: design → bank (dual-flash) → flash (mx66uw).
;; Each flash part id = hash(hash(bank_uuid, "lo"/"hi"), origin_key).
(import dual-flash)

(design-block "Nested Flash Array"
  (hierarchical-ids)
  (sub-block "bank1" (dual-flash) (id ebcb7396))
  (sub-block "bank2" (dual-flash) (id ac2087b4))
  (net "VDDIO" "bank1/VDDIO" "bank2/VDDIO")
  (net "GND"   "bank1/GND"   "bank2/GND"))
