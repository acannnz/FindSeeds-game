extends StaticBody2D
## Satu benda di peta (sumber, kosong, wadah, atau alat). Padat: pemain
## berinteraksi dari petak sebelah. Keadaannya diubah oleh interaksi.gd.
## Digambar dengan aset SVG-nya (3/4, berpijak di dasar petak, boleh lebih
## tinggi dari satu petak); jika belum ada, kotak warna + huruf. Node ini
## di-y-sort bersama pemain, jadi benda di depan menutupi pemain di belakangnya.

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
const WARNA_GELEMBUNG := Color(1, 1, 1, 0.92)
const WARNA_TEKS_GELEMBUNG := Color("#263238")
const WARNA_LABEL_WADAH := Color("#5d4037")
## Area tulisan di muka kardus, sebagai porsi ukuran gambar (0..1), sesuai
## panel kosong di aset/benda/kardus.svg.
const KOTAK_LABEL_WADAH := Rect2(Vector2(0.17, 0.44), Vector2(0.66, 0.31))
const PORSI_GELEMBUNG := 0.42
## Piksel tekstur per petak (SVG viewBox 128 per petak, diekspor 2x).
const PIKSEL_PER_PETAK := 256.0
const WARNA_CINCIN := Color(1, 1, 1, 0.55)
## Lapisan gelembung ikon alat: di atas pemain dan benda lain.
const LAPISAN_GELEMBUNG := 5

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
			_tekstur_ikon = Aset.tekstur(Aset.benda(v, DataGame.entri_benda(v))) if v != "" else null
			if _gelembung:
				_gelembung.queue_redraw()

var _ukuran: float
var _tekstur: Texture2D
var _tekstur_ikon: Texture2D
var _gelembung: Node2D
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
	# Gelembung ikon alat di node anak dengan z_index sendiri, supaya tidak
	# ikut tertutup pemain walau bendanya tertutup.
	_gelembung = Node2D.new()
	_gelembung.z_index = LAPISAN_GELEMBUNG
	_gelembung.draw.connect(_gambar_gelembung)
	add_child(_gelembung)
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
	if disorot:
		# Sorotan halus: cincin di kaki benda, tidak mencolok.
		draw_arc(Vector2(0, _ukuran * 0.36), _ukuran * 0.42, 0.0, TAU, 32, WARNA_CINCIN, 3.0, true)
	if _tekstur != null:
		# Benda digambar lebih besar dari petaknya supaya adegan rapat dan
		# benda saling bersinggungan (menyatu); tabrakan tetap satu petak.
		var ukuran_gambar: Vector2 = _tekstur.get_size() / PIKSEL_PER_PETAK * _ukuran * float(DataGame.pengaturan.skala_gambar_benda)
		var dasar := Vector2(-ukuran_gambar.x / 2.0, _ukuran / 2.0 - ukuran_gambar.y)
		draw_texture_rect(_tekstur, Rect2(dasar, ukuran_gambar), false)
		if entri.has("label"):
			var area := Rect2(dasar + KOTAK_LABEL_WADAH.position * ukuran_gambar, KOTAK_LABEL_WADAH.size * ukuran_gambar)
			Gambar.huruf_tengah(self, entri.label, area, WARNA_LABEL_WADAH, 0.7)
		return
	var warna := WARNA_ABU if status == AturanAksi.STATUS_ABU else Color(entri.get("warna", "#ffffff"))
	if entri.has("label"):
		draw_rect(kotak, warna)
		draw_rect(kotak, warna.darkened(0.35), false, 2.0)
		Gambar.huruf_tengah(self, entri.label, kotak, Gambar.warna_kontras(warna), PORSI_HURUF_LABEL)
	else:
		Gambar.kotak_benda(self, kotak, warna, huruf)


func _gambar_gelembung() -> void:
	if ikon_alat == "":
		return
	var r := _ukuran * PORSI_GELEMBUNG / 2.0
	var pusat := Vector2(0, -_ukuran * 0.5 - r - 4.0)
	_gelembung.draw_circle(pusat, r + 2.0, WARNA_TEKS_GELEMBUNG)
	_gelembung.draw_circle(pusat, r, WARNA_GELEMBUNG)
	if _tekstur_ikon != null:
		_gelembung.draw_texture_rect(_tekstur_ikon, Rect2(pusat - Vector2.ONE * r * 0.8, Vector2.ONE * r * 1.6), false)
	else:
		Gambar.huruf_tengah(_gelembung, DataGame.nama_benda(ikon_alat), Rect2(pusat - Vector2(r * 2.0, r), Vector2(r * 4.0, r * 2.0)), WARNA_TEKS_GELEMBUNG, 0.6)
