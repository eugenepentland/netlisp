(import tpsm84338)

(design-block "tpsm84338-eval"

  ;; Instantiate TPSM84338 with: RFBT=220k, RFBB=47k, RLED=1k
  ;; VOUT = 0.6 * (1 + 220k/47k) = 3.41V
  (sub-block "pwr-3v3" (tpsm84338 220000 47000 1000)))
