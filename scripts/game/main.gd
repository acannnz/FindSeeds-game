extends Node
## Adegan utama prototipe: memuat stage pertama. Jika data stage bermasalah,
## menampilkan galatnya di layar alih-alih memulai permainan.
## Alur antarstage (menang, kalah, lanjut) ditambahkan di fase 7.

const DataGame := preload("res://scripts/inti/data_game.gd")
const ADEGAN_STAGE := preload("res://scenes/stage.tscn")

var _indeks := 0
var _stage: Node


func _ready() -> void:
	if not DataGame.galat.is_empty():
		_tampilkan_galat()
		return
	muat_stage(0)


func muat_stage(indeks: int) -> void:
	if _stage:
		_stage.queue_free()
	_indeks = wrapi(indeks, 0, DataGame.daftar_stage.size())
	_stage = ADEGAN_STAGE.instantiate()
	_stage.data = DataGame.daftar_stage[_indeks].data
	add_child(_stage)


## Pintasan pengembang (hanya build debug): 1–9 pilih stage, R ulang stage.
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode >= KEY_1 and event.keycode <= KEY_9:
		var i: int = event.keycode - KEY_1
		if i < DataGame.daftar_stage.size():
			muat_stage(i)
	elif event.keycode == KEY_R:
		muat_stage(_indeks)


func _tampilkan_galat() -> void:
	var label := Label.new()
	label.text = "Data stage bermasalah. Jalankan tools\\periksa.bat untuk detail.\n\n" + "\n".join(DataGame.galat)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color("#ff5252"))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 24)
	var lapisan := CanvasLayer.new()
	lapisan.add_child(label)
	add_child(lapisan)
