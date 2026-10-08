extends "res://tools/dasar_uji.gd"
## Uji logika murni: kantong benih, pesanan, bintang, rekor, dan aturan tombol aksi.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-logika

const DataGame := preload("res://scripts/inti/data_game.gd")
const Kantong := preload("res://scripts/inti/kantong.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")
const Pesanan := preload("res://scripts/inti/pesanan.gd")
const Bintang := preload("res://scripts/inti/bintang.gd")
const Rekor := preload("res://scripts/inti/rekor.gd")

## File rekor khusus uji, supaya rekor pemain tidak tersentuh.
const JALUR_REKOR_UJI := "user://uji_logika_rekor.json"


func _initialize() -> void:
	_uji_kantong()
	_uji_pesanan()
	_uji_bintang()
	_uji_rekor()
	_uji_aturan_aksi()
	_uji_aturan_tanah()
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


func _uji_pesanan() -> void:
	# Pesanan stage 1-3 dari file data: 2 tomat, 1 jagung.
	var p := Pesanan.new(DataGame.stage_dengan_id("1-3").pesanan.isi)
	_cek("Pesanan baru belum lengkap", not p.lengkap())
	_cek("Stroberi (pengecoh) ditolak", not p.terima("stroberi"))
	_cek("Tomat pertama diterima", p.terima("tomat"))
	_cek("Jagung diterima dan item jagung lengkap", p.terima("jagung") and p.tanaman_lengkap("jagung"))
	_cek("Jagung kedua (melebihi pesanan) ditolak", not p.terima("jagung"))
	_cek("Belum lengkap selama tomat baru 1 dari 2", not p.lengkap() and p.terisi.tomat == 1)
	_cek("Tomat kedua melengkapi pesanan", p.terima("tomat") and p.lengkap())


func _uji_bintang() -> void:
	for s in DataGame.daftar_stage:
		var ambang: Dictionary = s.data.bintang_sisa_detik
		var id: String = s.data.id
		_cek("Stage %s: sisa %d (= ambang tiga) memberi 3 bintang" % [id, ambang.tiga], Bintang.hitung(ambang.tiga, ambang) == 3)
		_cek("Stage %s: sisa %.1f memberi 2 bintang" % [id, ambang.tiga - 0.1], Bintang.hitung(ambang.tiga - 0.1, ambang) == 2)
		_cek("Stage %s: sisa %d (= ambang dua) memberi 2 bintang" % [id, ambang.dua], Bintang.hitung(ambang.dua, ambang) == 2)
		_cek("Stage %s: sisa %.1f memberi 1 bintang" % [id, ambang.dua - 0.1], Bintang.hitung(ambang.dua - 0.1, ambang) == 1)
	_cek("Selesai di detik terakhir tetap 1 bintang", Bintang.hitung(0.01, {"tiga": 60, "dua": 40}) == 1)


func _uji_rekor() -> void:
	_hapus_rekor_uji()
	var r := Rekor.new(JALUR_REKOR_UJI)
	_cek("Rekor tanpa file: 0 bintang", r.bintang("1-1") == 0)
	_cek("2 bintang pertama adalah rekor baru", r.catat("1-1", 2))
	_cek("1 bintang bukan rekor baru, rekor tetap 2", not r.catat("1-1", 1) and r.bintang("1-1") == 2)
	_cek("2 bintang lagi bukan rekor baru", not r.catat("1-1", 2))
	_cek("3 bintang memecahkan rekor (file ditimpa)", r.catat("1-1", 3) and r.bintang("1-1") == 3)
	r.catat("1-3", 1)
	var dimuat := Rekor.new(JALUR_REKOR_UJI)
	_cek("Rekor tersimpan dan terbaca lagi (sesi baru)", dimuat.bintang("1-1") == 3 and dimuat.bintang("1-3") == 1 and dimuat.bintang("1-2") == 0)
	_cek("Tidak ada file sementara tertinggal", not FileAccess.file_exists(JALUR_REKOR_UJI + Rekor.AKHIRAN_SEMENTARA))

	# Aplikasi mati di antara hapus dan ganti nama: hanya file sementara tersisa.
	DirAccess.rename_absolute(JALUR_REKOR_UJI, JALUR_REKOR_UJI + Rekor.AKHIRAN_SEMENTARA)
	_cek("Rekor dipulihkan dari file sementara", Rekor.new(JALUR_REKOR_UJI).bintang("1-1") == 3)
	_hapus_rekor_uji()

	var f := FileAccess.open(JALUR_REKOR_UJI, FileAccess.WRITE)
	f.store_string("{ ini bukan json")
	f.close()
	var rusak := Rekor.new(JALUR_REKOR_UJI)
	_cek("File rekor rusak: tidak crash, dimulai dari 0", rusak.bintang("1-1") == 0)
	_cek("File rusak tertimpa rekor baru yang sah", rusak.catat("1-1", 2) and Rekor.new(JALUR_REKOR_UJI).bintang("1-1") == 2)

	f = FileAccess.open(JALUR_REKOR_UJI, FileAccess.WRITE)
	f.store_string('{"versi": 1, "bintang": {"1-1": 99, "1-2": "tiga"}}')
	f.close()
	var aneh := Rekor.new(JALUR_REKOR_UJI)
	_cek("Nilai di luar batas dipotong ke maksimum, nilai bukan angka diabaikan",
		aneh.bintang("1-1") == Bintang.BINTANG_MAKS and aneh.bintang("1-2") == 0)
	_hapus_rekor_uji()


func _hapus_rekor_uji() -> void:
	for jalur in [JALUR_REKOR_UJI, JALUR_REKOR_UJI + Rekor.AKHIRAN_SEMENTARA]:
		if FileAccess.file_exists(jalur):
			DirAccess.remove_absolute(jalur)


func _uji_aturan_tanah() -> void:
	_aksi("Tanah kosong + ada benih: Tanam aktif", AturanAksi.untuk_tanah(AturanAksi.TANAH_KOSONG, true), "tanam", true)
	_aksi("Tanah kosong tanpa benih: tidak ada aksi", AturanAksi.untuk_tanah(AturanAksi.TANAH_KOSONG, false), "", false)
	_aksi("Tanaman tumbuh: tidak ada aksi", AturanAksi.untuk_tanah(AturanAksi.TANAH_TUMBUH, true), "", false)
	_aksi("Tanaman matang: Panen aktif", AturanAksi.untuk_tanah(AturanAksi.TANAH_MATANG, false), "panen", true)


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
	var hiasan := AturanAksi.untuk_benda(DataGame.entri_benda("batu_bulat"), N, false, "")
	_aksi("Hiasan: bisa diperiksa seperti benda kosong", hiasan, "identifikasi", true)
	_cek("  label tombol \"Periksa\"", hiasan.label == "Periksa")
	_aksi("Hiasan, kantong penuh: ikut terkunci", AturanAksi.untuk_benda(DataGame.entri_benda("batu_bulat"), N, true, ""), "identifikasi", false)
	_aksi("Benda abu-abu: tidak ada aksi", AturanAksi.untuk_benda(kosong, AturanAksi.STATUS_ABU, false, ""), "", false)
	_aksi("Alat: Ambil aktif walau kantong penuh", AturanAksi.untuk_benda(alat, N, true, ""), "ambil", true)
	var tanpa_alat := AturanAksi.untuk_benda(wadah, N, false, "")
	_aksi("Wadah tanpa alat: Potong terkunci", tanpa_alat, "potong", false)
	_cek("  butuh_alat = gunting", tanpa_alat.butuh_alat == "gunting")
	_aksi("Wadah dengan alat salah (sekop): Potong terkunci", AturanAksi.untuk_benda(wadah, N, false, "sekop"), "potong", false)
	_aksi("Wadah dengan gunting: Potong aktif", AturanAksi.untuk_benda(wadah, N, true, "gunting"), "potong", true)


func _aksi(judul: String, hasil: Dictionary, aksi: String, aktif: bool) -> void:
	_cek(judul, hasil.aksi == aksi and hasil.aktif == aktif, "dapat aksi='%s' aktif=%s" % [hasil.aksi, hasil.aktif])
