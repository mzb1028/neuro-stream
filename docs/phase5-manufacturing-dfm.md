# Neuro-Stream — Phase 5: Manufacturing Plan & Tiered Pricing (DFM)

**Status:** Draft for founder sign-off
**Date:** 2026-07-09
**Configuration priced:** 11-slot carousel machine (10 ingredients + cleaning
slot), water/heating/venturi system, touchscreen, per signed-off Phases 1–4.

---

## 1. How each part gets made (DFM review)

### Machine — 11-slot countertop unit

| Part | Process | Tooling cost (Asia) | Notes |
|---|---|---|---|
| Chassis skirt + tower (2 shells) | Injection mold, ABS | $45–60k × 2 | Biggest tools in the program |
| Carousel ring w/ molded gear | Injection mold, GF-PP | $28k | Ø~47 cm part — needs a large press (≥650 T); fewer vendors, quote early |
| Docking cone | Injection mold, GF-PP | $12k | |
| Water tank (2 pcs + lid) | Injection mold, Tritan | $30k | Clear part: high-polish tool |
| Venturi manifold + spout | Injection mold, Tritan | $16k | Food-contact, high-polish |
| Weigh platform, drip tray, small covers | Injection mold | $22k | Family tool |
| Machine lid | Injection mold, clear PC | $20k | |
| Internal deck plate | Sheet metal, 1.5 mm | $3k (soft tool) | Convert to molding later if volume grows |
| Drive spline shaft | CNC, 316L stainless | — | ~$3.80/pc machined; the one precision metal part |
| Motors, pump, heater, load cell, slew bearing, display, NFC, PCBA | Off-the-shelf / standard PCBA | — | See Phase 3 BOM |
| **Machine tooling total** | | **≈ $180–225k** | One-time, before first sellable unit |

### Cartridges (3 SKUs: powder, syrup, cleaning)

| Part set | Tooling | Notes |
|---|---|---|
| Shell + neck + base cap (shared across SKUs) | $38k (multi-cavity) | Shared geometry is the money-saver |
| Powder screw + agitator | $20k | POM, single tool |
| Syrup piston block + leadscrew | $26k | POM |
| LSR seals/valves (all SKUs) | $24k (2 micro-molds) | |
| Cleaning cartridge divider insert | $9k | Reuses shell |
| Aseptic bag + valve | — | Bought from bag-in-box supplier; MOQ ~50k bags |
| **Cartridge tooling total** | | **≈ $117k** |

**Program tooling total: ≈ $300–340k** (Asia; roughly 1.7–2× if tooled in the
US). This is the capital gate identified back in Phase 1 — unchanged.

## 2. Tiered pricing — machine cost at three year-1 volumes

Build cost per machine (parts + assembly + test + packaging, ex-factory):

| | **2,000 units** | **5,000 units** | **10,000 units** |
|---|---|---|---|
| Electronics + electromech (Phase 3 set) | $95 | $83 | $75 |
| Moldings (chassis, carousel, tank, etc.) | $46 | $38 | $33 |
| Hardware, bearing, spline, fasteners | $14 | $12 | $10 |
| Assembly + test labor | $22 | $16 | $13 |
| Packaging (retail box, foam, manual) | $11 | $9 | $8 |
| **Build cost (BOM + labor)** | **≈ $188** | **≈ $158** | **≈ $139** |
| + freight, duty, warranty reserve (~12%) | ≈ $211 | ≈ $177 | ≈ $156 |
| **Suggested retail (≈3× landed)** | **$599–649** | **$499–549** | **$449–479** |
| Tooling amortized per unit (if you prefer to load it) | +$160 | +$64 | +$32 |

Plain-English read: **at 2,000 units the machine wants to retail near $600;
at 10,000 it can hit $449.** The single biggest lever is volume on the molded
parts and electronics. (These are estimate-grade numbers, ±15%, for deciding
strategy — real quotes come from the CMs below.)

### Cartridge cost (the recurring item)

| Per filled-ready empty cartridge | 50k/yr | 250k/yr | 500k/yr |
|---|---|---|---|
| Powder cartridge | $1.65 | $1.25 | $1.05 |
| Syrup cartridge (incl. aseptic bag) | $2.40 | $1.85 | $1.60 |
| Cleaning cartridge | $2.10 | $1.70 | $1.50 |

(Formula, filling, and co-packer margin add on top — typically $1.50–4.00
depending on ingredients. A $20–30 subscription price holds healthy margin.)

## 3. Who builds it

| Volume | Right manufacturing partner |
|---|---|
| 2,000 | A small-appliance contract manufacturer in Shenzhen/Dongguan/Zhuhai that already builds coffee/espresso machines (they know heaters, pumps, UL). Found and vetted through an NPI (new-product-introduction) firm — e.g., Dragon Innovation-style consultancies — rather than cold-calling. |
| 5,000–10,000 | Same class of CM, now with dedicated line time; second-source the cartridge molding separately (cartridges are pure high-volume molding — any good molder can run them; keep them out of the machine CM's scope for cost control). |
| Cartridge filling | A **21 CFR 111-registered supplement co-packer** with powder-fill and liquid aseptic lines (Phase 4 decision). The novel step — writing each lot's calibration number to the smart tag on the fill line — is a check-weigher + tag-writer station your engineers install at the co-packer (~$60–90k one-time). |

## 4. Highest-risk items for cost overrun or delay (watch these)

1. **UL testing of the heater system** — strictest timeline item: 3–4 months
   and any failure means re-spin + re-test. Mitigate: use a pre-certified
   heater module and engage the lab before tooling.
2. **The Ø47 cm carousel molding** — large-press parts have fewer supplier
   options and longer tool debug. Mitigate: quote 3 vendors now; design allows
   splitting into 2 bonded halves if needed.
3. **Aseptic bag supplier MOQ (~50k)** — fine at scale, heavy for first runs.
   Mitigate: launch flavors share one bag size.
4. **2.8" touchscreen supply** — display modules go end-of-life fast.
   Mitigate: qualify two interchangeable panels at design time.
5. **Tooling capital timing (~$300–340k)** — all spent before revenue.
   Mitigate: stage it — machine tools first, cleaning-cartridge insert tool
   can trail by a quarter (manual cleaning instructions as stopgap).
6. **Co-packer calibration station** — custom equipment, single point of
   failure for the ±2% accuracy promise. Mitigate: build two stations; the
   second doubles as your QA lab unit.

---

**✅ WHAT I NEED FROM YOU (simple version):**

1. **Pick a year-1 volume plan.** 2,000 (safest cash, ~$599 retail),
   5,000 (~$499–549 retail), or 10,000 (~$449–479 retail, biggest bet).
   This decides which factories we talk to and locks the target price.
2. **OK the tooling budget** — about $300–340k one-time to make all the
   molds, before the first machine is sold.
3. **OK the partner plan** — Chinese coffee-machine-class factory for the
   machine, separate molder for cartridges, licensed supplement co-packer
   for filling.
4. Then → Phase 6: the testing plan that proves the machine doses accurately
   and keeps formulas fresh, plus the full certification checklist.