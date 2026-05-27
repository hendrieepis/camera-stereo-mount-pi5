# Camera Stereo Mount Pi5 — 90°

Dudukan kamera CSI stereo untuk Raspberry Pi 5, konfigurasi siku 90°.
Repo ini berisi empat versi desain (V3, V4, V5, V6) dalam format OpenSCAD `.scad`.

---

## Kamera yang Didukung

![Waveshare IMX219-83 Stereo Camera](https://www.waveshare.com/media/catalog/product/cache/1/image/800x800/9df78eab33525d08d6e5fb8d27136e95/i/m/imx219-83-stereo-camera-1.jpg)

Desain mount ini dibuat dan diuji untuk kamera:

**Waveshare Binocular Camera Module — IMX219-83 Stereo Camera**
- Sensor: Dual IMX219, 8 Megapixel per lensa
- FOV: 83°
- Antarmuka: CSI (kompatibel Raspberry Pi 5 dan Jetson Nano)
- Fitur: Stereo vision, depth vision
- Jarak antar lubang baut: 20.45mm (X) × 13.87mm (Y)
- Baut mounting: M2

Beli di: [Waveshare IMX219-83 Stereo Camera](https://www.waveshare.com/product/raspberry-pi/boards-kits/raspberry-pi-5/imx219-83-stereo-camera.htm)

---

## Perbedaan V3, V4, V5, V6

Keempat versi punya fungsi sama — menahan pelat kamera tegak lurus terhadap base
yang dibaut ke casing Raspberry Pi 5. Yang berbeda adalah **cara part disambung
dan apakah sudut kamera bisa disetel**.

| Aspek | V3 | V4 | V5 | V6 |
|---|---|---|---|---|
| Penyambung | Ball head (beli) | Batang ulir terpisah | Tidak ada — menyatu | Engsel knuckle BOSL2 |
| Jumlah part cetak | 2 | 3 | 1 | 2 |
| Ulir | 1/4"-20 (ke ball head) | 1/4"-20 (di rod) | Tidak ada | Tidak ada |
| Bisa dibongkar | Ya | Ya | Tidak | Ya |
| Setel sudut tilt | Ya (via ball head) | Tidak | Tidak | Ya, ±15° atas-bawah |
| Komponen beli | Ball head 1/4" | Threaded rod / baut M4 | — | Baut M4×25mm + mur M4 |

### V3 — dengan ball head
Part atas dan part bawah tidak tersambung langsung. Di antara keduanya
dipasang **ball head** (komponen tripod yang dibeli jadi). Part bawah punya
ulir male di puncak stick yang masuk ke lubang female ball head; part atas
punya lubang female yang menerima ulir male di atas ball head. Ball head
memberi kebebasan mengatur sudut kamera ke segala arah.

### V4 — batang ulir terpisah
Ball head dihilangkan. Sebagai gantinya dipakai **connector rod**: satu
batang dengan ulir male 1/4"-20 di kedua ujung dan batang polos di tengah.
Part atas dan part bawah dua-duanya punya lubang ulir female; connector rod
disekrup ke keduanya. Masih bisa dibongkar, tetapi sudut sudah tetap (90°).

Connector rod bisa dicetak, namun **disarankan memakai threaded rod 1/4"-20
dari logam** (potong sepanjang ±26 mm) karena ulir hasil cetak FDM rapuh
terhadap puntiran.

### V5 — satu objek utuh
Tanpa ulir, tanpa penyambung. Base, stick, dan pelat kamera **menyatu jadi
satu objek** yang dicetak sekaligus. Paling kuat dan paling sederhana, tetapi
tidak bisa dibongkar dan ukuran cetaknya paling besar.

### V6 — engsel tilt dengan friction lock
Pelat kamera bisa **tilt atas-bawah ±15°** dan dikunci di posisi manapun.
Menggunakan modul `knuckle_hinge()` dari library BOSL2. Ada dua part cetak:
bracket (base + stick + knuckle outer) dan tilt plate (pelat kamera + knuckle
inner). Poros engsel sekaligus pengunci menggunakan **baut M4 polos** (tidak
berulir di barrel) — baut tinggal ditusuk, mur dipasang di ujung, kencangkan
untuk mengunci sudut tilt.

---

## Cara Cetak — memisah part per versi

Pemisahan part dilakukan lewat variabel `mode` di dalam file `.scad`, dekat
bagian akhir file pada blok **MODE RENDER**.

Cara pakai: buka file di OpenSCAD → ubah nilai `mode` → tekan **F6** (render
penuh) → **File → Export → Export as STL** → ulangi untuk tiap part.

### Pilihan mode V3

```
mode = "all_parts";        // tampilan rakitan — JANGAN diexport STL
mode = "print_part_atas";  // pelat kamera + hub
mode = "print_part_bawah"; // base + stick
```

V3 menghasilkan **2 file STL**: part atas dan part bawah.
Ball head tidak dicetak — komponen beli.

### Pilihan mode V4

```
mode = "all_parts";           // tampilan rakitan — JANGAN diexport STL
mode = "print_part_atas";     // pelat kamera + hub berlubang ulir
mode = "print_part_bawah";    // base + stick + hub berlubang ulir
mode = "print_connector_rod"; // batang ulir penyambung (opsional)
```

V4 menghasilkan **3 file STL**: part atas, part bawah, connector rod.
Connector rod boleh dilewati bila memakai threaded rod logam.

### Pilihan mode V5

V5 hanya satu objek, tidak ada mode pemisahan part. Cukup buka file,
tekan F6, lalu export STL langsung.

### Pilihan mode V6

```
mode = "assembly";         // preview rakitan — JANGAN diexport STL
mode = "print_bracket";    // base + stick + knuckle outer engsel
mode = "print_tilt_plate"; // pelat kamera CSI + knuckle inner engsel
```

V6 menghasilkan **2 file STL**: bracket dan tilt plate.

Untuk preview sudut tilt di mode `assembly`, ubah variabel:

```
preview_tilt = 0;    // posisi tengah (default)
preview_tilt = 15;   // tilt ke belakang
preview_tilt = -15;  // tilt ke depan
```

### Catatan orientasi cetak

- V3 `print_part_atas` — sudah otomatis direbahkan, pelat tidur di bed.
- V3/V4 `print_part_bawah` — berdiri dengan base menempel di bed.
- V6 `print_bracket` — berdiri dengan base di bed, knuckle di atas.
- V6 `print_tilt_plate` — pelat tidur di bed, knuckle berdiri di sisi.
- Mode `all_parts` / `assembly` hanya untuk cek susunan, jangan diexport STL.

---

## Komponen Beli per Versi

### V3
- Ball head kamera 1/4"-20 (beli jadi, ukuran standar tripod)

### V4
- Threaded rod 1/4"-20 panjang ±26mm (bisa potong dari rod lebih panjang)
- Atau: baut 1/4"-20 + mur sebagai pengganti rod

### V5
- Tidak ada komponen beli

### V6
- **Baut M4 × 25mm, kepala socket (hex dalam / Allen)** — 1 buah
- **Mur M4** — 1 buah
- **Washer M4** — 2 buah (opsional, bikin tekanan pengunci lebih merata)

Cara pasang V6: tusuk baut dari satu sisi barrel knuckle (lubang polos,
tidak berulir, baut M4 langsung masuk bebas), pasang mur di sisi lain,
kencangkan dengan obeng hex + kunci 7mm hingga tilt plate terjepit dan
tidak bergerak. Kendorkan untuk ganti sudut tilt.

---

## Instalasi Library BOSL2

Semua versi (V3–V6) memakai library **BOSL2**. V3/V4 memakai `threading.scad`
untuk ulir; V5/V6 memakai `std.scad` dan `hinges.scad`. Tanpa BOSL2, file
tidak bisa dirender dan akan muncul error `Can't open include file`.

Library harus diletakkan di folder **libraries** milik OpenSCAD.

### Lokasi folder libraries

| OS | Lokasi |
|---|---|
| Windows | `Documents\OpenSCAD\libraries` |
| Linux | `~/.local/share/OpenSCAD/libraries` |

Cara pasti menemukannya: di OpenSCAD buka menu **File → Show Library Folder**.

### Cara 1 — Download manual (paling mudah)

1. Buka `https://github.com/BelfrySCAD/BOSL2/releases`
2. Download `Source code (zip)`
3. Ekstrak, ganti nama folder hasil ekstrak menjadi tepat `BOSL2`
4. Pindahkan folder `BOSL2` ke folder libraries

Struktur akhir yang benar:

```
libraries/
└── BOSL2/
    ├── std.scad
    ├── hinges.scad
    ├── threading.scad
    └── ... (file lain)
```

### Cara 2 — Lewat Git

#### Windows

```
mkdir %USERPROFILE%\Documents\OpenSCAD\libraries
cd %USERPROFILE%\Documents\OpenSCAD\libraries
git clone https://github.com/BelfrySCAD/BOSL2.git
```

#### Linux

```
mkdir -p ~/.local/share/OpenSCAD/libraries
cd ~/.local/share/OpenSCAD/libraries
git clone https://github.com/BelfrySCAD/BOSL2.git
```

### Verifikasi

Tutup dan buka ulang OpenSCAD, lalu buka salah satu file dan tekan F5.
Bila tidak ada error `Can't open include file 'BOSL2/std.scad'`, instalasi
berhasil.

---

## Ringkasan Parameter Penting

Parameter berada di bagian atas tiap file `.scad` dan bisa diubah langsung.
Setelah mengubah parameter, render ulang (F6) sebelum export STL.

---

## Lisensi

Desain ini dirilis di bawah lisensi **Creative Commons Attribution 4.0 International (CC BY 4.0)**.

Kamu bebas untuk:
- **Berbagi** — menyalin dan mendistribusikan materi ini dalam medium atau format apapun
- **Adaptasi** — menggubah, mengubah, dan membuat turunan dari materi ini untuk keperluan apapun, termasuk komersial

Dengan syarat:
- **Atribusi** — kamu harus mencantumkan kredit yang sesuai, menyertakan link ke lisensi, dan menyatakan jika ada perubahan yang dibuat. Kredit harus menyebut nama pembuat asli.

**Pembuat:** Akhmad Hendriawan — Wireless Sensor Network Laboratory, PENS (Politeknik Elektronika Negeri Surabaya)

**Repository:** https://github.com/hendrieepis/camera-stereo-mount-pi5

**Link lisensi:** https://creativecommons.org/licenses/by/4.0/

---

*Desain ini dibuat secara sukarela untuk melengkapi produk Waveshare IMX219-83
yang tidak disertai bracket/mount. Jika desain ini bermanfaat bagimu, cukup
cantumkan kredit dan bagikan ke orang lain yang membutuhkan.*

| Parameter | Versi | Fungsi |
|---|---|---|
| `cam_hole_dist_x` / `_y` | Semua | Jarak antar lubang baut kamera CSI |
| `m2_dia` | Semua | Diameter lubang baut kamera M2 (clearance) |
| `bottom_hole_margin` | Semua | Jarak lubang bawah ke tepi bawah pelat |
| `top_hole_margin` | Semua | Jarak lubang atas ke tepi atas pelat |
| `base_hole_dia` | Semua | Diameter 6 lubang M2 di base ke casing Raspi |
| `stick_height` | Semua | Tinggi batang stick |
| `tripod_screw_dia_female` | V3/V4 | Diameter lubang ulir — perbesar bila seret |
| `hinge_len` | V6 | Panjang barrel engsel (sumbu X) |
| `hinge_segs` | V6 | Jumlah segmen knuckle (ganjil = simetris) |
| `hinge_offset` | V6 | Jarak barrel dari permukaan leaf |
| `knuckle_d` | V6 | Diameter barrel engsel |
| `preview_tilt` | V6 | Sudut tilt untuk preview assembly (-15..+15) |
