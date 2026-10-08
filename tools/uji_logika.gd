extends "res://tools/dasar_uji.gd"
## Uji logika murni: kantong benih dan aturan tombol aksi.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-logika

const DataGame := preload("res://scripts/inti/data_game.gd")
const Kantong := preload("res://scripts/inti/kantong.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")


func _initialize() -> void:
	_uji_kantong()
	_uji_aturan_aksi()
	_selesai("uji logika")


func _uji_kantong() -> void:
	var kapasitas := int(DataGame.pengaturan.kapasitas_kantong)
	var k := Kantong.new(kapasitas)
	_cek("Kantong baru kosong, kapasitas %d dari pengaturan" % kapasitas, k.kosong() and k.kapasitas == kapasitas)
	var urutan := ["jagung", "tomat", "stroberi", "wortel", "kubis"]
	for i in kapasitas:
		k.tambah(urutan[i])
	_cek("Kantong penuh setelah %d benih" % kapasitas, k.penuh())
	_cek("Benih ke-%d ditolak saat penuh" % (kapasitas + 1), not k.tambah("kubis") and k.isi.size() == kapasitas)
	_cek("Benih berikutnya adalah yang paling lama (FIFO)", k.berikutnya() == urutan[0])
	var keluar: Array[String] = []
	while not k.kosong():
		keluar.append(k.ambil())
	_cek("Urutan tanam sama dengan urutan masuk", keluar == urutan.slice(0, kapasitas))
	_cek("Ambil dari kantong kosong mengembalikan \"\"", k.ambil() == "")


func _uji_aturan_aksi() -> void:
	var sumber := DataGame.entri_benda("lampion_merah")
	var kosong := DataGame.entri_benda("kotak_pos")
	var pengecoh := DataGame.entri_benda("bantalan_jarum")
	var wadah := DataGame.entri_benda("kardus_mainan")
	var alat := DataGame.entri_benda("gunting")
	var N := AturanAksi.STATUS_NORMAL

	_aksi("Sumber, kantong ada ruang: Identifikasi aktif", AturanAksi.untuk_benda(sumber, N, false, ""), "identifikasi", true)
	_aksi("Benda kosong: Identifikasi aktif", AturanAksi.untuk_benda(kosong, N, false, ""), "identifikasi", true)
	_aksi("Pengecoh: Identifikasi aktif", AturanAksi.untuk_benda(pengecoh, N, false, ""), "identifikasi", true)
	var penuh := AturanAksi.untuk_benda(sumber, N, true, "")
	_aksi("Sumber, kantong penuh: Identifikasi terkunci", penuh, "identifikasi", false)
	_cek("  alasan \"Kantong penuh\"", penuh.alasan == AturanAksi.ALASAN_KANTONG_PENUH)
	_aksi("Benda kosong, kantong penuh: juga terkunci (tidak membocorkan jawaban)", AturanAksi.untuk_benda(kosong, N, true, ""), "identifikasi", false)
	_aksi("Benda abu-abu: tidak ada aksi", AturanAksi.untuk_benda(kosong, AturanAksi.STATUS_ABU, false, ""), "", false)
	_aksi("Alat: Ambil aktif walau kantong penuh", AturanAksi.untuk_benda(alat, N, true, ""), "ambil", true)
	var tanpa_alat := AturanAksi.untuk_benda(wadah, N, false, "")
	_aksi("Wadah tanpa alat: Potong terkunci", tanpa_alat, "potong", false)
	_cek("  butuh_alat = gunting", tanpa_alat.butuh_alat == "gunting")
	_aksi("Wadah dengan alat salah (sekop): Potong terkunci", AturanAksi.untuk_benda(wadah, N, false, "sekop"), "potong", false)
	_aksi("Wadah dengan gunting: Potong aktif", AturanAksi.untuk_benda(wadah, N, true, "gunting"), "potong", true)


func _aksi(judul: String, hasil: Dictionary, aksi: String, aktif: bool) -> void:
	_cek(judul, hasil.aksi == aksi and hasil.aktif == aktif, "dapat aksi='%s' aktif=%s" % [hasil.aksi, hasil.aktif])
