// ==========================================
// BOSL2 LIBRARY
// ==========================================
include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// ==========================================
// RESOLUTION CONTROL
// ==========================================
$fn = 24;

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


// Ball Head
ball_head_dia = 28.35;
ball_head_height = 47.88;

// Thread tolerance FDM
tripod_screw_dia_male = 6.25;

// Female dilonggarkan: cukup untuk male printed
// (part bawah) maupun male logam (ball head).
// Naikkan angka ini kalau masih seret,
// turunkan kalau terlalu longgar/oblak.
tripod_screw_dia_female = 6.90;

screw_length = 7.0;


// Base
total_target_height = 70.0;

base_thick = 3;
top_sub_base_thick = 3.0;

stick_height =
    total_target_height
    - ball_head_height
    - base_thick
    - top_sub_base_thick;

stick_dia = 14.0;


// Lubang base bawah
num_base_holes = 6;
base_hole_radius = 10.5;

// Diameter lubang clearance baut M2 di base (6 buah).
// Bukan lubang ulir - baut hanya lewat, dikencangkan
// dengan mur di sisi casing Raspi 5.
base_hole_dia = 2.6;


// ==========================================
// BOSL2 THREAD MODULES
// ==========================================

// Male 1/4"-20 UNC
module tripod_male_thread(h=7)
{
    threaded_rod(
        d = tripod_screw_dia_male,
        l = h,
        pitch = 1.27,
        internal = false,
        blunt_start = true
    );
}


// Female 1/4"-20 UNC
module tripod_female_thread_cutter(h=8)
{
    threaded_rod(
        d = tripod_screw_dia_female,
        l = h,
        pitch = 1.27,
        internal = true,
        blunt_start = true
    );
}


// ==========================================
// PART ATAS
// ==========================================

module part_atas_camera_holder()
{
    plate_w = cam_hole_dist_x + 8;

    // tinggi pelat dihitung otomatis
    plate_h =
        bottom_hole_margin
        + cam_hole_dist_y
        + top_hole_margin;

    hub_height = 15;
    hub_dia = 15;

    // Offset vertikal pangkal pelat kamera.
    // hub_height/2 = pelat nempel di permukaan atas hub.
    plate_offset_z = hub_height/2;


    difference()
    {
        // ==================================
        // BODY UTAMA
        // ==================================
        union()
        {
            // Pelat kamera
            translate([
                -plate_w/2,
                -cam_plate_thick/2,
                plate_offset_z
            ])
                cube([
                    plate_w,
                    cam_plate_thick,
                    plate_h
                ]);


            // Sirip penguat
            hull()
            {
                translate([
                    -plate_w/2,
                    -cam_plate_thick/2,
                    plate_offset_z
                ])
                    cube([
                        plate_w,
                        cam_plate_thick,
                        2
                    ]);

                translate([0,0,-hub_height])
                    cylinder(
                        d = hub_dia,
                        h = 2
                    );
            }


            // Hub silinder
            translate([0,0,-hub_height])
                cylinder(
                    d = hub_dia,
                    h = hub_height + hub_height/2
                );
        }


        // ==================================
        // POSISI LUBANG KAMERA
        // ==================================

        // bawah pelat
        plate_bottom_z = plate_offset_z;

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
        // FEMALE THREAD
        // ==================================
        translate([0,0,-(hub_height+0.1)])
            tripod_female_thread_cutter(h=10);
    }
}



// ==========================================
// PART BAWAH
// ==========================================

module part_bawah_stick_and_base()
{
    difference()
    {
        union()
        {
            // Base bawah
            cylinder(
                d = ball_head_dia,
                h = base_thick
            );


            // Stick
            translate([0,0,base_thick])
                cylinder(
                    d = stick_dia,
                    h = stick_height
                );


            // Top base
            translate([
                0,
                0,
                base_thick + stick_height
            ])
                cylinder(
                    d = ball_head_dia,
                    h = top_sub_base_thick
                );


            // Male thread
            translate([
                0,
                0,
                base_thick
                + stick_height
                + top_sub_base_thick
            ])
                tripod_male_thread(h=screw_length);
        }


        // Lubang base bawah
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

mode = "all_parts";

// pilihan:
// "all_parts"
// "print_part_atas"
// "print_part_bawah"



if (mode == "all_parts")
{
    part_bawah_stick_and_base();

    translate([
        0,
        0,
        base_thick
        + stick_height
        + top_sub_base_thick
        + screw_length
        + 25
    ])
        part_atas_camera_holder();
}



if (mode == "print_part_atas")
{
    translate([0,0,cam_plate_thick/2])
        rotate([-90,0,0])
            part_atas_camera_holder();
}



if (mode == "print_part_bawah")
{
    part_bawah_stick_and_base();
}