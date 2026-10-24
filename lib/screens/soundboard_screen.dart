import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/audio/sfx.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/soundboard.dart';
import '../models/sound_clip.dart';

/// Soundboard: a grid of original synth cues, like a bank of pads on a
/// 1984 synth. Tapping a pad plays it and pulses its glow in time with an
/// amplitude meter.
class SoundboardScreen extends StatefulWidget {
  const SoundboardScreen({super.key});

  @override
  State<SoundboardScreen> createState() => _SoundboardScreenState();
}

class _SoundboardScreenState extends State<SoundboardScreen>
    with SoundtrackClaimMixin {
  final _player = AudioPlayer();
  StreamSubscription<void>? _completeSub;
  String? _playingId;
  double _level = 0;
  Timer? _meter;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      _meter?.cancel();
      setState(() {
        _playingId = null;
        _level = 0;
      });
    });
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _meter?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(SoundClip clip) async {
    HapticFeedback.selectionClick();
    if (_playingId == clip.id) {
      await _player.stop();
      _meter?.cancel();
      setState(() {
        _playingId = null;
        _level = 0;
      });
      return;
    }
    await _player.stop();
    await _player.play(AssetSource(clip.asset));
    _meter?.cancel();
    final rng = math.Random();
    _meter = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (!mounted) return;
      setState(() => _level = 0.3 + rng.nextDouble() * 0.7);
    });
    setState(() => _playingId = clip.id);
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return STScaffold(
      title: 'SOUNDBOARD',
      subtitle: '${Soundboard.clips.length} original synth cues',
      actions: [
        IconButton(
          tooltip: _muted ? 'Unmute' : 'Mute',
          icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
          onPressed: () {
            _player.setVolume(_muted ? 1 : 0);
            setState(() => _muted = !_muted);
          },
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          NeonCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.graphic_eq, color: world.accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Original synth cues, generated for this app. Tap a pad to '
                    'trigger it - tap again to stop.',
                    style: AppText.body(world.muted, size: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.98,
            ),
            itemCount: Soundboard.clips.length,
            itemBuilder: (context, i) {
              final clip = Soundboard.clips[i];
              final isPlaying = _playingId == clip.id;
              return FlickerIn(
                index: i,
                child: _SoundTile(
                  clip: clip,
                  isPlaying: isPlaying,
                  level: isPlaying ? _level : 0,
                  onTap: () => _play(clip),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SoundTile extends StatefulWidget {
  const _SoundTile({
    required this.clip,
    required this.isPlaying,
    required this.level,
    required this.onTap,
  });

  final SoundClip clip;
  final bool isPlaying;
  final double level;
  final VoidCallback onTap;

  @override
  State<_SoundTile> createState() => _SoundTileState();
}

class _SoundTileState extends State<_SoundTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final accent = world.tint(widget.clip.accent);

    return Semantics(
      button: true,
      label: '${widget.isPlaying ? 'Stop' : 'Play'} ${widget.clip.label}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(14),
                transform: Matrix4.diagonal3Values(
                  widget.isPlaying ? 1.02 : 1.0,
                  widget.isPlaying ? 1.02 : 1.0,
                  1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: widget.isPlaying
                        ? [
                            accent.withValues(alpha: 0.5),
                            accent.withValues(alpha: 0.2),
                            world.card,
                          ]
                        : [accent.withValues(alpha: 0.16), world.card],
                    stops: widget.isPlaying
                        ? const [0, 0.45, 1]
                        : const [0, 0.7],
                  ),
                  border: Border.all(
                    color: accent.withValues(
                      alpha: widget.isPlaying ? 0.9 : 0.35,
                    ),
                    width: widget.isPlaying ? 1.6 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(
                        alpha: widget.isPlaying
                            ? 0.35 + widget.level * 0.25
                            : 0.1,
                      ),
                      blurRadius: widget.isPlaying
                          ? 18 + widget.level * 12
                          : 16,
                      spreadRadius: widget.isPlaying ? 1 : 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.15),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.clip.icon,
                            color: accent,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          widget.isPlaying ? Icons.stop : Icons.play_arrow,
                          color: accent,
                          size: 22,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.clip.label,
                          style: AppText.h2(world.ink).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        // Amplitude bars animate while playing.
                        SizedBox(
                          height: 30,
                          child: widget.isPlaying
                              ? CustomPaint(
                                  size: const Size(double.infinity, 30),
                                  painter: _BarsPainter(
                                    color: accent,
                                    level: widget.level,
                                  ),
                                )
                              : Text(
                                  widget.clip.caption,
                                  style: AppText.body(world.muted, size: 11.5),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({required this.color, required this.level});

  final Color color;
  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 24;
    final gap = size.width / bars;
    final paint = Paint()..strokeCap = StrokeCap.round;
    final rng = math.Random();

    for (var i = 0; i < bars; i++) {
      final h = (0.15 + rng.nextDouble() * 0.85 * level) * size.height;
      final x = i * gap + gap / 2;
      paint.color = color.withValues(alpha: 0.85);
      paint.strokeWidth = gap * 0.5;
      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.level != level || old.color != color;
}
