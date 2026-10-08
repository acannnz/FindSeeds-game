extends CharacterBody2D
## Pemain: bergerak bebas (tidak per petak) dengan joystick virtual,
## atau tombol panah keyboard saat diuji di desktop.

const DataGame := preload("res://scripts/inti/data_game.gd")

const WARNA_BADAN := Color("#1e88e5")
const WARNA_MATA := Color.WHITE
## Posisi dan ukuran titik arah hadap, sebagai porsi radius badan.
const PORSI_JARAK_MATA := 0.55
const PORSI_RADIUS_MATA := 0.25

## Sumber arah dari joystick virtual (punya properti `vektor`).
var joystick: Node
## Diisi skrip uji atau otomasi untuk menggantikan masukan pemain; null = masukan biasa.
var arah_paksa: Variant = null
## True selama aksi berdurasi berlangsung (fase 5): pemain tidak bisa bergerak.
var terkunci := false
## Arah hadap terakhir (vektor satuan). Dipakai sebagai pemecah seri target.
var hadap := Vector2.DOWN:
	set(v):
		if not v.is_equal_approx(hadap):
			hadap = v
			queue_redraw()

var _kecepatan := 0.0
var _radius := 0.0


func siapkan(ukuran_petak: float, sumber_joystick: Node) -> void:
	var p := DataGame.pengaturan
	_kecepatan = p.kecepatan_jalan_petak_per_detik * ukuran_petak
	_radius = p.radius_pemain_petak * ukuran_petak
	joystick = sumber_joystick
	var bentuk := CircleShape2D.new()
	bentuk.radius = _radius
	$Bentuk.shape = bentuk
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var arah := Vector2.ZERO if terkunci else _arah_masukan()
	velocity = arah * _kecepatan
	move_and_slide()
	if arah != Vector2.ZERO:
		hadap = arah.normalized()


## Panjang 0..1. Keyboard didahulukan bila ditekan.
func _arah_masukan() -> Vector2:
	if arah_paksa != null:
		return arah_paksa
	var papan := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if papan != Vector2.ZERO:
		return papan
	return joystick.vektor if joystick else Vector2.ZERO


func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, WARNA_BADAN)
	draw_circle(hadap * _radius * PORSI_JARAK_MATA, _radius * PORSI_RADIUS_MATA, WARNA_MATA)
