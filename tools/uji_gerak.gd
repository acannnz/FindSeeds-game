extends "res://tools/dasar_uji.gd"
## Uji gerak dan tabrakan: memuat stage sungguhan, menggerakkan pemain lewat
## `arah_paksa`, dan memeriksa posisi akhirnya.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-gerak
## atau:
##   godot --headless --fixed-fps 60 --path . --script res://tools/uji_gerak.gd

const ADEGAN_STAGE := preload("res://scenes/stage.tscn")
const DataGame := preload("res://scripts/inti/data_game.gd")

## Toleransi posisi, sebagai porsi ukuran petak.
const TOLERANSI_PETAK := 0.1
## Jarak ke titik tujuan yang dianggap sudah sampai, sebagai porsi ukuran petak.
const SAMPAI_PETAK := 0.1
const FPS := 60

var _u: float


func _initialize() -> void:
	_jalankan()


func _jalankan() -> void:
	# Pohon adegan baru siap setelah _initialize; tunggu satu frame.
	await process_frame
	if not DataGame.galat.is_empty():
		print("GAGAL: data stage bermasalah, jalankan tools\\periksa.bat.")
		quit(1)
		return
	var p: Dictionary = DataGame.pengaturan

	var stage := await _muat("1-1")
	_u = stage.UKURAN_PETAK
	var r: float = p.radius_pemain_petak * _u
	var pemain: CharacterBody2D = stage.pemain
	# Kolom 4 dari baris 9 ke atas kosong di 1-1.
	pemain.position = stage.peta.pusat_petak(Vector2i(4, 9))
	await physics_frame
	var awal := pemain.position

	await _gerak(pemain, Vector2.UP, 0.5)
	var harapan: float = p.kecepatan_jalan_petak_per_detik * 0.5 * _u
	_cek("Kecepatan: 0,5 detik ke atas = %.1f petak" % (harapan / _u),
		absf(awal.y - pemain.position.y - harapan) < TOLERANSI_PETAK * _u,
		"bergerak %.2f petak" % ((awal.y - pemain.position.y) / _u))

	stage = await _muat("1-1")
	pemain = stage.pemain
	await _gerak(pemain, Vector2.LEFT, 0.5)
	_cek("Dinding kiri menahan pemain (1-1)", pemain.position.x >= _u + r - 1.0,
		"x = %.2f petak" % (pemain.position.x / _u))

	pemain.position = stage.peta.pusat_petak(Vector2i(4, 9))
	await physics_frame
	await _gerak(pemain, Vector2.RIGHT, 1.0)
	_cek("Penghalang rumah 'R' menahan pemain (1-1)", pemain.position.x <= 5.0 * _u - r + 1.0,
		"x = %.2f petak" % (pemain.position.x / _u))

	stage = await _muat("1-1")
	pemain = stage.pemain
	# Pembeli di (1,1); dekati dari kanan.
	pemain.position = stage.peta.pusat_petak(Vector2i(2, 1))
	await physics_frame
	await _gerak(pemain, Vector2.LEFT, 1.0)
	_cek("Pembeli 'B' padat (1-1)", pemain.position.x >= 2.0 * _u + r - 1.0,
		"x = %.2f petak" % (pemain.position.x / _u))

	stage = await _muat("1-3")
	pemain = stage.pemain
	await _gerak(pemain, Vector2.RIGHT, 0.5)
	_cek("Benda 'Q' padat (1-3)", pemain.position.x <= 2.0 * _u - r + 1.0,
		"x = %.2f petak" % (pemain.position.x / _u))

	stage = await _muat("1-3")
	pemain = stage.pemain
	var rute: Array[Vector2] = [Vector2(1.5, 9.5), Vector2(4.5, 9.5), Vector2(4.5, 5.5), Vector2(3.5, 2.5)]
	var sampai := await _ikuti_rute(pemain, rute, 6.0)
	_cek("Lewat celah dinding ke ruang atas (1-3)", sampai,
		"berhenti di petak %s" % str((pemain.position / _u).floor()))

	_selesai("uji gerak")


func _muat(id: String) -> Node:
	for anak in root.get_children():
		if anak.name == "StageUji":
			anak.free()
	var stage := ADEGAN_STAGE.instantiate()
	stage.name = "StageUji"
	stage.data = DataGame.stage_dengan_id(id)
	root.add_child(stage)
	await physics_frame
	return stage


func _gerak(pemain: CharacterBody2D, arah: Vector2, detik: float) -> void:
	pemain.arah_paksa = arah
	for i in int(detik * FPS):
		await physics_frame
	pemain.arah_paksa = Vector2.ZERO
	await physics_frame


## Mengarahkan pemain ke tiap titik rute (koordinat petak). True jika semua tercapai.
func _ikuti_rute(pemain: CharacterBody2D, rute: Array[Vector2], batas_detik: float) -> bool:
	var sisa_frame := int(batas_detik * FPS)
	for titik in rute:
		var tujuan := titik * _u
		while pemain.position.distance_to(tujuan) > SAMPAI_PETAK * _u:
			if sisa_frame <= 0:
				pemain.arah_paksa = Vector2.ZERO
				return false
			pemain.arah_paksa = (tujuan - pemain.position).normalized()
			sisa_frame -= 1
			await physics_frame
	pemain.arah_paksa = Vector2.ZERO
	return true
