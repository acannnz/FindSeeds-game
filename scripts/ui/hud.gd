extends Control
## Baris info di atas area kontrol: nama stage, isi kantong benih (slot
## sebanyak kapasitas, urut dari yang akan ditanam duluan), dan alat di tangan.
## Timer dan pesanan ditambahkan di fase berikutnya.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")

const WARNA_JUDUL := Color(1, 1, 1, 0.8)
const WARNA_SLOT_KOSONG := Color(1, 1, 1, 0.1)
const WARNA_TEPI_SLOT := Color(1, 1, 1, 0.35)
const WARNA_TEKS := Color.WHITE
const TEPI := 16.0
const TINGGI_JUDUL := 34.0
const TINGGI_SLOT := 52.0
const LEBAR_SLOT := 108.0
const JARAK_SLOT := 8.0
const LEBAR_TANGAN := 210.0

var judul := "":
	set(v):
		judul = v
		queue_redraw()

var _isi_kantong: Array[String] = []
var _kapasitas := 0
var _alat := ""


func perbarui(kantong: RefCounted, alat_di_tangan: String) -> void:
	_isi_kantong = kantong.isi.duplicate()
	_kapasitas = kantong.kapasitas
	_alat = alat_di_tangan
	queue_redraw()


func _draw() -> void:
	Gambar.huruf_tengah(self, judul, Rect2(Vector2.ZERO, Vector2(size.x, TINGGI_JUDUL)), WARNA_JUDUL, 0.6)

	var y := TINGGI_JUDUL + 6.0
	var label_kantong := Rect2(Vector2(TEPI, y), Vector2(LEBAR_SLOT, TINGGI_SLOT * 0.4))
	Gambar.huruf_tengah(self, "Kantong", label_kantong, WARNA_JUDUL, 0.9)
	var y_slot := y + TINGGI_SLOT * 0.45
	for i in _kapasitas:
		var kotak := Rect2(Vector2(TEPI + i * (LEBAR_SLOT + JARAK_SLOT), y_slot), Vector2(LEBAR_SLOT, TINGGI_SLOT))
		if i < _isi_kantong.size():
			var warna := DataGame.warna_tanaman(_isi_kantong[i])
			draw_rect(kotak, warna)
			Gambar.huruf_tengah(self, DataGame.nama_tanaman(_isi_kantong[i]), kotak, Gambar.warna_kontras(warna), 0.42)
		else:
			draw_rect(kotak, WARNA_SLOT_KOSONG)
		draw_rect(kotak, WARNA_TEPI_SLOT, false, 2.0)

	var x_tangan := size.x - TEPI - LEBAR_TANGAN
	Gambar.huruf_tengah(self, "Tangan", Rect2(Vector2(x_tangan, y), Vector2(LEBAR_TANGAN, TINGGI_SLOT * 0.4)), WARNA_JUDUL, 0.9)
	var kotak_tangan := Rect2(Vector2(x_tangan, y_slot), Vector2(LEBAR_TANGAN, TINGGI_SLOT))
	draw_rect(kotak_tangan, WARNA_SLOT_KOSONG)
	draw_rect(kotak_tangan, WARNA_TEPI_SLOT, false, 2.0)
	var teks_tangan := DataGame.nama_benda(_alat) if _alat != "" else "-"
	Gambar.huruf_tengah(self, teks_tangan, kotak_tangan, WARNA_TEKS, 0.42)
