# Neuro-Stream — Phase 3: Electronics & Firmware

**Status:** Draft for founder sign-off
**Date:** 2026-07-09
**Scope:** dose control, thermal control (±2 °F), calibration, error handling,
power architecture, electronics BOM.

---

## 1. Microcontroller recommendation

**Primary: ESP32-S3-WROOM-1 module (Espressif) — ~$2.60 @ 5k, multi-source
distribution (Digi-Key/Mouser/LCSC), mature toolchain (ESP-IDF).**

Why it wins for this product:

- **Wi-Fi + BLE built in.** A $300–600 wellness appliance with per-user dose
  profiles, recipes, cartridge subscriptions, and OTA firmware updates needs an
  app. On any non-wireless MCU you'd add a radio module and end up paying more.
- **Horsepower headroom:** dual-core 240 MHz — one core owns hard-real-time
  control (steppers, PID, safety), the other runs UI/network. 512 KB SRAM +
  8 MB flash swallows the display UI and OTA A/B partitions.
- Peripherals cover the whole sensor set natively (I²C ×2, SPI, UART, PWM/MCPWM
  for steppers, ADC for NTCs, pulse counter for the flow meter, capacitive touch).
- Supply-chain: ESP32-S3 ships from multiple assembly houses; no allocation
  drama at 10k/yr volumes.

Alternatives considered: **STM32G0B1** (~$1.80) — cheaper, excellent control
MCU, but zero radio: adding BLE/Wi-Fi costs +$2.50–4 and a second firmware
target. **RP2040/RP2350** — nice PIO for steppers, but external flash + radio
still needed. **Nordic nRF52840** — BLE only (no Wi-Fi OTA/cloud), pricier.
Recommendation stands: one ESP32-S3 does everything.

**Safety split:** the 1200 W heater gets an independent hardware safety net
that works even if firmware crashes — two thermal cutoffs (one resettable
klixon, one one-shot fuse) in series with the heater line, plus a watchdog-fed
enable line: the TRIAC can only conduct while the MCU strokes a hardware
watchdog. This is the standard UL-friendly pattern.

## 2. Electronics architecture

```
                 ┌──────────────────────────────────────────────┐
                 │                ESP32-S3 module                │
                 │  core0: control loop (1 kHz)   core1: UI/net  │
                 └──┬─────┬─────┬─────┬─────┬─────┬─────┬───────┘
        TMC2209 ◄───┘     │     │     │     │     │     └──► 2.8" IPS touch (SPI)
      drive stepper   TMC2209   │     │     │     └──► NFC reader PN7150 (I²C)
      (NEMA17 1:5)    carousel  │     │     └──► HX717 load cell ADC
                      stepper   │     └──► flow meter (pulse counter)
                                └──► heater TRIAC (zero-cross, PWM burst)
                                     + 2× NTC (spout, heater body) via ADC
   Power: universal-input 12 V/5 A SMPS board (logic, motors, pump)
          + direct mains leg to heater through TRIAC + dual thermal cutoffs
```

Stepper drivers are **TMC2209**: silent (a kitchen product must not buzz) and
their **StallGuard load measurement is the jam sensor** — no extra hardware.

## 3. Firmware design

### 3.1 Dispense state machine (per recipe of up to 4 ingredients)

```
IDLE → CUP_CHECK → PREHEAT → for each ingredient i (≤4):
        INDEX(i) → DOCK → TAG_VERIFY → CO_DISPENSE(i) → UNDOCK
      → FLUSH → DONE  (any fault → SAFE_STOP → user message)
```

- `CUP_CHECK`: load cell confirms a vessel is present and tares it. No cup,
  no dispense — ever.
- `PREHEAT`: heater brings the loop to set-point ±2 °F before any product
  moves (see 3.3); water recirculates to drain volume is minimal (<15 mL).
- `CO_DISPENSE`: water flows through the venturi *while* the cartridge screw/
  piston meters product into the stream — dissolution happens in-line. Water
  volume per ingredient = recipe water ÷ ingredients, so the last mL of water
  always runs clean (self-rinsing spout).
- `TAG_VERIFY`: NFC tag must authenticate (signed), be in-date, and its
  remaining-dose counter must cover the request. Tag unreadable → **refuse to
  dispense, never guess.**
- `FLUSH`: 20 mL of clean hot water through the venturi at cycle end keeps the
  shared manifold rinsed after every serving.

### 3.2 Dose control (per ingredient)

```c
// dose_g  : target dose from recipe (clamped to tag's max_dose)
// k_cal   : g per drive revolution — read from THIS cartridge's NFC tag,
//           measured on the filling line for this lot (Phase 1, Arch. B)
revs      = dose_g / k_cal;
steps     = revs * STEPS_PER_REV * GEAR_RATIO;        // 0.65 mg/step resolution
run_stepper(DRIVE, steps, profile=TRAPEZOID);
// verification layer (doses ≥ 5 g): compare load-cell delta vs. target
delta = loadcell_delta();
if (dose_g >= 5.0 && fabs(delta - dose_g) > 0.04 * dose_g)   // 2× spec band
    raise(FAULT_DOSE_VERIFY, ingredient);
nfc_decrement_counter(dose_g);                        // update tag bookkeeping
```

### 3.3 Thermal control — hitting ±2 °F (±1.1 °C) at the spout

Classic PID is not enough on a flow-through heater; the loop uses
**feed-forward + PID trim**:

```c
// Feed-forward: power needed to lift measured flow to set-point
//   P_ff [W] = flow [g/s] × 4.186 [J/g°C] × (T_set − T_tank) [°C]
// PID trims the residual using the spout NTC (placed 20 mm after heater exit)
P = P_ff(flow, T_tank, T_set) + PID(T_set − T_spout);
triac_burst_set(P / P_MAX);          // zero-cross burst control, 50/60 Hz safe
```

- Pump runs at constant, flow-meter-verified rate → the feed-forward term is
  accurate, and PID only corrects ±3–4 °F of residual → settles inside ±2 °F
  in <4 s and holds it. This is proven Keurig/espresso-class control.
- **Cup compensation (UX):** optional "temperature at first sip" mode adds a
  model-based offset for vessel heat-steal, calibrated once per cup type.
- Guards: `T_heater_body > 260 °F` → hard fault; flow < 2 g/s while heating
  → boil-dry fault (pump lost prime / tank empty); both independent of the
  hardware cutoffs.

### 3.4 Calibration routines

- **Factory (per cartridge lot):** the fill line dispenses 3 test shots into a
  check-weigher and writes `k_cal` to the tag. The machine itself needs no
  per-cartridge calibration — it inherits it from the tag.
- **Machine self-check (monthly, automatic):** dispense 3 × 10 g water pulses
  by flow meter onto the load cell; cross-compare flow meter, load cell, and
  time. Any pair disagreeing >1.5% flags the drifting sensor and schedules a
  service prompt. This keeps the *verification* chain honest without user labor.
- **Load-cell zero:** auto-tare before every serving; creep-compensated.

### 3.5 Error handling matrix

| Fault | Detection | Response |
|---|---|---|
| Cartridge jam / powder bridge | TMC2209 StallGuard threshold + missed dose on load cell | Reverse ¼ turn ×3 (declog wiggle), retry once; else abort serving, message "Cartridge 4 jammed — remove and shake" |
| Low reservoir (cartridge) | NFC remaining-dose counter + StallGuard running-light signature | Warn at ≤3 servings; refuse when insufficient for recipe |
| Water tank empty | Flow < 2 g/s with pump on | Pause serving, prompt refill, resume (recipe state preserved) |
| Dose verify miss (≥5 g) | Load-cell delta outside ±4% | Abort remaining recipe, flag cartridge, log for QA |
| Overtemp | Spout or body NTC over limit | Firmware kills TRIAC; hardware cutoffs back-stop |
| NFC unreadable/invalid | Auth fail / CRC fail | Refuse that cartridge only; rest of carousel usable |
| Carousel mis-index | Dock cone hall sensor absent after index | Re-home carousel (one full revolution), retry once |
| MCU hang | Hardware watchdog | Heater + motors drop out in <100 ms |

## 4. Battery vs. mains — decided by physics

The 1200 W heater ends this debate: heating 300 mL from 68→140 °F takes
~50 kJ ≈ a **full 18650 cell per drink**. Battery operation would need a
laptop-pack-sized battery per day of use. **v1 is mains-only (universal
100–240 V input).** The only battery aboard is a coin cell for the RTC so
schedules survive unplugging. (A future battery "travel dispenser" would be a
no-heat, dose-only device — different product.)

## 5. Electronics BOM estimate (5k units, mid-2026 pricing)

| Item | Qty | Est. unit cost |
|---|---|---|
| ESP32-S3-WROOM-1 (8 MB) | 1 | $2.60 |
| TMC2209 driver | 2 | $1.40 ea |
| NEMA17 stepper + 1:5 planetary (drive) | 1 | $9.50 |
| NEMA17 pancake stepper (carousel) | 1 | $5.50 |
| Load cell 1 kg + HX717 ADC | 1 | $2.80 |
| NFC reader PN7150 + antenna | 1 | $2.90 |
| 2.8" IPS touch display (SPI) | 1 | $8.00 |
| Diaphragm pump (flow-controlled) | 1 | $8.00 |
| Inline thick-film heater 1200 W | 1 | $14.00 |
| Flow meter (hall) | 1 | $2.50 |
| NTC sensors ×3, thermal cutoffs ×2 | — | $3.20 |
| TRIAC + zero-cross + snubber | 1 | $2.20 |
| 12 V/5 A universal SMPS board | 1 | $6.50 |
| Main PCB (4-layer) + passives + connectors | 1 | $7.50 |
| Wiring harness, dock hall sensor, misc | — | $5.00 |
| **Electronics + electromechanical subtotal** | | **≈ $83** |

(Machine-total BOM including mechanics/enclosure lands in Phase 5; this
subtotal is consistent with a $400–700 retail device at standard multipliers.)

---

**⏸ STOP — awaiting founder sign-off on:**
1. ESP32-S3 as the MCU (implies app + OTA as product features)
2. Mains-only power (battery formally dropped for v1)
3. The error-handling behaviors in §3.5 (these become UX copy)
4. 2.8" touchscreen vs. cheaper knob+ring-LED UI (−$6 BOM if downgraded)
5. Then → Phase 4: materials & food-safety compliance
