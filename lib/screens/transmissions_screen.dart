import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sfx.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/particles.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/seasons.dart';
import 'trailer_player_screen.dart';

/// Transmissions from Hawkins: every official trailer (streamed from
/// Netflix's own YouTube channels) and a bank of original synth "radio
/// signals" with an animated title card and waveform that work offline.
class TransmissionsScreen extends ConsumerStatefulWidget {
  const TransmissionsScreen({super.key});

  @override
  ConsumerState<TransmissionsScreen> createState() =>
      _TransmissionsScreenState();
}

class _Transmission {
  const _Transmission({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String asset;
  final Color accent;
  final IconData icon;
}

const _transmissions = <_Transmission>[
  _Transmission(
    title: 'Main Title',
    subtitle: 'The synth that started it all.',
    asset: 'audio/theme.wav',
    accent: AppColors.stRed,
    icon: Icons.graphic_eq,
  ),
  _Transmission(
    title: 'The Portal',
    subtitle: 'Something breathes beneath the lab.',
    asset: 'audio/portal.wav',
    accent: AppColors.udVine,
    icon: Icons.blur_on,
  ),
  _Transmission(
    title: 'Eleven\'s Power',
    subtitle: 'The hum before the nosebleed.',
    asset: 'audio/power.wav',
    accent: Color(0xFFF09CB8),
    icon: Icons.bolt,
  ),
  _Transmission(
    title: 'The Shriek',
    subtitle: 'Petals open. Do not answer.',
    asset: 'audio/screech.wav',
    accent: Color(0xFFEF5350),
    icon: Icons.pets,
  ),
  _Transmission(
    title: 'Radio Silence',
    subtitle: 'Channel one, and nobody home.',
    asset: 'audio/static.wav',
    accent: Color(0xFF78909C),
    icon: Icons.wifi_tethering,
  ),
];

class _TransmissionsScreenState extends ConsumerState<TransmissionsScreen> {
  final _player = AudioPlayer();
  int? _playingIndex;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  Timer? _waveTimer;
  double _level = 0;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    // Tuning in: a burst of static as the receiver warms up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Sfx.cue(ref, 'audio/static.wav', volume: 0.3);
    });
    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingIndex = null;
          _level = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _waveTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(int i) async {
    if (_playingIndex == i) {
      await _player.stop();
      _waveTimer?.cancel();
      if (mounted) {
        setState(() {
          _playingIndex = null;
          _level = 0;
        });
      }
      return;
    }
    await _player.stop();
    await _player.play(AssetSource(_transmissions[i].asset));
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() => _level = 0.25 + math.Random().nextDouble() * 0.75);
    });
    setState(() => _playingIndex = i);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final trailers = [for (final season in Seasons.all) ...season.trailers];

    return STScaffold(
      title: 'TRANSMISSIONS',
      subtitle:
          '${trailers.length} trailers · ${_transmissions.length} radio signals',
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          const SectionHeader(
            title: 'Official Trailers',
            padding: EdgeInsets.fromLTRB(0, 16, 0, 12),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemCount: trailers.length,
            itemBuilder: (context, i) => FlickerIn(
              index: i,
              child: TrailerCard(
                trailer: trailers[i],
                onTap: () {
                  // Don't talk over the trailer.
                  if (_playingIndex != null) _toggle(_playingIndex!);
                  RiftPageRoute.push(
                    context,
                    TrailerPlayerScreen(trailer: trailers[i]),
                    name: '/trailer',
                  );
                },
              ),
            ),
          ),
          const SectionHeader(
            title: 'Radio Signals',
            padding: EdgeInsets.fromLTRB(0, 28, 0, 12),
          ),
          // Now-playing hero card.
          if (_playingIndex != null) ...[
            _NowPlayingCard(
              t: _transmissions[_playingIndex!],
              position: _position,
              duration: _duration,
              level: _level,
              progressText: '${_fmt(_position)} / ${_fmt(_duration)}',
            ),
            const SizedBox(height: 18),
          ],
          for (var i = 0; i < _transmissions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TransmissionTile(
                t: _transmissions[i],
                isPlaying: _playingIndex == i,
                level: _level,
                onTap: () => _toggle(i),
              ),
            ),
          const SizedBox(height: 8),
          NeonCard(
            tube: false,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: world.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Trailers stream from Netflix\'s official YouTube channels. '
                    'Radio signals are original synth homages generated for this '
                    'app (tool/generate_audio.py) - no recordings from the show.',
                    style: AppText.body(world.muted, size: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({
    required this.t,
    required this.position,
    required this.duration,
    required this.level,
    required this.progressText,
  });

  final _Transmission t;
  final Duration position;
  final Duration duration;
  final double level;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    final accent = WorldPalette.of(context).tint(t.accent);
    final pct = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [accent, accent.withValues(alpha: 0.6), Colors.black87],
            stops: const [0, 0.5, 1],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ParticleField(
              color: Colors.white,
              glowColor: accent,
              count: 22,
              baseRadius: 1.0,
              speed: 1.4,
              opacity: 0.55,
            ),
            Positioned(
              left: 20,
              top: 20,
              right: 20,
              child: Row(
                children: [
                  Icon(t.icon, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.title.toUpperCase(),
                      style: AppText.label(Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            // Waveform strip.
            Positioned(
              left: 20,
              right: 20,
              bottom: 56,
              child: SizedBox(
                height: 44,
                child: CustomPaint(
                  painter: _WaveformPainter(
                    level: level,
                    color: accent,
                    progress: pct,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 4,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(progressText, style: AppText.label(Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.level,
    required this.color,
    required this.progress,
  });

  final double level;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 42;
    final gap = size.width / bars;
    final paint = Paint()..strokeCap = StrokeCap.round;
    final played = (bars * progress).floor();

    for (var i = 0; i < bars; i++) {
      final seed = (i * 37) % 100 / 100;
      final h = (0.2 + 0.8 * seed * level) * size.height;
      final x = i * gap + gap / 2;
      paint.color = i <= played ? color : color.withValues(alpha: 0.28);
      paint.strokeWidth = gap * 0.55;
      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.level != level || old.progress != progress || old.color != color;
}

class _TransmissionTile extends StatelessWidget {
  const _TransmissionTile({
    required this.t,
    required this.isPlaying,
    required this.level,
    required this.onTap,
  });

  final _Transmission t;
  final bool isPlaying;
  final double level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final accent = world.tint(t.accent);
    return NeonCard(
      onTap: onTap,
      glow: t.accent,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [accent, accent.withValues(alpha: 0.6)],
              ),
              boxShadow: isPlaying
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5 + level * 0.3),
                        blurRadius: 14 + level * 10,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: AppText.h2(world.ink).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(t.subtitle, style: AppText.body(world.muted, size: 12.5)),
              ],
            ),
          ),
          if (isPlaying)
            SizedBox(
              width: 34,
              height: 24,
              child: CustomPaint(
                painter: _MiniBars(color: accent, level: level),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniBars extends CustomPainter {
  const _MiniBars({required this.color, required this.level});

  final Color color;
  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final h = (0.3 + 0.7 * ((i + 1) / 3) * level) * size.height;
      paint.color = color;
      paint.strokeWidth = 3;
      final x = i * (size.width / 3) + size.width / 6;
      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBars old) => old.level != level;
}
