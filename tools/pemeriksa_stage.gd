extends SceneTree
## Pemeriksa stage FindSeeds: menjalankan enam pengecekan dokumen rancangan
## (ditambah cek format) pada semua file stage.
##
## Jalankan dari root proyek:
##   tools\periksa.bat
## atau langsung:
##   godot --headless --path . --script res://tools/pemeriksa_stage.gd
##
## Opsi setelah "--":
##   --data=<folder>   folder pengaturan.json, katalog_benda.json, pembeli.json, tanaman.json (bawaan res://data)
##   --stage=<folder>  folder file stage (bawaan <data>/stage)
##
## Kode keluar: 0 jika semua lolos, 1 jika ada masalah.

const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const Pemeriksa := preload("res://scripts/inti/pemeriksa.gd")


func _initialize() -> void:
	quit(_jalankan())


func _jalankan() -> int:
	var opsi := _baca_opsi()
	print("Pemeriksa stage FindSeeds")
	print("  data : %s" % opsi.data)
	print("  stage: %s" % opsi.stage)
	print("")

	var muat := PemuatData.muat_semua(opsi.data, opsi.stage)
	if not muat.galat.is_empty():
		for g in muat.galat:
			print("[GAGAL] %s" % g)
		print("\nGAGAL: data tidak bisa dibaca, pengecekan tidak dijalankan.")
		return 1
	if muat.stage.is_empty():
		print("GAGAL: tidak ada file %s*.json di %s." % [PemuatData.AWALAN_FILE_STAGE, opsi.stage])
		return 1

	var temuan := Pemeriksa.new().periksa(muat)

	var per_file := {}
	for t in temuan:
		if not per_file.has(t.file):
			per_file[t.file] = []
		per_file[t.file].append(t)

	# File data umum lebih dulu, lalu stage sesuai urutan id.
	var urutan: Array = [PemuatData.FILE_PENGATURAN, PemuatData.FILE_KATALOG]
	for s in muat.stage:
		urutan.append(s.file)
	var stage_gagal := 0
	for f in urutan:
		var daftar: Array = per_file.get(f, [])
		if daftar.is_empty():
			if f.begins_with(PemuatData.AWALAN_FILE_STAGE):
				print("[LOLOS] %s" % f)
			continue
		if f.begins_with(PemuatData.AWALAN_FILE_STAGE):
			stage_gagal += 1
		print("[GAGAL] %s" % f)
		daftar.sort_custom(func(a, b): return a.cek < b.cek)
		for t in daftar:
			print("    Cek %d (%s): %s" % [t.cek, Pemeriksa.NAMA_CEK[t.cek], t.pesan])

	print("")
	if temuan.is_empty():
		print("LOLOS: %d stage diperiksa, semua lolos." % muat.stage.size())
		return 0
	print("GAGAL: %d stage diperiksa, %d gagal, %d masalah ditemukan." % [muat.stage.size(), stage_gagal, temuan.size()])
	return 1


func _baca_opsi() -> Dictionary:
	var opsi := {"data": PemuatData.FOLDER_DATA, "stage": ""}
	# Menerima "--data=X" maupun "--data X" (cmd.exe kadang memecah di "=").
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var bagian := args[i].split("=", true, 1)
		var nama := bagian[0].trim_prefix("--")
		if nama in opsi:
			if bagian.size() == 2:
				opsi[nama] = bagian[1]
			elif i + 1 < args.size():
				i += 1
				opsi[nama] = args[i]
		else:
			push_warning("Opsi tidak dikenal diabaikan: %s" % args[i])
		i += 1
	if opsi.stage == "":
		opsi.stage = opsi.data.path_join(PemuatData.SUBFOLDER_STAGE)
	return opsi
