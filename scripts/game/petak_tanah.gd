extends Node2D
## Satu petak tanah. Bisa diinjak. Tanam dan panen ditambahkan di fase 6.

const Gambar := preload("res://scripts/game/gambar.gd")

const WARNA_TANAH := Color("#8d5a3b")
const WARNA_ALUR := Color("#6d4029")
const JUMLAH_ALUR := 3

var sel: Vector2i
var _ukuran: float


func siapkan(sel_peta: Vector2i, ukuran_petak: float) -> void:
	sel = sel_peta
	_ukuran = ukuran_petak
	name = "Tanah_%d_%d" % [sel.x, sel.y]
	queue_redraw()


func _draw() -> void:
	var kotak := Rect2(Vector2.ONE * (-_ukuran / 2.0), Vector2.ONE * _ukuran)
	draw_rect(kotak, WARNA_TANAH)
	for i in JUMLAH_ALUR:
		var y := kotak.position.y + _ukuran * (i + 1) / (JUMLAH_ALUR + 1)
		draw_line(Vector2(kotak.position.x + 4, y), Vector2(kotak.end.x - 4, y), WARNA_ALUR, 2.0)
	Gambar.huruf_tengah(self, "T", kotak, Color(1, 1, 1, 0.35))
