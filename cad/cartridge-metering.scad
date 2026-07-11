// ============================================================================
// NEURO-STREAM — Cartridge metering internals (deep design, prototype-ready)
// Companion to neuro-stream.scad (machine-level model).
//
// TWO MECHANISMS IN THIS FILE:
//   part = "powder"  → dosing-screw assembly (class P2)
//   part = "syrup"   → piston pump assembly  (class L2)
//   part = "both"    → side by side
//
// PROTOTYPE INTENT: geometry is printable for bench testing —
//   screw/agitator + pump parts: SLS/MJF nylon or machined POM
//   barrels/housings: SLA clear resin (watch the powder/syrup move)
//   seals: cast or bought silicone (see notes)
// Bench tolerances (printed): ±0.2 mm — fine for dose-physics testing.
// Production tolerances (molded): metering bore ±0.05 mm (SPI A-2 cavity).
// ============================================================================

part          = "both";   // "powder" | "syrup" | "both"
explode       = 0;        // 0 assembled … 1 exploded
half_section  = false;    // cut housings to show internals
$fn = 96;

ex = explode;
function exz(mm) = ex*mm;

// ---------------------------------------------------------------------------
// SHARED: neck + 6-lobe spline socket (matches machine drive, spline_d=10)
// ---------------------------------------------------------------------------
neck_od     = 34;
neck_h      = 28;
outlet_d    = 12;
spline_d    = 10;
spline_lobes= 6;
spline_len  = 12;
spline_clr  = 0.15;   // POM socket vs 316L shaft — see machine model rationale

module spline_socket_negative() {   // subtract from driven part
    r = spline_d/2 + spline_clr/2;
    linear_extrude(spline_len+0.5)
        for (i=[0:spline_lobes-1])
            rotate(i*360/spline_lobes) translate([r*0.55,0]) circle(r=r*0.5);
}

// ============================================================================
// POWDER DOSING SCREW  (class P2: 2–15 g servings, target 0.65 g/rev)
// ============================================================================
// DESIGN NOTES (the details that make ±2% real):
//  * Dose/rev = π/4·(D²−d²)·pitch·fill ≈ 1.09 cm³ → ~0.65 g/rev @ 0.6 g/cm³.
//    Fill fraction is the variable — per-lot calibration absorbs its mean;
//    the geometry below controls its VARIANCE:
//  * 3 full flights inside the barrel → powder in the metering zone is fully
//    confined; only the last flight's state varies serving-to-serving.
//  * Agitator arms sweep 2 mm above the barrel entry slot at 1:1 screw speed —
//    keeps the slot flooded (constant head) from full to empty. This is the
//    single most important feature for no-drift-across-cartridge-life.
//  * Hopper cone at 60° from horizontal (steeper than any target powder's
//    angle of repose + 15° margin) → mass flow, no rat-holing.
//  * End-of-dose: firmware reverses 0.5 rev ("suck-back") to decompress the
//    last flight, then the duckbill wiper closes. Kills after-dribble.
//  * Torque budget: cohesive powder shear in this barrel ≈ 0.05–0.12 N·m;
//    spline + POM screw rated 0.5 N·m (4× margin). NEMA17+1:5 delivers 2 N·m.

aug_barrel_id = 16;      // metering bore (THE precision dimension, molded ±0.05)
aug_root_d    = 8;
aug_pitch     = 8;
aug_flight_t  = 2.2;     // flight thickness
aug_turns_in  = 3;       // flights confined in barrel
barrel_wall   = 2.5;
barrel_len    = aug_turns_in*aug_pitch + 6;
entry_slot_w  = 14;      // barrel entry slot (top side, under agitator)
entry_slot_l  = 16;
hopper_angle  = 60;      // deg from horizontal — anti-bridging
hopper_top_d  = 74;      // matches cartridge shell ID
agit_arm_r    = 33;      // agitator sweep radius
agit_clear    = 2;       // arm height above hopper floor

module powder_screw() {
    // one molded/printed part: spline socket + screw + agitator arms
    color("DarkOrange") difference() {
        union() {
            // screw root through barrel + up into hopper
            translate([0,0,-barrel_len]) cylinder(d=aug_root_d, h=barrel_len+8);
            // helical flight (true helix)
            translate([0,0,-barrel_len])
                linear_extrude(barrel_len, twist=-360*barrel_len/aug_pitch,
                               slices=barrel_len*6, convexity=10)
                    translate([(aug_root_d+ (aug_barrel_id-aug_root_d)/2)/2 - aug_root_d/4 + aug_root_d/2 - ((aug_barrel_id-aug_root_d)/4),0])
                        square([(aug_barrel_id-aug_root_d)/2, aug_flight_t], center=true);
            // hub above hopper floor
            translate([0,0,6]) cylinder(d=14, h=8);
            // two agitator arms, swept tips, 2 mm over hopper floor
            for (a=[0,180]) rotate(a)
                translate([0,0,agit_clear+8]) hull() {
                    translate([6,0,0])        sphere(d=6);
                    translate([agit_arm_r,0,10]) sphere(d=6);  // rises along cone
                }
        }
        translate([0,0,-barrel_len-0.4]) spline_socket_negative();
    }
}

module powder_housing() {
    // barrel + hopper cone + neck (cartridge-bottom insert, one molded part)
    color("WhiteSmoke", half_section?1:0.45) difference() {
        union() {
            // neck
            translate([0,0,-neck_h]) cylinder(d=neck_od, h=neck_h);
            // barrel body
            translate([0,0,-barrel_len]) cylinder(d=aug_barrel_id+2*barrel_wall, h=barrel_len);
            // hopper cone
            cylinder(d1=aug_barrel_id+2*barrel_wall, d2=hopper_top_d,
                     h=(hopper_top_d-aug_barrel_id)/2*tan(hopper_angle));
        }
        // metering bore
        translate([0,0,-barrel_len-1]) cylinder(d=aug_barrel_id, h=barrel_len+2);
        // hopper interior
        translate([0,0,0.01])
            cylinder(d1=aug_barrel_id, d2=hopper_top_d-4,
                     h=(hopper_top_d-aug_barrel_id)/2*tan(hopper_angle));
        // entry slot from hopper into barrel top flight
        translate([-entry_slot_l/2,-entry_slot_w/2,-aug_pitch-2])
            cube([entry_slot_l, entry_slot_w, aug_pitch+3]);
        // outlet bore through neck
        translate([0,0,-neck_h-1]) cylinder(d=outlet_d, h=neck_h+2);
        if (half_section) translate([0,-100,-200]) cube([200,200,400]);
    }
}

module duckbill_seal() {
    // LSR duckbill at outlet: powder passes down, humidity blocked upward.
    // Prototype: buy Ø12 silicone duckbill (Minivalve-class); this is a stand-in.
    color("IndianRed") translate([0,0,-neck_h-6-exz(25)]) {
        difference() {
            cylinder(d1=outlet_d+6, d2=outlet_d+2, h=7);
            translate([0,0,-0.5]) cylinder(d1=outlet_d+2, d2=2, h=7.5);
        }
    }
}

module powder_assembly() {
    powder_housing();
    translate([0,0,exz(70)]) powder_screw();
    duckbill_seal();
}

// ============================================================================
// SYRUP PISTON PUMP  (class L2: 5–50 mL servings, 1.26 mL/rev)
// ============================================================================
// DESIGN NOTES:
//  * Rotation→stroke inside the cartridge: spline turns a leadscrew (lead
//    4 mm) engaged in the piston's molded nut; piston is keyed against
//    rotation by two flats in the bore.  1 rev = 4 mm × π·10² = 1.26 mL.
//  * Full stroke 40 mm = 12.6 mL per stroke. Doses >12.6 mL auto-cycle:
//    dispense-stroke → fast retract (re-prime from bag) → repeat.
//  * Re-prime physics (the risky bit for 20,000 cP syrup): retract at
//    ≤6 mm/s with Ø8 inlet → bag pressure (collapsible, ~0.05 bar elastic
//    + atmospheric) refills in 4–7 s worst case. Firmware paces retract
//    speed by syrup viscosity class from the NFC tag. PROTOTYPE MUST VERIFY.
//  * Check valves: inlet umbrella (cracks 0.03 bar, low restriction),
//    outlet duckbill (cracks 0.15 bar — holds column, no drip). End-of-dose
//    reverse ¼ rev decompresses the bore.
//  * Piston seal: single X-ring (quad ring), silicone, Ø20 bore — lower
//    friction than O-ring, no lubricant (dry POM bore, Ra 0.4).
//  * Accuracy: displacement is geometric — bore ±0.05 mm ⇒ ±0.5% volume;
//    leadscrew molded pitch error <0.3%; both absorbed by per-lot k_cal.

pist_bore   = 20;
pist_stroke = 40;
lead        = 4;
pump_od     = 30;
pump_len    = pist_stroke + 26;

module syrup_pump_housing() {
    color("Honeydew", half_section?1:0.45) difference() {
        union() {
            translate([0,0,-neck_h]) cylinder(d=neck_od, h=neck_h);
            cylinder(d=pump_od, h=pump_len);
            // inlet port boss (from bag, side entry near bore top)
            translate([0,0,pump_len-10]) rotate([0,90,0]) cylinder(d=12, h=pump_od/2+6);
        }
        // bore with two anti-rotation flats
        difference() {
            translate([0,0,4]) cylinder(d=pist_bore, h=pump_len);
            for (m=[0,1]) mirror([m,0,0])
                translate([pist_bore/2-1.2,-pist_bore/2,3]) cube([3,pist_bore,pump_len]);
        }
        // inlet passage Ø8
        translate([0,0,pump_len-10]) rotate([0,90,0]) cylinder(d=8, h=pump_od/2+8);
        // outlet passage to neck
        translate([0,0,-neck_h-1]) cylinder(d=8, h=neck_h+6);
        if (half_section) translate([0,-100,-200]) cube([200,200,400]);
    }
}

module syrup_piston_screw() {
    // leadscrew (spline-driven) — visualized with helical thread
    color("DarkOrange") translate([0,0,exz(60)]) difference() {
        union() {
            translate([0,0,-neck_h+2]) cylinder(d=8, h=pump_len-6);
            translate([0,0,6]) // thread over stroke region
                linear_extrude(pist_stroke+12, twist=-360*(pist_stroke+12)/lead,
                               slices=(pist_stroke+12)*4, convexity=10)
                    translate([4.4,0]) square([2.8,1.8], center=true);
        }
        translate([0,0,-neck_h+1.6]) spline_socket_negative();
    }
    // piston with molded nut + X-ring groove + keyed flats
    color("SteelBlue") translate([0,0,14+exz(110)]) difference() {
        union() {
            cylinder(d=pist_bore-0.3, h=14);
            for (m=[0,1]) mirror([m,0,0])   // anti-rotation keys
                translate([pist_bore/2-1.4,-4,0]) cube([2.4,8,14]);
        }
        cylinder(d=8.2, h=15);              // nut bore (thread omitted, visual)
        translate([0,0,7]) rotate_extrude() // X-ring groove
            translate([pist_bore/2-0.3-1.4,0]) square([2.8,3.6], center=true);
    }
}

module syrup_checkvalves() {
    // outlet duckbill (in neck) + inlet umbrella (at side port)
    color("IndianRed") translate([0,0,-neck_h-6-exz(30)]) difference() {
        cylinder(d1=outlet_d+6, d2=outlet_d+2, h=7);
        translate([0,0,-0.5]) cylinder(d1=outlet_d+2, d2=2, h=7.5);
    }
    color("IndianRed") translate([pump_od/2+8+exz(30),0,pump_len-10])
        rotate([0,90,0]) cylinder(d1=11, d2=7, h=4);
}

module syrup_assembly() {
    syrup_pump_housing();
    syrup_piston_screw();
    syrup_checkvalves();
}

// ============================================================================
// LAYOUT
// ============================================================================
if (part=="powder") powder_assembly();
else if (part=="syrup") syrup_assembly();
else {
    translate([-55,0,0]) powder_assembly();
    translate([ 55,0,0]) syrup_assembly();
}

// ============================================================================
// PROTOTYPE BUILD SHEET (bench rig, ~$1,900 total)
//  1. Print housings in clear SLA (Formlabs Clear), screws in MJF PA12 or
//     machine from POM rod ($60/part at a job shop).
//  2. Buy: Ø12 duckbill + Ø10 umbrella valves (Minivalve), Ø20 X-ring
//     (silicone), NEMA17 + 1:5 planetary + TMC2209 + ESP32 devkit (~$70),
//     0.001 g balance (~$400), test powders (creatine, cohesive greens
//     blend, maltodextrin) + glycerin/syrup series 1k–20k cP.
//  3. Rig: motor drives spline shaft upward into hanging cartridge (mimics
//     machine orientation); balance under outlet.
//  4. Test matrix → docs/design-metering-venturi.md §4.
// ============================================================================
