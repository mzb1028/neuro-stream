# Deep Design: Cartridge Metering Internals & Mixing Manifold

**Models:** [`cad/cartridge-metering.scad`](../cad/cartridge-metering.scad) ·
[`cad/venturi-manifold.scad`](../cad/venturi-manifold.scad)
**Status:** Prototype-ready — these are the two subsystems to build and test
first (they carry the ±2% dosing promise and the "dissolves properly" promise).
**Date:** 2026-07-10

---

## 1. Powder dosing screw — the details that make ±2% real

The screw geometry is easy; **dose consistency** is the design problem. Four
features do the work:

1. **Three confined flights.** The metering zone holds 3 full screw turns
   inside a tight barrel (Ø16 bore, molded to ±0.05 mm). Powder in this zone
   is fully enclosed — only the state of the last flight varies from serving
   to serving, so variance stays small even when the powder itself varies.
2. **Agitator sweeps the barrel entry at constant height.** Two arms turn
   with the screw, 2 mm above the entry slot, keeping it flooded with powder
   at constant pressure ("constant head") from a full cartridge to a nearly
   empty one. This is the anti-drift feature — without it, dose/rev falls as
   the powder column above gets lighter.
3. **60° hopper cone.** Steeper than any target powder's angle of repose plus
   margin → mass flow, no rat-holes, no dead powder at end of life
   (target residual <2% of fill).
4. **Suck-back finish.** At end of dose, firmware reverses the screw ½ turn to
   decompress the last flight, then the silicone duckbill closes. No dribble,
   no dose tail.

**The numbers:** ~1.09 cm³/rev → ~0.65 g/rev at 0.6 g/cm³ bulk density;
motor resolution 0.65 mg/step; 5 g serving ≈ 7.7 rev ≈ 5 s. Torque worst-case
(caked cohesive powder) ≈ 0.12 N·m vs. 2 N·m available — 16× margin, and the
drive current limit doubles as the jam detector.

**Accuracy budget (why ±2% closes):** bore molding ±0.05 mm → ±0.6% volume;
fill-fraction serving-to-serving σ ≈ 0.5–0.8% with the agitator (literature +
to be confirmed on rig); lash <0.1%; balance-verified calibration removes the
mean. Root-sum-square ≈ ±1.2–1.6% (3σ) — inside spec with margin.

## 2. Syrup piston pump — the risky bit is re-priming, not dosing

Dosing is geometric and boring (that's good): Ø20 bore × 4 mm lead = 1.26
mL/rev; bore tolerance ±0.05 mm → ±0.5% volume. The engineering risk is
**refilling the bore with 20,000 cP syrup** between strokes:

- Doses >12.6 mL need multiple strokes: dispense → retract (inlet umbrella
  valve opens, collapsible bag feeds the bore) → dispense again.
- Worst case (cold, thickest syrup): refill through the Ø8 inlet takes 4–7 s
  per stroke. Firmware paces retract speed using the viscosity class from the
  cartridge tag. A 30 mL thick-syrup serving ≈ 40–50 s — acceptable, but
  **this is the number the prototype must confirm.** Fallback knobs: Ø10
  inlet, dual inlet ports, or a lightly spring-loaded bag shell.
- Anti-drip: outlet duckbill needs 0.15 bar to open (holds the column), and a
  ¼-turn reverse decompresses the bore at end of dose.
- Piston seal: silicone X-ring (quad-ring) — lower friction than an O-ring,
  runs dry against a polished POM bore, no lubricant anywhere in the product path.

## 3. Mixing manifold — an honest design evolution

Testing the physics on paper changed the concept, and you should know why:
at our flow rate (~0.5 L/min) a classic venturi generates only ~100–400 Pa of
suction — **too weak to pull powder in reliably.** What works at this scale —
and what fountain and powder-drink machines actually use — is a **wet-wall
swirl cone**, which the model now implements:

- Water enters **tangentially** at the rim and spins into a thin film coating
  the whole cone wall. Powder falls from the cartridge outlet onto this
  *moving* film — every particle lands on water that's already flowing, so it
  wets instantly and can't clump or stick to a dry wall.
- The film converges into a Ø7 **throat** (the venturi-like element) where
  shear finishes dissolution, then a short **mixing tube** (3× throat
  diameter) evens concentration before the spout.
- **Vapor shield:** the subtle killer in hot-water powder systems is steam —
  it rises, condenses in the powder chute, and cakes it shut. A molded baffle
  ring keeps the drop path dry, with a drip edge so condensate returns to the
  swirl, never the chute.
- Still a twist-lock (3-lug bayonet), still the only user-washed part, still
  dishwasher-safe Tritan in production — prototype in clear SLA so you can
  *watch* the film form.

**Tuning knobs left deliberately parametric:** `throat_d` (5–9 mm),
`cone_angle` (50–65°), `inlet_d` (4.5–6 mm). These three get swept on the rig.

## 4. Bench prototype plan (~$2,500 total, 3–4 weeks)

**Rig A — dosing (from cartridge-metering.scad):** printed housings (clear
SLA) + MJF or machined-POM screws, NEMA17 + TMC2209 + ESP32 devkit, 0.001 g
balance. Cartridge hangs neck-down over the balance, exactly like the machine.

| Test | Method | Pass |
|---|---|---|
| Dose repeatability | 50 doses × {1, 5, 15 g} × {creatine, greens, maltodextrin} | σ ≤ 0.8% of dose |
| Life drift | Full-to-empty run, dose every 10th serving weighed | slope flat, all within ±2% of calibrated mean |
| Humidity abuse | Cartridge open at 32 °C/80 %RH for 48 h, then dose | within ±2%, no caking at wiper |
| Suck-back | High-speed video of outlet at dose end | 0 visible dribble |
| Syrup re-prime | 20k cP glycerin blend, cold (15 °C), full-stroke cycling | refill ≤7 s/stroke, dose σ ≤0.5% |
| Jam behavior | Deliberately caked plug | StallGuard trips before spline/screw damage |

**Rig B — mixing (from venturi-manifold.scad):** pump + bench heater + flow
meter into the tangential inlet; Rig A drops powder through the vapor shield.

| Test | Method | Pass |
|---|---|---|
| Film coverage | Dye pulse, clear body | full wet wall <1 s after flow start |
| Dissolution | 5 g greens into 250 mL at 20° and 60 °C; filter, dry, weigh residue | <1% undissolved; no wall cake after 20 servings, no manual clean |
| Steam/caking | 95 °C water 30 s, then powder drop; paper indicator in chute | chute bone dry |
| Carryover | Flavor A → 20 mL rinse → clean water; refractometer + taste | below taste threshold |
| Drip | Valve close, observe spout | ≤2 drops |

**Order of work:** print Rig A parts week 1; dose matrix weeks 2–3; Rig B
sweep (`throat_d` × `cone_angle` × `inlet_d`, ~12 printed variants at ~$18
each) weeks 2–4 in parallel. Every number that passes gets locked into the
main parametric model; every miss has its named fallback above.

These two rigs *are* the heart of the bench MVP from Phase 5 — passing this
plan means the four risky claims are two-thirds proven before the full
machine exists.