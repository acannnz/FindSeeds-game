extends RefCounted
## Data game bersama: pengaturan, katalog, pembeli, tanaman, tema, dan semua stage. Dimuat
## sekali saat skrip ini pertama kali dipakai, lalu divalidasi pemeriksa stage.
##
## Pakai lewat preload, bukan autoload, supaya juga bisa dipakai skrip uji
## yang dijalankan dengan --script:
##   const DataGame := preload("res://scripts/inti/data_game.gd")
##   DataGame.pengaturan.kapasitas_kantong

const PemuatData := preload("res://scripts/inti/pemuat_data.gd")
const Pemeriksa := preload("res://scripts/inti/pemeriksa.gd")

static var pengaturan: Dictionary = {}
static var katalog: Dictionary = {}
static var pembeli: Dictionary = {}
static var tanaman: Dictionary = {}
static var tema: Dictionary = {}
## Array berisi {"file", "data"}, urut menurut id stage.
static var daftar_stage: Array = []
## Pesan galat pemuatan dan temuan pemeriksa. Kosong berarti data sehat.
static var galat: Array[String] = []


static func _static_init() -> void:
	var muat := PemuatData.muat_semua()
	pengaturan = muat.pengaturan
	katalog = muat.katalog
	pembeli = muat.pembeli
	tanaman = muat.tanaman
	tema = muat.tema
	daftar_stage = muat.stage
	galat.assign(muat.galat)
	if galat.is_empty():
		for t in Pemeriksa.new().periksa(muat):
			galat.append(Pemeriksa.format_temuan(t))
	for g in galat:
		push_error(g)


## Data dalam bentuk kamus seperti hasil PemuatData.muat_semua().
static func sebagai_data() -> Dictionary:
	return {"pengaturan": pengaturan, "katalog": katalog, "pembeli": pembeli,
		"tanaman": tanaman, "tema": tema, "stage": daftar_stage}


static func stage_dengan_id(id: String) -> Dictionary:
	for s in daftar_stage:
		if s.data.id == id:
			return s.data
	return {}


static func entri_benda(id: String) -> Dictionary:
	return katalog.get(id, {})


static func nama_benda(id: String) -> String:
	return str(entri_benda(id).get("nama", id))


static func nama_tanaman(id: String) -> String:
	return str(tanaman.get(id, {}).get("nama", id))


static func warna_tanaman(id: String) -> Color:
	return Color(tanaman.get(id, {}).get("warna", "#ffffff"))


static func durasi(aksi: String) -> float:
	return float(pengaturan.durasi_detik[aksi])
