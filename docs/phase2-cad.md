# Neuro-Stream — Phase 2: Parametric CAD Model

**Status:** Draft for founder sign-off
**Date:** 2026-07-09
**Model:** [`cad/neuro-stream.scad`](../cad/neuro-stream.scad) (OpenSCAD 2021.01+)
**Renders:** [`cad/renders/`](../cad/renders/)

---

## 1. Layout decision: carousel, not drawer rack (for v1)

Phase 1 left the cartridge-presentation question open. Decided: **rotating
carousel** for the countertop v1.

- 10 × Ø80 mm cartridges in a straight rack (as in your renders) makes a
  ~950 mm-wide machine — a drawer works under a counter, not on one.
- A carousel packs the same 10 stations into a **Ø~440 mm, ~465 mm tall**
  cylinder — large-blender footprint.
- It needs only **one docking/drive station**: the carousel rotates the chosen
  cartridge over it. One drive motor + one cheap indexing motor serve all 10
  stations, which is the whole point of Architecture B.
- Your 4-ingredient recipe requirement is sequential: index → dock → dispense,
  four times. At ~5–16 s per ingredient plus ~1.5 s indexing, a 4-ingredient
  serving takes **~30–60 s**.
- The v2 under-counter drawer keeps the identical cartridge and docking-cone
  interface — only the presentation mechanism changes.

## 2. What's in the model

Open `cad/neuro-stream.scad`. Every dimension is a named variable at the top;
the geometry re-derives when you change them. Highlights:

| Variable | Value | What it controls |
|---|---|---|
| `n_stations` | 10 | Cartridge count — set 6 and the whole machine shrinks into a compact SKU |
| `cart_od` / `cart_h` | 80 / 220 | Cartridge envelope (≈1 L net) |
| `spline_d`, `spline_clr` | 10, 0.15 | The standard drive interface and its fit |
| `aug_*` | 16/8/8 | Powder dosing screw → ≈0.65 g/rev |
| `pist_id`, `pist_lead` | 20, 4 | Syrup piston pump → ≈1.26 mL/rev |
| `explode` | 0–1 | Exploded-view slider |
| `cross_section` | bool | Half-section through internals |

**View controls:** `explode=1` for the exploded assembly, `cross_section=true`
for a half-section, `show_*` flags to isolate subsystems. Render from CLI:

```
openscad -o out.png --imgsize=1200,900 --camera=0,0,230,65,0,35,1500 \
         -D explode=1 cad/neuro-stream.scad
```

## 3. Key tolerances and why (also commented in the model)

| Feature | Tolerance | Rationale |
|---|---|---|
| Spline socket↔shaft | 0.15 mm diametral | Absorbs POM molding variation (±0.05 mm typ.) + carousel positioning error while keeping rotational backlash <2°, so step-count dose error from lash stays <0.1% of one revolution |
| Docking cone seat | +0.2 mm on neck | Slip fit that still centres the outlet within ±0.3 mm over a 12 mm funnel throat |
| Carousel station bore | +0.4 mm on neck | Deliberately loose drop-in fit — a consumer must never have to aim; precision location comes from the cone, not the plate |
| Docking capture range | ±2.5 mm | Cone mouth vs. neck: the indexing motor + molded ring gear only need to be this accurate, so no precision gearing anywhere |
| Cartridge shell wall | 1.6 mm PP | PP flow-length sweet spot: <1.2 mm short-shots on a 220 mm part, >2.5 mm sinks and adds cycle time |
| Metering chamber (screw OD/bore) | ±0.05 mm (mold spec, SPI A-2 cavity) | Chamber volume variation is the largest open-loop dose error source; ±0.05 on Ø16 ≈ ±0.6% volume, leaving budget inside ±2% — and per-lot fill-line calibration absorbs the systematic part |

## 4. Dose math sanity check (±2% feasibility)

- **Powder (P2):** 0.65 g/rev; NEMA17 at 200 steps/rev through 1:5 gearing →
  0.65 mg per full step. A 5 g dose = ~7.7 rev = 5 s at 90 rpm. Quantization
  error is negligible; accuracy is governed by fill-fraction repeatability,
  which the agitator + per-lot calibration constant handle.
- **Syrup (L2):** 1.26 mL/rev → 30 mL ≈ 24 rev ≈ 16 s. Check-valve pair
  re-primes the piston from the aseptic bag; the one-way valve means no air
  ever back-fills the bag (founder's preservative-free requirement).
- **Micro-dose (P1, later):** same architecture with a smaller screw
  (`aug_barrel_id=8, aug_pitch=4` → ~0.08 g/rev, 1.25 rev minimum dose).

## 5. Part → manufacturing process map

### Machine (sellable unit)

| Part | Qty | Process | Notes |
|---|---|---|---|
| Chassis skirt + tower shells | 2 | **Injection mold** (ABS) | Largest tools in the program; texture spec MT-11010 |
| Internal deck plate | 1 | **Sheet metal** (1.5 mm galv.) | Flat + stiff + cheap at launch volume; convert to a 3rd molding above ~20k units/yr |
| Carousel plate w/ molded ring gear | 1 | **Injection mold** (30% GF-PP) | Molded gear is fine — cone does final location |
| Docking cone | 1 | **Injection mold** (GF-PP) | |
| Drive spline shaft (annular crown) | 1 | **CNC** (316L SS — Phase 4 correction) | The one precision machined part; product falls through its centre, torque enters around it |
| Drop funnel | 1 | **Injection mold** (Tritan) | Only user-washed food-contact part; twist-lock, dishwasher-safe |
| Weigh platform / drip tray | 2 | **Injection mold** (ABS / PP) | |
| Lid | 1 | **Injection mold** (clear PC) | |
| Drive stepper + 1:5 planetary | 1 | **OTS** | NEMA17 class |
| Carousel index stepper + pinion | 1 | **OTS** | |
| Carousel bearing (slew ring) | 1 | **OTS** | Lazy-susan class, not precision |
| Load cell 1 kg + mounts | 1 | **OTS** | TAL221 class |
| Lift cam, spring, small hardware | — | **OTS** | |
| NFC reader module | 1 | **OTS** | Reads cartridge tag at dock |

### Powder cartridge (P2) — 7 parts, all high-volume

| Part | Process |
|---|---|
| Shell + integral neck | Injection mold, PP (food-contact grade) |
| Dosing screw + agitator (one part) | Injection mold, POM |
| Outlet wiper/duckbill seal | LSR micro-mold |
| Foil induction seal | OTS converting |
| Desiccant puck | OTS |
| NFC tag inlay | OTS |
| Snap base cap | Injection mold, PP |

### Syrup cartridge (L2) — 8 parts

| Part | Process |
|---|---|
| Shell | Injection mold, PP |
| Piston pump block + leadscrew (2 pts) | Injection mold, POM |
| Inlet + outlet check valves (2 pts) | LSR micro-mold |
| Aseptic collapsible bag + one-way valve | OTS (bag-in-box industry standard, sterile-filled) |
| NFC tag inlay | OTS |

## 6. Open items flagged for founder

1. **Stirring/dissolution:** the machine dispenses up to 4 ingredients into the
   glass but does not stir. Powders like greens blends need agitation to
   dissolve. Options: (a) user stirs — recommended for v1, zero cost;
   (b) magnetic stirrer coil under the weigh platform + a puck in a branded
   shaker cup (~$6 BOM); (c) defer to v2. **Recommendation: (a), with (b) as a
   fast-follow accessory.**
2. **Compact SKU:** `n_stations=6` yields a Ø~350 mm machine from the same
   parts. Worth deciding before tooling, since the carousel tool would differ.
3. This is a **concept-geometry model** — correct architecture, envelopes,
   interfaces, and tolerances for review. Production surfacing (ribs, bosses,
   draft angles, snap details) belongs in a mechanical-CAD package (Fusion/
   SolidWorks) during Phase 5 DFM; the .scad stays the dimensional source of
   truth until then.

---

## 7. AMENDMENT — Water / heating / mixing subsystem (founder-approved 2026-07-09)

Founder decision: v1 must dissolve powders and incorporate liquids properly,
and must deliver water at a user-set temperature within **±2 °F**. Scope
change adopted: v1 gains a **tank-fed hot-water system with in-stream venturi
mixing** (this supersedes the "user stirs" recommendation in §6.1).

**Architecture** (now in the parametric model, `show_water=true`):

- **Removable ~3.5 L Tritan tank in the dead centre of the carousel ring** —
  the carousel is rim-driven, so its middle is empty; the tank lives there and
  lifts out through the lid. Machine footprint is unchanged.
- Water path: tank → poppet coupling → diaphragm pump → hall flow meter →
  **1200 W inline thick-film heater** (PID against outlet NTC + measured
  flow) → tangential inlet of the **venturi/swirl mixing manifold** mounted
  under the docking cone. Dosed ingredients drop from the cartridge outlet
  directly into the swirling heated stream and dissolve in-line before the
  spout. The manifold replaces the drop funnel as the single user-removable,
  dishwasher-safe food-contact part.
- **±2 °F at spout** is a firmware deliverable (Phase 3 PID + feed-forward on
  flow); heater-only system heats from tank temperature up to ~205 °F —
  chilling remains a v2 feature.
- Consequences accepted: mains-only power (1200 W kills battery), UL
  heating-appliance certification path (+$15–30k, +2–3 months), NSF/ANSI 42
  attention on the water path, descaling routine, added BOM ~$30–45.

**Sign-off status:** carousel layout, 10-station envelope, and Ø80×220
cartridge confirmed by founder ("go forward", 2026-07-09) together with this
subsystem. Mixing decision resolved: **venturi in-stream mixing** (no stirrer).

---

**→ Phase 3: electronics & firmware** (see `docs/phase3-electronics-firmware.md`)
