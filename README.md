# Neuro-Stream

Countertop smart-cartridge dispenser for functional powders and liquid
formulas — doses up to 4 ingredients per serving to ±2%, into water heated to
±2 °F, with self-cleaning and app/wearable connectivity.

**Engineering program: complete (all 6 phases founder-signed, 2026-07-10).**

## The design in one paragraph

Eleven 1-liter smart cartridges (10 ingredients + 1 self-cleaning cartridge)
sit on a rotating carousel around a central removable water tank. Each
cartridge contains its own factory-calibrated metering mechanism (dosing
screw for powders, piston pump for liquids in sterile no-preservative bags)
driven by a single shared motor through a standard docking interface. Doses
drop into a swirling stream of precisely heated water (venturi manifold) and
dissolve in-line. A built-in scale verifies doses, an NFC reader identifies
every cartridge and its calibration, and an ESP32-S3 runs the touchscreen,
app, auto-reorder, and wearable-driven recipe suggestions — all fully usable
with no phone present.

## Documents (read in order)

| # | File | Contents |
|---|---|---|
| 1 | [docs/phase1-concept-and-mechanisms.md](docs/phase1-concept-and-mechanisms.md) | Mechanism trade study, dose envelope, architecture decision |
| 2 | [docs/phase2-cad.md](docs/phase2-cad.md) | Parametric CAD guide, tolerances, water/heating amendment |
| 3 | [docs/phase3-electronics-firmware.md](docs/phase3-electronics-firmware.md) | MCU, firmware design, thermal control, connected-product spec |
| 4 | [docs/phase4-materials-food-safety.md](docs/phase4-materials-food-safety.md) | FDA food-contact materials, certifications, self-cleaning model |
| 5 | [docs/phase5-manufacturing-dfm.md](docs/phase5-manufacturing-dfm.md) | DFM, tooling, costs from MVP ($55–105k) to 10k units ($139/unit) |
| 6 | [docs/phase6-validation-testing.md](docs/phase6-validation-testing.md) | Dosing/stability test protocols, certification checklist, stage gates |

## CAD

Parametric model: [cad/neuro-stream.scad](cad/neuro-stream.scad) (OpenSCAD).
Every dimension is a named variable; `explode`, `cross_section`, and `show_*`
flags control views. Renders in [cad/renders/](cad/renders/).

## Approved path

**MVP ($55–105k) → 150-unit beta (~$220k) → 1,000–1,500 soft-mold run →
steel tooling + 5,000-unit production (~$499–549 retail).**
