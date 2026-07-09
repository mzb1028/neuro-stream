// ============================================================================
// NEURO-STREAM v1 — Parametric concept model (Phase 2)
// Countertop 10-station smart-cartridge dispenser, Architecture B
//
// OpenSCAD 2021.01+.  All dimensions in millimetres.
//
// HOW TO USE
//   explode = 0;          assembled view
//   explode = 1;          fully exploded view (parts translate apart)
//   cross_section = true; cut the model in half to see internals
//   show_* flags          isolate subsystems
//
// MANUFACTURING FLAGS (also repeated per-module):
//   [IM]  injection molded        [CNC] machined
//   [SM]  sheet metal             [OTS] off-the-shelf purchased part
//   [EXT] extrusion, cut to length
// ============================================================================

// ---------------------------------------------------------------------------
// VIEW CONTROLS
// ---------------------------------------------------------------------------
explode        = 0;      // 0 = assembled … 1 = fully exploded
cross_section  = false;  // true = half-section through machine centreline
show_chassis   = true;
show_carousel  = true;
show_cartridges= true;   // one powder + one syrup cartridge shown docked
show_drive     = true;
show_dispense  = true;   // funnel, load-cell platform, drip tray
show_lid       = true;
show_water     = true;   // tank, pump, heater, venturi mixing manifold

$fn = 64;                // curve resolution (raise for exports)

// ---------------------------------------------------------------------------
// MASTER PARAMETERS — the numbers you will actually tune
// ---------------------------------------------------------------------------

// ---- Cartridge envelope (shared by all cartridge SKUs) --------------------
cart_od          = 80;    // cartridge body outer dia. 80 dia × 220 tall ≈ 1.0 L net
cart_h           = 220;   // cartridge body height (above neck)
cart_wall        = 1.6;   // [IM] PP shell wall. 1.6 mm is the sweet spot for
                          // PP flow length vs. rigidity; <1.2 warps, >2.5 sinks.
cart_neck_od     = 34;    // neck that seats into the docking station
cart_neck_h      = 28;    // neck engagement length
cart_outlet_d    = 12;    // product outlet bore

// ---- Standard drive interface (THE precision interface of the machine) ----
// 6-lobe spline socket molded into every cartridge metering element; mating
// steel spline shaft rises from the drive station.
spline_d         = 10;    // spline major dia
spline_lobes     = 6;
spline_len       = 12;    // axial engagement
spline_clr       = 0.15;  // TOLERANCE: fit clearance between molded POM socket
                          // and machined steel shaft. 0.15 mm absorbs molding
                          // variation (±0.05 typ. for a 10 mm POM feature) plus
                          // carousel positioning error, while keeping rotational
                          // backlash < 2° so step-counted dose error from lash
                          // stays below 0.1% of a 1-revolution dose.
spline_lead_in   = 2;     // chamfer so blind docking self-aligns

// ---- Carousel & station geometry -------------------------------------------
n_stations       = 10;    // cartridge count. Set 6 for a compact SKU —
                          // everything below re-derives automatically.
station_gap      = 15;    // clearance between adjacent cartridge bodies
pitch_c          = n_stations * (cart_od + station_gap);   // pitch circumference
pitch_r          = pitch_c / (2 * PI);                     // station pitch radius
carousel_r       = pitch_r + cart_od/2 + 12;               // carousel disc radius
carousel_t       = 6;     // [IM] carousel plate thickness (glass-filled PP)
station_bore     = cart_neck_od + 0.4;  // TOLERANCE: neck-to-plate fit. +0.4 mm
                          // diametral = drop-in fit for a consumer with no
                          // aiming; radial location comes from the tapered
                          // docking cone below, not this bore.

// ---- Chassis ----------------------------------------------------------------
deck_h           = 185;   // carousel deck height above countertop. Must exceed
                          // glass_h + funnel_h + 25 mm clearance.
base_r           = carousel_r + 18;   // chassis skirt radius
base_wall        = 2.5;   // [IM] ABS enclosure wall
glass_h          = 150;   // tallest vessel the dispense bay accepts
bay_w            = 110;   // dispense bay opening width

// ---- Powder metering element (class P2) -------------------------------------
// Vertical dosing screw in the cartridge neck, agitator on the same shaft.
aug_barrel_id    = 16;    // [IM] barrel bore molded into neck insert
aug_root_d       = 8;     // screw root dia
aug_pitch        = 8;     // flight pitch
aug_turns        = 3;     // flights inside the barrel
// dose/rev ≈ π/4·(id²−root²)·pitch·fill ≈ 1.09 cm³/rev ≈ 0.65 g/rev @0.6 g/cm³.
// A 5 g serving ≈ 7.7 rev; at 90 rpm that is a 5 s dispense. Resolution per
// motor full-step (200 steps/rev, 1:5 gear) ≈ 0.65 mg — far inside ±2%.
agitator_r       = cart_od/2 - cart_wall - 4;  // sweep radius of agitator flight

// ---- Syrup metering element (class L2) --------------------------------------
// Piston displacement pump driven through an internal leadscrew from the same
// rotary spline — cartridge converts rotation to linear stroke internally.
pist_id          = 20;    // piston bore
pist_stroke      = 40;    // max stroke per re-prime cycle
pist_lead        = 4;     // leadscrew lead: 4 mm/rev → 1.26 mL/rev.
// 30 mL serving ≈ 24 rev ≈ 16 s at 90 rpm. Check-valve pair re-primes from bag.

// ---- Drive station -----------------------------------------------------------
drive_travel     = 14;    // vertical engage/retract stroke of spline shaft
motor_l          = 42;    // [OTS] NEMA17 stepper + 1:5 planetary
cone_big_d       = cart_neck_od + 6;   // docking cone mouth
cone_small_d     = cart_neck_od + 0.2; // TOLERANCE: cone seat. +0.2 mm on the
                          // neck gives a slip fit that still centres the outlet
                          // over the funnel within ±0.3 mm — powder stream and
                          // syrup drip both land inside a 12 mm funnel throat.

// ---- Dispense bay -------------------------------------------------------------
funnel_top_d     = 46;    // [IM] shared drop funnel, dishwasher-safe, tool-less
funnel_bot_d    = 14;
funnel_h         = 38;
loadcell_l       = 55;    // [OTS] 1 kg single-point load cell (TAL221-class)
platform_d       = 95;    // [IM] weighing platform / drip tray top

// ---- Water / heating / mixing subsystem (founder-approved 2026-07-09) ---------
// Tank lives in the dead space inside the carousel ring: zero footprint cost.
tank_d           = 140;   // [IM] removable tank, Ø140 × 250 ≈ 3.5 L usable
tank_h           = 250;
tank_wall        = 2.0;   // Tritan (clear, tough, dishwasher-safe)
pump_l           = 55;    // [OTS] diaphragm pump body length (base compartment)
heater_l         = 90;    // [OTS] inline thick-film heater, 1200 W
heater_d         = 32;
tube_d           = 8;     // silicone water line, 8 mm OD
// TOLERANCE: tank-to-base water coupling uses a spring poppet + EPDM O-ring;
// coupling bore +0.1/-0 on a Ø14 spigot — sealing comes from the O-ring
// squeeze (25% nominal), not the bore fit, so molding variation is absorbed.
venturi_l        = 34;    // [IM Tritan] mixing manifold: heated water enters
venturi_d        = 22;    //   tangentially, product drops in from the cone
                          //   above, swirl + venturi throat dissolves powder
                          //   in-stream before the spout. Removable for wash.
spout_d          = 10;

// ---- Lid ----------------------------------------------------------------------
lid_h            = 24;    // [IM] hinged translucent lid over cartridge deck

// Exploded-view translation distances (scaled by `explode`)
ex   = explode;
function exz(mm) = ex * mm;   // axial explode helper

// ============================================================================
// PART MODULES
// ============================================================================

// ---- 6-lobe spline (male shaft / female socket via `clr`) -------------------
// [CNC] machine-side shaft: 303 SS, machined + tumbled. This is the highest-
// precision metal part in the machine; everything else forgives.
// [IM] cartridge-side socket: molded into the POM metering element.
module spline(male=true, clr=0) {
    r = spline_d/2 + (male ? -clr/2 : clr/2);
    linear_extrude(spline_len)
        for (i=[0:spline_lobes-1])
            rotate(i*360/spline_lobes)
                translate([r*0.55,0]) circle(r=r*0.5);
}

// ---- Powder cartridge (class P2) --------------------------------------------
// Shell [IM PP], neck insert+barrel [IM PP], dosing screw+agitator [IM POM],
// outlet wiper seal [IM LSR], foil induction seal [OTS], desiccant puck [OTS],
// NFC tag [OTS]. 7 parts.
module cartridge_powder() {
    // body shell
    color("WhiteSmoke", 0.55) difference() {
        union() {
            cylinder(d=cart_od, h=cart_h);
            translate([0,0,-cart_neck_h]) cylinder(d=cart_neck_od, h=cart_neck_h+1);
        }
        translate([0,0,cart_wall]) cylinder(d=cart_od-2*cart_wall, h=cart_h);
        translate([0,0,-cart_neck_h-1]) cylinder(d=aug_barrel_id, h=cart_neck_h+cart_h);
    }
    // dosing screw + agitator (single molded POM part, snaps in from below)
    color("DarkOrange") translate([0,0,exz(70)]) {
        // screw root
        translate([0,0,-cart_neck_h]) cylinder(d=aug_root_d, h=cart_neck_h+30);
        // helical flights (visual approximation of the molded helix)
        translate([0,0,-cart_neck_h])
            linear_extrude(aug_turns*aug_pitch, twist=-360*aug_turns, slices=90)
                translate([ (aug_barrel_id-1)/4 ,0])
                    square([ (aug_barrel_id-aug_root_d)/2 -0.5, 2.2], center=true);
        // agitator sweep arm above the screw
        translate([0,0,35]) rotate([90,0,0])
            cylinder(d=5, h=agitator_r, center=false);
        // female spline socket at the very bottom
        translate([0,0,-cart_neck_h-spline_len+2]) spline(male=false, clr=spline_clr);
    }
    // outlet wiper seal (LSR duckbill — powder can leave, humidity can't enter)
    color("IndianRed") translate([0,0,-cart_neck_h - 3 - exz(30)])
        cylinder(d1=cart_outlet_d+6, d2=cart_outlet_d+2, h=4);
    // NFC tag puck on shoulder
    color("SteelBlue") translate([cart_od/2-8, 0, cart_h-6+exz(25)])
        cylinder(d=14, h=1.5);
}

// ---- Syrup cartridge (class L2) ---------------------------------------------
// Shell [IM PP], aseptic collapsible bag [OTS PE/EVOH, sterile-filled],
// piston pump block w/ leadscrew [IM POM ×2], inlet+outlet check valves
// [IM LSR ×2], one-way bag valve [OTS], NFC tag [OTS]. 8 parts.
// Founder requirement: sterile fill + one-way check valve — no air return,
// preservative-free contents never see atmosphere until dispensed.
module cartridge_syrup() {
    color("Honeydew", 0.5) difference() {
        union() {
            cylinder(d=cart_od, h=cart_h);
            translate([0,0,-cart_neck_h]) cylinder(d=cart_neck_od, h=cart_neck_h+1);
        }
        translate([0,0,cart_wall]) cylinder(d=cart_od-2*cart_wall, h=cart_h);
    }
    // collapsible aseptic bag (shown part-collapsed)
    color("LightSkyBlue", 0.6) translate([0,0,30+exz(60)])
        scale([0.8,0.55,1]) cylinder(d=cart_od-10, h=cart_h-70);
    // piston pump block in the neck
    color("DarkOrange") translate([0,0,-cart_neck_h - exz(35)]) {
        cylinder(d=pist_id+6, h=cart_neck_h-2);           // pump body
        translate([0,0,-spline_len+2]) spline(male=false, clr=spline_clr);
    }
    // check valves (inlet from bag, outlet duckbill)
    color("IndianRed") translate([0,0,-cart_neck_h-3-exz(70)])
        cylinder(d1=cart_outlet_d+6, d2=cart_outlet_d+2, h=4);
    color("SteelBlue") translate([cart_od/2-8, 0, cart_h-6+exz(25)])
        cylinder(d=14, h=1.5);
}

// ---- Carousel plate -----------------------------------------------------------
// [IM] 30% glass-filled PP. One tool, no inserts. Ring gear molded into rim,
// driven by a pinion on a small stepper — carousel positioning only needs to
// land the neck inside the docking cone's ±2.5 mm capture range, so molded
// gear accuracy is fine (no machined gear needed).
module carousel() {
    color("DimGray") difference() {
        union() {
            cylinder(r=carousel_r, h=carousel_t);
            // molded ring gear (represented as a rim band)
            translate([0,0,-4]) difference() {
                cylinder(r=carousel_r, h=4);
                cylinder(r=carousel_r-6, h=5);
            }
        }
        for (i=[0:n_stations-1])
            rotate(i*360/n_stations)
                translate([pitch_r,0,-5]) cylinder(d=station_bore, h=carousel_t+10);
        // centre opening: carousel is a RING around the fixed water tank,
        // driven at the rim gear (rim drive is why the middle can be empty)
        cylinder(d=tank_d+8, h=40, center=true);
    }
}

// ---- Docking cone + drive station (at the front/dispense position) -----------
// Cone [IM GF-PP], spline shaft [CNC 303 SS], lift cam + spring [OTS],
// drive stepper+gearbox [OTS NEMA17 1:5]. The cone captures a mis-positioned
// neck (±2.5 mm) and centres it; the spring-loaded spline then rises
// drive_travel mm and self-clocks into the socket within one motor turn.
module drive_station() {
    rotate(0) translate([pitch_r, 0, deck_h - 30]) {
        // docking cone under the deck plate
        color("SlateGray") difference() {
            cylinder(d1=cone_big_d+8, d2=cone_big_d+8, h=26);
            translate([0,0,6]) cylinder(d1=cone_small_d, d2=cone_big_d, h=21);
            cylinder(d=funnel_bot_d+4, h=30, center=true);
        }
        // spline shaft (engaged position), offset to bypass product path:
        // shaft is annular-drive — a crown ring around the outlet, so product
        // falls through the centre while torque enters around it.
        color("Silver") translate([0,0,26 - exz(45)]) {
            difference() {
                cylinder(d=cart_neck_od-2, h=spline_len);
                cylinder(d=cart_outlet_d+4, h=spline_len*3, center=true);
            }
        }
        // motor + gearbox hanging below [OTS]
        color([0.2,0.2,0.25]) translate([-21,-21,-motor_l-30+exz(-60)])
            cube([42,42,motor_l]);
    }
}

// ---- Chassis -------------------------------------------------------------------
// Skirt+tower [IM ABS, 2 shells], internal deck [SM 1.5 mm galv. steel — flat,
// stiff, cheap at low volume; convert to a third molding at >20k units/yr].
module chassis() {
    color([0.85,0.85,0.87]) difference() {
        union() {
            // outer skirt up to deck
            cylinder(r1=base_r, r2=base_r-4, h=deck_h);
        }
        // hollow it
        translate([0,0,base_wall]) cylinder(r1=base_r-base_wall, r2=base_r-4-base_wall, h=deck_h);
        // dispense bay cut-out at front (+X)
        translate([pitch_r-10, -bay_w/2, base_wall+2])
            cube([base_r, bay_w, glass_h+funnel_h+20]);
    }
    // steel deck plate carrying carousel bearing + drive station [SM]
    color("Gainsboro") translate([0,0,deck_h-3+exz(-25)])
        difference() {
            cylinder(r=base_r-6, h=3);
            translate([pitch_r,0,-1]) cylinder(d=cone_big_d+2, h=6);
        }
    // tank seat boss with poppet coupling at deck centre
    color("Gainsboro") translate([0,0,deck_h]) cylinder(d=tank_d-10, h=6);
}

// ---- Water / heating / mixing subsystem ------------------------------------------
// Tank [IM Tritan ×2 + OTS poppet valve], pump [OTS], inline heater [OTS],
// flow meter [OTS], venturi manifold [IM Tritan, user-removable].
// Water path: tank → poppet → pump → flow meter → 1200 W thick-film heater
// (PID, NTC at outlet) → tangential inlet of venturi manifold, where the
// dosed ingredient stream from the docking cone drops into the swirl.
// ±2 °F at spout = PID on heater power against measured flow (Phase 3).
module water_system() {
    // removable tank in the carousel centre
    color("LightCyan", 0.5) translate([0,0,deck_h+6+exz(120)])
        difference() {
            cylinder(d=tank_d, h=tank_h);
            translate([0,0,tank_wall]) cylinder(d=tank_d-2*tank_wall, h=tank_h);
        }
    // pump + heater in the base compartment (rear, opposite dispense bay)
    color("DarkSeaGreen") translate([-pitch_r-10, -20+exz(-50), base_wall+8])
        cube([pump_l, 40, 40]);                               // pump [OTS]
    color("Tomato") rotate(25) translate([-pitch_r+20, 30+exz(50), base_wall+8])
        rotate([0,90,0]) cylinder(d=heater_d, h=heater_l);    // heater [OTS]
    // water line from heater to venturi (routed under deck; shown direct)
    color("SlateGray") translate([-pitch_r+40, 0, base_wall+30+exz(-15)])
        rotate([0,90,0]) cylinder(d=tube_d, h=2*pitch_r-40);
    // venturi mixing manifold hanging under the docking cone, above the glass
    color("MediumAquamarine", 0.8)
        translate([pitch_r, 0, deck_h-30-venturi_l-2-exz(75)]) {
            cylinder(d=venturi_d+8, h=venturi_l);             // swirl body
            translate([0,0,-10]) cylinder(d=spout_d, h=12);   // spout
            rotate([0,90,90]) translate([-venturi_l+12,0,0])
                cylinder(d=tube_d, h=26);                     // tangential inlet
        }
}

// ---- Dispense bay: funnel, load-cell platform, drip tray ------------------------
module dispense_bay() {
    // Drop funnel [IM Tritan] — used only in the dry (no-water) build variant;
    // with show_water the venturi manifold takes its place as the single
    // user-washed food-contact part (twist-lock, dishwasher-safe).
    if (!show_water) color("LightSteelBlue", 0.7)
        translate([pitch_r, 0, deck_h - 30 - funnel_h - 4 - exz(55)])
            difference() {
                cylinder(d1=funnel_bot_d+4, d2=funnel_top_d, h=funnel_h);
                translate([0,0,-1]) cylinder(d1=funnel_bot_d, d2=funnel_top_d-4, h=funnel_h+2);
            }
    // load-cell platform [OTS cell + IM platform]
    color("DarkSlateGray") translate([pitch_r, 0, base_wall + exz(-30)]) {
        cylinder(d=platform_d, h=6);                        // drip-tray top
        translate([-loadcell_l/2,-6,-0.1]) cube([loadcell_l,12,3]); // cell (hidden)
    }
    // example glass (reference geometry only, not a part)
    if (explode == 0)
        color("White", 0.25) translate([pitch_r,0,base_wall+6])
            difference() {
                cylinder(d1=60, d2=72, h=glass_h);
                translate([0,0,3]) cylinder(d1=55, d2=67, h=glass_h);
            }
}

// ---- Lid ------------------------------------------------------------------------
module lid() {
    color("WhiteSmoke", 0.35)
        translate([0,0,deck_h + carousel_t + cart_h + 6 + exz(90)])
            difference() {
                cylinder(r1=base_r-4, r2=base_r-30, h=lid_h);
                translate([0,0,-2]) cylinder(r1=base_r-4-2.5, r2=base_r-32, h=lid_h);
            }
}

// ============================================================================
// ASSEMBLY
// ============================================================================
module assembly() {
    if (show_chassis)  chassis();
    if (show_drive)    drive_station();
    if (show_dispense) dispense_bay();
    if (show_carousel) translate([0,0,deck_h + 10 + exz(45)]) carousel();
    if (show_cartridges) {
        // powder cartridge docked at the dispense station (front)
        translate([pitch_r, 0, deck_h + 10 + carousel_t + cart_neck_h + exz(120)])
            cartridge_powder();
        // syrup cartridge parked one station over
        rotate(360/n_stations)
            translate([pitch_r, 0, deck_h + 10 + carousel_t + cart_neck_h + exz(120)])
                cartridge_syrup();
    }
    if (show_lid) lid();
    if (show_water) water_system();
}

if (cross_section)
    difference() { assembly(); translate([-500, 0, -50]) cube(1000); }
else
    assembly();

// ============================================================================
// PART → PROCESS SUMMARY (detail table in docs/phase2-cad.md)
//   Machine:  chassis shells [IM ABS], deck [SM], carousel [IM GF-PP],
//             docking cone [IM GF-PP], spline shaft [CNC 303SS],
//             funnel [IM Tritan], platform/drip tray [IM],
//             steppers, gearbox, load cell, bearings, NFC reader [OTS]
//   Powder cartridge (7 pts): shell+neck [IM PP], screw+agitator [IM POM],
//             wiper seal [IM LSR], foil, desiccant, NFC tag [OTS]
//   Syrup cartridge (8 pts):  shell [IM PP], pump block+leadscrew [IM POM],
//             check valves [IM LSR], aseptic bag+one-way valve [OTS], NFC [OTS]
// ============================================================================
