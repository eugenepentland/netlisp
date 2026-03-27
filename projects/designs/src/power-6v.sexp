(import tpsm84338)
(import lt3045)

(design-block "6V Low Noise Power Supply"
  ;; Buck: RFBT=320k, RFBB=30k -> VOUT=7.0V
  (sub-block "buck" (tpsm84338 320000 30000 820))
  ;; LDO: RSET=60k -> VOUT=6.0V
  (sub-block "ldo" (lt3045 60000 300)))
