extends "res://tools/dasar_uji.gd"
## Uji timer dan alur stage lewat adegan utama: hitung mundur, jeda saat
## aplikasi ke latar belakang, timer merah, waktu habis + ulang < 1 detik,
## layar menang dengan bintang dan rekor, lanjut ke stage berikutnya, dan
## kembali ke awal. Rekor ditulis ke file khusus uji, bukan rekor pemain.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-alur

const ADEGAN_MAIN := preload("res://scenes/main.tscn")
const DataGame := preload("res://scripts/inti/data_game.gd")
const FPS := 60
const FRAME_LEBIH := 3
## Batas dari dokumen: stage diulang dalam kurang dari 1 detik.
const BATAS_ULANG_DETIK := 1.0
const Rekor := preload("res://scripts/inti/rekor.gd")
const JALUR_REKOR_UJI := "user://uji_alur_rekor.json"

var _main: Node


func _initialize() -> void:
	_jalankan()


func _jalankan() -> void:
	await process_frame
	if not DataGame.galat.is_empty():
		print("GAGAL: data stage bermasalah, jalankan tools\\periksa.bat.")
		quit(1)
		return
	_hapus_rekor_uji()
	_main = ADEGAN_MAIN.instantiate()
	_main.jalur_rekor = JALUR_REKOR_UJI
	root.add_child(_main)
	await process_frame
	await _uji_timer_dan_jeda()
	await _uji_waktu_habis()
	await _uji_menang_dan_lanjut()
	_hapus_rekor_uji()
	_selesai("uji alur")


func _uji_timer_dan_jeda() -> void:
	var stage: Node = _main.stage_aktif()
	var waktu: float = stage.data.waktu_detik
	_cek("Stage pertama dimuat: %s" % stage.data.id, stage.data.id == DataGame.daftar_stage[0].data.id)
	# Stage sudah berjalan satu-dua frame sejak dimuat.
	_cek("Timer mulai dari waktu_detik stage (%d)" % waktu, waktu - stage.sisa_detik <= 2.0 / FPS + 0.001,
		"sisa %.3f" % stage.sisa_detik)
	await _tunggu(1.0)
	_cek("Timer berkurang ~1 detik dalam 1 detik", absf(waktu - 1.0 - stage.sisa_detik) < 0.05,
		"sisa %.2f" % stage.sisa_detik)

	_main.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var saat_jeda: float = stage.sisa_detik
	var posisi: Vector2 = stage.pemain.position
	stage.pemain.arah_paksa = Vector2.UP
	await _tunggu(1.0)
	_cek("Aplikasi ke latar belakang: timer berhenti", is_equal_approx(stage.sisa_detik, saat_jeda),
		"sisa %.2f, saat jeda %.2f" % [stage.sisa_detik, saat_jeda])
	_cek("Aplikasi ke latar belakang: pemain ikut berhenti", stage.pemain.position.is_equal_approx(posisi))
	_cek("Layar 'Dijeda' tampil", _main.layar_hasil.sedang_tampil() and _main.layar_hasil.judul() == "Dijeda")
	stage.pemain.arah_paksa = Vector2.ZERO
	_main.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await _tunggu(0.5)
	_cek("Kembali dari latar belakang: timer lanjut", stage.sisa_detik < saat_jeda - 0.4)
	_cek("Kembali dari latar belakang: layar jeda hilang", not _main.layar_hasil.sedang_tampil())

	var batas_merah: float = DataGame.pengaturan.timer_merah_sisa_detik
	stage.sisa_detik = batas_merah + 0.5
	await _tunggu(0.2)
	_cek("Timer belum merah di atas %d detik" % batas_merah, not stage.hud.merah())
	await _tunggu(0.4)
	_cek("Timer merah pada %d detik terakhir" % batas_merah, stage.hud.merah())


func _uji_waktu_habis() -> void:
	var stage: Node = _main.stage_aktif()
	var id_stage: String = stage.data.id
	stage.sisa_detik = 0.3
	var frame := 0
	while not stage.sudah_habis and frame < FPS:
		frame += 1
		await process_frame
	_cek("Waktu habis terdeteksi", stage.sudah_habis)
	_cek("Layar 'Waktu habis!' tampil", _main.layar_hasil.sedang_tampil() and _main.layar_hasil.judul() == "Waktu habis!")
	_cek("Pemain tidak bisa bergerak setelah waktu habis", stage.pemain.terkunci)

	var frame_habis := Engine.get_process_frames()
	while _main.stage_aktif() == stage and Engine.get_process_frames() - frame_habis < 2 * FPS:
		await process_frame
	var detik_ulang := float(Engine.get_process_frames() - frame_habis) / FPS
	var baru: Node = _main.stage_aktif()
	_cek("Stage diulang dalam < %.0f detik (%.2f dtk)" % [BATAS_ULANG_DETIK, detik_ulang],
		baru != stage and detik_ulang < BATAS_ULANG_DETIK)
	_cek("Stage ulang sama dan mulai dari awal", baru.data.id == id_stage
		and is_equal_approx(baru.sisa_detik, float(baru.data.waktu_detik)) and baru.interaksi.kantong.kosong())
	_cek("Layar hasil hilang setelah stage diulang", not _main.layar_hasil.sedang_tampil())

	var mulai := Time.get_ticks_usec()
	_main.muat_stage(0)
	var ms := (Time.get_ticks_usec() - mulai) / 1000.0
	_cek("Memuat ulang stage cepat (%.1f ms waktu nyata)" % ms, ms < 200.0)


func _uji_menang_dan_lanjut() -> void:
	var jumlah_stage := DataGame.daftar_stage.size()
	_main.muat_stage(0)
	await process_frame
	var stage: Node = _main.stage_aktif()
	var ambang: Dictionary = stage.data.bintang_sisa_detik
	# Selesaikan pesanan langsung (alur tanam/panen sudah diuji di uji_main).
	await _menangkan(stage, ambang.tiga + 1.0)
	var id_pertama: String = stage.data.id
	_cek("Belum ada rekor: judul HUD tanpa rekor", not "rekor" in stage.hud.judul)
	_cek("Menang dengan sisa ≥ ambang tiga: 3 bintang", _main.layar_hasil.jumlah_bintang() == 3)
	_cek("Kemenangan pertama: \"Rekor baru!\"", _main.layar_hasil.teks_rekor() == "Rekor baru!")
	_cek("Timer berhenti setelah menang", is_equal_approx(stage.sisa_detik, ambang.tiga + 1.0))

	_main.layar_hasil.ulangi.emit()
	await process_frame
	stage = _main.stage_aktif()
	await _menangkan(stage, ambang.dua + 0.5)
	_cek("Ulangi lalu menang dengan sisa di antara ambang: 2 bintang", _main.layar_hasil.jumlah_bintang() == 2)
	_cek("2 bintang tidak menimpa rekor 3", _main.layar_hasil.teks_rekor() == "Rekor: 3 bintang"
		and Rekor.new(JALUR_REKOR_UJI).bintang(id_pertama) == 3)
	_cek("Judul HUD menampilkan rekor stage", "rekor 3/3" in stage.hud.judul, stage.hud.judul)

	_main.layar_hasil.ulangi.emit()
	await process_frame
	stage = _main.stage_aktif()
	await _menangkan(stage, ambang.dua - 0.5)
	_cek("Menang dengan sisa di bawah ambang dua: 1 bintang", _main.layar_hasil.jumlah_bintang() == 1)

	_main.layar_hasil.lanjut.emit()
	await process_frame
	_cek("Lanjut memuat stage kedua", _main.stage_aktif().data.id == DataGame.daftar_stage[1 % jumlah_stage].data.id)

	_main.muat_stage(jumlah_stage - 1)
	await process_frame
	await _menangkan(_main.stage_aktif(), 30.0)
	_main.layar_hasil.lanjut.emit()
	await process_frame
	_cek("Lanjut dari stage terakhir kembali ke stage pertama", _main.stage_aktif().data.id == DataGame.daftar_stage[0].data.id)


## Mengisi pesanan lewat jalur panen sungguhan (sinyal dipanen) dengan sisa waktu tertentu.
func _menangkan(stage: Node, sisa: float) -> void:
	stage.sisa_detik = sisa
	for tanaman in stage.pesanan.diminta:
		for i in stage.pesanan.diminta[tanaman]:
			stage.pesanan.terima(tanaman)
	stage.interaksi.dipanen.emit(stage.pesanan.diminta.keys()[0], true)
	await process_frame


func _hapus_rekor_uji() -> void:
	for jalur in [JALUR_REKOR_UJI, JALUR_REKOR_UJI + Rekor.AKHIRAN_SEMENTARA]:
		if FileAccess.file_exists(jalur):
			DirAccess.remove_absolute(jalur)


func _tunggu(detik: float) -> void:
	for i in ceili(detik * FPS):
		await process_frame
