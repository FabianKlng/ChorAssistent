"""Python-Nachbau von StaffImageAnalyzer/StaffDetector zum lokalen Testen an echten Scans.

Aufruf:
  py -3 -I tools/staff_detect.py <bild> <x> <y> [schlüssel] [vorzeichen]
  py -3 -I tools/staff_detect.py --selftest
Koordinaten in Bildpixeln (nach Verkleinerung auf max. 2000 px, wie in der App).
"""
import io
import math
import sys

from PIL import Image, ImageDraw

MIN_LINE_DARKNESS = 0.35
MIN_CONTRAST = 40.0


def prepare(img):
    img = img.convert("L")
    w, h = img.size
    longest = max(w, h)
    if longest > 2000:
        s = 2000 / longest
        img = img.resize((round(w * s), round(h * s)), Image.LANCZOS)
    buf = io.BytesIO()
    img.convert("RGB").save(buf, "JPEG", quality=70)
    return Image.open(io.BytesIO(buf.getvalue())).convert("L")


def line_centers(dark, min_dark, max_thick):
    centers, start = [], None
    for i, v in enumerate(dark + [0.0]):
        if v >= min_dark:
            if start is None:
                start = i
        elif start is not None:
            end = i - 1
            if end - start + 1 <= max_thick:
                wsum = sum(dark[r] for r in range(start, end + 1))
                centers.append(sum(dark[r] * r for r in range(start, end + 1)) / wsum)
            start = None
    return centers


def distance(y, staff):
    if y < staff[0]:
        return staff[0] - y
    if y > staff[-1]:
        return y - staff[-1]
    return 0.0


def find_staff(lines, y, max_ratio=1.35, min_gap=3):
    best = None
    for i in range(0, len(lines) - 4):
        g = lines[i:i + 5]
        gaps = [b - a for a, b in zip(g, g[1:])]
        if min(gaps) < min_gap or max(gaps) / min(gaps) > max_ratio:
            continue
        sp = (g[4] - g[0]) / 4
        d = distance(y, g)
        if d > sp * 6:
            continue
        if best is None or d < best[1]:
            best = (g, d)
    return best[0] if best else None


def detect(img, x, y, verbose=False):
    w, h = img.size
    px = img.load()
    cx, cy = int(x), int(y)
    strip = max(24, w // 60)
    excl = max(10, w // 80)
    reach = max(120, h // 12)
    rows = range(max(0, cy - reach), min(h - 1, cy + reach) + 1)
    starts = [cx - excl - strip, cx + excl, cx - excl - 3 * strip, cx + excl + 2 * strip]
    strips = []
    for s0 in starts:
        lo, hi = max(0, s0), min(w, s0 + strip)
        if hi - lo >= strip // 2:
            strips.append(range(lo, hi))
    hist = [0] * 256
    for r in rows:
        for st in strips:
            for c in st:
                hist[px[c, r]] += 1
    total = sum(hist)

    def q(f):
        t, acc = int(total * f), 0
        for v, n in enumerate(hist):
            acc += n
            if acc > t:
                return v
        return 255

    ink, paper = q(0.01), q(0.90)
    if verbose:
        print(f"Bild {w}x{h}, Streifen {strip}px, Tinte {ink}, Papier {paper}")
    if paper - ink < MIN_CONTRAST:
        return None
    rng = paper - ink
    cands = []
    for st in strips:
        dark = [sum(min(1, max(0, (paper - px[c, r]) / rng)) for c in st) / len(st) for r in rows]
        lines = [c + rows.start for c in line_centers(dark, MIN_LINE_DARKNESS, max(5, h // 400))]
        staff = find_staff(lines, y)
        if verbose:
            print(f"  Streifen {st.start}-{st.stop}: Linien {[round(l, 1) for l in lines]} -> System {staff and [round(l, 1) for l in staff]}")
        if staff:
            cands.append((staff, distance(y, staff)))
    if not cands:
        return None

    def agree(a, b):
        tol = max(2, (a[4] - a[0]) / 8)
        return all(abs(p - q_) <= tol for p, q_ in zip(a, b))

    scored = [(c, sum(agree(o[0], c[0]) for o in cands)) for c in cands]
    best = max(scored, key=lambda s: (s[1], -s[0][1]))[0][0]
    bottom, half = best[4], (best[4] - best[0]) / 8
    return best, round((bottom - y) / half)


CLEF_BOTTOM = {"treble": 4 * 7 + 2, "treble8": 3 * 7 + 2, "bass": 2 * 7 + 4}
NAMES = ["C", "Cis", "D", "Dis", "E", "F", "Fis", "G", "Gis", "A", "B", "H"]


def midi(step, clef="treble", key=0):
    d = CLEF_BOTTOM[clef] + step
    octave, letter = d // 7, d % 7
    m = (octave + 1) * 12 + [0, 2, 4, 5, 7, 9, 11][letter]
    sharps, flats = [3, 0, 4, 1, 5, 2, 6], [6, 2, 5, 1, 4, 0, 3]
    if key > 0 and letter in sharps[:key]:
        m += 1
    if key < 0 and letter in flats[:-key]:
        m -= 1
    return m


def name(m):
    return NAMES[m % 12] + str(m // 12 - 1)


def selftest():
    tilt = math.tan(math.radians(1.5))
    W, H = 1414, 2000
    img = Image.new("L", (W, H), 237)
    d = ImageDraw.Draw(img)
    ly = lambda i, x: 600 + i * 12 + x * tilt
    for i in range(5):
        d.line([(80, ly(i, 80)), (1334, ly(i, 1334))], fill=115, width=1)
    notes = [(400, ly(3, 400)), (700, ly(2, 700)), (1000, (ly(0, 1000) + ly(1, 1000)) / 2)]
    for x, y in notes:
        d.ellipse([x - 8, y - 6, x + 8, y + 6], fill=25)
        d.rectangle([x + 6, y - 40, x + 7, y], fill=25)
    img = prepare(img)
    expected = [2, 4, 7]
    ok = True
    for (x, y), exp in zip(notes, expected):
        r = detect(img, x, y, verbose=True)
        step = r[1] if r else None
        print(f"Note bei ({x}, {y:.1f}): Schritt {step}, erwartet {exp}")
        ok &= step == exp
    print("SELBSTTEST", "OK" if ok else "FEHLGESCHLAGEN")
    return ok


if __name__ == "__main__":
    if sys.argv[1:] == ["--selftest"]:
        sys.exit(0 if selftest() else 1)
    path, x, y = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
    clef = sys.argv[4] if len(sys.argv) > 4 else "treble"
    key = int(sys.argv[5]) if len(sys.argv) > 5 else 0
    img = prepare(Image.open(path))
    r = detect(img, x, y, verbose=True)
    if not r:
        print("Keine Notenlinien gefunden")
    else:
        print(f"System {[round(l, 1) for l in r[0]]}, Schritt {r[1]} -> {name(midi(r[1], clef, key))}")
