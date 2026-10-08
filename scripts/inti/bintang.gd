extends RefCounted
## Perhitungan bintang: 1 bintang untuk stage selesai; 2 dan 3 bintang jika
## sisa waktu minimal sebesar ambang yang diatur per stage.

const BINTANG_MAKS := 3


## ambang: isi "bintang_sisa_detik" file stage, {"tiga": detik, "dua": detik}.
static func hitung(sisa_detik: float, ambang: Dictionary) -> int:
	if sisa_detik >= float(ambang.tiga):
		return 3
	if sisa_detik >= float(ambang.dua):
		return 2
	return 1
