extends Control
## Layar di atas stage: hasil menang (bintang, sisa waktu, Ulangi/Lanjut),
## "Waktu habis!" sebelum stage diulang otomatis, dan "Dijeda" saat aplikasi
## pindah ke latar belakang.

signal ulangi
signal lanjut

@onready var _judul: Label = $Kotak/Judul
@onready var _bintang: Control = $Kotak/Bintang
@onready var _info: Label = $Kotak/Info
@onready var _rekor: Label = $Kotak/Rekor
@onready var _tombol: Control = $Kotak/Tombol
@onready var _tombol_lanjut: Button = $Kotak/Tombol/Lanjut


func _ready() -> void:
	$Kotak/Tombol/Ulangi.pressed.connect(ulangi.emit)
	_tombol_lanjut.pressed.connect(lanjut.emit)
	sembunyikan()


## rekor: bintang terbaik setelah hasil ini dicatat; rekor_baru: hasil ini memecahkannya.
func tampilkan_menang(bintang: int, sisa_detik: float, teks_lanjut: String, rekor: int, rekor_baru: bool) -> void:
	_judul.text = "Pesanan lengkap!"
	_bintang.jumlah = bintang
	_bintang.show()
	_info.text = "Sisa waktu %d detik" % floori(sisa_detik)
	_info.show()
	_rekor.text = "Rekor baru!" if rekor_baru else "Rekor: %d bintang" % rekor
	_rekor.show()
	_tombol_lanjut.text = teks_lanjut
	_tombol.show()
	show()


func tampilkan_waktu_habis() -> void:
	_tampilkan_pesan("Waktu habis!")


func tampilkan_jeda() -> void:
	_tampilkan_pesan("Dijeda")


func sembunyikan() -> void:
	hide()


func sedang_tampil() -> bool:
	return visible


func judul() -> String:
	return _judul.text


func teks_rekor() -> String:
	return _rekor.text if _rekor.visible else ""


func jumlah_bintang() -> int:
	return _bintang.jumlah if _bintang.visible else 0


func _tampilkan_pesan(teks: String) -> void:
	_judul.text = teks
	_bintang.hide()
	_info.hide()
	_rekor.hide()
	_tombol.hide()
	show()
