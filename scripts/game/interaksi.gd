extends Node
## Tombol aksi kontekstual dan aksi berdurasi. Setiap frame mencari benda atau
## petak tanah terdekat dalam jarak interaksi (jika jaraknya seri, yang searah
## hadap pemain menang), menentukan aksinya lewat
## AturanAksi, lalu menjalankan aksi saat tombol ditekan: identifikasi,
## ambil/tukar alat, potong wadah, tanam, dan panen. Selama aksi berjalan
## pemain tidak bisa bergerak.

signal bawaan_berubah
## Hasil panen sudah diproses: diterima = true jika mengisi pesanan.
signal dipanen(tanaman: String, diterima: bool)

const DataGame := preload("res://scripts/inti/data_game.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const Kantong := preload("res://scripts/inti/kantong.gd")
const PetakTanah := preload("res://scripts/game/petak_tanah.gd")
const TeksMelayang := preload("res://scripts/game/teks_melayang.gd")

const WARNA_TEKS_REAKSI := Color.WHITE
const WARNA_TEKS_INFO := Color("#b3e5fc")
const WARNA_TEKS_DITOLAK := Color("#ef9a9a")
## Kelonggaran jarak interaksi (satuan dunia) agar pemain yang berdiri tepat
## di tengah petak sebelah tetap terhitung dalam jangkauan.
const KELONGGARAN_JARAK := 0.5

var kantong: Kantong
var pesanan: RefCounted
## Id alat yang dipegang, atau "".
var alat_di_tangan := ""
## Aksi yang ditawarkan sekarang: hasil AturanAksi ditambah "target" (Benda
## atau PetakTanah). Kosong jika tidak ada target dalam jangkauan.
var aksi_kini: Dictionary = {}

var _pemain: CharacterBody2D
var _peta: Node2D
var _tombol: Control
var _label_target: Node2D
var _ukuran: float
var _berjalan: Dictionary = {}
var _sisa_detik := 0.0
var _berhenti := false


func siapkan(pemain: CharacterBody2D, peta: Node2D, tombol: Control, label_target: Node2D, pesanan_stage: RefCounted, ukuran_petak: float) -> void:
	_pemain = pemain
	_peta = peta
	_tombol = tombol
	_label_target = label_target
	pesanan = pesanan_stage
	_ukuran = ukuran_petak
	kantong = Kantong.new(int(DataGame.pengaturan.kapasitas_kantong))
	_tombol.ditekan.connect(tekan_aksi)


func sibuk() -> bool:
	return not _berjalan.is_empty()


## Menghentikan semua interaksi (stage selesai): tombol dikosongkan.
func hentikan() -> void:
	_berhenti = true
	_berjalan = {}
	aksi_kini = {}
	_tombol.progres = -1.0
	_tombol.tampilkan("", false, "")
	_label_target.sembunyikan()
	_sorot(null)


func _process(delta: float) -> void:
	if _berhenti:
		return
	if sibuk():
		_sisa_detik -= delta
		_tombol.progres = 1.0 - _sisa_detik / _berjalan.durasi
		if _sisa_detik <= 0.0:
			_selesaikan()
		return
	_perbarui_target()


## Dipanggil tombol aksi (atau skrip uji). Diabaikan jika tidak ada aksi aktif.
func tekan_aksi() -> void:
	if _berhenti or sibuk() or aksi_kini.is_empty() or not aksi_kini.aktif:
		return
	_berjalan = aksi_kini.duplicate()
	_berjalan.durasi = DataGame.durasi(AturanAksi.KUNCI_DURASI[_berjalan.aksi])
	_sisa_detik = _berjalan.durasi
	_pemain.terkunci = true
	_tombol.progres = 0.0


func _perbarui_target() -> void:
	var jangkauan: float = DataGame.pengaturan.jarak_interaksi_petak * _ukuran + KELONGGARAN_JARAK
	var calon: Array[Dictionary] = []
	for benda in _peta.daftar_benda:
		var jarak := _pemain.position.distance_to(benda.position)
		var dalam_jangkauan := jarak <= jangkauan
		var aksi := AturanAksi.untuk_benda(benda.entri, benda.status, kantong.penuh(), alat_di_tangan)
		# Wadah tertutup memunculkan ikon alat saat didekati, tanpa memotong waktu.
		benda.ikon_alat = aksi.butuh_alat if dalam_jangkauan else ""
		if dalam_jangkauan and aksi.aksi != AturanAksi.AKSI_TIDAK_ADA:
			calon.append({"target": benda, "aksi": aksi, "jarak": jarak})
	for tanah in _peta.daftar_tanah:
		var jarak := _pemain.position.distance_to(tanah.position)
		var aksi := AturanAksi.untuk_tanah(tanah.status, not kantong.kosong())
		if jarak <= jangkauan and aksi.aksi != AturanAksi.AKSI_TIDAK_ADA:
			calon.append({"target": tanah, "aksi": aksi, "jarak": jarak})
	var pilihan := _pilih_calon(calon)
	var terdekat: Node2D = pilihan.get("target")
	var aksi_terdekat: Dictionary = pilihan.get("aksi", {})
	_sorot(terdekat)

	aksi_kini = {}
	if terdekat == null:
		_tombol.tampilkan("", false, "")
		_label_target.sembunyikan()
		return
	aksi_kini = aksi_terdekat
	aksi_kini.target = terdekat
	var alasan: String = aksi_kini.alasan
	if aksi_kini.butuh_alat != "":
		alasan = "Butuh %s" % DataGame.nama_benda(aksi_kini.butuh_alat)
	_tombol.tampilkan(aksi_kini.label, aksi_kini.aktif, alasan, aksi_kini.aksi)
	var ada_ikon: bool = "ikon_alat" in terdekat and terdekat.ikon_alat != ""
	# Pemain di atas target: label di bawah agar tidak menutupi pemain.
	var di_bawah := _pemain.position.y < terdekat.position.y - _ukuran * 0.25
	_label_target.tampilkan(terdekat.position, _nama_target(terdekat), aksi_kini.label, aksi_kini.aktif, alasan, ada_ikon, di_bawah)


## Calon terdekat. Jika selisih jaraknya dalam toleransi seri, pilih yang
## arahnya paling searah dengan hadap pemain.
func _pilih_calon(calon: Array[Dictionary]) -> Dictionary:
	var seri: float = DataGame.pengaturan.toleransi_seri_petak * _ukuran
	var terbaik := {}
	for c in calon:
		c.searah = _pemain.hadap.dot((c.target.position - _pemain.position).normalized())
		if terbaik.is_empty() or c.jarak < terbaik.jarak - seri 				or (absf(c.jarak - terbaik.jarak) <= seri and c.searah > terbaik.searah):
			terbaik = c
	return terbaik


func _nama_target(target: Node2D) -> String:
	if target is PetakTanah:
		if target.status == AturanAksi.TANAH_MATANG:
			return "%s matang" % DataGame.nama_tanaman(target.tanaman)
		# Benih ditanam sesuai urutan masuk; beri tahu benih mana yang akan dipakai.
		return "Petak tanah · benih %s" % DataGame.nama_tanaman(kantong.berikutnya()).to_lower()
	return DataGame.nama_benda(target.id)


func _sorot(target: Node2D) -> void:
	for benda in _peta.daftar_benda:
		benda.disorot = benda == target
	for tanah in _peta.daftar_tanah:
		tanah.disorot = tanah == target


func _selesaikan() -> void:
	var aksi := _berjalan
	_berjalan = {}
	_pemain.terkunci = false
	_tombol.progres = -1.0
	var target: Node2D = aksi.target
	if not is_instance_valid(target):
		return
	match aksi.aksi:
		AturanAksi.AKSI_IDENTIFIKASI:
			_identifikasi(target)
		AturanAksi.AKSI_AMBIL:
			_ambil(target)
		AturanAksi.AKSI_POTONG:
			target.buka()
			_teks(target.position, "Terbuka!", WARNA_TEKS_INFO)
		AturanAksi.AKSI_TANAM:
			var tanaman := kantong.ambil()
			target.tanam(tanaman)
			_teks(target.position, "%s ditanam" % DataGame.nama_tanaman(tanaman), WARNA_TEKS_INFO)
		AturanAksi.AKSI_PANEN:
			_panen(target)
	bawaan_berubah.emit()
	if not _berhenti:
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


## Tidak ada keranjang: hasil panen langsung mengisi pesanan atau hilang.
func _panen(tanah: Node2D) -> void:
	var tanaman: String = tanah.panen()
	var diterima: bool = pesanan.terima(tanaman)
	if diterima:
		_teks(tanah.position, "%s untuk pesanan!" % DataGame.nama_tanaman(tanaman), DataGame.warna_tanaman(tanaman))
	else:
		_teks(tanah.position, "%s tidak dipesan" % DataGame.nama_tanaman(tanaman), WARNA_TEKS_DITOLAK)
	dipanen.emit(tanaman, diterima)


func _teks(posisi: Vector2, teks: String, warna: Color) -> void:
	var t := TeksMelayang.new()
	t.position = posisi
	t.siapkan(teks, warna, _ukuran)
	_peta.add_child(t)
