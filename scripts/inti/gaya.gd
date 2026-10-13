extends RefCounted
## Sistem desain UI "kayu & kertas": satu sumber font, warna, dan resep panel
## untuk semua komponen (HUD, gelembung pesanan, pop-up aksi, teks melayang,
## catatan, layar hasil) supaya UI menyatu dengan adegan. Ubah tampilan di
## sini, bukan di masing-masing komponen.

## Fredoka (OFL, aset/font/). Tebal 600 untuk teks biasa, 700 untuk angka besar.
const FONT := preload("res://aset/font/fredoka.tres")
const FONT_TEBAL := preload("res://aset/font/fredoka_tebal.tres")

const KERTAS := Color("#fff6e3")
const KERTAS_REDUP := Color("#f1e2c3")
const KAYU := Color("#8a5a36")
const KAYU_GELAP := Color("#5e3a22")
const TEKS := Color("#4a2f1c")
const TEKS_SAMAR := Color("#a0805f")
const HIJAU := Color("#6aae45")
const HIJAU_GELAP := Color("#3f7a2a")
const MERAH := Color("#d9493a")
const BAYANGAN := Color(0.24, 0.13, 0.05, 0.32)

const RADIUS := 18.0
const TEBAL_TEPI := 4.0
const JARAK_BAYANGAN := 5.0


## StyleBox panel standar; dipakai Control (add_theme_stylebox_override) dan
## gambar langsung lewat panel().
static func kotak_gaya(isi: Color = KERTAS, tepi: Color = KAYU, radius: float = RADIUS,
		tebal: float = TEBAL_TEPI, bayangan: float = JARAK_BAYANGAN) -> StyleBoxFlat:
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = isi
	gaya.border_color = tepi
	gaya.set_border_width_all(int(tebal))
	gaya.set_corner_radius_all(int(radius))
	gaya.anti_aliasing = true
	if bayangan > 0.0:
		gaya.shadow_color = BAYANGAN
		gaya.shadow_size = 2
		gaya.shadow_offset = Vector2(0, bayangan)
	return gaya


static func panel(kanvas: CanvasItem, kotak: Rect2, radius: float = RADIUS, isi: Color = KERTAS,
		tepi: Color = KAYU, tebal: float = TEBAL_TEPI, bayangan: float = JARAK_BAYANGAN) -> void:
	kanvas.draw_style_box(kotak_gaya(isi, tepi, radius, tebal, bayangan), kotak)


## Lingkaran berbingkai (slot, gelembung): bayangan, tepi, isi.
static func bulatan(kanvas: CanvasItem, pusat: Vector2, r: float, isi: Color = KERTAS,
		tepi: Color = KAYU, tebal: float = TEBAL_TEPI, bayangan: float = JARAK_BAYANGAN) -> void:
	if bayangan > 0.0:
		kanvas.draw_circle(pusat + Vector2(0, bayangan), r + tebal / 2.0, BAYANGAN)
	kanvas.draw_circle(pusat, r + tebal / 2.0, tepi)
	kanvas.draw_circle(pusat, r - tebal / 2.0, isi)
