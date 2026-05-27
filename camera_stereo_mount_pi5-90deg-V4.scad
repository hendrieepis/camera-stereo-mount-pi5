// ==========================================
// CAMERA STEREO MOUNT PI5 - 90 DEG - V4
// ------------------------------------------
// Perubahan dari V3:
// - Ball head DIHAPUS.
// - Part atas & part bawah disambung dengan
//   BATANG ULIR 1/4"-20 TERPISAH (connector rod).
// - Kedua part punya lubang ulir FEMALE.
// - Bisa dibongkar. Sudut tetap 90 derajat.
// ==========================================

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


// ==========================================
// THREAD 1/4"-20 UNC
// ==========================================

// Diameter ulir male.
// 6.25 = nominal 1/4" dikurangi sedikit untuk FDM.
tripod_screw_dia_male = 6.25;

// Diameter cutter ulir female (lubang).
// Dilonggarkan supaya batang ulir masuk
// tanpa dipaksa. Naikkan kalau seret,
// turunkan kalau oblak.
tripod_screw_dia_female = 6.90;

// Kedalaman lubang female di tiap part.
female_thread_depth = 10.0;


// ==========================================
// CONNECTOR ROD (batang ulir penyambung)
// ==========================================

// Panjang ulir male di TIAP ujung batang.
// Harus <= female_thread_depth.
rod_thread_each_end = 9.0;

// Panjang bagian tengah batang (polos, tanpa ulir).
// Ini jarak bebas antara part atas & part bawah.
rod_middle_length = 8.0;

// Diameter bagian tengah batang polos.
// 6.35 = diameter nominal ulir 1/4 inch.
rod_middle_dia = 6.35;


// ==========================================
// BASE & STICK
// ==========================================

total_target_height = 70.0;

base_thick = 2.5;
top_sub_base_thick = 3.0;

// Diameter piringan base (atas & bawah)
base_disc_dia = 28.35;

// Diameter batang stick.
// 6.35 = sebesar diameter ulir 1/4 inch.
stick_dia = 6.35;

// Hub di puncak stick untuk menampung ulir
// female. Dibuat lebih gemuk dari stick agar
// dinding di sekeliling ulir cukup tebal.
stick_hub_dia = 12.0;
stick_hub_height = 12.0;

// Tinggi stick dihitung otomatis supaya
// total tinggi part bawah mendekati target.
stick_height =
    total_target_height
    - base_thick
    - top_sub_base_thick
    - stick_hub_height;


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


// Female 1/4"-20 UNC (cutter)
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
// CONNECTOR ROD
// ------------------------------------------
// Batang ulir terpisah: ulir male di kedua
// ujung, batang polos di tengah.
// Disekrup ke part atas & part bawah.
//
// CATATAN: untuk sambungan yang kuat, batang
// ini sebaiknya diganti dengan threaded rod
// 1/4"-20 dari logam. Versi cetak ini hanya
// untuk uji rakit / cadangan.
// ==========================================

module connector_rod()
{
    // Disusun dari bawah ke atas. threaded_rod()
    // ber-anchor di center, jadi tiap ulir digeser
    // +l/2 dari batas bawahnya. cylinder ber-anchor
    // di base. Total panjang rod:
    //   rod_thread_each_end*2 + rod_middle_length

    // ulir male bawah: batas bawah z=0,
    // center = rod_thread_each_end/2
    translate([0,0,rod_thread_each_end/2])
        tripod_male_thread(h=rod_thread_each_end);

    // batang tengah polos: mulai tepat di ujung
    // atas ulir bawah (z = rod_thread_each_end)
    translate([0,0,rod_thread_each_end])
        cylinder(
            d = rod_middle_dia,
            h = rod_middle_length
        );

    // ulir male atas: batas bawah di ujung batang
    // tengah, center = batas + rod_thread_each_end/2
    translate([
        0,
        0,
        rod_thread_each_end
        + rod_middle_length
        + rod_thread_each_end/2
    ])
        tripod_male_thread(h=rod_thread_each_end);
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
        // FEMALE THREAD (untuk connector rod)
        // ==================================
        translate([0,0,-(hub_height+0.1)])
            tripod_female_thread_cutter(h=female_thread_depth);
    }
}



// ==========================================
// PART BAWAH
// ------------------------------------------
// V4: tanpa male thread di puncak.
// Puncak stick diberi hub + lubang ulir
// FEMALE untuk menerima connector rod.
// ==========================================

module part_bawah_stick_and_base()
{
    difference()
    {
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


            // Top base (piringan transisi)
            translate([
                0,
                0,
                base_thick + stick_height
            ])
                cylinder(
                    d = base_disc_dia,
                    h = top_sub_base_thick
                );


            // Hub puncak - penampung ulir female
            translate([
                0,
                0,
                base_thick
                + stick_height
                + top_sub_base_thick
            ])
                cylinder(
                    d = stick_hub_dia,
                    h = stick_hub_height
                );
        }


        // ==================================
        // FEMALE THREAD di puncak hub
        // ==================================
        // threaded_rod() BOSL2 ber-anchor di CENTER
        // (membentang +/- l/2 dari titik translate).
        // Agar lubang sedalam female_thread_depth dan
        // ujung atasnya tembus permukaan hub:
        //   center cutter = hub_top - depth/2 + lebih
        hub_top_z =
            base_thick
            + stick_height
            + top_sub_base_thick
            + stick_hub_height;

        translate([
            0,
            0,
            hub_top_z - female_thread_depth/2 + 1
        ])
            tripod_female_thread_cutter(h=female_thread_depth);


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

mode = "all_parts";

// pilihan:
// "all_parts"
// "print_part_atas"
// "print_part_bawah"
// "print_connector_rod"


// jarak bebas antar part saat dirakit (visual)
assembly_gap = rod_middle_length;


if (mode == "all_parts")
{
    // part bawah
    part_bawah_stick_and_base();

    // tinggi puncak hub part bawah
    bawah_top_z =
        base_thick
        + stick_height
        + top_sub_base_thick
        + stick_hub_height;

    // connector rod, ulir bawah masuk ke part bawah
    translate([
        0,
        0,
        bawah_top_z - rod_thread_each_end
    ])
        connector_rod();

    // part atas, hub-nya duduk di atas connector rod.
    // hub part atas tingginya dari -hub_height..+hub_height/2
    // sehingga dasar hub = bawah_top_z + rod_middle_length.
    translate([
        0,
        0,
        bawah_top_z
        + rod_middle_length
        + 15   // = hub_height part atas
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



if (mode == "print_connector_rod")
{
    connector_rod();
}
