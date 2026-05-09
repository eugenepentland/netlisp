(import 204927-0601 204928-0601 pin-header-1x30)

;; Breakout / pass-through board for the Cyclops Digital ↔ Analog expansion link.
;; J1 is the 204927-0601 SlimStack receptacle that mates with the 204928-0601
;; expansion header on the Cyclops Digital board.
;; J4 is the 204928-0601 SlimStack header that mates with the 204927-0601
;; receptacle on the Cyclops Analog board, so the breakout can sit in-line
;; between the two boards (digital → breakout → analog) while still fanning
;; the bus out to 0.1" headers for probing.
;; J2 fans the 30 even pins out to a 0.1" pin header,
;; J3 fans the 30 odd pins out to a 0.1" pin header.
;; Net names mirror the Cyclops Digital expansion-connector net map
;; so the silkscreen on each header reads the function of every pin.
(design-block "Cyclops Expansion Breakout"

  ;; Mezzanine connector — mates with the Cyclops Digital expansion header.
  (instance "J1" 204928-0601
    ;; Even pins — power, SPI3, radar control, GND (mirrored along Y axis: n → 62 - n)
    (pin 58 56 54 52 "VBATT")
    (pin 48 46 "V1P8")
    (pin 44 "EXP_SPI_SCK")
    (pin 42 "EXP_SPI_MISO")
    (pin 40 "EXP_SPI_MOSI")
    (pin 38 "EXP_SPI_NCS")
    (pin 36 "CS_IO_EXP")
    (pin 32 "RF_SPI_SCK")
    (pin 30 "RF_SPI_MOSI")
    (pin 28 "RF_SPI_MISO")
    (pin 24 "TXDATA_1")
    (pin 22 "TXDATA_2")
    (pin 20 "BPSK_GATE_1")
    (pin 18 "BPSK_GATE_2")
    (pin 16 "MRST")
    (pin 12 "RxRST")
    (pin 10 "CNV_MASTER")
    (pin 8 "RxADV")
    (pin 6 "CHIRP_START")
    (pin 4 "MADV")
    (pin 60 50 34 26 14 2 "GND")
    ;; Odd pins — 10 differential pairs with a GND shield between each pair (mirrored: n → 60 - n)
    (pin 59 53 47 41 35 29 23 17 11 5 "GND")
    (pin 57 "ADF_CH1P")  (pin 55 "ADF_CH1N")
    (pin 51 "ADF_CH2P")  (pin 49 "ADF_CH2N")
    (pin 45 "ADF_CH3P")  (pin 43 "ADF_CH3N")
    (pin 39 "ADF_CH4P")  (pin 37 "ADF_CH4N")
    (pin 33 "ADF_CH5P")  (pin 31 "ADF_CH5N")
    (pin 27 "ADF_CH6P")  (pin 25 "ADF_CH6N")
    (pin 21 "ADF_CH7P")  (pin 19 "ADF_CH7N")
    (pin 15 "ADF_CH8P")  (pin 13 "ADF_CH8N")
    (pin 9 "ADF_CH9P")   (pin 7 "ADF_CH9N")
    (pin 3 "ADF_CH10P")  (pin 1 "ADF_CH10N")
    (pin MP1 MP2 MP3 MP4 "GND") (id c45ff0a8))

  ;; Mezzanine connector — mates with the Cyclops Analog expansion receptacle.
  ;; 204928-0601 is the male plug (counterpart to J1's 204927-0601 receptacle),
  ;; so the analog board's 204927-0601 plugs into this side of the breakout.
  ;; Pin numbers are mirrored 1:1 with J1, giving a straight pass-through.
  (instance "J4" 204927-0601
    ;; Even pins — power, SPI3, radar control, GND (mirrored along Y axis: n → 62 - n)
    (pin 58 56 54 52 "VBATT")
    (pin 48 46 "V1P8")
    (pin 44 "EXP_SPI_SCK")
    (pin 42 "EXP_SPI_MISO")
    (pin 40 "EXP_SPI_MOSI")
    (pin 38 "EXP_SPI_NCS")
    (pin 36 "CS_IO_EXP")
    (pin 32 "RF_SPI_SCK")
    (pin 30 "RF_SPI_MOSI")
    (pin 28 "RF_SPI_MISO")
    (pin 24 "TXDATA_1")
    (pin 22 "TXDATA_2")
    (pin 20 "BPSK_GATE_1")
    (pin 18 "BPSK_GATE_2")
    (pin 16 "MRST")
    (pin 12 "RxRST")
    (pin 10 "CNV_MASTER")
    (pin 8 "RxADV")
    (pin 6 "CHIRP_START")
    (pin 4 "MADV")
    (pin 60 50 34 26 14 2 "GND")
    ;; Odd pins — 10 differential pairs with a GND shield between each pair (mirrored: n → 60 - n)
    (pin 59 53 47 41 35 29 23 17 11 5 "GND")
    (pin 57 "ADF_CH1P")  (pin 55 "ADF_CH1N")
    (pin 51 "ADF_CH2P")  (pin 49 "ADF_CH2N")
    (pin 45 "ADF_CH3P")  (pin 43 "ADF_CH3N")
    (pin 39 "ADF_CH4P")  (pin 37 "ADF_CH4N")
    (pin 33 "ADF_CH5P")  (pin 31 "ADF_CH5N")
    (pin 27 "ADF_CH6P")  (pin 25 "ADF_CH6N")
    (pin 21 "ADF_CH7P")  (pin 19 "ADF_CH7N")
    (pin 15 "ADF_CH8P")  (pin 13 "ADF_CH8N")
    (pin 9 "ADF_CH9P")   (pin 7 "ADF_CH9N")
    (pin 3 "ADF_CH10P")  (pin 1 "ADF_CH10N")
    (pin MP1 MP2 MP3 MP4 "GND") (id a20281c8))

  ;; Even-pin header J2 — pin N on header maps to pin (62 - 2*N) on the (mirrored) mezzanine.
  ;; Header pin 1 = mezz pin 60, header pin 2 = mezz pin 58, ..., header pin 30 = mezz pin 2.
  (instance "J2" pin-header-1x30
    (pin 1 "GND")           ;; mezz 60
    (pin 2 "VBATT")         ;; mezz 58
    (pin 3 "VBATT")         ;; mezz 56
    (pin 4 "VBATT")         ;; mezz 54
    (pin 5 "VBATT")         ;; mezz 52
    (pin 6 "GND")           ;; mezz 50
    (pin 7 "V1P8")          ;; mezz 48
    (pin 8 "V1P8")          ;; mezz 46
    (pin 9 "EXP_SPI_SCK")   ;; mezz 44
    (pin 10 "EXP_SPI_MISO") ;; mezz 42
    (pin 11 "EXP_SPI_MOSI") ;; mezz 40
    (pin 12 "EXP_SPI_NCS")  ;; mezz 38
    (pin 13 "CS_IO_EXP")    ;; mezz 36
    (pin 14 "GND")          ;; mezz 34
    (pin 15 "RF_SPI_SCK")   ;; mezz 32
    (pin 16 "RF_SPI_MOSI")  ;; mezz 30
    (pin 17 "RF_SPI_MISO")  ;; mezz 28
    (pin 18 "GND")          ;; mezz 26
    (pin 19 "TXDATA_1")     ;; mezz 24
    (pin 20 "TXDATA_2")     ;; mezz 22
    (pin 21 "BPSK_GATE_1")  ;; mezz 20
    (pin 22 "BPSK_GATE_2")  ;; mezz 18
    (pin 23 "MRST")         ;; mezz 16
    (pin 24 "GND")          ;; mezz 14
    (pin 25 "RxRST")        ;; mezz 12
    (pin 26 "CNV_MASTER")   ;; mezz 10
    (pin 27 "RxADV")        ;; mezz 8
    (pin 28 "CHIRP_START")  ;; mezz 6
    (pin 29 "MADV")         ;; mezz 4
    (pin 30 "GND") (id a3c83b6c))         ;; mezz 2

  ;; Odd-pin header J3 — pin N on header maps to pin (61 - 2*N) on the (mirrored) mezzanine.
  ;; Header pin 1 = mezz pin 59, header pin 2 = mezz pin 57, ..., header pin 30 = mezz pin 1.
  (instance "J3" pin-header-1x30
    (pin 1 "GND")           ;; mezz 59
    (pin 2 "ADF_CH1P")      ;; mezz 57
    (pin 3 "ADF_CH1N")      ;; mezz 55
    (pin 4 "GND")           ;; mezz 53
    (pin 5 "ADF_CH2P")      ;; mezz 51
    (pin 6 "ADF_CH2N")      ;; mezz 49
    (pin 7 "GND")           ;; mezz 47
    (pin 8 "ADF_CH3P")      ;; mezz 45
    (pin 9 "ADF_CH3N")      ;; mezz 43
    (pin 10 "GND")          ;; mezz 41
    (pin 11 "ADF_CH4P")     ;; mezz 39
    (pin 12 "ADF_CH4N")     ;; mezz 37
    (pin 13 "GND")          ;; mezz 35
    (pin 14 "ADF_CH5P")     ;; mezz 33
    (pin 15 "ADF_CH5N")     ;; mezz 31
    (pin 16 "GND")          ;; mezz 29
    (pin 17 "ADF_CH6P")     ;; mezz 27
    (pin 18 "ADF_CH6N")     ;; mezz 25
    (pin 19 "GND")          ;; mezz 23
    (pin 20 "ADF_CH7P")     ;; mezz 21
    (pin 21 "ADF_CH7N")     ;; mezz 19
    (pin 22 "GND")          ;; mezz 17
    (pin 23 "ADF_CH8P")     ;; mezz 15
    (pin 24 "ADF_CH8N")     ;; mezz 13
    (pin 25 "GND")          ;; mezz 11
    (pin 26 "ADF_CH9P")     ;; mezz 9
    (pin 27 "ADF_CH9N")     ;; mezz 7
    (pin 28 "GND")          ;; mezz 5
    (pin 29 "ADF_CH10P")    ;; mezz 3
    (pin 30 "ADF_CH10N") (id fe501f81))   ;; mezz 1

  (note "J1" "Molex SlimStack 204927-0601 receptacle — mates with the 204928-0601 expansion header on the Cyclops Digital board.")
  (note "J4" "Molex SlimStack 204928-0601 plug — mates with the 204927-0601 receptacle on the Cyclops Analog board. Wired straight through to J1 (same pin numbers, same nets) so the breakout can be inserted between the digital and analog boards while still exposing every signal on J2/J3 for probing.")
  (note "J2" "Even-pin breakout: header pin N = mezzanine pin (62 - 2*N) after the J1/J4 Y-axis mirror. Carries power (VBATT/V1P8), EXP_SPI3, radar control bus, and GND shields.")
  (note "J3" "Odd-pin breakout: header pin N = mezzanine pin (61 - 2*N) after the J1/J4 Y-axis mirror. Carries 10 differential ADC pairs (CH1..CH10) with a GND shield between each pair."))
