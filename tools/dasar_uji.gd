extends SceneTree
## Dasar bersama skrip uji: penghitung kegagalan, pencatat galat skrip/mesin,
## dan penutup yang menentukan kode keluar. Galat yang tercatat selama uji
## dihitung sebagai kegagalan, supaya uji yang macet karena galat skrip tidak
## pernah melapor LOLOS palsu.


class PenghitungGalat extends Logger:
	var jumlah := 0
	var _kunci := Mutex.new()

	func _log_message(_pesan: String, _galat: bool) -> void:
		pass

	func _log_error(_fungsi: String, _file: String, _baris: int, _kode: String, _alasan: String,
			_beri_tahu_editor: bool, jenis_galat: int, _jejak: Array[ScriptBacktrace]) -> void:
		if jenis_galat == Logger.ERROR_TYPE_WARNING:
			return
		_kunci.lock()
		jumlah += 1
		_kunci.unlock()


## Batas waktu simulasi satu skrip uji. Galat skrip menghentikan coroutine uji
## sehingga _selesai() tidak pernah dipanggil; batas ini mencegah proses
## menggantung. Dengan --fixed-fps, waktu simulasi berjalan jauh lebih cepat
## dari waktu nyata.
const BATAS_DETIK := 120.0

var _gagal := 0
var _penghitung := PenghitungGalat.new()
## Jumlah galat dari panggilan _dengan_galat_diharapkan() terakhir.
var _galat_diharapkan := 0


func _init() -> void:
	OS.add_logger(_penghitung)
	create_timer(BATAS_DETIK, true, false, true).timeout.connect(_waktu_habis)


func _waktu_habis() -> void:
	_gagal += 1
	print("[GAGAL] Uji tidak selesai dalam %d detik (kemungkinan berhenti karena galat skrip)." % BATAS_DETIK)
	_selesai("uji")


func _cek(judul: String, lolos: bool, rincian: String = "") -> void:
	if lolos:
		print("[LOLOS] %s" % judul)
	else:
		_gagal += 1
		print("[GAGAL] %s %s" % [judul, rincian])


## Menjalankan `kerja` yang memang diharapkan mencatat galat (misalnya
## push_error untuk data yang sengaja dirusak). Galat itu tidak dihitung
## sebagai kegagalan. Mengembalikan hasil `kerja`; jumlah galat yang tercatat
## disimpan di `_galat_diharapkan`. (Lambda GDScript menyalin variabel lokal,
## jadi hasil harus dikembalikan, bukan ditulis ke variabel luar.)
func _dengan_galat_diharapkan(kerja: Callable) -> Variant:
	var awal := _penghitung.jumlah
	var hasil = kerja.call()
	_galat_diharapkan = _penghitung.jumlah - awal
	_penghitung.jumlah = awal
	return hasil


## Mencetak ringkasan dan keluar: 0 jika semua lolos, 1 jika tidak.
func _selesai(nama_uji: String) -> void:
	if _penghitung.jumlah > 0:
		_gagal += _penghitung.jumlah
		print("[GAGAL] %d galat skrip/mesin tercatat selama uji (lihat pesan di atas)." % _penghitung.jumlah)
	print("")
	if _gagal == 0:
		print("LOLOS: semua %s berhasil." % nama_uji)
	else:
		print("GAGAL: %d %s tidak sesuai harapan." % [_gagal, nama_uji])
	quit(1 if _gagal > 0 else 0)
