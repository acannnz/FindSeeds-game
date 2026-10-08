@tool
extends EditorPlugin
## Menjalankan pemeriksa stage (enam pengecekan dokumen + cek format) setiap
## kali "build" dari editor:
## - Run (F5/F6): jika ada stage yang salah, game TIDAK dijalankan dan
##   masalahnya tampil di dialog serta panel Output.
## - Export: Godot tidak mengizinkan plugin membatalkan export, jadi masalah
##   dilaporkan dengan galat dan dialog. Game hasil export juga menolak mulai
##   dengan data rusak (layar galat dari main.gd). Untuk build yang benar-benar
##   berhenti saat stage salah, pakai tools\build_android.bat.
## Logikanya ada di penjaga_build.gd (diuji tools/uji_plugin.gd).

const PenjagaBuild := preload("res://addons/pemeriksa_stage/penjaga_build.gd")

var _penjaga := PenjagaBuild.new()
var _ekspor: PemeriksaEkspor


func _enter_tree() -> void:
	_ekspor = PemeriksaEkspor.new()
	_ekspor.penjaga = _penjaga
	add_export_plugin(_ekspor)


func _exit_tree() -> void:
	remove_export_plugin(_ekspor)
	_ekspor = null


## Dipanggil editor sebelum game dijalankan. False = run dibatalkan.
func _build() -> bool:
	return _penjaga.boleh_jalan()


class PemeriksaEkspor extends EditorExportPlugin:
	var penjaga: RefCounted

	func _get_name() -> String:
		return "PemeriksaStage"

	func _export_begin(_fitur: PackedStringArray, _debug: bool, _jalur: String, _bendera: int) -> void:
		penjaga.saat_export()
