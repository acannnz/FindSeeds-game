extends "res://tools/dasar_uji.gd"
## Uji interaksi pada stage sungguhan: memindahkan pemain ke sebelah benda,
## menekan tombol aksi, menunggu durasinya, lalu memeriksa hasilnya.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-interaksi

const ADEGAN_STAGE := preload("res://scenes/stage.tscn")
const DataGame := preload("res://scripts/inti/data_game.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const FPS := 60
## Frame tambahan setelah durasi aksi, untuk pembulatan waktu.
const FRAME_LEBIH := 3

var _stage: Node
var _interaksi: Node
var _pemain: CharacterBody2D
var _peta: Node2D


func _initialize() -> void:
	_jalankan()


func _jalankan() -> void:
	# Pohon adegan baru siap setelah _initialize; tunggu satu frame.
	await process_frame
	if not DataGame.galat.is_empty():
		print("GAGAL: data stage bermasalah, jalankan tools\\periksa.bat.")
		quit(1)
		return
	await _uji_stage_1_3()
	await _uji_tukar_alat()
	await _uji_panen_pengecoh()
	_selesai("uji interaksi")


func _uji_stage_1_3() -> void:
	await _muat(DataGame.stage_dengan_id("1-3"))
	var durasi_identifikasi := DataGame.durasi("identifikasi")

	# Benda kosong: reaksi lalu abu-abu, pemain terkunci selama identifikasi.
	await _berdiri_di(Vector2i(2, 9))
	_cek_aksi("Dekat kotak pos: Identifikasi aktif", "kotak_pos", "identifikasi", true)
	var posisi_awal := _pemain.position
	_interaksi.tekan_aksi()
	_pemain.arah_paksa = Vector2.RIGHT
	await _tunggu(durasi_identifikasi - 0.1)
	_cek("Selama identifikasi pemain tidak bergerak", _pemain.position.is_equal_approx(posisi_awal))
	_cek("Identifikasi belum selesai sebelum %.1f detik" % durasi_identifikasi, _interaksi.sibuk())
	_pemain.arah_paksa = Vector2.ZERO
	await _tunggu(0.1 + float(FRAME_LEBIH) / FPS)
	var kotak_pos := _benda_di(Vector2i(2, 10))
	_cek("Kotak pos jadi abu-abu dan kantong tetap kosong", kotak_pos.status == AturanAksi.STATUS_ABU and _interaksi.kantong.kosong())
	_cek("Benda abu-abu tidak menawarkan aksi lagi", _interaksi.aksi_kini.is_empty())

	# Wadah tanpa alat: tombol terkunci dan ikon alat muncul.
	await _berdiri_di(Vector2i(4, 9))
	_cek_aksi("Kardus MAINAN tanpa gunting: Potong terkunci", "kardus_mainan", "potong", false)
	_cek("Ikon gunting muncul di atas kardus", _benda_di(Vector2i(4, 10)).ikon_alat == DataGame.nama_benda("gunting"))
	_interaksi.tekan_aksi()
	await _tunggu(0.1)
	_cek("Menekan tombol terkunci tidak memotong waktu", not _interaksi.sibuk())

	# Sumber: berubah jadi benih dan hilang dari peta.
	await _berdiri_di(Vector2i(5, 9))
	await _jalankan_aksi("spons_kuning", "identifikasi")
	_cek("Spons kuning jadi benih jagung", _kantong_berisi(["jagung"]))
	_cek("Spons kuning hilang dari peta", _benda_di(Vector2i(6, 9)) == null)

	# Alat: diambil ke tangan.
	await _berdiri_di(Vector2i(6, 2))
	await _jalankan_aksi("gunting", "ambil")
	_cek("Gunting dipegang dan hilang dari peta", _interaksi.alat_di_tangan == "gunting" and _benda_di(Vector2i(6, 1)) == null)

	await _berdiri_di(Vector2i(4, 2))
	await _jalankan_aksi("lampion_merah", "identifikasi")
	await _berdiri_di(Vector2i(1, 2))
	await _jalankan_aksi("bantalan_jarum", "identifikasi")
	_cek("Pengecoh tetap jadi benih (stroberi), kantong penuh",
		_kantong_berisi(["jagung", "tomat", "stroberi"]) and _interaksi.kantong.penuh())

	# Wadah dengan alat: isinya tertinggal di tempat.
	await _berdiri_di(Vector2i(4, 9))
	_cek("Ikon gunting hilang saat gunting dipegang", _benda_di(Vector2i(4, 10)).ikon_alat == "")
	await _jalankan_aksi("kardus_mainan", "potong")
	_cek("Kardus MAINAN terbuka, isinya hidung badut", _benda_di(Vector2i(4, 10)).id == "hidung_badut")
	_cek("Gunting tetap dipegang setelah dipakai", _interaksi.alat_di_tangan == "gunting")
	_cek_aksi("Kantong penuh: identifikasi hidung badut terkunci", "hidung_badut", "identifikasi", false)
	_cek("  dengan alasan \"Kantong penuh\"", _interaksi.aksi_kini.get("alasan", "") == AturanAksi.ALASAN_KANTONG_PENUH)


## Stage 1-1 diubah agar punya dua alat: E jadi gunting, S jadi sekop.
func _uji_tukar_alat() -> void:
	var data: Dictionary = DataGame.stage_dengan_id("1-1").duplicate(true)
	data.legenda.E = "gunting"
	data.legenda.S = "sekop"
	await _muat(data)
	await _berdiri_di(Vector2i(6, 2))
	await _jalankan_aksi("gunting", "ambil")
	await _berdiri_di(Vector2i(2, 5))
	await _jalankan_aksi("sekop", "ambil")
	_cek("Tukar alat: tangan memegang sekop", _interaksi.alat_di_tangan == "sekop")
	var ditaruh := _benda_di(Vector2i(2, 6))
	_cek("Tukar alat: gunting ditaruh di tempat sekop", ditaruh != null and ditaruh.id == "gunting")


## Stage 1-2: benih bunga (pengecoh) ditanam dan dipanen.
func _uji_panen_pengecoh() -> void:
	await _muat(DataGame.stage_dengan_id("1-2"))
	await _berdiri_di(Vector2i(2, 3))
	await _jalankan_aksi("pot_bunga", "identifikasi")
	_cek("Pot bunga jadi benih bunga", _kantong_berisi(["bunga"]))

	var tanah := _tanah_di(Vector2i(1, 6))
	await _berdiri_di(tanah.sel)
	_cek_aksi_tanah("Di petak tanah dengan benih: Tanam", tanah, "tanam")
	_interaksi.tekan_aksi()
	await _tunggu(DataGame.durasi("tanam") + float(FRAME_LEBIH) / FPS)
	_cek("Benih bunga tertanam, kantong kosong", tanah.status == AturanAksi.TANAH_TUMBUH and _interaksi.kantong.kosong())
	_cek("Tanaman yang tumbuh tidak menawarkan aksi", _interaksi.aksi_kini.is_empty())

	var posisi := _pemain.position
	_pemain.arah_paksa = Vector2.DOWN
	await _tunggu(0.3)
	_pemain.arah_paksa = Vector2.ZERO
	_cek("Pemain bisa bergerak selama tanaman tumbuh", _pemain.position.distance_to(posisi) > 0.5 * _stage.UKURAN_PETAK)
	_cek("Tanaman belum matang sebelum %.1f detik" % DataGame.durasi("tumbuh"), tanah.status == AturanAksi.TANAH_TUMBUH)
	await _tunggu(DataGame.durasi("tumbuh"))
	_cek("Tanaman matang setelah %.1f detik" % DataGame.durasi("tumbuh"), tanah.status == AturanAksi.TANAH_MATANG)

	await _berdiri_di(tanah.sel)
	_cek_aksi_tanah("Tanaman matang: Panen", tanah, "panen")
	_interaksi.tekan_aksi()
	await _tunggu(DataGame.durasi("panen") + float(FRAME_LEBIH) / FPS)
	var pesanan: RefCounted = _stage.pesanan
	_cek("Bunga tidak mengisi pesanan", pesanan.terisi.tomat == 0 and pesanan.terisi.wortel == 0)
	_cek("Pembeli menggeleng", _stage.peta.daftar_pembeli[0].sedang_menggeleng())
	_cek("Petak tanah kosong lagi, stage belum selesai", tanah.status == AturanAksi.TANAH_KOSONG and not _stage.sudah_selesai)


func _tanah_di(sel: Vector2i) -> Node2D:
	for t in _peta.daftar_tanah:
		if t.sel == sel:
			return t
	return null


func _cek_aksi_tanah(judul: String, tanah: Node2D, aksi: String) -> void:
	var a: Dictionary = _interaksi.aksi_kini
	_cek(judul, a.get("target") == tanah and a.get("aksi", "") == aksi and a.get("aktif", false),
		"dapat aksi='%s' aktif=%s" % [a.get("aksi", ""), a.get("aktif", false)])


func _muat(data: Dictionary) -> void:
	if _stage:
		_stage.free()
	_stage = ADEGAN_STAGE.instantiate()
	_stage.data = data
	root.add_child(_stage)
	await process_frame
	_interaksi = _stage.interaksi
	_pemain = _stage.pemain
	_peta = _stage.peta


func _berdiri_di(sel: Vector2i) -> void:
	_pemain.position = _peta.pusat_petak(sel)
	await _tunggu(2.0 / FPS)


## Memastikan aksi yang ditawarkan sesuai, menekannya, lalu menunggu selesai.
func _jalankan_aksi(id_target: String, aksi: String) -> void:
	_cek_aksi("Tawarkan %s pada %s" % [aksi, id_target], id_target, aksi, true)
	_interaksi.tekan_aksi()
	await _tunggu(DataGame.durasi(AturanAksi.KUNCI_DURASI[aksi]) + float(FRAME_LEBIH) / FPS)
	_cek("  %s selesai dalam durasinya" % aksi, not _interaksi.sibuk())


func _cek_aksi(judul: String, id_target: String, aksi: String, aktif: bool) -> void:
	var a: Dictionary = _interaksi.aksi_kini
	var target_id: String = a.target.id if a.has("target") and is_instance_valid(a.target) else ""
	_cek(judul, target_id == id_target and a.get("aksi", "") == aksi and a.get("aktif", false) == aktif,
		"dapat target='%s' aksi='%s' aktif=%s" % [target_id, a.get("aksi", ""), a.get("aktif", false)])


func _kantong_berisi(harapan: Array[String]) -> bool:
	return _interaksi.kantong.isi == harapan


func _benda_di(sel: Vector2i) -> Node2D:
	for b in _peta.daftar_benda:
		if b.sel == sel:
			return b
	return null


func _tunggu(detik: float) -> void:
	for i in ceili(detik * FPS):
		await process_frame
