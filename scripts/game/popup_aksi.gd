extends Node2D
## Pop-up aksi di dunia game, melayang di atas target terdekat (pengganti
## tombol aksi di pojok layar): gelembung bulat berisi ikon aksi (kaca
## pembesar untuk Periksa, tangan untuk Ambil, ...) yang ditekan langsung.
## Di bawah gelembung ada keterangan kecil: alasan jika aksi terkunci, atau
## nama target jika boleh diketahui (benda rahasia tanpa nama). Aksi aktif:
## hijau dan berdenyut; terkunci: abu-abu. Progres aksi berdurasi tampil
## sebagai cincin di tepi gelembung. Jika pemain berdiri di atas target,
## pop-up pindah ke bawah target agar tidak menutupi pemain.
## Di desktop, Spasi/Enter (ui_accept) juga memicu aksi.

signal ditekan

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Aset := preload("res://scripts/inti/aset.gd")

const WARNA_AKTIF := Color("#43a047")
const WARNA_NONAKTIF := Color("#757575")
const WARNA_TEPI := Color.WHITE
const WARNA_BAYANGAN := Color(0, 0, 0, 0.28)
const WARNA_PROGRES := Color("#fff59d")
const WARNA_LATAR_TEKS := Color(0.08, 0.1, 0.09, 0.82)
const WARNA_NAMA := Color(1, 1, 1, 0.9)
const WARNA_ALASAN := Color("#ffcc80")
## Ukuran dalam satuan petak (selain radius gelembung dari pengaturan).
## Jarak dari pusat target ke dasar gelembung: gambar benda diperbesar
## skala_gambar_benda dan berpijak di dasar petak, jadi puncaknya ±0,85 petak.
const PORSI_JARAK_ATAS := 0.95
const PORSI_JARAK_BAWAH := 0.55
## Tambahan jarak jika di atas target sudah ada gelembung ikon alat.
const PORSI_JARAK_IKON := 0.5
const PORSI_TINGGI_TEKS := 0.26
const PORSI_EKOR := 0.12
## Area sentuh sedikit lebih besar dari gelembung agar mudah dikenai jempol.
const PORSI_AREA_SENTUH := 1.35
const SKALA_DENYUT := 0.06
const KECEPATAN_DENYUT := 5.0

## 0..1 saat aksi berjalan, negatif jika tidak ada aksi berjalan.
var progres := -1.0:
	set(v):
		progres = v
		queue_redraw()

var _ukuran := 64.0
var _radius := 0.0
var _lebar_peta := 0.0
var _nama := ""
var _label := ""
var _alasan := ""
var _ikon: Texture2D
var _aktif := false
var _naik := 0.0
var _di_bawah := false
var _waktu := 0.0


func siapkan(ukuran_petak: float, lebar_peta: float) -> void:
	_ukuran = ukuran_petak
	_radius = float(DataGame.pengaturan.popup_aksi_radius_petak) * _ukuran
	_lebar_peta = lebar_peta
	z_index = 30
	hide()


## posisi: pusat target di dunia; aksi: id aksi untuk ikon; ada_ikon: target
## sedang menampilkan ikon alat di atasnya; di_bawah: pop-up di bawah target.
func tampilkan(posisi: Vector2, nama: String, label_aksi: String, aksi: String, aktif: bool, alasan: String, ada_ikon: bool, di_bawah: bool) -> void:
	var naik := PORSI_JARAK_ATAS + (PORSI_JARAK_IKON if ada_ikon and not di_bawah else 0.0)
	var ikon := Aset.tekstur(Aset.aksi(aksi)) if aksi != "" else null
	if visible and position == posisi and nama == _nama and label_aksi == _label and alasan == _alasan \
			and ikon == _ikon and aktif == _aktif and naik == _naik and di_bawah == _di_bawah:
		return
	position = posisi
	_nama = nama
	_label = label_aksi
	_alasan = alasan
	_ikon = ikon
	_aktif = aktif
	_naik = naik
	_di_bawah = di_bawah
	show()
	queue_redraw()


func sembunyikan() -> void:
	hide()
	progres = -1.0


## Pusat gelembung dalam koordinat dunia.
func pusat_gelembung() -> Vector2:
	return position + _pusat_lokal()


## True jika titik layar mengenai gelembung (dipakai juga joystick supaya
## sentuhan pada pop-up tidak memunculkan joystick).
func kena(posisi_layar: Vector2) -> bool:
	if not visible:
		return false
	var dunia := get_canvas_transform().affine_inverse() * posisi_layar
	return dunia.distance_to(pusat_gelembung()) <= _radius * PORSI_AREA_SENTUH


func _process(delta: float) -> void:
	if visible and _aktif and progres < 0.0:
		_waktu += delta
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and kena(event.position):
		get_viewport().set_input_as_handled()
		ditekan.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		ditekan.emit()


func _pusat_lokal() -> Vector2:
	var x := _geser_x(_radius)
	if _di_bawah:
		return Vector2(x, _ukuran * PORSI_JARAK_BAWAH + _radius)
	return Vector2(x, -_ukuran * _naik - _radius)


## Geser horizontal agar selebar `setengah` di kiri-kanan tetap di dalam peta.
func _geser_x(setengah: float) -> float:
	if _lebar_peta <= 0.0:
		return 0.0
	return -minf(0.0, position.x - setengah) - maxf(0.0, position.x + setengah - _lebar_peta)


func _draw() -> void:
	var p := _pusat_lokal()
	var r := _radius
	if _aktif and progres < 0.0:
		r *= 1.0 + sin(_waktu * KECEPATAN_DENYUT) * SKALA_DENYUT
	var warna := WARNA_AKTIF if _aktif else WARNA_NONAKTIF
	# Ekor kecil menunjuk ke target.
	var arah := -1.0 if _di_bawah else 1.0
	var e := _ukuran * PORSI_EKOR
	var pangkal := p + Vector2(0, (r - 2.0) * arah)
	var ekor := PackedVector2Array([pangkal + Vector2(-e, 0), pangkal + Vector2(e, 0), Vector2(p.x * 0.5, pangkal.y + e * 1.4 * arah)])
	draw_circle(p + Vector2(0, 3), r + 2.0, WARNA_BAYANGAN)
	draw_colored_polygon(ekor, WARNA_TEPI)
	draw_circle(p, r + 2.5, WARNA_TEPI)
	draw_circle(p, r, warna)
	var warna_ikon := Color.WHITE if _aktif else Color(1, 1, 1, 0.7)
	if _ikon != null:
		var sisi := r * 1.25
		draw_texture_rect(_ikon, Rect2(p - Vector2.ONE * sisi / 2.0, Vector2.ONE * sisi), false, warna_ikon)
	else:
		Gambar.huruf_tengah(self, _label, Rect2(p - Vector2(r, r * 0.4), Vector2(r * 2.0, r * 0.8)), warna_ikon, 0.7)
	if progres >= 0.0:
		draw_arc(p, r - 3.0, -PI / 2.0, -PI / 2.0 + TAU * clampf(progres, 0.0, 1.0), 40, WARNA_PROGRES, 5.0, true)
	_gambar_keterangan(p, r)


## Keterangan kecil: alasan (terkunci) atau nama target, di sisi gelembung
## yang menjauhi target agar tidak menutupi benda.
func _gambar_keterangan(p: Vector2, r: float) -> void:
	var teks := _alasan if _alasan != "" else _nama
	if teks == "":
		return
	var font := ThemeDB.fallback_font
	var tinggi := _ukuran * PORSI_TINGGI_TEKS
	var ukuran_font := int(tinggi * 0.75)
	var lebar := font.get_string_size(teks, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran_font).x + tinggi
	var y := p.y + r + 4.0 if _di_bawah else p.y - r - 4.0 - tinggi
	var kotak := Rect2(Vector2(p.x - lebar / 2.0, y), Vector2(lebar, tinggi))
	var x_dunia := position.x + kotak.position.x
	if _lebar_peta > 0.0:
		kotak.position.x -= minf(0.0, x_dunia) + maxf(0.0, x_dunia + lebar - _lebar_peta)
	draw_rect(kotak, WARNA_LATAR_TEKS)
	Gambar.huruf_tengah(self, teks, kotak, WARNA_ALASAN if _alasan != "" else WARNA_NAMA, 0.75)
