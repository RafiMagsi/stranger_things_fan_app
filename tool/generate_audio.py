#!/usr/bin/env python3
"""Synthesize original 80s-synth-flavored WAV cues for the Stranger Things fan app.

All audio here is generated procedurally - it is an original homage in the style
of analog synth scores, NOT transcriptions of any copyrighted music.

Outputs 16-bit mono 22050 Hz WAVs into assets/audio/.
"""
import math
import os
import random
import struct
import wave

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
random.seed(1986)


def write_wav(name, samples):
    path = os.path.join(OUT, name)
    os.makedirs(OUT, exist_ok=True)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples
        )
        w.writeframes(frames)
    kb = os.path.getsize(path) // 1024
    print(f"{name}: {len(samples)/SR:.2f}s {kb}KB")


def env(i, n, attack=0.01, release=0.3):
    t = i / SR
    total = n / SR
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = min(1.0, (total - t) / release) if release > 0 else 1.0
    return max(0.0, min(a, r))


def saw(f, t):
    return 2.0 * ((f * t) % 1.0) - 1.0


def square(f, t, duty=0.5):
    return 1.0 if ((f * t) % 1.0) < duty else -1.0


def sine(f, t):
    return math.sin(2 * math.pi * f * t)


def lowpass(samples, cutoff):
    """One-pole lowpass."""
    rc = 1.0 / (2 * math.pi * cutoff)
    dt = 1.0 / SR
    a = dt / (rc + dt)
    out = []
    y = 0.0
    for x in samples:
        y += a * (x - y)
        out.append(y)
    return out


def echo(samples, delay_s=0.28, fb=0.38, mix=0.35, taps=4):
    d = int(delay_s * SR)
    out = list(samples)
    for tap in range(1, taps + 1):
        g = (fb ** tap) * mix
        for i in range(d * tap, len(out)):
            out[i] += samples[i - d * tap] * g
    return out


def norm(samples, peak=0.85):
    m = max(1e-6, max(abs(s) for s in samples))
    return [s * (peak / m) for s in samples]


def theme():
    """Original minor-key arpeggio homage: detuned saws + sub + pad + echo."""
    bpm = 96
    beat = 60.0 / bpm
    n = int(beat * 16 * SR)
    # A minor-ish progression, one chord per bar.
    roots = [110.0, 87.31, 130.81, 98.0]  # A2, F2, C3, G2
    arp = [0, 3, 7, 12, 7, 3]
    out = [0.0] * n
    for bar in range(4):
        root = roots[bar]
        start = int(bar * 4 * beat * SR)
        for step in range(12):
            semi = arp[step % len(arp)] + (12 if step % 4 == 3 else 0)
            f = root * 2 * (2 ** (semi / 12.0))
            s0 = start + int(step * (beat / 2) * SR)
            length = int(beat * 0.45 * SR)
            for i in range(length):
                idx = s0 + i
                if idx >= n:
                    break
                t = i / SR
                v = saw(f, t) * 0.5 + saw(f * 1.007, t) * 0.5
                v *= env(i, length, attack=0.004, release=0.2) * 0.5
                out[idx] += v
        # Sub drone for the bar.
        bar_len = int(4 * beat * SR)
        for i in range(bar_len):
            idx = start + i
            if idx >= n:
                break
            t = i / SR
            out[idx] += sine(root / 2, t) * 0.22 * env(i, bar_len, 0.05, 0.4)
    out = lowpass(out, 2600)
    out = echo(out, 60.0 / bpm / 2, 0.4, 0.4)
    # Vinyl-ish noise floor.
    out = [s + (random.random() * 2 - 1) * 0.012 for s in out]
    write_wav("theme.wav", norm(out, 0.8))


def screech():
    """Demogorgon-style shriek: FM sweep + noise."""
    n = int(2.1 * SR)
    out = []
    for i in range(n):
        t = i / SR
        carrier = 900 - 520 * (t / 2.1)
        mod = sine(carrier * 2.4, t) * 180 * (1 - t / 2.6)
        v = sine(carrier + mod, t) * 0.6
        v += (random.random() * 2 - 1) * 0.35 * math.exp(-t * 1.5)
        v *= env(i, n, 0.02, 0.5) * (0.5 + 0.5 * math.sin(t * 21))
        out.append(v)
    write_wav("screech.wav", norm(out, 0.8))


def static_burst():
    """Radio/TV static burst with bandpass wobble."""
    n = int(1.6 * SR)
    noise = [(random.random() * 2 - 1) for _ in range(n)]
    out = lowpass(noise, 5200)
    out = [x - y for x, y in zip(out, lowpass(out, 320))]
    for i in range(n):
        t = i / SR
        wob = 0.55 + 0.45 * math.sin(t * 34 + math.sin(t * 7) * 3)
        out[i] *= wob * env(i, n, 0.01, 0.25)
    write_wav("static.wav", norm(out, 0.7))


def dice():
    """D20 roll: hard clicks decaying in tempo."""
    n = int(1.7 * SR)
    out = [0.0] * n
    times = [0.02, 0.18, 0.32, 0.55, 0.74, 0.98, 1.22, 1.44]
    for k, at in enumerate(times):
        start = int(at * SR)
        length = int(0.05 * SR)
        amp = 0.85 - k * 0.08
        for i in range(length):
            idx = start + i
            if idx >= n:
                break
            t = i / SR
            v = (random.random() * 2 - 1) * math.exp(-t * 90) * amp
            v += sine(1900 - k * 120, t) * math.exp(-t * 120) * 0.4 * amp
            out[idx] += v
    write_wav("dice.wav", norm(out, 0.8))


def squelch():
    """Walkie-talkie beep + static tail."""
    n = int(1.1 * SR)
    out = []
    for i in range(n):
        t = i / SR
        if t < 0.18:
            v = square(1180, t) * 0.4 + square(2360, t) * 0.1
        elif t < 0.3:
            v = 0.0
        else:
            v = (random.random() * 2 - 1) * math.exp(-(t - 0.3) * 7) * 0.5
        out.append(v * env(i, n, 0.005, 0.12))
    write_wav("squelch.wav", norm(out, 0.75))


def portal():
    """Upside Down portal rumble: slow AM low sine + overtones."""
    n = int(3.0 * SR)
    out = []
    for i in range(n):
        t = i / SR
        f = 44 + 12 * math.sin(t * 0.9)
        v = sine(f, t) * 0.8
        v += sine(f * 2.01, t) * 0.25
        v += sine(f * 3.97, t) * 0.12
        v *= 0.55 + 0.45 * math.sin(t * 5.2)
        out.append(v * env(i, n, 0.4, 0.8))
    write_wav("portal.wav", norm(out, 0.85))


def chime():
    """Christmas-light bell ding (inharmonic partials)."""
    n = int(2.2 * SR)
    f = 1046.5
    out = []
    for i in range(n):
        t = i / SR
        v = sine(f, t) * math.exp(-t * 3.2)
        v += sine(f * 2.76, t) * 0.5 * math.exp(-t * 5.5)
        v += sine(f * 5.4, t) * 0.25 * math.exp(-t * 9.0)
        out.append(v * env(i, n, 0.002, 0.5))
    write_wav("chime.wav", norm(out, 0.75))


def coin():
    """Arcade coin blip."""
    n = int(0.5 * SR)
    out = []
    for i in range(n):
        t = i / SR
        f = 523.25 if t < 0.07 else 1046.5
        v = square(f, t, 0.5) * 0.5 + sine(f * 2, t) * 0.2
        out.append(v * env(i, n, 0.003, 0.12))
    write_wav("coin.wav", norm(out, 0.7))


def power():
    """Eleven's power: rising distorted tone + shimmer."""
    n = int(2.4 * SR)
    out = []
    for i in range(n):
        t = i / SR
        f = 70 + 360 * (t / 2.4) ** 1.6
        v = sine(f, t) * 0.7 + saw(f * 1.5, t) * 0.2
        v = math.tanh(v * 4.0) * 0.6  # soft clip
        v += sine(f * 4.02, t) * 0.12 * math.sin(t * 43)
        out.append(v * env(i, n, 0.25, 0.5))
    write_wav("power.wav", norm(out, 0.8))


def clock():
    """Vecna's grandfather clock: a slow tick-tock over a dread drone."""
    n = int(2.4 * SR)
    out = [0.0] * n
    # Dread drone bed.
    for i in range(n):
        t = i / SR
        out[i] += sine(38, t) * 0.18 * env(i, n, 0.3, 0.6)
        out[i] += sine(57, t) * 0.1 * env(i, n, 0.3, 0.6)
    # Ticks every 0.6s.
    for k, at in enumerate([0.05, 0.65, 1.25, 1.85]):
        start = int(at * SR)
        length = int(0.09 * SR)
        for i in range(length):
            idx = start + i
            if idx >= n:
                break
            t = i / SR
            # Woodblock-ish: high click + resonant knock.
            v = (random.random() * 2 - 1) * math.exp(-t * 120)
            v += sine(1800 if k % 2 == 0 else 1300, t) * math.exp(-t * 70) * 0.5
            out[idx] += v * 0.7
    write_wav("clock.wav", norm(out, 0.75))


def heartbeat():
    """A slow thumping heartbeat - tension before a Vecna kill."""
    n = int(2.6 * SR)
    out = [0.0] * n

    def thump(at, amp):
        start = int(at * SR)
        length = int(0.16 * SR)
        for i in range(length):
            idx = start + i
            if idx >= n:
                break
            t = i / SR
            f = 62 * (1 - t / 0.3)
            v = sine(max(f, 30), t) * math.exp(-t * 22) * amp
            out[idx] += v

    for at in [0.0, 0.42, 1.1, 1.52, 2.1]:
        thump(at, 0.9)
        thump(at + 0.18, 0.55)  # the lub-dub pair
    write_wav("heartbeat.wav", norm(out, 0.8))


def vines():
    """Vine rustle / spore shimmer - the Upside Down breathing."""
    n = int(2.2 * SR)
    noise = [(random.random() * 2 - 1) for _ in range(n)]
    out = lowpass(noise, 1600)
    out = [x - y for x, y in zip(out, lowpass(out, 200))]
    for i in range(n):
        t = i / SR
        # Slow swells, like tendrils shifting.
        swell = 0.3 + 0.7 * abs(math.sin(t * 2.3))
        out[i] *= swell * env(i, n, 0.3, 0.6) * 0.5
        # A faint shimmering partial.
        out[i] += sine(660 + 120 * math.sin(t * 3), t) * 0.04 * env(i, n, 0.4, 0.6)
    write_wav("vines.wav", norm(out, 0.65))


if __name__ == "__main__":
    theme()
    screech()
    static_burst()
    dice()
    squelch()
    portal()
    chime()
    coin()
    power()
    clock()
    heartbeat()
    vines()
    print("done")
