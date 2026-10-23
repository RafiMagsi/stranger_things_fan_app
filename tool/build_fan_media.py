#!/usr/bin/env python3
"""Builds the app's fan-media pack from the raw files in docs/.

    python3 tool/build_fan_media.py            # build everything
    python3 tool/build_fan_media.py --clean    # remove the pack again
    python3 tool/build_fan_media.py thumbs     # one group: loops, frames, art,
                                               # audio, reel or thumbs

Sources (supplied by the app's owner, not downloaded by this script):
    docs/videos/*.mp4   phone-recorded fan edits (most are landscape footage
                        stored sideways in a 9:16 frame)
    docs/images/*.PNG   phone screenshots of fan art (UI bars around the art)

Outputs, all small enough to bundle:
    assets/video/<key>.mp4            muted UI loops (dossiers, hero, Gate...)
    assets/video/reel_<slug>.mp4      the Reel: full edits with sound, upright
    assets/images/<key>.jpg           drop-in stills (char_*, season_*, ...)
    assets/images/reel/<slug>.jpg     Reel thumbnails
    assets/images/fan/<slug>.jpg      the fan-art gallery
    assets/audio/captures/<key>.m4a   soundboard captures

Everything here is third-party fan work around Netflix footage. It is fine
for a personal build; strip it (--clean) before publishing the app anywhere.
The matching credits live in lib/data/fan_media.dart.

Requires ffmpeg and Pillow.
"""

import json
import os
import shutil
import subprocess
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VIDEOS = os.path.join(ROOT, 'docs', 'videos')
IMAGES = os.path.join(ROOT, 'docs', 'images')
OUT_VIDEO = os.path.join(ROOT, 'assets', 'video')
OUT_IMAGES = os.path.join(ROOT, 'assets', 'images')
OUT_AUDIO = os.path.join(ROOT, 'assets', 'audio', 'captures')

# Each source by a unique prefix of its file name (the names are hashtags).
SRC = {
    1: '#Strangerthings #aesthetic',
    2: '#strangerthings #aesthetic #netflix',
    3: '#strangerthings #netflix (1)',
    4: '#strangerthings #netflix.mp4',
    5: 'AQPy7SVM2u1z',
    6: 'Am I dreaming',
    7: 'Filming credit- @beitman.ae',
    8: 'Four time(s)',
    10: 'I don’t wanna say goodbye',
    12: 'Part 2 Trailer',
    13: 'Peakkkkkk',
    14: 'Pure goosebumps',
    15: 'Quality Setting is In Bio',
    16: 'Quality settings is in bio',
    17: 'Riding into the unknown',
    19: 'Steve Harrington 🗿',
    20: 'Stranger Things 🥵',
    21: 'Stranger fam…happy 1 year',
    25: 'The clock is ticking',
    26: 'Ticking clocks are going',
    28: 'Vecna knew he was cooked',
    29: 'W series',
    30: 'WILL. BYERS.',
    31: 'Wait Is Over',
    33: 'William in S5',
    35: '[4K 60FPS] Stranger Things – One Last Adventure',
    36: '[4K+60FPS] Stranger things',
    37: '[4K] Stranger Things Finale Edit',
    38: '[4K] The Undying King Vecna',
    39: '[4k] Vecna🔥#strangerthings #strangerthingss5 #edit #fyp #explorepage #vecna #will (1)',
    40: '[4k] Vecna🔥#strangerthings #strangerthingss5 #edit #fyp #explorepage #vecna #will.mp4',
    41: 'in the fall of 1987',
    42: 'it’s almost time',
}

# Landscape footage recorded sideways: turned 90° counter-clockwise.
SIDEWAYS = {1, 2, 3, 4, 7, 10, 12, 13, 14, 15, 16, 19, 20, 28, 29, 33, 35, 36,
            37, 38, 39, 40}

# Muted loops: key -> list of (source, start, end); 'boomerang' plays the
# span forward then back so a slow shot loops without a cut.
LOOPS = {
    'hero_finale': dict(parts=[(37, 0.0, 3.35)], boomerang=True),
    'gate_crossing': dict(parts=[(38, 0.3, 4.4)]),
    'gate_hawkins': dict(parts=[(17, 0.0, 15.0)]),
    'ud_lightning': dict(parts=[(16, 0.2, 3.9)]),
    'ud_red': dict(parts=[(1, 0.8, 5.6)]),
    'bikes_night': dict(parts=[(3, 2.9, 5.2)]),
    'clock_loop': dict(parts=[(42, 0.0, 6.4)]),
    'vinyl_loop': dict(parts=[(5, 2.0, 6.0)]),
    'char_eleven': dict(parts=[(28, 4.8, 7.6)]),
    'char_will': dict(parts=[(33, 4.6, 8.2)]),
    'char_mike': dict(parts=[(39, 0.3, 4.5)]),
    'char_steve': dict(parts=[(19, 6.2, 8.4)]),
    'char_max': dict(parts=[(29, 7.2, 10.6)]),
    'char_hopper': dict(parts=[(7, 9.0, 10.4), (35, 6.5, 8.0)]),
    'char_nancy': dict(parts=[(20, 19.3, 21.6), (4, 12.0, 13.0)]),
    'char_vecna': dict(parts=[(38, 4.5, 8.6)]),
    'char_demogorgon': dict(parts=[(33, 15.6, 18.6)]),
    'char_mind_flayer': dict(parts=[(13, 0.0, 3.8)]),
    'monster_demogorgon': dict(parts=[(33, 9.4, 12.4)]),
    'monster_mind_flayer': dict(parts=[(13, 4.0, 8.6)]),
    'monster_vecna': dict(parts=[(12, 4.2, 7.2)]),
}

# The Reel: slug -> (source, start, end or None, thumbnail time).
REEL = {
    'finale': (37, 0, None, 1.6),
    'adventure': (35, 0, None, 7.1),
    'eleven': (36, 0, None, 14.2),
    'undying_king': (38, 0, None, 6.3),
    'mind_flayer': (13, 0, None, 5.7),
    'stranger_things': (20, 0, None, 3.2),
    'w_series': (29, 0, None, 0.6),
    'william': (33, 0, None, 5.4),
    'steve': (19, 0, None, 8.9),
    'other_side': (15, 0, None, 7.3),
    'one': (16, 0, None, 5.9),
    'vecna_4k': (39, 0, None, 2.3),
    'creel_house': (40, 0, None, 9.2),
    'goodbye': (10, 0, None, 15.3),
    'goosebumps': (14, 0, None, 1.0),
    'volume_2': (12, 0, None, 5.7),
    'beitman': (7, 0, None, 4.5),
    'aesthetic_1': (1, 0, None, 3.0),
    'aesthetic_2': (2, 0, None, 7.6),
    'aesthetic_3': (3, 0, None, 7.3),
    'aesthetic_4': (4, 0, None, 4.9),
    'cooked': (28, 0, None, 5.1),
    'kate_bush': (21, 55.0, 113.0, 63.8),
    'fall_1987': (41, 0, None, 44.0),
    'will': (30, 0, None, 31.9),
    'riding': (17, 0, None, 7.0),
    'wait_over': (31, 0, None, 3.5),
    'pumpkin': (25, 0, None, 5.4),
    'almost_time': (42, 0, None, 5.2),
    'four_times': (8, 0, None, 6.4),
    'billy': (6, 0, None, 8.5),
}

# Stills cut from footage: key -> (source, time, crop). 'portrait' cuts a
# 3:4 card centred on cx (0..1 across the upright frame); 'full' keeps it.
FRAMES = {
    'char_eleven': (29, 0.6, ('portrait', 0.50)),
    'char_will': (33, 5.4, ('portrait', 0.52)),
    'char_mike': (39, 2.3, ('portrait', 0.50)),
    'char_steve': (19, 8.9, ('portrait', 0.48)),
    'char_max': (29, 9.8, ('portrait', 0.53)),
    'char_hopper': (7, 9.6, ('portrait', 0.56)),
    'char_nancy': (20, 20.1, ('portrait', 0.64)),
    'char_vecna': (12, 5.7, ('portrait', 0.50)),
    'char_demogorgon': (33, 16.1, ('portrait', 0.60)),
    'char_mind_flayer': (37, 1.6, ('portrait', 0.50)),
    'monster_demogorgon': (33, 9.9, ('full', None)),
    'monster_mind_flayer': (13, 8.7, ('full', None)),
    'monster_vecna': (38, 6.3, ('full', None)),
    'loc_creel_house': (4, 4.9, ('full', None)),
    'loc_upside_down': (1, 3.7, ('full', None)),
    'st_clock': (42, 3.5, ('full', None)),
}

# Fan art: slug -> (screenshot, stored sideways?). Gallery copies plus the
# drop-in keys that reuse them.
FAN_ART = {
    'cast_poster': ('IMG_9691.PNG', False),
    'logo_bikes': ('IMG_9692.PNG', True),
    'eleven_reach': ('IMG_9693.PNG', True),
    'eleven_paint': ('IMG_9694.PNG', False),
    'will': ('IMG_9695.PNG', True),
    'max': ('IMG_9696.PNG', True),
    'steve_bat': ('IMG_9697.PNG', True),
    'henry_creel': ('IMG_9698.PNG', True),
    'eleven_011_pink': ('IMG_9699.PNG', False),
    'steve_shades': ('IMG_9700.PNG', False),
    'eddie': ('IMG_9701.PNG', False),
    'demogorgon': ('IMG_9702.PNG', False),
    'vecna': ('IMG_9703.PNG', False),
    'bedroom': ('IMG_9704.PNG', False),
    'shotgun': ('IMG_9705.PNG', False),
    'eleven_011': ('IMG_9706.PNG', False),
    'mind_flayer': ('IMG_9707.PNG', False),
    'bikes_mirror': ('IMG_9708.PNG', False),
    'red_storm': ('IMG_9709.PNG', False),
    'red_forest': ('IMG_9710.PNG', False),
    'vecna_clock': ('IMG_9711.PNG', False),
}
FAN_KEYS = {
    'featured': 'cast_poster',
    'season_1': 'eleven_011_pink',
    'season_2': 'mind_flayer',
    'season_3': 'red_storm',
    'season_4': 'vecna_clock',
    'season_5': 'red_forest',
    'bg_upside': 'bikes_mirror',
    'gate_eleven': 'eleven_reach',
    'henry_creel': 'henry_creel',
}

# Soundboard captures: key -> (source, start, end).
AUDIO = {
    'vecna_chimes': (25, 10.2, 20.8),
    'clock_ticking': (26, 3.0, 10.0),
    'almost_time': (42, 0.0, 7.0),
    'running_up_that_hill': (5, 0.0, 16.0),
    'fall_of_1987': (41, 3.0, 21.0),
    'finale': (37, 3.3, 13.0),
}

# Files earlier passes left behind that this pack replaces.
OBSOLETE = [
    'assets/video/adventure.mp4', 'assets/video/clock.mp4',
    'assets/video/eleven.mp4', 'assets/video/gate_finale.mp4',
    'assets/video/hawkins_world.mp4', 'assets/video/kate_bush.mp4',
    'assets/video/max.mp4', 'assets/video/mind_flayer.mp4',
    'assets/video/s5_teaser.mp4', 'assets/video/steve.mp4',
    'assets/video/upside_down.mp4', 'assets/video/vecna.mp4',
    'assets/video/will.mp4',
    'assets/images/bg_hawkins.jpg', 'assets/images/st_adventure.jpg',
    'assets/audio/captures/ticking.wav', 'assets/audio/captures/that_hill.wav',
    'assets/audio/captures/finale.wav', 'assets/audio/captures/fall1987.wav',
]


def src_path(i):
    matches = [f for f in os.listdir(VIDEOS) if f.startswith(SRC[i])]
    if len(matches) != 1:
        sys.exit(f'source #{i}: expected one match for {SRC[i]!r}, got {matches}')
    return os.path.join(VIDEOS, matches[0])


def probe(path):
    out = subprocess.run(['ffprobe', '-v', 'error', '-select_streams', 'v:0', '-show_entries',
                          'stream=width,height', '-of', 'json', path], capture_output=True, text=True)
    s = json.loads(out.stdout)['streams'][0]
    return s['width'], s['height']


def upright(i, long_edge):
    """Filter chain that turns source #i upright and scales its long edge."""
    w, h = probe(src_path(i))
    if i in SIDEWAYS:
        w, h = h, w
    rot = 'transpose=2,' if i in SIDEWAYS else ''
    scale = f'scale={long_edge}:-2' if w >= h else f'scale=-2:{long_edge}'
    return rot + scale + ',setsar=1'


def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f'ffmpeg failed: {" ".join(cmd)}\n{r.stderr[-2000:]}')


X264 = ['-c:v', 'libx264', '-profile:v', 'high', '-preset', 'slow', '-pix_fmt', 'yuv420p',
        '-movflags', '+faststart']


def build_loop(key, spec):
    out = os.path.join(OUT_VIDEO, f'{key}.mp4')
    cmd = ['ffmpeg', '-v', 'error', '-y']
    for (i, a, b) in spec['parts']:
        cmd += ['-ss', f'{a}', '-t', f'{b - a}', '-i', src_path(i)]
    parts = spec['parts']
    if len(parts) == 1:
        graph = f'[0:v]{upright(parts[0][0], 960)},fps=30,setpts=PTS-STARTPTS[s]'
    else:
        # Shots from different edits: one 960x540 frame so they join.
        graph = ';'.join(
            f'[{n}:v]{upright(i, 960)},fps=30,scale=960:540:force_original_aspect_ratio=increase,'
            f'crop=960:540,setsar=1,setpts=PTS-STARTPTS[p{n}]' for n, (i, _, _) in enumerate(parts))
        graph += ';' + ''.join(f'[p{n}]' for n in range(len(parts))) + \
            f'concat=n={len(parts)}:v=1:a=0[s]'
    if spec.get('boomerang'):
        graph += ';[s]split[a][b];[b]reverse[r];[a][r]concat=n=2:v=1:a=0[v]'
    else:
        graph += ';[s]null[v]'
    cmd += ['-filter_complex', graph, '-map', '[v]', '-an', *X264, '-crf', '27', '-g', '60', out]
    run(cmd)
    return out


def build_thumb(slug, spec):
    i, _, _, thumb_t = spec
    thumb = os.path.join(OUT_IMAGES, 'reel', f'{slug}.jpg')
    run(['ffmpeg', '-v', 'error', '-y', '-ss', f'{thumb_t}', '-i', src_path(i), '-frames:v', '1',
         '-vf', upright(i, 480), '-q:v', '4', thumb])
    return thumb


def build_reel(slug, spec):
    i, a, b, thumb_t = spec
    out = os.path.join(OUT_VIDEO, f'reel_{slug}.mp4')
    cmd = ['ffmpeg', '-v', 'error', '-y', '-ss', f'{a}']
    if b is not None:
        cmd += ['-t', f'{b - a}']
    cmd += ['-i', src_path(i), '-vf', upright(i, 854), *X264, '-crf', '31', '-g', '60',
            '-c:a', 'aac', '-b:a', '80k', '-ac', '2', out]
    run(cmd)
    build_thumb(slug, spec)
    return out


def frame(i, t):
    tmp = os.path.join(ROOT, 'build', 'fan_media_frame.png')
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    vf = 'transpose=2' if i in SIDEWAYS else 'null'
    run(['ffmpeg', '-v', 'error', '-y', '-ss', f'{t}', '-i', src_path(i), '-frames:v', '1', '-vf', vf, tmp])
    return Image.open(tmp).convert('RGB')


def build_frame(key, spec):
    i, t, (mode, cx) = spec
    im = frame(i, t)
    if mode == 'portrait':
        w, h = im.size
        cw = int(h * 3 / 4)
        left = max(0, min(w - cw, int(cx * w - cw / 2)))
        im = im.crop((left, 0, left + cw, h))
    im.thumbnail((1280, 1280), Image.LANCZOS)
    out = os.path.join(OUT_IMAGES, f'{key}.jpg')
    im.save(out, 'JPEG', quality=86, optimize=True, progressive=True)
    return out


def art_box(im):
    """The fan art's own rectangle inside a phone screenshot. The app chrome
    above and below is flat, the art is textured - except where the art has
    dark bands of its own, so long textured runs are merged across short
    gaps while the short comment bar at the bottom is left out."""
    g = im.convert('L')
    w, h = g.size
    px = g.load()
    def textured_row(y):
        vals = [px[x, y] for x in range(0, w, 8)]
        m = sum(vals) / len(vals)
        return (sum((v - m) ** 2 for v in vals) / len(vals)) ** 0.5 > 6 or m > 40
    rows = [textured_row(y) for y in range(h)]
    runs, start = [], None
    for y, on in enumerate(rows + [False]):
        if on and start is None:
            start = y
        elif not on and start is not None:
            runs.append((start, y))
            start = None
    long_runs = [r for r in runs if r[1] - r[0] >= h * 0.07]
    spans = []
    for r in long_runs:
        if spans and r[0] - spans[-1][1] < h * 0.15:
            spans[-1] = (spans[-1][0], r[1])
        else:
            spans.append(r)
    top, bottom = max(spans, key=lambda s: s[1] - s[0])
    def textured_col(x):
        vals = [px[x, y] for y in range(top, bottom, 8)]
        m = sum(vals) / len(vals)
        return (sum((v - m) ** 2 for v in vals) / len(vals)) ** 0.5 > 6 or m > 40
    cols = [x for x in range(w) if textured_col(x)]
    left, right = (min(cols), max(cols) + 1) if cols else (0, w)
    # A thin scrollbar can sit apart from the art on the right: ignore
    # isolated columns more than 2% away from the main block.
    block = [x for x in cols if x < w * 0.97]
    if block:
        right = max(block) + 1
    return left, top, right, bottom


def build_fan_art():
    os.makedirs(os.path.join(OUT_IMAGES, 'fan'), exist_ok=True)
    made = {}
    for slug, (name, sideways) in FAN_ART.items():
        im = Image.open(os.path.join(IMAGES, name)).convert('RGB')
        im = im.crop(art_box(im))
        if sideways:
            im = im.rotate(90, expand=True)
        im.thumbnail((1600, 1600), Image.LANCZOS)
        out = os.path.join(OUT_IMAGES, 'fan', f'{slug}.jpg')
        im.save(out, 'JPEG', quality=84, optimize=True, progressive=True)
        made[slug] = out
    for key, slug in FAN_KEYS.items():
        im = Image.open(made[slug])
        im.thumbnail((1280, 1280), Image.LANCZOS)
        im.save(os.path.join(OUT_IMAGES, f'{key}.jpg'), 'JPEG', quality=86, optimize=True, progressive=True)
    return made


def build_audio(key, spec):
    i, a, b = spec
    out = os.path.join(OUT_AUDIO, f'{key}.m4a')
    d = b - a
    run(['ffmpeg', '-v', 'error', '-y', '-ss', f'{a}', '-t', f'{d}', '-i', src_path(i), '-vn',
         '-af', f'loudnorm=I=-16:TP=-1.5:LRA=11,afade=t=in:d=0.15,afade=t=out:st={max(0, d - 1.2)}:d=1.2',
         '-c:a', 'aac', '-b:a', '128k', '-ac', '2', '-ar', '44100', '-movflags', '+faststart', out])
    return out


def clean(everything=False):
    paths = [os.path.join(ROOT, p) for p in OBSOLETE]
    if everything:
        paths += [os.path.join(OUT_VIDEO, f'{k}.mp4') for k in LOOPS]
        paths += [os.path.join(OUT_VIDEO, f'reel_{k}.mp4') for k in REEL]
        paths += [os.path.join(OUT_IMAGES, f'{k}.jpg') for k in list(FRAMES) + list(FAN_KEYS)]
        paths += [os.path.join(OUT_AUDIO, f'{k}.m4a') for k in AUDIO]
        for d in ('reel', 'fan'):
            shutil.rmtree(os.path.join(OUT_IMAGES, d), ignore_errors=True)
    for p in paths:
        if os.path.exists(p):
            os.remove(p)


def main():
    if '--clean' in sys.argv:
        clean(everything=True)
        print('fan media removed')
        return
    clean()
    for d in (OUT_VIDEO, OUT_AUDIO, os.path.join(OUT_IMAGES, 'reel')):
        os.makedirs(d, exist_ok=True)
    only = [a for a in sys.argv[1:] if not a.startswith('-')]
    def want(group):
        return not only or group in only
    if want('loops'):
        for k, s in LOOPS.items():
            print('loop', k, os.path.getsize(build_loop(k, s)) // 1024, 'KB')
    if want('frames'):
        for k, s in FRAMES.items():
            print('frame', k, build_frame(k, s))
    if want('art'):
        for slug, p in build_fan_art().items():
            print('art', slug, Image.open(p).size)
    if want('audio'):
        for k, s in AUDIO.items():
            print('audio', k, os.path.getsize(build_audio(k, s)) // 1024, 'KB')
    if want('thumbs'):
        for k, s in REEL.items():
            build_thumb(k, s)
        print('thumbs', len(REEL))
    if want('reel'):
        for k, s in REEL.items():
            print('reel', k, os.path.getsize(build_reel(k, s)) // 1024, 'KB')


if __name__ == '__main__':
    main()
