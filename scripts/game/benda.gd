extends StaticBody2D
## Satu benda di peta (sumber, kosong, wadah, atau alat). Padat: pemain
## berinteraksi dari petak sebelah. Status interaksi ditambahkan di fase 5.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Gambar := preload("res://scripts/game/gambar.gd")

## Jarak tepi kotak gambar dari tepi petak, sebagai porsi ukuran petak.
const PORSI_TEPI := 0.1

var id: String
var huruf: String
var entri: Dictionary
var sel: Vector2i
var _ukuran: float


func siapkan(id_benda: String, huruf_peta: String, sel_peta: Vector2i, ukuran_petak: float) -> void:
	id = id_benda
	huruf = huruf_peta
	sel = sel_peta
	entri = DataGame.entri_benda(id)
	_ukuran = ukuran_petak
	name = "Benda_%s_%d_%d" % [huruf, sel.x, sel.y]
	var bentuk := CollisionShape2D.new()
	var kotak := RectangleShape2D.new()
	kotak.size = Vector2.ONE * _ukuran
	bentuk.shape = kotak
	add_child(bentuk)
	queue_redraw()


func _draw() -> void:
	var tepi := _ukuran * PORSI_TEPI
	var kotak := Rect2(Vector2.ONE * (-_ukuran / 2.0 + tepi), Vector2.ONE * (_ukuran - 2.0 * tepi))
	Gambar.kotak_benda(self, kotak, Color(entri.get("warna", "#ffffff")), huruf)
