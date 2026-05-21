;; Option-4 (hierarchical) identity demo — 3 instantiations of ONE module.
;; `(hierarchical-ids)` opts in: each (sub-block …) gets a single uuid (auto-
;; minted on first build), and every part's id = hash(subblock_uuid, its stable
;; module-local key). The module itself stays a clean, un-annotated template.
(import ad7380-channel)

(design-block "ADC Array (hierarchical-id demo)"
  (hierarchical-ids)

  (sub-block "adc1" (ad7380-channel 1) (id c240ac6e))
  (sub-block "adc2" (ad7380-channel 2) (id a5eb04ca))
  (sub-block "adc3" (ad7380-channel 3) (id d6568ac3))

  (net "VCC3V3"  "adc1/VCC"    "adc2/VCC"    "adc3/VCC")
  (net "V1P8"    "adc1/VLOGIC" "adc2/VLOGIC" "adc3/VLOGIC")
  (net "VREF2V5" "adc1/REFIN"  "adc2/REFIN"  "adc3/REFIN")
  (net "GND"     "adc1/GND"    "adc2/GND"    "adc3/GND")
  (net "SCK"     "adc1/SCK"    "adc2/SCK"    "adc3/SCK")
  (net "SDI"     "adc1/SDI"    "adc2/SDI"    "adc3/SDI"))
