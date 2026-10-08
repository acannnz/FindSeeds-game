# Rancangan Game Farming Puzzle — Musim Semi

Oct 8, 2026 · @candra pratama

## Ringkasan konsep

Setiap stage adalah teka-teki 90 detik: pemain memenuhi pesanan pembeli dengan benih yang didapat dari benda-benda konyol di sekitarnya.

- **Bentuk:** game 2D mobile dengan layar portrait; karakter digerakkan bebas di peta 8 × 12 petak (lebar × tinggi).
- **Menang:** semua isi pesanan terpenuhi sebelum waktu habis. Setiap hasil panen yang dipesan langsung mengisi pesanan, tanpa perlu mendatangi pembeli.
- **Kalah:** waktu habis, lalu stage langsung diulang dari awal.
- **Pembeda:** benih tidak dibeli. Pemain menebak benda mana yang bisa jadi benih dari kemiripan warna dan bentuk dengan tanaman yang dipesan, misalnya bola karet merah menjadi benih tomat.
- **Tanaman tumbuh instan** (1,5 detik), jadi tekanan datang dari mencari dan berpikir, bukan dari menunggu.

&#91;embedded content: alur satu stage · 3 keputusan, 2 putaran kembali\]

Tebakan yang salah dan pesanan yang belum lengkap sama-sama mengembalikan pemain ke tahap mencari, jadi di situlah waktu paling banyak habis.

## Aturan inti

Semua angka di bagian ini adalah titik awal untuk prototipe dan perlu disetel lewat uji main.

**Kontrol**

- Layar portrait, satu kanvas tanpa panel kontrol terpisah. Peta selebar layar tepat di bawah HUD atas; area di bawah peta tetap bagian dunia game dan menjadi tempat jempol. Jika layar terlalu pendek (misalnya 16:9), peta diperkecil secukupnya agar area bawah tetap minimal 22% tinggi layar.
- Joystick virtual dinamis untuk bergerak bebas, tidak per petak: tidak terlihat sampai disentuh, muncul di titik sentuh mana pun di separuh kiri layar, alasnya ikut tertarik jika jempol melewati radius, dan memudar saat dilepas.
- Satu tombol aksi melayang di kanan bawah. Labelnya berubah sesuai benda terdekat dalam jarak 1 petak: Periksa (identifikasi), Ambil, Potong, Tanam, atau Panen. Tanpa aksi, tombol kecil dan samar; ada aksi, tombol membesar dan berdenyut. Label aksi juga muncul kecil di atas benda itu. Nama benda yang belum diperiksa TIDAK ditampilkan: pemain menebak dari gambar saja, dan namanya baru terungkap setelah diperiksa.
- HUD (timer, kantong benih, alat di tangan) melayang di tepi atas layar.

**Durasi aksi**

Pemain berjalan 4 petak per detik, jadi menyeberangi peta dari bawah ke atas (12 petak) butuh sekitar 3 detik.

| Aksi | Durasi | Pemain bisa bergerak? |
| --- | --- | --- |
| Identifikasi | 2 detik | Tidak |
| Ambil atau tukar alat | 0,5 detik | Tidak |
| Pakai alat (potong, gali) | 1,5 detik | Tidak |
| Tanam | 1 detik | Tidak |
| Tanaman tumbuh | 1,5 detik | Ya |
| Panen | 0,5 detik | Tidak |

**Identifikasi**

- Benda sumber benih berubah jadi benih dan masuk kantong.
- Benda kosong memunculkan reaksi lucu, lalu berubah abu-abu supaya tidak dicoba dua kali.
- Benda pengecoh tetap menghasilkan benih, tapi hasil panennya tidak mengisi pesanan.
- Benda hiasan adegan (kursi, pot, tong sampah, dan lain-lain) juga bisa diperiksa: bereaksi lucu lalu abu-abu seperti benda kosong. Hiasan membuat benda petunjuk menyatu dengan adegan, sehingga pemain harus benar-benar mengamati warna dan bentuk.
- Tiap stage digambar sebagai satu adegan utuh bersudut pandang 3/4 tanpa garis petak; benda di depan bisa menutupi pemain.
- Wadah tertutup memunculkan ikon alat yang dibutuhkan saat didekati, tanpa memotong waktu.

**Bawaan**

- Tangan memegang 1 alat. Mengambil alat lain berarti menukar, dan alat lama ditaruh di tempat.
- Alat tidak habis setelah dipakai.
- Kantong benih menampung maksimal 3 benih sejak stage pertama. Saat penuh, benda sumber tidak bisa diidentifikasi sampai ada benih yang ditanam.
- Benih tidak bisa dibuang, jadi benih pengecoh memakan satu slot sampai ditanam.
- Tidak ada keranjang: hasil panen langsung diproses saat dipanen.

**Tanam dan panen**

- Satu petak tanah menampung satu tanaman, yang matang 1,5 detik setelah ditanam.
- Saat dipanen, hasil yang dipesan langsung mengisi pesanan, dan centang muncul di gelembung pesanan pembeli.
- Hasil yang tidak dipesan langsung hilang, dan pembeli menggeleng.
- Stage selesai otomatis begitu item terakhir pesanan terisi.

**Waktu dan ulang**

- Timer 90 detik berhenti saat teks tutorial tampil dan saat aplikasi pindah ke latar belakang.
- Pada 10 detik terakhir, angka timer jadi merah dan musik makin cepat.
- Saat waktu habis, layar "Waktu habis!" tampil, lalu stage diulang dalam kurang dari 1 detik.

**Bintang**

- 1 bintang: stage selesai.
- 2 dan 3 bintang: sisa waktu di atas ambang yang diatur per stage (lihat tiap stage di bawah).

## Kamus benda dan benih Musim Semi

Musim Semi memakai lima tanaman dengan minimal dua benda sumber per tanaman, dan semua pasangannya memakai logika warna dan bentuk.

**Aturan variasi benda**

- **Jeda 4 stage:** benda yang sama, baik sumber benih, benda kosong, maupun pengecoh, baru boleh muncul lagi minimal 4 stage setelah kemunculan terakhirnya. Benda hiasan adegan tidak terkena aturan ini.
- **Dua sifat sekaligus:** benda sumber cocok dengan tanamannya di dua sifat. Benda kosong dan pengecoh sengaja cocok di satu sifat saja, sehingga pemain yang terburu-buru tertipu.
- **Logika baru tiap musim:** setiap musim memperkenalkan satu jenis logika di stage 1–3, dan logika musim sebelumnya tetap dipakai.

| Musim | Logika baru | Contoh |
| --- | --- | --- |
| Semi | Warna dan bentuk | Bola karet merah → tomat |
| Panas | Asosiasi: benda berhubungan dengan tanamannya, tidak harus mirip | Boneka kelinci → wortel, monyet mainan → pisang |
| Gugur | Bunyi nama | Teropong → terong, kentongan → kentang, balon → melon, ayam → bayam |
| Dingin | Varian benda: satu benda dasar dengan beberapa versi yang hasilnya berbeda | Bola merah → tomat, bola hijau bergaris → semangka, bola oranye → jeruk |

**Benda sumber benih Musim Semi**

| Tanaman | Benda sumber | Kenapa masuk akal | Dipakai di |
| --- | --- | --- | --- |
| Tomat | Bola karet merah | Merah dan bulat | 1-1 |
| Tomat | Jam weker merah bundar | Merah dan bulat | 1-2 |
| Tomat | Lampion merah | Merah dan bulat | 1-3 |
| Tomat | Hidung badut | Merah, bulat, empuk | 1-3 |
| Wortel | Kerucut lalu lintas | Oranye dan lancip | 1-2 |
| Wortel | Krayon oranye | Oranye, panjang, lancip | Cadangan |
| Jagung | Spons cuci piring kuning | Kuning dan berlubang kecil seperti barisan biji | 1-3 |
| Jagung | Kemoceng kuning | Kuning dan berumbai seperti rambut jagung | Cadangan |
| Stroberi | Bantalan jarum jahit merah | Merah dengan bintik-bintik | 1-3, sebagai pengecoh |
| Stroberi | Bantal sofa merah berbentuk hati | Merah dan berbentuk hati | Cadangan |
| Kubis | Bola kertas hijau kusut | Hijau dan berlapis-lapis | Cadangan |
| Kubis | Rok tutu hijau | Hijau dan berlapis mengembang | Cadangan |
| Bunga (pengecoh) | Pot bunga | Memang bunga, tapi tidak pernah dipesan | 1-2 |

**Benda kosong**

| Benda | Sifat yang menjebak | Reaksi saat diidentifikasi | Dipakai di |
| --- | --- | --- | --- |
| Kaleng cat merah | Merah, tapi tidak bulat | Cat tumpah ke lantai | 1-2 |
| Kotak pos merah | Merah, tapi kotak | Surat beterbangan | 1-3 |
| Bola tenis | Bulat, tapi hijau kekuningan | Memantul ke sana kemari | 1-2 |
| Kucing tidur | Bulat dan menggemaskan | Mengeong kesal | 1-2 |
| Sepatu (di dalam kardus) | Ada di kardus, seperti hidung badut | Bau, karakter menutup hidung | 1-3 |
| Ember | Alat kebun, tapi kosong | Bunyi "klontang" | 1-1 |
| Sandal jepit | Pengisi latar | Bunyi "plak" | 1-1 |

## Alat Musim Semi

Musim Semi hanya punya dua alat, dan masing-masing membuka satu jenis penghalang.

| Alat | Membuka | Durasi pakai | Pertama muncul |
| --- | --- | --- | --- |
| Gunting | Kardus tertutup dan karung bertali | 1,5 detik | Stage 1-3 |
| Sekop | Gundukan tanah berisi benda terkubur | 1,5 detik | Stage 1-4 |

- Wadah diberi tulisan besar ("MAINAN", "SEPATU") sebagai petunjuk isinya, jadi pemain yang membaca bisa menghemat waktu.
- Setelah dibuka, wadah meninggalkan isinya di tempat, lalu benda itu diidentifikasi seperti biasa.

## Stage 1-1: Halaman Rumah

Stage pertama hanya meminta 1 tomat dan mengajarkan seluruh alur dasar: bergerak, identifikasi, tanam, panen.

**Pesanan:** Bu Ijah minta 1 tomat. **Mekanik baru:** semua alur dasar.

Simbol umum di semua peta: `#` dinding atau pagar, `.` lantai, `@` posisi awal pemain, `T` petak tanah, `B` pembeli (hanya menampilkan pesanan, tidak perlu didatangi). Semua peta berukuran 8 × 12 petak untuk layar portrait.

```
# # # # # # # #
# B . k . . E #
# . m . . . . #
# c . . O . t #
# . . . . . . #
# . . . . b . #
# . S . . . . #
# w . . . R R #
# . . g . R R #
# a . T . R R #
# @ . s . R R #
# # # # # # # #
```

| Simbol | Benda | Hasil identifikasi |
| --- | --- | --- |
| O | Bola karet merah | Benih tomat |
| E | Ember | Kosong |
| S | Sandal jepit | Kosong |
| R | Rumah | Penghalang |
| m | Semak mawar merah | Hiasan (merah, tapi bukan bola) |
| g | Sepeda roda tiga merah | Hiasan (merah, tapi tidak bulat) |
| b | Batu bulat | Hiasan (bulat, tapi abu-abu) |
| k, c, t, w, a, s | Kursi taman, pot kaktus, tong sampah, kaleng siram, mobil mainan, gulungan selang | Hiasan |

Huruf kecil dipakai untuk hiasan adegan. Posisi bola karet, tanah, rumah, dan jalur solusi sama seperti rancangan awal.

**Solusi tercepat, sekitar 9 detik:**

1. Jalan ke bola karet merah, lalu identifikasi (4 detik).
2. Jalan ke petak tanah, tanam, tunggu, lalu panen. Pesanan langsung terisi dan stage selesai (4,5 detik).

**Bintang:** 3 bintang jika sisa waktu minimal 60 detik, 2 bintang jika minimal 40 detik.

**Tutorial:**

- Saat mulai, timer dijeda. Bu Ijah berkata "Aku mau satu tomat!", disusul teks "Benda apa di halaman ini yang mirip tomat?"
- Tombol aksi berkedip saat pemain pertama kali berada di dekat benda.
- Setelah dapat benih, panah menunjuk petak tanah. Setelah panen, gelembung pesanan Bu Ijah tercentang dan stage selesai.
- Jika 20 detik berlalu tanpa identifikasi, bola karet memantul pelan sebagai petunjuk.

## Stage 1-2: Teras Rumah Dodi

Stage kedua mengenalkan benda kosong dan pengecoh: tiga benda di dekat jalur pemain mirip tomat, tapi hanya satu yang benar.

**Pesanan:** Mang Ujang, tukang sayur, minta 1 tomat dan 1 wortel. **Mekanik baru:** benda kosong, benih pengecoh, dua jenis tanaman, dua petak tanah.

```
# # # # # # # #
# B . . . . X #
# . P Z . . . #
# . . . O . . #
# . . . M M . #
# . . . M M . #
# T . . M M . #
# T . . . . . #
# . . . . . K #
# . N . . . . #
# . . . @ . . #
# # # # # # # #
```

| Simbol | Benda | Hasil identifikasi |
| --- | --- | --- |
| O | Jam weker merah bundar | Benih tomat |
| X | Kerucut lalu lintas | Benih wortel |
| P | Pot bunga | Benih bunga, tidak dipesan |
| K | Kaleng cat merah | Kosong |
| N | Bola tenis | Kosong |
| Z | Kucing tidur | Kosong |
| M | Meja | Penghalang |

**Jebakan yang disengaja:** bola tenis dan kaleng cat ada di dekat posisi awal, jadi pemain yang menebak dari "bulat" atau "merah" saja rugi 2 detik. Pot bunga ada di dekat jam weker merah, dan benihnya memakan satu slot kantong sampai ditanam.

**Solusi tercepat, sekitar 13 detik:**

1. Memutari meja lewat sisi kanan ke jam weker merah, lalu identifikasi (4 detik).
2. Ke kerucut lalu lintas, lalu identifikasi (2,4 detik).
3. Kembali memutari meja lewat kanan ke petak tanah, tanam dua benih, panen keduanya begitu matang. Pesanan terisi dan stage selesai (6,5 detik: jalan 2,5 detik, lalu tanam, tanam, panen, panen tanpa berpindah petak).

Rute lewat sisi kiri meja lebih pendek ke jam weker, tetapi sekitar 4 detik lebih lambat secara keseluruhan: celah diagonal kucing–jam weker dan pot bunga–pembeli tertutup, jadi pemain harus memutari meja lagi untuk mencapai kerucut.

**Bintang:** 3 bintang jika sisa waktu minimal 55 detik, 2 bintang jika minimal 35 detik.

**Tutorial:** satu teks saat mulai, "Tidak semua benda adalah benih. Salah tebak membuang 2 detik." Setelah itu tidak ada panah petunjuk.

## Stage 1-3: Gudang Kakek

Stage ketiga mengenalkan alat: satu tomat tersembunyi di kardus yang hanya bisa dibuka dengan gunting dari ruangan sebelah.

**Pesanan:** Pak RT minta 2 tomat dan 1 jagung. **Mekanik baru:** gunting, wadah tertutup, dua ruangan, tiga benih untuk dua petak tanah.

```
# B # # # # # #
# . . S . . G #
# . R . . R . #
# J R . L R . #
# . R . . R . #
# . . . . . . #
# # # # . # # #
# T . . . . . #
# T . . . . . #
# . . . . . Y #
# @ Q . A . W #
# # # # # # # #
```

Pak RT berdiri di pintu kiri atas dan tidak perlu didatangi. Kedua ruangan tersambung lewat satu celah di tengah dinding.

| Simbol | Benda | Hasil identifikasi |
| --- | --- | --- |
| Y | Spons cuci piring kuning | Benih jagung |
| L | Lampion merah | Benih tomat |
| A | Kardus bertulisan "MAINAN" | Butuh gunting; isinya hidung badut (benih tomat) |
| S | Kardus bertulisan "SEPATU" | Butuh gunting; isinya sepatu (kosong) |
| G | Gunting | Alat |
| J | Bantalan jarum jahit merah | Benih stroberi, tidak dipesan |
| Q | Kotak pos merah | Kosong |
| W | Wastafel | Penghalang |
| R | Rak | Penghalang |

**Jebakan yang disengaja:** kardus "SEPATU" ada di dekat gunting. Pemain yang tidak membaca tulisannya akan memotong kardus yang salah dan rugi 3,5 detik. Bantalan jarum juga merah dan bulat seperti tomat, tapi bintik-bintiknya menandakan stroberi.

**Solusi tercepat, sekitar 22 detik:**

1. Ke spons kuning, lalu identifikasi (3,3 detik).
2. Ke petak tanah, tanam jagung (2,3 detik). Jagung tumbuh sambil pemain pergi.
3. Lewat celah ke lampion merah, lalu identifikasi (3,6 detik).
4. Ambil gunting (1,2 detik).
5. Kembali lewat celah ke kardus "MAINAN", potong, lalu identifikasi hidung badut (5,9 detik).
6. Ke petak tanah: panen jagung, tanam dua tomat, panen keduanya begitu matang. Pesanan terisi dan stage selesai (5,5 detik).

**Bintang:** 3 bintang jika sisa waktu minimal 45 detik, 2 bintang jika minimal 25 detik.

**Tutorial:** saat pertama mendekati kardus tanpa alat, ikon gunting muncul dan teks "Kardus ini tertutup. Cari alat untuk membukanya." tampil sekali.

## Saran implementasi: peta stage sebagai data

Simpan setiap stage sebagai file data yang memuat peta huruf persis seperti di dokumen ini, supaya rancangan di kertas langsung bisa dimainkan tanpa diterjemahkan ke kode.

Pakai dua jenis file:

1. **Katalog benda**, satu untuk seluruh game. Isinya sifat setiap benda: hasil, alat yang dibutuhkan, isi wadah, dan reaksi.
2. **File stage**, satu per stage. Isinya hanya peta, legenda huruf, pesanan, dan ambang bintang.

Contoh `katalog_benda.json`:

```json
{
  "lampion_merah":  { "hasil": "tomat",    "logika": "warna_bentuk" },
  "hidung_badut":   { "hasil": "tomat",    "logika": "warna_bentuk" },
  "spons_kuning":   { "hasil": "jagung",   "logika": "warna_bentuk" },
  "bantalan_jarum": { "hasil": "stroberi", "logika": "warna_bentuk" },
  "kotak_pos":      { "hasil": null, "reaksi": "surat_beterbangan" },
  "sepatu":         { "hasil": null, "reaksi": "bau" },
  "kardus_mainan":  { "butuh_alat": "gunting", "isi": "hidung_badut" },
  "kardus_sepatu":  { "butuh_alat": "gunting", "isi": "sepatu" },
  "gunting":        { "jenis": "alat" }
}
```

Contoh `stage_1-3.json`:

```json
{
  "id": "1-3",
  "nama": "Gudang Kakek",
  "waktu_detik": 90,
  "bintang_sisa_detik": { "tiga": 45, "dua": 25 },
  "pesanan": { "pembeli": "pak_rt", "isi": { "tomat": 2, "jagung": 1 } },
  "peta": [
    "#B######",
    "#..S..G#",
    "#.R..R.#",
    "#JR.LR.#",
    "#.R..R.#",
    "#......#",
    "####.###",
    "#T.....#",
    "#T.....#",
    "#.....Y#",
    "#@Q.A.W#",
    "########"
  ],
  "legenda": {
    "Y": "spons_kuning", "L": "lampion_merah", "A": "kardus_mainan",
    "S": "kardus_sepatu", "G": "gunting", "J": "bantalan_jarum",
    "Q": "kotak_pos", "W": "penghalang", "R": "penghalang"
  }
}
```

Keuntungannya:

- Mengubah sifat satu benda, misalnya reaksi kaleng cat, langsung berlaku di semua stage.
- Stage baru cukup dibuat dengan menggambar peta huruf, tanpa menyentuh kode game.
- Simbol umum (`#`, `.`, `@`, `T`, `B`) dibaca langsung oleh kode pemuat peta dan tidak perlu masuk legenda.

Simpan juga angka penyetelan (kapasitas kantong 3, durasi tiap aksi, kecepatan jalan) di satu file pengaturan, bukan tertulis langsung di kode. Angka-angka ini pasti berubah selama uji main, dan mengubahnya jadi cukup mengedit satu file.

Tambahkan juga skrip pemeriksa yang berjalan setiap kali build, untuk menangkap stage yang mustahil diselesaikan sebelum sempat dimainkan:

1. Setiap tanaman di pesanan punya cukup benda sumber di peta.
2. Setiap wadah yang butuh alat punya alat itu di peta yang sama.
3. Setiap huruf di peta ada di legenda atau termasuk simbol umum.
4. Semua benda dan petak tanah bisa dicapai dari `@`, dicek dengan flood fill (menyebar dari posisi awal ke semua petak yang bisa dilewati).
5. Tidak ada benda (selain hiasan) yang muncul lagi kurang dari 4 stage setelah kemunculan terakhirnya. Skrip membaca semua file stage berurutan dan mencatat stage terakhir tempat setiap benda dipakai.
6. Setiap benda sumber memakai logika yang sudah diperkenalkan di musim itu atau sebelumnya. Musim dibaca dari angka pertama id stage, logika dari kolom `logika` di katalog.

## Keputusan

Tiga hal sudah diputuskan; dua masih terbuka dan sebaiknya dijawab selama prototipe.

- [x] Orientasi layar: portrait.
- [ ] Kecepatan jalan 4 petak per detik dan durasi tiap aksi, disetel dari uji main.
- [x] Benih bunga tidak punya kegunaan rahasia; murni pengecoh.
- [x] Batas kantong benih berlaku sejak stage pertama; keranjang ditiadakan.
- [ ] Judul game.

Cadangan pasangan untuk musim berikutnya: bola basket jadi semangka dan pelampung oranye jadi jeruk (Panas), mobil van hijau jadi mentimun dan gagang telepon jadi pisang (Gugur), manusia salju jadi wortel dan balon ungu jadi anggur (Dingin).
