extends RefCounted
## Aturan tombol aksi kontekstual: dari keadaan target terdekat dan bawaan
## pemain, tentukan aksi apa yang ditawarkan dan apakah bisa ditekan.
## Logika murni, diuji oleh tools/uji_logika.gd.

const PemuatData := preload("res://scripts/inti/pemuat_data.gd")

const AKSI_TIDAK_ADA := ""
const AKSI_IDENTIFIKASI := "identifikasi"
const AKSI_AMBIL := "ambil"
const AKSI_POTONG := "potong"
const AKSI_TANAM := "tanam"
const AKSI_PANEN := "panen"

const LABEL := {
	AKSI_IDENTIFIKASI: "Periksa",
	AKSI_AMBIL: "Ambil",
	AKSI_POTONG: "Potong",
	AKSI_TANAM: "Tanam",
	AKSI_PANEN: "Panen",
}

## Kunci durasi di pengaturan.durasi_detik untuk tiap aksi.
const KUNCI_DURASI := {
	AKSI_IDENTIFIKASI: "identifikasi",
	AKSI_AMBIL: "ambil_alat",
	AKSI_POTONG: "pakai_alat",
	AKSI_TANAM: "tanam",
	AKSI_PANEN: "panen",
}

## Status benda di peta.
const STATUS_NORMAL := "normal"
## Benda kosong yang sudah diidentifikasi: abu-abu, tidak bisa dicoba lagi.
const STATUS_ABU := "abu"

## Status petak tanah.
const TANAH_KOSONG := "kosong"
const TANAH_TUMBUH := "tumbuh"
const TANAH_MATANG := "matang"

const ALASAN_KANTONG_PENUH := "Kantong penuh"

## Jenis benda yang namanya dirahasiakan sampai diperiksa: pemain harus
## menebak dari gambar saja (keputusan pengguna).
const JENIS_RAHASIA := [PemuatData.JENIS_SUMBER, PemuatData.JENIS_KOSONG, PemuatData.JENIS_HIASAN]


## Aksi untuk satu petak tanah. Petak kosong tanpa benih di kantong dan
## tanaman yang masih tumbuh tidak menawarkan aksi, supaya tidak menutupi
## benda di sebelahnya.
static func untuk_tanah(status: String, ada_benih: bool) -> Dictionary:
	match status:
		TANAH_KOSONG:
			return _hasil(AKSI_TANAM if ada_benih else AKSI_TIDAK_ADA)
		TANAH_MATANG:
			return _hasil(AKSI_PANEN)
	return _hasil(AKSI_TIDAK_ADA)


## Aksi untuk satu benda.
## entri: entri katalog benda; status: STATUS_*; kantong_penuh: bool;
## alat_di_tangan: id alat yang dipegang atau "".
## Mengembalikan {"aksi", "label", "aktif": bool, "alasan": String, "butuh_alat": String}.
static func untuk_benda(entri: Dictionary, status: String, kantong_penuh: bool, alat_di_tangan: String) -> Dictionary:
	if status == STATUS_ABU:
		return _hasil(AKSI_TIDAK_ADA)
	match PemuatData.jenis_benda(entri):
		PemuatData.JENIS_ALAT:
			return _hasil(AKSI_AMBIL)
		PemuatData.JENIS_WADAH:
			var butuh: String = entri.butuh_alat
			if alat_di_tangan == butuh:
				return _hasil(AKSI_POTONG)
			var hasil := _hasil(AKSI_POTONG, false, "Butuh alat")
			hasil.butuh_alat = butuh
			return hasil
		PemuatData.JENIS_SUMBER, PemuatData.JENIS_KOSONG, PemuatData.JENIS_HIASAN:
			# Saat kantong penuh semua benda dikunci, supaya tombol tidak
			# membocorkan mana yang sumber benih (keputusan pengguna).
			if kantong_penuh:
				return _hasil(AKSI_IDENTIFIKASI, false, ALASAN_KANTONG_PENUH)
			return _hasil(AKSI_IDENTIFIKASI)
	return _hasil(AKSI_TIDAK_ADA)


static func _hasil(aksi: String, aktif: bool = true, alasan: String = "") -> Dictionary:
	return {
		"aksi": aksi,
		"label": LABEL.get(aksi, ""),
		"aktif": aktif and aksi != AKSI_TIDAK_ADA,
		"alasan": alasan,
		"butuh_alat": "",
	}
