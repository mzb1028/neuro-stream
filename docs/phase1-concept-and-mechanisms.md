# Neuro-Stream — Phase 1: Concept & Mechanism Logic

**Status:** Draft for founder sign-off
**Date:** 2026-07-08

---

## 1. Design inputs (as agreed, with gaps filled by stated assumptions)

| Parameter | Value | Source |
|---|---|---|
| Use context | Consumer countertop, home/on-the-go, zero technical skill | Founder |
| Dosing accuracy | ±2% of target dose per serving | Founder |
| Formula forms | **Both dry powder and liquid**, varying per cartridge | Founder |
| Cartridge count | **Up to 10 independent cartridges**, shipped to user pre-filled | Founder |
| Cartridge capacity | Up to 1 L (or 1 kg-class for powder) each | Founder |
| Dose per serving | Varies by ingredient — see proposed dose envelope (§2) | Founder ("depends") |
| Storage/refrigeration | Unknown — recommendation in §3 | Founder ("advise me") |

> **Open item:** Founder will supply a concept sketch/picture. Phase 2 CAD will be
> reconciled against it before modeling starts.

### 1.1 What "up to 10 cartridges, powder AND liquid" forces on the design

1. **You cannot afford 10 machine-side precision mechanisms.** Ten motors, ten
   pumps, ten cleanable food-contact paths is a $600+ BOM and a sanitation
   nightmare. Every credible multi-ingredient consumer machine (Keurig,
   Bartesian, Cana) solves this by putting the food-contact complexity in the
   **disposable/replaceable cartridge** and keeping one shared drive in the machine.
2. **Powder and liquid need different metering physics.** No single mechanism
   meters both a cohesive powder and a 5,000 cP syrup at ±2%. The system must
   either (a) run two parallel subsystems, or (b) make the *cartridge* carry the
   media-specific metering element behind a *common mechanical interface*.
3. **±2% across varying particle sizes and viscosities** rules out any open-loop
   mechanism whose delivery-per-actuation depends on the bulk properties of the
   formula — unless each cartridge is factory-calibrated for its specific fill.

## 2. Proposed dose envelope (needs your confirmation)

Since dose "depends on what is being dosed," the machine must be specified
against an envelope. Proposed ingredient classes:

| Class | Form | Dose range | ±2% means | Notes |
|---|---|---|---|---|
| P1 — micro powder | Powder | 0.25–2 g | ±5–40 mg | Concentrated actives (e.g., caffeine blends **pre-diluted in carrier** — see safety note) |
| P2 — standard powder | Powder | 2–15 g | ±40–300 mg | Typical nootropic/greens/creatine-class servings |
| L1 — thin liquid | Liquid | 0.5–10 mL | ±10–200 µL | Tinctures, flavor/active concentrates, ≤ ~500 cP |
| L2 — syrup | Liquid | 5–50 mL | ±0.1–1 mL | Sweetener/functional syrups, up to ~20,000 cP |

**Formula limits the device will impose** (state these to your formulator):

- **Powders:** moisture < 5%, free-flowing to moderately cohesive
  (Carr index ≤ ~25 preferred), particle size D50 ≈ 100–800 µm, oil/fat
  content < ~5% (sticky powders bridge and smear). Hygroscopic powders
  allowed only with desiccant cartridge + wiper-sealed outlet.
- **Liquids:** 1–20,000 cP at 20 °C, no particulates > 0.5 mm, no
  carbonation, must tolerate the cartridge's in-use life at ambient.
- **Safety-by-formulation:** any active where a 2× overdose is harmful must be
  diluted in carrier so that a full-mechanism-fault dose is still safe.
  A consumer device cannot be the sole overdose safeguard.

## 3. Refrigeration & environmental protection — recommendation

**Recommend: design the machine ambient-only and make shelf stability a
formulation/cartridge requirement, not a device feature.**

- Onboard refrigeration (thermoelectric or compressor) adds roughly $40–80 BOM,
  ~2–4 L of enclosure volume, continuous 30–60 W draw (kills any battery
  option), condensation management inside a powder machine (bad), and drives
  you toward compressor reliability/warranty issues. Cana's cooled multi-liquid
  machine ended up at a ~$500–900 price point partly for this reason.
- Instead, protect the formula **in the cartridge**:
  - **Powder cartridges:** integrated desiccant chamber, foil induction seal
    pierced at install, elastomer wiper seal on the outlet so ambient humidity
    can't wick up the dispense path between doses.
  - **Liquid cartridges:** collapsible inner bag (bag-in-shell) so no air
    headspace forms as it empties — this addresses oxidation without nitrogen
    hardware; opaque shell handles light sensitivity.
  - **In-use life** (time from install to empty) becomes a cartridge spec, e.g.
    30–60 days at 15–30 °C / ≤ 60% RH. Your formulator validates each formula
    against it (Phase 6 has the test protocol).
- If a future formula genuinely requires cold chain, that becomes a v2 chilled
  bay variant — don't tax every unit for it.

---

## 4. Three mechanism architectures

### Architecture A — Machine-side dedicated mechanisms per media type
*(bank of mini-augers for powder slots + peristaltic pumps for liquid slots)*

Cartridges are dumb containers; the machine owns all metering. Powder slots get
a stainless auger + agitator each; liquid slots get a peristaltic pump each
(tubing is the only food-contact pump part). A slot is factory-configured or
user-configured as powder or liquid.

**Dosing accuracy path:** auger dose = flights × fill fraction; step-count the
motor. Fill fraction varies with powder cohesion, humidity, and fill level →
open-loop auger accuracy is realistically ±3–8% for varying powders; hitting
±2% requires per-formula calibration *and* stable powder properties, or weight
feedback. Peristaltic is ±1–2% when tubing is fresh but drifts 5–10% as tubing
takes compression set over weeks.

**Pros for your formula set**
- Handles both media with proven, well-understood mechanisms.
- Cartridges are cheap dumb bottles → lowest recurring cost per fill.
- Peristaltic keeps liquid inside disposable tubing — decent hygiene story for liquids.

**Cons**
- **10 mechanisms:** even with clever clutching, this is the highest machine BOM
  and part count of the three.
- Powder path (auger, chute) is machine-side food contact → user must
  disassemble and wash 10 metering assemblies; cross-contamination between
  refills; allergen carryover risk.
- Auger accuracy on *varying* powders won't reliably hit ±2% open-loop.
- Peristaltic tubing is a wear item the consumer must replace on schedule.

**Rough part count / complexity:** ~10 motors (or 1–2 motors + 10-way clutch,
which is its own complexity), ~25–35 parts per powder slot, ~15–20 per liquid
slot → **300+ parts total**, high.

**Food-contact materials:** 316/304 SS or acetal (POM) augers, PP/Tritan
hoppers, platinum-cured silicone peristaltic tubing (all 21 CFR 177-coverable —
detail in Phase 4).

**Failure modes:** powder bridging/rat-holing in hoppers; auger clogging with
hygroscopic caking; peristaltic tube fatigue → drift then rupture; humidity
ingress into open machine-side powder path; cleaning non-compliance by users
(the biggest real-world failure).

---

### Architecture B — Smart cartridges with integrated positive-displacement
metering + one shared machine drive **(recommended)**

Each cartridge contains its own media-matched metering element behind a
**standardized drive interface** (a spline/dog-clutch socket in the cartridge
base). The machine has **one** drive motor that reaches each cartridge —
either the cartridges sit on a rotating carousel over a fixed drive/dispense
station, or a small gantry carries the drive head across a fixed cartridge rack
(decided in Phase 2 against your sketch).

- **Powder cartridge:** molded auger/dosing-screw integral to the cartridge,
  with a slow agitator flight above it (same shaft), foil seal, outlet wiper.
- **Thin-liquid cartridge:** miniature piston/diaphragm dosing element or
  rotary dosing valve, fed by the collapsible bag.
- **Syrup cartridge:** progressive-cavity or larger-bore piston element (the
  interface torque budget is sized for worst-case viscosity).
- Each cartridge carries an **NFC/QR tag** with: ingredient ID, lot,
  **factory-measured calibration constant (g or mL per drive revolution for
  that exact fill lot)**, max dose per serving, expiry, doses-dispensed counter.

**Dosing accuracy path:** positive displacement + per-lot factory calibration
removes the "properties vary" problem — the calibration constant is measured
*with the actual formula in the actual cartridge design* at fill time. Motor
step-counting delivers the dose. Because the metering element is **new with
every cartridge**, wear-related drift resets every ~1 L. Expected: ±2–3%
open-loop; ±2% is met by (a) tightening cartridge molding tolerances on the
metering chamber, and (b) the gravimetric trim described in §5. Fill-level
dependence is handled by the agitator (powder) and collapsed bag (liquid).

**Pros**
- **One motor, near-zero machine-side food contact.** The user never cleans a
  metering mechanism — they recycle it with the cartridge. This is the only
  architecture where "no technical knowledge required" survives contact with
  10 ingredients.
- Cross-contamination and allergen carryover structurally eliminated (each
  formula's entire wetted path is its own cartridge; only the last ~10 mm of
  drop path is shared and is a removable, dishwasher-safe funnel).
- Powder vs. liquid is solved per-cartridge-SKU, invisible to the machine.
- Per-lot calibration is a genuinely strong accuracy story for a formula whose
  particle size and viscosity vary batch to batch.
- Business model alignment: cartridges are already being shipped to users.

**Cons**
- Cartridge unit cost carries the mechanism: roughly **$0.40–1.20 added COGS
  per cartridge** at volume (molded auger or piston element + seals + tag).
- Requires real injection-mold tooling investment for 2–3 cartridge variants
  before revenue (mitigate: launch with powder + one liquid variant).
- Filling line must include a calibration/check-weigh station.
- Drive interface (spline + docking) needs careful tolerance work — it's the
  one precision machine-side part.

**Rough part count / complexity:** machine ≈ **60–90 parts** (1 drive motor +
gearbox, carousel or gantry with 1–2 cheap positioning motors, load cell,
electronics, enclosure); cartridge ≈ 6–9 parts each (shell, bag or agitator,
metering element, seals, foil, tag, cap). Medium overall — complexity is
shifted into high-volume molded disposables, which is where manufacturing is
cheapest.

**Food-contact materials:** cartridge shell PP or PET, metering screw/piston
POM or PP, seals platinum-cured silicone or TPE, bag PE/EVOH laminate — all
mainstream 21 CFR 177 materials (Phase 4).

**Failure modes:** powder caking if user stores machine in high humidity
(mitigated by desiccant + wiper seal); mold-to-mold variation in metering
chamber volume (mitigated by per-lot calibration, which absorbs it); drive
spline wear (machine side, hard-anodized or SS, 10k-cycle rated); counterfeit
or refilled cartridges dosing wrongly (mitigated by signed NFC tags); tag
read failure (fail-safe: refuse to dispense, never guess).

---

### Architecture C — Gravimetric closed-loop
*(crude dispense mechanisms + precision load cell; accuracy from measurement,
not metering)*

Any cheap dispense method (coarse auger, pinch valve on gravity-fed liquid)
runs in closed loop against a load cell under the user's glass: dispense fast
to ~90% of target, then pulse in dribble mode until the scale reads the target.

**Dosing accuracy path:** accuracy = scale accuracy. A consumer-grade load
cell + 24-bit ADC (HX711-class) realistically holds ±0.1 g in a kitchen
environment (vibration, thermal drift, someone bumping the counter).
**±2% is therefore only achievable for doses ≥ ~5 g.** Class P1 (0.25–2 g)
and L1 low-end (0.5 mL) fail the spec outright. Liquids also drip/string after
cutoff, corrupting the endpoint.

**Pros**
- Totally agnostic to formula changes — no per-lot calibration, self-corrects
  bridging and partial clogs, inherently detects jams and empty cartridges.
- Cheapest cartridges of the three (dumb containers).
- The load cell doubles as a UX feature ("add 200 mL water… done").

**Cons**
- **Cannot meet ±2% below ~5 g** → fails your micro-dose classes.
- Slow: dribble-mode endpoint approach adds 5–20 s per ingredient × up to 10
  ingredients per drink.
- Requires the user's vessel on the scale, correctly placed, undisturbed —
  fragile against exactly the "no technical knowledge" user you're targeting.
- Still needs 10 crude dispensers with machine-side food contact (Architecture
  A's cleaning problem returns, just with cheaper mechanisms).

**Rough part count / complexity:** ~200+ parts (10 crude dispensers + scale
station). Medium-high.

**Food-contact & failure modes:** as Architecture A for the dispense path;
plus load-cell drift, tare errors, vibration sensitivity, drip-after-cutoff.

---

## 5. Recommendation: Architecture B, with a load cell as a verification layer

**Primary metering: cartridge-integrated positive displacement (B).
Secondary: a load cell under the dispense station used not for control but for
*verification and drift/jam detection* on doses ≥ ~5 g (a de-contented C).**

Justification against the alternatives:

1. **Only B meets ±2% across the whole dose envelope.** C's physics caps it at
   ~5 g minimum. A's open-loop auger can't hold ±2% on powders whose particle
   size and cohesion vary — and your formula characteristics explicitly vary.
   B converts that variability from a machine problem into a fill-line
   calibration measurement, which is where you can actually control it.
2. **Only B survives the consumer-simplicity requirement at 10 ingredients.**
   A and C both leave 10 food-contact metering paths in the machine that a
   non-technical user must clean correctly, repeatedly, forever. Field data
   from every appliance category says they won't. B's user-facing sanitation
   burden is one dishwasher-safe drop funnel.
3. **Cost lands in the right place.** A puts ~$300+ of mechanisms in a machine
   you sell once (probably at a loss). B puts ~$1 of mechanism in a cartridge
   you sell every month — and injection-molded disposables at volume are the
   cheapest precision parts in existence.
4. **The load-cell layer buys back C's best property cheaply** (~$4 of BOM):
   every ≥5 g dose is check-weighed, so the machine detects clogs, exhausted
   cartridges, and calibration drift, logs accuracy for QA/regulatory
   evidence, and can flag "cartridge underdelivering — replace" instead of
   silently mis-dosing. Small doses rely on positive displacement + factory
   calibration alone, which is exactly where positive displacement is
   strongest.

**Cost of this choice, stated plainly:** upfront cartridge tooling
(~$80–250k across 2–3 cartridge variants before launch) and recurring
cartridge COGS. If that capital doesn't exist, the fallback is Architecture A
reduced to **3–4 slots** with a relaxed accuracy spec (±5%) on powders — but
that is a different product. Recommendation stands on B.

### Carry-forward decisions for Phase 2 (CAD)

- Carousel vs. gantry cartridge presentation — **decide against your sketch**
  (please attach it with your sign-off).
- Standard drive interface geometry (spline profile, docking float, torque cap).
- Cartridge variant set for launch: P2 powder + L2 syrup first; P1/L1 second.
- Shared drop-funnel geometry and its removal/cleaning gesture.

---

**⏸ STOP — awaiting founder sign-off on:**
1. Architecture B (+ load-cell verification) as the mechanism direction
2. Dose envelope classes P1/P2/L1/L2 (§2) and the formula limits
3. Ambient-only storage strategy (§3)
4. Launch cartridge set (P2 + L2 first)
