extends StaticBody2D
## Satu benda di peta (sumber, kosong, wadah, atau alat). Padat: pemain
## berinteraksi dari petak sebelah. Keadaannya diubah oleh interaksi.gd.
## Digambar dengan aset SVG-nya; jika belum ada, kotak warna + huruf.

const DataGame := preload("res://scripts/inti/data_game.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Aset := preload("res://scripts/inti/aset.gd")
const SHADER_ABU := preload("res://scripts/game/abu.gdshader")

## Jarak tepi kotak gambar dari tepi petak, sebagai porsi ukuran petak.
const PORSI_TEPI := 0.1
const PORSI_HURUF_LABEL := 0.45
const WARNA_ABU := Color("#9e9e9e")
const WARNA_SOROT := Color("#ffeb3b")
const WARNA_GELEMBUNG := Color(1, 1, 1, 0.92)
const WARNA_TEKS_GELEMBUNG := Color("#263238")
const WARNA_LABEL_WADAH := Color("#5d4037")
## Area tulisan di muka kardus (porsi petak, sesuai aset/benda/kardus.svg).
const KOTAK_LABEL_WADAH := Rect2(Vector2(-0.33, -0.06), Vector2(0.66, 0.3))
const PORSI_GELEMBUNG := 0.42

var id: String
var huruf: String
var entri: Dictionary
var sel: Vector2i
var status := AturanAksi.STATUS_NORMAL
## True jika benda ini target tombol aksi saat ini.
var disorot := false:
	set(v):
		if v != disorot:
			disorot = v
			queue_redraw()
## Id alat yang ikonnya ditampilkan di gelembung di atas wadah, atau "".
var ikon_alat := "":
	set(v):
		if v != ikon_alat:
			ikon_alat = v
			# Gelembung menjorok ke petak atas; gambar di atas benda lain.
			z_index = 1 if v != "" else 0
			_tekstur_ikon = Aset.tekstur(Aset.benda(v, DataGame.entri_benda(v))) if v != "" else null
			queue_redraw()

var _ukuran: float
var _tekstur: Texture2D
var _tekstur_ikon: Texture2D
static var _bahan_abu: ShaderMaterial


func siapkan(id_benda: String, huruf_peta: String, sel_peta: Vector2i, ukuran_petak: float) -> void:
	sel = sel_peta
	_ukuran = ukuran_petak
	name = "Benda_%d_%d" % [sel.x, sel.y]
	var bentuk := CollisionShape2D.new()
	var kotak := RectangleShape2D.new()
	kotak.size = Vector2.ONE * _ukuran
	bentuk.shape = kotak
	add_child(bentuk)
	_jadi(id_benda, huruf_peta)


func jenis() -> String:
	return PemuatData.jenis_benda(entri)


## Benda kosong yang sudah dicoba: abu-abu dan tidak bisa dicoba lagi.
func jadi_abu() -> void:
	status = AturanAksi.STATUS_ABU
	if _bahan_abu == null:
		_bahan_abu = ShaderMaterial.new()
		_bahan_abu.shader = SHADER_ABU
	material = _bahan_abu
	queue_redraw()


## Wadah dibuka: isinya tertinggal di petak yang sama.
func buka() -> void:
	_jadi(entri.isi)


## Mengganti benda ini dengan benda lain (dipakai saat menukar alat).
func ganti_menjadi(id_baru: String) -> void:
	_jadi(id_baru)


## Huruf placeholder benda yang tidak berasal dari peta: huruf pertama namanya.
func _jadi(id_baru: String, huruf_peta: String = "") -> void:
	id = id_baru
	entri = DataGame.entri_benda(id)
	huruf = huruf_peta if huruf_peta != "" else DataGame.nama_benda(id).left(1).to_upper()
	status = AturanAksi.STATUS_NORMAL
	material = null
	ikon_alat = ""
	_tekstur = Aset.tekstur(Aset.benda(id, entri))
	queue_redraw()


func _draw() -> void:
	var tepi := _ukuran * PORSI_TEPI
	var kotak := Rect2(Vector2.ONE * (-_ukuran / 2.0 + tepi), Vector2.ONE * (_ukuran - 2.0 * tepi))
	var warna := Color(entri.get("warna", "#ffffff"))
	if status == AturanAksi.STATUS_ABU:
		warna = WARNA_ABU
	if _tekstur != null:
		draw_texture_rect(_tekstur, Rect2(Vector2.ONE * -_ukuran / 2.0, Vector2.ONE * _ukuran), false)
		if entri.has("label"):
			var area := Rect2(KOTAK_LABEL_WADAH.position * _ukuran, KOTAK_LABEL_WADAH.size * _ukuran)
			Gambar.huruf_tengah(self, entri.label, area, WARNA_LABEL_WADAH, 0.7)
	elif entri.has("label"):
		# Wadah: tulisan besar sebagai petunjuk isinya.
		draw_rect(kotak, warna)
		draw_rect(kotak, warna.darkened(0.35), false, 2.0)
		Gambar.huruf_tengah(self, entri.label, kotak, Gambar.warna_kontras(warna), PORSI_HURUF_LABEL)
	else:
		Gambar.kotak_benda(self, kotak, warna, huruf)
	if disorot:
		draw_rect(kotak.grow(tepi * 0.6), WARNA_SOROT, false, 3.0)
	if ikon_alat != "":
		var r := _ukuran * PORSI_GELEMBUNG / 2.0
		var pusat := Vector2(0, -_ukuran * 0.5 - r - 4.0)
		draw_circle(pusat, r + 2.0, WARNA_TEKS_GELEMBUNG)
		draw_circle(pusat, r, WARNA_GELEMBUNG)
		if _tekstur_ikon != null:
			draw_texture_rect(_tekstur_ikon, Rect2(pusat - Vector2.ONE * r * 0.8, Vector2.ONE * r * 1.6), false)
		else:
			Gambar.huruf_tengah(self, DataGame.nama_benda(ikon_alat), Rect2(pusat - Vector2(r * 2.0, r), Vector2(r * 4.0, r * 2.0)), WARNA_TEKS_GELEMBUNG, 0.6)
