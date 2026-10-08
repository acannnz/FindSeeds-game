extends RefCounted
## Pembantu menggambar placeholder: kotak warna dengan huruf di tengah.

## Porsi tinggi petak yang dipakai untuk ukuran huruf.
const PORSI_HURUF := 0.5


static func huruf_tengah(kanvas: CanvasItem, teks: String, kotak: Rect2, warna: Color, porsi: float = PORSI_HURUF) -> void:
	var font := ThemeDB.fallback_font
	var ukuran_font := maxi(8, int(kotak.size.y * porsi))
	var garis_dasar := kotak.get_center().y + (font.get_ascent(ukuran_font) - font.get_descent(ukuran_font)) / 2.0
	kanvas.draw_string(font, Vector2(kotak.position.x, garis_dasar), teks, HORIZONTAL_ALIGNMENT_CENTER, kotak.size.x, ukuran_font, warna)


## Hitam atau putih, mana yang lebih terbaca di atas warna latar.
static func warna_kontras(latar: Color) -> Color:
	return Color.BLACK if latar.get_luminance() > 0.55 else Color.WHITE


static func kotak_benda(kanvas: CanvasItem, kotak: Rect2, warna: Color, huruf: String) -> void:
	kanvas.draw_rect(kotak, warna)
	kanvas.draw_rect(kotak, warna.darkened(0.35), false, 2.0)
	huruf_tengah(kanvas, huruf, kotak, warna_kontras(warna))
