extends Control
## HUD melayang di tepi atas layar, langsung di atas tampilan game (tanpa
## panel): timer (merah pada detik-detik terakhir) dan nama stage di kiri,
## slot kantong benih (urut dari yang akan ditanam duluan) di tengah, dan alat
## di tangan di kanan. Pesanan tampil di gelembung pembeli di peta.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Aset := preload("res://scripts/inti/aset.gd")

const WARNA_LATAR := Color(0.06, 0.08, 0.07, 0.6)
const WARNA_SLOT_KOSONG := Color(1, 1, 1, 0.12)
const WARNA_TEPI_SLOT := Color(1, 1, 1, 0.4)
const WARNA_TEKS := Color.WHITE
const WARNA_TEKS_SAMAR := Color(1, 1, 1, 0.7)
const WARNA_TIMER := Color.WHITE
const WARNA_TIMER_MERAH := Color("#ff5252")
const TEPI := 14.0
const LEBAR_KIRI := 240.0
const SISI_SLOT := 64.0
const JARAK_SLOT := 8.0
const LEBAR_TANGAN := 128.0
const TINGGI_LABEL := 20.0

var judul := "":
	set(v):
		judul = v
		queue_redraw()
## Jarak dari tepi atas layar (area aman di HP berponi).
var inset_atas := 0.0:
	set(v):
		inset_atas = v
		queue_redraw()
## Sisa waktu stage. Digambar ulang hanya saat detik yang tampil berubah.
var sisa_detik := 0.0:
	set(v):
		var berubah := ceili(v) != ceili(sisa_detik)
		sisa_detik = v
		if berubah:
			queue_redraw()

var _isi_kantong: Array[String] = []
var _kapasitas := 0
var _alat := ""


func perbarui(kantong: RefCounted, alat_di_tangan: String) -> void:
	_isi_kantong = kantong.isi.duplicate()
	_kapasitas = kantong.kapasitas
	_alat = alat_di_tangan
	queue_redraw()


## True pada detik-detik terakhir (timer_merah_sisa_detik di pengaturan).
func merah() -> bool:
	return sisa_detik <= float(DataGame.pengaturan.timer_merah_sisa_detik)


func teks_timer() -> String:
	var detik := ceili(sisa_detik)
	return "%d:%02d" % [detik / 60, detik % 60]


func _draw() -> void:
	var tinggi: float = DataGame.pengaturan.tinggi_hud_atas_px
	var y := inset_atas + TEPI
	var tinggi_isi := tinggi - 2.0 * TEPI

	# Kiri: timer besar, nama stage kecil di bawahnya.
	var kotak_kiri := Rect2(Vector2(TEPI, y), Vector2(LEBAR_KIRI, tinggi_isi))
	draw_rect(kotak_kiri, WARNA_LATAR)
	var kotak_timer := Rect2(kotak_kiri.position, Vector2(LEBAR_KIRI, tinggi_isi - TINGGI_LABEL))
	Gambar.huruf_tengah(self, teks_timer(), kotak_timer, WARNA_TIMER_MERAH if merah() else WARNA_TIMER, 0.85)
	var kotak_judul := Rect2(Vector2(kotak_kiri.position.x, kotak_kiri.end.y - TINGGI_LABEL - 4.0), Vector2(LEBAR_KIRI, TINGGI_LABEL))
	Gambar.huruf_tengah(self, judul, kotak_judul, WARNA_TEKS_SAMAR, 0.8)

	# Kanan: alat di tangan.
	var kotak_tangan := Rect2(Vector2(size.x - TEPI - LEBAR_TANGAN, y), Vector2(LEBAR_TANGAN, tinggi_isi))
	draw_rect(kotak_tangan, WARNA_LATAR)
	Gambar.huruf_tengah(self, "Tangan", Rect2(kotak_tangan.position, Vector2(LEBAR_TANGAN, TINGGI_LABEL + 4.0)), WARNA_TEKS_SAMAR, 0.75)
	var isi_tangan := Rect2(kotak_tangan.position + Vector2(0, TINGGI_LABEL), Vector2(LEBAR_TANGAN, tinggi_isi - TINGGI_LABEL))
	var ikon_alat := Aset.tekstur(Aset.benda(_alat, DataGame.entri_benda(_alat))) if _alat != "" else null
	if ikon_alat != null:
		var sisi := isi_tangan.size.y
		draw_texture_rect(ikon_alat, Rect2(isi_tangan.get_center() - Vector2.ONE * sisi / 2.0, Vector2.ONE * sisi), false)
	else:
		Gambar.huruf_tengah(self, DataGame.nama_benda(_alat) if _alat != "" else "-", isi_tangan, WARNA_TEKS, 0.45)

	# Tengah: slot kantong benih.
	var lebar_kantong := _kapasitas * SISI_SLOT + (_kapasitas + 1) * JARAK_SLOT
	var x_kantong := (kotak_kiri.end.x + kotak_tangan.position.x - lebar_kantong) / 2.0
	var kotak_kantong := Rect2(Vector2(x_kantong, y), Vector2(lebar_kantong, tinggi_isi))
	draw_rect(kotak_kantong, WARNA_LATAR)
	Gambar.huruf_tengah(self, "Kantong", Rect2(kotak_kantong.position, Vector2(lebar_kantong, TINGGI_LABEL + 4.0)), WARNA_TEKS_SAMAR, 0.75)
	var sisi := minf(SISI_SLOT, tinggi_isi - TINGGI_LABEL - JARAK_SLOT)
	for i in _kapasitas:
		var kotak := Rect2(Vector2(x_kantong + JARAK_SLOT + i * (SISI_SLOT + JARAK_SLOT), y + TINGGI_LABEL + 2.0), Vector2(SISI_SLOT, sisi))
		var ikon_buah := Aset.tekstur(Aset.tanaman(_isi_kantong[i], "buah")) if i < _isi_kantong.size() else null
		if ikon_buah != null:
			draw_rect(kotak, WARNA_SLOT_KOSONG)
			draw_texture_rect(ikon_buah, kotak.grow(-3.0), false)
		elif i < _isi_kantong.size():
			var warna := DataGame.warna_tanaman(_isi_kantong[i])
			draw_rect(kotak, warna)
			Gambar.huruf_tengah(self, DataGame.nama_tanaman(_isi_kantong[i]), kotak, Gambar.warna_kontras(warna), 0.32)
		else:
			draw_rect(kotak, WARNA_SLOT_KOSONG)
		draw_rect(kotak, WARNA_TEPI_SLOT, false, 2.0)
