extends Node2D
## Satu stage yang sedang dimainkan: membangun peta dari data, menaruh pemain
## di '@', menyambungkan interaksi dengan tombol aksi, HUD, dan pembeli,
## menghitung mundur timer, dan mengatur tata letak layar (peta di atas,
## kontrol di bawah). Stage selesai otomatis begitu item terakhir pesanan
## terisi. Alur antarstage (bintang, ulang, lanjut) diatur main.gd.

## Pesanan lengkap sebelum waktu habis.
signal selesai(sisa_detik: float)
## Waktu habis sebelum pesanan lengkap.
signal waktu_habis

const DataGame := preload("res://scripts/inti/data_game.gd")
const Pesanan := preload("res://scripts/inti/pesanan.gd")
const Bintang := preload("res://scripts/inti/bintang.gd")

## Satuan dunia per petak. Tampilan diskalakan oleh kamera agar pas di layar,
## jadi angka ini hanya satuan internal, bukan angka penyetelan.
const UKURAN_PETAK := 64.0

## Data stage (isi file stage_<id>.json). Diisi sebelum node masuk pohon.
var data: Dictionary
var pesanan: Pesanan
var sisa_detik := 0.0
var sudah_selesai := false
var sudah_habis := false
## Bintang terbaik stage ini dari sesi sebelumnya (0 = belum pernah selesai).
## Diisi main.gd sebelum node masuk pohon.
var rekor_bintang := 0

@onready var kamera: Camera2D = $Kamera
@onready var peta: Node2D = $Peta
@onready var pemain: CharacterBody2D = $Pemain
@onready var area_kontrol: Control = $UI/AreaKontrol
@onready var joystick: Control = $UI/AreaKontrol/Joystick
@onready var tombol_aksi: Control = $UI/AreaKontrol/TombolAksi
@onready var hud: Control = $UI/AreaKontrol/Hud
@onready var interaksi: Node = $Interaksi


func _ready() -> void:
	pesanan = Pesanan.new(data.pesanan.isi)
	sisa_detik = float(data.waktu_detik)
	peta.bangun(data, UKURAN_PETAK, pesanan)
	pemain.position = peta.posisi_awal
	pemain.siapkan(UKURAN_PETAK, joystick)
	interaksi.siapkan(pemain, peta, tombol_aksi, pesanan, UKURAN_PETAK)
	interaksi.bawaan_berubah.connect(_perbarui_hud)
	interaksi.dipanen.connect(_saat_dipanen)
	hud.judul = "Stage %s: %s" % [data.id, data.nama]
	if rekor_bintang > 0:
		hud.judul += "  ·  rekor %d/%d" % [rekor_bintang, Bintang.BINTANG_MAKS]
	hud.sisa_detik = sisa_detik
	_perbarui_hud()
	get_viewport().size_changed.connect(_atur_tata_letak)
	_atur_tata_letak()


func _process(delta: float) -> void:
	if sudah_selesai or sudah_habis:
		return
	sisa_detik = maxf(0.0, sisa_detik - delta)
	hud.sisa_detik = sisa_detik
	if sisa_detik <= 0.0:
		sudah_habis = true
		_hentikan_permainan()
		waktu_habis.emit()


func _saat_dipanen(tanaman: String, diterima: bool) -> void:
	for pembeli in peta.daftar_pembeli:
		pembeli.reaksi(tanaman, diterima)
	if pesanan.lengkap() and not sudah_habis:
		sudah_selesai = true
		_hentikan_permainan()
		selesai.emit(sisa_detik)


func _hentikan_permainan() -> void:
	hud.sisa_detik = sisa_detik
	interaksi.hentikan()
	pemain.terkunci = true
	joystick.lepas()


func _perbarui_hud() -> void:
	hud.perbarui(interaksi.kantong, interaksi.alat_di_tangan)


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
