@tool
extends RefCounted
## Logika plugin pemeriksa stage, terpisah dari EditorPlugin supaya bisa diuji
## dari command line (EditorPlugin hanya bisa dibuat oleh editor).

const Pemeriksa := preload("res://scripts/inti/pemeriksa.gd")
const AWALAN := "Pemeriksa stage: "

## Folder stage yang diperiksa; kosong = data/stage. Diganti oleh skrip uji.
var folder_stage := ""


func periksa() -> Array[String]:
	return Pemeriksa.periksa_folder(Pemeriksa.PemuatData.FOLDER_DATA, folder_stage)


## Sebelum Run dari editor. False = game tidak boleh dijalankan.
func boleh_jalan() -> bool:
	var pesan := periksa()
	if pesan.is_empty():
		print(AWALAN + "semua stage lolos.")
		return true
	laporkan("Game tidak dijalankan karena ada stage yang salah.", pesan)
	return false


## Di awal export. Godot tidak mengizinkan plugin membatalkan export, jadi
## masalah hanya bisa dilaporkan. Mengembalikan true jika semua lolos.
func saat_export() -> bool:
	var pesan := periksa()
	if pesan.is_empty():
		print(AWALAN + "semua stage lolos, export dilanjutkan.")
		return true
	laporkan("Ada stage yang salah. Godot tidak mengizinkan plugin membatalkan export, "
		+ "jadi hasil export ini akan menampilkan layar galat data saat dibuka. "
		+ "Perbaiki stage lalu export ulang, atau pakai tools\\build_android.bat.", pesan)
	return false


## Mencetak tiap masalah ke Output sebagai galat dan, di editor, menampilkan dialog.
func laporkan(judul: String, pesan: Array[String]) -> void:
	push_error(AWALAN + judul)
	for p in pesan:
		push_error(AWALAN + p)
	if not Engine.is_editor_hint() or DisplayServer.get_name() == "headless":
		return
	var dialog := AcceptDialog.new()
	dialog.title = "Pemeriksa stage: %d masalah" % pesan.size()
	dialog.dialog_text = "%s\n\n%s\n\nJalankan tools\\periksa.bat untuk laporan lengkap." % [judul, "\n".join(pesan)]
	dialog.dialog_autowrap = true
	dialog.min_size = Vector2i(720, 0)
	dialog.visibility_changed.connect(func():
		if not dialog.visible:
			dialog.queue_free())
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered()
