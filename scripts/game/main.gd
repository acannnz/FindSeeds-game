extends Node
## Adegan utama prototipe dan alur antarstage:
## - memuat stage pertama; jika data stage bermasalah, galatnya tampil di layar;
## - menang: hitung bintang, tampilkan layar hasil (Ulangi / Lanjut);
## - waktu habis: tampilkan "Waktu habis!", lalu stage diulang dalam jeda_ulang_detik;
## - aplikasi ke latar belakang: seluruh permainan dijeda (timer ikut berhenti).
## Main berjalan dengan PROCESS_MODE_ALWAYS; stage PAUSABLE agar ikut terjeda.

const DataGame := preload("res://scripts/inti/data_game.gd")
const Bintang := preload("res://scripts/inti/bintang.gd")
const ADEGAN_STAGE := preload("res://scenes/stage.tscn")

var _indeks := 0
var _stage: Node
var _dijeda := false

@onready var layar_hasil: Control = $Lapisan/LayarHasil


func _ready() -> void:
	layar_hasil.ulangi.connect(func(): muat_stage(_indeks))
	layar_hasil.lanjut.connect(func(): muat_stage(_indeks + 1))
	if not DataGame.galat.is_empty():
		_tampilkan_galat()
		return
	muat_stage(0)


## Memuat (atau memuat ulang) stage. Indeks di luar batas berputar, jadi
## setelah stage terakhir kembali ke stage pertama.
func muat_stage(indeks: int) -> void:
	if _stage:
		_stage.free()
	_indeks = wrapi(indeks, 0, DataGame.daftar_stage.size())
	_stage = ADEGAN_STAGE.instantiate()
	_stage.process_mode = Node.PROCESS_MODE_PAUSABLE
	_stage.data = DataGame.daftar_stage[_indeks].data
	_stage.selesai.connect(_saat_selesai)
	_stage.waktu_habis.connect(_saat_waktu_habis)
	add_child(_stage)
	move_child(_stage, 0)
	layar_hasil.sembunyikan()


func stage_aktif() -> Node:
	return _stage


func _saat_selesai(sisa_detik: float) -> void:
	var bintang := Bintang.hitung(sisa_detik, _stage.data.bintang_sisa_detik)
	var terakhir := _indeks == DataGame.daftar_stage.size() - 1
	layar_hasil.tampilkan_menang(bintang, sisa_detik, "Ke awal" if terakhir else "Lanjut")


func _saat_waktu_habis() -> void:
	layar_hasil.tampilkan_waktu_habis()
	var stage_habis := _stage
	# Timer pausable: jeda ulang ikut berhenti jika aplikasi dijeda.
	await get_tree().create_timer(DataGame.pengaturan.jeda_ulang_detik, false).timeout
	if _stage == stage_habis:
		muat_stage(_indeks)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			atur_jeda(true)
		NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN:
			atur_jeda(false)


## Menjeda atau melanjutkan seluruh permainan (timer, aksi, tanaman).
func atur_jeda(jeda: bool) -> void:
	if jeda == _dijeda or _stage == null:
		return
	_dijeda = jeda
	get_tree().paused = jeda
	var sedang_main: bool = not _stage.sudah_selesai and not _stage.sudah_habis
	if not sedang_main:
		return
	if jeda:
		layar_hasil.tampilkan_jeda()
	else:
		layar_hasil.sembunyikan()


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
