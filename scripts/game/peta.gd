extends Node2D
## Membangun peta dari data stage: menggambar lantai, dinding, dan penghalang;
## membuat tabrakan untuk petak padat; menaruh benda, petak tanah, dan pembeli.
## Latar (lantai, dinding dengan sisi muka, tanah) digambar node ini; benda,
## tanaman, pembeli, dan blok penghalang adalah anak yang di-y-sort bersama
## pemain (tampilan 3/4). Penghalang bersambung (huruf sama) jadi satu blok.
## Tanpa aset: warna polos.

const DataGame := preload("res://scripts/inti/data_game.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Benda := preload("res://scripts/game/benda.gd")
const PetakTanah := preload("res://scripts/game/petak_tanah.gd")
const Pembeli := preload("res://scripts/game/pembeli.gd")
const BlokPenghalang := preload("res://scripts/game/blok_penghalang.gd")
const Aset := preload("res://scripts/inti/aset.gd")

const WARNA_LANTAI := Color("#efe6d2")
const WARNA_GARIS_LANTAI := Color(0, 0, 0, 0.06)
const WARNA_DINDING := Color("#5b5b66")
const PORSI_TEPI_PENGHALANG := 0.04
const ARAH_TETANGGA := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
## Jarak tepi gelembung pesanan dari tepi baris petaknya.
const PORSI_TEPI_GELEMBUNG := 0.08
## Piksel tekstur per petak (SVG viewBox 128 per petak, diekspor 2x).
const PIKSEL_PER_PETAK := 256.0

var ukuran: float
var lebar: int
var tinggi: int
var posisi_awal := Vector2.ZERO
var daftar_benda: Array[Benda] = []
var daftar_tanah: Array[PetakTanah] = []
var daftar_pembeli: Array[Pembeli] = []

var _peta: Array
var _legenda: Dictionary
var _tekstur_lantai: Texture2D
var _tekstur_dinding: Texture2D
var _tekstur_dinding_muka: Texture2D
var _tekstur_tanah: Texture2D
## Tempelan lantai: Array berisi {"tekstur", "kotak" (dunia)}.
var _tempelan: Array[Dictionary] = []
## Blok penghalang: Array berisi {"simbol", "kotak" (dunia), "tekstur", "sel"}.
var _blok_penghalang: Array[Dictionary] = []


func bangun(data_stage: Dictionary, ukuran_petak: float, pesanan: RefCounted) -> void:
	ukuran = ukuran_petak
	_peta = data_stage.peta
	_legenda = data_stage.legenda
	tinggi = _peta.size()
	lebar = _peta[0].length()
	var tema: String = data_stage.get("tema", "")
	_tekstur_lantai = Aset.tekstur(Aset.petak(tema, "lantai"))
	_tekstur_dinding = Aset.tekstur(Aset.petak(tema, "dinding"))
	_tekstur_dinding_muka = Aset.tekstur(Aset.petak(tema, "dinding_muka"))
	_tekstur_tanah = Aset.tekstur(Aset.tanah())
	_sebar_tempelan(data_stage)
	_kumpulkan_blok_penghalang()
	for blok in _blok_penghalang:
		var node := BlokPenghalang.new()
		var entri := DataGame.entri_benda(_legenda.get(blok.simbol, ""))
		node.siapkan(blok.kotak, blok.tekstur, ukuran, blok.sel, Color(entri.get("warna", "#000000")), blok.simbol)
		add_child(node)

	var padat := StaticBody2D.new()
	padat.name = "PetakPadat"
	add_child(padat)

	for y in tinggi:
		for x in lebar:
			var sel := Vector2i(x, y)
			var simbol: String = _peta[y][x]
			match simbol:
				PemuatData.SIMBOL_LANTAI:
					pass
				PemuatData.SIMBOL_PEMAIN:
					posisi_awal = pusat_petak(sel)
				PemuatData.SIMBOL_TANAH:
					var tanah := PetakTanah.new()
					tanah.position = pusat_petak(sel)
					tanah.siapkan(sel, ukuran)
					add_child(tanah)
					daftar_tanah.append(tanah)
				PemuatData.SIMBOL_PEMBELI:
					_tambah_tabrakan(padat, sel)
					var pembeli := Pembeli.new()
					pembeli.position = pusat_petak(sel)
					add_child(pembeli)
					# Hanya pembeli pertama yang memegang gelembung pesanan.
					var gelembung := _kotak_gelembung(sel) if daftar_pembeli.is_empty() else Rect2()
					pembeli.siapkan(data_stage.pesanan.pembeli, pesanan, ukuran, gelembung)
					daftar_pembeli.append(pembeli)
				PemuatData.SIMBOL_DINDING:
					_tambah_tabrakan(padat, sel)
				_:
					if _adalah_penghalang(simbol):
						_tambah_tabrakan(padat, sel)
					else:
						var benda := Benda.new()
						benda.position = pusat_petak(sel)
						benda.siapkan(_legenda[simbol], simbol, sel, ukuran)
						add_child(benda)
						daftar_benda.append(benda)
	queue_redraw()


## Menghapus benda dari peta (misalnya sumber yang sudah jadi benih).
func hapus_benda(benda: Benda) -> void:
	daftar_benda.erase(benda)
	benda.queue_free()


## True jika petak ini lantai, posisi awal, atau tanah menurut data peta.
func bisa_diinjak(sel: Vector2i) -> bool:
	if sel.x < 0 or sel.y < 0 or sel.x >= lebar or sel.y >= tinggi:
		return false
	return _peta[sel.y][sel.x] in PemuatData.SIMBOL_BISA_DIINJAK


func pusat_petak(sel: Vector2i) -> Vector2:
	return (Vector2(sel) + Vector2(0.5, 0.5)) * ukuran


func sel_dari_posisi(posisi: Vector2) -> Vector2i:
	return Vector2i((posisi / ukuran).floor())


func ukuran_dunia() -> Vector2:
	return Vector2(lebar, tinggi) * ukuran


## Gelembung pesanan menempati baris di atas pembeli (atau barisnya sendiri
## jika pembeli ada di baris teratas), memanjang ke kanan sampai tepi peta.
## Dengan tepi peta berupa dinding, gelembung tidak menutupi area main.
## Mengembalikan kotak dalam koordinat lokal pembeli.
func _kotak_gelembung(sel_pembeli: Vector2i) -> Rect2:
	var baris := sel_pembeli.y - 1 if sel_pembeli.y > 0 else sel_pembeli.y
	var x_awal := sel_pembeli.x if sel_pembeli.y > 0 else sel_pembeli.x + 1
	var kotak := Rect2(Vector2(x_awal, baris) * ukuran, Vector2(lebar - x_awal, 1) * ukuran)
	kotak = kotak.grow(-ukuran * PORSI_TEPI_GELEMBUNG)
	kotak.position -= pusat_petak(sel_pembeli)
	return kotak


## Huruf legenda yang tidak dikenal katalog juga dianggap padat, supaya
## pemain tidak berjalan menembus sesuatu yang tergambar.
func _adalah_penghalang(simbol: String) -> bool:
	var entri := DataGame.entri_benda(_legenda.get(simbol, ""))
	return entri.is_empty() or PemuatData.jenis_benda(entri) == PemuatData.JENIS_PENGHALANG


## Menyebar tempelan lantai (bunga, batu pijakan, daun...) dari daftar tema
## ke petak lantai kosong. Acak tapi tetap: benih acak dari id stage, jadi
## tampilan stage selalu sama setiap dimainkan.
func _sebar_tempelan(data_stage: Dictionary) -> void:
	_tempelan.clear()
	var daftar: Array = DataGame.tema.get(data_stage.get("tema", ""), {}).get("tempelan", [])
	var tekstur: Array[Texture2D] = []
	for nama in daftar:
		var t := Aset.tekstur(Aset.tempelan(nama))
		if t != null:
			tekstur.append(t)
	if tekstur.is_empty():
		return
	var acak := RandomNumberGenerator.new()
	acak.seed = hash(str(data_stage.get("id", "")))
	var peluang: float = DataGame.pengaturan.peluang_tempelan_lantai
	for y in tinggi:
		for x in lebar:
			var simbol: String = _peta[y][x]
			if simbol != PemuatData.SIMBOL_LANTAI and simbol != PemuatData.SIMBOL_PEMAIN:
				continue
			if acak.randf() > peluang:
				continue
			var t: Texture2D = tekstur[acak.randi() % tekstur.size()]
			var sisi := ukuran * acak.randf_range(0.55, 0.85)
			var geser := Vector2(acak.randf_range(-0.2, 0.2), acak.randf_range(-0.2, 0.2)) * ukuran
			_tempelan.append({"tekstur": t, "kotak": Rect2(pusat_petak(Vector2i(x, y)) + geser - Vector2.ONE * sisi / 2.0, Vector2.ONE * sisi)})


## Mengelompokkan petak penghalang bersambung (4 arah, huruf sama) menjadi
## blok persegi panjang, supaya rumah 2x4 tergambar sebagai satu atap.
func _kumpulkan_blok_penghalang() -> void:
	_blok_penghalang.clear()
	var sudah := {}
	for y in tinggi:
		for x in lebar:
			var simbol: String = _peta[y][x]
			if sudah.has(Vector2i(x, y)) or simbol in PemuatData.SIMBOL_UMUM or not _adalah_penghalang(simbol):
				continue
			var batas := Rect2i(x, y, 1, 1)
			var sel_blok: Array[Vector2i] = []
			var antrean: Array[Vector2i] = [Vector2i(x, y)]
			sudah[Vector2i(x, y)] = true
			while not antrean.is_empty():
				var sel: Vector2i = antrean.pop_front()
				sel_blok.append(sel)
				batas = batas.expand(sel).expand(sel + Vector2i.ONE)
				for arah in ARAH_TETANGGA:
					var n: Vector2i = sel + arah
					if not sudah.has(n) and n.x >= 0 and n.y >= 0 and n.x < lebar and n.y < tinggi and _peta[n.y][n.x] == simbol:
						sudah[n] = true
						antrean.append(n)
			var id: String = _legenda.get(simbol, "")
			_blok_penghalang.append({
				"simbol": simbol,
				"kotak": Rect2(Vector2(batas.position) * ukuran, Vector2(batas.size) * ukuran),
				"tekstur": Aset.tekstur(Aset.benda(id, DataGame.entri_benda(id))) if id != "" else null,
				"sel": sel_blok,
			})


func _tambah_tabrakan(badan: StaticBody2D, sel: Vector2i) -> void:
	var bentuk := CollisionShape2D.new()
	var kotak := RectangleShape2D.new()
	kotak.size = Vector2.ONE * ukuran
	bentuk.shape = kotak
	bentuk.position = pusat_petak(sel)
	badan.add_child(bentuk)


func _draw() -> void:
	# Lantai: tekstur mulus dipasang per potongan selebar teksturnya (mis. 2x2
	# petak), sehingga tidak tampak garis petak.
	if _tekstur_lantai != null:
		var rentang := maxi(1, roundi(_tekstur_lantai.get_size().x / PIKSEL_PER_PETAK))
		for y in range(0, tinggi, rentang):
			for x in range(0, lebar, rentang):
				draw_texture_rect(_tekstur_lantai, Rect2(Vector2(x, y) * ukuran, Vector2.ONE * rentang * ukuran), false)
	else:
		for y in tinggi:
			for x in lebar:
				var kotak := Rect2(Vector2(x, y) * ukuran, Vector2.ONE * ukuran)
				draw_rect(kotak, WARNA_LANTAI)
				draw_rect(kotak, WARNA_GARIS_LANTAI, false, 1.0)
	for t in _tempelan:
		draw_texture_rect(t.tekstur, t.kotak, false)
	for y in tinggi:
		for x in lebar:
			var kotak := Rect2(Vector2(x, y) * ukuran, Vector2.ONE * ukuran)
			match _peta[y][x]:
				PemuatData.SIMBOL_DINDING:
					# Dinding yang di bawahnya bukan dinding menampakkan sisi muka (3/4).
					var ada_muka: bool = y + 1 < tinggi and _peta[y + 1][x] != PemuatData.SIMBOL_DINDING
					var tekstur: Texture2D = _tekstur_dinding_muka if ada_muka and _tekstur_dinding_muka != null else _tekstur_dinding
					if tekstur != null:
						draw_texture_rect(tekstur, kotak, false)
					else:
						draw_rect(kotak, WARNA_DINDING)
				PemuatData.SIMBOL_TANAH:
					if _tekstur_tanah != null:
						draw_texture_rect(_tekstur_tanah, kotak, false)
