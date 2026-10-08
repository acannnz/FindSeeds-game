extends "res://tools/dasar_uji.gd"
## Uji mandiri pemeriksa stage: data asli harus lolos, dan setiap kerusakan
## yang disengaja harus memicu tepat pengecekan yang diharapkan.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji
## atau:
##   godot --headless --path . --script res://tools/uji_pemeriksa.gd

const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const Pemeriksa := preload("res://scripts/inti/pemeriksa.gd")

var _asli: Dictionary


func _initialize() -> void:
	_asli = PemuatData.muat_semua()
	if not _asli.galat.is_empty():
		print("GAGAL: data asli tidak bisa dibaca: %s" % "; ".join(_asli.galat))
		quit(1)
		return

	_uji("Data asli lolos semua pengecekan", [], func(_d): pass)

	_uji("Cek 0: peta tanpa @", [Pemeriksa.CEK_FORMAT], func(d):
		_ganti_sel(_stage(d, "1-1"), Vector2i(1, 10), "."))

	_uji("Cek 1: pesanan 2 tomat di stage yang hanya punya 1 sumber", [Pemeriksa.CEK_SUMBER_CUKUP], func(d):
		_stage(d, "1-1").pesanan.isi.tomat = 2)

	_uji("Cek 2: gunting dihapus dari stage 1-3", [Pemeriksa.CEK_ALAT_ADA], func(d):
		_ganti_sel(_stage(d, "1-3"), Vector2i(6, 1), "."))

	_uji("Cek 3: huruf 'Z' tanpa legenda di stage 1-1", [Pemeriksa.CEK_HURUF_DIKENAL], func(d):
		_ganti_sel(_stage(d, "1-1"), Vector2i(2, 2), "Z"))

	_uji("Cek 4: dinding memotong peta stage 1-1", [Pemeriksa.CEK_BISA_DICAPAI], func(d):
		_stage(d, "1-1").peta[6] = "########")

	_uji("Cek 5: bola karet merah dipakai lagi di stage 1-2", [Pemeriksa.CEK_JEDA_BENDA], func(d):
		_stage(d, "1-2").legenda.K = "bola_karet_merah")

	_uji("Hiasan boleh dipakai lagi di stage berikutnya (bebas jeda 4 stage)", [], func(d):
		var s := _stage(d, "1-2")
		_ganti_sel(s, Vector2i(6, 2), "k")
		s.legenda.k = "kursi_taman")

	_uji("Cek 6: logika musim Panas dipakai di Musim Semi", [Pemeriksa.CEK_LOGIKA_MUSIM], func(d):
		d.katalog.bola_karet_merah.logika = "asosiasi")

	_selesai("uji pemeriksa")


## Menyalin data asli, merusaknya lewat `ubah`, lalu memastikan cek yang
## muncul persis sama dengan `cek_diharapkan`.
func _uji(judul: String, cek_diharapkan: Array, ubah: Callable) -> void:
	var d: Dictionary = _asli.duplicate(true)
	ubah.call(d)
	var temuan := Pemeriksa.new().periksa(d)
	var cek_muncul := {}
	for t in temuan:
		cek_muncul[t.cek] = true
	var muncul: Array = cek_muncul.keys()
	muncul.sort()
	if muncul == cek_diharapkan:
		print("[LOLOS] %s" % judul)
		for t in temuan:
			print("          -> %s: %s" % [t.file, t.pesan])
	else:
		_gagal += 1
		print("[GAGAL] %s: diharapkan cek %s, muncul cek %s" % [judul, cek_diharapkan, muncul])
		for t in temuan:
			print("          -> %s (cek %d): %s" % [t.file, t.cek, t.pesan])


func _stage(d: Dictionary, id: String) -> Dictionary:
	for s in d.stage:
		if s.data.id == id:
			return s.data
	push_error("Stage %s tidak ditemukan" % id)
	return {}


func _ganti_sel(stage: Dictionary, sel: Vector2i, huruf: String) -> void:
	var baris: String = stage.peta[sel.y]
	stage.peta[sel.y] = baris.substr(0, sel.x) + huruf + baris.substr(sel.x + 1)
