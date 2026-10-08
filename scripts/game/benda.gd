extends StaticBody2D
## Satu benda di peta (sumber, kosong, wadah, atau alat). Padat: pemain
## berinteraksi dari petak sebelah. Keadaannya diubah oleh interaksi.gd.

const DataGame := preload("res://scripts/inti/data_game.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const Gambar := preload("res://scripts/game/gambar.gd")

## Jarak tepi kotak gambar dari tepi petak, sebagai porsi ukuran petak.
const PORSI_TEPI := 0.1
const PORSI_HURUF_LABEL := 0.45
const WARNA_ABU := Color("#9e9e9e")
const WARNA_SOROT := Color("#ffeb3b")
const WARNA_GELEMBUNG := Color(1, 1, 1, 0.92)
const WARNA_TEKS_GELEMBUNG := Color("#263238")

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
## Nama alat yang ditampilkan di gelembung di atas wadah, atau "".
var ikon_alat := "":
	set(v):
		if v != ikon_alat:
			ikon_alat = v
			# Gelembung menjorok ke petak atas; gambar di atas benda lain.
			z_index = 1 if v != "" else 0
			queue_redraw()

var _ukuran: float


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
	ikon_alat = ""
	queue_redraw()


func _draw() -> void:
	var tepi := _ukuran * PORSI_TEPI
	var kotak := Rect2(Vector2.ONE * (-_ukuran / 2.0 + tepi), Vector2.ONE * (_ukuran - 2.0 * tepi))
	var warna := Color(entri.get("warna", "#ffffff"))
	if status == AturanAksi.STATUS_ABU:
		warna = WARNA_ABU
	if entri.has("label"):
		# Wadah: tulisan besar sebagai petunjuk isinya.
		draw_rect(kotak, warna)
		draw_rect(kotak, warna.darkened(0.35), false, 2.0)
		Gambar.huruf_tengah(self, entri.label, kotak, Gambar.warna_kontras(warna), PORSI_HURUF_LABEL)
	else:
		Gambar.kotak_benda(self, kotak, warna, huruf)
	if disorot:
		draw_rect(kotak.grow(tepi * 0.6), WARNA_SOROT, false, 3.0)
	if ikon_alat != "":
		var gelembung := Rect2(Vector2(-_ukuran * 0.6, -_ukuran * 1.05), Vector2(_ukuran * 1.2, _ukuran * 0.4))
		draw_rect(gelembung, WARNA_GELEMBUNG)
		Gambar.huruf_tengah(self, ikon_alat, gelembung, WARNA_TEKS_GELEMBUNG, 0.6)
