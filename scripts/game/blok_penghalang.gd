extends Node2D
## Satu blok penghalang bersambung (mis. rumah 2x4 petak) yang digambar
## sebagai satu gambar 3/4, berpijak di dasar blok dan boleh menjulang ke atas.
## Posisi node = pusat baris paling bawah blok, supaya y-sort sejajar dengan
## benda (pusat petak) dan pemain: pemain di belakang blok tertutup olehnya.
## Tanpa aset: kotak warna per petak seperti placeholder lama.

const Gambar := preload("res://scripts/game/gambar.gd")

const PORSI_TEPI := 0.04

var _kotak_dunia: Rect2
var _tekstur: Texture2D
var _ukuran: float
var _sel_cadangan: Array[Vector2i] = []
var _warna := Color.BLACK
var _huruf := ""


## kotak_dunia: batas blok di dunia; sel: petak-petak blok (untuk cadangan).
func siapkan(kotak_dunia: Rect2, tekstur: Texture2D, ukuran_petak: float, sel: Array[Vector2i], warna: Color, huruf: String) -> void:
	_kotak_dunia = kotak_dunia
	_tekstur = tekstur
	_ukuran = ukuran_petak
	_sel_cadangan = sel
	_warna = warna
	_huruf = huruf
	position = Vector2(kotak_dunia.get_center().x, kotak_dunia.end.y - ukuran_petak / 2.0)
	queue_redraw()


func _draw() -> void:
	var kiri_bawah := Vector2(_kotak_dunia.position.x, _kotak_dunia.end.y) - position
	if _tekstur != null:
		var lebar := _kotak_dunia.size.x
		var tinggi := lebar * _tekstur.get_size().y / _tekstur.get_size().x
		draw_texture_rect(_tekstur, Rect2(kiri_bawah - Vector2(0, tinggi), Vector2(lebar, tinggi)), false)
		return
	for sel in _sel_cadangan:
		var kotak := Rect2(Vector2(sel) * _ukuran - position, Vector2.ONE * _ukuran)
		Gambar.kotak_benda(self, kotak.grow(-_ukuran * PORSI_TEPI), _warna, _huruf)
