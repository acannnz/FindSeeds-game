# Generator aset SVG FindSeeds, gaya adegan modern: garis tipis senada warna,
# bayangan & sorotan lembut, sudut pandang 3/4, palet per tema. Lebar 128 unit
# = 1 petak (diekspor 2x); dasar benda di bawah kanvas.
#
# SVG hasilnya adalah sumber utama dan boleh diedit langsung atau diganti
# ilustrator. PERINGATAN: menjalankan skrip ini lagi MENIMPA file yang ia tulis.
#
# Pemakaian (dari root proyek):  python tools/buat_aset_adegan.py aset
# Setelah itu impor ulang: godot --headless --path . --import
import os, re, sys

KELUAR = sys.argv[1]
SKALA = 2
GELAP_DASAR = (28, 24, 36)


def hx(c):
    c = c.lstrip("#")
    return tuple(int(c[i:i + 2], 16) for i in (0, 2, 4))


def campur(c, ke, f):
    a, b = hx(c), ke
    return "#%02x%02x%02x" % tuple(round(a[i] + (b[i] - a[i]) * f) for i in range(3))


def gelap(c, f=0.35):
    return campur(c, GELAP_DASAR, f)


def terang(c, f=0.35):
    return campur(c, (255, 255, 255), f)


def isi(c, garis=True, tebal=2.5):
    """Atribut fill + garis tepi senada (lebih gelap dari isinya)."""
    if not garis:
        return f'fill="{c}"'
    return f'fill="{c}" stroke="{gelap(c, 0.5)}" stroke-width="{tebal}" stroke-linejoin="round" stroke-linecap="round"'


def garis(c, tebal=3):
    return f'fill="none" stroke="{c}" stroke-width="{tebal}" stroke-linecap="round" stroke-linejoin="round"'


def svg(isi_svg, vw=128, vh=128):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{vw*SKALA}" height="{vh*SKALA}" '
            f'viewBox="0 0 {vw} {vh}">\n{isi_svg}\n</svg>\n')


def bayang(cx, cy, rx, warna="#1f2a14"):
    """Bayangan tanah lembut: dua elips berlapis, warna senada tema."""
    ry = rx * 0.3
    return (f'<ellipse cx="{cx}" cy="{cy}" rx="{rx*1.12:.1f}" ry="{ry*1.25:.1f}" fill="{warna}" fill-opacity="0.12"/>'
            f'<ellipse cx="{cx}" cy="{cy}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{warna}" fill-opacity="0.18"/>')


A = {}

# =============================================================== latar halaman
rumput = "#7fb24a"
bercak = "".join(f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="{c}" fill-opacity="0.55"/>' for x, y, rx, ry, c in (
    (60, 50, 36, 22, "#74a743"), (190, 80, 40, 24, "#86b950"), (110, 170, 44, 26, "#74a743"), (210, 205, 30, 18, "#86b950"), (40, 210, 26, 16, "#86b950")))
rumpun = "".join(f'<path d="M{x} {y} q2 -9 4 0 M{x+5} {y} q2 -12 4 0 M{x+10} {y} q2 -8 4 0" {garis("#6a9a3c", 2)}/>' for x, y in (
    (30, 30), (150, 40), (90, 100), (200, 130), (24, 150), (140, 220), (226, 236), (70, 236)))
bunga_kecil = "".join(f'<circle cx="{x}" cy="{y}" r="2.6" fill="#ffffff"/><circle cx="{x}" cy="{y}" r="1.1" fill="#f6c343"/>' for x, y in (
    (120, 60), (40, 120), (176, 150), (100, 214), (230, 30)))
A["petak/halaman_lantai"] = svg(f'<rect width="256" height="256" fill="{rumput}"/>{bercak}{rumpun}{bunga_kecil}', 256, 256)

def semak_atas(warna_dasar="#4c8a36"):
    daun = "".join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{c}"/>' for x, y, r, c in (
        (14, 18, 20, "#5a9a3f"), (58, 10, 22, "#5a9a3f"), (104, 18, 21, "#5a9a3f"), (34, 52, 22, "#63a545"), (86, 50, 23, "#63a545"),
        (12, 84, 20, "#5a9a3f"), (60, 80, 21, "#5a9a3f"), (110, 86, 20, "#5a9a3f")))
    kilau = "".join(f'<circle cx="{x}" cy="{y}" r="5" fill="#7cbc57"/>' for x, y in ((50, 4), (28, 44), (80, 42), (54, 72), (104, 80)))
    return f'<rect width="128" height="128" fill="{warna_dasar}"/>{daun}{kilau}'

A["petak/halaman_dinding"] = svg(semak_atas())
A["petak/halaman_dinding_muka"] = svg(semak_atas() + '''
<rect x="0" y="80" width="128" height="48" fill="#3c6f2b"/>
<path d="M0 80 Q16 90 32 80 Q48 90 64 80 Q80 90 96 80 Q112 90 128 80 L128 86 L0 86 Z" fill="#4c8a36"/>
<g fill="#33612a"><ellipse cx="18" cy="104" rx="10" ry="14"/><ellipse cx="54" cy="108" rx="11" ry="13"/><ellipse cx="92" cy="104" rx="10" ry="14"/><ellipse cx="120" cy="108" rx="8" ry="13"/></g>
<rect x="0" y="122" width="128" height="6" fill="#2a4f20"/>''')

# Dinding bersisi muka untuk tema lain (sementara, gaya baru).
A["petak/teras_dinding_muka"] = svg('''<rect width="128" height="128" fill="#a9563f"/>
<rect x="0" y="0" width="128" height="74" fill="#b8644b"/>
<g fill="#c4705a"><rect x="4" y="6" width="56" height="26" rx="2"/><rect x="68" y="6" width="56" height="26" rx="2"/><rect x="-24" y="40" width="56" height="26" rx="2"/><rect x="36" y="40" width="56" height="26" rx="2"/><rect x="100" y="40" width="56" height="26" rx="2"/></g>
<rect x="0" y="74" width="128" height="54" fill="#8c4533"/>
<g fill="#97503c"><rect x="4" y="80" width="56" height="18" rx="2"/><rect x="68" y="80" width="56" height="18" rx="2"/><rect x="-24" y="104" width="56" height="18" rx="2"/><rect x="36" y="104" width="56" height="18" rx="2"/><rect x="100" y="104" width="56" height="18" rx="2"/></g>
<rect x="0" y="72" width="128" height="5" fill="#d48a6f"/>''')
A["petak/gudang_dinding_muka"] = svg('''<rect width="128" height="128" fill="#5a3f30"/>
<g fill="#6b4b39"><rect x="2" y="0" width="28" height="74"/><rect x="34" y="0" width="28" height="74"/><rect x="66" y="0" width="28" height="74"/><rect x="98" y="0" width="28" height="74"/></g>
<rect x="0" y="74" width="128" height="54" fill="#47311f"/>
<g fill="#523a28"><rect x="2" y="78" width="28" height="50"/><rect x="34" y="78" width="28" height="50"/><rect x="66" y="78" width="28" height="50"/><rect x="98" y="78" width="28" height="50"/></g>
<rect x="0" y="72" width="128" height="5" fill="#8a6548"/>''')

alur = "".join(f'<path d="M14 {y} Q64 {y-5} 114 {y}" {garis("#6a3f27", 7)}/><path d="M14 {y-4} Q64 {y-9} 114 {y-4}" {garis("#a36d4b", 3)}/>' for y in (36, 66, 96))
A["petak/tanah"] = svg(f'''<rect x="6" y="6" width="116" height="116" rx="18" fill="#875737"/>
<rect x="6" y="6" width="116" height="116" rx="18" fill="none" stroke="#6a4129" stroke-width="3"/>{alur}''')

# =============================================================== benda stage 1-1
def bola(cx, cy, r, warna, kilau=True):
    s = f'<circle cx="{cx}" cy="{cy}" r="{r}" {isi(warna)}/>'
    s += f'<path d="M{cx+r*0.92:.1f} {cy+r*0.35:.1f} A{r} {r} 0 0 1 {cx-r*0.55:.1f} {cy+r*0.84:.1f} A{r*1.05:.1f} {r*1.05:.1f} 0 0 0 {cx+r*0.92:.1f} {cy+r*0.35:.1f} Z" fill="{gelap(warna, 0.22)}"/>'
    if kilau:
        s += f'<ellipse cx="{cx-r*0.38:.1f}" cy="{cy-r*0.42:.1f}" rx="{r*0.3:.1f}" ry="{r*0.18:.1f}" fill="#ffffff" fill-opacity="0.6" transform="rotate(-35 {cx-r*0.38:.1f} {cy-r*0.42:.1f})"/>'
    return s

A["benda/bola_karet_merah"] = svg(bayang(64, 116, 30) + bola(64, 86, 30, "#e2483d")
    + f'<path d="M36 92 Q64 108 92 92" {garis(gelap("#e2483d", 0.3), 2.5)}/>')

A["benda/ember"] = svg(bayang(64, 116, 32) + f'''
<path d="M34 64 L40 112 Q64 120 88 112 L94 64 Z" {isi("#7fa7bf")}/>
<path d="M74 66 L94 64 L88 112 Q80 115 72 116 Z" fill="{gelap("#7fa7bf", 0.15)}"/>
<path d="M37 84 L91 84" {garis(gelap("#7fa7bf", 0.25), 3)}/>
<ellipse cx="64" cy="64" rx="31" ry="10" {isi(terang("#7fa7bf", 0.2))}/>
<ellipse cx="64" cy="65" rx="24" ry="6" fill="#4d6b7d"/>
<path d="M34 64 Q64 22 94 64" {garis("#56707f", 3)}/>''')

def sandal(x, sudut):
    return (f'<g transform="rotate({sudut} {x} 96)"><rect x="{x-13}" y="72" width="26" height="46" rx="13" {isi("#3fb5e8")}/>'
            f'<rect x="{x-9}" y="76" width="18" height="38" rx="9" fill="{terang("#3fb5e8", 0.25)}"/>'
            f'<path d="M{x-9} 98 L{x} 82 L{x+9} 98" {garis("#f2c230", 4.5)}/></g>')
A["benda/sandal_jepit"] = svg(bayang(64, 118, 38) + sandal(46, -12) + sandal(82, 10))

# Rumah 2x4 petak dalam 3/4: atap dua bidang + fasad depan.
genteng_belakang = "".join(f'<path d="M14 {y} L242 {y}" {garis("#8a3a2b", 2.5)}/>' for y in range(60, 300, 22))
genteng_depan = "".join(f'<path d="M14 {y} L242 {y}" {garis("#7a3124", 2.5)}/>' for y in range(320, 470, 22))
A["benda/rumah"] = svg(f'''
<ellipse cx="128" cy="594" rx="128" ry="12" fill="#1f2a14" fill-opacity="0.18"/>
<path d="M10 40 L246 40 L246 300 L10 300 Z" {isi("#c0553f")}/>{genteng_belakang}
<path d="M10 300 L246 300 L238 470 L18 470 Z" {isi("#a8473a")}/>{genteng_depan}
<rect x="6" y="294" width="244" height="12" rx="5" fill="#7a2f22"/>
<rect x="170" y="70" width="34" height="58" rx="3" {isi("#9c7b67")}/>
<rect x="164" y="64" width="46" height="12" rx="4" {isi("#7f6252")}/>
<rect x="18" y="470" width="220" height="118" {isi("#f1e3c8")}/>
<rect x="18" y="470" width="220" height="14" fill="#d8c6a6"/>
<rect x="44" y="504" width="62" height="50" rx="4" {isi("#9fd3e8")}/>
<path d="M75 504 L75 554 M44 529 L106 529" {garis("#ffffff", 3)}/>
<rect x="148" y="500" width="54" height="88" rx="4" {isi("#8a5a3b")}/>
<circle cx="192" cy="548" r="4" fill="#f2c230"/>
<rect x="140" y="584" width="70" height="8" rx="3" fill="#b9a78c"/>''', 256, 600)

# --- hiasan halaman
A["benda/mawar_merah"] = svg(bayang(64, 116, 40) + f'''
<path d="M20 112 Q12 76 34 66 Q40 44 64 50 Q88 42 96 66 Q118 74 108 112 Z" {isi("#4f8f3a")}/>
<path d="M64 112 Q60 84 78 70 Q96 70 102 88 Q110 100 108 112 Z" fill="{gelap("#4f8f3a", 0.15)}"/>
''' + "".join(f'<circle cx="{x}" cy="{y}" r="{r}" {isi("#d8394a")}/><path d="M{x-r*0.5:.1f} {y} a{r*0.5:.1f} {r*0.5:.1f} 0 1 1 {r*0.5:.1f} {r*0.45:.1f}" {garis(gelap("#d8394a", 0.35), 2)}/>'
              for x, y, r in ((40, 74, 11), (66, 62, 12), (90, 78, 11), (56, 92, 10), (82, 98, 9))))

A["benda/sepeda_roda_tiga"] = svg(bayang(64, 116, 40) + f'''
<circle cx="30" cy="102" r="12" {isi("#3a3a46")}/><circle cx="30" cy="102" r="5" fill="#b9bcc6"/>
<circle cx="98" cy="102" r="12" {isi("#3a3a46")}/><circle cx="98" cy="102" r="5" fill="#b9bcc6"/>
<path d="M30 96 L64 80 L98 96" {garis("#c93b33", 7)}/>
<path d="M64 80 L80 52" {garis("#c93b33", 7)}/>
<circle cx="80" cy="76" r="17" {isi("#3a3a46")}/><circle cx="80" cy="76" r="7" fill="#b9bcc6"/>
<path d="M68 48 L92 48" {garis("#3a3a46", 6)}/>
<ellipse cx="54" cy="74" rx="14" ry="7" {isi("#2f2f3a")}/>''')

A["benda/batu_bulat"] = svg(bayang(64, 114, 34) + f'''
<path d="M30 108 Q22 74 46 62 Q64 52 86 62 Q108 74 100 108 Z" {isi("#9a9ea8")}/>
<path d="M70 108 Q88 92 86 64 Q106 76 100 108 Z" fill="{gelap("#9a9ea8", 0.18)}"/>
<ellipse cx="52" cy="72" rx="12" ry="6" fill="#ffffff" fill-opacity="0.35"/>
<path d="M44 94 Q52 90 58 94" {garis(gelap("#9a9ea8", 0.3), 2)}/>''')

A["benda/kaleng_siram"] = svg(bayang(60, 116, 34) + f'''
<path d="M88 74 L118 54 L122 60 L94 84" {isi("#3e9e6e")}/>
<ellipse cx="120" cy="56" rx="6" ry="8" {isi("#2f7f57")} transform="rotate(-35 120 56)"/>
<path d="M28 66 L32 110 Q58 118 84 110 L88 66 Z" {isi("#47b07c")}/>
<path d="M66 68 L88 66 L84 110 Q76 113 68 114 Z" fill="{gelap("#47b07c", 0.15)}"/>
<ellipse cx="58" cy="66" rx="30" ry="9" {isi(terang("#47b07c", 0.2))}/>
<path d="M36 64 Q58 30 80 64" {garis("#2f7f57", 6)}/>''')

A["benda/selang_air"] = svg(bayang(64, 116, 36) + f'''
<rect x="56" y="54" width="16" height="58" rx="4" {isi("#8b8f99")}/>
<circle cx="64" cy="82" r="30" {isi("#2f9a4f")}/>
''' + "".join(f'<circle cx="64" cy="82" r="{r}" {garis(c, 4)}/>' for r, c in ((24, "#3fb361"), (17, "#2f9a4f"), (10, "#3fb361")))
    + f'<circle cx="64" cy="82" r="5" fill="#d9dbe0"/><path d="M90 96 Q110 108 104 116" {garis("#2f9a4f", 6)}/>')

A["benda/kursi_taman"] = svg(bayang(64, 118, 34) + f'''
<path d="M34 112 L38 78 M94 112 L90 78" {garis("#cfd6d8", 6)}/>
<path d="M34 112 L38 78 M94 112 L90 78" {garis(gelap("#e9eef0", 0.4), 1.5)}/>
<path d="M32 40 Q64 26 96 40 L92 74 L36 74 Z" {isi("#e9eef0")}/>
<path d="M44 44 L44 70 M64 38 L64 70 M84 44 L84 70" {garis("#cfd6d8", 3)}/>
<path d="M30 74 L98 74 L94 92 L34 92 Z" {isi("#f6f9fa")}/>
<path d="M34 92 L94 92 L92 98 L36 98 Z" fill="#cfd6d8"/>''')

A["benda/pot_kaktus"] = svg(bayang(64, 116, 28) + f'''
<path d="M42 82 L86 82 L80 114 L48 114 Z" {isi("#cf7449")}/>
<rect x="38" y="76" width="52" height="12" rx="4" {isi("#e08458")}/>
<path d="M54 78 L54 34 Q54 22 64 22 Q74 22 74 34 L74 78 Z" {isi("#58a35a")}/>
<path d="M54 56 L44 56 Q38 56 38 48 L38 40" {garis("#58a35a", 10)}/>
<path d="M74 50 L84 50 Q90 50 90 42 L90 36" {garis("#58a35a", 10)}/>
<path d="M64 26 L64 76" {garis(gelap("#58a35a", 0.25), 2)}/>
<circle cx="64" cy="20" r="5" fill="#f28fb0"/>''')

A["benda/tong_sampah"] = svg(bayang(64, 118, 32) + f'''
<path d="M36 52 L42 112 Q64 120 86 112 L92 52 Z" {isi("#3f8a6a")}/>
<path d="M70 54 L92 52 L86 112 Q78 115 70 116 Z" fill="{gelap("#3f8a6a", 0.15)}"/>
<path d="M50 62 L52 104 M64 62 L64 106 M78 62 L76 104" {garis(gelap("#3f8a6a", 0.25), 3)}/>
<ellipse cx="64" cy="50" rx="32" ry="10" {isi("#4fa07c")}/>
<rect x="56" y="38" width="16" height="8" rx="3" {isi("#2f6e53")}/>''')

A["benda/mobil_mainan"] = svg(bayang(64, 114, 38) + f'''
<rect x="22" y="78" width="84" height="26" rx="10" {isi("#3a7bd5")}/>
<path d="M40 80 L50 60 L82 60 L92 80 Z" {isi("#5a96e6")}/>
<path d="M54 64 L60 78 M76 64 L72 78" {garis("#cfe6ff", 4)}/>
<circle cx="42" cy="106" r="10" {isi("#33333d")}/><circle cx="86" cy="106" r="10" {isi("#33333d")}/>
<circle cx="42" cy="106" r="4" fill="#c8ccd6"/><circle cx="86" cy="106" r="4" fill="#c8ccd6"/>
<circle cx="102" cy="86" r="3" fill="#f6d365"/>''')

# =============================================================== karakter
KULIT = "#f6c79e"


def topi_jerami(cx, cy):
    return (f'<ellipse cx="{cx}" cy="{cy}" rx="34" ry="15" {isi("#f2c14e")}/>'
            f'<ellipse cx="{cx}" cy="{cy-5}" rx="19" ry="12" {isi("#e8b03b")}/>'
            f'<path d="M{cx-19} {cy-2} Q{cx} {cy+5} {cx+19} {cy-2}" {garis("#d9534f", 4)}/>')


def badan_pemain(cx=64):
    return (f'<path d="M{cx-11} 140 L{cx-11} 152 M{cx+11} 140 L{cx+11} 152" {garis("#3b4a6b", 9)}/>'
            f'<path d="M{cx-26} 140 Q{cx-28} 102 {cx} 98 Q{cx+28} 102 {cx+26} 140 Z" {isi("#3d8fe0")}/>'
            f'<path d="M{cx-26} 128 L{cx+26} 128 L{cx+26} 140 L{cx-26} 140 Z" fill="#3b4a6b"/>')


A["karakter/pemain_bawah"] = svg(bayang(64, 152, 26) + f'''
<circle cx="34" cy="118" r="8" {isi(KULIT)}/><circle cx="94" cy="118" r="8" {isi(KULIT)}/>
{badan_pemain()}
<circle cx="64" cy="78" r="24" {isi(KULIT)}/>
<circle cx="55" cy="83" r="3.4" fill="#3a2e2a"/><circle cx="73" cy="83" r="3.4" fill="#3a2e2a"/>
<path d="M58 93 Q64 98 70 93" {garis("#a0523d", 2.5)}/>
<circle cx="48" cy="91" r="4.5" fill="#f19b8a" fill-opacity="0.55"/><circle cx="80" cy="91" r="4.5" fill="#f19b8a" fill-opacity="0.55"/>
{topi_jerami(64, 62)}''', 128, 160)

A["karakter/pemain_atas"] = svg(bayang(64, 152, 26) + f'''
<circle cx="34" cy="114" r="8" {isi(KULIT)}/><circle cx="94" cy="114" r="8" {isi(KULIT)}/>
{badan_pemain()}
<circle cx="64" cy="80" r="24" {isi("#5d3f30")}/>
{topi_jerami(64, 72)}''', 128, 160)

A["karakter/pemain_kanan"] = svg(bayang(64, 152, 24) + f'''
{badan_pemain(62)}
<circle cx="74" cy="116" r="8" {isi(KULIT)}/>
<circle cx="64" cy="78" r="24" {isi(KULIT)}/>
<circle cx="76" cy="83" r="3.4" fill="#3a2e2a"/>
<path d="M74 93 Q79 95 83 91" {garis("#a0523d", 2.5)}/>
<circle cx="70" cy="91" r="4.5" fill="#f19b8a" fill-opacity="0.55"/>
{topi_jerami(64, 62)}''', 128, 160)

A["karakter/pemain_kiri"] = A["karakter/pemain_kanan"].replace(
    'viewBox="0 0 128 160">', 'viewBox="0 0 128 160">\n<g transform="translate(128 0) scale(-1 1)">').replace("\n</svg>", "\n</g>\n</svg>")

A["pembeli/bu_ijah"] = svg(bayang(64, 120, 34) + f'''
<path d="M24 122 Q22 88 64 84 Q106 88 104 122 Z" {isi("#8e44ad")}/>
<g fill="#f6d365"><circle cx="44" cy="106" r="3.5"/><circle cx="64" cy="100" r="3.5"/><circle cx="84" cy="106" r="3.5"/></g>
<path d="M30 74 Q26 26 64 24 Q102 26 98 74 Q98 98 64 100 Q30 98 30 74 Z" {isi("#3f9a5b")}/>
<ellipse cx="64" cy="66" rx="23" ry="25" {isi(KULIT)}/>
<circle cx="55" cy="66" r="3.2" fill="#3a2e2a"/><circle cx="73" cy="66" r="3.2" fill="#3a2e2a"/>
<path d="M57 78 Q64 83 71 78" {garis("#a0523d", 2.5)}/>
<circle cx="49" cy="74" r="4" fill="#f19b8a" fill-opacity="0.5"/><circle cx="79" cy="74" r="4" fill="#f19b8a" fill-opacity="0.5"/>''')

# =============================================================== tanaman (tomat + tunas)
DAUN = "#5fae4b"


def daun(cx, cy, rx, ry, sudut):
    return (f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" {isi(DAUN, tebal=2)} transform="rotate({sudut} {cx} {cy})"/>'
            f'<path d="M{cx-rx*0.7:.1f} {cy} L{cx+rx*0.7:.1f} {cy}" {garis(gelap(DAUN, 0.2), 1.5)} transform="rotate({sudut} {cx} {cy})"/>')


def batang(d):
    return f'<path d="{d}" {garis("#3f7f34", 5)}/>'


def tomat(cx, cy, r, w="#e2483d"):
    return (bola(cx, cy, r, w) +
            f'<path d="M{cx-6} {cy-r+3} L{cx} {cy-r+7} L{cx+6} {cy-r+3} M{cx} {cy-r+7} L{cx} {cy-r}" {garis("#3f7f34", 2.5)}/>')


A["tanaman/tunas"] = svg(batang("M64 110 L64 78") + daun(50, 74, 14, 7, -30) + daun(78, 74, 14, 7, 30))
A["tanaman/tomat_muda"] = svg(batang("M64 112 Q60 74 66 36") + daun(46, 66, 17, 8, -30) + daun(84, 52, 17, 8, 30) + daun(50, 40, 13, 6, -40) + tomat(80, 84, 9, "#a7cf6b"))
A["tanaman/tomat_matang"] = svg(batang("M64 112 Q60 74 66 30") + daun(44, 58, 17, 8, -30) + daun(86, 46, 17, 8, 30) + daun(52, 34, 13, 6, -40) + tomat(46, 86, 15) + tomat(84, 78, 14))
A["tanaman/tomat_buah"] = svg(bayang(64, 116, 30) + bola(64, 76, 36, "#e2483d") + f'''
<path d="M46 46 L58 52 L64 38 L70 52 L82 46 L76 58 L52 58 Z" {isi("#4f9e3f", tebal=2)}/>''')


# --- tempelan lantai halaman (datar, tanpa bayangan)
A["petak/halaman_bunga"] = svg("".join(
    f'<circle cx="{x}" cy="{y}" r="9" fill="{c}"/><circle cx="{x}" cy="{y}" r="3.5" fill="#f6d365"/>'
    for x, y, c in ((40, 56, "#ffffff"), (70, 44, "#f48fb1"), (90, 70, "#ffffff"), (56, 82, "#ce93d8"), (80, 96, "#f48fb1")))
    + f'<path d="M30 70 q6 -10 12 0 M96 88 q6 -10 12 0 M48 100 q6 -10 12 0" {garis("#5f9a3a", 3)}/>')
A["petak/halaman_batu_pijakan"] = svg("".join(
    f'<ellipse cx="{x}" cy="{y}" rx="{rx}" ry="{ry}" fill="#c9c3b6" stroke="#a49d8f" stroke-width="2.5"/>'
    for x, y, rx, ry in ((44, 50, 22, 14), (86, 82, 24, 15))))
A["petak/halaman_daun"] = svg("".join(
    f'<ellipse cx="{x}" cy="{y}" rx="10" ry="5" fill="{c}" transform="rotate({s} {x} {y})"/>'
    for x, y, c, s in ((40, 50, "#d9a441", 30), (76, 40, "#c97d34", -20), (60, 76, "#e0b44f", 60), (92, 84, "#c97d34", 10), (34, 90, "#d9a441", -40))))
A["petak/halaman_rumput"] = svg("".join(
    f'<path d="M{x} {y} q-4 -18 -10 -26 M{x} {y} q0 -22 2 -30 M{x} {y} q6 -16 12 -24" {garis(c, 3.5)}/>'
    for x, y, c in ((40, 80, "#5f9a3a"), (78, 66, "#6aa842"), (92, 104, "#5f9a3a"))))

# ------------------------------------------------------------------ tulis
ATRIBUT = re.compile(r'([\w:-]+)="([^"]*)"')


def rapikan_tag(cocok):
    nama, isi_tag, tutup = cocok.group(1), cocok.group(2), cocok.group(3)
    atribut = {}
    for k, v in ATRIBUT.findall(isi_tag):
        atribut.pop(k, None)
        atribut[k] = v
    return "<%s %s%s>" % (nama, " ".join(f'{k}="{v}"' for k, v in atribut.items()), tutup)


for nama, isi_svg in A.items():
    isi_svg = re.sub(r'<(\w+)\s([^<>]*?)\s*(/?)>', rapikan_tag, isi_svg)
    jalur = os.path.join(KELUAR, nama + ".svg")
    os.makedirs(os.path.dirname(jalur), exist_ok=True)
    with open(jalur, "w", encoding="utf-8", newline="\n") as f:
        f.write(isi_svg)
print(len(A), "file SVG gaya baru ditulis")
