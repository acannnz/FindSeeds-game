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

# Warna bayangan senada per tema.
B_TERAS = "#3a2716"
B_GUDANG = "#1e140c"

# =============================================================== latar teras
ubin = "".join(f'<rect x="{x}" y="{y}" width="64" height="64" fill="{"#e9c9a1" if (x // 64 + y // 64) % 2 == 0 else "#e2bd92"}"/>'
               for x in range(0, 256, 64) for y in range(0, 256, 64))
nat = "".join(f'<path d="M{v} 0 L{v} 256 M0 {v} L256 {v}" {garis("#c9a27f", 2)}/>' for v in (0, 64, 128, 192))
kilap_ubin = "".join(f'<path d="M{x+10} {y+14} L{x+24} {y+10}" {garis("#f4dcbd", 3)}/>' for x in range(0, 256, 64) for y in range(0, 256, 64))
A["petak/teras_lantai"] = svg(f'<rect width="256" height="256" fill="#e5c39a"/>{ubin}{nat}{kilap_ubin}', 256, 256)
A["petak/teras_dinding"] = svg('''<rect width="128" height="128" fill="#b8644b"/>
<g fill="#c4705a"><rect x="4" y="6" width="56" height="26" rx="2"/><rect x="68" y="6" width="56" height="26" rx="2"/><rect x="-24" y="38" width="56" height="26" rx="2"/><rect x="36" y="38" width="56" height="26" rx="2"/><rect x="100" y="38" width="56" height="26" rx="2"/>
<rect x="4" y="70" width="56" height="26" rx="2"/><rect x="68" y="70" width="56" height="26" rx="2"/><rect x="-24" y="102" width="56" height="26" rx="2"/><rect x="36" y="102" width="56" height="26" rx="2"/><rect x="100" y="102" width="56" height="26" rx="2"/></g>''')
A["petak/teras_keset"] = svg(f'''<rect x="20" y="36" width="88" height="56" rx="8" fill="#2f7f86"/>
<rect x="28" y="44" width="72" height="40" rx="5" fill="#46a0a6"/>{"".join(f'<path d="M{x} 46 L{x} 82" {garis("#2f7f86", 3)}/>' for x in range(36, 100, 10))}''')
A["petak/teras_daun"] = A["petak/halaman_daun"]
A["petak/teras_noda"] = svg('<ellipse cx="62" cy="66" rx="34" ry="18" fill="#d4ae86" fill-opacity="0.7"/><ellipse cx="80" cy="74" rx="14" ry="8" fill="#d4ae86" fill-opacity="0.7"/>')
A["petak/teras_kerikil"] = svg("".join(f'<ellipse cx="{x}" cy="{y}" rx="{r}" ry="{r*0.7:.1f}" fill="{c}"/>' for x, y, r, c in (
    (40, 60, 5, "#b9ab98"), (52, 68, 4, "#9c8f7c"), (78, 52, 6, "#b9ab98"), (86, 84, 4, "#9c8f7c"), (60, 92, 5, "#b9ab98"))))

# =============================================================== latar gudang
papan_gudang = "".join(f'<rect x="0" y="{y}" width="256" height="32" fill="{c}"/><path d="M0 {y+32} L256 {y+32}" {garis("#6e4c31", 2)}/>'
                       for y, c in zip(range(0, 256, 32), ("#a77b52", "#b0835a", "#9f744c", "#ab7f56") * 2))
sambungan = "".join(f'<path d="M{x} {y} L{x} {y+32}" {garis("#6e4c31", 2)}/>' for x, y in (
    (70, 0), (190, 32), (40, 64), (150, 96), (220, 128), (90, 160), (30, 192), (170, 224)))
mata_kayu = "".join(f'<ellipse cx="{x}" cy="{y}" rx="5" ry="3" fill="#8a6141"/>' for x, y in ((120, 16), (60, 80), (200, 112), (130, 176), (230, 240)))
A["petak/gudang_lantai"] = svg(f'{papan_gudang}{sambungan}{mata_kayu}', 256, 256)
A["petak/gudang_dinding"] = svg('''<rect width="128" height="128" fill="#5a3f30"/>
<g fill="#6b4b39"><rect x="2" y="0" width="28" height="128"/><rect x="34" y="0" width="28" height="128"/><rect x="66" y="0" width="28" height="128"/><rect x="98" y="0" width="28" height="128"/></g>
<rect x="0" y="56" width="128" height="14" fill="#7a5640"/>''')
A["petak/gudang_jerami"] = svg("".join(f'<path d="M{x} {y} l{dx} {dy}" {garis(c, 3)}/>' for x, y, dx, dy, c in (
    (30, 60, 30, -8, "#e3c46a"), (40, 70, 34, 6, "#d6b55a"), (56, 54, 28, 14, "#e3c46a"), (70, 80, 30, -10, "#d6b55a"), (36, 86, 26, 2, "#e3c46a"))))
A["petak/gudang_serbuk"] = svg("".join(f'<circle cx="{x}" cy="{y}" r="2.2" fill="#d9b88a"/>' for x, y in (
    (40, 50), (48, 58), (56, 48), (62, 64), (72, 56), (80, 70), (52, 74), (66, 80), (86, 60), (44, 68))))
A["petak/gudang_noda_oli"] = svg('<ellipse cx="64" cy="66" rx="36" ry="20" fill="#3b2e26" fill-opacity="0.55"/><ellipse cx="52" cy="60" rx="10" ry="4" fill="#ffffff" fill-opacity="0.12"/>')
A["petak/gudang_paku"] = svg("".join(f'<g transform="rotate({s} {x} {y})"><path d="M{x-10} {y} L{x+10} {y}" {garis("#8d949c", 2.5)}/><path d="M{x-10} {y-3} L{x-10} {y+3}" {garis("#6d737a", 3)}/></g>'
    for x, y, s in ((44, 54, 20), (78, 70, -35), (58, 88, 60))))


# =============================================================== benda teras (1-2)
def kaki_jam(cx):
    return f'<path d="M{cx-18} 98 L{cx-24} 114 M{cx+18} 98 L{cx+24} 114" {garis("#5a2a22", 5)}/>'


A["benda/jam_weker_merah"] = svg(bayang(64, 116, 30, B_TERAS) + kaki_jam(64) + f'''
<circle cx="40" cy="50" r="11" {isi("#cf4339")}/><circle cx="88" cy="50" r="11" {isi("#cf4339")}/>
<rect x="60" y="36" width="8" height="12" rx="3" {isi("#f2c230")}/>
{bola(64, 78, 30, "#d8453b", kilau=False)}
<circle cx="64" cy="78" r="20" {isi("#fff7e8")}/>
<g fill="#5a2a22"><circle cx="64" cy="62" r="2"/><circle cx="80" cy="78" r="2"/><circle cx="64" cy="94" r="2"/><circle cx="48" cy="78" r="2"/></g>
<path d="M64 78 L64 66 M64 78 L74 82" {garis("#3a2e2a", 3)}/><circle cx="64" cy="78" r="3" fill="#3a2e2a"/>''')

A["benda/kerucut_lalu_lintas"] = svg(bayang(64, 116, 36, B_TERAS) + f'''
<path d="M24 104 L104 104 L98 116 L30 116 Z" {isi("#3d3d48")}/>
<path d="M64 18 L92 106 L36 106 Z" {isi("#f07f2a")}/>
<path d="M64 18 L92 106 L68 106 Z" fill="{gelap("#f07f2a", 0.15)}"/>
<path d="M52 58 L76 58 L81 74 L47 74 Z" fill="#fbfbfb"/><path d="M58 38 L70 38 L73 46 L55 46 Z" fill="#fbfbfb"/>
<path d="M64 18 L92 106 L36 106 Z" fill="none" stroke="{gelap("#f07f2a", 0.5)}" stroke-width="2.5" stroke-linejoin="round"/>''')

A["benda/pot_bunga"] = svg(bayang(64, 116, 28, B_TERAS) + f'''
<path d="M42 80 L86 80 L80 114 L48 114 Z" {isi("#cf7449")}/>
<path d="M68 80 L86 80 L80 114 L70 114 Z" fill="{gelap("#cf7449", 0.15)}"/>
<rect x="38" y="74" width="52" height="12" rx="4" {isi("#e08458")}/>
<path d="M64 76 L64 46 M52 76 L44 52 M76 76 L86 52" {garis("#3f7f34", 4)}/>
''' + "".join(f'<circle cx="{x}" cy="{y}" r="{r}" {isi(c)}/><circle cx="{x}" cy="{y}" r="{r*0.38:.1f}" fill="#f6d365"/>' for x, y, r, c in (
    (64, 38, 13, "#9b59b6"), (42, 48, 11, "#c39bd3"), (88, 48, 11, "#c39bd3"))))

A["benda/kaleng_cat_merah"] = svg(bayang(64, 116, 32, B_TERAS) + f'''
<path d="M34 58 L34 108 Q64 118 94 108 L94 58 Z" {isi("#a9b4bd")}/>
<path d="M34 70 L94 70 L94 96 Q64 104 34 96 Z" fill="#cf3f36"/>
<path d="M76 58 L94 58 L94 108 Q86 112 76 114 Z" fill="{gelap("#a9b4bd", 0.12)}" fill-opacity="0.8"/>
<ellipse cx="64" cy="58" rx="30" ry="9" {isi("#c7d0d6")}/>
<ellipse cx="64" cy="58" rx="22" ry="5" fill="#cf3f36"/>
<path d="M84 62 Q87 74 83 80" {garis("#cf3f36", 5)}/>
<path d="M38 56 Q64 22 90 56" {garis("#6d7780", 3)}/>''')

A["benda/bola_tenis"] = svg(bayang(64, 116, 22, B_TERAS) + bola(64, 92, 22, "#d4e157") + f'''
<path d="M46 80 Q58 92 46 106" {garis("#ffffff", 3.5)}/><path d="M82 80 Q70 92 82 106" {garis("#ffffff", 3.5)}/>''')

A["benda/kucing_tidur"] = svg(bayang(64, 116, 40, B_TERAS) + f'''
<path d="M98 102 Q120 84 104 64" {garis(gelap("#f0a650", 0.4), 12)}/><path d="M98 102 Q120 84 104 64" {garis("#f0a650", 7)}/>
<ellipse cx="66" cy="94" rx="38" ry="22" {isi("#f0a650")}/>
<path d="M66 116 Q96 112 102 96 Q96 108 66 108 Z" fill="{gelap("#f0a650", 0.15)}"/>
<path d="M36 74 L32 56 L46 66 M56 66 L64 52 L68 70" {isi("#f0a650")}/>
<circle cx="50" cy="82" r="20" {isi("#f0a650")}/>
<path d="M40 82 Q44 86 48 82 M54 82 Q58 86 62 82" {garis("#5a3a22", 2.5)}/>
<path d="M76 80 L82 92 M88 80 L92 94" {garis("#d98a3a", 3)}/>
<circle cx="51" cy="90" r="2.5" fill="#e88a8a"/>''')

# Meja 2x3 petak (3/4): taplak kotak-kotak di atas, sisi muka + kaki di bawah.
kotak_taplak = "".join(f'<rect x="{x}" y="{y}" width="24" height="24" fill="#f3d2c4"/>' for x in range(24, 232, 48) for y in range(48, 300, 48))
kotak_taplak += "".join(f'<rect x="{x}" y="{y}" width="24" height="24" fill="#f3d2c4"/>' for x in range(48, 232, 48) for y in range(72, 300, 48))
A["benda/meja"] = svg(f'''
<ellipse cx="128" cy="414" rx="124" ry="10" fill="{B_TERAS}" fill-opacity="0.2"/>
<path d="M30 336 L30 412 M226 336 L226 412" {garis("#7a4d2d", 10)}/>
<rect x="10" y="24" width="236" height="296" rx="12" {isi("#fbe9e1")}/>{kotak_taplak}
<path d="M10 320 L246 320 L240 352 L16 352 Z" {isi("#b9783f")}/>
<path d="M10 300 Q30 320 50 300 Q70 320 90 300 Q110 320 130 300 Q150 320 170 300 Q190 320 210 300 Q230 320 246 300 L246 320 L10 320 Z" fill="#f3d2c4" stroke="{gelap("#f3d2c4", 0.4)}" stroke-width="2"/>
<ellipse cx="80" cy="110" rx="34" ry="20" {isi("#ffffff")}/><ellipse cx="80" cy="108" rx="22" ry="12" fill="#eef3f5"/>
<rect x="150" y="190" width="40" height="46" rx="6" {isi("#cfe8f2")}/><ellipse cx="170" cy="190" rx="20" ry="7" {isi("#e6f4fa")}/>
<circle cx="96" cy="230" r="14" {isi("#fff4d6")}/>''', 256, 424)

# --- hiasan teras
A["benda/payung_merah"] = svg(bayang(64, 116, 22, B_TERAS) + f'''
<path d="M54 116 L58 98 L70 98 L74 116 Z" {isi("#6a6f78")}/>
<path d="M64 108 L64 14" {garis("#5a3a28", 4)}/>
<path d="M64 20 Q44 50 50 100 L78 100 Q84 50 64 20 Z" {isi("#d0413a")}/>
<path d="M64 20 Q72 50 78 100 L66 100 Q68 50 64 20 Z" fill="{gelap("#d0413a", 0.15)}"/>
<path d="M64 14 Q60 6 54 10" {garis("#5a3a28", 4)}/>
<path d="M54 64 Q64 70 74 64" {garis("#f0f0f0", 3)}/>''')

A["benda/radio_merah"] = svg(bayang(64, 116, 36, B_TERAS) + f'''
<path d="M36 52 L48 34 L80 34 L92 52" {garis("#4a4a52", 4)}/>
<rect x="20" y="52" width="88" height="58" rx="10" {isi("#c8423b")}/>
<rect x="20" y="52" width="88" height="12" rx="6" fill="{terang("#c8423b", 0.18)}"/>
<circle cx="46" cy="86" r="16" {isi("#3a3a42")}/>{"".join(f'<circle cx="{46+dx}" cy="{86+dy}" r="2" fill="#6a6a74"/>' for dx in (-8, 0, 8) for dy in (-8, 0, 8))}
<rect x="70" y="72" width="28" height="12" rx="3" {isi("#f2e6c8")}/>
<circle cx="76" cy="96" r="4" {isi("#e8e8ee")}/><circle cx="92" cy="96" r="4" {isi("#e8e8ee")}/>''')

anyaman = "".join(f'<path d="M{x} 64 L{x} 100" {garis("#a87a42", 2)}/>' for x in range(40, 92, 8))
A["benda/kursi_rotan"] = svg(bayang(64, 118, 38, B_TERAS) + f'''
<path d="M34 104 L32 116 M94 104 L96 116" {garis("#8a6232", 6)}/>
<path d="M26 32 Q64 10 102 32 L98 70 L30 70 Z" {isi("#c99a5b")}/>{"".join(f'<path d="M{x} 26 L{x} 68" {garis("#a87a42", 2)}/>' for x in range(40, 92, 8))}
<path d="M24 68 L104 68 L98 104 L30 104 Z" {isi("#d6a96a")}/>{anyaman}
<ellipse cx="64" cy="76" rx="30" ry="8" {isi("#e8c27a")}/>''')

A["benda/bola_basket"] = svg(bayang(64, 116, 28, B_TERAS) + bola(64, 86, 28, "#e07b2e") + f'''
<path d="M36 86 L92 86 M64 58 L64 114" {garis("#7a3a14", 2.5)}/>
<path d="M44 64 Q56 86 44 108 M84 64 Q72 86 84 108" {garis("#7a3a14", 2.5)}/>''')

A["benda/topi_pesta_biru"] = svg(bayang(64, 116, 26, B_TERAS) + f'''
<path d="M64 22 L90 108 Q64 118 38 108 Z" {isi("#3f7fd8")}/>
<path d="M64 22 L90 108 Q78 112 70 113 Z" fill="{gelap("#3f7fd8", 0.15)}"/>
<path d="M50 64 L78 64 M46 86 L84 86" {garis("#f6d365", 4)}/>
<g fill="#ff8fb0"><circle cx="58" cy="76" r="3"/><circle cx="72" cy="98" r="3"/><circle cx="64" cy="50" r="3"/></g>
<circle cx="64" cy="20" r="8" {isi("#f6d365")}/>''')

A["benda/pot_lidah_mertua"] = svg(bayang(64, 116, 26, B_TERAS) + f'''
<path d="M44 86 L84 86 L80 114 L48 114 Z" {isi("#8d8f99")}/>
<rect x="40" y="80" width="48" height="10" rx="4" {isi("#a4a6b0")}/>
''' + "".join(f'<path d="M{x} 84 Q{x+dx} {44} {x+dx*2} {top} Q{x+dx*2+6} {50} {x+8} 84 Z" {isi(c, tebal=2)}/>'
              for x, dx, top, c in ((46, -4, 22, "#4c9a52"), (56, 0, 12, "#5aa95c"), (66, 4, 18, "#4c9a52"), (74, 8, 30, "#5aa95c"))))

A["benda/sapu_ijuk"] = svg(bayang(64, 118, 30, B_TERAS) + f'''
<path d="M80 8 L58 86" {garis("#a0784a", 6)}/>
<path d="M40 80 L76 90 L70 118 L28 108 Z" {isi("#4a3626")}/>
<path d="M44 86 L36 110 M54 88 L48 114 M64 90 L60 116" {garis("#2e2218", 2.5)}/>
<rect x="44" y="76" width="36" height="12" rx="3" {isi("#c94a3a")} transform="rotate(15 62 82)"/>''')

A["benda/rak_sepatu"] = svg(bayang(64, 118, 46, B_TERAS) + f'''
<rect x="14" y="50" width="100" height="64" rx="4" {isi("#8a6a4a")}/>
<path d="M14 82 L114 82" {garis(gelap("#8a6a4a", 0.3), 3)}/>
<path d="M22 78 Q22 66 36 66 L50 66 Q56 72 56 78 Z" {isi("#e8e8ee", tebal=2)}/><path d="M64 78 Q64 64 80 66 L92 70 Q96 74 96 78 Z" {isi("#3a7bd5", tebal=2)}/>
<path d="M24 110 Q24 98 38 98 L52 98 Q58 104 58 110 Z" {isi("#d0413a", tebal=2)}/><path d="M66 110 Q66 98 80 98 L94 100 Q98 104 98 110 Z" {isi("#5a3a28", tebal=2)}/>''')

A["benda/keranjang_cucian"] = svg(bayang(64, 118, 36, B_TERAS) + f'''
<path d="M28 60 L36 112 Q64 120 92 112 L100 60 Z" {isi("#7fb0d8")}/>
{"".join(f'<path d="M{x} 66 L{x+2} 108" {garis(gelap("#7fb0d8", 0.25), 3)}/>' for x in (44, 56, 68, 80))}
<path d="M34 60 Q40 40 56 48 Q62 34 76 44 Q92 38 96 60 Z" {isi("#f1f1f4")}/>
<path d="M60 52 Q70 40 82 50" {isi("#e88a8a", tebal=2)}/>
<ellipse cx="64" cy="60" rx="36" ry="8" fill="none" stroke="{gelap("#7fb0d8", 0.4)}" stroke-width="3"/>''')

# =============================================================== benda gudang (1-3)
A["benda/spons_kuning"] = svg(bayang(64, 116, 36, B_GUDANG) + f'''
<path d="M24 66 L88 66 L104 54 L40 54 Z" {isi("#58a35a")}/>
<path d="M24 66 L88 66 L88 76 L24 76 Z" {isi("#4c8f4e")}/>
<path d="M88 66 L104 54 L104 64 L88 76 Z" fill="#3f7a41"/>
<path d="M24 76 L88 76 L88 110 L24 110 Z" {isi("#f6d23a")}/>
<path d="M88 76 L104 64 L104 98 L88 110 Z" {isi(gelap("#f6d23a", 0.12))}/>
<g fill="#d9b12a">{"".join(f'<ellipse cx="{x}" cy="{y}" rx="{r}" ry="{r*0.8:.1f}"/>' for x, y, r in ((34, 86, 3.5), (46, 96, 3), (58, 86, 4), (70, 100, 3.5), (80, 88, 3), (38, 102, 3), (62, 104, 2.5)))}</g>''')

A["benda/lampion_merah"] = svg(bayang(64, 118, 30, B_GUDANG) + f'''
<path d="M64 112 L64 120" {garis("#e0a93a", 4)}/>
<rect x="46" y="22" width="36" height="10" rx="3" {isi("#e0a93a")}/>
<rect x="46" y="100" width="36" height="10" rx="3" {isi("#e0a93a")}/>
<ellipse cx="64" cy="66" rx="40" ry="36" {isi("#d8453b")}/>
<path d="M64 30 Q100 40 102 66 Q100 92 64 102 Q86 66 64 30 Z" fill="{gelap("#d8453b", 0.15)}"/>
<path d="M64 30 L64 102 M44 33 Q34 66 44 99 M84 33 Q94 66 84 99" {garis(gelap("#d8453b", 0.3), 2.5)}/>
<ellipse cx="44" cy="52" rx="7" ry="11" fill="#ffffff" fill-opacity="0.35" transform="rotate(20 44 52)"/>
<path d="M64 22 L64 10" {garis("#5a3a28", 3)}/>''')

A["benda/hidung_badut"] = svg(bayang(64, 116, 22, B_GUDANG) + f'''
<path d="M30 92 Q64 60 98 92" {garis("#2a2a30", 2.5)}/>
{bola(64, 94, 22, "#ff2e4d")}''')

A["benda/bantalan_jarum"] = svg(bayang(64, 118, 32, B_GUDANG) + f'''
<path d="M48 70 L40 44 M64 66 L64 38 M80 70 L90 44" {garis("#9aa3ad", 2.5)}/>
<circle cx="40" cy="42" r="5.5" {isi("#f6d365", tebal=2)}/><circle cx="64" cy="36" r="5.5" {isi("#66bb6a", tebal=2)}/><circle cx="90" cy="42" r="5.5" {isi("#42a5f5", tebal=2)}/>
<ellipse cx="64" cy="108" rx="32" ry="9" {isi("#9a6b46")}/>
<ellipse cx="64" cy="86" rx="36" ry="26" {isi("#c62a4a")}/>
<path d="M64 112 Q96 104 100 86 Q96 100 64 104 Z" fill="{gelap("#c62a4a", 0.15)}"/>
<g fill="#ffd2dc">{"".join(f'<circle cx="{x}" cy="{y}" r="2.6"/>' for x, y in ((44, 80), (56, 72), (72, 74), (86, 82), (50, 94), (66, 90), (80, 98), (40, 92)))}</g>''')

A["benda/kotak_pos"] = svg(bayang(64, 118, 28, B_GUDANG) + f'''
<rect x="58" y="96" width="12" height="22" {isi("#5a4a40")}/>
<path d="M36 100 L36 48 Q36 26 64 26 Q92 26 92 48 L92 100 Z" {isi("#d84a2f")}/>
<path d="M72 28 Q92 32 92 48 L92 100 L74 100 Z" fill="{gelap("#d84a2f", 0.15)}"/>
<rect x="48" y="48" width="32" height="7" rx="3" fill="#3a2a24"/>
<rect x="50" y="66" width="28" height="16" rx="3" {isi("#ffd9c9", tebal=2)}/>''')

A["benda/kardus"] = svg(bayang(64, 118, 46, B_GUDANG) + f'''
<path d="M14 46 L114 46 L104 26 L24 26 Z" {isi("#d9b98f")}/>
<path d="M56 26 L72 26 L72 46 L56 46 Z" fill="#ead6b3"/>
<path d="M14 46 L114 46 L114 116 L14 116 Z" {isi("#c79f72")}/>
<path d="M88 46 L114 46 L114 116 L88 116 Z" fill="{gelap("#c79f72", 0.1)}"/>
<rect x="22" y="56" width="84" height="40" rx="4" {isi("#f1e2c4", tebal=2)}/>''')

A["benda/gunting"] = svg(bayang(64, 116, 32, B_GUDANG) + f'''
<path d="M50 96 L94 44" {garis(gelap("#c9d1d8", 0.5), 9)}/><path d="M78 96 L34 44" {garis(gelap("#c9d1d8", 0.5), 9)}/>
<path d="M50 96 L94 44" {garis("#dfe6ea", 5)}/><path d="M78 96 L34 44" {garis("#dfe6ea", 5)}/>
<circle cx="44" cy="104" r="11" fill="none" stroke="{gelap("#ef6c4a", 0.4)}" stroke-width="9"/><circle cx="84" cy="104" r="11" fill="none" stroke="{gelap("#ef6c4a", 0.4)}" stroke-width="9"/>
<circle cx="44" cy="104" r="11" fill="none" stroke="#ef6c4a" stroke-width="5"/><circle cx="84" cy="104" r="11" fill="none" stroke="#ef6c4a" stroke-width="5"/>
<circle cx="64" cy="79" r="4" fill="#4a4f55"/>''')

A["benda/sepatu"] = svg(bayang(64, 116, 36, B_GUDANG) + f'''
<path d="M22 104 L22 84 Q22 64 44 64 L60 64 Q70 80 92 84 Q108 88 108 104 Z" {isi("#7a5240")}/>
<path d="M18 104 L110 104 L110 112 Q64 118 18 112 Z" {isi("#efe6dc")}/>
<path d="M44 66 L58 82 M50 66 L62 80 M38 70 L52 86" {garis("#efe6dc", 2.5)}/>''')

A["benda/wastafel"] = svg(bayang(64, 120, 46, B_GUDANG) + f'''
<path d="M18 62 L110 62 L110 118 L18 118 Z" {isi("#cfd8dc")}/>
<path d="M84 62 L110 62 L110 118 L84 118 Z" fill="{gelap("#cfd8dc", 0.1)}"/>
<path d="M30 74 L66 74 L66 110 L30 110 Z M70 74 L98 74 L98 110 L70 110 Z" fill="none" stroke="{gelap("#cfd8dc", 0.3)}" stroke-width="2.5"/>
<path d="M12 40 L116 40 L110 62 L18 62 Z" {isi("#eef3f5")}/>
<ellipse cx="64" cy="50" rx="34" ry="7" {isi("#b9c7cf")}/>
<path d="M64 46 L64 30 Q64 24 74 24" {garis("#9aa6ad", 5)}/>''')

# Rak 1x3 petak (3/4): tinggi, papan rak berisi barang.
A["benda/rak"] = svg(f'''
<ellipse cx="64" cy="412" rx="60" ry="8" fill="{B_GUDANG}" fill-opacity="0.22"/>
<rect x="8" y="16" width="112" height="396" rx="4" {isi("#7a5240")}/>
<rect x="16" y="24" width="96" height="380" fill="#5f3f30"/>
''' + "".join(f'<rect x="12" y="{y}" width="104" height="10" fill="#8a6048"/>' for y in (110, 210, 310)) + f'''
<rect x="22" y="70" width="26" height="40" rx="3" {isi("#e8a64a", tebal=2)}/><rect x="54" y="80" width="22" height="30" rx="3" {isi("#7fb0d8", tebal=2)}/><circle cx="94" cy="96" r="13" {isi("#9ccc65", tebal=2)}/>
<rect x="22" y="176" width="40" height="34" rx="3" {isi("#c9443a", tebal=2)}/><rect x="68" y="168" width="34" height="42" rx="3" {isi("#e3d2a8", tebal=2)}/>
<circle cx="40" cy="294" r="15" {isi("#f2c230", tebal=2)}/><rect x="64" y="276" width="38" height="34" rx="3" {isi("#b39ddb", tebal=2)}/>
<rect x="24" y="372" width="78" height="32" rx="3" {isi("#a1887f", tebal=2)}/>''', 128, 424)

# --- hiasan gudang
A["benda/kotak_perkakas"] = svg(bayang(64, 118, 42, B_GUDANG) + f'''
<path d="M44 58 L44 44 L84 44 L84 58" {garis("#4a4f55", 6)}/>
<rect x="16" y="58" width="96" height="56" rx="6" {isi("#c9443a")}/>
<rect x="16" y="58" width="96" height="14" rx="6" fill="{terang("#c9443a", 0.18)}"/>
<path d="M86 58 L112 58 L112 114 L86 114 Z" fill="{gelap("#c9443a", 0.12)}" fill-opacity="0.8"/>
<rect x="56" y="78" width="16" height="10" rx="2" {isi("#d9dde2", tebal=2)}/>''')

A["benda/tali_gulung"] = svg(bayang(64, 118, 36, B_GUDANG) + f'''
<ellipse cx="64" cy="92" rx="38" ry="22" {isi("#b89160")}/>
''' + "".join(f'<ellipse cx="64" cy="92" rx="{rx}" ry="{rx*0.58:.1f}" {garis(gelap("#b89160", 0.25), 2.5)}/>' for rx in (30, 22, 14))
    + f'<ellipse cx="64" cy="92" rx="7" ry="4" fill="#5a4030"/><path d="M98 98 Q112 108 104 118" {garis("#b89160", 6)}/>')

A["benda/kaleng_oli"] = svg(bayang(64, 118, 28, B_GUDANG) + f'''
<path d="M38 50 L38 112 L90 112 L90 50 Z" {isi("#c23b30")}/>
<path d="M74 50 L90 50 L90 112 L74 112 Z" fill="{gelap("#c23b30", 0.15)}"/>
<rect x="44" y="66" width="40" height="26" rx="3" {isi("#f2c230", tebal=2)}/>
<path d="M38 50 L52 36 L90 36 L90 50 Z" {isi("#d9534a")}/>
<rect x="72" y="26" width="12" height="12" rx="2" {isi("#4a4f55")}/>''')

A["benda/jeriken_kuning"] = svg(bayang(64, 118, 34, B_GUDANG) + f'''
<path d="M30 48 L98 48 L98 114 L30 114 Z" {isi("#f2c230")}/>
<path d="M78 48 L98 48 L98 114 L78 114 Z" fill="{gelap("#f2c230", 0.12)}"/>
<path d="M36 58 L92 58 M36 104 L92 104" {garis(gelap("#f2c230", 0.25), 3)}/>
<path d="M44 48 L44 30 L70 30 L70 48" {isi("#e6b521")}/><rect x="50" y="36" width="14" height="10" rx="2" fill="#5a4a2a"/>
<rect x="78" y="34" width="12" height="14" rx="2" {isi("#2f2f36")}/>''')

A["benda/karung_beras"] = svg(bayang(64, 118, 42, B_GUDANG) + f'''
<path d="M24 114 Q16 74 30 48 L40 36 Q64 44 88 36 L98 48 Q112 74 104 114 Z" {isi("#e3d2a8")}/>
<path d="M80 40 L98 48 Q112 74 104 114 L86 114 Q96 74 80 40 Z" fill="{gelap("#e3d2a8", 0.1)}"/>
<path d="M40 36 Q64 26 88 36" {garis("#a88e5c", 4)}/>
<rect x="40" y="70" width="48" height="24" rx="3" fill="none" stroke="#5a7fb0" stroke-width="3"/>
<path d="M48 82 L80 82" {garis("#5a7fb0", 3)}/>''')

A["benda/tangga_lipat"] = svg(bayang(64, 120, 34, B_GUDANG) + f'''
<path d="M44 118 L60 10 M84 118 L68 10" {garis(gelap("#9aa3ad", 0.4), 8)}/>
<path d="M44 118 L60 10 M84 118 L68 10" {garis("#b9c1ca", 4.5)}/>
''' + "".join(f'<path d="M{48+i*2.3:.0f} {100-i*22} L{80-i*2.3:.0f} {100-i*22}" {garis("#9aa3ad", 5)}/>' for i in range(4))
    + f'<rect x="56" y="6" width="16" height="10" rx="2" {isi("#e07b2e")}/>')

A["benda/kipas_angin"] = svg(bayang(64, 120, 28, B_GUDANG) + f'''
<path d="M64 76 L64 112" {garis("#9aa3ad", 6)}/>
<ellipse cx="64" cy="112" rx="24" ry="7" {isi("#b9c1ca")}/>
<circle cx="64" cy="50" r="34" {isi("#d9eef5")}/>
''' + "".join(f'<ellipse cx="{64+dx}" cy="{50+dy}" rx="12" ry="7" fill="#7fc3d8" transform="rotate({s} {64+dx} {50+dy})"/>' for dx, dy, s in ((0, -14, 0), (13, 8, 60), (-13, 8, -60)))
    + f'<circle cx="64" cy="50" r="6" fill="#4a7f8f"/>' + "".join(f'<path d="M{64+30*c:.1f} {50+30*s:.1f} L{64+34*c:.1f} {50+34*s:.1f}" {garis("#9aa3ad", 2)}/>'
    for c, s in ((1, 0), (0, 1), (-1, 0), (0, -1), (0.7, 0.7), (-0.7, 0.7), (0.7, -0.7), (-0.7, -0.7))))

A["benda/lampu_minyak"] = svg(bayang(64, 118, 24, B_GUDANG) + f'''
<path d="M42 116 L46 96 L82 96 L86 116 Z" {isi("#8a6a3a")}/>
<path d="M48 96 Q40 70 52 50 L76 50 Q88 70 80 96 Z" fill="#fff3c4" fill-opacity="0.75" stroke="{gelap("#e0a93a", 0.4)}" stroke-width="2.5"/>
<path d="M64 88 Q56 76 64 62 Q72 76 64 88 Z" fill="#f2a33a"/><path d="M64 84 Q60 78 64 70 Q68 78 64 84 Z" fill="#fff0a0"/>
<rect x="48" y="42" width="32" height="10" rx="3" {isi("#8a6a3a")}/>
<path d="M50 42 Q64 22 78 42" {garis("#6a4f2a", 3)}/>''')

# --- benda cadangan & alat lain (gaya baru)
A["benda/krayon_oranye"] = svg(bayang(64, 116, 36) + f'''<g transform="rotate(-28 64 92)">
<rect x="22" y="80" width="64" height="24" rx="4" {isi("#ef7a1a")}/><rect x="36" y="80" width="36" height="24" {isi("#ffd2a0", tebal=2)}/>
<path d="M86 80 L108 92 L86 104 Z" {isi("#ef7a1a")}/></g>''')
A["benda/kemoceng_kuning"] = svg(bayang(64, 118, 26) + f'''
<path d="M64 118 L64 70" {garis("#8a6a4a", 7)}/>
''' + "".join(f'<path d="M64 74 Q{64+dx} {40+dy} {64+dx*1.6:.0f} {18+dy}" {garis(c, 9)}/>' for dx, dy, c in (
    (-22, 6, "#f6d23a"), (-10, 0, "#f2c230"), (0, -2, "#f6d23a"), (10, 0, "#f2c230"), (22, 6, "#f6d23a"), (-16, 18, "#e6b521"), (16, 18, "#e6b521"))))
A["benda/bantal_hati_merah"] = svg(bayang(64, 118, 40) + f'''
<path d="M64 116 C26 92 18 70 26 54 C34 38 54 38 64 56 C74 38 94 38 102 54 C110 70 102 92 64 116 Z" {isi("#c62a4a")}/>
<path d="M64 106 C34 86 30 70 36 60 C42 50 56 52 64 64" fill="none" stroke="#ffd2dc" stroke-width="2" stroke-dasharray="4 4"/>''')
A["benda/bola_kertas_hijau"] = svg(bayang(64, 116, 30) + f'''
<path d="M38 72 L54 56 L76 58 L94 72 L98 94 L86 112 L60 116 L40 106 L32 88 Z" {isi("#8cc152")}/>
<path d="M54 56 L60 80 L38 72 M60 80 L86 84 L94 72 M86 84 L76 104 L86 112 M60 80 L54 100 L32 88 M54 100 L76 104 L60 116" {garis(gelap("#8cc152", 0.3), 2.5)}/>''')
A["benda/rok_tutu_hijau"] = svg(bayang(64, 116, 40) + "".join(
    f'<ellipse cx="64" cy="{y}" rx="{rx}" ry="{rx*0.35:.1f}" {isi(c)}/>' for y, rx, c in ((100, 46, "#9ccc65"), (90, 40, "#aed581"), (80, 32, "#c5e1a5")))
    + f'<rect x="44" y="64" width="40" height="14" rx="6" {isi("#689f38")}/>')
A["benda/sekop"] = svg(bayang(64, 118, 28) + f'''
<path d="M70 10 L60 78" {garis("#a0784a", 7)}/>
<path d="M60 10 L80 10" {garis("#a0784a", 7)}/>
<path d="M42 78 L80 78 L78 104 Q61 120 44 104 Z" {isi("#b9c1ca")}/>''')
A["benda/penghalang"] = svg(bayang(64, 120, 52, B_GUDANG) + f'''
<path d="M10 64 L118 64 L118 118 L10 118 Z" {isi("#b07a4a")}/>
<path d="M10 64 L118 64 L108 50 L20 50 Z" {isi("#c58c5a")}/>
<path d="M28 26 L100 26 L100 50 L28 50 Z" {isi("#c58c5a")}/>
<path d="M28 26 L100 26 L94 16 L34 16 Z" {isi("#d39c68")}/>
<path d="M10 90 L118 90 M64 64 L64 118" {garis(gelap("#b07a4a", 0.3), 3)}/>''')

# =============================================================== pembeli lain
def badan_pembeli(warna, motif=""):
    return f'<path d="M24 122 Q22 88 64 84 Q106 88 104 122 Z" {isi(warna)}/>{motif}'


def wajah(cy=64):
    return (f'<ellipse cx="64" cy="{cy}" rx="24" ry="26" {isi(KULIT)}/>'
            f'<circle cx="55" cy="{cy}" r="3.2" fill="#3a2e2a"/><circle cx="73" cy="{cy}" r="3.2" fill="#3a2e2a"/>'
            f'<circle cx="49" cy="{cy+8}" r="4" fill="#f19b8a" fill-opacity="0.5"/><circle cx="79" cy="{cy+8}" r="4" fill="#f19b8a" fill-opacity="0.5"/>')


A["pembeli/mang_ujang"] = svg(bayang(64, 120, 34, B_TERAS) + badan_pembeli("#ef7d2a", f'<path d="M34 92 Q64 104 94 92" {garis("#ffffff", 7)}/>')
    + wajah() + f'<path d="M57 76 Q64 81 71 76" {garis("#a0523d", 2.5)}/>'
    + f'<path d="M38 50 Q40 26 64 26 Q88 26 90 50 Z" {isi("#4a5a6a")}/><path d="M36 50 L110 50 Q110 58 94 56 L36 56 Z" {isi("#3a4856", tebal=2)}/>')

A["pembeli/pak_rt"] = svg(bayang(64, 120, 34, B_GUDANG) + badan_pembeli("#3f51b5", f'<path d="M64 86 L58 122 M64 86 L70 122" {garis("#ffffff", 3)}/>'
    + "".join(f'<circle cx="{x}" cy="{y}" r="3" fill="#f6d365"/>' for x, y in ((40, 104), (88, 104), (46, 116), (82, 116))))
    + wajah() + f'<path d="M52 77 Q64 72 76 77" {garis("#3a2e2a", 5)}/>'
    + f'<g fill="none" stroke="#3a2e2a" stroke-width="2.5"><circle cx="55" cy="63" r="8"/><circle cx="73" cy="63" r="8"/><path d="M63 63 L65 63"/></g>'
    + f'<path d="M40 44 L40 30 Q64 20 88 30 L88 44 Q64 38 40 44 Z" {isi("#26262e", tebal=2)}/>')

# =============================================================== tanaman lain
def buah_bayang(isi_svg):
    return svg(bayang(64, 116, 30) + isi_svg)


daun_wortel = "".join(f'<path d="M64 76 Q{64+dx} {48} {64+dx*1.5:.0f} {22+abs(dx)//2}" {garis(DAUN, 5)}/>' for dx in (-16, -6, 4, 14))
A["tanaman/wortel_muda"] = svg('<g transform="translate(16 30) scale(0.75)">' + daun_wortel + '</g>' + '<ellipse cx="64" cy="96" rx="9" ry="4" fill="#f08a2a"/>')
A["tanaman/wortel_matang"] = svg(daun_wortel + f'<path d="M50 74 L78 74 Q74 96 64 104 Q54 96 50 74 Z" {isi("#f08a2a")}/><ellipse cx="64" cy="76" rx="14" ry="4" fill="{terang("#f08a2a", 0.3)}"/>')
A["tanaman/wortel_buah"] = buah_bayang(f'''<path d="M64 46 Q52 24 44 12 M64 46 Q64 22 66 8 M64 46 Q76 24 86 14" {garis(DAUN, 6)}/>
<path d="M44 44 L84 44 Q80 92 64 116 Q48 92 44 44 Z" {isi("#f08a2a")}/>
<path d="M64 44 L84 44 Q80 92 64 116 Z" fill="{gelap("#f08a2a", 0.12)}"/>
<path d="M50 62 L58 62 M68 78 L76 78 M54 94 L60 94" {garis(gelap("#f08a2a", 0.3), 2.5)}/>''')

A["tanaman/jagung_muda"] = svg(batang("M64 112 L64 30") + daun(46, 70, 24, 7, -35) + daun(82, 56, 24, 7, 35) + daun(48, 40, 20, 6, -40))
A["tanaman/jagung_matang"] = svg(batang("M58 112 L58 18") + daun(40, 76, 24, 7, -35) + daun(40, 44, 20, 6, -40) + f'''
<ellipse cx="78" cy="62" rx="12" ry="24" {isi("#f6d23a")} transform="rotate(15 78 62)"/>
<path d="M66 84 Q60 60 70 36" {garis("#8cc152", 7)}/><path d="M84 38 Q92 26 88 16" {garis("#b08a5a", 2.5)}/>''')
biji_jagung = "".join(f'<ellipse cx="{x}" cy="{y}" rx="4" ry="3.4" fill="{c}"/>' for i, y in enumerate(range(36, 104, 10)) for x, c in ((54, "#e6b521"), (64, "#f2c230"), (74, "#e6b521")))
A["tanaman/jagung_buah"] = buah_bayang(f'''<ellipse cx="64" cy="70" rx="22" ry="44" {isi("#f6d23a")}/>{biji_jagung}
<path d="M44 112 Q30 72 46 42 Q52 82 60 114 Z" {isi("#8cc152", tebal=2)}/><path d="M84 112 Q98 72 82 42 Q76 82 68 114 Z" {isi("#8cc152", tebal=2)}/>''')


def stroberi(cx, cy, s):
    return (f'<path d="M{cx} {cy+s} Q{cx-s} {cy} {cx-s*0.8:.1f} {cy-s*0.6:.1f} Q{cx} {cy-s*0.95:.1f} {cx+s*0.8:.1f} {cy-s*0.6:.1f} Q{cx+s} {cy} {cx} {cy+s} Z" {isi("#e2483d", tebal=2)}/>'
            + "".join(f'<circle cx="{cx+dx*s:.1f}" cy="{cy+dy*s:.1f}" r="{s*0.07:.1f}" fill="#f6d365"/>' for dx, dy in ((-0.4, -0.2), (0.3, -0.25), (0, 0.15), (-0.3, 0.35), (0.35, 0.3)))
            + f'<path d="M{cx-s*0.6:.1f} {cy-s*0.62:.1f} L{cx} {cy-s*0.35:.1f} L{cx+s*0.6:.1f} {cy-s*0.62:.1f} L{cx} {cy-s:.1f} Z" {isi("#4f9e3f", tebal=2)}/>')


A["tanaman/stroberi_muda"] = svg(daun(44, 76, 18, 11, -20) + daun(84, 76, 18, 11, 20) + daun(64, 58, 12, 16, 0) + f'<circle cx="64" cy="92" r="8" {isi("#ffffff", tebal=2)}/><circle cx="64" cy="92" r="3" fill="#f6d365"/>')
A["tanaman/stroberi_matang"] = svg(daun(44, 64, 18, 11, -20) + daun(84, 64, 18, 11, 20) + daun(64, 48, 12, 16, 0) + stroberi(46, 92, 14) + stroberi(84, 90, 13))
A["tanaman/stroberi_buah"] = buah_bayang(stroberi(64, 76, 40))


def kubis(r, cy=70):
    return (f'<circle cx="64" cy="{cy}" r="{r}" {isi("#8cc152")}/>'
            f'<circle cx="64" cy="{cy}" r="{r*0.7:.1f}" {isi("#a5d06a", tebal=2)}/>'
            f'<circle cx="64" cy="{cy}" r="{r*0.38:.1f}" {isi("#c5e1a5", tebal=2)}/>'
            f'<path d="M64 {cy-r} L64 {cy-r*0.38:.1f} M{64-r} {cy} L{64-r*0.38:.1f} {cy} M{64+r} {cy} L{64+r*0.38:.1f} {cy}" {garis("#6a9a3c", 2.5)}/>')


A["tanaman/kubis_muda"] = svg(kubis(22, 84))
A["tanaman/kubis_matang"] = svg(daun(32, 94, 18, 9, 30) + daun(96, 94, 18, 9, -30) + kubis(36, 76))
A["tanaman/kubis_buah"] = buah_bayang(kubis(40, 72))


def bunga(cx, cy, r):
    kelopak = "".join(f'<circle cx="{cx + r*0.9*dx:.1f}" cy="{cy + r*0.9*dy:.1f}" r="{r*0.6:.1f}" {isi("#9b59b6", tebal=2)}/>'
                      for dx, dy in ((0, -1), (0.95, -0.31), (0.59, 0.81), (-0.59, 0.81), (-0.95, -0.31)))
    return kelopak + f'<circle cx="{cx}" cy="{cy}" r="{r*0.5:.1f}" {isi("#f6d365", tebal=2)}/>'


A["tanaman/bunga_muda"] = svg(batang("M64 112 L64 46") + daun(48, 86, 15, 7, -30) + daun(80, 76, 15, 7, 30) + f'<ellipse cx="64" cy="40" rx="8" ry="12" {isi("#c39bd3", tebal=2)}/>')
A["tanaman/bunga_matang"] = svg(batang("M64 112 L64 48") + batang("M64 82 Q46 72 38 58") + daun(80, 86, 15, 7, 30) + bunga(64, 38, 15) + bunga(36, 54, 10))
A["tanaman/bunga_buah"] = buah_bayang(bunga(64, 70, 30))

# =============================================================== ikon aksi (putih, untuk tombol)
P = 'fill="none" stroke="#ffffff" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"'
A["ui/aksi_identifikasi"] = svg(f'<circle cx="54" cy="54" r="28" {P}/><line x1="76" y1="76" x2="104" y2="104" {P} stroke-width="13"/><path d="M45 46 Q45 37 54 37 Q63 37 63 45 Q63 51 54 55 L54 61" {P} stroke-width="7"/><circle cx="54" cy="71" r="4.5" fill="#ffffff"/>')
A["ui/aksi_ambil"] = svg(f'<path d="M36 70 L36 40 Q36 32 44 32 Q52 32 52 40 L52 62 M52 38 Q52 26 60 26 Q68 26 68 38 L68 62 M68 42 Q68 32 76 32 Q84 32 84 42 L84 64 M84 50 Q84 42 92 42 Q100 42 100 52 L100 80 Q100 108 72 108 Q46 108 36 86 L22 64 Q18 56 26 54 Q32 52 36 60" {P} stroke-width="7"/>')
A["ui/aksi_potong"] = svg(f'<line x1="44" y1="86" x2="100" y2="22" {P}/><line x1="84" y1="86" x2="28" y2="22" {P}/><circle cx="38" cy="100" r="13" {P} stroke-width="7"/><circle cx="90" cy="100" r="13" {P} stroke-width="7"/>')
A["ui/aksi_tanam"] = svg(f'<path d="M64 112 L64 62" {P}/><path d="M64 70 Q40 70 32 46 Q56 44 64 64" {P} stroke-width="7"/><path d="M64 62 Q88 62 96 38 Q72 36 64 56" {P} stroke-width="7"/><line x1="30" y1="112" x2="98" y2="112" {P}/>')
A["ui/aksi_panen"] = svg(f'<path d="M20 56 L108 56 L96 108 L32 108 Z" {P} stroke-width="8"/><path d="M38 56 Q64 10 90 56" {P} stroke-width="7"/><line x1="44" y1="72" x2="48" y2="96" {P} stroke-width="6"/><line x1="64" y1="72" x2="64" y2="96" {P} stroke-width="6"/><line x1="84" y1="72" x2="80" y2="96" {P} stroke-width="6"/>')

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
