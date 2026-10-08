extends Node2D
## Satu petak tanah: bisa diinjak, menampung satu tanaman. Setelah ditanam,
## tanaman tumbuh sendiri (pemain bebas bergerak) lalu matang dan bisa dipanen.
## Gambar tanaman: tunas di paruh pertama tumbuh, lalu muda, lalu matang.

const DataGame := preload("res://scripts/inti/data_game.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Aset := preload("res://scripts/inti/aset.gd")

const WARNA_TANAH := Color("#8d5a3b")
const WARNA_ALUR := Color("#6d4029")
const WARNA_BATANG := Color("#558b2f")
const WARNA_SOROT := Color("#ffeb3b")
const WARNA_PROGRES := Color(1, 1, 1, 0.8)
const JUMLAH_ALUR := 3
## Ukuran buah, sebagai porsi ukuran petak, saat baru ditanam dan saat matang.
const PORSI_BUAH_AWAL := 0.12
const PORSI_BUAH_MATANG := 0.32
## Tanaman digambar sedikit lebih tinggi dari petaknya agar tampak tegak.
const PORSI_NAIK_TANAMAN := 0.18
## Porsi waktu tumbuh sebelum gambar tunas berganti jadi tanaman muda.
const PORSI_TUNAS := 0.5

signal matang

var sel: Vector2i
var status := AturanAksi.TANAH_KOSONG
## Id tanaman yang sedang tumbuh atau matang, atau "".
var tanaman := ""
var disorot := false:
	set(v):
		if v != disorot:
			disorot = v
			queue_redraw()

var _ukuran: float
var _lama_tumbuh := 0.0
var _umur := 0.0
var _tekstur_tanah: Texture2D
## Tekstur tanaman yang sedang ditanam: "tunas", "muda", "matang".
var _tekstur_tanaman := {}


func siapkan(sel_peta: Vector2i, ukuran_petak: float) -> void:
	sel = sel_peta
	_ukuran = ukuran_petak
	name = "Tanah_%d_%d" % [sel.x, sel.y]
	_tekstur_tanah = Aset.tekstur(Aset.tanah())
	queue_redraw()


func tanam(id_tanaman: String) -> void:
	tanaman = id_tanaman
	status = AturanAksi.TANAH_TUMBUH
	_lama_tumbuh = DataGame.durasi("tumbuh")
	_umur = 0.0
	_tekstur_tanaman = {
		"tunas": Aset.tekstur(Aset.tunas()),
		"muda": Aset.tekstur(Aset.tanaman(tanaman, "muda")),
		"matang": Aset.tekstur(Aset.tanaman(tanaman, "matang")),
	}
	queue_redraw()


## Mengosongkan petak dan mengembalikan id tanaman yang dipanen.
func panen() -> String:
	var hasil := tanaman
	tanaman = ""
	status = AturanAksi.TANAH_KOSONG
	queue_redraw()
	return hasil


func _process(delta: float) -> void:
	if status != AturanAksi.TANAH_TUMBUH:
		return
	_umur += delta
	if _umur >= _lama_tumbuh:
		status = AturanAksi.TANAH_MATANG
		matang.emit()
	queue_redraw()


func _draw() -> void:
	var kotak := Rect2(Vector2.ONE * (-_ukuran / 2.0), Vector2.ONE * _ukuran)
	if _tekstur_tanah != null:
		draw_texture_rect(_tekstur_tanah, kotak, false)
	else:
		draw_rect(kotak, WARNA_TANAH)
		for i in JUMLAH_ALUR:
			var y := kotak.position.y + _ukuran * (i + 1) / (JUMLAH_ALUR + 1)
			draw_line(Vector2(kotak.position.x + 4, y), Vector2(kotak.end.x - 4, y), WARNA_ALUR, 2.0)
	var t := 1.0 if status == AturanAksi.TANAH_MATANG else clampf(_umur / maxf(_lama_tumbuh, 0.001), 0.0, 1.0)
	var tahap := "matang" if status == AturanAksi.TANAH_MATANG else ("tunas" if t < PORSI_TUNAS else "muda")
	var gambar: Texture2D = _tekstur_tanaman.get(tahap)
	if status == AturanAksi.TANAH_KOSONG:
		if _tekstur_tanah == null:
			Gambar.huruf_tengah(self, "T", kotak, Color(1, 1, 1, 0.35))
	elif gambar != null:
		draw_texture_rect(gambar, Rect2(kotak.position - Vector2(0, _ukuran * PORSI_NAIK_TANAMAN), kotak.size), false)
		if status == AturanAksi.TANAH_TUMBUH:
			draw_arc(Vector2(0, _ukuran * 0.36), _ukuran * 0.1, -PI / 2.0, -PI / 2.0 + TAU * t, 24, WARNA_PROGRES, 3.0)
	else:
		var radius := _ukuran * lerpf(PORSI_BUAH_AWAL, PORSI_BUAH_MATANG, t)
		draw_line(Vector2(0, _ukuran * 0.4), Vector2(0, 0), WARNA_BATANG, 4.0)
		var warna := DataGame.warna_tanaman(tanaman)
		draw_circle(Vector2.ZERO, radius, warna)
		if status == AturanAksi.TANAH_TUMBUH:
			draw_arc(Vector2.ZERO, _ukuran * 0.42, -PI / 2.0, -PI / 2.0 + TAU * t, 32, WARNA_PROGRES, 3.0)
		else:
			var kotak_huruf := Rect2(Vector2.ONE * -radius, Vector2.ONE * radius * 2.0)
			Gambar.huruf_tengah(self, DataGame.nama_tanaman(tanaman).left(1), kotak_huruf, Gambar.warna_kontras(warna), 0.7)
	if disorot:
		draw_rect(kotak.grow(-2.0), WARNA_SOROT, false, 3.0)
