extends "res://tools/dasar_uji.gd"
## Uji aset gambar: semua aset yang dibutuhkan data ada dan bisa dimuat,
## konvensi nama file benar, cadangan placeholder bekerja, dan penghalang
## bersambung tergambar sebagai satu blok.
##
## Jalankan dari root proyek (setelah aset diimpor Godot):
##   tools\periksa.bat --uji-aset

const ADEGAN_STAGE := preload("res://scenes/stage.tscn")
const DataGame := preload("res://scripts/inti/data_game.gd")
const Aset := preload("res://scripts/inti/aset.gd")


func _initialize() -> void:
	_jalankan()


func _jalankan() -> void:
	await process_frame
	var data := DataGame.sebagai_data()
	var butuh := Aset.kebutuhan(data)
	var hilang := Aset.hilang(data)
	_cek("Semua %d aset yang dibutuhkan data ada" % butuh.size(), hilang.is_empty(), str(hilang))

	var gagal_muat: Array[String] = []
	for j in butuh:
		if Aset.tekstur(j) == null:
			gagal_muat.append(j)
	_cek("Semua aset bisa dimuat sebagai tekstur (sudah diimpor Godot)", gagal_muat.is_empty(),
		"%d gagal, contoh %s. Jalankan: godot --headless --path . --import" % [gagal_muat.size(), gagal_muat.slice(0, 3)])

	_cek("Kolom \"gambar\" di katalog dipakai: kardus MAINAN dan SEPATU berbagi kardus.svg",
		Aset.benda("kardus_mainan", DataGame.entri_benda("kardus_mainan")) == "res://aset/benda/kardus.svg"
		and Aset.benda("kardus_sepatu", DataGame.entri_benda("kardus_sepatu")) == "res://aset/benda/kardus.svg")
	_cek("Aset yang tidak ada mengembalikan null tanpa galat (cadangan kotak warna)",
		Aset.tekstur("res://aset/benda/belum_ada.svg") == null)

	var stage := ADEGAN_STAGE.instantiate()
	stage.data = DataGame.stage_dengan_id("1-1")
	root.add_child(stage)
	await process_frame
	var blok: Array = stage.peta._blok_penghalang
	var u: float = stage.UKURAN_PETAK
	_cek("Rumah 2x4 petak di 1-1 digambar sebagai satu blok bertekstur",
		blok.size() == 1 and blok[0].kotak.size == Vector2(2, 4) * u and blok[0].tekstur != null,
		"blok: %s" % str(blok.map(func(b): return b.kotak)))
	_cek("Pemain memakai gambar 4 arah", stage.pemain._tekstur.size() == 4 and not stage.pemain._tekstur.values().has(null))
	stage.pemain.hadap = Vector2.LEFT
	_cek("Hadap kiri memakai gambar pemain_kiri", stage.pemain.arah_gambar() == "kiri")
	stage.free()

	_selesai("uji aset")
