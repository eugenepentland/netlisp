(import lt3045)

(design-block "LT3045 6V Eval"
  ;; RSET=60k -> VOUT=6.0V, RILIM=300 -> ILIM=500mA
  (sub-block "ldo" (lt3045 60000 300)))
