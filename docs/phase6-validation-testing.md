# Neuro-Stream — Phase 6: Validation & Testing Plan

**Status:** Final phase — written for the approved path: MVP → 150-unit beta → scale
**Date:** 2026-07-10

Plain-English purpose: before anyone's health drink depends on this machine,
we prove three things — **it doses what it says, keeps ingredients good, and
is safe** — and we collect the paperwork stores and regulators ask for.

---

## 1. Dosing accuracy — proving ±2% from full cartridge to empty

**The claim being tested:** every serving is within ±2% of the target dose,
from the first serving of a new cartridge to the last one before empty, in
real kitchen conditions.

### 1.1 Bench protocol (runs on the MVP, repeats every design change)

1. Take 6 cartridges per SKU (powder + syrup + micro-dose later), from 2
   different production lots.
2. On a lab balance (0.001 g, calibrated), dispense the **smallest, middle,
   and largest allowed dose**, in rotation, until the cartridge is empty
   (~100–200 servings per cartridge).
3. Record every dose against the machine's own log (the machine believes vs.
   the balance knows).
4. **Pass:** ≥99% of doses within ±2%; no single dose beyond ±4%; no drift
   trend across cartridge life (regression slope statistically flat).
5. Repeat the whole matrix at: 15 °C/30 %RH, 25 °C/50 %RH, 32 °C/80 %RH
   (cold kitchen, normal kitchen, humid summer kitchen) — humidity is the
   powder killer, so it gets tested explicitly.
6. Repeat after the machine has run a 10,000-serving endurance cycle
   (motors/spline wear) and after 50 self-clean cycles (chemical exposure).

### 1.2 Temperature accuracy (±2 °F)

Thermocouple at the spout (not the machine's own sensor): 30 servings across
set-points 100–205 °F, three ambient temps, tank cold-start and warm.
**Pass:** 95% of servings within ±2 °F at the spout, all within ±3 °F.

### 1.3 What the 150 beta machines add (the real-world layer)

Every beta unit logs anonymized telemetry: dose commanded vs. load-cell
verified, StallGuard signatures, water hardness, cleaning compliance, faults.
150 kitchens × 12 weeks ≈ **>100,000 real servings** — this is the dataset
that catches what the lab can't (weird water, cold garages, curious kids,
never-cleaned units), and it becomes the accuracy-claim evidence file.

## 2. Formula stability — proving ingredients stay good inside the machine

**The claim:** an opened cartridge in the machine stays potent, safe, and
in-spec for its printed in-use life (target 60 days powder / 30 days liquid).

Per formula SKU (run by the co-packer's lab or a contract lab, ~$8–15k/SKU):

1. **Real-time in-device test:** cartridges installed in machines dispensing
   2 servings/day. Pull samples at day 0/7/14/30/45/60 and test:
   - **Potency:** active-ingredient assay ≥90% of label through end of life.
   - **Micro:** total plate count, yeast/mold, and for the preservative-free
     liquids a full **sterility hold** — the aseptic bag + one-way valve must
     show zero growth to end of life. This is the make-or-break test for the
     no-preservatives decision.
   - **Powder moisture:** Karl Fischer ≤5% throughout (validates the desiccant
     + wiper-seal design).
   - **Physical:** no caking/bridging (dose accuracy is re-checked on aged
     cartridges — stability and dosing tie together).
2. **Accelerated test (early warning):** same measurements at 40 °C/75 %RH
   for 4 weeks ≈ rough proxy for 3–4 months ambient. Run first, before
   betting real-time months on a formula.
3. **Cleaning-residue check:** after a self-clean cycle, swab + rinse-water
   assay for detergent/descaler residue at the spout. **Pass:** below
   food-code limits (this validates the triple-rinse firmware).
4. **Abuse cases:** cartridge left in a hot car (50 °C, 48 h) then used;
   machine unplugged 2 weeks mid-cartridge; tank water stagnant 1 week
   (micro test of first serving after). Each gets a defined pass or a
   firmware guard (e.g., stagnant-water auto-flush — already in spec).

## 3. Certificates & approvals needed before retail (the checklist)

| What | Who does it | Cost | When on your path |
|---|---|---|---|
| **Electrical safety (UL/ETL 60335-2-15)** — mandatory; it heats water | UL, Intertek, or TÜV lab | $25–40k, 3–4 mo | Start pre-review on the polished prototypes; formal cert on soft-mold units |
| **FCC (Wi-Fi/BLE)** | Test lab (uses the ESP32 module's existing cert) | $5–10k | Same time as UL |
| **FDA food-contact file** — proof every wetted material is food-legal | Regulatory consultant assembles supplier letters | $8–15k | Before cartridge molds are cut (letters gathered during sourcing) |
| **Supplement filling under 21 CFR 111 (cGMP)** | Your co-packer already holds it; you audit them | Audit ~$5k | Before first sellable cartridge |
| **Formula stability data (§2)** | Contract lab / co-packer lab | $8–15k per formula | Accelerated during beta; real-time before retail |
| **NSF/ANSI 42 water-path listing** — voluntary, retailers like it | NSF | $10–20k | After steel-tool units exist; not needed for beta/early-adopter sales |
| **CA Prop 65 review** | Same regulatory consultant | ~$3k | With the FDA file |
| **Wellness-claims legal review** — app suggestions stay "wellness," not medical | Healthcare/FDA attorney | $5–10k | Before the app ships wearable-driven suggestions |
| **Insurance (product liability)** | Broker | ~$15–30k/yr premium | Before any unit leaves your hands — including beta loaners |

**Total certification + validation budget through retail launch: ≈ $90–150k**
(consistent with the ~$35–55k Phase 4 core-cert figure plus stability
science, legal, and NSF).

### What each stage of your path must clear before the next

- **MVP → beta:** §1.1 bench dosing pass + §1.2 temperature pass + §2
  accelerated stability pass on launch formulas + basic electrical safety
  pre-review (lab looks at the design before you build 150 of anything).
- **Beta → soft-mold sales run:** beta telemetry confirms ±2% in the field;
  UL/ETL formal testing underway; FDA materials file complete; co-packer
  audited; insurance active.
- **Sales run → steel-tool scale:** UL/ETL granted; real-time stability
  complete on all shipping formulas; NSF listing filed; claims legal review
  done.

---

## Program status: ALL SIX PHASES DELIVERED

| Phase | Deliverable | Status |
|---|---|---|
| 1 — Concept & mechanism | Architecture B smart cartridges | ✅ signed off |
| 2 — Parametric CAD | `cad/neuro-stream.scad` + renders | ✅ signed off (11 slots, water system) |
| 3 — Electronics & firmware | ESP32-S3, ±2 °F control, error matrix | ✅ signed off (+connected-product amendments) |
| 4 — Materials & food safety | 21 CFR 177 sourcing spec, self-clean model | ✅ signed off |
| 5 — Manufacturing & pricing | DFM, tooling, tiers from MVP to 10k units | ✅ signed off (path a: MVP → beta → scale) |
| 6 — Validation & testing | This document | **← needs your final yes** |

**Final sign-off (simple version):** do you approve this testing plan — the
dosing tests, the freshness tests, the certificate checklist, and the
gates between MVP → beta → sales run → scale? Say yes (or ask for changes)
and the engineering program is complete and handoff-ready.