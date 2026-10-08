extends Node2D
## Membangun peta dari data stage: menggambar lantai, dinding, dan penghalang;
## membuat tabrakan untuk petak padat; menaruh benda, petak tanah, dan pembeli.

const DataGame := preload("res://scripts/inti/data_game.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const Gambar := preload("res://scripts/game/gambar.gd")
const Benda := preload("res://scripts/game/benda.gd")
const PetakTanah := preload("res://scripts/game/petak_tanah.gd")
const Pembeli := preload("res://scripts/game/pembeli.gd")

const WARNA_LANTAI := Color("#efe6d2")
const WARNA_GARIS_LANTAI := Color(0, 0, 0, 0.06)
const WARNA_DINDING := Color("#5b5b66")
const PORSI_TEPI_PENGHALANG := 0.04
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


func bangun(data_stage: Dictionary, ukuran_petak: float, pesanan: RefCounted) -> void:
	ukuran = ukuran_petak
	_peta = data_stage.peta
	_legenda = data_stage.legenda
	tinggi = _peta.size()
	lebar = _peta[0].length()

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
			var simbol: String = _peta[y][x]
			var kotak := Rect2(Vector2(x, y) * ukuran, Vector2.ONE * ukuran)
			if simbol == PemuatData.SIMBOL_DINDING:
				draw_rect(kotak, WARNA_DINDING)
				continue
			draw_rect(kotak, WARNA_LANTAI)
			draw_rect(kotak, WARNA_GARIS_LANTAI, false, 1.0)
			if not simbol in PemuatData.SIMBOL_UMUM and _adalah_penghalang(simbol):
				var entri := DataGame.entri_benda(_legenda.get(simbol, ""))
				Gambar.kotak_benda(self, kotak.grow(-ukuran * PORSI_TEPI_PENGHALANG), Color(entri.get("warna", "#000000")), simbol)
