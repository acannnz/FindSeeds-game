extends Node2D
## Pembeli 'B': hanya menampilkan pesanan, tidak perlu didatangi. Gelembung
## pesanan digambar di baris dinding atas agar tidak menutupi area main.
## Item yang lengkap diberi centang; hasil panen yang tidak dipesan membuat
## pembeli menggeleng.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Aset := preload("res://scripts/inti/aset.gd")

const WARNA_BADAN := Color("#3949ab")
const WARNA_GELEMBUNG := Color(1, 1, 1, 0.95)
const WARNA_TEKS := Color("#263238")
const WARNA_CENTANG := Color("#2e7d32")
const WARNA_SOROT_CENTANG := Color("#c8e6c9")
const PORSI_RADIUS_BADAN := 0.4
## Simpangan geleng sebagai porsi ukuran petak, dan jumlah ayunannya.
const PORSI_GELENG := 0.12
const AYUNAN_GELENG := 3.0

var pesanan: RefCounted
var nama := ""

var _ukuran: float
## Kotak gelembung dalam koordinat lokal pembeli.
var _gelembung := Rect2()
var _lama_reaksi := 0.0
var _sisa_geleng := 0.0
var _sisa_sorot := 0.0
var _tanaman_disorot := ""
var _tekstur: Texture2D
## id tanaman -> tekstur buah untuk ikon di gelembung pesanan.
var _ikon_buah := {}


## kotak_gelembung: kotak gelembung dalam koordinat lokal (dihitung peta).
func siapkan(id_pembeli: String, pesanan_stage: RefCounted, ukuran_petak: float, kotak_gelembung: Rect2) -> void:
	nama = str(DataGame.pembeli.get(id_pembeli, {}).get("nama", id_pembeli))
	pesanan = pesanan_stage
	_ukuran = ukuran_petak
	_gelembung = kotak_gelembung
	_lama_reaksi = DataGame.pengaturan.lama_reaksi_pembeli_detik
	_tekstur = Aset.tekstur(Aset.pembeli(id_pembeli))
	for tanaman in pesanan.diminta:
		_ikon_buah[tanaman] = Aset.tekstur(Aset.tanaman(tanaman, "buah"))
	z_index = 2
	queue_redraw()


## Reaksi saat hasil panen tiba: centang jika dipesan, menggeleng jika tidak.
func reaksi(tanaman: String, diterima: bool) -> void:
	if diterima:
		_tanaman_disorot = tanaman
		_sisa_sorot = _lama_reaksi
	else:
		_sisa_geleng = _lama_reaksi
	queue_redraw()


func sedang_menggeleng() -> bool:
	return _sisa_geleng > 0.0


func _process(delta: float) -> void:
	if _sisa_geleng > 0.0 or _sisa_sorot > 0.0:
		_sisa_geleng = maxf(0.0, _sisa_geleng - delta)
		_sisa_sorot = maxf(0.0, _sisa_sorot - delta)
		queue_redraw()


func _draw() -> void:
	var geser := 0.0
	if _sisa_geleng > 0.0:
		var t := 1.0 - _sisa_geleng / _lama_reaksi
		geser = sin(t * TAU * AYUNAN_GELENG) * _ukuran * PORSI_GELENG
	var pusat := Vector2(geser, 0)
	var kotak_badan := Rect2(pusat - Vector2.ONE * _ukuran / 2.0, Vector2.ONE * _ukuran)
	if _tekstur != null:
		draw_texture_rect(_tekstur, kotak_badan, false)
	else:
		draw_circle(pusat, _ukuran * PORSI_RADIUS_BADAN, WARNA_BADAN)
		Gambar.huruf_tengah(self, "B", kotak_badan, Color.WHITE)
	if pesanan == null or _gelembung.size.x <= 0.0:
		return

	draw_rect(_gelembung, WARNA_GELEMBUNG)
	var tinggi := _gelembung.size.y
	var x := _gelembung.position.x
	var lebar_nama := tinggi * 2.2
	Gambar.huruf_tengah(self, nama, Rect2(Vector2(x, _gelembung.position.y), Vector2(lebar_nama, tinggi)), WARNA_TEKS, 0.4)
	x += lebar_nama
	var lebar_item := minf(tinggi * 1.9, (_gelembung.end.x - x) / maxf(1.0, pesanan.diminta.size()))
	for tanaman in pesanan.diminta:
		var kotak := Rect2(Vector2(x, _gelembung.position.y), Vector2(lebar_item, tinggi)).grow(-tinggi * 0.08)
		if _sisa_sorot > 0.0 and tanaman == _tanaman_disorot:
			draw_rect(kotak, WARNA_SOROT_CENTANG)
		_gambar_item(tanaman, kotak)
		x += lebar_item


func _gambar_item(tanaman: String, kotak: Rect2) -> void:
	var sisi := kotak.size.y
	var ikon := Rect2(kotak.position + Vector2(sisi * 0.1, sisi * 0.15), Vector2.ONE * sisi * 0.7)
	var gambar: Texture2D = _ikon_buah.get(tanaman)
	if gambar != null:
		draw_texture_rect(gambar, ikon.grow(sisi * 0.08), false)
	else:
		var warna := DataGame.warna_tanaman(tanaman)
		draw_rect(ikon, warna)
		Gambar.huruf_tengah(self, DataGame.nama_tanaman(tanaman).left(1), ikon, Gambar.warna_kontras(warna), 0.7)
	var kotak_angka := Rect2(Vector2(ikon.end.x, kotak.position.y), Vector2(kotak.end.x - ikon.end.x, sisi))
	if pesanan.tanaman_lengkap(tanaman):
		_gambar_centang(kotak_angka.grow(-sisi * 0.18))
	else:
		var teks := "%d/%d" % [pesanan.terisi[tanaman], pesanan.diminta[tanaman]]
		Gambar.huruf_tengah(self, teks, kotak_angka, WARNA_TEKS, 0.5)


## Centang digambar dengan garis (font bawaan belum tentu punya simbol ✓).
func _gambar_centang(kotak: Rect2) -> void:
	var s := minf(kotak.size.x, kotak.size.y)
	var o := kotak.get_center() - Vector2.ONE * s / 2.0
	var titik := PackedVector2Array([o + Vector2(0.1, 0.55) * s, o + Vector2(0.4, 0.85) * s, o + Vector2(0.9, 0.2) * s])
	draw_polyline(titik, WARNA_CENTANG, maxf(2.0, s * 0.14))
