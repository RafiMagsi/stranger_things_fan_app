import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/glass_card.dart';
import '../data/quiz.dart';
import '../models/quiz_question.dart';

/// Trivia game: shuffled questions, animated correct/wrong feedback, running
/// score, and a results card at the end.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;

  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _questions = [...Quiz.bank]..shuffle(math.Random(2016));
  }

  @override
  void dispose() {
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
      await _player.stop();
      await _player.play(AssetSource('audio/chime.wav'));
    } else {
      await _player.stop();
      await _player.play(AssetSource('audio/static.wav'));
    }

    Timer(const Duration(milliseconds: 1500), () {
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TRIVIA',
          style: AppText.h2(scheme.onSurface).copyWith(letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score / ${_questions.length}',
                style: AppText.label(AppColors.hawkinsGold).copyWith(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
      body: _finished ? _Results(score: _score, total: _questions.length, onRestart: _restart) : _buildQuiz(scheme),
    );
  }

  Widget _buildQuiz(ColorScheme scheme) {
    final q = _current;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress dots.
          Row(
            children: [
              for (var i = 0; i < _questions.length; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i < _index
                          ? AppColors.safeGreen
                          : i == _index
                              ? Theme.of(context).colorScheme.primary
                              : scheme.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Question card.
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUESTION ${_index + 1} OF ${_questions.length}',
                  style: AppText.label(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(q.question, style: AppText.h2(scheme.onSurface).copyWith(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Options.
          for (var i = 0; i < q.options.length; i++)
            _OptionTile(
              text: q.options[i],
              state: _optionState(i, q),
              onTap: () => _answer(i),
            ),

          // Evidence blurb after answering.
          if (_selected != null) ...[
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: GlassCard(
                key: ValueKey(_index),
                glow: _selected == q.correctIndex
                    ? AppColors.safeGreen
                    : AppColors.dangerGlow,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selected == q.correctIndex
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _selected == q.correctIndex
                              ? AppColors.safeGreen
                              : AppColors.dangerGlow,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selected == q.correctIndex ? 'CORRECT' : 'MISSED IT',
                          style: AppText.label(
                            _selected == q.correctIndex
                                ? AppColors.safeGreen
                                : AppColors.dangerGlow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(q.fact, style: AppText.dossier(scheme.onSurface.withValues(alpha: 0.8), size: 13.5)),
                  ],
                ),
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border;
    Color? bg;
    IconData? icon;

    switch (state) {
      case _OptionState.idle:
        border = scheme.outline;
        bg = null;
        icon = null;
      case _OptionState.correct:
        border = AppColors.safeGreen;
        bg = AppColors.safeGreen.withValues(alpha: 0.14);
        icon = Icons.check_circle;
      case _OptionState.wrong:
        border = AppColors.dangerGlow;
        bg = AppColors.dangerGlow.withValues(alpha: 0.14);
        icon = Icons.cancel;
      case _OptionState.dimmed:
        border = scheme.outline.withValues(alpha: 0.4);
        bg = null;
        icon = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        key: ValueKey('quiz-option-$text'),
        onTap: state == _OptionState.idle ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: bg ?? scheme.surface,
            border: Border.all(color: border, width: state == _OptionState.idle ? 1 : 1.6),
            boxShadow: state == _OptionState.correct
                ? [BoxShadow(color: AppColors.safeGreen.withValues(alpha: 0.3), blurRadius: 16)]
                : state == _OptionState.wrong
                    ? [BoxShadow(color: AppColors.dangerGlow.withValues(alpha: 0.25), blurRadius: 14)]
                    : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppText.body(
                    state == _OptionState.dimmed
                        ? scheme.onSurface.withValues(alpha: 0.4)
                        : scheme.onSurface,
                    size: 14.5,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: border, size: 20),
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
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: score / total),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 8,
                      backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  Text(
                    '$score/$total',
                    style: AppText.h1(scheme.onSurface).copyWith(fontSize: 34),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlowBadge(
              text: _rank,
              color: AppColors.hawkinsGold,
              icon: Icons.emoji_events,
            ),
            const SizedBox(height: 16),
            Text(
              'You scored $score out of $total.',
              style: AppText.body(scheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.replay),
              label: const Text('RUN IT BACK'),
            ),
          ],
        ),
      ),
    );
  }
}
