extends RefCounted
## Aset gambar (SVG) dan konvensi lokasinya. Gambar dicari dari id di data,
## jadi menambah benda baru cukup dengan menaruh file SVG bernama sesuai id.
## Jika file belum ada, tekstur() mengembalikan null dan pemanggil menggambar
## placeholder kotak warna, sehingga aset bisa masuk bertahap.
##
##   aset/benda/<id>.svg            (atau <gambar>.svg jika katalog punya kolom "gambar")
##   aset/tanaman/<id>_<tahap>.svg  tahap: muda, matang, buah; plus tanaman/tunas.svg
##   aset/karakter/pemain_<arah>.svg   arah: bawah, atas, kiri, kanan
##   aset/pembeli/<id>.svg
##   aset/petak/<tema>_<bagian>.svg    bagian: lantai, dinding; plus petak/tanah.svg
##   aset/ui/aksi_<aksi>.svg

const FOLDER := "res://aset"
const TAHAP_TANAMAN := ["muda", "matang", "buah"]
const ARAH_PEMAIN := ["bawah", "atas", "kiri", "kanan"]
const BAGIAN_PETAK := ["lantai", "dinding"]
const AKSI := ["identifikasi", "ambil", "potong", "tanam", "panen"]

static var _simpanan := {}


static func benda(id: String, entri: Dictionary) -> String:
	return "%s/benda/%s.svg" % [FOLDER, entri.get("gambar", id)]


static func tanaman(id: String, tahap: String) -> String:
	return "%s/tanaman/%s_%s.svg" % [FOLDER, id, tahap]


static func tunas() -> String:
	return FOLDER + "/tanaman/tunas.svg"


static func pemain(arah: String) -> String:
	return "%s/karakter/pemain_%s.svg" % [FOLDER, arah]


static func pembeli(id: String) -> String:
	return "%s/pembeli/%s.svg" % [FOLDER, id]


static func petak(tema: String, bagian: String) -> String:
	return "%s/petak/%s_%s.svg" % [FOLDER, tema, bagian]


static func tanah() -> String:
	return FOLDER + "/petak/tanah.svg"


static func aksi(nama_aksi: String) -> String:
	return "%s/ui/aksi_%s.svg" % [FOLDER, nama_aksi]


## Tekstur dari jalur, atau null jika belum ada (atau belum diimpor Godot).
## Hasil disimpan supaya tiap file hanya dimuat sekali.
static func tekstur(jalur: String) -> Texture2D:
	if _simpanan.has(jalur):
		return _simpanan[jalur]
	var hasil: Texture2D = null
	if ResourceLoader.exists(jalur):
		hasil = load(jalur)
	_simpanan[jalur] = hasil
	return hasil


## Semua file aset yang dibutuhkan data game (benda, tanaman, pembeli, tema).
static func kebutuhan(data: Dictionary) -> Array[String]:
	var jalur: Array[String] = []
	for id in data.katalog:
		var j := benda(id, data.katalog[id])
		if not j in jalur:
			jalur.append(j)
	jalur.append(tunas())
	for id in data.tanaman:
		for tahap in TAHAP_TANAMAN:
			jalur.append(tanaman(id, tahap))
	for id in data.pembeli:
		jalur.append(pembeli(id))
	for tema in data.get("tema", {}):
		for bagian in BAGIAN_PETAK:
			jalur.append(petak(tema, bagian))
	jalur.append(tanah())
	for arah in ARAH_PEMAIN:
		jalur.append(pemain(arah))
	for a in AKSI:
		jalur.append(aksi(a))
	return jalur


## Memuat semua tekstur sekaligus (dipanggil saat game mulai). Tekstur yang
## pertama kali dimuat di tengah _draw() bisa tampil putih satu kali, jadi
## semua aset dimuat lebih dulu dan _draw() hanya mengambil dari simpanan.
static func muat_semua(daftar: Array[String]) -> int:
	var jumlah := 0
	for j in daftar:
		if tekstur(j) != null:
			jumlah += 1
	return jumlah


## File aset yang dibutuhkan tetapi belum ada di folder aset.
static func hilang(data: Dictionary) -> Array[String]:
	var hasil: Array[String] = []
	for j in kebutuhan(data):
		if not FileAccess.file_exists(j):
			hasil.append(j)
	return hasil
