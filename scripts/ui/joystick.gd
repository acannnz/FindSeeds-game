extends Control
## Joystick virtual mengambang: alasnya pindah ke titik sentuh pertama di area
## ini, lalu kenop mengikuti jempol. Mendukung multi-sentuh (melacak satu indeks
## sentuhan), jadi tombol aksi tetap bisa ditekan jempol lain.

const DataGame := preload("res://scripts/inti/data_game.gd")

const WARNA_ALAS := Color(1, 1, 1, 0.12)
const WARNA_TEPI_ALAS := Color(1, 1, 1, 0.35)
const WARNA_KENOP := Color(1, 1, 1, 0.6)
const PORSI_KENOP := 0.45

## Arah gerak, panjang 0..1 (sudah dikurangi zona mati).
var vektor := Vector2.ZERO

var _radius := 0.0
var _zona_mati := 0.0
var _indeks_sentuh := -1
var _pusat_alas := Vector2.ZERO
var _kenop := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_radius = DataGame.pengaturan.joystick_radius_px
	_zona_mati = DataGame.pengaturan.joystick_zona_mati
	resized.connect(_kembali_ke_tempat)
	_kembali_ke_tempat()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _indeks_sentuh == -1 and get_global_rect().has_point(event.position):
			_indeks_sentuh = event.index
			var lokal: Vector2 = event.position - global_position
			_pusat_alas = lokal.clamp(Vector2.ONE * _radius, (size - Vector2.ONE * _radius).max(Vector2.ONE * _radius))
			_perbarui(event.position)
		elif not event.pressed and event.index == _indeks_sentuh:
			lepas()
	elif event is InputEventScreenDrag and event.index == _indeks_sentuh:
		_perbarui(event.position)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		lepas()


## Melepas joystick (jempol diangkat atau aplikasi kehilangan fokus).
func lepas() -> void:
	_indeks_sentuh = -1
	vektor = Vector2.ZERO
	_kembali_ke_tempat()


func _perbarui(posisi_layar: Vector2) -> void:
	var geser := (posisi_layar - global_position - _pusat_alas).limit_length(_radius)
	_kenop = _pusat_alas + geser
	var mentah := geser / _radius
	var panjang := mentah.length()
	if panjang <= _zona_mati:
		vektor = Vector2.ZERO
	else:
		vektor = mentah.normalized() * (panjang - _zona_mati) / (1.0 - _zona_mati)
	queue_redraw()


func _kembali_ke_tempat() -> void:
	_pusat_alas = size / 2.0
	_kenop = _pusat_alas
	queue_redraw()


func _draw() -> void:
	draw_circle(_pusat_alas, _radius, WARNA_ALAS)
	draw_arc(_pusat_alas, _radius, 0.0, TAU, 48, WARNA_TEPI_ALAS, 2.0)
	draw_circle(_kenop, _radius * PORSI_KENOP, WARNA_KENOP)
