# FindSeeds — Catatan Proyek untuk Claude

Ringkasan dari `docs/Rancangan Game Farming Puzzle — Musim Semi.md` (acuan utama).
Baca dokumen lengkapnya hanya jika butuh detail yang tidak ada di sini.

## Status

| Fase | Isi | Status |
| --- | --- | --- |
| 1 | Rencana: struktur folder, daftar file | Selesai |
| 2 | Data: katalog, pengaturan, 3 file stage | Selesai |
| 3 | Pemeriksa stage (6 pengecekan, CLI) | Selesai |
| 4 | Pemuat peta, gerak, tabrakan | Selesai |
| 5 | Interaksi: aksi kontekstual, identifikasi, alat, wadah, kantong | Selesai |
| 6 | Tanam, panen, pesanan, menang otomatis | Selesai |
| 7 | Timer, restart < 1 detik, bintang, stage berikutnya | Selesai |

Kerjakan per fase. Setelah tiap fase: jelaskan singkat, commit, push ke `origin main`, lalu tunggu konfirmasi.

## Teknologi

- Godot 4.7.2-stable, GDScript. Executable CLI: `D:\Download\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64_console.exe` (editor: `Godot_v4.7.2-stable_win64.exe` di folder yang sama)
- Target Android, layar portrait. Placeholder kotak warna + huruf, belum ada aset.
- Peta 8 × 12 petak di dua pertiga atas layar; sepertiga bawah: joystick (kiri), satu tombol aksi (kanan).
- Lingkup prototipe: Stage 1-1, 1-2, 1-3. Tanpa menu, musim lain, suara, art, tutorial.

## Aturan main (ringkas)

- Stage 90 detik. Cari benda yang bisa jadi benih, tanam, panen. Panen yang dipesan langsung mengisi pesanan.
- Menang: pesanan lengkap (otomatis). Kalah: waktu habis → "Waktu habis!" → ulang < 1 detik.
- Tombol aksi kontekstual untuk benda terdekat dalam 1 petak: Identifikasi, Ambil, Potong, Tanam, Panen.
- Identifikasi: sumber → benih masuk kantong; kosong → reaksi lalu abu-abu; pengecoh → benih yang hasilnya tidak dipesan.
- Wadah tertutup: ikon alat muncul saat didekati, tanpa memotong waktu. Setelah dibuka, isinya tertinggal di tempat lalu diidentifikasi biasa.
- Tangan pegang 1 alat; ambil alat lain = tukar, alat lama ditaruh di tempat. Alat tidak habis.
- Kantong maks 3 benih. Penuh → benda sumber tidak bisa diidentifikasi. Benih tidak bisa dibuang.
- Satu petak tanah = satu tanaman, matang 1,5 detik (pemain bisa bergerak selama tumbuh).
- Panen tidak dipesan → hilang, pembeli menggeleng. Timer merah di 10 detik terakhir.
- Timer berhenti saat aplikasi ke latar belakang.
- Bintang: 1 = selesai; 2/3 = sisa waktu ≥ ambang per stage.

Durasi (semua dari `data/pengaturan.json`): jalan 4 petak/detik, identifikasi 2, ambil/tukar alat 0,5, pakai alat 1,5, tanam 1, tumbuh 1,5, panen 0,5 (detik). Semua aksi kecuali tumbuh mengunci gerak.

## Keputusan yang sudah dikonfirmasi pengguna

- **Benih yang ditanam:** urutan masuk (FIFO), paling lama ditanam duluan.
- **Benda padat:** benda menempati petaknya dan tidak bisa dilewati; diinteraksi dari petak sebelah.
- **Wadah tanpa alat:** ikon alat di atas wadah, tombol tampil abu-abu "Potong" dan tidak bisa ditekan.
- **Kantong penuh:** Identifikasi dikunci untuk SEMUA benda yang belum dicoba (tombol abu-abu "Kantong penuh"), supaya tidak membocorkan mana yang sumber. Ambil dan Potong tetap bisa.
- **Pemecah seri target:** jika dua target berselisih jarak ≤ `toleransi_seri_petak`, pilih yang paling searah dengan `pemain.hadap`.
- **Git:** commit tiap fase lalu push ke `origin main` (https://github.com/acannnz/FindSeeds-game.git).

## Tafsiran dokumen yang dipakai

1. Format stage persis contoh `stage_1-3.json`: peta string tanpa spasi; penghalang di legenda ditulis `"penghalang"`.
2. Simbol umum dibaca kode, tidak masuk legenda: `#` dinding, `.` lantai, `@` awal pemain, `T` tanah, `B` pembeli.
3. `B` padat dan tidak wajib dijangkau flood fill. `T` bisa diinjak.
4. Jenis benda disimpulkan dari katalog: `hasil` ≠ null → sumber; `hasil: null` → kosong; `butuh_alat` → wadah; `jenis: "alat"` → alat; `jenis: "penghalang"` → penghalang. Pengecoh = sumber yang hasilnya tidak ada di pesanan stage itu.
5. Jeda 4 stage hanya untuk benda sumber, kosong, dan pengecoh (termasuk isi wadah). Alat, wadah, penghalang dikecualikan. Selisih urutan stage ≥ 4.
6. Pengecekan "cukup benda sumber" menghitung isi wadah.
7. Panen melebihi jumlah pesanan dianggap tidak dipesan.
8. Sumber/pengecoh yang diidentifikasi hilang dari peta (berubah jadi benih). Benda kosong tetap di tempat, abu-abu, padat.
9. Jarak interaksi diukur pusat pemain ke pusat petak benda ≤ `jarak_interaksi_petak` (+0,5 satuan). Target = benda terdekat yang punya aksi; benda abu-abu diabaikan.
10. Tukar alat: alat lama ditaruh di petak alat yang baru diambil. Benda hasil buka wadah / alat tukaran memakai huruf pertama namanya.
11. Petak tanah: kosong tanpa benih dan tanaman yang sedang tumbuh tidak menawarkan aksi (tidak menutupi benda di sebelahnya). Pemain berdiri di atas petak untuk Tanam/Panen.
12. Gelembung pesanan digambar di baris dinding atas, di atas/kanan pembeli, memanjang ke tepi kanan peta. Centang digambar dengan garis (font bawaan tak punya ✓).
13. Jeda latar belakang: NOTIFICATION_APPLICATION_PAUSED/FOCUS_OUT → `get_tree().paused` (timer, aksi, tanaman, jeda ulang ikut berhenti), layar "Dijeda". RESUMED/FOCUS_IN melanjutkan. Di desktop, klik di luar jendela juga menjeda.
14. Menang → layar hasil (bintang, sisa waktu, Ulangi/Lanjut). Waktu habis → "Waktu habis!" selama `jeda_ulang_detik` (0,8) lalu stage dimuat ulang. Setelah stage terakhir, "Ke awal" kembali ke 1-1. Bintang belum disimpan antar sesi.
15. Di luar lingkup sekarang: tutorial (timer langsung jalan), musik, animasi reaksi (cukup teks). Setelah 1-3 kembali ke 1-1.

## Struktur folder

```
project.godot
CLAUDE.md                    mengimpor docs/Claude.md
data/
  katalog_benda.json         sifat semua benda
  pengaturan.json            semua angka penyetelan
  pembeli.json               nama tampilan pembeli (id → nama)
  stage/stage_1-1.json …     peta, legenda, pesanan, ambang bintang
scripts/
  inti/                      logika murni (bukan Node)
    pemuat_data.gd           baca JSON, simbol umum, jenis benda (dipakai game + pemeriksa)
    pemeriksa.gd             logika 6 pengecekan + cek format, mengembalikan daftar temuan
    data_game.gd             data bersama via static var + _static_init (BUKAN autoload)
    kantong.gd               kantong benih FIFO, kapasitas dari pengaturan
    aturan_aksi.gd           aksi kontekstual per benda (label, aktif, alasan, butuh_alat)
    pesanan.gd               diminta/terisi per tanaman; terima() menolak yang tidak dipesan atau berlebih
    bintang.gd               hitung(sisa, ambang): ≥ tiga → 3, ≥ dua → 2, selain itu 1
  game/
    main.gd                  alur stage (PROCESS_MODE_ALWAYS): muat/ulang/lanjut, bintang, waktu habis, jeda latar belakang; galat data; pintasan debug
    stage.gd                 bangun peta, pesanan, pemain di @, timer mundur, tata letak + kamera; sinyal `selesai(sisa)` / `waktu_habis`
    peta.gd                  gambar lantai/dinding/B/penghalang, tabrakan petak padat
    benda.gd                 StaticBody2D per benda (padat): status normal/abu, buka(), ganti_menjadi(), sorot, ikon alat
    interaksi.gd             target terdekat (benda + tanah), aksi berdurasi (kunci gerak), kantong, alat, panen → pesanan; hentikan()
    teks_melayang.gd         teks reaksi / "+ Benih tomat" yang naik lalu memudar
    petak_tanah.gd           petak T (bisa diinjak): kosong → tumbuh (durasi tumbuh) → matang; tanam(), panen()
    pembeli.gd               pembeli B + gelembung pesanan, centang, geleng
    pemain.gd                CharacterBody2D (motion floating), joystick/panah, `arah_paksa` utk uji
    gambar.gd                pembantu gambar placeholder (huruf di tengah, warna kontras)
  ui/
    joystick.gd              joystick mengambang, melacak satu indeks sentuhan
    tombol_aksi.gd           tombol kontekstual: nama target, label, alasan, cincin progres; Spasi/Enter di desktop
    hud.gd                   nama stage, timer m:ss (merah ≤ timer_merah_sisa_detik), slot kantong, alat di tangan
    layar_hasil.gd           layar menang / "Waktu habis!" / "Dijeda" (scenes/layar_hasil.tscn)
    tampilan_bintang.gd      bintang digambar poligon
scenes/                      main.tscn, stage.tscn, pemain.tscn, layar_hasil.tscn
tools/
  pemeriksa_stage.gd         CLI (extends SceneTree), cetak laporan, exit code 1 jika gagal
  uji_pemeriksa.gd           uji mandiri: data asli lolos, tiap kerusakan memicu cek yang tepat
  dasar_uji.gd               dasar semua uji: _cek, _selesai, Logger penghitung galat, batas waktu 120 dtk simulasi
  uji_logika.gd              uji kantong + aturan aksi
  uji_gerak.gd               uji gerak: kecepatan, dinding, penghalang, benda & B padat, celah 1-3
  uji_interaksi.gd           uji interaksi di 1-3 sungguhan, tukar alat, panen pengecoh di 1-2
  uji_main.gd                bot (rute BFS) memainkan solusi tercepat dokumen tiap stage, ukur waktu vs ambang 3 bintang
  uji_alur.gd                timer, jeda latar belakang, timer merah, waktu habis + ulang < 1 dtk, bintang 3/2/1, lanjut, kembali ke awal
  periksa.bat                pembungkus command line
```

Aturan kode: tidak ada angka penyetelan atau posisi benda di kode; semuanya dari `data/`.

## Format data

**`data/katalog_benda.json`** — kunci = id benda. Kolom dari dokumen: `hasil`, `logika`, `reaksi`, `butuh_alat`, `isi`, `jenis`.
Kolom tambahan prototipe: `nama` (teks tampilan), `warna` (warna kotak placeholder), `teks_reaksi` (benda kosong), `label` (tulisan di wadah).
Legenda penghalang selalu menunjuk id `penghalang`. Benda cadangan (krayon, kemoceng, bantal hati, bola kertas, rok tutu) dan `sekop` sudah ada di katalog walau belum dipakai.

**`data/tanaman.json`** — id tanaman → `nama`, `warna` (slot kantong, teks benih). Semua `hasil` katalog dan isi pesanan harus ada di sini (cek 0).

**`data/pengaturan.json`** — `peta_lebar_petak`, `peta_tinggi_petak`, `porsi_tinggi_peta`, `radius_pemain_petak`, `joystick_radius_px`, `joystick_zona_mati`, `tombol_aksi_radius_px`, `lama_teks_melayang_detik`, `lama_reaksi_pembeli_detik`, `kapasitas_kantong`, `kecepatan_jalan_petak_per_detik`, `jarak_interaksi_petak`, `toleransi_seri_petak`, `durasi_detik.{identifikasi, ambil_alat, pakai_alat, tanam, tumbuh, panen}`, `timer_merah_sisa_detik`, `jeda_ulang_detik`, `jeda_kemunculan_benda_stage`, `logika_per_musim` (angka musim → id logika).

**`data/stage/stage_<id>.json`** — `id`, `nama`, `waktu_detik`, `bintang_sisa_detik.{tiga, dua}`, `pesanan.{pembeli, isi}`, `peta` (12 string × 8 karakter), `legenda` (huruf → id katalog). Urutan stage = urutan id (musim, nomor).

## Catatan teknis Godot

- **Jangan pakai autoload.** Di mode `--script` (skrip uji), nama autoload tidak dikenali saat kompilasi. Data bersama ada di `scripts/inti/data_game.gd`, dipakai lewat `const DataGame := preload("res://scripts/inti/data_game.gd")`.
- **Skrip uji** extends `res://tools/dasar_uji.gd`, harus `await process_frame` dulu sebelum menambah node ke `root` (pohon belum siap di `_initialize`), dan dijalankan dengan `--fixed-fps 60`.
- **Pemeriksa** dipanggil `Pemeriksa.new().periksa(data)` dengan `data` = hasil `PemuatData.muat_semua()`.
- **Satuan dunia** `Stage.UKURAN_PETAK = 64` per petak. Camera2D (jangkar kiri atas) di-zoom agar peta pas di area `porsi_tinggi_peta` bagian atas layar dan berada di tengah.
- **Benda, `B`, `#`, dan penghalang padat.** `.`, `@`, `T` bisa diinjak. Pemain berupa lingkaran dengan radius `radius_pemain_petak`.
- **Pintasan debug** (build debug saja): tombol 1–9 memilih stage, R mengulang stage, panah untuk bergerak.
- **Menjalankan game:** buka proyek di editor Godot 4.7.2 lalu F5. Bisa juga `Godot_v4.7.2-stable_win64.exe --path . --resolution 360x640`.

## Menjalankan pemeriksa stage

```bat
tools\periksa.bat                 :: periksa data\stage, exit 0 = lolos, 1 = ada masalah
tools\periksa.bat --uji           :: uji mandiri pemeriksa (8 kasus)
tools\periksa.bat --semua         :: pemeriksa stage + SEMUA uji (jalankan sebelum commit)
tools\periksa.bat --uji-logika    :: uji kantong dan aturan aksi
tools\periksa.bat --uji-gerak     :: uji gerak dan tabrakan
tools\periksa.bat --uji-interaksi :: uji identifikasi, alat, wadah, kantong penuh, tukar alat, tanam/panen pengecoh
tools\periksa.bat --uji-main      :: bot memainkan solusi tercepat 1-1/1-2/1-3 (hasil: 8,9 / 16,9 / 24,7 dtk)
tools\periksa.bat --uji-alur      :: timer, jeda, waktu habis + ulang (0,78 dtk), bintang, lanjut
tools\periksa.bat --stage=FOLDER  :: periksa folder stage lain (--data=FOLDER untuk katalog/pengaturan lain)
```

Langsung tanpa .bat: `godot --headless --path . --script res://tools/pemeriksa_stage.gd -- --stage=FOLDER`.
Lokasi Godot bisa diganti lewat variabel lingkungan `GODOT`. Jalankan pemeriksa + uji setiap kali mengubah `data/` atau `scripts/inti/`.

Pengecekan (nomor sama dengan dokumen):
0. Format: kolom wajib, ukuran peta sesuai pengaturan, tepat satu `@`, ada `T`, tepi peta tidak bisa diinjak, legenda → katalog, pembeli ada, 0 ≤ dua ≤ tiga ≤ waktu, nama file = `stage_<id>.json`. Juga validasi katalog (wadah → alat & isi valid, sumber punya `logika`).
1. Tiap tanaman di pesanan punya cukup benda sumber (isi wadah dihitung).
2. Tiap wadah punya alat yang dibutuhkan di peta yang sama.
3. Tiap huruf peta ada di legenda atau simbol umum.
4. Flood fill 4 arah dari `@` lewat `. @ T`. Tiap `T` harus tercapai; tiap benda (bukan penghalang) harus punya tetangga yang tercapai.
5. Benda sumber/kosong/pengecoh (termasuk isi wadah) tidak muncul lagi sebelum selang `jeda_kemunculan_benda_stage` stage. Selang = selisih posisi dalam daftar stage yang sudah diurutkan, jadi semua stage harus ada di folder.
6. Logika benda sumber sudah diperkenalkan di musim stage itu atau sebelumnya (`logika_per_musim`).
