#!/usr/bin/env python3
"""Generate ORIGINAL placeholder art for every drop-in media slot.

These are NOT Stranger Things promotional images or trailers. They are
original, procedurally-drawn slates (dark gradient + neon ring + a clear
"DROP YOUR FILE HERE" label) that mark where a fan's own licensed/captured
still or clip would go. They keep the demo visually complete while making it
obvious which real asset replaces each one.

Stills -> tool/placeholder_slates/images/*.jpg   (PIL)
Slates  -> tool/placeholder_slates/video/*.mp4   (ffmpeg, from a PNG sequence)

They are written OUTSIDE assets/ on purpose: the app prefers any file it
finds under assets/images/, so bundling these would put a "PLACEHOLDER"
slate on every card. Copy one into assets/images/ only to check a slot.

Run: python3 tool/generate_placeholders.py
"""
import os
import subprocess

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.join(os.path.dirname(__file__), "..")
IMG = os.path.join(ROOT, "tool", "placeholder_slates", "images")
VID = os.path.join(ROOT, "tool", "placeholder_slates", "video")

# (filename stem, display label, accent RGB, kind)
STILLS = [
    ("featured", "BANNER", (229, 9, 20), "hero"),
    ("char_eleven", "ELEVEN", (240, 156, 184), "poster"),
    ("char_mike", "MIKE", (99, 179, 255), "poster"),
    ("char_dustin", "DUSTIN", (245, 197, 24), "poster"),
    ("char_lucas", "LUCAS", (87, 217, 163), "poster"),
    ("char_will", "WILL", (179, 136, 255), "poster"),
    ("char_max", "MAX", (255, 110, 64), "poster"),
    ("char_steve", "STEVE", (255, 213, 79), "poster"),
    ("char_nancy", "NANCY", (255, 92, 138), "poster"),
    ("char_jonathan", "JONATHAN", (126, 170, 255), "poster"),
    ("char_robin", "ROBIN", (77, 208, 225), "poster"),
    ("char_hopper", "HOPPER", (141, 141, 141), "poster"),
    ("char_joyce", "JOYCE", (185, 246, 202), "poster"),
    ("char_vecna", "VECNA", (142, 69, 133), "poster"),
    ("char_demogorgon", "DEMOGORGON", (229, 57, 53), "poster"),
    ("char_mind_flayer", "MIND FLAYER", (74, 85, 104), "poster"),
    ("season_1", "SEASON 1", (229, 9, 20), "wide"),
    ("season_2", "SEASON 2", (255, 109, 0), "wide"),
    ("season_3", "SEASON 3", (0, 229, 255), "wide"),
    ("season_4", "SEASON 4", (156, 39, 176), "wide"),
    ("season_5", "SEASON 5", (198, 40, 40), "wide"),
    ("loc_hawkins_lab", "HAWKINS LAB", (144, 164, 174), "wide"),
    ("loc_byers_house", "BYERS HOUSE", (185, 246, 202), "wide"),
    ("loc_wheeler_house", "WHEELER BASEMENT", (99, 179, 255), "wide"),
    ("loc_palace_arcade", "PALACE ARCADE", (212, 225, 87), "wide"),
    ("loc_starcourt", "STARCOURT MALL", (0, 229, 255), "wide"),
    ("loc_creel_house", "CREEL HOUSE", (142, 69, 133), "wide"),
    ("loc_upside_down", "THE UPSIDE DOWN", (91, 255, 223), "wide"),
    ("loc_russian_base", "RUSSIAN BASE", (239, 83, 80), "wide"),
    ("monster_demogorgon", "DEMOGORGON", (229, 57, 53), "poster"),
    ("monster_demodog", "DEMODOG", (239, 83, 80), "poster"),
    ("monster_mind_flayer", "MIND FLAYER", (84, 110, 122), "poster"),
    ("monster_vecna", "VECNA", (142, 69, 133), "poster"),
    ("monster_demo_bat", "DEMO-BAT", (109, 75, 195), "poster"),
    ("monster_the_flayed", "THE FLAYED", (38, 198, 218), "poster"),
]

VIDEOS = [
    ("featured", "FEATURED TEASER", (229, 9, 20)),
    ("s1_teaser", "S1 TEASER", (229, 9, 20)),
    ("s2_teaser", "S2 TEASER", (255, 109, 0)),
    ("s3_teaser", "S3 TEASER", (0, 229, 255)),
    ("s4_teaser", "S4 TEASER", (156, 39, 176)),
    ("s5_teaser", "S5 TEASER", (198, 40, 40)),
]


def _font(size):
    for p in [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
    ]:
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            continue
    return ImageFont.load_default()


def _draw_slate(w, h, label, rgb, kind):
    """Original dark slate: gradient + neon ring + placeholder label."""
    img = Image.new("RGB", (w, h), (8, 6, 10))
    d = ImageDraw.Draw(img)

    # Diagonal gradient wash toward the accent corner.
    for y in range(h):
        for_x = int((y / h) * w)
        t = y / h
        col = (
            int(8 + rgb[0] * 0.18 * (1 - t)),
            int(6 + rgb[1] * 0.12 * (1 - t)),
            int(10 + rgb[2] * 0.16 * (1 - t)),
        )
        d.line([(0, y), (w, y)], fill=col)
    # Accent bloom top-right: glow image with a separate alpha mask.
    r = min(w, h)
    solid = Image.new("RGB", (w, h), rgb)
    alpha = Image.new("L", (w, h), 0)
    ImageDraw.Draw(alpha).ellipse([w - r, -r // 2, w + r // 2, r], fill=90)
    alpha = alpha.filter(ImageFilter.GaussianBlur(r // 3))
    img.paste(solid, (0, 0), alpha)
    d = ImageDraw.Draw(img)

    # Scanline texture.
    for y in range(0, h, 3):
        d.line([(0, y), (w, y)], fill=(0, 0, 0), width=1)

    # Neon ring in the centre.
    cx, cy = w // 2, int(h * 0.42)
    rad = int(min(w, h) * (0.26 if kind == "poster" else 0.2))
    ring = Image.new("RGB", (w, h), (0, 0, 0))
    rd = ImageDraw.Draw(ring)
    rd.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], outline=rgb, width=4)
    ring = ring.filter(ImageFilter.GaussianBlur(2))
    rmask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(rmask).ellipse(
        [cx - rad, cy - rad, cx + rad, cy + rad], outline=255, width=4
    )
    img.paste(ring, (0, 0), rmask.filter(ImageFilter.GaussianBlur(1)))
    d = ImageDraw.Draw(img)
    d.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], outline=rgb, width=2)

    # Icon glyph inside the ring.
    f_big = _font(int(rad * 0.9))
    glyph = {"hero": "▶", "poster": "◎", "wide": "▦"}.get(kind, "◎")
    _center_text(d, cx, cy, glyph, f_big, (255, 255, 255))

    # Label + placeholder note.
    f_label = _font(int(h * 0.09))
    f_note = _font(int(h * 0.045))
    _center_text(d, w // 2, int(h * 0.72), label, f_label, (255, 255, 255))
    _center_text(
        d,
        w // 2,
        int(h * 0.82),
        "PLACEHOLDER — DROP YOUR OWN FILE HERE",
        f_note,
        rgb,
    )
    _center_text(
        d,
        w // 2,
        int(h * 0.89),
        "original demo slate · not show content",
        _font(int(h * 0.035)),
        (150, 150, 160),
    )
    return img


def _center_text(d, cx, cy, text, font, fill):
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((cx - tw / 2, cy - th / 2), text, font=font, fill=fill)


def main():
    os.makedirs(IMG, exist_ok=True)
    os.makedirs(VID, exist_ok=True)

    for stem, label, rgb, kind in STILLS:
        w, h = (900, 1200) if kind == "poster" else (1200, 700)
        if kind == "hero":
            w, h = 1600, 900
        img = _draw_slate(w, h, label, rgb, kind)
        path = os.path.join(IMG, f"{stem}.jpg")
        img.save(path, "JPEG", quality=82)
        print(f"still {stem}.jpg {w}x{h} {os.path.getsize(path)//1024}KB")

    # Video slates: a short animated still (pulse) rendered to mp4 via ffmpeg.
    for stem, label, rgb in VIDEOS:
        frames_dir = os.path.join(VID, f".tmp_{stem}")
        os.makedirs(frames_dir, exist_ok=True)
        base = _draw_slate(1280, 720, label, rgb, "wide")
        for i in range(24):
            # Pulse the ring brightness across frames.
            f = base.copy()
            d = ImageDraw.Draw(f)
            scale = 0.5 + 0.5 * abs((i / 24) * 2 - 1)
            cx, cy = 640, int(720 * 0.42)
            rad = int(144 * (0.9 + 0.12 * scale))
            d.ellipse(
                [cx - rad, cy - rad, cx + rad, cy + rad],
                outline=tuple(int(c * scale) for c in rgb),
                width=4,
            )
            f.save(os.path.join(frames_dir, f"f{i:03d}.png"))
        out = os.path.join(VID, f"{stem}.mp4")
        subprocess.run(
            [
                "ffmpeg", "-y", "-loglevel", "error",
                "-framerate", "12", "-i",
                os.path.join(frames_dir, "f%03d.png"),
                "-c:v", "libx264", "-pix_fmt", "yuv420p",
                "-movflags", "+faststart", out,
            ],
            check=True,
        )
        for fn in os.listdir(frames_dir):
            os.remove(os.path.join(frames_dir, fn))
        os.rmdir(frames_dir)
        print(f"video {stem}.mp4 {os.path.getsize(out)//1024}KB")

    print("done")


if __name__ == "__main__":
    main()
