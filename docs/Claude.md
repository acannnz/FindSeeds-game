# FindSeeds — Catatan Proyek untuk Claude

Ringkasan dari `docs/Rancangan Game Farming Puzzle — Musim Semi.md` (acuan utama).
Baca dokumen lengkapnya hanya jika butuh detail yang tidak ada di sini.

## Status

| Fase | Isi | Status |
| --- | --- | --- |
| 1 | Rencana: struktur folder, daftar file | Selesai |
| 2 | Data: katalog, pengaturan, 3 file stage | Belum |
| 3 | Pemeriksa stage (6 pengecekan, CLI) | Belum |
| 4 | Pemuat peta, gerak, tabrakan | Belum |
| 5 | Interaksi: aksi kontekstual, identifikasi, alat, wadah, kantong | Belum |
| 6 | Tanam, panen, pesanan, menang otomatis | Belum |
| 7 | Timer, restart < 1 detik, bintang, stage berikutnya | Belum |

Kerjakan per fase. Setelah tiap fase: jelaskan singkat, commit, push ke `origin main`, lalu tunggu konfirmasi.

## Teknologi

- Godot 4.6.2-stable, GDScript. Executable: `D:\Download\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64_console.exe`
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
- **Git:** commit tiap fase lalu push ke `origin main` (https://github.com/acannnz/FindSeeds-game.git).

## Tafsiran dokumen yang dipakai

1. Format stage persis contoh `stage_1-3.json`: peta string tanpa spasi; penghalang di legenda ditulis `"penghalang"`.
2. Simbol umum dibaca kode, tidak masuk legenda: `#` dinding, `.` lantai, `@` awal pemain, `T` tanah, `B` pembeli.
3. `B` padat dan tidak wajib dijangkau flood fill. `T` bisa diinjak.
4. Jenis benda disimpulkan dari katalog: `hasil` ≠ null → sumber; `hasil: null` → kosong; `butuh_alat` → wadah; `jenis: "alat"` → alat; `jenis: "penghalang"` → penghalang. Pengecoh = sumber yang hasilnya tidak ada di pesanan stage itu.
5. Jeda 4 stage hanya untuk benda sumber, kosong, dan pengecoh (termasuk isi wadah). Alat, wadah, penghalang dikecualikan. Selisih urutan stage ≥ 4.
6. Pengecekan "cukup benda sumber" menghitung isi wadah.
7. Panen melebihi jumlah pesanan dianggap tidak dipesan.
8. Di luar lingkup sekarang: tutorial (timer langsung jalan), musik, animasi reaksi (cukup teks). Setelah 1-3 kembali ke 1-1.

## Struktur folder

```
project.godot
CLAUDE.md                    mengimpor docs/Claude.md
data/
  katalog_benda.json         sifat semua benda
  pengaturan.json            semua angka penyetelan
  stage/stage_1-1.json …     peta, legenda, pesanan, ambang bintang
scripts/
  inti/                      logika murni (bukan Node), dipakai game dan pemeriksa
    pemuat_data.gd, kantong.gd, pesanan.gd, bintang.gd
  autoload/
    data_game.gd             memuat pengaturan + katalog
    alur_stage.gd            stage aktif, urutan stage (dari id file)
  game/
    stage.gd, peta.gd, pemain.gd, benda.gd, petak_tanah.gd
  ui/
    hud.gd, joystick.gd, tombol_aksi.gd, layar_hasil.gd
scenes/                      main.tscn, stage.tscn, pemain.tscn, ui/*.tscn
tools/
  pemeriksa_stage.gd         extends SceneTree, 6 pengecekan, exit code 1 jika gagal
  periksa.bat                pembungkus command line
```

Aturan kode: tidak ada angka penyetelan atau posisi benda di kode; semuanya dari `data/`.

## Menjalankan pemeriksa stage

(Diisi di Fase 3.)
