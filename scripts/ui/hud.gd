extends Control
## HUD di tepi atas layar: satu papan kertas berbingkai kayu (gaya.gd) berisi
## jam + timer (merah pada detik-detik terakhir) dan nama stage di kiri, slot
## kantong benih bulat (urut dari yang akan ditanam duluan) di tengah, dan
## slot alat di tangan di kanan. Pesanan tampil di gelembung pembeli di peta.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Aset := preload("res://scripts/inti/aset.gd")
const Gaya := preload("res://scripts/inti/gaya.gd")

const TEPI := 12.0
const PADAT := 14.0
const LEBAR_KIRI := 236.0
const R_JAM := 24.0
const R_SLOT := 30.0
const JARAK_SLOT := 12.0
const R_TANGAN := 34.0
## Ukuran huruf timer sebagai porsi tinggi kotaknya.
const PORSI_UKURAN_TIMER := 0.85
const UKURAN_JUDUL := 19
## Getar jam saat timer merah (radian per detik).
const KECEPATAN_DENYUT := 12.0

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


func _process(_delta: float) -> void:
	if merah():
		queue_redraw()


func _draw() -> void:
	var tinggi: float = DataGame.pengaturan.tinggi_hud_atas_px
	var papan := Rect2(Vector2(TEPI, inset_atas + TEPI * 0.5), Vector2(size.x - 2.0 * TEPI, tinggi - TEPI * 1.5))
	Gaya.panel(self, papan, 26.0)
	var tengah_y := papan.get_center().y

	# Kiri: jam, timer besar, nama stage kecil di bawahnya.
	var warna_timer := Gaya.MERAH if merah() else Gaya.TEKS
	var pusat_jam := Vector2(papan.position.x + PADAT + R_JAM, tengah_y)
	if merah():
		pusat_jam.x += sin(Time.get_ticks_msec() / 1000.0 * KECEPATAN_DENYUT) * 1.5
	_gambar_jam(pusat_jam, warna_timer)
	var x_teks := pusat_jam.x + R_JAM + 10.0
	var lebar_teks := papan.position.x + LEBAR_KIRI - x_teks
	var kotak_timer := Rect2(Vector2(x_teks, papan.position.y + 4.0), Vector2(lebar_teks, papan.size.y * 0.62))
	_teks_kiri(teks_timer(), kotak_timer, warna_timer, int(kotak_timer.size.y * PORSI_UKURAN_TIMER), Gaya.FONT_TEBAL)
	var kotak_judul := Rect2(Vector2(x_teks, kotak_timer.end.y - 6.0), Vector2(lebar_teks, papan.end.y - kotak_timer.end.y))
	_teks_kiri(judul, kotak_judul, Gaya.TEKS_SAMAR, UKURAN_JUDUL, Gaya.FONT)

	# Kanan: slot alat di tangan.
	var pusat_tangan := Vector2(papan.end.x - PADAT - R_TANGAN, tengah_y)
	Gaya.bulatan(self, pusat_tangan, R_TANGAN, Gaya.KERTAS_REDUP, Gaya.KAYU, 4.0, 0.0)
	var ikon_alat := Aset.tekstur(Aset.benda(_alat, DataGame.entri_benda(_alat))) if _alat != "" else null
	if ikon_alat != null:
		var sisi := R_TANGAN * 1.7
		draw_texture_rect(ikon_alat, Rect2(pusat_tangan - Vector2.ONE * sisi / 2.0, Vector2.ONE * sisi), false)
	elif _alat != "":
		Gambar.huruf_tengah(self, DataGame.nama_benda(_alat), Rect2(pusat_tangan - Vector2(R_TANGAN, R_TANGAN / 2.0), Vector2(R_TANGAN * 2.0, R_TANGAN)), Gaya.TEKS, 0.45)
	else:
		# Tangan kosong: ikon tangan samar.
		var ikon_tangan := Aset.tekstur(Aset.aksi("ambil"))
		if ikon_tangan != null:
			var sisi := R_TANGAN * 1.2
			draw_texture_rect(ikon_tangan, Rect2(pusat_tangan - Vector2.ONE * sisi / 2.0, Vector2.ONE * sisi), false, Color(Gaya.TEKS_SAMAR, 0.55))

	# Tengah: slot kantong benih bulat.
	var lebar_kantong := _kapasitas * R_SLOT * 2.0 + (_kapasitas - 1) * JARAK_SLOT
	var x_awal := (papan.position.x + LEBAR_KIRI + pusat_tangan.x - R_TANGAN - lebar_kantong) / 2.0
	for i in _kapasitas:
		var pusat := Vector2(x_awal + R_SLOT + i * (R_SLOT * 2.0 + JARAK_SLOT), tengah_y)
		Gaya.bulatan(self, pusat, R_SLOT, Gaya.KERTAS_REDUP, Gaya.KAYU, 3.0, 0.0)
		if i >= _isi_kantong.size():
			# Slot kosong: bentuk biji samar.
			draw_set_transform(pusat, -0.5, Vector2(0.6, 1.0))
			draw_circle(Vector2.ZERO, R_SLOT * 0.32, Color(Gaya.TEKS_SAMAR, 0.35))
			draw_set_transform(Vector2.ZERO)
			continue
		var ikon_buah := Aset.tekstur(Aset.tanaman(_isi_kantong[i], "buah"))
		if ikon_buah != null:
			var sisi := R_SLOT * 1.6
			draw_texture_rect(ikon_buah, Rect2(pusat - Vector2.ONE * sisi / 2.0, Vector2.ONE * sisi), false)
		else:
			var warna := DataGame.warna_tanaman(_isi_kantong[i])
			draw_circle(pusat, R_SLOT * 0.7, warna)
			Gambar.huruf_tengah(self, DataGame.nama_tanaman(_isi_kantong[i]).left(1), Rect2(pusat - Vector2.ONE * R_SLOT, Vector2.ONE * R_SLOT * 2.0), Gambar.warna_kontras(warna), 0.5)


func _gambar_jam(pusat: Vector2, warna: Color) -> void:
	Gaya.bulatan(self, pusat, R_JAM, Gaya.KERTAS_REDUP, warna, 4.0, 0.0)
	draw_line(pusat, pusat + Vector2(0, -R_JAM * 0.55), warna, 3.5, true)
	draw_line(pusat, pusat + Vector2(R_JAM * 0.4, 0), warna, 3.5, true)
	draw_circle(pusat, 3.0, warna)


func _teks_kiri(teks: String, kotak: Rect2, warna: Color, ukuran: int, font: Font) -> void:
	var lebar := font.get_string_size(teks, HORIZONTAL_ALIGNMENT_LEFT, -1, ukuran).x
	if lebar > kotak.size.x:
		ukuran = maxi(8, int(ukuran * kotak.size.x / lebar))
	var dasar := kotak.get_center().y + (font.get_ascent(ukuran) - font.get_descent(ukuran)) / 2.0
	draw_string(font, Vector2(kotak.position.x, dasar), teks, HORIZONTAL_ALIGNMENT_LEFT, kotak.size.x, ukuran, warna)
