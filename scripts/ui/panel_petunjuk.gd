extends Control
## Panel catatan petunjuk: dibuka lewat aksi "Baca" di catatan samping lahan,
## berisi teka-teki benda sumber tiap pesanan (kolom `petunjuk` file stage).
## Petunjuk tidak menyebut posisi, warna, atau jenis benda; hanya tanaman
## yang akan dihasilkan. Timer tetap berjalan selama panel terbuka. Ditutup
## dengan ketukan di mana saja, Spasi/Enter/Esc, atau saat pemain menjauh
## (diatur stage.gd). Bisa dibuka ulang kapan saja dari catatan.

const DataGame := preload("res://scripts/inti/data_game.gd")

const WARNA_REDUP := Color(0, 0, 0, 0.45)
const WARNA_KERTAS := Color("#fff8e1")
const WARNA_TEPI := Color("#8d6e63")
const WARNA_JUDUL := Color("#4e342e")
const WARNA_TEKS := Color("#3e2723")
const WARNA_SAMAR := Color("#8d6e63")
const LEBAR_KARTU := 600.0
const SELA := 28.0
const UKURAN_JUDUL := 34
const UKURAN_TEKS := 27
const UKURAN_SAMAR := 20
const SISI_TITIK := 18.0

var _daftar: VBoxContainer
## Frame saat panel dibuka: ketukan yang membukanya (lewat pop-up) diabaikan.
var _frame_buka := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var redup := ColorRect.new()
	redup.color = WARNA_REDUP
	redup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	redup.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(redup)
	var tengah := CenterContainer.new()
	tengah.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tengah.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(tengah)
	var kartu := PanelContainer.new()
	kartu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kartu.custom_minimum_size.x = LEBAR_KARTU
	var gaya := StyleBoxFlat.new()
	gaya.bg_color = WARNA_KERTAS
	gaya.border_color = WARNA_TEPI
	gaya.set_border_width_all(4)
	gaya.set_corner_radius_all(18)
	gaya.set_content_margin_all(SELA)
	kartu.add_theme_stylebox_override("panel", gaya)
	tengah.add_child(kartu)
	var isi := VBoxContainer.new()
	isi.add_theme_constant_override("separation", 18)
	kartu.add_child(isi)
	isi.add_child(_label("Catatan petunjuk", UKURAN_JUDUL, WARNA_JUDUL, HORIZONTAL_ALIGNMENT_CENTER))
	_daftar = VBoxContainer.new()
	_daftar.add_theme_constant_override("separation", 14)
	isi.add_child(_daftar)
	isi.add_child(_label("Ketuk di mana saja untuk menutup", UKURAN_SAMAR, WARNA_SAMAR, HORIZONTAL_ALIGNMENT_CENTER))
	hide()


## petunjuk: isi kolom `petunjuk` stage, Array of {"benda", "teks"}.
func tampilkan(petunjuk: Array) -> void:
	for anak in _daftar.get_children():
		anak.free()
	for i in petunjuk.size():
		var tanaman: String = DataGame.entri_benda(petunjuk[i].benda).get("hasil", "")
		var baris := HBoxContainer.new()
		baris.add_theme_constant_override("separation", 12)
		var titik := ColorRect.new()
		titik.color = DataGame.warna_tanaman(tanaman)
		titik.custom_minimum_size = Vector2.ONE * SISI_TITIK
		titik.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		baris.add_child(titik)
		var teks := "%d. Benih %s: %s" % [i + 1, DataGame.nama_tanaman(tanaman).to_lower(), petunjuk[i].teks]
		var label := _label(teks, UKURAN_TEKS, WARNA_TEKS, HORIZONTAL_ALIGNMENT_LEFT)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		baris.add_child(label)
		_daftar.add_child(baris)
	_frame_buka = Engine.get_process_frames()
	show()


func tutup() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if not visible or Engine.get_process_frames() == _frame_buka:
		return
	if (event is InputEventScreenTouch and event.pressed) or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		# Ditunda: joystick memeriksa `visible` pada sentuhan yang sama dan
		# harus tetap menolaknya.
		hide.call_deferred()


func _label(teks: String, ukuran: int, warna: Color, rata: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = teks
	label.horizontal_alignment = rata
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", ukuran)
	label.add_theme_color_override("font_color", warna)
	return label
