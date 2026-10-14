extends Control
## Layar di atas stage: hasil menang (bintang, sisa waktu, Ulangi/Lanjut),
## "Waktu habis!" sebelum stage diulang otomatis, dan "Dijeda" saat aplikasi
## pindah ke latar belakang. Kartu kertas berbingkai kayu (gaya.gd); "Lanjut"
## tombol utama berwarna hijau.

signal ulangi
signal lanjut

const Gaya := preload("res://scripts/inti/gaya.gd")

const PADAT_KARTU := 40.0

@onready var _judul: Label = %Judul
@onready var _bintang: Control = %Bintang
@onready var _info: Label = %Info
@onready var _rekor: Label = %Rekor
@onready var _tombol: Control = %Tombol
@onready var _tombol_ulangi: Button = %Ulangi
@onready var _tombol_lanjut: Button = %Lanjut


func _ready() -> void:
	var kartu := Gaya.kotak_gaya(Gaya.KERTAS, Gaya.KAYU, 30.0, 5.0, 8.0)
	kartu.set_content_margin_all(PADAT_KARTU)
	%Kartu.add_theme_stylebox_override("panel", kartu)
	_judul.add_theme_font_override("font", Gaya.FONT_TEBAL)
	_info.add_theme_color_override("font_color", Gaya.TEKS)
	_gaya_tombol(_tombol_ulangi, Gaya.KERTAS_REDUP, Gaya.KAYU, Gaya.TEKS)
	_gaya_tombol(_tombol_lanjut, Gaya.HIJAU, Gaya.HIJAU_GELAP, Color.WHITE)
	_tombol_ulangi.pressed.connect(ulangi.emit)
	_tombol_lanjut.pressed.connect(lanjut.emit)
	sembunyikan()


## rekor: bintang terbaik setelah hasil ini dicatat; rekor_baru: hasil ini memecahkannya.
func tampilkan_menang(bintang: int, sisa_detik: float, teks_lanjut: String, rekor: int, rekor_baru: bool) -> void:
	_judul.text = "Pesanan lengkap!"
	_judul.add_theme_color_override("font_color", Gaya.KAYU_GELAP)
	_bintang.jumlah = bintang
	_bintang.show()
	_info.text = "Sisa waktu %d detik" % floori(sisa_detik)
	_info.show()
	_rekor.text = "Rekor baru!" if rekor_baru else "Rekor: %d bintang" % rekor
	_rekor.add_theme_color_override("font_color", Gaya.HIJAU_GELAP if rekor_baru else Gaya.TEKS_SAMAR)
	_rekor.show()
	_tombol_lanjut.text = teks_lanjut
	_tombol.show()
	show()


func tampilkan_waktu_habis() -> void:
	_tampilkan_pesan("Waktu habis!", Gaya.MERAH)


func tampilkan_jeda() -> void:
	_tampilkan_pesan("Dijeda", Gaya.KAYU_GELAP)


func sembunyikan() -> void:
	hide()


func sedang_tampil() -> bool:
	return visible


func judul() -> String:
	return _judul.text


func teks_rekor() -> String:
	return _rekor.text if _rekor.visible else ""


func jumlah_bintang() -> int:
	return _bintang.jumlah if _bintang.visible else 0


func _tampilkan_pesan(teks: String, warna: Color) -> void:
	_judul.text = teks
	_judul.add_theme_color_override("font_color", warna)
	_bintang.hide()
	_info.hide()
	_rekor.hide()
	_tombol.hide()
	show()


## Tombol kayu membulat: normal, disorot (sedikit lebih terang), ditekan (turun).
func _gaya_tombol(tombol: Button, isi: Color, tepi: Color, warna_teks: Color) -> void:
	tombol.add_theme_stylebox_override("normal", Gaya.kotak_gaya(isi, tepi, 22.0, 4.0, 5.0))
	tombol.add_theme_stylebox_override("hover", Gaya.kotak_gaya(isi.lightened(0.08), tepi, 22.0, 4.0, 5.0))
	tombol.add_theme_stylebox_override("focus", Gaya.kotak_gaya(isi.lightened(0.08), tepi, 22.0, 4.0, 5.0))
	var ditekan := Gaya.kotak_gaya(isi.darkened(0.08), tepi, 22.0, 4.0, 1.0)
	ditekan.content_margin_top = 4.0
	tombol.add_theme_stylebox_override("pressed", ditekan)
	tombol.add_theme_font_override("font", Gaya.FONT_TEBAL)
	for keadaan in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		tombol.add_theme_color_override(keadaan, warna_teks)
