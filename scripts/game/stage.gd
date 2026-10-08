extends Node2D
## Satu stage yang sedang dimainkan: membangun peta dari data, menaruh pemain
## di '@', dan mengatur tata letak layar (peta di atas, kontrol di bawah).

const DataGame := preload("res://scripts/inti/data_game.gd")

## Satuan dunia per petak. Tampilan diskalakan oleh kamera agar pas di layar,
## jadi angka ini hanya satuan internal, bukan angka penyetelan.
const UKURAN_PETAK := 64.0

## Data stage (isi file stage_<id>.json). Diisi sebelum node masuk pohon.
var data: Dictionary

@onready var kamera: Camera2D = $Kamera
@onready var peta: Node2D = $Peta
@onready var pemain: CharacterBody2D = $Pemain
@onready var area_kontrol: Control = $UI/AreaKontrol
@onready var joystick: Control = $UI/AreaKontrol/Joystick
@onready var label_judul: Label = $UI/AreaKontrol/Judul


func _ready() -> void:
	peta.bangun(data, UKURAN_PETAK)
	pemain.position = peta.posisi_awal
	pemain.siapkan(UKURAN_PETAK, joystick)
	label_judul.text = "Stage %s: %s" % [data.id, data.nama]
	get_viewport().size_changed.connect(_atur_tata_letak)
	_atur_tata_letak()


## Peta mengisi bagian atas layar sebesar porsi_tinggi_peta, sisanya kontrol.
func _atur_tata_letak() -> void:
	var layar := get_viewport_rect().size
	var porsi: float = DataGame.pengaturan.porsi_tinggi_peta
	var area_peta := Vector2(layar.x, layar.y * porsi)
	area_kontrol.anchor_top = porsi

	var dunia: Vector2 = peta.ukuran_dunia()
	var skala := minf(area_peta.x / dunia.x, area_peta.y / dunia.y)
	kamera.zoom = Vector2.ONE * skala
	# Kamera berjangkar kiri atas: titik dunia di posisi kamera tampil di (0, 0).
	var sisa := (area_peta - dunia * skala) / 2.0
	kamera.position = -sisa / skala
