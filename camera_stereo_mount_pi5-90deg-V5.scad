// ==========================================
// CAMERA STEREO MOUNT PI5 - 90 DEG - V5
// ------------------------------------------
// Perubahan dari V4:
// - Tanpa ulir, tanpa connector rod.
// - Base + stick + pelat kamera MENYATU jadi
//   SATU OBJEK UTUH, dicetak sekaligus.
// - Sudut tetap 90 derajat.
// ==========================================

// ==========================================
// BOSL2 LIBRARY
// ==========================================
include <BOSL2/std.scad>

// ==========================================
// RESOLUTION CONTROL
// ==========================================
$fn = 48;

// ==========================================
// PARAMETER DEFINITION
// ==========================================

// Kamera
cam_hole_dist_x = 20.45;
cam_hole_dist_y = 13.87;

cam_plate_thick = 2.5;

m2_dia = 2.2;

// Jarak pusat lubang bawah dari tepi bawah pelat
bottom_hole_margin = 15;

// Jarak pusat lubang atas dari tepi atas pelat
top_hole_margin = 2;


// ==========================================
// BASE & STICK
// ==========================================

// Tinggi stick (batang penghubung base ke pelat)
stick_height = 45.0;

// Diameter batang stick
stick_dia = 10.0;

// Tinggi sirip penguat di pangkal pelat.
// Sirip menjembatani puncak stick ke pelat;
// makin tinggi makin kuat menahan pelat.
fin_height = 18.0;

base_thick = 2.5;

// Diameter piringan base
base_disc_dia = 28.35;


// Lubang base bawah
num_base_holes = 6;
base_hole_radius = 10.5;

// Diameter lubang clearance baut M2 di base (6 buah).
// Bukan lubang ulir - baut hanya lewat, dikencangkan
// dengan mur di sisi casing Raspi 5.
base_hole_dia = 2.6;


// ==========================================
// PART V5 - SATU OBJEK UTUH
// ==========================================

module camera_mount_v5()
{
    plate_w = cam_hole_dist_x + 8;

    // tinggi pelat dihitung otomatis
    plate_h =
        bottom_hole_margin
        + cam_hole_dist_y
        + top_hole_margin;

    // z permukaan atas stick = pangkal pelat kamera
    stick_top_z = base_thick + stick_height;


    difference()
    {
        // ==================================
        // BODY UTAMA (semua menyatu)
        // ==================================
        union()
        {
            // Base bawah
            cylinder(
                d = base_disc_dia,
                h = base_thick
            );


            // Stick
            translate([0,0,base_thick])
                cylinder(
                    d = stick_dia,
                    h = stick_height
                );


            // Pelat kamera
            translate([
                -plate_w/2,
                -cam_plate_thick/2,
                stick_top_z
            ])
                cube([
                    plate_w,
                    cam_plate_thick,
                    plate_h
                ]);


            // Sirip penguat: menjembatani puncak
            // stick ke pangkal pelat kamera.
            hull()
            {
                // kotak tipis di pangkal pelat
                translate([
                    -plate_w/2,
                    -cam_plate_thick/2,
                    stick_top_z
                ])
                    cube([
                        plate_w,
                        cam_plate_thick,
                        2
                    ]);

                // silinder tipis di puncak stick,
                // tepat di bawah pangkal pelat
                translate([
                    0,
                    0,
                    stick_top_z - fin_height
                ])
                    cylinder(
                        d = stick_dia,
                        h = 2
                    );
            }
        }


        // ==================================
        // LUBANG KAMERA (4 buah)
        // ==================================

        // bawah pelat
        plate_bottom_z = stick_top_z;

        // lubang bawah
        lower_hole_z =
            plate_bottom_z
            + bottom_hole_margin;

        // lubang atas
        upper_hole_z =
            lower_hole_z
            + cam_hole_dist_y;


        // kanan bawah
        translate([
            cam_hole_dist_x/2,
            -5,
            lower_hole_z
        ])
            rotate([-90,0,0])
                cylinder(
                    d = m2_dia,
                    h = 10
                );


        // kiri bawah
        translate([
            -cam_hole_dist_x/2,
            -5,
            lower_hole_z
        ])
            rotate([-90,0,0])
                cylinder(
                    d = m2_dia,
                    h = 10
                );


        // kanan atas
        translate([
            cam_hole_dist_x/2,
            -5,
            upper_hole_z
        ])
            rotate([-90,0,0])
                cylinder(
                    d = m2_dia,
                    h = 10
                );


        // kiri atas
        translate([
            -cam_hole_dist_x/2,
            -5,
            upper_hole_z
        ])
            rotate([-90,0,0])
                cylinder(
                    d = m2_dia,
                    h = 10
                );


        // ==================================
        // Lubang base bawah (6 buah, clearance M2)
        // ==================================
        for (i = [0 : num_base_holes - 1])
        {
            angle = i * (360 / num_base_holes);

            rotate([0,0,angle])
                translate([
                    base_hole_radius,
                    0,
                    -1
                ])
                    cylinder(
                        d = base_hole_dia,
                        h = base_thick + 2
                    );
        }
    }
}


// ==========================================
// MODE RENDER
// ==========================================

mode = "default";

// pilihan:
// "default"       - orientasi normal (base di bawah)
// "print"         - orientasi cetak

camera_mount_v5();
