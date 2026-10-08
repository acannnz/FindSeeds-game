extends Control
## Deretan bintang (terisi sebanyak `jumlah`). Digambar sebagai poligon karena
## font bawaan belum tentu punya simbol bintang.

const Bintang := preload("res://scripts/inti/bintang.gd")

const WARNA_ISI := Color("#ffd54f")
const WARNA_KOSONG := Color(1, 1, 1, 0.18)
const WARNA_TEPI := Color("#ff8f00")
const SUDUT_BINTANG := 5
const PORSI_DALAM := 0.45

var jumlah := 0:
	set(v):
		jumlah = v
		queue_redraw()


func _draw() -> void:
	var lebar_satu := size.x / Bintang.BINTANG_MAKS
	var radius := minf(lebar_satu, size.y) * 0.45
	for i in Bintang.BINTANG_MAKS:
		var pusat := Vector2(lebar_satu * (i + 0.5), size.y / 2.0)
		var titik := _titik_bintang(pusat, radius)
		draw_colored_polygon(titik, WARNA_ISI if i < jumlah else WARNA_KOSONG)
		if i < jumlah:
			titik.append(titik[0])
			draw_polyline(titik, WARNA_TEPI, 3.0)


func _titik_bintang(pusat: Vector2, radius: float) -> PackedVector2Array:
	var titik := PackedVector2Array()
	for k in SUDUT_BINTANG * 2:
		var r := radius if k % 2 == 0 else radius * PORSI_DALAM
		var sudut := -PI / 2.0 + k * PI / SUDUT_BINTANG
		titik.append(pusat + Vector2(cos(sudut), sin(sudut)) * r)
	return titik
