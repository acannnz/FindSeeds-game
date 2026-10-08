@tool
extends RefCounted
## Enam pengecekan stage dari bagian "Saran implementasi" dokumen rancangan,
## ditambah pengecekan format dasar (cek 0). Logika murni: menerima data yang
## sudah dimuat dan mengembalikan daftar temuan tanpa mencetak apa pun.
## @tool karena juga dijalankan plugin editor addons/pemeriksa_stage.

const PemuatData := preload("res://scripts/inti/pemuat_data.gd")

const CEK_FORMAT := 0
const CEK_SUMBER_CUKUP := 1
const CEK_ALAT_ADA := 2
const CEK_HURUF_DIKENAL := 3
const CEK_BISA_DICAPAI := 4
const CEK_JEDA_BENDA := 5
const CEK_LOGIKA_MUSIM := 6

const NAMA_CEK := {
	CEK_FORMAT: "Format data",
	CEK_SUMBER_CUKUP: "Benda sumber cukup",
	CEK_ALAT_ADA: "Alat untuk wadah ada",
	CEK_HURUF_DIKENAL: "Huruf peta dikenal",
	CEK_BISA_DICAPAI: "Bisa dicapai dari @",
	CEK_JEDA_BENDA: "Jeda kemunculan benda",
	CEK_LOGIKA_MUSIM: "Logika sesuai musim",
}

const ARAH_TETANGGA := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
# Batas wadah bersarang (wadah berisi wadah), mencegah putaran tak berujung.
const BATAS_SARANG_WADAH := 8

var _pengaturan: Dictionary
var _katalog: Dictionary
var _pembeli: Dictionary
var _tanaman: Dictionary
var _tema: Dictionary
var _temuan: Array[Dictionary] = []


## data: hasil PemuatData.muat_semua() berisi pengaturan, katalog, pembeli,
## tanaman, dan stage (Array {"file", "data"} yang sudah urut menurut id).
## Mengembalikan Array berisi {"file": String, "cek": int, "pesan": String}.
func periksa(data: Dictionary) -> Array[Dictionary]:
	_pengaturan = data.pengaturan
	var katalog: Dictionary = data.katalog
	_katalog = katalog
	_pembeli = data.pembeli
	_tanaman = data.tanaman
	_tema = data.get("tema", {})
	var daftar_stage: Array = data.stage
	_temuan = []
	if not _periksa_pengaturan():
		return _temuan
	_periksa_katalog()
	# Entri katalog yang bukan objek sudah dilaporkan; buang agar cek lain aman.
	_katalog = katalog.duplicate()
	for id in katalog:
		if typeof(katalog[id]) != TYPE_DICTIONARY:
			_katalog.erase(id)
	var stage_sah: Array = []
	for s in daftar_stage:
		if _periksa_format(s.file, s.data):
			stage_sah.append(s)
	for s in stage_sah:
		_cek_sumber_cukup(s.file, s.data)
		_cek_alat_ada(s.file, s.data)
		_cek_huruf_dikenal(s.file, s.data)
		_cek_bisa_dicapai(s.file, s.data)
		_cek_logika_musim(s.file, s.data)
	_cek_jeda_benda(stage_sah)
	return _temuan


## Satu baris pesan untuk satu temuan, dipakai game dan plugin editor.
static func format_temuan(t: Dictionary) -> String:
	return "%s: cek %d (%s): %s" % [t.file, t.cek, NAMA_CEK[t.cek], t.pesan]


## Memuat data dari folder dan menjalankan semua pengecekan. Mengembalikan
## daftar pesan (galat pemuatan atau temuan); kosong berarti semua lolos.
static func periksa_folder(folder_data: String = PemuatData.FOLDER_DATA, folder_stage: String = "") -> Array[String]:
	var muat := PemuatData.muat_semua(folder_data, folder_stage)
	var pesan: Array[String] = []
	pesan.assign(muat.galat)
	if pesan.is_empty():
		for t in new().periksa(muat):
			pesan.append(format_temuan(t))
	return pesan


# --- Cek 0: format -----------------------------------------------------------

func _periksa_pengaturan() -> bool:
	var f := PemuatData.FILE_PENGATURAN
	var sah := true
	for kunci in ["peta_lebar_petak", "peta_tinggi_petak", "jeda_kemunculan_benda_stage"]:
		if not _bilangan_bulat_positif(_pengaturan.get(kunci)):
			_lapor(f, CEK_FORMAT, "'%s' harus bilangan bulat positif." % kunci)
			sah = false
	if typeof(_pengaturan.get("logika_per_musim")) != TYPE_DICTIONARY:
		_lapor(f, CEK_FORMAT, "'logika_per_musim' harus berupa objek {\"1\": \"warna_bentuk\", ...}.")
		sah = false
	return sah


func _periksa_katalog() -> void:
	var f := PemuatData.FILE_KATALOG
	for id in _katalog:
		var entri = _katalog[id]
		if typeof(entri) != TYPE_DICTIONARY:
			_lapor(f, CEK_FORMAT, "Entri '%s' harus berupa objek." % id)
			continue
		match PemuatData.jenis_benda(entri):
			PemuatData.JENIS_TIDAK_DIKENAL:
				_lapor(f, CEK_FORMAT, "Jenis benda '%s' tidak bisa disimpulkan (butuh 'hasil', 'butuh_alat', atau 'jenis')." % id)
			PemuatData.JENIS_SUMBER:
				if not _tanaman.has(entri.hasil):
					_lapor(f, CEK_FORMAT, "'%s': hasil '%s' tidak ada di %s." % [id, entri.hasil, PemuatData.FILE_TANAMAN])
				if not entri.has("logika"):
					_lapor(f, CEK_FORMAT, "Benda sumber '%s' tidak punya kolom 'logika'." % id)
			PemuatData.JENIS_WADAH:
				var alat = entri.butuh_alat
				if not _katalog.has(alat) or PemuatData.jenis_benda(_katalog[alat]) != PemuatData.JENIS_ALAT:
					_lapor(f, CEK_FORMAT, "Wadah '%s' butuh alat '%s', tapi itu bukan alat di katalog." % [id, alat])
				if not _katalog.has(entri.get("isi")):
					_lapor(f, CEK_FORMAT, "Wadah '%s' berisi '%s', tapi benda itu tidak ada di katalog." % [id, entri.get("isi")])


## Mengembalikan false jika struktur stage terlalu rusak untuk dicek lebih lanjut.
func _periksa_format(f: String, d: Dictionary) -> bool:
	var bisa_lanjut := true

	var id_pecah := PemuatData.pecah_id(d.get("id"))
	if id_pecah.is_empty():
		_lapor(f, CEK_FORMAT, "'id' harus berformat \"musim-nomor\", misalnya \"1-3\".")
		bisa_lanjut = false
	elif f != "%s%s.json" % [PemuatData.AWALAN_FILE_STAGE, d.id]:
		_lapor(f, CEK_FORMAT, "Nama file tidak cocok dengan id \"%s\" (seharusnya %s%s.json)." % [d.id, PemuatData.AWALAN_FILE_STAGE, d.id])

	if typeof(d.get("nama")) != TYPE_STRING or d.nama.is_empty():
		_lapor(f, CEK_FORMAT, "'nama' harus teks yang tidak kosong.")

	if not _tema.has(d.get("tema")):
		_lapor(f, CEK_FORMAT, "'tema' \"%s\" tidak ada di %s (pilihan: %s)." % [d.get("tema"), PemuatData.FILE_TEMA, ", ".join(_tema.keys())])

	var waktu = d.get("waktu_detik")
	if not _bilangan(waktu) or waktu <= 0:
		_lapor(f, CEK_FORMAT, "'waktu_detik' harus angka lebih dari 0.")
		waktu = INF

	var bintang = d.get("bintang_sisa_detik")
	if typeof(bintang) != TYPE_DICTIONARY or not _bilangan(bintang.get("tiga")) or not _bilangan(bintang.get("dua")):
		_lapor(f, CEK_FORMAT, "'bintang_sisa_detik' harus berisi angka 'tiga' dan 'dua'.")
	elif not (0 <= bintang.dua and bintang.dua <= bintang.tiga and bintang.tiga <= waktu):
		_lapor(f, CEK_FORMAT, "Ambang bintang harus 0 ≤ dua (%s) ≤ tiga (%s) ≤ waktu_detik." % [bintang.dua, bintang.tiga])

	var pesanan = d.get("pesanan")
	if typeof(pesanan) != TYPE_DICTIONARY or typeof(pesanan.get("isi")) != TYPE_DICTIONARY or pesanan.isi.is_empty():
		_lapor(f, CEK_FORMAT, "'pesanan' harus berisi 'pembeli' dan 'isi' yang tidak kosong.")
		bisa_lanjut = false
	else:
		if not _pembeli.has(pesanan.get("pembeli")):
			_lapor(f, CEK_FORMAT, "Pembeli '%s' tidak ada di %s." % [pesanan.get("pembeli"), PemuatData.FILE_PEMBELI])
		for tanaman in pesanan.isi:
			if not _tanaman.has(tanaman):
				_lapor(f, CEK_FORMAT, "Pesanan '%s' tidak ada di %s." % [tanaman, PemuatData.FILE_TANAMAN])
			if not _bilangan_bulat_positif(pesanan.isi[tanaman]):
				_lapor(f, CEK_FORMAT, "Jumlah pesanan '%s' harus bilangan bulat ≥ 1." % tanaman)
				bisa_lanjut = false

	var legenda = d.get("legenda")
	if typeof(legenda) != TYPE_DICTIONARY:
		_lapor(f, CEK_FORMAT, "'legenda' harus berupa objek huruf → id benda.")
		bisa_lanjut = false
	else:
		for huruf in legenda:
			if huruf.length() != 1:
				_lapor(f, CEK_FORMAT, "Kunci legenda \"%s\" harus tepat satu karakter." % huruf)
			elif huruf in PemuatData.SIMBOL_UMUM:
				_lapor(f, CEK_FORMAT, "Huruf '%s' adalah simbol umum dan tidak boleh ada di legenda." % huruf)
			if not _katalog.has(legenda[huruf]):
				_lapor(f, CEK_FORMAT, "Legenda '%s' menunjuk '%s', tapi benda itu tidak ada di %s." % [huruf, legenda[huruf], PemuatData.FILE_KATALOG])

	var lebar: int = _pengaturan.peta_lebar_petak
	var tinggi: int = _pengaturan.peta_tinggi_petak
	var peta = d.get("peta")
	if typeof(peta) != TYPE_ARRAY or peta.size() != tinggi:
		_lapor(f, CEK_FORMAT, "'peta' harus berisi tepat %d baris." % tinggi)
		return false
	for y in tinggi:
		if typeof(peta[y]) != TYPE_STRING or peta[y].length() != lebar:
			_lapor(f, CEK_FORMAT, "Baris peta ke-%d harus tepat %d karakter." % [y + 1, lebar])
			bisa_lanjut = false
	if not bisa_lanjut:
		return false

	var posisi_pemain := _cari_simbol(peta, PemuatData.SIMBOL_PEMAIN)
	if posisi_pemain.size() != 1:
		_lapor(f, CEK_FORMAT, "Peta harus punya tepat satu '@' (ditemukan %d)." % posisi_pemain.size())
		bisa_lanjut = false
	if _cari_simbol(peta, PemuatData.SIMBOL_TANAH).is_empty():
		_lapor(f, CEK_FORMAT, "Peta tidak punya petak tanah 'T'.")

	for y in tinggi:
		for x in lebar:
			var di_tepi := x == 0 or y == 0 or x == lebar - 1 or y == tinggi - 1
			if di_tepi and peta[y][x] in PemuatData.SIMBOL_BISA_DIINJAK:
				_lapor(f, CEK_FORMAT, "Tepi peta di %s bisa diinjak ('%s'); pemain bisa keluar peta." % [_posisi(Vector2i(x, y)), peta[y][x]])
	return bisa_lanjut


# --- Cek 1: setiap tanaman di pesanan punya cukup benda sumber ---------------

func _cek_sumber_cukup(f: String, d: Dictionary) -> void:
	var sumber_per_tanaman := {}
	for b in _benda_di_peta(d):
		var id_sumber := _sumber_dari(b.id)
		if id_sumber == "":
			continue
		var tanaman: String = _katalog[id_sumber].hasil
		if not sumber_per_tanaman.has(tanaman):
			sumber_per_tanaman[tanaman] = []
		sumber_per_tanaman[tanaman].append(b)
	for tanaman in d.pesanan.isi:
		var butuh := int(d.pesanan.isi[tanaman])
		var ada: Array = sumber_per_tanaman.get(tanaman, [])
		if ada.size() < butuh:
			var rincian := ""
			if not ada.is_empty():
				rincian = " (%s)" % ", ".join(ada.map(_uraikan_benda))
			_lapor(f, CEK_SUMBER_CUKUP, "Pesanan butuh %d %s, tapi peta hanya punya %d benda sumber %s%s." % [butuh, tanaman, ada.size(), tanaman, rincian])


# --- Cek 2: setiap wadah yang butuh alat punya alat itu di peta yang sama ----

func _cek_alat_ada(f: String, d: Dictionary) -> void:
	var benda := _benda_di_peta(d)
	var alat_di_peta := {}
	for b in benda:
		if PemuatData.jenis_benda(_katalog[b.id]) == PemuatData.JENIS_ALAT:
			alat_di_peta[b.id] = true
	for b in benda:
		for id_wadah in _rantai_wadah(b.id):
			var alat: String = _katalog[id_wadah].butuh_alat
			if not alat_di_peta.has(alat):
				_lapor(f, CEK_ALAT_ADA, "%s butuh alat '%s', tapi alat itu tidak ada di peta." % [_uraikan_benda(b), alat])


# --- Cek 3: setiap huruf di peta ada di legenda atau simbol umum -------------

func _cek_huruf_dikenal(f: String, d: Dictionary) -> void:
	var tak_dikenal := {}
	for y in d.peta.size():
		for x in d.peta[y].length():
			var huruf: String = d.peta[y][x]
			if huruf in PemuatData.SIMBOL_UMUM or d.legenda.has(huruf):
				continue
			if not tak_dikenal.has(huruf):
				tak_dikenal[huruf] = []
			tak_dikenal[huruf].append(_posisi(Vector2i(x, y)))
	for huruf in tak_dikenal:
		_lapor(f, CEK_HURUF_DIKENAL, "Huruf '%s' di %s tidak ada di legenda dan bukan simbol umum (%s)." % [huruf, ", ".join(tak_dikenal[huruf]), " ".join(PemuatData.SIMBOL_UMUM)])


# --- Cek 4: semua benda dan petak tanah bisa dicapai dari @ (flood fill) ------

func _cek_bisa_dicapai(f: String, d: Dictionary) -> void:
	var peta: Array = d.peta
	var awal: Vector2i = _cari_simbol(peta, PemuatData.SIMBOL_PEMAIN)[0]
	var tercapai := {awal: true}
	var antrean: Array[Vector2i] = [awal]
	while not antrean.is_empty():
		var sel: Vector2i = antrean.pop_front()
		for arah in ARAH_TETANGGA:
			var n: Vector2i = sel + arah
			if tercapai.has(n) or not _di_dalam_peta(peta, n):
				continue
			if peta[n.y][n.x] in PemuatData.SIMBOL_BISA_DIINJAK:
				tercapai[n] = true
				antrean.append(n)

	for sel in _cari_simbol(peta, PemuatData.SIMBOL_TANAH):
		if not tercapai.has(sel):
			_lapor(f, CEK_BISA_DICAPAI, "Petak tanah 'T' di %s tidak bisa dicapai dari @." % _posisi(sel))
	# Benda padat: cukup ada satu tetangga yang tercapai untuk diinteraksi.
	for b in _benda_di_peta(d):
		if PemuatData.jenis_benda(_katalog[b.id]) == PemuatData.JENIS_PENGHALANG:
			continue
		var bisa := false
		for arah in ARAH_TETANGGA:
			if tercapai.has(b.sel + arah):
				bisa = true
				break
		if not bisa:
			_lapor(f, CEK_BISA_DICAPAI, "%s tidak bisa didekati dari @." % _uraikan_benda(b))


# --- Cek 5: benda tidak muncul lagi sebelum jeda minimal ---------------------

func _cek_jeda_benda(stage_sah: Array) -> void:
	var jeda: int = _pengaturan.jeda_kemunculan_benda_stage
	var terakhir := {}  # id benda -> {"indeks", "id_stage"}
	for i in stage_sah.size():
		var s: Dictionary = stage_sah[i]
		var dipakai := {}
		for b in _benda_di_peta(s.data):
			for id in _benda_teridentifikasi(b.id):
				dipakai[id] = true
		for id in dipakai:
			if terakhir.has(id) and i - terakhir[id].indeks < jeda:
				_lapor(s.file, CEK_JEDA_BENDA, "%s muncul lagi di stage %s, padahal terakhir dipakai di stage %s (selang %d stage, minimal %d)." % [_nama(id), s.data.id, terakhir[id].id_stage, i - terakhir[id].indeks, jeda])
			terakhir[id] = {"indeks": i, "id_stage": s.data.id}


# --- Cek 6: benda sumber memakai logika yang sudah diperkenalkan -------------

func _cek_logika_musim(f: String, d: Dictionary) -> void:
	var musim: int = PemuatData.pecah_id(d.id)[0]
	var musim_logika := {}  # logika -> musim pertama diperkenalkan
	for k in _pengaturan.logika_per_musim:
		if str(k).is_valid_int():
			musim_logika[_pengaturan.logika_per_musim[k]] = int(k)
	var boleh: Array = musim_logika.keys().filter(func(l): return musim_logika[l] <= musim)
	var sudah := {}
	for b in _benda_di_peta(d):
		for id in _benda_teridentifikasi(b.id):
			if sudah.has(id) or PemuatData.jenis_benda(_katalog[id]) != PemuatData.JENIS_SUMBER:
				continue
			sudah[id] = true
			var logika = _katalog[id].get("logika")
			if not musim_logika.has(logika):
				_lapor(f, CEK_LOGIKA_MUSIM, "%s memakai logika '%s' yang tidak terdaftar di logika_per_musim." % [_nama(id), logika])
			elif musim_logika[logika] > musim:
				_lapor(f, CEK_LOGIKA_MUSIM, "%s memakai logika '%s' yang baru diperkenalkan di musim %d, padahal stage %s ada di musim %d (boleh: %s)." % [_nama(id), logika, musim_logika[logika], d.id, musim, ", ".join(boleh)])


# --- Pembantu ----------------------------------------------------------------

func _lapor(file: String, cek: int, pesan: String) -> void:
	_temuan.append({"file": file, "cek": cek, "pesan": pesan})


## Semua benda (huruf legenda yang ada di katalog) beserta posisinya di peta.
func _benda_di_peta(d: Dictionary) -> Array:
	var hasil := []
	for y in d.peta.size():
		for x in d.peta[y].length():
			var huruf: String = d.peta[y][x]
			if huruf in PemuatData.SIMBOL_UMUM or not d.legenda.has(huruf):
				continue
			var id: String = d.legenda[huruf]
			if _katalog.has(id):
				hasil.append({"huruf": huruf, "id": id, "sel": Vector2i(x, y)})
	return hasil


## Wadah-wadah yang harus dibuka untuk sampai ke isi terdalam benda ini.
func _rantai_wadah(id: String) -> Array[String]:
	var rantai: Array[String] = []
	var kini := id
	while rantai.size() < BATAS_SARANG_WADAH and _katalog.has(kini) \
			and PemuatData.jenis_benda(_katalog[kini]) == PemuatData.JENIS_WADAH:
		rantai.append(kini)
		kini = str(_katalog[kini].get("isi"))
	return rantai


## Benda yang akhirnya diidentifikasi pemain: benda itu sendiri, atau isi wadah.
## Hanya benda sumber dan kosong (termasuk pengecoh); alat dan penghalang tidak.
func _benda_teridentifikasi(id: String) -> Array[String]:
	var rantai := _rantai_wadah(id)
	var akhir: String = id if rantai.is_empty() else str(_katalog[rantai[-1]].get("isi"))
	if not _katalog.has(akhir):
		return []
	var jenis := PemuatData.jenis_benda(_katalog[akhir])
	if jenis == PemuatData.JENIS_SUMBER or jenis == PemuatData.JENIS_KOSONG:
		return [akhir]
	return []


## Id benda sumber yang dihasilkan benda ini (langsung atau lewat wadah), atau "".
func _sumber_dari(id: String) -> String:
	for akhir in _benda_teridentifikasi(id):
		if PemuatData.jenis_benda(_katalog[akhir]) == PemuatData.JENIS_SUMBER:
			return akhir
	return ""


func _cari_simbol(peta: Array, simbol: String) -> Array[Vector2i]:
	var hasil: Array[Vector2i] = []
	for y in peta.size():
		for x in peta[y].length():
			if peta[y][x] == simbol:
				hasil.append(Vector2i(x, y))
	return hasil


func _di_dalam_peta(peta: Array, sel: Vector2i) -> bool:
	return sel.y >= 0 and sel.y < peta.size() and sel.x >= 0 and sel.x < peta[sel.y].length()


func _nama(id: String) -> String:
	return str(_katalog.get(id, {}).get("nama", id))


func _uraikan_benda(b: Dictionary) -> String:
	return "%s ('%s' di %s)" % [_nama(b.id), b.huruf, _posisi(b.sel)]


## Posisi untuk manusia: baris dan kolom dihitung dari 1, mulai kiri atas.
func _posisi(sel: Vector2i) -> String:
	return "baris %d kolom %d" % [sel.y + 1, sel.x + 1]


func _bilangan(v: Variant) -> bool:
	return typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT


func _bilangan_bulat_positif(v: Variant) -> bool:
	return _bilangan(v) and v >= 1 and v == floor(v)
