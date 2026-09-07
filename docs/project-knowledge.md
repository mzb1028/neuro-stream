# Neuro-Stream — Complete Project Knowledge File

*Self-contained summary of the entire engineering program. Drop this file into
any workspace (Claude Project, Notion, investor data room) and the reader has
the whole picture. Full detail lives in the repo:
https://github.com/mzb1028/neuro-stream — status as of 2026-09-07.*

---

## 1. What Neuro-Stream is

A countertop smart-cartridge dispenser for functional powders and liquid
formulas. It builds a personalized drink in about a minute: meters up to
**4 ingredients per serving to ±2%** accuracy, dissolves them in-line in
water heated to **±2 °F** of the recipe setpoint, verifies every dose on a
built-in scale, and cleans itself overnight.

**Program status: complete.** All six engineering phases founder-signed
(final sign-off 2026-07-10), plus a hands-on MVP build pack (wiring,
plumbing, parts list, build order) added afterward.

### Key specs

| Spec | Value |
|---|---|
| Cartridge slots | 11 (10 ingredients + 1 self-cleaning cartridge) |
| Cartridge capacity | 1 L / ~1 kg-class each, shipped pre-filled |
| Ingredients per drink | up to 4 |
| Dose accuracy | ±2%, factory-calibrated per cartridge, scale-verified |
| Water temperature | ±2 °F (±1.1 °C) at the spout, per-recipe setpoint |
| Water tank | ~3.5 L, removable |
| Footprint | Ø 47 cm countertop |
| Controller | ESP32-S3; Wi-Fi/BLE, NFC, touchscreen; fully offline-capable |
| Power | Mains (1200 W inline heater rules out battery) |
| Target retail | $499–549 at 5,000-unit production |

## 2. The architecture (Phase 1 decision)

Three architectures were traded off:

- **A — machine-side mechanisms per media type**: rejected ($600+ BOM, 10
  cleanable food paths, sanitation nightmare).
- **B — smart cartridges with integrated positive displacement** ✅ chosen:
  each cartridge carries its own media-specific metering element (dosing
  screw for powders, piston pump for liquids in sterile no-preservative
  bag-in-box) behind a common docking interface, driven by ONE shared machine
  motor. Factory calibration per cartridge, stored on its NFC tag.
- **C — gravimetric closed-loop**: kept as a *verification* layer only — a
  load cell under the glass checks every dose rather than controlling it.

Why: no single mechanism meters both cohesive powder and 5,000 cP syrup to
±2%; putting food-contact complexity in the replaceable cartridge (the
Keurig/Bartesian/Cana pattern) keeps the machine clean and cheap.

**Dose envelope** the machine is specified against: P1 micro powders
0.25–2 g, P2 standard powders 2–15 g, L1 thin liquids 0.5–10 mL (≤500 cP),
L2 syrups 5–50 mL (≤20,000 cP). Concentrated actives must be pre-diluted in
carrier by the formulator.

## 3. Mechanical design (Phases 2 + deep dive)

- **Layout**: 11 cartridges on a rotating carousel around a central removable
  water tank; hinged clear lid; front dispense bay with touchscreen; drive
  motor, pump, heater, and PCBA in the base.
- **Powder cartridge internals**: hopper cone with rotating sweeper arms
  (prevents bridging/rat-holing), precision dosing screw, silicone duckbill
  outlet seal. Delivery is per-revolution, calibrated at fill time.
- **Liquid cartridge internals**: leadscrew-driven piston pulling from an
  aseptic bag (no preservatives needed), one-way valves; the engineering risk
  is re-priming after idle, not dosing.
- **Mixing**: doses drop dry into a venturi/swirl manifold; heated water
  enters the cone **tangentially (off-center)** so it spins — a straight-in
  inlet dribbles down one wall and clumps powder. Dissolution happens in the
  stream, not in the glass.
- **CAD**: fully parametric OpenSCAD — `cad/neuro-stream.scad` (whole
  machine, with `explode`/`cross_section`/`lid_open` flags),
  `cad/cartridge-metering.scad`, `cad/venturi-manifold.scad`. 20+ renders in
  `cad/renders/`.
- **One precision metal part**: the drive spline shaft, CNC 316L stainless
  (corrected from 303 during the materials review), ~$3.80/pc.

## 4. Electronics & firmware (Phase 3)

- **MCU**: ESP32-S3 (Wi-Fi + BLE on module). Drives: 2× stepper (TMC2209
  with StallGuard jam detection — cartridge drive + carousel), 12 V
  diaphragm pump (MOSFET), 1200 W inline heater via zero-cross SSR, flow
  meter, 2× NTC (spout tee + heater body), 1 kg load cell + HX717, PN532
  NFC at the dock collar, 2.8" IPS SPI touchscreen, hall/reed position
  switches.
- **Dispense state machine**: identify cartridge (NFC) → rotate to dock →
  dose (steps from stored calibration) → scale verification → next
  ingredient → heat/mix water pass → done. Error matrix covers jams
  (StallGuard), empty cartridge, no glass, boil-dry.
- **Thermal control**: feed-forward + PI on the spout NTC hits ±2 °F;
  firmware boil-dry guard (flow < 2 g/s → heater off) plus hardware chain:
  GFCI → 2 thermal cutoffs in series → SSR → hardware watchdog that kills
  heat if firmware hangs.
- **Connected product (founder amendment)**: auto-reorder from cartridge
  fill-level telemetry; wearable integration drives recipe *suggestions*
  (wellness framing, not medical); **offline-first** — every function works
  with no phone present.
- Electronics BOM ≈ $83/unit at 5k volume.

## 5. Materials & food safety (Phase 4)

- Cartridge wetted parts: Tritan shells, POM screw/piston, platinum-cured
  LSR seals/valves, aseptic PE bag — all FDA food-contact grades with
  supplier letters collected into an FDA food-contact file.
- Machine water path: Tritan tank and manifold, silicone tube, 316L wetted
  heater.
- **Self-cleaning model (founder-approved)**: slot 11 holds a cleaning
  cartridge; machine runs an overnight rinse/sanitize cycle through the
  full wet path. Design requirement: no dead legs, all wetted surfaces
  flushable.
- Certifications flagged: UL/ETL 60335-2-15 (mandatory — it heats water),
  FCC (module-based), FDA food-contact file, NSF/ANSI 42 (voluntary),
  CA Prop 65, 21 CFR 111 cGMP filling via co-packer.

## 6. Manufacturing & cost (Phase 5)

**Tooling (Asia)**: machine ≈ $180–225k, cartridges ≈ $117k → **program
total ≈ $300–340k** one-time (1.7–2× if tooled in the US). This is the
capital gate.

**Machine build cost / suggested retail** (±15% estimate grade):

| Year-1 volume | Build cost | Landed (+12%) | Retail (≈3×) |
|---|---|---|---|
| 2,000 | ≈ $188 | ≈ $211 | $599–649 |
| 5,000 | ≈ $158 | ≈ $177 | **$499–549** |
| 10,000 | ≈ $139 | ≈ $156 | $449–479 |

**Small batches (100–1,500 units)** skip steel tools: MJF/SLS-printed or
CNC enclosures at 100–500 units, soft aluminum molds at 500–1,500. The one
exception: **cartridge food-contact parts can never be 3D printed** — soft
cartridge molds (~$50–65k) are unavoidable even for a 100-unit pilot.
Aseptic bags come from a bag-in-box supplier (MOQ ~50k).

**Approved commercialization path**:
MVP ($55–105k) → 150-unit beta (~$220k) → 1,000–1,500 soft-mold run →
steel tooling + 5,000-unit production run.

## 7. Validation & certification (Phase 6)

- **Dosing protocol**: full-to-empty cartridge runs on the bench MVP,
  repeated on every design change; every dispense logs a CSV row — the logs
  are the evidence file for the beta gate and investors.
- **Temperature protocol**: spout-thermocouple verification across
  setpoints and tank temperatures.
- **150-unit beta adds** real-world variation: homes, water hardness, user
  abuse, formula stability in the machine.
- **Formula stability**: accelerated studies during beta, real-time before
  retail ($8–15k per formula).
- **Certification budget through retail: ≈ $90–150k** (UL $25–40k, FCC
  $5–10k, FDA file $8–15k, NSF $10–20k, legal reviews, product-liability
  insurance ~$15–30k/yr — required before even beta loaners ship).
- Stage gates: MVP must pass bench dosing + temperature before beta; beta
  must pass stability + formal certs before soft-mold run.

## 8. The MVP (buildable today)

Deliberately **one dispense station with hand-swapped cartridges** — the
rotating ring is proven engineering that adds prototype cost without
reducing risk. ~$1,150 in parts (~$700 electronics/hardware + ~$450 printed
parts), ~2 weekends of assembly.

Build order, risk-first:
1. **Dry powder dosing** — no water, no mains; alone proves ±2%
2. **Cold water + swirl cone** — proves in-line dissolution
3. **Smart tags** — NFC identity + calibration
4. **Heat, last** — only after the full hardware safety chain is wired

Three of four stages need no mains wiring; a pre-built inline heater or an
appliance tech can cover the fourth. Full parts list, ESP32 pin map,
assembly order, firmware starting points, and pass/fail criteria:
`docs/mvp-build-spec.md`. Every-wire schematic and every-tube plumbing
diagram: `docs/diagrams/mvp-wiring.png`, `docs/diagrams/mvp-plumbing.png`.

## 9. Where everything lives

| Asset | Location |
|---|---|
| Repository (single source of truth) | https://github.com/mzb1028/neuro-stream |
| Phase docs 1–6 | `docs/phase1…phase6…*.md` |
| Metering/venturi deep dive | `docs/design-metering-venturi.md` |
| MVP build spec | `docs/mvp-build-spec.md` |
| Parametric CAD (OpenSCAD) | `cad/*.scad`, renders in `cad/renders/` |
| Schematics & diagrams | `docs/diagrams/` (SVG sources + PNG) |
| MVP Build Pack web page | live: https://claude.ai/code/artifact/5ff84554-1ebf-416a-b2bb-9e4c18771d7c · archived: `docs/mvp-build-pack.html` |

## 10. Open items / watch list

- Founder to confirm the dose envelope holds for the launch formula set.
- Highest cost/delay risks (Phase 5): the ≥650-tonne press for the Ø47 cm
  carousel ring (few vendors — quote early), aseptic bag MOQ, UL timeline
  (3–4 months — start pre-review on polished prototypes).
- Wellness-claims legal review required before the app ships
  wearable-driven suggestions.
