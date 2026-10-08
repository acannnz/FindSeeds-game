extends "res://tools/dasar_uji.gd"
## Uji kontrol melayang: joystick dinamis (event sentuh sungguhan lewat
## viewport), tombol aksi, label target di dunia, dan tata letak peta selebar
## layar untuk beberapa rasio layar HP.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-kontrol

const ADEGAN_STAGE := preload("res://scenes/stage.tscn")
const SkripStage := preload("res://scripts/game/stage.gd")
const DataGame := preload("res://scripts/inti/data_game.gd")
const FPS := 60

var _stage: Node


func _initialize() -> void:
	_jalankan()


func _jalankan() -> void:
	await process_frame
	if not DataGame.galat.is_empty():
		print("GAGAL: data stage bermasalah, jalankan tools\\periksa.bat.")
		quit(1)
		return
	_uji_tata_letak()
	_stage = ADEGAN_STAGE.instantiate()
	_stage.data = DataGame.stage_dengan_id("1-3")
	root.add_child(_stage)
	await process_frame
	await _uji_joystick()
	await _uji_tombol_dan_label()
	_selesai("uji kontrol")


func _uji_tata_letak() -> void:
	var p := DataGame.pengaturan
	var dunia := Vector2(p.peta_lebar_petak, p.peta_tinggi_petak) * SkripStage.UKURAN_PETAK
	var atas: float = p.tinggi_hud_atas_px
	var porsi: float = p.porsi_bawah_minimal
	# Ukuran viewport untuk lebar 720 pada beberapa rasio layar HP.
	for rasio in [["9:16", 1280.0], ["9:18", 1440.0], ["9:19,5", 1560.0], ["9:20", 1600.0]]:
		var layar := Vector2(720.0, rasio[1])
		var t := SkripStage.hitung_tata_letak(layar, dunia, atas, porsi)
		var ukuran_peta: Vector2 = dunia * t.skala
		var bawah: float = layar.y - t.asal.y - ukuran_peta.y
		_cek("Layar %s: peta di bawah HUD, di dalam layar, sisa bawah ≥ %d%% (%.0f px, %.0f%%)" % [rasio[0], porsi * 100, bawah, bawah / layar.y * 100],
			is_equal_approx(t.asal.y, atas) and t.asal.x >= -0.01 and ukuran_peta.x <= layar.x + 0.01 and bawah >= layar.y * porsi - 0.01)
		# HP modern (≥ 19,5:9): peta selebar layar. Layar lebih pendek: peta
		# diperkecil secukupnya agar sisa bawah tetap ≥ porsi_bawah_minimal.
		if rasio[1] >= 1560.0:
			_cek("Layar %s: peta selebar layar (%.0f px)" % [rasio[0], ukuran_peta.x], is_equal_approx(ukuran_peta.x, layar.x))
		else:
			_cek("Layar %s: peta diperkecil secukupnya, tetap di tengah (%.0f px)" % [rasio[0], ukuran_peta.x],
				ukuran_peta.x < layar.x and is_equal_approx(t.asal.x * 2.0 + ukuran_peta.x, layar.x))


func _uji_joystick() -> void:
	var joystick: Control = _stage.joystick
	var pemain: CharacterBody2D = _stage.pemain
	var layar: Vector2 = _stage.get_viewport_rect().size
	var r: float = DataGame.pengaturan.joystick_radius_px
	_cek("Joystick tidak terlihat sebelum disentuh", joystick.tampak() == 0.0 and not joystick.aktif())

	# Sentuh di separuh kiri, di atas peta sekalipun.
	var titik := Vector2(layar.x * 0.2, layar.y * 0.5)
	_sentuh(0, titik, true)
	await _tunggu(0.1)
	_cek("Sentuhan di separuh kiri (di atas peta) memunculkan joystick di titik itu",
		joystick.aktif() and joystick.tampak() == 1.0 and joystick.pusat_alas_layar().is_equal_approx(titik))
	_cek("Joystick baru muncul: belum bergerak", joystick.vektor == Vector2.ZERO)

	_seret(0, titik + Vector2(r * 0.5, 0))
	var dz: float = DataGame.pengaturan.joystick_zona_mati
	var harap := (0.5 - dz) / (1.0 - dz)
	_cek("Seret setengah radius: kecepatan analog %.2f" % harap, is_equal_approx(joystick.vektor.x, harap) and joystick.vektor.y == 0.0)

	var jauh := titik + Vector2(r * 3.0, 0)
	_seret(0, jauh)
	_cek("Seret melewati radius: jalan penuh", is_equal_approx(joystick.vektor.length(), 1.0))
	_cek("Seret melewati radius: alas ikut tertarik (jarak alas–jempol = radius)",
		is_equal_approx(joystick.pusat_alas_layar().distance_to(jauh), r))

	# Alas sekarang di jauh - r; jempol ke kiri alas langsung berbalik arah.
	_seret(0, jauh - Vector2(r * 1.5, 0))
	_cek("Setelah alas tertarik, menggeser balik langsung berbalik arah", joystick.vektor.x < 0.0)

	# Pemain mulai di '@' 1-3; atasnya kosong.
	_seret(0, joystick.pusat_alas_layar() + Vector2(0, -r))
	var y_awal := pemain.position.y
	await _tunggu(0.3)
	_cek("Pemain bergerak mengikuti joystick", pemain.position.y < y_awal - 10.0)

	# Jempol kedua di separuh kanan tidak merebut joystick.
	var alas: Vector2 = joystick.pusat_alas_layar()
	_sentuh(1, Vector2(layar.x * 0.8, layar.y * 0.5), true)
	_cek("Sentuhan kedua di separuh kanan tidak mengganggu joystick", joystick.aktif() and joystick.pusat_alas_layar() == alas)
	_sentuh(1, Vector2(layar.x * 0.8, layar.y * 0.5), false)

	_sentuh(0, jauh, false)
	_cek("Dilepas: berhenti seketika", joystick.vektor == Vector2.ZERO and not joystick.aktif())
	await _tunggu(0.1)
	_cek("Dilepas: sedang memudar", joystick.tampak() > 0.0 and joystick.tampak() < 1.0)
	await _tunggu(0.3)
	_cek("Dilepas: hilang setelah memudar", joystick.tampak() == 0.0)

	_sentuh(0, Vector2(layar.x * 0.8, layar.y * 0.5), true)
	_cek("Sentuhan pertama di separuh kanan tidak memunculkan joystick", not joystick.aktif())
	_sentuh(0, Vector2(layar.x * 0.8, layar.y * 0.5), false)


func _uji_tombol_dan_label() -> void:
	var tombol: Control = _stage.tombol_aksi
	var label: Node2D = _stage.label_target
	var jumlah := [0]
	tombol.ditekan.connect(func(): jumlah[0] += 1)

	var p: Vector2 = tombol.global_position + tombol.pusat()
	var layar: Vector2 = _stage.get_viewport_rect().size
	_cek("Tombol aksi di kanan bawah layar", p.x > layar.x * 0.6 and p.y > layar.y * 0.75)

	_stage.pemain.position = _stage.peta.pusat_petak(Vector2i(2, 9))
	await _tunggu(2.0 / FPS)
	_cek("Dekat kotak pos: label muncul di atas target", label.visible and label.position == _stage.peta.pusat_petak(Vector2i(2, 10)))

	_sentuh(2, p, true)
	_sentuh(2, p, false)
	_cek("Sentuh di tombol: tombol terpicu dan aksi berjalan", jumlah[0] == 1 and _stage.interaksi.sibuk())
	_sentuh(2, Vector2(layar.x * 0.75, layar.y * 0.4), true)
	_sentuh(2, Vector2(layar.x * 0.75, layar.y * 0.4), false)
	_cek("Sentuh di luar tombol: tidak memicu", jumlah[0] == 1)

	await _tunggu(DataGame.durasi("identifikasi") + 0.1)
	_cek("Tidak ada target lagi: label disembunyikan", not label.visible)


func _sentuh(indeks: int, posisi: Vector2, tekan: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = indeks
	e.position = posisi
	e.pressed = tekan
	root.push_input(e, true)


func _seret(indeks: int, posisi: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = indeks
	e.position = posisi
	root.push_input(e, true)


func _tunggu(detik: float) -> void:
	for i in ceili(detik * FPS):
		await process_frame
