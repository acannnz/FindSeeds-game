extends Control
## Tombol aksi kontekstual yang melayang di kanan bawah, langsung di atas
## tampilan game (tanpa panel). Tanpa aksi: kecil dan samar. Ada aksi aktif:
## ukuran penuh dan berdenyut pelan. Aksi terkunci: abu-abu dengan alasan di
## bawahnya. Progres aksi berdurasi tampil sebagai cincin. Nama target tampil
## di dunia game lewat label_target.gd, bukan di sini.
## Multi-sentuh: sentuhan mana pun di dalam lingkaran memicu tombol.
## Di desktop, Spasi/Enter (ui_accept) juga memicu tombol.

signal ditekan

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")

const WARNA_AKTIF := Color(0.26, 0.63, 0.28, 0.9)
const WARNA_NONAKTIF := Color(0.38, 0.38, 0.38, 0.75)
const WARNA_KOSONG := Color(1, 1, 1, 0.14)
const WARNA_TEPI := Color(1, 1, 1, 0.5)
const WARNA_PROGRES := Color.WHITE
const WARNA_ALASAN := Color("#ffcc80")
const WARNA_BAYANGAN_TEKS := Color(0, 0, 0, 0.6)
const TINGGI_TEKS := 36.0
## Area sentuh sedikit lebih besar dari lingkaran agar mudah dikenai jempol.
const PORSI_AREA_SENTUH := 1.2
const SKALA_DIAM := 0.7
const SKALA_DENYUT := 0.04
const KECEPATAN_DENYUT := 5.0
const KECEPATAN_SKALA := 10.0

## 0..1 saat aksi berjalan, negatif jika tidak ada aksi berjalan.
var progres := -1.0:
	set(v):
		progres = v
		queue_redraw()
## Jarak tambahan dari tepi bawah layar (area aman di HP berponi/gestur).
var inset_bawah := 0.0:
	set(v):
		inset_bawah = v
		queue_redraw()

var _radius := 0.0
var _jarak_tepi := 0.0
var _label := ""
var _aktif := false
var _alasan := ""
var _skala := SKALA_DIAM
var _waktu := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_radius = DataGame.pengaturan.tombol_aksi_radius_px
	_jarak_tepi = DataGame.pengaturan.tombol_aksi_jarak_tepi_px


func tampilkan(label: String, aktif: bool, alasan: String) -> void:
	if label == _label and aktif == _aktif and alasan == _alasan:
		return
	_label = label
	_aktif = aktif
	_alasan = alasan
	queue_redraw()


## Pusat tombol dalam koordinat lokal (Control ini selebar layar).
func pusat() -> Vector2:
	return size - Vector2(_radius + _jarak_tepi, _radius + _jarak_tepi + inset_bawah)


func _process(delta: float) -> void:
	_waktu += delta
	var tujuan := SKALA_DIAM if _label == "" else 1.0
	if _aktif and progres < 0.0:
		tujuan += sin(_waktu * KECEPATAN_DENYUT) * SKALA_DENYUT
	var baru := lerpf(_skala, tujuan, minf(1.0, delta * KECEPATAN_SKALA))
	if absf(baru - _skala) > 0.0005:
		_skala = baru
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if (event.position - global_position).distance_to(pusat()) <= _radius * PORSI_AREA_SENTUH:
			ditekan.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		ditekan.emit()


func _draw() -> void:
	var p := pusat()
	var r := _radius * _skala
	if _label == "":
		draw_circle(p, r, WARNA_KOSONG)
		draw_arc(p, r, 0.0, TAU, 48, Color(WARNA_TEPI, 0.25), 2.0, true)
		return
	draw_circle(p, r, WARNA_AKTIF if _aktif else WARNA_NONAKTIF)
	draw_arc(p, r, 0.0, TAU, 48, WARNA_TEPI, 3.0, true)
	var kotak_label := Rect2(p - Vector2(r, TINGGI_TEKS / 2.0), Vector2(r * 2.0, TINGGI_TEKS))
	Gambar.huruf_tengah(self, _label, kotak_label, Color.WHITE if _aktif else Color(1, 1, 1, 0.65), 0.8)
	if progres >= 0.0:
		draw_arc(p, r - 6.0, -PI / 2.0, -PI / 2.0 + TAU * clampf(progres, 0.0, 1.0), 48, WARNA_PROGRES, 8.0, true)
	if _alasan != "":
		var kotak_alasan := Rect2(Vector2(p.x - _radius * 1.5, p.y - r - TINGGI_TEKS - 8.0), Vector2(_radius * 3.0, TINGGI_TEKS))
		Gambar.huruf_tengah(self, _alasan, Rect2(kotak_alasan.position + Vector2(2, 2), kotak_alasan.size), WARNA_BAYANGAN_TEKS, 0.65)
		Gambar.huruf_tengah(self, _alasan, kotak_alasan, WARNA_ALASAN, 0.65)
