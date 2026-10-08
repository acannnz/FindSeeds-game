extends RefCounted
## Rekor bintang terbaik per stage, disimpan sebagai JSON di user:// supaya
## bertahan antar sesi. File yang hilang atau rusak dianggap belum ada rekor
## (tidak membuat game gagal). Penulisan lewat file sementara lalu diganti
## nama, supaya file rekor tidak setengah tertulis jika aplikasi mati.

const Bintang := preload("res://scripts/inti/bintang.gd")

const JALUR_BAWAAN := "user://rekor.json"
const VERSI := 1
const AKHIRAN_SEMENTARA := ".tmp"

var jalur: String
## id stage -> bintang terbaik
var _bintang: Dictionary = {}


func _init(jalur_file: String = JALUR_BAWAAN) -> void:
	jalur = jalur_file
	_muat()


## Bintang terbaik stage ini, 0 jika belum pernah selesai.
func bintang(id_stage: String) -> int:
	return int(_bintang.get(id_stage, 0))


## Mencatat hasil stage. True jika ini rekor baru (lebih banyak bintang
## dari sebelumnya); hanya rekor baru yang ditulis ke file.
func catat(id_stage: String, jumlah: int) -> bool:
	if jumlah <= bintang(id_stage):
		return false
	_bintang[id_stage] = clampi(jumlah, 0, Bintang.BINTANG_MAKS)
	_simpan()
	return true


func _muat() -> void:
	# Jika aplikasi mati di antara hapus dan ganti nama, hanya file sementara
	# yang tersisa; isinya sudah lengkap.
	var sumber := jalur
	if not FileAccess.file_exists(sumber):
		sumber = jalur + AKHIRAN_SEMENTARA
		if not FileAccess.file_exists(sumber):
			return
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(sumber)) != OK \
			or typeof(json.data) != TYPE_DICTIONARY or typeof(json.data.get("bintang")) != TYPE_DICTIONARY:
		push_warning("File rekor %s rusak; rekor dimulai dari kosong." % sumber)
		return
	var isi: Dictionary = json.data.bintang
	for id in isi:
		if typeof(isi[id]) == TYPE_INT or typeof(isi[id]) == TYPE_FLOAT:
			_bintang[str(id)] = clampi(int(isi[id]), 0, Bintang.BINTANG_MAKS)


func _simpan() -> void:
	var sementara := jalur + AKHIRAN_SEMENTARA
	var file := FileAccess.open(sementara, FileAccess.WRITE)
	if file == null:
		push_warning("Rekor tidak bisa disimpan ke %s: %s" % [sementara, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify({"versi": VERSI, "bintang": _bintang}, "  "))
	file.close()
	if FileAccess.file_exists(jalur):
		DirAccess.remove_absolute(jalur)
	var galat := DirAccess.rename_absolute(sementara, jalur)
	if galat != OK:
		push_warning("Rekor tidak bisa disimpan ke %s: %s" % [jalur, error_string(galat)])
