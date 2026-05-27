// ==========================================
// CAMERA STEREO MOUNT PI5 - 90 DEG - V6
// ------------------------------------------
// Dudukan kamera CSI stereo untuk Raspberry Pi 5.
// Engsel tilt atas-bawah +/-15 derajat.
// Pakai knuckle_hinge() BOSL2.
// Pengunci: baut M4 + mur (beli).
//
// 2 part cetak:
//   1. bracket   : base + stick + leaf + knuckle outer
//   2. tilt_plate: pelat kamera + leaf + knuckle inner
//
// Beli: baut M4 x 25mm + mur M4 (1 set)
// ==========================================

include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

$fn = 48;

// ==========================================
// PARAMETER KAMERA CSI
// ==========================================
cam_hole_dist_x    = 20.45;
cam_hole_dist_y    = 13.87;
cam_plate_thick    = 3.0;
m2_dia             = 2.2;
bottom_hole_margin = 15;
top_hole_margin    = 2;

// ==========================================
// PARAMETER BASE & STICK
// ==========================================
base_thick     = 2.5;
base_disc_dia  = 28.35;
stick_height   = 45.0;
stick_dia      = 12.0;
num_base_holes = 6;
base_hole_r    = 10.5;
base_hole_dia  = 2.6;

// ==========================================
// PARAMETER ENGSEL
// ==========================================
hinge_len    = 20.0;   // panjang barrel (sejajar sumbu X)
hinge_segs   = 5;      // jumlah knuckle
hinge_offset = 6.0;    // offset barrel dari permukaan leaf
hinge_arm_h  = 2.0;    // tinggi arm
knuckle_d    = 8.0;    // diameter barrel
hinge_gap    = 0.25;   // gap antar segmen

// ==========================================
// DIMENSI TURUNAN
// ==========================================
plate_w     = cam_hole_dist_x + 8;
plate_h     = bottom_hole_margin + cam_hole_dist_y + top_hole_margin;
stick_top_z = base_thick + stick_height;

// Tebal leaf = tebal pelat kamera
leaf_thick  = cam_plate_thick;
// Tinggi leaf bracket (blok di puncak stick)
leaf_h      = 10.0;


// ==========================================
// BRACKET
// ------------------------------------------
// Leaf bracket berdiri di puncak stick.
// Knuckle outer tumbuh ke arah FRONT (+Y)
// dengan barrel sejajar sumbu X.
// Putaran engsel = tilt atas-bawah. ✓
// ==========================================

module bracket()
{
    difference()
    {
        union()
        {
            // Base
            cylinder(d = base_disc_dia, h = base_thick);

            // Stick
            translate([0, 0, base_thick])
                cylinder(d = stick_dia, h = stick_height);

            // Leaf bracket + knuckle outer
            translate([0, 0, stick_top_z + leaf_h/2])
                cuboid([hinge_len, leaf_thick, leaf_h])
                    position(TOP+FRONT) orient(anchor=FWD)
                        knuckle_hinge(
                            length       = hinge_len,
                            segs         = hinge_segs,
                            offset       = hinge_offset,
                            inner        = false,
                            arm_height   = hinge_arm_h,
                            pin_diam     = "M4",
                            knuckle_diam = knuckle_d,
                            gap          = hinge_gap,
                            fill         = true
                        );
        }

        // 6 lubang base clearance M2
        for (i = [0 : num_base_holes - 1])
            rotate([0, 0, i * 360/num_base_holes])
                translate([base_hole_r, 0, -1])
                    cylinder(d = base_hole_dia, h = base_thick + 2);
    }
}


// ==========================================
// TILT PLATE (koordinat lokal, z mulai 0)
// ------------------------------------------
// Leaf tilt di bawah pelat.
// Knuckle inner tumbuh ke arah FRONT (+Y)
// dengan barrel sejajar sumbu X. ✓
// ==========================================

module tilt_plate_local()
{
    difference()
    {
        union()
        {
            // Leaf + knuckle inner
            // Leaf dari z=0 ke z=leaf_h
            translate([0, 0, leaf_h/2])
                cuboid([hinge_len, leaf_thick, leaf_h])
                    position(BOT+FRONT) orient(anchor=FWD)
                        knuckle_hinge(
                            length       = hinge_len,
                            segs         = hinge_segs,
                            offset       = hinge_offset,
                            inner        = true,
                            arm_height   = hinge_arm_h,
                            pin_diam     = "M4",
                            knuckle_diam = knuckle_d,
                            gap          = hinge_gap,
                            fill         = true
                        );

            // Pelat kamera di atas leaf
            translate([
                -plate_w/2,
                -leaf_thick/2,
                leaf_h
            ])
                cube([plate_w, leaf_thick, plate_h]);
        }

        // 4 lubang kamera CSI (M2 clearance)
        lower_z = leaf_h + bottom_hole_margin;
        upper_z = lower_z + cam_hole_dist_y;

        for (sx = [-1, 1])
            for (hz = [lower_z, upper_z])
                translate([sx * cam_hole_dist_x/2, -5, hz])
                    rotate([-90, 0, 0])
                        cylinder(d = m2_dia, h = 10);
    }
}


// ==========================================
// TILT PLATE dalam koordinat dunia
// Pusat rotasi = sumbu barrel knuckle
// ==========================================

module tilt_plate_world(tilt_angle = 0)
{
    // Barrel knuckle bracket ada di:
    //   z = stick_top_z + leaf_h (TOP leaf) + arm + knuckle_d/2
    //     = poros engsel dalam dunia
    //   y = leaf_thick/2 + hinge_offset + hinge_arm_h + knuckle_d/2
    pivot_z = stick_top_z + leaf_h + hinge_arm_h + knuckle_d/2;
    pivot_y = leaf_thick/2 + hinge_offset + hinge_arm_h + knuckle_d/2;

    // tilt_plate_local: barrel-nya ada di
    //   z lokal = 0 (BOT leaf), tapi BOT leaf posisi di z=0
    //   karena inner, knuckle tumbuh ke bawah dari BOT leaf
    //   barrel center = z_lokal=0 - arm - knuckle_d/2 = -(arm+kd/2)
    //
    // Supaya barrel lokal bertemu barrel bracket:
    //   z_world(barrel lokal) = pivot_z
    //   translate_z + lokal_barrel_z = pivot_z
    //   translate_z + 0 - (arm+kd/2) = pivot_z - (arm+kd/2) ... hmm
    //
    // Cara paling aman: translate leaf BOT ke pivot_z
    // karena inner tumbuh dari BOT leaf ke arah +y (FRONT)
    // dan bracket outer tumbuh dari TOP leaf ke arah +y (FRONT)
    // Mereka mesh saat leaf BOT inner = leaf TOP outer
    //   leaf TOP outer z = stick_top_z + leaf_h
    //   leaf BOT inner z = pivot_z (yang kita terjemahkan)

    plate_translate_z = stick_top_z + leaf_h;

    // Rotasi pada sumbu X di posisi poros
    translate([0, pivot_y, pivot_z])
        rotate([tilt_angle, 0, 0])
            translate([0, -pivot_y, -pivot_z])
                translate([0, 0, plate_translate_z])
                    tilt_plate_local();
}


// ==========================================
// MODE RENDER
// ==========================================

mode = "assembly";

// pilihan:
// "assembly"         - preview rakitan
// "print_bracket"    - cetak bracket
// "print_tilt_plate" - cetak tilt plate

preview_tilt = 0;   // sudut preview (-15..+15)


if (mode == "assembly")
{
    color("gold") bracket();
    color("cyan") tilt_plate_world(preview_tilt);
}

if (mode == "print_bracket")
    bracket();

if (mode == "print_tilt_plate")
    tilt_plate_local();

