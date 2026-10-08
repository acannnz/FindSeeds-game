extends RefCounted
## Pesanan pembeli: berapa tiap tanaman diminta dan berapa sudah terisi.
## Hasil panen yang dipesan langsung mengisi pesanan; yang tidak dipesan,
## atau melebihi jumlah yang diminta, ditolak.

## tanaman -> jumlah diminta
var diminta: Dictionary = {}
## tanaman -> jumlah sudah terisi
var terisi: Dictionary = {}


func _init(isi_pesanan: Dictionary) -> void:
	for tanaman in isi_pesanan:
		diminta[tanaman] = int(isi_pesanan[tanaman])
		terisi[tanaman] = 0


## Menerima satu hasil panen. True jika mengisi pesanan.
func terima(tanaman: String) -> bool:
	if not diminta.has(tanaman) or terisi[tanaman] >= diminta[tanaman]:
		return false
	terisi[tanaman] += 1
	return true


func tanaman_lengkap(tanaman: String) -> bool:
	return diminta.has(tanaman) and terisi[tanaman] >= diminta[tanaman]


func lengkap() -> bool:
	for tanaman in diminta:
		if not tanaman_lengkap(tanaman):
			return false
	return true
