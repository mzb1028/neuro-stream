# Neuro-Stream — MVP Build Spec

**Goal:** a bench machine that proves the four make-or-break claims — ±2%
dosing, smart-cartridge docking, ±2 °F water, in-stream dissolution — built
from this document, the two schematics, and the printed parts.

**Companion diagrams:**
[`diagrams/mvp-wiring.svg`](diagrams/mvp-wiring.svg) ·
[`diagrams/mvp-plumbing.svg`](diagrams/mvp-plumbing.svg)
**Printed parts:** from [`../cad/cartridge-metering.scad`](../cad/cartridge-metering.scad)
and [`../cad/venturi-manifold.scad`](../cad/venturi-manifold.scad)
**Test matrix:** [`design-metering-venturi.md`](design-metering-venturi.md) §4

**MVP scope (deliberately smaller than the product):** ONE dispense station.
Cartridges are swapped by hand instead of a motorized carousel (the carousel is
proven engineering — rotation is not a risk worth prototyping). Everything else
is the real architecture.

---

## 1. Shopping list (~$700 electronics/hardware + ~$450 printed parts)

### Electronics

| Item | Example part | Qty | ~Cost |
|---|---|---|---|
| ESP32-S3 devkit | ESP32-S3-DevKitC-1-N8R2 | 1 | $15 |
| Stepper driver | BIGTREETECH TMC2209 v1.3 | 2 | $18 |
| Drive motor | NEMA17 + 5.18:1 planetary (StepperOnline 17HS15-1684S-PG5) | 1 | $35 |
| Carousel motor (optional) | NEMA17 pancake | 1 | $14 |
| Load cell + ADC | 1 kg TAL221 + SparkFun HX717 (or HX711) | 1 | $18 |
| NFC reader | PN532 module (set to I²C) + NTAG215 stickers ×10 | 1 | $16 |
| Flow meter | YF-S402B (G1/4, hall pulse) | 1 | $9 |
| NTC thermistors | 100 kΩ 1% glass bead, ×3 | 3 | $6 |
| SSR | 25 A zero-cross (Crydom-class, with heatsink) — genuine, not clone | 1 | $35 |
| Thermal cutoffs | KSD301 95 °C manual-reset + 130 °C one-shot fuse | 2 | $6 |
| PSU | Mean Well LRS-75-12 (12 V 6 A, enclosed) | 1 | $22 |
| Buck converter | 12→5 V 3 A module | 1 | $6 |
| MOSFET + flyback diode | IRLZ44N + 1N5822 (pump switch) | 1 | $3 |
| Touchscreen (optional on bench) | 2.8" ILI9341 SPI + touch | 1 | $12 |
| Hall switch + magnet, reed switch | dock-aligned + manifold-present interlocks | 2 | $5 |
| GFCI adapter, IEC inlet w/ fuse, earthed metal project box for mains | — | — | $45 |
| Wire, JST connectors, perfboard, standoffs | — | — | $30 |

### Water path

| Item | Spec | ~Cost |
|---|---|---|
| Pump | 12 V diaphragm, potable-rated, 0.5–1 L/min (e.g., Bartendro/Flojet-class) | $25 |
| Inline heater | 1200 W thick-film coffee-machine heater, 316L wetted (or **skip for cold-water phase 1**) | $40 |
| Silicone tube | platinum-cured, 8 mm OD × 5 mm ID, 2 m | $15 |
| Barbs, tees, clamps | PP or 304 SS, 8 mm | $20 |
| Check valve | 8 mm inline, silicone/PP | $5 |
| Tank | any 2 L food container, bulkhead fitting at bottom | $12 |

### Printed / fabricated (upload STLs to a service like Craftcloud/Xometry)

| Part | File / module | Process | Qty | ~Cost |
|---|---|---|---|---|
| Powder cartridge housing | `cartridge-metering.scad` part="powder" housing | **Clear SLA** (watch powder move) | 3 | $90 |
| Powder screw + agitator | same, screw | **MJF PA12** or machined POM | 3+3 | $120 |
| Syrup pump housing + piston + leadscrew | part="syrup" | MJF PA12 / machined POM | 2 sets | $110 |
| Mixing cone + vapor shield | `venturi-manifold.scad` | **Clear SLA**, 3 throat variants (Ø5/7/9) | 3+1 | $80 |
| Dock frame, motor mount, cartridge collar | simple brackets — any FDM printer | — | ~$30 |
| Duckbill/umbrella valves, Ø20 X-ring | **buy silicone** (Minivalve or eBay assortment) — don't print seals | — | $25 |

## 2. Wiring — pin map (matches the schematic)

| ESP32-S3 pin | Connects to | Notes |
|---|---|---|
| GPIO4 / GPIO5 | TMC2209 #1 STEP / DIR | drive motor |
| GPIO15 / GPIO16 | TMC2209 #2 STEP / DIR | carousel (optional) |
| GPIO6 | both TMC2209 EN | active low |
| GPIO7 | both TMC2209 UART (addr 0 / 1) | 1 kΩ into PDN_UART |
| GPIO13 | SSR control + | SSR − to GND; **series with GPIO21 watchdog gate** |
| GPIO21 | 555/monostable hardware watchdog | firmware strokes it at 2 Hz; loss = SSR off |
| GPIO14 | IRLZ44N gate (pump) | 100 Ω series, 100 k pulldown, diode across pump |
| GPIO12 | flow meter signal | 10 k pull-up to 3.3 V |
| GPIO1 / GPIO2 | NTC dividers (spout / heater body) | 100 k NTC + 100 k 1% to 3.3 V |
| GPIO10 / GPIO11 | HX717 DOUT / SCK | load cell E±, S± per module silk |
| GPIO8 / GPIO9 | PN532 SDA / SCL | module DIP switches → I²C |
| GPIO17 / GPIO18 | dock hall switch / manifold reed switch | interlocks, pull-ups |
| SPI2 (GPIO33–38) | display SCK/MOSI/CS/DC/RST/BL | optional |
| 5 V / GND | from buck converter | common ground everywhere **except** mains side |

## 3. Assembly order (a competent maker: ~2 weekends)

1. **Frame:** 2020 aluminum extrusion or plywood tower. Cartridge dock collar
   at top (cartridge hangs neck-down), drive motor **below** it pointing up,
   its shaft carrying a printed 6-lobe spline (from the .scad) that engages
   the cartridge when you seat it. Mixing cone clamps 10–15 mm below the
   cartridge outlet. Glass sits on the load cell at the bottom.
2. **Dry dosing first (no water at all):** wire ESP32 + TMC2209 + load cell.
   Fill a powder cartridge with table salt or creatine. Run the dose test:
   command revolutions → weigh what falls into a cup on the load cell,
   cross-check on a 0.001 g balance. **This alone proves claim #1.**
3. **Cold water loop:** add tank → pump → flow meter → (tube where heater will
   go) → mixing cone. Verify the swirl film with food dye, then run
   dissolution tests cold. Proves claim #4 at room temperature.
4. **NFC:** stick NTAG215 tags on cartridges; write ingredient ID + a
   calibration constant from step 2's data; firmware reads tag before dosing.
   Proves claim #2.
5. **Heat — last, and only with the safety chain complete:** GFCI + earthed
   mains box + both thermal cutoffs + SSR + watchdog gate + boil-dry guard in
   firmware. PID + feed-forward per Phase 3 §3.3. Thermocouple reference at
   the spout. Proves claim #3.
   *If mains work isn't your comfort zone: hire any appliance tech for a day,
   or run the entire MVP cold — 3 of 4 claims need no heat.*

## 4. Firmware starting points

- Framework: ESP-IDF or Arduino-ESP32; libraries: `TMCStepper`, `HX711`
  (HX717-compatible), `Adafruit_PN532`, `LVGL` (if screen).
- Control loop 100 Hz: read flow + NTCs → PID/feed-forward (Phase 3 §3.3) →
  SSR burst duty; stroke watchdog at 2 Hz.
- Dose sequence exactly as Phase 3 §3.1–3.2 (cup check → tag verify →
  co-dispense → suck-back → verify weight).
- Log every dispense to flash/serial CSV: commanded g, revs, load-cell delta,
  water temp — this CSV **is** the evidence file for the test matrix.

## 5. What "done" looks like

The MVP passes when the `design-metering-venturi.md` §4 table is green:
dose σ ≤ 0.8%, full-to-empty drift flat within ±2%, syrup re-prime ≤ 7 s,
wet-wall coverage < 1 s, dissolution residue < 1%, spout ±2 °F. Bring those
CSVs to the Phase-5 beta gate — they're what you show engineers, co-packers,
and investors next.
