import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/particles.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/quiz.dart';
import '../models/quiz_question.dart';

/// Trivia game: shuffled questions across all five seasons, animated
/// correct/wrong feedback, running score, and a rank at the end.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;
  Timer? _advance;

  final _player = AudioPlayer();
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _questions = [...Quiz.bank]..shuffle(math.Random(2016));
  }

  @override
  void dispose() {
    _advance?.cancel();
    _burst.dispose();
    _player.dispose();
    super.dispose();
  }

  QuizQuestion get _current => _questions[_index];

  Future<void> _answer(int i) async {
    if (_selected != null) return;
    setState(() => _selected = i);
    final correct = i == _current.correctIndex;
    if (correct) {
      _score++;
      _burst.forward(from: 0);
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    _advance = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (_index == _questions.length - 1) {
        setState(() => _finished = true);
      } else {
        setState(() {
          _index++;
          _selected = null;
        });
      }
    });

    try {
      await _player.stop();
      await _player.play(AssetSource(correct ? 'audio/chime.wav' : 'audio/static.wav'));
    } catch (_) {
      // Audio is a garnish; never let it break the game.
    }
  }

  void _restart() {
    setState(() {
      _questions = [...Quiz.bank]..shuffle(math.Random());
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return STScaffold(
      title: 'TRIVIA',
      subtitle: '${_questions.length} questions · all five seasons',
      actions: [
        Center(
          child: Text(
            '$_score / ${_questions.length}',
            style: AppText.label(world.secondary).copyWith(fontSize: 14),
          ),
        ),
      ],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        // The default layout centres children in a loose Stack, which
        // shrinks the scroll view and floats it mid-screen.
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, ?current],
        ),
        child: _finished
            ? _Results(score: _score, total: _questions.length, onRestart: _restart)
            : _buildQuiz(world),
      ),
    );
  }

  Widget _buildQuiz(WorldPalette world) {
    final q = _current;
    final correct = _selected == q.correctIndex;
    return SingleChildScrollView(
      key: const ValueKey('quiz'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress: one bulb per question.
          Row(
            children: [
              for (var i = 0; i < _questions.length; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i < _index
                          ? AppColors.bulbs[i % AppColors.bulbs.length]
                          : i == _index
                              ? world.accent
                              : world.ink.withValues(alpha: 0.1),
                      boxShadow: i == _index
                          ? [BoxShadow(color: world.accent, blurRadius: 8)]
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Question card.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: NeonCard(
              key: ValueKey(_index),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUESTION ${_index + 1} OF ${_questions.length}',
                    style: AppText.chapter(world.accent, size: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(q.question, style: AppText.h2(world.ink).copyWith(fontSize: 21)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Options, with a burst of sparks on a correct answer.
          Stack(
            children: [
              Column(
                children: [
                  for (var i = 0; i < q.options.length; i++)
                    _OptionTile(
                      letter: String.fromCharCode(65 + i),
                      text: q.options[i],
                      state: _optionState(i, q),
                      onTap: () => _answer(i),
                    ),
                ],
              ),
              Positioned.fill(
                child: ParticleBurst(controller: _burst, color: AppColors.safeGreen, count: 22),
              ),
            ],
          ),

          // Evidence blurb after answering.
          if (_selected != null) ...[
            const SizedBox(height: 8),
            NeonCard(
              key: ValueKey('evidence-$_index'),
              glow: correct ? AppColors.safeGreen : AppColors.dangerGlow,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        correct ? Icons.check_circle : Icons.cancel,
                        color: correct ? AppColors.safeGreen : AppColors.dangerGlow,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        correct ? 'CORRECT' : 'MISSED IT',
                        style: AppText.label(correct ? AppColors.safeGreen : AppColors.dangerGlow),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(q.fact, style: AppText.dossier(world.ink.withValues(alpha: 0.85), size: 13.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  _OptionState _optionState(int i, QuizQuestion q) {
    if (_selected == null) return _OptionState.idle;
    if (i == q.correctIndex) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.dimmed;
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

/// An answer, keyed like an 80s game-show board.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final color = switch (state) {
      _OptionState.idle => world.accent,
      _OptionState.correct => AppColors.safeGreen,
      _OptionState.wrong => AppColors.dangerGlow,
      _OptionState.dimmed => world.ink.withValues(alpha: 0.25),
    };
    final lit = state == _OptionState.correct || state == _OptionState.wrong;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        key: ValueKey('quiz-option-$text'),
        onTap: state == _OptionState.idle ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: lit ? color.withValues(alpha: 0.12) : world.card,
            border: Border.all(
              color: state == _OptionState.idle ? world.line : color,
              width: lit ? 1.6 : 1,
            ),
            boxShadow: lit ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16)] : null,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.8)),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Text(letter, style: AppText.neon(size: 17, color: color, glow: 0.7)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: AppText.body(
                    state == _OptionState.dimmed ? world.ink.withValues(alpha: 0.4) : world.ink,
                    size: 14.5,
                  ),
                ),
              ),
              if (lit) ...[
                const SizedBox(width: 8),
                Icon(state == _OptionState.correct ? Icons.check_circle : Icons.cancel, color: color, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.score,
    required this.total,
    required this.onRestart,
  });

  final int score;
  final int total;
  final VoidCallback onRestart;

  String get _rank {
    final pct = score / total;
    if (pct >= 0.9) return 'Hawkins Historian';
    if (pct >= 0.7) return 'Party Member';
    if (pct >= 0.5) return 'Town Skeptic';
    return 'Lab Specimen';
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Center(
      key: const ValueKey('results'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: NeonCard(
          glow: AppColors.hawkinsGold,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: score / total),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: v,
                          strokeWidth: 8,
                          color: world.accent,
                          backgroundColor: world.ink.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Text('$score/$total', style: AppText.neon(size: 38, color: world.accent)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GlowBadge(text: _rank, color: AppColors.hawkinsGold, icon: Icons.emoji_events),
              const SizedBox(height: 14),
              Text(
                'You scored $score out of $total.',
                style: AppText.dossier(world.muted, size: 14),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay),
                label: const Text('RUN IT BACK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
