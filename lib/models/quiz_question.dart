import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.fact,
  });

  final String question;
  final List<String> options;
  final int correctIndex;

  /// Shown after answering, as an "evidence" blurb from the dossier.
  final String fact;
}
