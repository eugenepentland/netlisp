;; USB 2.0 High-Speed front-end: USB-C receptacle (UFP/device role) +
;; ECMF02 ESD/EMI protection on the data lines + TXRTUNE termination.
;; Exposes the host MCU side as USB_DP/USB_DN/TXRTUNE so the board can
;; wire them to whichever MCU implements the USB PHY.

(import ecmf02-2amx6)
(import usb4235-03-c)

(defmodule usb-c-hs ()
  "USB-C UFP (device-only) front-end with USB 2.0 HS data path.
   Provides ESD protection and PHY-side TXRTUNE termination internally.
   Caller wires VBUS, GND, USB_DP, USB_DN, and TXRTUNE."

  (design-block "USB-C 2.0 HS"

    (instance "usb-esd" ecmf02-2amx6
      (pin D_1 "USB_DP")
      (pin D_2 "USB_DN")
      (pin GND "GND")
      (pin "D-" "USB_CONN_DN")
      (pin "D+" "USB_CONN_DP"))
    (instance "usb-c" usb4235-03-c
      (pin A1 A12 B1 B12 17 18 "GND")
      (pin A4 A9 B4 B9 "VBUS")
      (pin A5 "CC1")
      (pin B5 "CC2")
      (pin A6 B6 "USB_CONN_DP")
      (pin A7 B7 "USB_CONN_DN"))
    (series (res-0402 "5.1k") "CC1" "GND" "CC2" "GND")
    (series "R8" (res-0201 "200R") "TXRTUNE" "GND")
    (decouple "VBUS" (cap-0805 "10uF") 1 per-pin usb-c A4)

    (port "VBUS"    out (rated 4.0 5.5))
    (port "GND"     bidi)
    (port "USB_DP"  io)
    (port "USB_DN"  io)
    (port "TXRTUNE" io)

    (note "usb-c"  "5.1k pull-downs on CC1/CC2 select UFP (device) role per USB-C spec.")
    (note "usb-c"  "SBU1 (A8) and SBU2 (B8) left unconnected — unused in USB 2.0 device mode.")
    (note "usb-c"  "Pins 17/18 are shield/shell GND (mid-mount tabs).")
    (note "R8"     "TXRTUNE 200Ω-to-GND sets the USB HS PHY transmitter source impedance. Required by the USB 2.0 spec for HS eye compliance — placed close to the MCU TXRTUNE pin.")
    (note "usb-esd" "ECMF02-2AMX6 provides common-mode + ESD protection on D+/D-. Chip's data-side D_1/D_2 face the MCU; \"D+\"/\"D-\" pins face the USB-C receptacle.")))
