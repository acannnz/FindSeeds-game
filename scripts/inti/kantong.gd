extends RefCounted
## Kantong benih: kapasitas tetap, urutan masuk dipertahankan (FIFO).
## Benih tidak bisa dibuang; satu-satunya cara keluar adalah ditanam.

var kapasitas: int
## Id tanaman tiap benih, dari yang paling lama ke paling baru.
var isi: Array[String] = []


func _init(kapasitas_kantong: int) -> void:
	kapasitas = kapasitas_kantong


func penuh() -> bool:
	return isi.size() >= kapasitas


func kosong() -> bool:
	return isi.is_empty()


## Menambah benih. False jika kantong penuh.
func tambah(tanaman: String) -> bool:
	if penuh():
		return false
	isi.append(tanaman)
	return true


## Benih yang akan ditanam berikutnya (paling lama), atau "" jika kosong.
func berikutnya() -> String:
	return "" if isi.is_empty() else isi[0]


## Mengeluarkan benih paling lama untuk ditanam, atau "" jika kosong.
func ambil() -> String:
	return "" if isi.is_empty() else isi.pop_front()
