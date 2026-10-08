extends "res://tools/dasar_uji.gd"
## Uji plugin editor addons/pemeriksa_stage (logikanya di penjaga_build.gd,
## karena EditorPlugin hanya bisa dibuat editor): Run dibatalkan jika ada stage
## yang salah, dan export melaporkan masalahnya. Memakai salinan stage yang
## sengaja dirusak di user://, data asli tidak disentuh.
##
## Jalankan dari root proyek:
##   tools\periksa.bat --uji-plugin

const PenjagaBuild := preload("res://addons/pemeriksa_stage/penjaga_build.gd")
const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const FOLDER_RUSAK := "user://uji_plugin_stage"


func _initialize() -> void:
	var plugin := PenjagaBuild.new()

	_cek("Data asli: pemeriksa plugin tidak menemukan masalah", plugin.periksa().is_empty())
	var boleh_jalan: bool = _dengan_galat_diharapkan(plugin.boleh_jalan)
	_cek("Data asli: Run diizinkan tanpa galat", boleh_jalan and _galat_diharapkan == 0)

	_siapkan_stage_rusak()
	plugin.folder_stage = FOLDER_RUSAK
	var pesan: Array[String] = plugin.periksa()
	_cek("Stage rusak: masalah ditemukan", pesan.size() == 1 and "jagung" in pesan[0], str(pesan))
	boleh_jalan = _dengan_galat_diharapkan(plugin.boleh_jalan)
	_cek("Stage rusak: Run dibatalkan", not boleh_jalan)
	_cek("Stage rusak: masalah dilaporkan sebagai galat di Output", _galat_diharapkan >= 2, "galat %d" % _galat_diharapkan)

	var lolos_export: bool = _dengan_galat_diharapkan(plugin.saat_export)
	_cek("Stage rusak: export melaporkan masalah", not lolos_export and _galat_diharapkan >= 2, "galat %d" % _galat_diharapkan)

	plugin.folder_stage = ""
	lolos_export = _dengan_galat_diharapkan(plugin.saat_export)
	_cek("Data asli: export berjalan tanpa galat", lolos_export and _galat_diharapkan == 0)

	_hapus_stage_rusak()
	_selesai("uji plugin")


## Salinan semua stage, dengan pesanan 1-2 meminta jagung yang tidak ada sumbernya.
func _siapkan_stage_rusak() -> void:
	_hapus_stage_rusak()
	DirAccess.make_dir_recursive_absolute(FOLDER_RUSAK)
	var asal := PemuatData.FOLDER_DATA.path_join(PemuatData.SUBFOLDER_STAGE)
	for f in DirAccess.get_files_at(asal):
		if not f.ends_with(".json"):
			continue
		var teks := FileAccess.get_file_as_string(asal.path_join(f))
		if f == "stage_1-2.json":
			teks = teks.replace("\"wortel\": 1", "\"wortel\": 1, \"jagung\": 1")
		var tulis := FileAccess.open(FOLDER_RUSAK.path_join(f), FileAccess.WRITE)
		tulis.store_string(teks)
		tulis.close()


func _hapus_stage_rusak() -> void:
	if not DirAccess.dir_exists_absolute(FOLDER_RUSAK):
		return
	for f in DirAccess.get_files_at(FOLDER_RUSAK):
		DirAccess.remove_absolute(FOLDER_RUSAK.path_join(f))
	DirAccess.remove_absolute(FOLDER_RUSAK)
