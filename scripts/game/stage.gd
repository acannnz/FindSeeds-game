extends Node2D
## Satu stage yang sedang dimainkan: membangun peta dari data, menaruh pemain
## di '@', menyambungkan interaksi dengan tombol aksi, HUD, dan pembeli,
## menghitung mundur timer, dan mengatur tata letak layar: peta selebar layar
## di bawah HUD atas; joystick, tombol aksi, dan HUD melayang langsung di atas
## tampilan game tanpa panel terpisah. Stage selesai otomatis begitu item terakhir pesanan
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
@onready var joystick: Control = $UI/Joystick
@onready var tombol_aksi: Control = $UI/TombolAksi
@onready var hud: Control = $UI/Hud
@onready var interaksi: Node = $Interaksi
@onready var label_target: Node2D = $LabelTarget


func _ready() -> void:
	# Latar di luar peta (area jempol) mengikuti tema stage.
	var tema: Dictionary = DataGame.tema.get(data.get("tema", ""), {})
	if tema.has("warna_latar"):
		RenderingServer.set_default_clear_color(Color(tema.warna_latar))
	pesanan = Pesanan.new(data.pesanan.isi)
	sisa_detik = float(data.waktu_detik)
	peta.bangun(data, UKURAN_PETAK, pesanan)
	pemain.position = peta.posisi_awal
	pemain.siapkan(UKURAN_PETAK, joystick)
	label_target.siapkan(UKURAN_PETAK, peta.ukuran_dunia().x)
	interaksi.siapkan(pemain, peta, tombol_aksi, label_target, pesanan, UKURAN_PETAK)
	interaksi.bawaan_berubah.connect(_perbarui_hud)
	interaksi.dipanen.connect(_saat_dipanen)
	hud.judul = "%s %s" % [data.id, data.nama]
	if rekor_bintang > 0:
		hud.judul += " · rekor %d/%d" % [rekor_bintang, Bintang.BINTANG_MAKS]
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


func _atur_tata_letak() -> void:
	var layar := get_viewport_rect().size
	var aman := _area_aman(layar)
	hud.inset_atas = aman.position.y
	tombol_aksi.inset_bawah = layar.y - aman.end.y
	var p := DataGame.pengaturan
	var tata := hitung_tata_letak(layar, peta.ukuran_dunia(), aman.position.y + float(p.tinggi_hud_atas_px), p.porsi_bawah_minimal)
	kamera.zoom = Vector2.ONE * tata.skala
	# Kamera berjangkar kiri atas: titik dunia di posisi kamera tampil di (0, 0).
	kamera.position = -tata.asal / tata.skala


## Peta selebar layar, tepat di bawah HUD atas. Jika layar terlalu pendek
## sehingga sisa bawah (tempat jempol) kurang dari porsi_bawah, peta diperkecil
## dan diletakkan di tengah horizontal.
## Mengembalikan {"skala": float, "asal": Vector2 (pojok kiri atas peta di layar)}.
static func hitung_tata_letak(layar: Vector2, dunia: Vector2, atas: float, porsi_bawah: float) -> Dictionary:
	var tinggi_boleh := layar.y - atas - layar.y * porsi_bawah
	var skala := minf(layar.x / dunia.x, tinggi_boleh / dunia.y)
	return {"skala": skala, "asal": Vector2((layar.x - dunia.x * skala) / 2.0, atas)}


## Area aman layar (di luar poni/bilah gestur) dalam koordinat viewport.
## Di desktop seluruh viewport dianggap aman.
func _area_aman(layar: Vector2) -> Rect2:
	if not OS.has_feature("mobile"):
		return Rect2(Vector2.ZERO, layar)
	var jendela := Vector2(DisplayServer.window_get_size())
	var aman := Rect2(DisplayServer.get_display_safe_area())
	var skala := layar / jendela
	return Rect2(aman.position * skala, aman.size * skala)
