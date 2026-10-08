extends Node2D
## Membangun peta dari data stage: menggambar lantai, dinding, dan penghalang;
## membuat tabrakan untuk petak padat; menaruh benda, petak tanah, dan pembeli.
## Lantai dan dinding memakai aset tema stage; penghalang yang bersambung
## (huruf sama) digambar sebagai satu blok. Tanpa aset: warna polos.

const DataGame := preload("res://scripts/inti/data_game.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Benda := preload("res://scripts/game/benda.gd")
const PetakTanah := preload("res://scripts/game/petak_tanah.gd")
const Pembeli := preload("res://scripts/game/pembeli.gd")
const Aset := preload("res://scripts/inti/aset.gd")

const WARNA_LANTAI := Color("#efe6d2")
const WARNA_GARIS_LANTAI := Color(0, 0, 0, 0.06)
const WARNA_DINDING := Color("#5b5b66")
const PORSI_TEPI_PENGHALANG := 0.04
const ARAH_TETANGGA := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
## Jarak tepi gelembung pesanan dari tepi baris petaknya.
const PORSI_TEPI_GELEMBUNG := 0.08

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
## Blok penghalang: Array berisi {"simbol", "kotak" (dunia), "tekstur"}.
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
	_kumpulkan_blok_penghalang()

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
			var antrean: Array[Vector2i] = [Vector2i(x, y)]
			sudah[Vector2i(x, y)] = true
			while not antrean.is_empty():
				var sel: Vector2i = antrean.pop_front()
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
			})


func _tambah_tabrakan(badan: StaticBody2D, sel: Vector2i) -> void:
	var bentuk := CollisionShape2D.new()
	var kotak := RectangleShape2D.new()
	kotak.size = Vector2.ONE * ukuran
	bentuk.shape = kotak
	bentuk.position = pusat_petak(sel)
	badan.add_child(bentuk)


func _draw() -> void:
	for y in tinggi:
		for x in lebar:
			var kotak := Rect2(Vector2(x, y) * ukuran, Vector2.ONE * ukuran)
			if _peta[y][x] == PemuatData.SIMBOL_DINDING:
				if _tekstur_dinding != null:
					draw_texture_rect(_tekstur_dinding, kotak, false)
				else:
					draw_rect(kotak, WARNA_DINDING)
			elif _tekstur_lantai != null:
				draw_texture_rect(_tekstur_lantai, kotak, false)
			else:
				draw_rect(kotak, WARNA_LANTAI)
				draw_rect(kotak, WARNA_GARIS_LANTAI, false, 1.0)
	for blok in _blok_penghalang:
		if blok.tekstur != null:
			draw_texture_rect(blok.tekstur, blok.kotak.grow(-ukuran * PORSI_TEPI_PENGHALANG), false)
			continue
		# Tanpa aset: kotak warna per petak seperti placeholder lama.
		var entri := DataGame.entri_benda(_legenda.get(blok.simbol, ""))
		var b: Rect2 = blok.kotak
		for y in range(int(b.position.y / ukuran), int(b.end.y / ukuran)):
			for x in range(int(b.position.x / ukuran), int(b.end.x / ukuran)):
				if _peta[y][x] == blok.simbol:
					var kotak := Rect2(Vector2(x, y) * ukuran, Vector2.ONE * ukuran)
					Gambar.kotak_benda(self, kotak.grow(-ukuran * PORSI_TEPI_PENGHALANG), Color(entri.get("warna", "#000000")), blok.simbol)
