extends Node2D
## Satu stage yang sedang dimainkan: membangun peta dari data, menaruh pemain
## di '@', menyambungkan interaksi dengan pop-up aksi, HUD, dan pembeli,
## menghitung mundur timer, dan mengatur tata letak layar: peta selebar layar
## di bawah HUD atas, di tengah sisa tinggi layar; joystick dan HUD melayang
## langsung di atas tampilan game, aksi berupa pop-up di atas benda. Stage selesai otomatis begitu item terakhir pesanan
## terisi. Alur antarstage (bintang, ulang, lanjut) diatur main.gd.

## Pesanan lengkap sebelum waktu habis.
signal selesai(sisa_detik: float)
## Waktu habis sebelum pesanan lengkap.
signal waktu_habis

const DataGame := preload("res://scripts/inti/data_game.gd")
const Pesanan := preload("res://scripts/inti/pesanan.gd")
const Bintang := preload("res://scripts/inti/bintang.gd")
const AturanAksi := preload("res://scripts/inti/aturan_aksi.gd")

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
@onready var hud: Control = $UI/Hud
@onready var interaksi: Node = $Interaksi
@onready var popup_aksi: Node2D = $PopupAksi
@onready var panel_petunjuk: Control = $UI/PanelPetunjuk


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
	popup_aksi.siapkan(UKURAN_PETAK, peta.ukuran_dunia().x)
	# Sentuhan pada pop-up atau saat panel petunjuk terbuka tidak memunculkan joystick.
	joystick.penolak = func(posisi: Vector2) -> bool: return panel_petunjuk.visible or popup_aksi.kena(posisi)
	interaksi.siapkan(pemain, peta, popup_aksi, pesanan, UKURAN_PETAK)
	interaksi.bawaan_berubah.connect(_perbarui_hud)
	interaksi.dipanen.connect(_saat_dipanen)
	interaksi.baca_catatan.connect(func(): panel_petunjuk.tampilkan(data.get("petunjuk", [])))
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
	# Panel petunjuk tertutup sendiri begitu pemain menjauh dari catatan.
	if panel_petunjuk.visible and interaksi.aksi_kini.get("aksi", "") != AturanAksi.AKSI_BACA:
		panel_petunjuk.tutup()
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
	panel_petunjuk.tutup()
	pemain.terkunci = true
	joystick.lepas()


func _perbarui_hud() -> void:
	hud.perbarui(interaksi.kantong, interaksi.alat_di_tangan)


func _atur_tata_letak() -> void:
	var layar := get_viewport_rect().size
	var aman := _area_aman(layar)
	hud.inset_atas = aman.position.y
	var atas := aman.position.y + float(DataGame.pengaturan.tinggi_hud_atas_px)
	var tata := hitung_tata_letak(layar, peta.ukuran_dunia(), atas, aman.end.y)
	kamera.zoom = Vector2.ONE * tata.skala
	# Kamera berjangkar kiri atas: titik dunia di posisi kamera tampil di (0, 0).
	kamera.position = -tata.asal / tata.skala


## Peta selebar layar di antara HUD atas (`atas`) dan tepi bawah area aman
## (`bawah`), di tengah sisa tingginya. Jika layar terlalu pendek, peta
## diperkecil agar muat dan diletakkan di tengah horizontal.
## Mengembalikan {"skala": float, "asal": Vector2 (pojok kiri atas peta di layar)}.
static func hitung_tata_letak(layar: Vector2, dunia: Vector2, atas: float, bawah: float) -> Dictionary:
	var tinggi_boleh := bawah - atas
	var skala := minf(layar.x / dunia.x, tinggi_boleh / dunia.y)
	var ukuran := dunia * skala
	return {"skala": skala, "asal": Vector2((layar.x - ukuran.x) / 2.0, atas + (tinggi_boleh - ukuran.y) / 2.0)}


## Area aman layar (di luar poni/bilah gestur) dalam koordinat viewport.
## Di desktop seluruh viewport dianggap aman.
func _area_aman(layar: Vector2) -> Rect2:
	if not OS.has_feature("mobile"):
		return Rect2(Vector2.ZERO, layar)
	var jendela := Vector2(DisplayServer.window_get_size())
	var aman := Rect2(DisplayServer.get_display_safe_area())
	var skala := layar / jendela
	return Rect2(aman.position * skala, aman.size * skala)
