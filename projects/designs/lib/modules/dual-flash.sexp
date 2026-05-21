;; A flash "bank" that sub-blocks mx66uw-flash twice — exists purely to
;; exercise NESTED hierarchical sub-blocks (a module containing sub-blocks).
(import mx66uw-flash)

(defmodule dual-flash ()
  "Two MX66UW flash chips behind one module boundary."
  (design-block "Dual Flash Bank"
    (sub-block "lo" (mx66uw-flash))
    (sub-block "hi" (mx66uw-flash))
    (net "VDDIO" "lo/VDDIO" "hi/VDDIO")
    (net "GND"   "lo/GND"   "hi/GND")
    (port "VDDIO" in (rated 1.7 1.95))
    (port "GND"   bidi)))
