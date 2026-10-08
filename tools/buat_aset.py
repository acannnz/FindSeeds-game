# Generator aset SVG FindSeeds: gaya kartun datar, garis tepi tebal.
#
# GAYA LAMA (digantikan tools/buat_aset_adegan.py). Dipakai sekali untuk set awal. File SVG hasilnya
# adalah sumber utama: boleh diedit langsung (Inkscape/Illustrator/teks) dan
# ilustrator boleh menggantinya. PERINGATAN: menjalankan skrip ini lagi akan
# MENIMPA semua SVG yang ada di folder tujuan, termasuk hasil edit manual.
#
# Pemakaian (dari root proyek):  python tools/buat_aset.py aset
# Setelah itu impor ulang: godot --headless --path . --import
#
# Kanvas 128x128 (diekspor 2x = 256 px) kecuali penghalang yang memanjang.
import os, sys

KELUAR = sys.argv[1]
O = "#3b2a20"     # warna garis tepi
W = 4             # tebal garis tepi
SKALA = 2


def svg(isi, vw=128, vh=128):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{vw*SKALA}" height="{vh*SKALA}" '
            f'viewBox="0 0 {vw} {vh}">\n{isi}\n</svg>\n')


def bayang(cx=64, cy=112, rx=36, ry=7):
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#000" fill-opacity="0.16"/>'


def g(atribut=""):
    return f'stroke="{O}" stroke-width="{W}" stroke-linejoin="round" stroke-linecap="round" {atribut}'


A = {}

# ---------------------------------------------------------------- benda sumber
A["benda/bola_karet_merah"] = svg(bayang() + f'''
<circle cx="64" cy="62" r="42" fill="#e53935" {g()}/>
<path d="M27 70 Q64 92 101 70" fill="none" stroke="#b71c1c" stroke-width="4" stroke-linecap="round"/>
<path d="M40 48 Q64 38 88 48" fill="none" stroke="#b71c1c" stroke-width="3" stroke-linecap="round" opacity="0.6"/>
<ellipse cx="46" cy="42" rx="12" ry="7" fill="#ff8a80" transform="rotate(-30 46 42)"/>''')

A["benda/jam_weker_merah"] = svg(bayang(rx=34) + f'''
<line x1="42" y1="94" x2="32" y2="112" {g()} stroke-width="7"/>
<line x1="86" y1="94" x2="96" y2="112" {g()} stroke-width="7"/>
<circle cx="34" cy="28" r="14" fill="#d32f2f" {g()}/>
<circle cx="94" cy="28" r="14" fill="#d32f2f" {g()}/>
<rect x="60" y="12" width="8" height="14" rx="3" fill="#ffd54f" {g('stroke-width="3"')}/>
<circle cx="64" cy="66" r="42" fill="#d32f2f" {g()}/>
<circle cx="64" cy="66" r="30" fill="#fffaf0" {g('stroke-width="3"')}/>
<g fill="{O}"><circle cx="64" cy="42" r="2.5"/><circle cx="88" cy="66" r="2.5"/><circle cx="64" cy="90" r="2.5"/><circle cx="40" cy="66" r="2.5"/></g>
<line x1="64" y1="66" x2="64" y2="47" {g()}/>
<line x1="64" y1="66" x2="79" y2="73" {g()}/>
<circle cx="64" cy="66" r="4" fill="{O}"/>''')

A["benda/lampion_merah"] = svg(bayang(rx=30) + f'''
<line x1="64" y1="4" x2="64" y2="20" {g()}/>
<line x1="64" y1="104" x2="64" y2="118" stroke="#fbc02d" stroke-width="5" stroke-linecap="round"/>
<rect x="46" y="16" width="36" height="12" rx="3" fill="#fbc02d" {g()}/>
<rect x="46" y="96" width="36" height="12" rx="3" fill="#fbc02d" {g()}/>
<ellipse cx="64" cy="62" rx="46" ry="38" fill="#e53935" {g()}/>
<g fill="none" stroke="#b71c1c" stroke-width="3">
<path d="M64 24 L64 100"/><path d="M42 27 Q30 62 42 97"/><path d="M86 27 Q98 62 86 97"/></g>
<ellipse cx="40" cy="48" rx="8" ry="12" fill="#ff8a80" transform="rotate(20 40 48)"/>''')

A["benda/hidung_badut"] = svg(bayang(rx=28) + f'''
<path d="M16 64 Q64 30 112 64" fill="none" stroke="#212121" stroke-width="3"/>
<circle cx="64" cy="70" r="32" fill="#ff1744" {g()}/>
<ellipse cx="52" cy="56" rx="11" ry="8" fill="#ffffff" fill-opacity="0.85" transform="rotate(-25 52 56)"/>
<circle cx="76" cy="84" r="4" fill="#ff8a80"/>''')

A["benda/kerucut_lalu_lintas"] = svg(bayang(rx=40) + f'''
<rect x="18" y="96" width="92" height="16" rx="4" fill="#424242" {g()}/>
<path d="M64 10 L96 98 L32 98 Z" fill="#fb8c00" {g()}/>
<path d="M50 50 L78 50 L84 66 L44 66 Z" fill="#ffffff"/>
<path d="M58 28 L70 28 L74 38 L54 38 Z" fill="#ffffff"/>
<path d="M64 10 L96 98 L32 98 Z" fill="none" {g()}/>''')

A["benda/krayon_oranye"] = svg(bayang() + f'''
<g transform="rotate(-35 64 64)">
<rect x="20" y="50" width="70" height="28" rx="4" fill="#ef6c00" {g()}/>
<rect x="34" y="50" width="42" height="28" fill="#ffcc80" {g()}/>
<path d="M90 50 L112 64 L90 78 Z" fill="#ef6c00" {g()}/>
<line x1="40" y1="58" x2="70" y2="58" stroke="#ef6c00" stroke-width="3"/>
<line x1="40" y1="70" x2="70" y2="70" stroke="#ef6c00" stroke-width="3"/></g>''')

A["benda/spons_kuning"] = svg(bayang(rx=44) + f'''
<rect x="16" y="30" width="96" height="74" rx="12" fill="#fdd835" {g()}/>
<rect x="16" y="22" width="96" height="22" rx="8" fill="#43a047" {g()}/>
<g fill="#f9a825"><circle cx="34" cy="62" r="5"/><circle cx="56" cy="56" r="4"/><circle cx="80" cy="64" r="6"/><circle cx="98" cy="56" r="4"/>
<circle cx="44" cy="84" r="5"/><circle cx="68" cy="88" r="4"/><circle cx="92" cy="86" r="5"/></g>''')

A["benda/kemoceng_kuning"] = svg(bayang(rx=30) + f'''
<rect x="58" y="70" width="12" height="46" rx="5" fill="#8d6e63" {g()}/>
<g fill="#fdd835" {g('stroke-width="3"')}>
<ellipse cx="44" cy="40" rx="18" ry="26" transform="rotate(-25 44 40)"/>
<ellipse cx="84" cy="40" rx="18" ry="26" transform="rotate(25 84 40)"/>
<ellipse cx="64" cy="34" rx="18" ry="30"/>
<ellipse cx="64" cy="64" rx="22" ry="14"/></g>''')

A["benda/bantalan_jarum"] = svg(bayang() + f'''
<line x1="44" y1="44" x2="36" y2="16" stroke="#78909c" stroke-width="3"/>
<line x1="64" y1="40" x2="64" y2="10" stroke="#78909c" stroke-width="3"/>
<line x1="84" y1="44" x2="94" y2="16" stroke="#78909c" stroke-width="3"/>
<circle cx="36" cy="14" r="7" fill="#fdd835" {g('stroke-width="3"')}/>
<circle cx="64" cy="9" r="7" fill="#66bb6a" {g('stroke-width="3"')}/>
<circle cx="94" cy="14" r="7" fill="#42a5f5" {g('stroke-width="3"')}/>
<ellipse cx="64" cy="98" rx="40" ry="12" fill="#8d6e63" {g()}/>
<ellipse cx="64" cy="70" rx="46" ry="36" fill="#c2185b" {g()}/>
<g fill="#f8bbd0"><circle cx="42" cy="60" r="3.5"/><circle cx="60" cy="52" r="3.5"/><circle cx="82" cy="58" r="3.5"/><circle cx="50" cy="78" r="3.5"/>
<circle cx="72" cy="74" r="3.5"/><circle cx="92" cy="80" r="3.5"/><circle cx="34" cy="82" r="3.5"/><circle cx="64" cy="92" r="3.5"/></g>''')

A["benda/bantal_hati_merah"] = svg(bayang(rx=42) + f'''
<path d="M64 108 C20 80 10 56 18 38 C26 20 50 18 64 38 C78 18 102 20 110 38 C118 56 108 80 64 108 Z" fill="#c2185b" {g()}/>
<path d="M64 96 C30 74 24 56 30 44 C36 32 52 32 64 48 C76 32 92 32 98 44 C104 56 98 74 64 96 Z" fill="none" stroke="#f8bbd0" stroke-width="2.5" stroke-dasharray="5 5"/>''')

A["benda/bola_kertas_hijau"] = svg(bayang(rx=38) + f'''
<path d="M30 40 L52 22 L78 26 L100 40 L108 66 L98 92 L72 106 L44 102 L22 82 L20 58 Z" fill="#7cb342" {g()}/>
<g fill="none" stroke="#33691e" stroke-width="3" stroke-linecap="round">
<path d="M52 22 L58 48 L30 40"/><path d="M58 48 L88 56 L100 40"/><path d="M88 56 L80 82 L98 92"/><path d="M58 48 L50 76 L22 82"/><path d="M50 76 L80 82 L72 106"/></g>''')

A["benda/rok_tutu_hijau"] = svg(bayang(rx=46) + f'''
<path d="M64 10 L76 22 L94 18 L98 36 L114 46 L104 62 L114 80 L96 88 L92 106 L74 100 L64 116 L54 100 L36 106 L32 88 L14 80 L24 62 L14 46 L30 36 L34 18 L52 22 Z" fill="#9ccc65" {g()}/>
<circle cx="64" cy="62" r="34" fill="#7cb342" {g()}/>
<circle cx="64" cy="62" r="16" fill="#33691e" {g()}/>''')

A["benda/pot_bunga"] = svg(bayang(rx=34) + f'''
<path d="M38 70 L90 70 L82 112 L46 112 Z" fill="#d1784f" {g()}/>
<rect x="32" y="62" width="64" height="14" rx="4" fill="#bf6a44" {g()}/>
<path d="M64 62 L64 36 M50 64 L42 42 M78 64 L88 42" fill="none" stroke="#33691e" stroke-width="4" stroke-linecap="round"/>
<g {g('stroke-width="3"')}>
<circle cx="64" cy="28" r="14" fill="#ab47bc"/><circle cx="40" cy="38" r="12" fill="#ce93d8"/><circle cx="90" cy="38" r="12" fill="#ce93d8"/></g>
<g fill="#fdd835"><circle cx="64" cy="28" r="5"/><circle cx="40" cy="38" r="4"/><circle cx="90" cy="38" r="4"/></g>''')

# ---------------------------------------------------------------- benda kosong
A["benda/kaleng_cat_merah"] = svg(bayang(rx=38) + f'''
<path d="M28 40 Q64 0 100 40" fill="none" {g()}/>
<path d="M24 40 L24 100 Q64 116 104 100 L104 40 Z" fill="#b0bec5" {g()}/>
<path d="M24 56 L104 56 L104 86 Q64 98 24 86 Z" fill="#d32f2f"/>
<path d="M24 40 L24 100 Q64 116 104 100 L104 40" fill="none" {g()}/>
<ellipse cx="64" cy="40" rx="40" ry="12" fill="#cfd8dc" {g()}/>
<ellipse cx="64" cy="40" rx="30" ry="7" fill="#d32f2f"/>
<path d="M88 44 Q90 60 86 66" fill="none" stroke="#d32f2f" stroke-width="5" stroke-linecap="round"/>''')

A["benda/kotak_pos"] = svg(bayang(rx=34) + f'''
<rect x="56" y="88" width="16" height="24" fill="#5d4037" {g()}/>
<path d="M28 92 L28 40 Q28 14 64 14 Q100 14 100 40 L100 92 Z" fill="#d84315" {g()}/>
<rect x="44" y="40" width="40" height="9" rx="4" fill="{O}"/>
<rect x="48" y="60" width="32" height="18" rx="4" fill="#ffccbc" {g('stroke-width="3"')}/>''')

A["benda/bola_tenis"] = svg(bayang(rx=32) + f'''
<circle cx="64" cy="64" r="38" fill="#cddc39" {g()}/>
<path d="M34 38 Q56 64 34 90" fill="none" stroke="#ffffff" stroke-width="5" stroke-linecap="round"/>
<path d="M94 38 Q72 64 94 90" fill="none" stroke="#ffffff" stroke-width="5" stroke-linecap="round"/>
<circle cx="64" cy="64" r="38" fill="none" {g()}/>''')

A["benda/kucing_tidur"] = svg(bayang(rx=46) + f'''
<path d="M100 92 Q122 70 104 52" fill="none" stroke="{O}" stroke-width="14" stroke-linecap="round"/>
<path d="M100 92 Q122 70 104 52" fill="none" stroke="#ffb74d" stroke-width="7" stroke-linecap="round"/>
<ellipse cx="66" cy="76" rx="44" ry="30" fill="#ffb74d" {g()}/>
<path d="M32 50 L28 30 L44 42 M60 42 L68 26 L74 46" fill="#ffb74d" {g()}/>
<circle cx="50" cy="60" r="22" fill="#ffb74d" {g()}/>
<g fill="none" stroke="{O}" stroke-width="3" stroke-linecap="round">
<path d="M38 60 Q42 64 46 60"/><path d="M54 60 Q58 64 62 60"/></g>
<g fill="none" stroke="#e65100" stroke-width="3" stroke-linecap="round"><path d="M80 60 L86 72"/><path d="M92 62 L96 74"/></g>
<circle cx="50" cy="68" r="2.5" fill="#e57373"/>''')

A["benda/sepatu"] = svg(bayang(rx=30) + f'''
<path d="M44 14 Q64 6 84 14 Q94 40 90 70 Q90 104 64 114 Q38 104 38 70 Q34 40 44 14 Z" fill="#6d4c41" {g()}/>
<path d="M48 30 Q64 24 80 30 L78 74 Q64 80 50 74 Z" fill="#efebe9" {g('stroke-width="3"')}/>
<g stroke="#6d4c41" stroke-width="3" stroke-linecap="round"><line x1="52" y1="40" x2="76" y2="40"/><line x1="52" y1="50" x2="76" y2="50"/><line x1="52" y1="60" x2="76" y2="60"/></g>''')

A["benda/ember"] = svg(bayang(rx=36) + f'''
<path d="M22 38 Q64 -6 106 38" fill="none" {g()}/>
<path d="M22 38 L32 106 Q64 116 96 106 L106 38 Z" fill="#78909c" {g()}/>
<path d="M27 64 L101 64" stroke="#546e7a" stroke-width="4"/>
<ellipse cx="64" cy="38" rx="42" ry="13" fill="#455a64" {g()}/>
<ellipse cx="64" cy="40" rx="32" ry="7" fill="#90caf9"/>''')

A["benda/sandal_jepit"] = svg(bayang(rx=44) + f'''
<g transform="rotate(-10 40 64)">
<rect x="22" y="16" width="34" height="96" rx="17" fill="#29b6f6" {g()}/>
<path d="M28 58 L39 36 L50 58" fill="none" stroke="#fdd835" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/></g>
<g transform="rotate(10 88 64)">
<rect x="72" y="16" width="34" height="96" rx="17" fill="#29b6f6" {g()}/>
<path d="M78 58 L89 36 L100 58" fill="none" stroke="#fdd835" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/></g>''')

# ---------------------------------------------------------------- wadah & alat
A["benda/kardus"] = svg(bayang(rx=48, cy=114) + f'''
<path d="M14 40 L114 40 L102 18 L26 18 Z" fill="#dcbc94" {g()}/>
<rect x="14" y="40" width="100" height="72" fill="#c8a27a" {g()}/>
<rect x="56" y="18" width="16" height="22" fill="#efdcb5"/>
<path d="M14 40 L114 40 L102 18 L26 18 Z" fill="none" {g()}/>
<rect x="22" y="56" width="84" height="40" rx="4" fill="#efdcb5" {g('stroke-width="2"')}/>''')

A["benda/gunting"] = svg(bayang(rx=30) + f'''
<line x1="46" y1="86" x2="96" y2="14" stroke="{O}" stroke-width="13" stroke-linecap="round"/>
<line x1="82" y1="86" x2="32" y2="14" stroke="{O}" stroke-width="13" stroke-linecap="round"/>
<line x1="46" y1="86" x2="96" y2="14" stroke="#cfd8dc" stroke-width="7" stroke-linecap="round"/>
<line x1="82" y1="86" x2="32" y2="14" stroke="#cfd8dc" stroke-width="7" stroke-linecap="round"/>
<circle cx="40" cy="100" r="14" fill="none" stroke="{O}" stroke-width="12"/>
<circle cx="88" cy="100" r="14" fill="none" stroke="{O}" stroke-width="12"/>
<circle cx="40" cy="100" r="14" fill="none" stroke="#ff7043" stroke-width="6"/>
<circle cx="88" cy="100" r="14" fill="none" stroke="#ff7043" stroke-width="6"/>
<circle cx="64" cy="61" r="5" fill="{O}"/>''')

A["benda/sekop"] = svg(bayang(rx=30) + f'''
<rect x="58" y="8" width="12" height="62" rx="5" fill="#8d6e63" {g()}/>
<rect x="46" y="6" width="36" height="12" rx="6" fill="#8d6e63" {g()}/>
<path d="M40 68 L88 68 L86 98 Q64 122 42 98 Z" fill="#b0bec5" {g()}/>
<path d="M52 76 L52 96" stroke="#eceff1" stroke-width="4" stroke-linecap="round"/>''')

# ---------------------------------------------------------------- penghalang
A["benda/penghalang"] = svg(bayang(rx=52, cy=116) + f'''
<rect x="10" y="44" width="108" height="70" rx="4" fill="#a1673f" {g()}/>
<rect x="26" y="12" width="76" height="40" rx="4" fill="#bf8350" {g()}/>
<g stroke="{O}" stroke-width="3"><line x1="10" y1="79" x2="118" y2="79"/><line x1="64" y1="44" x2="64" y2="114"/><line x1="26" y1="32" x2="102" y2="32"/></g>''')

# Atap rumah dilihat dari atas, dirancang untuk blok 2x4 petak (boleh diregangkan).
genteng = "".join(f'<line x1="8" y1="{y}" x2="120" y2="{y}" stroke="#6d2f22" stroke-width="3"/>' for y in range(28, 250, 20))
A["benda/rumah"] = svg(f'''
<rect x="4" y="4" width="120" height="248" rx="6" fill="#a0503d" {g()}/>
{genteng}
<line x1="64" y1="8" x2="64" y2="248" stroke="#5d261b" stroke-width="7"/>
<rect x="84" y="40" width="22" height="30" rx="3" fill="#8d6e63" {g()}/>
<rect x="80" y="36" width="30" height="8" rx="3" fill="#6d4c41" {g('stroke-width="3"')}/>''', 128, 256)

papan = "".join(f'<line x1="10" y1="{y}" x2="118" y2="{y}" stroke="#8a5530" stroke-width="3"/>' for y in range(46, 180, 34))
A["benda/meja"] = svg(f'''
<rect x="4" y="4" width="120" height="184" rx="10" fill="#c58a52" {g()}/>
<rect x="12" y="12" width="104" height="168" rx="6" fill="#d39b62"/>
{papan}
<ellipse cx="44" cy="62" rx="16" ry="10" fill="#ffffff" {g('stroke-width="3"')}/>
<circle cx="88" cy="128" r="10" fill="#fff8e1" {g('stroke-width="3"')}/>''', 128, 192)

A["benda/rak"] = svg(f'''
<rect x="4" y="4" width="56" height="184" rx="4" fill="#6d4c41" {g()}/>
<g stroke="{O}" stroke-width="3"><line x1="4" y1="66" x2="60" y2="66"/><line x1="4" y1="128" x2="60" y2="128"/></g>
<rect x="12" y="16" width="18" height="22" rx="2" fill="#ffb74d" {g('stroke-width="2.5"')}/>
<rect x="34" y="24" width="18" height="30" rx="2" fill="#90caf9" {g('stroke-width="2.5"')}/>
<circle cx="22" cy="92" r="10" fill="#a5d6a7" {g('stroke-width="2.5"')}/>
<rect x="34" y="80" width="18" height="34" rx="2" fill="#ef9a9a" {g('stroke-width="2.5"')}/>
<rect x="12" y="140" width="40" height="18" rx="2" fill="#ce93d8" {g('stroke-width="2.5"')}/>
<circle cx="32" cy="172" r="8" fill="#fff59d" {g('stroke-width="2.5"')}/>''', 64, 192)

A["benda/wastafel"] = svg(bayang(rx=48, cy=116) + f'''
<rect x="10" y="20" width="108" height="92" rx="12" fill="#eceff1" {g()}/>
<ellipse cx="64" cy="70" rx="38" ry="28" fill="#b0bec5" {g()}/>
<circle cx="64" cy="76" r="5" fill="{O}"/>
<rect x="56" y="18" width="16" height="26" rx="4" fill="#90a4ae" {g()}/>
<path d="M64 44 L64 52" stroke="#90a4ae" stroke-width="7" stroke-linecap="round"/>''')

# ---------------------------------------------------------------- tanaman
DAUN = "#7cb342"


def daun(cx, cy, rx, ry, sudut):
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{DAUN}" {g("stroke-width=\"3\"")} transform="rotate({sudut} {cx} {cy})"/>'


def batang(d):
    return f'<path d="{d}" fill="none" stroke="#33691e" stroke-width="5" stroke-linecap="round"/>'


A["tanaman/tunas"] = svg(f'''
{batang("M64 104 L64 70")}
{daun(48, 66, 16, 8, -30)}{daun(80, 66, 16, 8, 30)}''')

tomat = lambda cx, cy, r, w="#e53935": (f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{w}" {g("stroke-width=\"3\"")}/>'
    f'<path d="M{cx-6} {cy-r+2} L{cx} {cy-r+6} L{cx+6} {cy-r+2}" fill="none" stroke="#33691e" stroke-width="3" stroke-linecap="round"/>')
A["tanaman/tomat_muda"] = svg(batang("M64 110 Q60 70 66 30") + daun(46, 60, 18, 9, -30) + daun(84, 46, 18, 9, 30) + daun(50, 34, 14, 7, -40) + tomat(80, 78, 9, "#9ccc65"))
A["tanaman/tomat_matang"] = svg(batang("M64 110 Q60 70 66 24") + daun(44, 52, 18, 9, -30) + daun(86, 40, 18, 9, 30) + daun(52, 28, 14, 7, -40) + tomat(46, 80, 16) + tomat(84, 72, 15))
A["tanaman/tomat_buah"] = svg(bayang(rx=30) + f'''
<circle cx="64" cy="68" r="40" fill="#e53935" {g()}/>
<path d="M44 36 L56 44 L64 30 L72 44 L84 36 L76 50 L52 50 Z" fill="#43a047" {g('stroke-width="3"')}/>
<ellipse cx="46" cy="60" rx="9" ry="6" fill="#ff8a80" transform="rotate(-30 46 60)"/>''')

wortel_daun = f'<g fill="{DAUN}" {g("stroke-width=\"3\"")}><path d="M64 60 Q50 30 44 14 Q60 26 64 50 Q68 26 84 14 Q78 30 64 60 Z"/></g>'
A["tanaman/wortel_muda"] = svg(f'<g transform="translate(0 20) scale(1 0.8)">{wortel_daun}</g>' + '<ellipse cx="64" cy="98" rx="10" ry="6" fill="#ffa726"/>')
A["tanaman/wortel_matang"] = svg(wortel_daun + f'<path d="M48 60 L80 60 Q76 90 64 100 Q52 90 48 60 Z" fill="#fb8c00" {g()}/>' + '<ellipse cx="64" cy="64" rx="16" ry="5" fill="#ffb74d"/>')
A["tanaman/wortel_buah"] = svg(bayang(rx=24) + f'''
<path d="M64 46 Q50 22 40 8 Q58 18 64 36 Q70 18 88 8 Q78 22 64 46 Z" fill="{DAUN}" {g('stroke-width="3"')}/>
<path d="M42 44 L86 44 Q82 96 64 118 Q46 96 42 44 Z" fill="#fb8c00" {g()}/>
<g stroke="#e65100" stroke-width="3" stroke-linecap="round"><line x1="50" y1="62" x2="60" y2="62"/><line x1="66" y1="78" x2="76" y2="78"/><line x1="54" y1="94" x2="62" y2="94"/></g>''')

A["tanaman/jagung_muda"] = svg(batang("M64 112 L64 30") + daun(46, 70, 24, 7, -35) + daun(82, 56, 24, 7, 35) + daun(48, 40, 20, 6, -40))
jagung_tongkol = lambda: (f'<ellipse cx="78" cy="60" rx="13" ry="26" fill="#fdd835" {g("stroke-width=\"3\"")} transform="rotate(15 78 60)"/>'
    f'<path d="M66 82 Q60 60 70 34" fill="none" stroke="#9ccc65" stroke-width="7" stroke-linecap="round"/>'
    f'<path d="M84 34 Q92 24 88 14" fill="none" stroke="#a1887f" stroke-width="3" stroke-linecap="round"/>')
A["tanaman/jagung_matang"] = svg(batang("M58 112 L58 20") + daun(40, 76, 24, 7, -35) + daun(40, 46, 20, 6, -40) + jagung_tongkol())
biji = "".join(f'<circle cx="{x}" cy="{y}" r="4" fill="#f9a825"/>' for y in range(36, 104, 11) for x in (54, 64, 74))
A["tanaman/jagung_buah"] = svg(bayang(rx=26) + f'''
<ellipse cx="64" cy="68" rx="24" ry="46" fill="#fdd835" {g()}/>
{biji}
<path d="M44 110 Q30 70 46 40 Q52 80 60 112 Z" fill="#9ccc65" {g('stroke-width="3"')}/>
<path d="M84 110 Q98 70 82 40 Q76 80 68 112 Z" fill="#9ccc65" {g('stroke-width="3"')}/>''')

stroberi = lambda cx, cy, s: (f'<path d="M{cx} {cy+s} Q{cx-s} {cy} {cx-s*0.8} {cy-s*0.6} Q{cx} {cy-s*0.9} {cx+s*0.8} {cy-s*0.6} Q{cx+s} {cy} {cx} {cy+s} Z" fill="#e53935" {g("stroke-width=\"3\"")}/>'
    f'<path d="M{cx-s*0.6} {cy-s*0.6} L{cx} {cy-s*0.3} L{cx+s*0.6} {cy-s*0.6} L{cx} {cy-s} Z" fill="#43a047" {g("stroke-width=\"2.5\"")}/>')
A["tanaman/stroberi_muda"] = svg(daun(44, 70, 20, 12, -20) + daun(84, 70, 20, 12, 20) + daun(64, 52, 14, 18, 0) + f'<circle cx="64" cy="84" r="9" fill="#ffffff" {g("stroke-width=\"3\"")}/><circle cx="64" cy="84" r="3" fill="#fdd835"/>')
A["tanaman/stroberi_matang"] = svg(daun(44, 60, 20, 12, -20) + daun(84, 60, 20, 12, 20) + daun(64, 44, 14, 18, 0) + stroberi(46, 88, 15) + stroberi(84, 86, 14))
A["tanaman/stroberi_buah"] = svg(bayang(rx=28) + f'''
<path d="M64 114 Q20 70 28 46 Q64 30 100 46 Q108 70 64 114 Z" fill="#e53935" {g()}/>
<g fill="#fdd835"><circle cx="46" cy="58" r="2.5"/><circle cx="64" cy="54" r="2.5"/><circle cx="82" cy="58" r="2.5"/><circle cx="54" cy="74" r="2.5"/>
<circle cx="74" cy="74" r="2.5"/><circle cx="64" cy="92" r="2.5"/><circle cx="44" cy="76" r="2.5"/><circle cx="84" cy="76" r="2.5"/></g>
<path d="M36 44 L52 46 L50 30 L64 40 L78 30 L76 46 L92 44 L64 56 Z" fill="#43a047" {g('stroke-width="3"')}/>''')

kubis = lambda r: (f'<circle cx="64" cy="66" r="{r}" fill="#9ccc65" {g()}/>'
    f'<circle cx="64" cy="66" r="{r*0.68:.1f}" fill="#aed581" {g("stroke-width=\"3\"")}/>'
    f'<circle cx="64" cy="66" r="{r*0.36:.1f}" fill="#c5e1a5" {g("stroke-width=\"3\"")}/>'
    f'<path d="M64 {66-r} L64 {66-r*0.36:.1f} M{64-r} 66 L{64-r*0.36:.1f} 66 M{64+r} 66 L{64+r*0.36:.1f} 66" stroke="#689f38" stroke-width="3"/>')
A["tanaman/kubis_muda"] = svg(kubis(24))
A["tanaman/kubis_matang"] = svg(daun(30, 90, 18, 10, 30) + daun(98, 90, 18, 10, -30) + kubis(40))
A["tanaman/kubis_buah"] = svg(bayang(rx=36) + kubis(44))

bunga = lambda cx, cy, r: (f'<g fill="#ab47bc" {g("stroke-width=\"3\"")}>' + "".join(
    f'<circle cx="{cx + r*0.9*dx:.1f}" cy="{cy + r*0.9*dy:.1f}" r="{r*0.6:.1f}"/>' for dx, dy in ((0,-1),(0.95,-0.31),(0.59,0.81),(-0.59,0.81),(-0.95,-0.31)))
    + f'</g><circle cx="{cx}" cy="{cy}" r="{r*0.55:.1f}" fill="#fdd835" {g("stroke-width=\"3\"")}/>')
A["tanaman/bunga_muda"] = svg(batang("M64 112 L64 44") + daun(48, 84, 16, 8, -30) + daun(80, 74, 16, 8, 30) + f'<ellipse cx="64" cy="38" rx="9" ry="13" fill="#ce93d8" {g("stroke-width=\"3\"")}/>')
A["tanaman/bunga_matang"] = svg(batang("M64 112 L64 46") + batang("M64 80 Q44 70 36 56") + daun(80, 84, 16, 8, 30) + bunga(64, 36, 16) + bunga(34, 52, 11))
A["tanaman/bunga_buah"] = svg(bayang(rx=28) + bunga(64, 62, 30))

# ---------------------------------------------------------------- karakter
KULIT = "#ffcc80"
BAJU = "#1e88e5"


def topi(cx, cy):
    return (f'<ellipse cx="{cx}" cy="{cy}" rx="34" ry="17" fill="#fbc02d" {g()}/>'
            f'<ellipse cx="{cx}" cy="{cy-6}" rx="18" ry="12" fill="#f9a825" {g("stroke-width=\"3\"")}/>'
            f'<path d="M{cx-18} {cy-2} Q{cx} {cy+4} {cx+18} {cy-2}" fill="none" stroke="#e53935" stroke-width="4"/>')


A["karakter/pemain_bawah"] = svg(bayang(rx=30, cy=116) + f'''
<circle cx="34" cy="86" r="9" fill="{KULIT}" {g('stroke-width="3"')}/><circle cx="94" cy="86" r="9" fill="{KULIT}" {g('stroke-width="3"')}/>
<ellipse cx="64" cy="90" rx="28" ry="24" fill="{BAJU}" {g()}/>
<circle cx="64" cy="58" r="22" fill="{KULIT}" {g()}/>
<circle cx="56" cy="64" r="3.5" fill="{O}"/><circle cx="72" cy="64" r="3.5" fill="{O}"/>
<path d="M58 72 Q64 77 70 72" fill="none" stroke="{O}" stroke-width="3" stroke-linecap="round"/>
<circle cx="50" cy="70" r="4" fill="#ff8a65" fill-opacity="0.6"/><circle cx="78" cy="70" r="4" fill="#ff8a65" fill-opacity="0.6"/>
{topi(64, 44)}''')

A["karakter/pemain_atas"] = svg(bayang(rx=30, cy=116) + f'''
<circle cx="34" cy="80" r="9" fill="{KULIT}" {g('stroke-width="3"')}/><circle cx="94" cy="80" r="9" fill="{KULIT}" {g('stroke-width="3"')}/>
<ellipse cx="64" cy="86" rx="28" ry="24" fill="{BAJU}" {g()}/>
<circle cx="64" cy="60" r="22" fill="#6d4c41" {g()}/>
{topi(64, 54)}''')

A["karakter/pemain_kanan"] = svg(bayang(rx=26, cy=116) + f'''
<ellipse cx="62" cy="90" rx="22" ry="24" fill="{BAJU}" {g()}/>
<circle cx="78" cy="88" r="9" fill="{KULIT}" {g('stroke-width="3"')}/>
<circle cx="64" cy="58" r="22" fill="{KULIT}" {g()}/>
<circle cx="76" cy="62" r="3.5" fill="{O}"/>
<path d="M72 72 Q77 74 80 70" fill="none" stroke="{O}" stroke-width="3" stroke-linecap="round"/>
{topi(64, 44)}''')

A["karakter/pemain_kiri"] = A["karakter/pemain_kanan"].replace(
    'viewBox="0 0 128 128">', 'viewBox="0 0 128 128">\n<g transform="translate(128 0) scale(-1 1)">').replace("\n</svg>", "\n</g>\n</svg>")


def badan(warna, motif=""):
    return f'<path d="M20 124 Q20 84 64 80 Q108 84 108 124 Z" fill="{warna}" {g()}/>{motif}'


def wajah(cy=58):
    return (f'<circle cx="64" cy="{cy}" r="28" fill="{KULIT}" {g()}/>'
            f'<circle cx="54" cy="{cy+2}" r="3.5" fill="{O}"/><circle cx="74" cy="{cy+2}" r="3.5" fill="{O}"/>'
            f'<path d="M56 {cy+14} Q64 {cy+20} 72 {cy+14}" fill="none" stroke="{O}" stroke-width="3" stroke-linecap="round"/>')


A["pembeli/bu_ijah"] = svg(badan("#8e24aa", '<g fill="#fdd835"><circle cx="44" cy="104" r="4"/><circle cx="64" cy="98" r="4"/><circle cx="84" cy="104" r="4"/></g>')
    + f'<path d="M28 70 Q24 22 64 20 Q104 22 100 70 Q100 96 64 98 Q28 96 28 70 Z" fill="#43a047" {g()}/>'
    + f'<ellipse cx="64" cy="62" rx="24" ry="26" fill="{KULIT}" {g()}/>'
    + f'<circle cx="55" cy="62" r="3.5" fill="{O}"/><circle cx="73" cy="62" r="3.5" fill="{O}"/>'
    + f'<path d="M57 74 Q64 80 71 74" fill="none" stroke="{O}" stroke-width="3" stroke-linecap="round"/>')

A["pembeli/mang_ujang"] = svg(badan("#ef6c00") + f'<path d="M30 88 Q64 100 98 88" fill="none" stroke="#ffffff" stroke-width="7" stroke-linecap="round"/>'
    + wajah() + f'<path d="M34 46 Q36 22 64 22 Q92 22 94 46 Z" fill="#455a64" {g()}/>'
    + f'<path d="M30 46 L112 46 Q112 54 96 52 L30 52 Z" fill="#37474f" {g("stroke-width=\"3\"")}/>')

A["pembeli/pak_rt"] = svg(badan("#3949ab", f'<path d="M64 84 L58 124 M64 84 L70 124" stroke="#ffffff" stroke-width="4"/>')
    + wajah() + f'<path d="M52 70 Q64 66 76 70" fill="none" stroke="{O}" stroke-width="5" stroke-linecap="round"/>'
    + f'<g fill="none" stroke="{O}" stroke-width="3"><circle cx="54" cy="60" r="8"/><circle cx="74" cy="60" r="8"/><line x1="62" y1="60" x2="66" y2="60"/></g>'
    + f'<path d="M38 40 L38 26 Q64 16 90 26 L90 40 Q64 34 38 40 Z" fill="#212121" {g("stroke-width=\"3\"")}/>')

# ---------------------------------------------------------------- petak (mulus disambung)
A["petak/halaman_lantai"] = svg(f'''<rect width="128" height="128" fill="#8bc34a"/>
<g fill="none" stroke="#7cb342" stroke-width="4" stroke-linecap="round">
<path d="M24 30 L28 20 L32 30"/><path d="M84 22 L88 12 L92 22"/><path d="M56 70 L60 60 L64 70"/><path d="M14 100 L18 90 L22 100"/><path d="M98 96 L102 86 L106 96"/></g>
<g fill="#ffffff"><circle cx="104" cy="54" r="3"/><circle cx="40" cy="112" r="3"/></g>
<g fill="#fdd835"><circle cx="104" cy="54" r="1.4"/><circle cx="40" cy="112" r="1.4"/></g>''')

semak = "".join(f'<circle cx="{x}" cy="{y}" r="18" fill="#558b2f"/>' for x, y in ((20, 24), (64, 18), (108, 24), (40, 64), (88, 62), (20, 104), (64, 108), (108, 104)))
A["petak/halaman_dinding"] = svg(f'''<rect width="128" height="128" fill="#33691e"/>{semak}
<g fill="#7cb342"><circle cx="58" cy="12" r="5"/><circle cx="34" cy="58" r="5"/><circle cx="82" cy="56" r="5"/><circle cx="58" cy="102" r="5"/></g>''')

A["petak/teras_lantai"] = svg('''<rect width="128" height="128" fill="#f3e0c7"/>
<rect x="0" y="0" width="64" height="64" fill="#ead2b4"/><rect x="64" y="64" width="64" height="64" fill="#ead2b4"/>
<g stroke="#c9a888" stroke-width="3"><line x1="0" y1="1.5" x2="128" y2="1.5"/><line x1="0" y1="64" x2="128" y2="64"/><line x1="1.5" y1="0" x2="1.5" y2="128"/><line x1="64" y1="0" x2="64" y2="128"/></g>''')

bata = "".join(f'<rect x="{x}" y="{y}" width="60" height="28" rx="2" fill="#c0573e" stroke="#7f2f1f" stroke-width="3"/>'
               for y, xs in ((2, (2, 66)), (34, (-30, 34, 98)), (66, (2, 66)), (98, (-30, 34, 98))) for x in xs)
A["petak/teras_dinding"] = svg(f'<rect width="128" height="128" fill="#8d3b28"/>{bata}')

papan_kayu = "".join(f'<rect x="0" y="{y}" width="128" height="30" fill="{w}"/><line x1="0" y1="{y+30}" x2="128" y2="{y+30}" stroke="#7a5230" stroke-width="2"/>'
                     for y, w in ((1, "#b98a5e"), (33, "#c4966a"), (65, "#b98a5e"), (97, "#c4966a")))
A["petak/gudang_lantai"] = svg(f'''<rect width="128" height="128" fill="#a77b52"/>{papan_kayu}
<g stroke="#7a5230" stroke-width="2"><line x1="40" y1="1" x2="40" y2="31"/><line x1="96" y1="33" x2="96" y2="63"/><line x1="24" y1="65" x2="24" y2="95"/><line x1="80" y1="97" x2="80" y2="127"/></g>
<g fill="#7a5230"><circle cx="10" cy="16" r="2"/><circle cx="118" cy="48" r="2"/><circle cx="60" cy="80" r="2"/><circle cx="110" cy="112" r="2"/></g>''')

A["petak/gudang_dinding"] = svg('''<rect width="128" height="128" fill="#4e342e"/>
<g fill="#5d4037" stroke="#3e2723" stroke-width="3"><rect x="2" y="0" width="28" height="128"/><rect x="34" y="0" width="28" height="128"/><rect x="66" y="0" width="28" height="128"/><rect x="98" y="0" width="28" height="128"/></g>
<rect x="0" y="54" width="128" height="20" fill="#6d4c41" stroke="#3e2723" stroke-width="3"/>''')

alur = "".join(f'<path d="M6 {y} Q64 {y-6} 122 {y}" fill="none" stroke="#6d4029" stroke-width="6" stroke-linecap="round"/>' for y in (30, 64, 98))
A["petak/tanah"] = svg(f'''<rect width="128" height="128" rx="10" fill="#8d5a3b" stroke="#5d3a24" stroke-width="5"/>{alur}
<g fill="#a1714f"><circle cx="30" cy="46" r="3"/><circle cx="90" cy="82" r="3"/><circle cx="60" cy="114" r="3"/></g>''')

# ---------------------------------------------------------------- ikon aksi (putih, untuk tombol)
P = 'fill="none" stroke="#ffffff" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"'
A["ui/aksi_identifikasi"] = svg(f'<circle cx="54" cy="54" r="28" {P}/><line x1="76" y1="76" x2="104" y2="104" {P} stroke-width="13"/><path d="M45 46 Q45 37 54 37 Q63 37 63 45 Q63 51 54 55 L54 61" {P} stroke-width="7"/><circle cx="54" cy="71" r="4.5" fill="#ffffff"/>')
A["ui/aksi_ambil"] = svg(f'<path d="M36 70 L36 40 Q36 32 44 32 Q52 32 52 40 L52 62 M52 38 Q52 26 60 26 Q68 26 68 38 L68 62 M68 42 Q68 32 76 32 Q84 32 84 42 L84 64 M84 50 Q84 42 92 42 Q100 42 100 52 L100 80 Q100 108 72 108 Q46 108 36 86 L22 64 Q18 56 26 54 Q32 52 36 60" {P} stroke-width="7"/>')
A["ui/aksi_potong"] = svg(f'<line x1="44" y1="86" x2="100" y2="22" {P}/><line x1="84" y1="86" x2="28" y2="22" {P}/><circle cx="38" cy="100" r="13" {P} stroke-width="7"/><circle cx="90" cy="100" r="13" {P} stroke-width="7"/>')
A["ui/aksi_tanam"] = svg(f'<path d="M64 112 L64 62" {P}/><path d="M64 70 Q40 70 32 46 Q56 44 64 64" {P} stroke-width="7"/><path d="M64 62 Q88 62 96 38 Q72 36 64 56" {P} stroke-width="7"/><line x1="30" y1="112" x2="98" y2="112" {P}/>')
A["ui/aksi_panen"] = svg(f'<path d="M20 56 L108 56 L96 108 L32 108 Z" {P} stroke-width="8"/><path d="M38 56 Q64 10 90 56" {P} stroke-width="7"/><line x1="44" y1="72" x2="48" y2="96" {P} stroke-width="6"/><line x1="64" y1="72" x2="64" y2="96" {P} stroke-width="6"/><line x1="84" y1="72" x2="80" y2="96" {P} stroke-width="6"/>')

import re
ATRIBUT = re.compile(r'([\w:-]+)="([^"]*)"')


def rapikan_tag(cocok):
    # Atribut yang ditulis belakangan menggantikan nilai bawaan (mis. stroke-width).
    nama, isi, tutup = cocok.group(1), cocok.group(2), cocok.group(3)
    atribut = {}
    for k, v in ATRIBUT.findall(isi):
        atribut.pop(k, None)
        atribut[k] = v
    return "<%s %s%s>" % (nama, " ".join(f'{k}="{v}"' for k, v in atribut.items()), tutup)


for nama, isi in A.items():
    isi = re.sub(r'<(\w+)\s([^<>]*?)\s*(/?)>', rapikan_tag, isi)
    jalur = os.path.join(KELUAR, nama + ".svg")
    os.makedirs(os.path.dirname(jalur), exist_ok=True)
    with open(jalur, "w", encoding="utf-8", newline="\n") as f:
        f.write(isi)
print(len(A), "file SVG ditulis")
