extends Control
## Joystick virtual dinamis, melayang langsung di atas tampilan game:
## - tidak terlihat sampai disentuh; muncul di titik sentuh mana pun di area
##   ini (separuh kiri layar);
## - kenop mengikuti jempol; jika jempol ditarik melewati radius, alasnya ikut
##   tertarik sehingga jempol tidak pernah "mentok";
## - memudar saat dilepas.
## Melacak satu indeks sentuhan, jadi tombol aksi tetap bisa ditekan jempol lain.

const DataGame := preload("res://scripts/inti/data_game.gd")

const WARNA_ALAS := Color(1, 1, 1, 0.16)
const WARNA_TEPI_ALAS := Color(1, 1, 1, 0.45)
const WARNA_KENOP := Color(1, 1, 1, 0.8)
const WARNA_BAYANGAN := Color(0, 0, 0, 0.25)
const PORSI_KENOP := 0.45
const DETIK_MUNCUL := 0.06
const DETIK_PUDAR := 0.18

## Arah gerak, panjang 0..1 (sudah dikurangi zona mati).
var vektor := Vector2.ZERO

var _radius := 0.0
var _zona_mati := 0.0
var _indeks_sentuh := -1
var _pusat_alas := Vector2.ZERO
var _kenop := Vector2.ZERO
## 0 = tidak terlihat, 1 = terlihat penuh.
var _tampak := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_radius = DataGame.pengaturan.joystick_radius_px
	_zona_mati = DataGame.pengaturan.joystick_zona_mati


func aktif() -> bool:
	return _indeks_sentuh != -1


## Titik pusat alas dan kenop, dalam koordinat layar (dipakai skrip uji).
func pusat_alas_layar() -> Vector2:
	return global_position + _pusat_alas


func tampak() -> float:
	return _tampak


func _process(delta: float) -> void:
	var tujuan := 1.0 if aktif() else 0.0
	var laju := delta / (DETIK_MUNCUL if aktif() else DETIK_PUDAR)
	var baru := move_toward(_tampak, tujuan, laju)
	if baru != _tampak:
		_tampak = baru
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not aktif() and get_global_rect().has_point(event.position):
			_indeks_sentuh = event.index
			_pusat_alas = event.position - global_position
			_kenop = _pusat_alas
			vektor = Vector2.ZERO
			queue_redraw()
		elif not event.pressed and event.index == _indeks_sentuh:
			lepas()
	elif event is InputEventScreenDrag and event.index == _indeks_sentuh:
		_perbarui(event.position)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		lepas()


## Melepas joystick (jempol diangkat atau aplikasi kehilangan fokus).
## Posisi alas dipertahankan supaya joystick memudar di tempatnya.
func lepas() -> void:
	_indeks_sentuh = -1
	vektor = Vector2.ZERO


func _perbarui(posisi_layar: Vector2) -> void:
	var lokal := posisi_layar - global_position
	var geser := lokal - _pusat_alas
	if geser.length() > _radius:
		# Alas ikut tertarik ke arah jempol.
		_pusat_alas = lokal - geser.normalized() * _radius
		geser = lokal - _pusat_alas
	_kenop = lokal
	var mentah := geser / _radius
	var panjang := mentah.length()
	if panjang <= _zona_mati:
		vektor = Vector2.ZERO
	else:
		vektor = mentah.normalized() * (panjang - _zona_mati) / (1.0 - _zona_mati)
	queue_redraw()


func _draw() -> void:
	if _tampak <= 0.0:
		return
	var a := _tampak
	draw_circle(_pusat_alas, _radius, _pudar(WARNA_ALAS, a))
	draw_arc(_pusat_alas, _radius, 0.0, TAU, 48, _pudar(WARNA_TEPI_ALAS, a), 3.0, true)
	var r_kenop := _radius * PORSI_KENOP
	draw_circle(_kenop + Vector2(0, 4), r_kenop, _pudar(WARNA_BAYANGAN, a))
	draw_circle(_kenop, r_kenop, _pudar(WARNA_KENOP, a))


func _pudar(warna: Color, a: float) -> Color:
	return Color(warna, warna.a * a)
