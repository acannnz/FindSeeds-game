extends "res://tools/dasar_uji.gd"
## Uji main penuh: bot memainkan Stage 1-1, 1-2, dan 1-3 mengikuti "solusi
## tercepat" di dokumen rancangan. Bot berjalan sungguhan (rute BFS dari data
## peta, tanpa posisi tertulis), menekan tombol aksi, lalu mengukur waktunya.
## Saat mendekati benda, bot memilih sisi yang total jaraknya (ke benda ini
## lalu ke langkah berikutnya) paling pendek, seperti pemain yang berpikir
## satu langkah ke depan. Bot berjalan per petak (tidak diagonal), jadi
## waktunya sedikit di atas perkiraan dokumen yang memakai gerak bebas.
## Memastikan stage selesai otomatis dan solusi tercepat cukup untuk 3 bintang.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-main

const ADEGAN_STAGE := preload("res://scenes/stage.tscn")
const DataGame := preload("res://scripts/inti/data_game.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const Bintang := preload("res://scripts/inti/bintang.gd")
const FPS := 60
const ARAH := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
## Jarak ke titik rute yang dianggap sudah lewat / sampai (porsi petak).
const LEWAT_PETAK := 0.3
const SAMPAI_PETAK := 0.08
## Lama mendorong ke arah benda setelah sampai, agar benda itu yang terdekat.
const DETIK_DORONG := 0.15
const BATAS_DETIK_LANGKAH := 15.0

## Langkah solusi tercepat per stage, sesuai dokumen. [aksi, id benda].
const SOLUSI := {
	"1-1": [["identifikasi", "bola_karet_merah"], ["tanam"], ["panen"]],
	"1-2": [["identifikasi", "jam_weker_merah"], ["identifikasi", "kerucut_lalu_lintas"],
		["tanam"], ["tanam"], ["panen"], ["panen"]],
	"1-3": [["identifikasi", "spons_kuning"], ["tanam"], ["identifikasi", "lampion_merah"],
		["ambil", "gunting"], ["potong", "kardus_mainan"], ["identifikasi", "hidung_badut"],
		["panen"], ["tanam"], ["tanam"], ["panen"], ["panen"]],
}
## Perkiraan waktu solusi tercepat menurut dokumen, hanya untuk laporan.
const PERKIRAAN_DOKUMEN := {"1-1": 9.0, "1-2": 13.0, "1-3": 22.0}

var _stage: Node
var _u: float


func _initialize() -> void:
	_jalankan()


func _jalankan() -> void:
	await process_frame
	if not DataGame.galat.is_empty():
		print("GAGAL: data stage bermasalah, jalankan tools\\periksa.bat.")
		quit(1)
		return
	for id in SOLUSI:
		await _mainkan(id)
	_selesai("uji main")


func _mainkan(id: String) -> void:
	var data := DataGame.stage_dengan_id(id)
	if _stage:
		_stage.free()
	_stage = ADEGAN_STAGE.instantiate()
	_stage.data = data
	root.add_child(_stage)
	await process_frame
	_u = _stage.UKURAN_PETAK
	var frame_awal := Engine.get_process_frames()

	var langkah_ke := 0
	for langkah in SOLUSI[id]:
		langkah_ke += 1
		var berikutnya: Array = SOLUSI[id][langkah_ke] if langkah_ke < SOLUSI[id].size() else []
		var berhasil: bool = await _jalankan_langkah(langkah, berikutnya)
		if not berhasil:
			_cek("Stage %s: langkah %d %s" % [id, langkah_ke, str(langkah)], false, _rincian_aksi())
			return
		if _stage.sudah_selesai and langkah_ke < SOLUSI[id].size():
			_cek("Stage %s tidak selesai sebelum langkah terakhir" % id, false, "selesai di langkah %d" % langkah_ke)
			return

	var detik := float(Engine.get_process_frames() - frame_awal) / FPS
	var batas_tiga: float = data.waktu_detik - data.bintang_sisa_detik.tiga
	_cek("Stage %s selesai otomatis setelah panen terakhir" % id, _stage.sudah_selesai)
	_cek("Stage %s: solusi tercepat %.1f dtk (dokumen ~%.0f dtk) cukup untuk 3 bintang (≤ %.0f dtk)" % [id, detik, PERKIRAAN_DOKUMEN[id], batas_tiga],
		detik <= batas_tiga)
	_cek("Stage %s: pesanan terisi lengkap" % id, _stage.pesanan.lengkap())
	var bintang := Bintang.hitung(_stage.sisa_detik, data.bintang_sisa_detik)
	_cek("Stage %s: timer stage mencatat sisa %.1f dtk = 3 bintang" % [id, _stage.sisa_detik], bintang == 3)


func _jalankan_langkah(langkah: Array, berikutnya: Array) -> bool:
	var aksi: String = langkah[0]
	var target: Node2D
	if aksi == AturanAksi.AKSI_TANAM or aksi == AturanAksi.AKSI_PANEN:
		target = await _ke_tanah(aksi)
	else:
		target = await _ke_benda(langkah[1], berikutnya)
	if target == null:
		return false
	var a: Dictionary = _stage.interaksi.aksi_kini
	if a.get("target") != target or a.get("aksi", "") != aksi or not a.get("aktif", false):
		return false
	_stage.interaksi.tekan_aksi()
	var batas := int(BATAS_DETIK_LANGKAH * FPS)
	while _stage.interaksi.sibuk() and batas > 0:
		batas -= 1
		await process_frame
	await process_frame
	return batas > 0


func _ke_benda(id: String, berikutnya: Array) -> Node2D:
	var benda := _cari_benda(id)
	if benda == null:
		return null
	# Pilih sisi benda dengan jarak (ke sini + ke langkah berikutnya) terpendek.
	var terbaik: Array[Vector2i] = []
	var jarak_terbaik := INF
	for sel in _sel_sebelah(benda):
		var jalur := _cari_jalur(_sel_pemain(), [sel])
		if jalur.is_empty():
			continue
		var jarak := jalur.size() + _jarak_ke_langkah(sel, berikutnya)
		if jarak < jarak_terbaik:
			jarak_terbaik = jarak
			terbaik = [sel]
	if terbaik.is_empty() or not await _jalan_ke(terbaik):
		return null
	# Dorong sedikit ke arah benda supaya benda ini yang paling dekat.
	_stage.pemain.arah_paksa = (benda.position - _stage.pemain.position).normalized()
	await _tunggu(DETIK_DORONG)
	_stage.pemain.arah_paksa = Vector2.ZERO
	await _tunggu(2.0 / FPS)
	return benda


func _cari_benda(id: String) -> Node2D:
	for b in _stage.peta.daftar_benda:
		if b.id == id:
			return b
	return null


func _sel_sebelah(benda: Node2D) -> Array[Vector2i]:
	var hasil: Array[Vector2i] = []
	for arah in ARAH:
		if _stage.peta.bisa_diinjak(benda.sel + arah):
			hasil.append(benda.sel + arah)
	return hasil


## Jarak BFS (petak) dari sel ke tempat langkah berikutnya dikerjakan.
## 0 jika tidak ada langkah berikutnya atau bendanya belum muncul (isi wadah).
func _jarak_ke_langkah(dari: Vector2i, langkah: Array) -> int:
	if langkah.is_empty():
		return 0
	var tujuan: Array[Vector2i] = []
	if langkah[0] == AturanAksi.AKSI_TANAM or langkah[0] == AturanAksi.AKSI_PANEN:
		for t in _stage.peta.daftar_tanah:
			tujuan.append(t.sel)
	else:
		var benda := _cari_benda(langkah[1])
		if benda == null:
			return 0
		tujuan = _sel_sebelah(benda)
	var jalur := _cari_jalur(dari, tujuan)
	return jalur.size() - 1 if not jalur.is_empty() else 0


## Tanam: petak kosong terdekat. Panen: petak matang, atau tunggu yang tumbuh.
func _ke_tanah(aksi: String) -> Node2D:
	var calon: Array[Vector2i] = []
	var pilihan: Node2D = null
	for status in ([AturanAksi.TANAH_KOSONG] if aksi == AturanAksi.AKSI_TANAM else [AturanAksi.TANAH_MATANG, AturanAksi.TANAH_TUMBUH]):
		for t in _stage.peta.daftar_tanah:
			if t.status == status:
				calon.append(t.sel)
		if not calon.is_empty():
			break
	if calon.is_empty():
		return null
	var jalur := _cari_jalur(_sel_pemain(), calon)
	if jalur.is_empty():
		return null
	for t in _stage.peta.daftar_tanah:
		if t.sel == jalur[-1]:
			pilihan = t
	if not await _ikuti(jalur):
		return null
	var batas := int(BATAS_DETIK_LANGKAH * FPS)
	while aksi == AturanAksi.AKSI_PANEN and pilihan.status != AturanAksi.TANAH_MATANG and batas > 0:
		batas -= 1
		await process_frame
	await _tunggu(2.0 / FPS)
	return pilihan


func _jalan_ke(tujuan: Array[Vector2i]) -> bool:
	var jalur := _cari_jalur(_sel_pemain(), tujuan)
	return not jalur.is_empty() and await _ikuti(jalur)


## BFS 4 arah lewat petak yang bisa diinjak. Mengembalikan jalur termasuk awal.
func _cari_jalur(awal: Vector2i, tujuan: Array[Vector2i]) -> Array[Vector2i]:
	var asal := {awal: awal}
	var antrean: Array[Vector2i] = [awal]
	while not antrean.is_empty():
		var sel: Vector2i = antrean.pop_front()
		if sel in tujuan:
			var jalur: Array[Vector2i] = [sel]
			while jalur[0] != awal:
				jalur.push_front(asal[jalur[0]])
			return jalur
		for arah in ARAH:
			var n: Vector2i = sel + arah
			if not asal.has(n) and _stage.peta.bisa_diinjak(n):
				asal[n] = sel
				antrean.append(n)
	return []


func _ikuti(jalur: Array[Vector2i]) -> bool:
	var pemain: CharacterBody2D = _stage.pemain
	var batas := int(BATAS_DETIK_LANGKAH * FPS)
	for i in range(1, jalur.size()):
		var titik: Vector2 = _stage.peta.pusat_petak(jalur[i])
		var ambang := (SAMPAI_PETAK if i == jalur.size() - 1 else LEWAT_PETAK) * _u
		while pemain.position.distance_to(titik) > ambang:
			if batas <= 0:
				pemain.arah_paksa = Vector2.ZERO
				return false
			batas -= 1
			pemain.arah_paksa = (titik - pemain.position).normalized()
			await physics_frame
	pemain.arah_paksa = Vector2.ZERO
	return true


func _sel_pemain() -> Vector2i:
	return _stage.peta.sel_dari_posisi(_stage.pemain.position)


func _rincian_aksi() -> String:
	var a: Dictionary = _stage.interaksi.aksi_kini
	var t = a.get("target")
	return "aksi ditawarkan='%s' aktif=%s target=%s" % [a.get("aksi", ""), a.get("aktif", false), t.name if is_instance_valid(t) else "-"]


func _tunggu(detik: float) -> void:
	for i in ceili(detik * FPS):
		await process_frame
