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
  (instance "J1" 204927-0601
    ;; Even pins — power, SPI3, radar control, GND
    (pin 4 6 8 10 "VBATT")
    (pin 14 16 "V1P8")
    (pin 18 "EXP_SPI_SCK")
    (pin 20 "EXP_SPI_MISO")
    (pin 22 "EXP_SPI_MOSI")
    (pin 24 "EXP_SPI_NCS")
    (pin 26 "CS_IO_EXP")
    (pin 30 "RF_SPI_SCK")
    (pin 32 "RF_SPI_MOSI")
    (pin 34 "RF_SPI_MISO")
    (pin 38 "TXDATA_1")
    (pin 40 "TXDATA_2")
    (pin 42 "BPSK_GATE_1")
    (pin 44 "BPSK_GATE_2")
    (pin 46 "MRST")
    (pin 50 "RxRST")
    (pin 52 "CNV_MASTER")
    (pin 54 "RxADV")
    (pin 56 "CHIRP_START")
    (pin 58 "MADV")
    (pin 2 12 28 36 48 60 "GND")
    ;; Odd pins — 10 differential pairs with a GND shield between each pair
    (pin 1 7 13 19 25 31 37 43 49 55 "GND")
    (pin 3 "ADF_CH1P")   (pin 5 "ADF_CH1N")
    (pin 9 "ADF_CH2P")   (pin 11 "ADF_CH2N")
    (pin 15 "ADF_CH3P")  (pin 17 "ADF_CH3N")
    (pin 21 "ADF_CH4P")  (pin 23 "ADF_CH4N")
    (pin 27 "ADF_CH5P")  (pin 29 "ADF_CH5N")
    (pin 33 "ADF_CH6P")  (pin 35 "ADF_CH6N")
    (pin 39 "ADF_CH7P")  (pin 41 "ADF_CH7N")
    (pin 45 "ADF_CH8P")  (pin 47 "ADF_CH8N")
    (pin 51 "ADF_CH9P")  (pin 53 "ADF_CH9N")
    (pin 57 "ADF_CH10P") (pin 59 "ADF_CH10N")
    (pin MP1 MP2 MP3 MP4 "GND") (id c45ff0a8))

  ;; Mezzanine connector — mates with the Cyclops Analog expansion receptacle.
  ;; 204928-0601 is the male plug (counterpart to J1's 204927-0601 receptacle),
  ;; so the analog board's 204927-0601 plugs into this side of the breakout.
  ;; Pin numbers are mirrored 1:1 with J1, giving a straight pass-through.
  (instance "J4" 204928-0601
    ;; Even pins — power, SPI3, radar control, GND
    (pin 4 6 8 10 "VBATT")
    (pin 14 16 "V1P8")
    (pin 18 "EXP_SPI_SCK")
    (pin 20 "EXP_SPI_MISO")
    (pin 22 "EXP_SPI_MOSI")
    (pin 24 "EXP_SPI_NCS")
    (pin 26 "CS_IO_EXP")
    (pin 30 "RF_SPI_SCK")
    (pin 32 "RF_SPI_MOSI")
    (pin 34 "RF_SPI_MISO")
    (pin 38 "TXDATA_1")
    (pin 40 "TXDATA_2")
    (pin 42 "BPSK_GATE_1")
    (pin 44 "BPSK_GATE_2")
    (pin 46 "MRST")
    (pin 50 "RxRST")
    (pin 52 "CNV_MASTER")
    (pin 54 "RxADV")
    (pin 56 "CHIRP_START")
    (pin 58 "MADV")
    (pin 2 12 28 36 48 60 "GND")
    ;; Odd pins — 10 differential pairs with a GND shield between each pair
    (pin 1 7 13 19 25 31 37 43 49 55 "GND")
    (pin 3 "ADF_CH1P")   (pin 5 "ADF_CH1N")
    (pin 9 "ADF_CH2P")   (pin 11 "ADF_CH2N")
    (pin 15 "ADF_CH3P")  (pin 17 "ADF_CH3N")
    (pin 21 "ADF_CH4P")  (pin 23 "ADF_CH4N")
    (pin 27 "ADF_CH5P")  (pin 29 "ADF_CH5N")
    (pin 33 "ADF_CH6P")  (pin 35 "ADF_CH6N")
    (pin 39 "ADF_CH7P")  (pin 41 "ADF_CH7N")
    (pin 45 "ADF_CH8P")  (pin 47 "ADF_CH8N")
    (pin 51 "ADF_CH9P")  (pin 53 "ADF_CH9N")
    (pin 57 "ADF_CH10P") (pin 59 "ADF_CH10N")
    (pin MP1 MP2 MP3 MP4 "GND") (id a20281c8))

  ;; Even-pin header J2 — pin N on header maps to pin (2*N) on the mezzanine.
  ;; Header pin 1 = mezz pin 2, header pin 2 = mezz pin 4, ..., header pin 30 = mezz pin 60.
  (instance "J2" pin-header-1x30
    (pin 1 "GND")           ;; mezz 2
    (pin 2 "VBATT")         ;; mezz 4
    (pin 3 "VBATT")         ;; mezz 6
    (pin 4 "VBATT")         ;; mezz 8
    (pin 5 "VBATT")         ;; mezz 10
    (pin 6 "GND")           ;; mezz 12
    (pin 7 "V1P8")          ;; mezz 14
    (pin 8 "V1P8")          ;; mezz 16
    (pin 9 "EXP_SPI_SCK")   ;; mezz 18
    (pin 10 "EXP_SPI_MISO") ;; mezz 20
    (pin 11 "EXP_SPI_MOSI") ;; mezz 22
    (pin 12 "EXP_SPI_NCS")  ;; mezz 24
    (pin 13 "CS_IO_EXP")    ;; mezz 26
    (pin 14 "GND")          ;; mezz 28
    (pin 15 "RF_SPI_SCK")   ;; mezz 30
    (pin 16 "RF_SPI_MOSI")  ;; mezz 32
    (pin 17 "RF_SPI_MISO")  ;; mezz 34
    (pin 18 "GND")          ;; mezz 36
    (pin 19 "TXDATA_1")     ;; mezz 38
    (pin 20 "TXDATA_2")     ;; mezz 40
    (pin 21 "BPSK_GATE_1")  ;; mezz 42
    (pin 22 "BPSK_GATE_2")  ;; mezz 44
    (pin 23 "MRST")         ;; mezz 46
    (pin 24 "GND")          ;; mezz 48
    (pin 25 "RxRST")        ;; mezz 50
    (pin 26 "CNV_MASTER")   ;; mezz 52
    (pin 27 "RxADV")        ;; mezz 54
    (pin 28 "CHIRP_START")  ;; mezz 56
    (pin 29 "MADV")         ;; mezz 58
    (pin 30 "GND") (id a3c83b6c))         ;; mezz 60

  ;; Odd-pin header J3 — pin N on header maps to pin (2*N - 1) on the mezzanine.
  ;; Header pin 1 = mezz pin 1, header pin 2 = mezz pin 3, ..., header pin 30 = mezz pin 59.
  (instance "J3" pin-header-1x30
    (pin 1 "GND")           ;; mezz 1
    (pin 2 "ADF_CH1P")      ;; mezz 3
    (pin 3 "ADF_CH1N")      ;; mezz 5
    (pin 4 "GND")           ;; mezz 7
    (pin 5 "ADF_CH2P")      ;; mezz 9
    (pin 6 "ADF_CH2N")      ;; mezz 11
    (pin 7 "GND")           ;; mezz 13
    (pin 8 "ADF_CH3P")      ;; mezz 15
    (pin 9 "ADF_CH3N")      ;; mezz 17
    (pin 10 "GND")          ;; mezz 19
    (pin 11 "ADF_CH4P")     ;; mezz 21
    (pin 12 "ADF_CH4N")     ;; mezz 23
    (pin 13 "GND")          ;; mezz 25
    (pin 14 "ADF_CH5P")     ;; mezz 27
    (pin 15 "ADF_CH5N")     ;; mezz 29
    (pin 16 "GND")          ;; mezz 31
    (pin 17 "ADF_CH6P")     ;; mezz 33
    (pin 18 "ADF_CH6N")     ;; mezz 35
    (pin 19 "GND")          ;; mezz 37
    (pin 20 "ADF_CH7P")     ;; mezz 39
    (pin 21 "ADF_CH7N")     ;; mezz 41
    (pin 22 "GND")          ;; mezz 43
    (pin 23 "ADF_CH8P")     ;; mezz 45
    (pin 24 "ADF_CH8N")     ;; mezz 47
    (pin 25 "GND")          ;; mezz 49
    (pin 26 "ADF_CH9P")     ;; mezz 51
    (pin 27 "ADF_CH9N")     ;; mezz 53
    (pin 28 "GND")          ;; mezz 55
    (pin 29 "ADF_CH10P")    ;; mezz 57
    (pin 30 "ADF_CH10N") (id fe501f81))   ;; mezz 59

  (note "J1" "Molex SlimStack 204927-0601 receptacle — mates with the 204928-0601 expansion header on the Cyclops Digital board.")
  (note "J4" "Molex SlimStack 204928-0601 plug — mates with the 204927-0601 receptacle on the Cyclops Analog board. Wired straight through to J1 (same pin numbers, same nets) so the breakout can be inserted between the digital and analog boards while still exposing every signal on J2/J3 for probing.")
  (note "J2" "Even-pin breakout: header pin N = mezzanine pin 2*N. Carries power (VBATT/V1P8), EXP_SPI3, radar control bus, and GND shields.")
  (note "J3" "Odd-pin breakout: header pin N = mezzanine pin 2*N-1. Carries 10 differential ADC pairs (CH1..CH10) with a GND shield between each pair."))
