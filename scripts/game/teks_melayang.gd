extends Node2D
## Teks singkat yang naik lalu memudar, misalnya reaksi benda kosong atau
## "+ Benih tomat". Menghapus dirinya sendiri setelah selesai.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")

const WARNA_LATAR := Color(0, 0, 0, 0.7)
## Ukuran dalam satuan petak.
const PORSI_TINGGI := 0.42
const PORSI_LEBAR_PER_HURUF := 0.2
const PORSI_NAIK := 0.8

var _teks: String
var _warna: Color
var _ukuran: float
var _lama: float
var _umur := 0.0


func siapkan(teks: String, warna: Color, ukuran_petak: float) -> void:
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
	var lebar := maxf(_ukuran, _teks.length() * _ukuran * PORSI_LEBAR_PER_HURUF)
	var kotak := Rect2(Vector2(-lebar / 2.0, -_ukuran * (0.9 + PORSI_NAIK * t)), Vector2(lebar, tinggi))
	var pudar := 1.0 - maxf(0.0, t - 0.6) / 0.4
	draw_rect(kotak, Color(WARNA_LATAR, WARNA_LATAR.a * pudar))
	Gambar.huruf_tengah(self, _teks, kotak, Color(_warna, pudar), 0.7)
