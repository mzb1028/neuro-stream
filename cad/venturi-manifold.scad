// ============================================================================
// NEURO-STREAM — Mixing manifold deep design (prototype-ready)
//
// HONEST ENGINEERING NOTE (why this is a "swirl wetting cone", and the pure
// venturi idea evolved): at our pump flow (~0.5 L/min = 8.3 mL/s) water
// velocities are ~0.3–0.9 m/s — venturi suction at that speed is only
// ~100–400 Pa: too weak to *entrain* powder reliably. What actually works at
// this scale (and is how commercial powder-drink and fountain machines do
// it) is a WET-WALL SWIRL CONE:
//   * water enters TANGENTIALLY at the top rim → spins into a thin film
//     coating the entire cone wall (a "wet wall")
//   * powder falls from the cartridge outlet onto the moving film — every
//     particle lands on water already in motion, so it wets instantly and
//     cannot form dry clumps or stick to a dry wall
//   * film converges into the throat where the flow necks down (this is the
//     venturi-like part) → intense shear finishes dissolution
//   * a short mixing tube (3× throat dia) evens it out before the spout
// Steam/splash management matters more than suction: hot water at the rim
// creates vapor that would wet the powder chute and cake it. Hence the
// VAPOR SHIELD: a molded baffle ring separating the (dry) powder drop path
// from the (wet) rim region, with a condensation drip edge.
//
// Numbers at design flow 8.3 mL/s (0.5 L/min):
//   tangential inlet Ø6  → v_in   = 0.29 m/s (film launch speed)
//   throat Ø7            → v_thr  = 0.22 m/s bulk; film Reynolds ≈ 2,600
//   full serving 250 mL  → 30 s water; ingredients co-dispense in-stream
//   pressure drop total  < 4 kPa → any diaphragm pump shrugs
// Prototype MUST verify: greens-blend (worst wetter) 5 g into 250 mL with
// zero residue on walls and <10 s dissolution tail. Knobs if it fails:
// inlet Ø down to 4.5 (faster film), cone angle, second tangential inlet.
// ============================================================================

half_section = true;    // the useful view for this part
explode      = 0;
$fn = 120;

ex = explode;

// ---- Parameters (the tuning knobs) -----------------------------------------
cone_top_d    = 46;    // rim where water film launches
cone_angle    = 55;    // wall angle from horizontal; steeper = faster film
throat_d      = 7;     // neck-down: shear zone. THE dissolution knob.
throat_len    = 8;
mixtube_d     = 9;
mixtube_len   = 27;    // ≈3× throat dia — evens concentration before spout
spout_d       = 10;
wall          = 2.2;   // Tritan molded (prototype: clear SLA to watch flow)
inlet_d       = 6.0;   // tangential water inlet (production: molded-in barb)
inlet_h_below_rim = 6;
powder_tube_d = 14;    // dry drop path from cartridge outlet (Ø12 + clearance)
shield_gap    = 3;     // vapor-shield annular gap (condensate drip edge)
twist_lock_d  = 54;    // bayonet ring engaging the machine (user-removable)

cone_h = (cone_top_d-throat_d)/2*tan(cone_angle);

module manifold_body() {
    difference() {
        union() {
            // outer shell: cone + throat + mixing tube
            cylinder(d1=throat_d+2*wall, d2=cone_top_d+2*wall, h=cone_h);
            translate([0,0,-throat_len]) cylinder(d=throat_d+2*wall, h=throat_len+1);
            translate([0,0,-throat_len-mixtube_len]) cylinder(d=mixtube_d+2*wall, h=mixtube_len+1);
            translate([0,0,-throat_len-mixtube_len-8]) cylinder(d1=spout_d+2, d2=mixtube_d+2*wall, h=8.5);
            // rim + twist-lock ring
            translate([0,0,cone_h]) difference() {
                cylinder(d=twist_lock_d+8, h=10);
                translate([0,0,-0.5]) cylinder(d=twist_lock_d, h=11);
            }
            translate([0,0,cone_h+4]) for(a=[0,120,240]) rotate(a)  // 3 bayonet lugs
                translate([twist_lock_d/2+2,0,0]) cube([5,8,4], center=true);
            // tangential inlet boss
            translate([0,0,cone_h-inlet_h_below_rim]) rotate([0,90,0])
                translate([0, cone_top_d/2-6, 0]) cylinder(d=inlet_d+2*wall, h=cone_top_d/2+14);
        }
        // interior: cone
        translate([0,0,-0.01]) cylinder(d1=throat_d, d2=cone_top_d, h=cone_h+0.02);
        // throat + mixing tube + spout bores
        translate([0,0,-throat_len-0.5]) cylinder(d=throat_d, h=throat_len+1);
        translate([0,0,-throat_len-mixtube_len-0.5]) cylinder(d=mixtube_d, h=mixtube_len+1);
        translate([0,0,-throat_len-mixtube_len-8.6]) cylinder(d=spout_d, h=9);
        // TANGENTIAL inlet: offset from centre so flow enters along the wall
        translate([0,0,cone_h-inlet_h_below_rim]) rotate([0,90,0])
            translate([0, cone_top_d/2-6, -2]) cylinder(d=inlet_d, h=cone_top_d/2+18);
        if (half_section) translate([0,-100,-120]) cube([200,200,300]);
    }
}

module vapor_shield() {
    // Separately molded drop-in ring: keeps the powder drop path dry.
    // Powder falls through the centre tube; steam rising off the swirl film
    // condenses on the shield's underside and drips back at the drip edge —
    // never onto the powder chute. Clearance gap tuned at prototype.
    color("SlateGray") translate([0,0,cone_h-2 + ex*40]) difference() {
        union() {
            cylinder(d=powder_tube_d+2*wall+2*shield_gap+8, h=3);          // cap disc
            translate([0,0,-9]) cylinder(d=powder_tube_d+2*wall, h=12);    // chute tube
            translate([0,0,-9]) cylinder(d1=powder_tube_d+2*wall+6,
                                         d2=powder_tube_d+2*wall, h=4);    // drip edge
        }
        translate([0,0,-10]) cylinder(d=powder_tube_d, h=15);              // dry chute
        if (half_section) translate([0,-100,-50]) cube([200,200,100]);
    }
}

color("MediumAquamarine", 0.85) manifold_body();
vapor_shield();

// ============================================================================
// PROTOTYPE TEST PLAN (bench rig ~$600 + the metering rig)
//  Rig: aquarium-grade pump + inline 300 W heater (bench substitute) + flow
//  meter feeding the tangential inlet; metering rig from cartridge bench
//  drops powder through the vapor shield. Print in CLEAR SLA.
//  Measure:
//   1. FILM COVERAGE: dye pulse — full wet wall within 1 s of flow start?
//   2. DISSOLUTION: 5 g creatine & greens into 250 mL @ 60 °C and 20 °C —
//      residue filter-dry-weigh: <1% undissolved, no wall cake after 20
//      servings without cleaning.
//   3. STEAM TEST: 95 °C water 30 s, then powder drop — chute must stay dry
//      (paper indicator in chute).
//   4. CARRYOVER: dispense flavor A, rinse 20 mL, dispense into clean water,
//      measure A (taste + refractometer) — target below taste threshold.
//   5. DRIP: after valve close, ≤2 drops from spout.
//  Iterate: throat_d (5–9), cone_angle (50–65), inlet_d (4.5–6), then lock.
// ============================================================================
