extends Node2D
## Label kecil di dunia game, menempel pada target tombol aksi: nama benda dan
## aksinya (atau alasan jika terkunci). Pemain tidak perlu melirik ke pojok
## layar untuk tahu apa yang akan terjadi saat tombol ditekan. Label tampil di
## atas target, kecuali pemain berdiri di atasnya: label pindah ke bawah agar
## tidak menutupi pemain.

const Gambar := preload("res://scripts/game/gambar.gd")

const WARNA_LATAR := Color(0.08, 0.1, 0.09, 0.82)
const WARNA_NAMA := Color(1, 1, 1, 0.85)
const WARNA_AKSI := Color("#a5d6a7")
const WARNA_ALASAN := Color("#ffcc80")
## Ukuran dalam satuan petak.
const PORSI_TINGGI_BARIS := 0.3
const PORSI_SELA := 0.08
const PORSI_JARAK_ATAS := 0.55
## Tambahan jarak jika di atas target sudah ada gelembung ikon alat.
const PORSI_JARAK_IKON := 0.5

var _ukuran := 64.0
var _lebar_peta := 0.0
var _nama := ""
var _baris_aksi := ""
var _aktif := false
var _naik := 0.0
var _di_bawah := false


func siapkan(ukuran_petak: float, lebar_peta: float) -> void:
	_ukuran = ukuran_petak
	_lebar_peta = lebar_peta
	z_index = 30
	hide()


## posisi: pusat target di dunia; ada_ikon: target sedang menampilkan ikon
## alat di atasnya; di_bawah: tampilkan label di bawah target.
func tampilkan(posisi: Vector2, nama: String, label_aksi: String, aktif: bool, alasan: String, ada_ikon: bool, di_bawah: bool) -> void:
	var baris := label_aksi if alasan == "" else "%s · %s" % [label_aksi, alasan]
	var naik := PORSI_JARAK_ATAS + (PORSI_JARAK_IKON if ada_ikon and not di_bawah else 0.0)
	if visible and position == posisi and nama == _nama and baris == _baris_aksi and aktif == _aktif \
			and naik == _naik and di_bawah == _di_bawah:
		return
	_di_bawah = di_bawah
	position = posisi
	_nama = nama
	_baris_aksi = baris
	_aktif = aktif
	_naik = naik
	show()
	queue_redraw()


func sembunyikan() -> void:
	hide()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var tinggi_baris := _ukuran * PORSI_TINGGI_BARIS
	var sela := _ukuran * PORSI_SELA
	var ukuran_nama := int(tinggi_baris * 0.7)
	var ukuran_aksi := int(tinggi_baris * 0.8)
	var lebar := maxf(font.get_string_size(_nama, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran_nama).x,
		font.get_string_size(_baris_aksi, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran_aksi).x) + sela * 3.0
	# Tanpa nama (benda belum diperiksa): satu baris aksi saja.
	var jumlah_baris := 1 if _nama == "" else 2
	var tinggi := tinggi_baris * jumlah_baris + sela * 2.0
	var y_kotak := _ukuran * _naik if _di_bawah else -_ukuran * _naik - tinggi
	var kotak := Rect2(Vector2(-lebar / 2.0, y_kotak), Vector2(lebar, tinggi))
	# Jaga label tetap di dalam lebar peta.
	var x_dunia := position.x + kotak.position.x
	if _lebar_peta > 0.0:
		kotak.position.x -= minf(0.0, x_dunia) + maxf(0.0, x_dunia + lebar - _lebar_peta)
	draw_rect(kotak, WARNA_LATAR)
	var baris := Rect2(kotak.position + Vector2(0, sela), Vector2(lebar, tinggi_baris))
	if _nama != "":
		Gambar.huruf_tengah(self, _nama, baris, WARNA_NAMA, 0.7)
		baris.position.y += tinggi_baris
	Gambar.huruf_tengah(self, _baris_aksi, baris, WARNA_AKSI if _aktif else WARNA_ALASAN, 0.8)
	# Segitiga kecil menunjuk ke target.
	var arah := -1.0 if _di_bawah else 1.0
	var ujung := Vector2(0, -_ukuran * _naik * arah)
	draw_colored_polygon(PackedVector2Array([ujung + Vector2(-sela, 0), ujung + Vector2(sela, 0), ujung + Vector2(0, sela * arah)]), WARNA_LATAR)
