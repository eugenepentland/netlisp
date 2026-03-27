(import tpsm84338)

(design-block "TPSM84338 3.3V Eval"
  ;; RFBT=220k, RFBB=47k, RLED=1k -> VOUT=3.41V
  (sub-block "pwr" (tpsm84338 220000 47000 1000)))
