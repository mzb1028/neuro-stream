# Neuro-Stream — Phase 4: Materials & Food-Safety Compliance

**Status:** Draft for founder sign-off
**Date:** 2026-07-09
**Scope:** food-contact material selection per part (FDA 21 CFR 177),
certification flags, cleaning/sanitation requirements.

> Not legal advice: final compliance sign-off belongs with a food-contact
> regulatory consultant before tooling kickoff. This phase specifies materials
> with clear regulatory pathways so that review is a formality, not a redesign.

---

## 1. Formula-contact and water-contact parts, material by material

### 1.1 Cartridge (formula contact — the critical set)

| Part | Material | FDA pathway | Notes |
|---|---|---|---|
| Shell + neck | Polypropylene (homopolymer, food grade) | **21 CFR 177.1520** (olefin polymers) | Choose a resin with supplier FCS letter of guarantee; natural (unpigmented) inner surface |
| Dosing screw / piston block, leadscrew | Acetal (POM) copolymer | **21 CFR 177.2470** | Standard for food-machinery gears/screws; low friction, no lubricant needed (any grease in the product path must be NSF H1, but the design needs none) |
| Outlet wiper / duckbill / check valves | Platinum-cured LSR silicone | **21 CFR 177.2600** (rubber articles, repeated use) | Platinum-cure only — peroxide-cured silicone leaves volatiles; verify extractables per 177.2600 (e) |
| Aseptic collapsible bag | PE sealant / EVOH barrier laminate | PE: **177.1520**; EVOH: **177.1360** | Standard aseptic bag-in-box stack; buy as a converted component from an aseptic-bag supplier with existing FDA compliance docs |
| One-way bag valve | PE/silicone | as above | OTS from same bag supplier |
| Foil induction seal | Alu/PE lamination | **177.1520** + GRAS aluminum | Industry standard |
| Desiccant puck (powder SKU) | Silica gel in Tyvek/PE housing | Indirect contact; use FDA-grade dessicant pack | OTS (Multisorb-class) |
| NFC tag inlay | — | **No product contact** — bonded to shell exterior | Keep it outside; zero compliance burden |

### 1.2 Machine water path (water contact)

| Part | Material | Pathway | Notes |
|---|---|---|---|
| Water tank | Eastman Tritan copolyester | FDA-cleared via Eastman FCNs | BPA-free story is also a marketing asset; dishwasher-safe |
| Tank poppet coupling | PP + EPDM O-ring | 177.1520 / 177.2600 | EPDM must be potable-water grade |
| Pump (wetted path) | Buy **food/potable-grade pump** (PP/EPDM wetted) | Supplier declaration | Spec at sourcing time — many diaphragm pumps are not potable-rated |
| Water tubing | Platinum-cured silicone | 177.2600 | High-temp rated (post-heater segment sees ~96 °C) |
| Inline heater wetted surface | 316L stainless steel | GRAS / accepted food-contact metal | Thick-film heaters with 316L flow tubes are standard coffee-machine parts |
| Flow meter body | PP/POM potable-rated | 177.1520 / 177.2470 | OTS potable-rated part |
| Venturi mixing manifold + spout | Tritan | Eastman FCNs | The one user-washed part; must survive 1000+ dishwasher cycles |

### 1.3 Machine parts near, but not touching, product

Docking cone (GF-PP), carousel (GF-PP), chassis (ABS), lid (PC): **no direct
product contact by design** — the cartridge's own outlet passes through the
cone and delivers into the venturi. Keeping these out of the food-contact set
is deliberate: glass-filled and flame-retardant grades are hard to clear for
contact, and this design never needs to.

### 1.4 One correction from Phase 2

The spline drive shaft was drafted as **303 stainless** (free-machining).
303's sulfur content makes it a poor food-adjacent choice; although the shaft
is nominally non-contact (annular, around the outlet), powder dust will settle
on it. **Changed to 316L, machined.** Cost delta ≈ +$0.40/unit. The .scad
comment will be updated when the model is next touched.

## 2. Certification & testing flags

| Requirement | Applies to | When |
|---|---|---|
| **UL/ETL 60335-2-15** (household water-heating appliances) | Whole machine (heater!) | Mandatory for US retail; the heater moved us from the simple motor-appliance category into this one. Budget $25–40k, 3–4 months, engage the lab at EVT stage |
| **FCC Part 15 + intentional radiator** | ESP32-S3 Wi-Fi/BLE | Use the module's existing modular certification to cut cost/time; still need end-product verification |
| **NSF/ANSI 42** (or NSF/ANSI 51 materials listing) | Water path | Not legally mandatory for a consumer countertop unit, but retailers (Costco/Williams-Sonoma/Amazon brand registry) increasingly ask; the materials above are chosen to pass without change |
| **FDA food-contact compliance file** | All §1 parts | Assemble Letters of Guarantee from every resin/component supplier pre-tooling; consultant review ≈ $8–15k |
| **CA Prop 65** | Whole product | Verify no listed substances (mind brass fittings — use none) |
| **Cartridge filling operation** | Your fill line / co-packer | This is the big one outside the device: filling ingestible cartridges is **dietary-supplement manufacturing under 21 CFR 111 cGMP** — FDA-registered facility, lot traceability, stability data. Choose a co-packer who already holds this; do not build it yourself for launch |
| Wellness-claims guardrail | App + marketing | Health-data-driven dosing stays "suggestions" (see Phase 3 §6.2) or FDA SaMD risk attaches |

## 3. Cleaning & sanitation design requirements

> **SUPERSEDED in part by §5 (founder-approved self-cleaning model,
> 2026-07-09).** The design rules at the end of this section still apply;
> the user-facing regimen table is replaced by §5.

The design's core sanitation argument: **every formula's wetted path is
disposable** (lives in the cartridge, replaced ~monthly), and the shared path
is exactly two things — the venturi manifold and the spout.

Resulting user-facing regimen (this becomes manual + app copy):

| Task | Frequency | How |
|---|---|---|
| Venturi manifold + spout | Weekly (or on ingredient-class change) | Twist off, top-rack dishwasher. Machine reminds via screen; interlock detects it missing and refuses to dispense |
| Self-rinse | Every serving | Automatic 20 mL hot flush (firmware, Phase 3) — this is why weekly (not daily) manual washing is defensible |
| Water tank | Weekly | Rinse; dishwasher-safe monthly |
| Drip tray / weigh platform | Weekly | Sink or dishwasher |
| Descale cycle | Every 3 months (hardness-adjusted) | Citric-acid cycle, screen-guided, ~15 min; firmware tracks liters-since-descale |
| Deep water-path sanitize | Every 6 months | Dilute NaOCl or percarbonate cycle + double rinse, screen-guided |
| Docking cone wipe | Monthly | Damp cloth; no disassembly |

Design rules locked by this phase:
- No shared surface that a *formula* touches except venturi + spout (both
  user-removable, dishwasher-safe, transparent so soiling is visible).
- No crevices <1 mm radius in any wetted molded part (mold spec).
- All wetted materials rated ≥ 100 °C (hot flush + dishwasher + descale chemistry).
- Silicone water lines replaceable as a service part without tools beyond a
  Phillips screwdriver (10-year serviceability posture).

---

## 5. AMENDMENT — Self-cleaning model (founder-approved 2026-07-09)

Founder requirement: **the user should never have to clean the machine.**
Adopted design:

- **11 carousel slots** (was 10): 10 ingredient cartridges + **1 dedicated
  slot for a cleaning cartridge**. Machine grows to Ø~47 cm.
- **Cleaning cartridge SKU** (3rd cartridge type): same body/neck/tag as
  ingredient cartridges; two chambers — food-safe detergent/sanitizer
  concentrate + citric-acid descaler. Ships in every subscription box.
  Machine reads the tag, knows when cleaning last ran, and prompts.
- **Overnight self-clean cycle** (~30 min, scheduled by user, runs unattended):
  hot detergent flush of venturi/spout/water path → soak → descale stage when
  needed → triple rinse. Effluent (~1–1.5 L) exits the normal spout into a
  **user-placed container that the load cell verifies is present and large
  enough before the cycle will start**. (Direct sink drain is a v2
  under-counter feature.)
- **Water-tank filter cartridge** (Brita-class, ~$2 BOM + consumable):
  cuts scale, stretches descale interval, improves taste.
- **Conductivity sensor** (~$1 BOM): measures actual water hardness so
  descaling is scheduled by need, not calendar.
- Residual user tasks: place a container the night a clean runs; rinse the
  drip tray occasionally. Everything else is automatic (including the 20 mL
  hot rinse after every serving).
- Firmware additions (annexed to Phase 3 spec): cleaning-cycle state machine,
  container-mass check, hardness-based descale scheduler, cleaning-cartridge
  tag handling, "won't dispense while cleaning-overdue > 2 weeks" nag policy.

---

**✅ SIGN-OFF STATUS (in the simplest terms):**

1. **The plastics and metals list (§1)** — which exact materials touch your
   formula and water. All of them are the kinds the FDA already recognizes
   for food use. **← needs your yes**
2. **The safety-testing plan and budget (§2)** — the machine gets tested by a
   safety lab (required because it heats water), the Wi-Fi gets registered,
   and cartridge filling is done by a company already licensed to make
   supplements. Total certification budget roughly $35–55k. **← needs your yes**
3. **Self-cleaning model (§5)** — **approved by you** (11 slots, cleaning
   cartridge, overnight cycle, tank filter, hardness sensor).
4. Then → Phase 5: manufacturing plan and tiered pricing.