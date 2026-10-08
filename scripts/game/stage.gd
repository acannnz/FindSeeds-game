extends Node2D
## Satu stage yang sedang dimainkan: membangun peta dari data, menaruh pemain
## di '@', menyambungkan interaksi dengan tombol aksi, HUD, dan pembeli, dan
## mengatur tata letak layar (peta di atas, kontrol di bawah). Stage selesai
## otomatis begitu item terakhir pesanan terisi.

## Pesanan lengkap. Timer, bintang, dan stage berikutnya ditangani di fase 7.
signal selesai

const DataGame := preload("res://scripts/inti/data_game.gd")
const Pesanan := preload("res://scripts/inti/pesanan.gd")

## Satuan dunia per petak. Tampilan diskalakan oleh kamera agar pas di layar,
## jadi angka ini hanya satuan internal, bukan angka penyetelan.
const UKURAN_PETAK := 64.0

## Data stage (isi file stage_<id>.json). Diisi sebelum node masuk pohon.
var data: Dictionary
var pesanan: Pesanan
var sudah_selesai := false

@onready var kamera: Camera2D = $Kamera
@onready var peta: Node2D = $Peta
@onready var pemain: CharacterBody2D = $Pemain
@onready var area_kontrol: Control = $UI/AreaKontrol
@onready var joystick: Control = $UI/AreaKontrol/Joystick
@onready var tombol_aksi: Control = $UI/AreaKontrol/TombolAksi
@onready var hud: Control = $UI/AreaKontrol/Hud
@onready var interaksi: Node = $Interaksi
@onready var pengumuman: Label = $UI/Pengumuman


func _ready() -> void:
	pesanan = Pesanan.new(data.pesanan.isi)
	peta.bangun(data, UKURAN_PETAK, pesanan)
	pemain.position = peta.posisi_awal
	pemain.siapkan(UKURAN_PETAK, joystick)
	interaksi.siapkan(pemain, peta, tombol_aksi, pesanan, UKURAN_PETAK)
	interaksi.bawaan_berubah.connect(_perbarui_hud)
	interaksi.dipanen.connect(_saat_dipanen)
	pengumuman.hide()
	hud.judul = "Stage %s: %s" % [data.id, data.nama]
	_perbarui_hud()
	get_viewport().size_changed.connect(_atur_tata_letak)
	_atur_tata_letak()


func _saat_dipanen(tanaman: String, diterima: bool) -> void:
	for pembeli in peta.daftar_pembeli:
		pembeli.reaksi(tanaman, diterima)
	if pesanan.lengkap():
		_selesai()


func _selesai() -> void:
	sudah_selesai = true
	interaksi.hentikan()
	pemain.terkunci = true
	joystick.lepas()
	pengumuman.text = "Pesanan lengkap!"
	pengumuman.show()
	selesai.emit()


func _perbarui_hud() -> void:
	hud.perbarui(interaksi.kantong, interaksi.alat_di_tangan)


## Peta mengisi bagian atas layar sebesar porsi_tinggi_peta, sisanya kontrol.
func _atur_tata_letak() -> void:
	var layar := get_viewport_rect().size
	var porsi: float = DataGame.pengaturan.porsi_tinggi_peta
	var area_peta := Vector2(layar.x, layar.y * porsi)
	area_kontrol.anchor_top = porsi
	pengumuman.anchor_bottom = porsi

	var dunia: Vector2 = peta.ukuran_dunia()
	var skala := minf(area_peta.x / dunia.x, area_peta.y / dunia.y)
	kamera.zoom = Vector2.ONE * skala
	# Kamera berjangkar kiri atas: titik dunia di posisi kamera tampil di (0, 0).
	var sisa := (area_peta - dunia * skala) / 2.0
	kamera.position = -sisa / skala
