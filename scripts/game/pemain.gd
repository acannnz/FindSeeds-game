extends CharacterBody2D
## Pemain: bergerak bebas (tidak per petak) dengan joystick virtual,
## atau tombol panah keyboard saat diuji di desktop. Digambar dengan aset
## 4 arah (bawah, atas, kiri, kanan) dan sedikit memantul saat berjalan;
## tanpa aset: lingkaran dengan titik arah hadap.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Aset := preload("res://scripts/inti/aset.gd")

const WARNA_BADAN := Color("#1e88e5")
const WARNA_MATA := Color.WHITE
## Posisi dan ukuran titik arah hadap, sebagai porsi radius badan.
const PORSI_JARAK_MATA := 0.55
const PORSI_RADIUS_MATA := 0.25
## Pemain digambar di atas benda dan gelembung ikon alat (z_index 1).
const LAPISAN_GAMBAR := 2
## Ukuran gambar pemain (porsi petak) dan geseran ke atas agar kaki di pusat.
const PORSI_GAMBAR := 1.05
const PORSI_NAIK_GAMBAR := 0.2
## Pantulan langkah: tinggi (porsi petak) dan langkah per detik.
const PORSI_PANTUL := 0.04
const LANGKAH_PER_DETIK := 7.0

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
var _ukuran := 64.0
## arah ("bawah", "atas", "kiri", "kanan") -> tekstur
var _tekstur := {}
var _waktu_jalan := 0.0


func siapkan(ukuran_petak: float, sumber_joystick: Node) -> void:
	var p := DataGame.pengaturan
	_kecepatan = p.kecepatan_jalan_petak_per_detik * ukuran_petak
	_radius = p.radius_pemain_petak * ukuran_petak
	_ukuran = ukuran_petak
	for arah in Aset.ARAH_PEMAIN:
		_tekstur[arah] = Aset.tekstur(Aset.pemain(arah))
	joystick = sumber_joystick
	z_index = LAPISAN_GAMBAR
	var bentuk := CircleShape2D.new()
	bentuk.radius = _radius
	$Bentuk.shape = bentuk
	queue_redraw()


func _physics_process(delta: float) -> void:
	var arah := Vector2.ZERO if terkunci else _arah_masukan()
	velocity = arah * _kecepatan
	move_and_slide()
	if arah != Vector2.ZERO:
		hadap = arah.normalized()
	var berjalan := get_real_velocity().length() > 1.0
	if berjalan or _waktu_jalan != 0.0:
		_waktu_jalan = _waktu_jalan + delta if berjalan else 0.0
		queue_redraw()


## Arah gambar dari arah hadap: sumbu yang dominan.
func arah_gambar() -> String:
	if absf(hadap.x) > absf(hadap.y):
		return "kanan" if hadap.x > 0.0 else "kiri"
	return "bawah" if hadap.y >= 0.0 else "atas"


## Panjang 0..1. Keyboard didahulukan bila ditekan.
func _arah_masukan() -> Vector2:
	if arah_paksa != null:
		return arah_paksa
	var papan := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if papan != Vector2.ZERO:
		return papan
	return joystick.vektor if joystick else Vector2.ZERO


func _draw() -> void:
	var gambar: Texture2D = _tekstur.get(arah_gambar())
	if gambar != null:
		var pantul := absf(sin(_waktu_jalan * LANGKAH_PER_DETIK * PI)) * _ukuran * PORSI_PANTUL
		var sisi := _ukuran * PORSI_GAMBAR
		draw_texture_rect(gambar, Rect2(Vector2(-sisi / 2.0, -sisi / 2.0 - _ukuran * PORSI_NAIK_GAMBAR - pantul), Vector2.ONE * sisi), false)
		return
	draw_circle(Vector2.ZERO, _radius, WARNA_BADAN)
	draw_circle(hadap * _radius * PORSI_JARAK_MATA, _radius * PORSI_RADIUS_MATA, WARNA_MATA)
