extends Node
## Tombol aksi kontekstual dan aksi berdurasi. Setiap frame mencari benda
## terdekat dalam jarak interaksi, menentukan aksinya lewat AturanAksi, lalu
## menjalankan aksi saat tombol ditekan: identifikasi, ambil/tukar alat, potong
## wadah. Selama aksi berjalan pemain tidak bisa bergerak.
## Tanam dan panen ditambahkan di fase 6.

signal bawaan_berubah

const DataGame := preload("res://scripts/inti/data_game.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const Kantong := preload("res://scripts/inti/kantong.gd")
const TeksMelayang := preload("res://scripts/game/teks_melayang.gd")

const WARNA_TEKS_REAKSI := Color.WHITE
const WARNA_TEKS_INFO := Color("#b3e5fc")
## Kelonggaran jarak interaksi (satuan dunia) agar pemain yang berdiri tepat
## di tengah petak sebelah tetap terhitung dalam jangkauan.
const KELONGGARAN_JARAK := 0.5

var kantong: Kantong
## Id alat yang dipegang, atau "".
var alat_di_tangan := ""
## Aksi yang ditawarkan sekarang: hasil AturanAksi ditambah "target" (Benda).
## Kosong jika tidak ada benda dalam jangkauan.
var aksi_kini: Dictionary = {}

var _pemain: CharacterBody2D
var _peta: Node2D
var _tombol: Control
var _ukuran: float
var _berjalan: Dictionary = {}
var _sisa_detik := 0.0


func siapkan(pemain: CharacterBody2D, peta: Node2D, tombol: Control, ukuran_petak: float) -> void:
	_pemain = pemain
	_peta = peta
	_tombol = tombol
	_ukuran = ukuran_petak
	kantong = Kantong.new(int(DataGame.pengaturan.kapasitas_kantong))
	_tombol.ditekan.connect(tekan_aksi)


func sibuk() -> bool:
	return not _berjalan.is_empty()


func _process(delta: float) -> void:
	if sibuk():
		_sisa_detik -= delta
		_tombol.progres = 1.0 - _sisa_detik / _berjalan.durasi
		if _sisa_detik <= 0.0:
			_selesaikan()
		return
	_perbarui_target()


## Dipanggil tombol aksi (atau skrip uji). Diabaikan jika tidak ada aksi aktif.
func tekan_aksi() -> void:
	if sibuk() or aksi_kini.is_empty() or not aksi_kini.aktif:
		return
	_berjalan = aksi_kini.duplicate()
	_berjalan.durasi = DataGame.durasi(AturanAksi.KUNCI_DURASI[_berjalan.aksi])
	_sisa_detik = _berjalan.durasi
	_pemain.terkunci = true
	_tombol.progres = 0.0


func _perbarui_target() -> void:
	var jangkauan: float = DataGame.pengaturan.jarak_interaksi_petak * _ukuran + KELONGGARAN_JARAK
	var terdekat: Node2D = null
	var aksi_terdekat := {}
	var jarak_terdekat := INF
	for benda in _peta.daftar_benda:
		var jarak := _pemain.position.distance_to(benda.position)
		var dalam_jangkauan := jarak <= jangkauan
		var aksi := AturanAksi.untuk_benda(benda.entri, benda.status, kantong.penuh(), alat_di_tangan)
		# Wadah tertutup memunculkan ikon alat saat didekati, tanpa memotong waktu.
		benda.ikon_alat = DataGame.nama_benda(aksi.butuh_alat) if dalam_jangkauan and aksi.butuh_alat != "" else ""
		if dalam_jangkauan and aksi.aksi != AturanAksi.AKSI_TIDAK_ADA and jarak < jarak_terdekat:
			terdekat = benda
			aksi_terdekat = aksi
			jarak_terdekat = jarak
	for benda in _peta.daftar_benda:
		benda.disorot = benda == terdekat

	aksi_kini = {}
	if terdekat == null:
		_tombol.tampilkan("", false, "", "")
		return
	aksi_kini = aksi_terdekat
	aksi_kini.target = terdekat
	var alasan: String = aksi_kini.alasan
	if aksi_kini.butuh_alat != "":
		alasan = "Butuh %s" % DataGame.nama_benda(aksi_kini.butuh_alat)
	_tombol.tampilkan(aksi_kini.label, aksi_kini.aktif, alasan, DataGame.nama_benda(terdekat.id))


func _selesaikan() -> void:
	var aksi := _berjalan
	_berjalan = {}
	_pemain.terkunci = false
	_tombol.progres = -1.0
	var benda: Node2D = aksi.target
	if not is_instance_valid(benda):
		return
	match aksi.aksi:
		AturanAksi.AKSI_IDENTIFIKASI:
			_identifikasi(benda)
		AturanAksi.AKSI_AMBIL:
			_ambil(benda)
		AturanAksi.AKSI_POTONG:
			benda.buka()
			_teks(benda.position, "Terbuka!", WARNA_TEKS_INFO)
	bawaan_berubah.emit()
	_perbarui_target()


## Sumber dan pengecoh berubah jadi benih; benda kosong bereaksi lalu abu-abu.
func _identifikasi(benda: Node2D) -> void:
	if benda.jenis() == PemuatData.JENIS_SUMBER:
		var tanaman: String = benda.entri.hasil
		kantong.tambah(tanaman)
		_teks(benda.position, "+ Benih %s" % DataGame.nama_tanaman(tanaman).to_lower(), DataGame.warna_tanaman(tanaman))
		_peta.hapus_benda(benda)
	else:
		_teks(benda.position, str(benda.entri.get("teks_reaksi", "...")), WARNA_TEKS_REAKSI)
		benda.jadi_abu()


## Tangan memegang satu alat: alat lama ditaruh di tempat alat baru.
func _ambil(benda: Node2D) -> void:
	var lama := alat_di_tangan
	alat_di_tangan = benda.id
	_teks(benda.position, "Memegang %s" % DataGame.nama_benda(alat_di_tangan), WARNA_TEKS_INFO)
	if lama == "":
		_peta.hapus_benda(benda)
	else:
		benda.ganti_menjadi(lama)


func _teks(posisi: Vector2, teks: String, warna: Color) -> void:
	var t := TeksMelayang.new()
	t.position = posisi
	t.siapkan(teks, warna, _ukuran)
	_peta.add_child(t)
