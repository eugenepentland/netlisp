;; Integration coverage for hierarchical-ids with auto-generated passives.
;; mx66uw-flash has NO explicit child ids: a (decouple …) that fans out to
;; several pad-keyed caps, plus three named (series …) (incl. a diode). Under
;; (hierarchical-ids) each of those derives id = hash(subblock_uuid, origin_key)
;; — decouple caps via their value@pin#index key, series via their source name.
(import mx66uw-flash)

(design-block "Flash Array (hierarchical decouple/series coverage)"
  (hierarchical-ids)

  (sub-block "fa" (mx66uw-flash) (id c6236346))
  (sub-block "fb" (mx66uw-flash) (id eee79a74))

  (net "VDDIO" "fa/VDDIO" "fb/VDDIO")
  (net "GND"   "fa/GND"   "fb/GND")
  (net "NRST"  "fa/NRST"  "fb/NRST")
  (net "CLK"   "fa/CLK"   "fb/CLK"))
