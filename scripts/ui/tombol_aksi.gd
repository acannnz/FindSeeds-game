extends Control
## Tombol aksi kontekstual di kanan bawah. Menampilkan nama benda target,
## label aksi, alasan jika tidak bisa ditekan, dan progres aksi berdurasi.
## Multi-sentuh: sentuhan mana pun di dalam lingkaran memicu tombol.
## Di desktop, Spasi/Enter (ui_accept) juga memicu tombol.

signal ditekan

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")

const WARNA_AKTIF := Color("#43a047")
const WARNA_NONAKTIF := Color("#616161")
const WARNA_KOSONG := Color(1, 1, 1, 0.12)
const WARNA_PROGRES := Color.WHITE
const WARNA_NAMA := Color.WHITE
const WARNA_ALASAN := Color("#ffcc80")
const TINGGI_TEKS := 36.0
## Area sentuh sedikit lebih besar dari lingkaran agar mudah dikenai jempol.
const PORSI_AREA_SENTUH := 1.15

## 0..1 saat aksi berjalan, negatif jika tidak ada aksi berjalan.
var progres := -1.0:
	set(v):
		progres = v
		queue_redraw()

var _radius := 0.0
var _label := ""
var _aktif := false
var _alasan := ""
var _nama := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_radius = DataGame.pengaturan.tombol_aksi_radius_px


func tampilkan(label: String, aktif: bool, alasan: String, nama: String) -> void:
	if label == _label and aktif == _aktif and alasan == _alasan and nama == _nama:
		return
	_label = label
	_aktif = aktif
	_alasan = alasan
	_nama = nama
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if (event.position - global_position).distance_to(_pusat()) <= _radius * PORSI_AREA_SENTUH:
			ditekan.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		ditekan.emit()


func _pusat() -> Vector2:
	return size / 2.0


func _draw() -> void:
	var pusat := _pusat()
	if _nama != "":
		var kotak_nama := Rect2(Vector2(0, pusat.y - _radius - TINGGI_TEKS - 6), Vector2(size.x, TINGGI_TEKS))
		Gambar.huruf_tengah(self, _nama, kotak_nama, WARNA_NAMA, 0.7)

	if _label == "":
		draw_circle(pusat, _radius, WARNA_KOSONG)
	else:
		draw_circle(pusat, _radius, WARNA_AKTIF if _aktif else WARNA_NONAKTIF)
		var kotak_label := Rect2(pusat - Vector2(_radius, TINGGI_TEKS / 2.0), Vector2(_radius * 2.0, TINGGI_TEKS))
		Gambar.huruf_tengah(self, _label, kotak_label, Color.WHITE if _aktif else Color(1, 1, 1, 0.6), 0.8)
	if progres >= 0.0:
		draw_arc(pusat, _radius - 6.0, -PI / 2.0, -PI / 2.0 + TAU * clampf(progres, 0.0, 1.0), 48, WARNA_PROGRES, 8.0)

	if _alasan != "":
		var kotak_alasan := Rect2(Vector2(0, pusat.y + _radius + 6), Vector2(size.x, TINGGI_TEKS))
		Gambar.huruf_tengah(self, _alasan, kotak_alasan, WARNA_ALASAN, 0.65)
