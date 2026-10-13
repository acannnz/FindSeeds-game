extends "res://tools/dasar_uji.gd"
## Uji kontrol melayang: joystick dinamis (event sentuh sungguhan lewat
## viewport), pop-up aksi di atas benda, dan tata letak peta selebar layar
## untuk beberapa rasio layar HP.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-kontrol

const ADEGAN_STAGE := preload("res://scenes/stage.tscn")
const SkripStage := preload("res://scripts/game/stage.gd")
const DataGame := preload("res://scripts/inti/data_game.gd")
const Aset := preload("res://scripts/inti/aset.gd")
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
	await _uji_popup()
	await _uji_catatan()
	_selesai("uji kontrol")


func _uji_tata_letak() -> void:
	var p := DataGame.pengaturan
	var dunia := Vector2(p.peta_lebar_petak, p.peta_tinggi_petak) * SkripStage.UKURAN_PETAK
	var atas: float = p.tinggi_hud_atas_px
	# Ukuran viewport untuk lebar 720 pada beberapa rasio layar HP.
	for rasio in [["9:16", 1280.0], ["9:18", 1440.0], ["9:19,5", 1560.0], ["9:20", 1600.0], ["3:4", 960.0]]:
		var layar := Vector2(720.0, rasio[1])
		var t := SkripStage.hitung_tata_letak(layar, dunia, atas, layar.y)
		var ukuran_peta: Vector2 = dunia * t.skala
		var sela_atas: float = t.asal.y - atas
		var sela_bawah: float = layar.y - t.asal.y - ukuran_peta.y
		_cek("Layar %s: peta di bawah HUD, di dalam layar, di tengah sisa tinggi (sela %.0f / %.0f px)" % [rasio[0], sela_atas, sela_bawah],
			sela_atas >= -0.01 and sela_bawah >= -0.01 and is_equal_approx(sela_atas, sela_bawah)
			and t.asal.x >= -0.01 and ukuran_peta.x <= layar.x + 0.01)
		if rasio[1] >= 1280.0:
			_cek("Layar %s: peta selebar layar (%.0f px)" % [rasio[0], ukuran_peta.x], is_equal_approx(ukuran_peta.x, layar.x))
		else:
			_cek("Layar %s: peta diperkecil agar muat, di tengah horizontal (%.0f px)" % [rasio[0], ukuran_peta.x],
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


func _uji_popup() -> void:
	var popup: Node2D = _stage.popup_aksi
	var joystick: Control = _stage.joystick
	var jumlah := [0]
	popup.ditekan.connect(func(): jumlah[0] += 1)
	var layar: Vector2 = _stage.get_viewport_rect().size
	var kanvas: Transform2D = popup.get_canvas_transform()

	_stage.pemain.position = _stage.peta.pusat_petak(Vector2i(2, 9))
	# Hiasan di atas pemain sama dekatnya; hadapkan ke kotak pos (pemecah seri).
	_stage.pemain.hadap = Vector2.DOWN
	await _tunggu(2.0 / FPS)
	var target: Vector2 = _stage.peta.pusat_petak(Vector2i(2, 10))
	_cek("Dekat kotak pos: pop-up muncul menempel pada target", popup.visible and popup.position == target)
	# Pemain berdiri di atas kotak pos: pop-up pindah ke bawah agar tidak menutupi pemain.
	_cek("Pop-up di bawah target (pemain di atasnya), berikon kaca pembesar (Periksa)",
		popup.pusat_gelembung().y > target.y and popup._ikon != null and popup._ikon == Aset.tekstur(Aset.aksi("identifikasi")))

	_sentuh(2, kanvas * Vector2(target.x, target.y + SkripStage.UKURAN_PETAK * 3.0), true)
	_sentuh(2, kanvas * Vector2(target.x, target.y + SkripStage.UKURAN_PETAK * 3.0), false)
	_cek("Sentuh di luar pop-up: tidak memicu", jumlah[0] == 0)

	# Gelembung bisa berada di separuh kiri layar: joystick tidak boleh ikut muncul.
	var p: Vector2 = kanvas * popup.pusat_gelembung()
	_sentuh(2, p, true)
	_cek("Sentuh di pop-up: aksi berjalan, joystick tidak muncul", jumlah[0] == 1 and _stage.interaksi.sibuk() and not joystick.aktif())
	_sentuh(2, p, false)
	await _tunggu(0.5)
	_cek("Selama aksi: pop-up tetap tampil dengan cincin progres", popup.visible and popup.progres > 0.0 and popup.progres < 1.0)

	await _tunggu(DataGame.durasi("identifikasi"))
	_cek("Kotak pos abu-abu tidak lagi diberi pop-up", not popup.visible or popup.position != target)
	_stage.pemain.position = _stage.peta.pusat_petak(Vector2i(4, 8))
	await _tunggu(2.0 / FPS)
	_cek("Tidak ada target dalam jangkauan: pop-up disembunyikan", not popup.visible)
	_cek("Tidak ada tombol aksi di pojok layar", not _stage.has_node("UI/TombolAksi") and layar.x > 0.0)


func _uji_catatan() -> void:
	var popup: Node2D = _stage.popup_aksi
	var panel: Control = _stage.panel_petunjuk
	var joystick: Control = _stage.joystick
	var layar: Vector2 = _stage.get_viewport_rect().size
	var kanvas: Transform2D = popup.get_canvas_transform()
	# Catatan 1-3 di samping lahan, dicapai dari petak tanah di sebelahnya.
	var sel_catatan := Vector2i(2, 7)
	_stage.pemain.position = _stage.peta.pusat_petak(Vector2i(1, 7))
	_stage.pemain.hadap = Vector2.RIGHT
	await _tunggu(2.0 / FPS)
	_cek("Dekat catatan: pop-up \"Baca\" berikon buku, nama terlihat",
		popup.visible and popup.position == _stage.peta.pusat_petak(sel_catatan)
		and popup._ikon == Aset.tekstur(Aset.aksi("baca")) and popup._nama == "Catatan petunjuk")
	_cek("Panel petunjuk tertutup sebelum dibaca", not panel.visible)

	var p: Vector2 = kanvas * popup.pusat_gelembung()
	var sisa: float = _stage.sisa_detik
	_sentuh(3, p, true)
	_sentuh(3, p, false)
	await _tunggu(1.0 / FPS)
	_cek("Sentuh pop-up: panel terbuka seketika (tanpa aksi berdurasi), joystick tidak muncul",
		panel.visible and not _stage.interaksi.sibuk() and not joystick.aktif())
	var petunjuk: Array = _stage.data.petunjuk
	_cek("Panel berisi satu baris per petunjuk stage (%d)" % petunjuk.size(), panel._daftar.get_child_count() == petunjuk.size())
	await _tunggu(0.5)
	_cek("Timer tetap berjalan selama panel terbuka", _stage.sisa_detik < sisa - 0.4)

	var titik := Vector2(layar.x * 0.2, layar.y * 0.6)
	_sentuh(3, titik, true)
	await _tunggu(1.0 / FPS)
	_cek("Ketuk di mana saja: panel tertutup, joystick tidak ikut muncul", not panel.visible and not joystick.aktif())
	_sentuh(3, titik, false)

	_stage.interaksi.tekan_aksi()
	await _tunggu(1.0 / FPS)
	_cek("Catatan bisa dibaca ulang", panel.visible)
	_stage.pemain.position = _stage.peta.pusat_petak(Vector2i(4, 5))
	await _tunggu(2.0 / FPS)
	_cek("Menjauh dari catatan: panel tertutup sendiri", not panel.visible)


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
