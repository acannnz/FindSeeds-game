extends RefCounted
## Memuat file data JSON (pengaturan, katalog, pembeli, tanaman, stage).
## Logika murni tanpa Node: dipakai oleh game dan oleh pemeriksa stage.

const FOLDER_DATA := "res://data"
const FILE_PENGATURAN := "pengaturan.json"
const FILE_KATALOG := "katalog_benda.json"
const FILE_PEMBELI := "pembeli.json"
const FILE_TANAMAN := "tanaman.json"
const SUBFOLDER_STAGE := "stage"
const AWALAN_FILE_STAGE := "stage_"

# Simbol umum peta. Dibaca langsung oleh pemuat dan tidak masuk legenda.
const SIMBOL_DINDING := "#"
const SIMBOL_LANTAI := "."
const SIMBOL_PEMAIN := "@"
const SIMBOL_TANAH := "T"
const SIMBOL_PEMBELI := "B"
const SIMBOL_UMUM := [SIMBOL_DINDING, SIMBOL_LANTAI, SIMBOL_PEMAIN, SIMBOL_TANAH, SIMBOL_PEMBELI]
# Petak yang bisa diinjak pemain. Benda dan pembeli padat.
const SIMBOL_BISA_DIINJAK := [SIMBOL_LANTAI, SIMBOL_PEMAIN, SIMBOL_TANAH]

const JENIS_SUMBER := "sumber"
const JENIS_KOSONG := "kosong"
const JENIS_WADAH := "wadah"
const JENIS_ALAT := "alat"
const JENIS_PENGHALANG := "penghalang"
const JENIS_TIDAK_DIKENAL := "tidak_dikenal"


## Membaca satu file JSON. Mengembalikan {"data": Variant, "galat": String};
## "galat" kosong berarti berhasil.
static func baca_json(jalur: String) -> Dictionary:
	if not FileAccess.file_exists(jalur):
		return {"data": null, "galat": "file tidak ditemukan: %s" % jalur}
	var teks := FileAccess.get_file_as_string(jalur)
	var json := JSON.new()
	if json.parse(teks) != OK:
		return {"data": null, "galat": "JSON tidak valid di %s baris %d: %s" % [jalur, json.get_error_line(), json.get_error_message()]}
	return {"data": json.data, "galat": ""}


## Membaca pengaturan, katalog, pembeli, tanaman, dan semua stage sekaligus.
## Mengembalikan {"pengaturan", "katalog", "pembeli", "tanaman", "stage", "galat": Array[String]}.
static func muat_semua(folder_data: String = FOLDER_DATA, folder_stage: String = "") -> Dictionary:
	if folder_stage == "":
		folder_stage = folder_data.path_join(SUBFOLDER_STAGE)
	var hasil := {"pengaturan": {}, "katalog": {}, "pembeli": {}, "tanaman": {}, "stage": [], "galat": []}
	for pasangan in [["pengaturan", FILE_PENGATURAN], ["katalog", FILE_KATALOG], ["pembeli", FILE_PEMBELI], ["tanaman", FILE_TANAMAN]]:
		var baca := baca_json(folder_data.path_join(pasangan[1]))
		if baca.galat != "":
			hasil.galat.append(baca.galat)
		elif typeof(baca.data) != TYPE_DICTIONARY:
			hasil.galat.append("%s: isi file harus berupa objek JSON" % pasangan[1])
		else:
			hasil[pasangan[0]] = baca.data
	var stage := muat_semua_stage(folder_stage)
	hasil.stage = stage.stage
	hasil.galat.append_array(stage.galat)
	return hasil


## Membaca semua file stage di folder, diurutkan menurut id (musim, nomor).
## Mengembalikan {"stage": Array[{"file", "data"}], "galat": Array[String]}.
static func muat_semua_stage(folder: String) -> Dictionary:
	var hasil := {"stage": [], "galat": []}
	var dir := DirAccess.open(folder)
	if dir == null:
		hasil.galat.append("folder stage tidak bisa dibuka: %s" % folder)
		return hasil
	var nama_file: Array[String] = []
	for f in dir.get_files():
		if f.begins_with(AWALAN_FILE_STAGE) and f.ends_with(".json"):
			nama_file.append(f)
	for f in nama_file:
		var baca := baca_json(folder.path_join(f))
		if baca.galat != "":
			hasil.galat.append(baca.galat)
		elif typeof(baca.data) != TYPE_DICTIONARY:
			hasil.galat.append("%s: isi file harus berupa objek JSON" % f)
		else:
			hasil.stage.append({"file": f, "data": baca.data})
	hasil.stage.sort_custom(func(a, b): return _bandingkan_id(a.data.get("id", ""), b.data.get("id", "")))
	return hasil


## Memecah id "musim-nomor" menjadi [musim, nomor]. Kosong jika format salah.
static func pecah_id(id: Variant) -> Array:
	if typeof(id) != TYPE_STRING:
		return []
	var bagian: PackedStringArray = id.split("-")
	if bagian.size() != 2 or not bagian[0].is_valid_int() or not bagian[1].is_valid_int():
		return []
	return [bagian[0].to_int(), bagian[1].to_int()]


static func _bandingkan_id(a: Variant, b: Variant) -> bool:
	var pa := pecah_id(a)
	var pb := pecah_id(b)
	if pa.is_empty() or pb.is_empty():
		return str(a) < str(b)
	if pa[0] != pb[0]:
		return pa[0] < pb[0]
	return pa[1] < pb[1]


## Menyimpulkan jenis benda dari isi entri katalog.
static func jenis_benda(entri: Variant) -> String:
	if typeof(entri) != TYPE_DICTIONARY:
		return JENIS_TIDAK_DIKENAL
	match entri.get("jenis", ""):
		JENIS_ALAT:
			return JENIS_ALAT
		JENIS_PENGHALANG:
			return JENIS_PENGHALANG
	if entri.has("butuh_alat"):
		return JENIS_WADAH
	if entri.has("hasil"):
		return JENIS_KOSONG if entri.hasil == null else JENIS_SUMBER
	return JENIS_TIDAK_DIKENAL
