extends Control
## Deretan bintang emas (terisi sebanyak `jumlah`), kosong = kertas redup.
## Digambar sebagai poligon karena font belum tentu punya simbol bintang.

const Bintang := preload("res://scripts/inti/bintang.gd")
const Gaya := preload("res://scripts/inti/gaya.gd")

const WARNA_ISI := Color("#f6c445")
const WARNA_KILAU := Color("#fde59a")
const WARNA_TEPI := Color("#b7781c")
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
		var terisi := i < jumlah
		draw_colored_polygon(titik, WARNA_ISI if terisi else Gaya.KERTAS_REDUP)
		if terisi:
			draw_colored_polygon(_titik_bintang(pusat - Vector2(radius * 0.12, radius * 0.14), radius * 0.45), WARNA_KILAU)
		titik.append(titik[0])
		draw_polyline(titik, WARNA_TEPI if terisi else Gaya.TEKS_SAMAR, 4.0, true)


func _titik_bintang(pusat: Vector2, radius: float) -> PackedVector2Array:
	var titik := PackedVector2Array()
	for k in SUDUT_BINTANG * 2:
		var r := radius if k % 2 == 0 else radius * PORSI_DALAM
		var sudut := -PI / 2.0 + k * PI / SUDUT_BINTANG
		titik.append(pusat + Vector2(cos(sudut), sin(sudut)) * r)
	return titik
