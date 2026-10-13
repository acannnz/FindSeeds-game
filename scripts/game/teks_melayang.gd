extends Node2D
## Teks singkat yang naik lalu memudar, misalnya reaksi benda kosong atau
## "+ Benih tomat". Kapsul kertas dengan titik aksen berwarna. Menghapus
## dirinya sendiri setelah selesai.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Gaya := preload("res://scripts/inti/gaya.gd")

## Ukuran dalam satuan petak.
const PORSI_TINGGI := 0.5
const PORSI_UKURAN_HURUF := 0.62
const PORSI_NAIK := 0.8

var _teks: String
var _warna: Color
var _ukuran: float
var _lama: float
var _umur := 0.0
var _lebar_peta := 0.0


## lebar_peta: lebar dunia peta; teks digeser agar tidak keluar tepi peta.
func siapkan(teks: String, warna: Color, ukuran_petak: float, lebar_peta: float = 0.0) -> void:
	_lebar_peta = lebar_peta
	_teks = teks
	_warna = warna
	_ukuran = ukuran_petak
	_lama = DataGame.pengaturan.lama_teks_melayang_detik
	z_index = 10


func _process(delta: float) -> void:
	_umur += delta
	if _umur >= _lama:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := _umur / _lama
	var tinggi := _ukuran * PORSI_TINGGI
	var ukuran_font := int(tinggi * PORSI_UKURAN_HURUF)
	var lebar := Gaya.FONT.get_string_size(_teks, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran_font).x + tinggi * 1.3
	var kotak := Rect2(Vector2(-lebar / 2.0, -_ukuran * (0.9 + PORSI_NAIK * t)), Vector2(lebar, tinggi))
	if _lebar_peta > 0.0:
		var x_dunia := position.x + kotak.position.x
		kotak.position.x -= minf(0.0, x_dunia) + maxf(0.0, x_dunia + lebar - _lebar_peta)
	var pudar := 1.0 - maxf(0.0, t - 0.6) / 0.4
	# Kapsul kertas (gaya.gd) dengan titik aksen berwarna (warna tanaman/info).
	modulate.a = pudar
	Gaya.panel(self, kotak, tinggi / 2.0, Gaya.KERTAS, Gaya.KAYU, 2.5, 3.0)
	var r_titik := tinggi * 0.18
	draw_circle(Vector2(kotak.position.x + tinggi * 0.45, kotak.get_center().y), r_titik, _warna)
	var kotak_teks := Rect2(kotak.position + Vector2(tinggi * 0.5, 0), kotak.size - Vector2(tinggi * 0.5, 0))
	Gambar.huruf_tengah(self, _teks, kotak_teks, Gaya.TEKS, PORSI_UKURAN_HURUF)
