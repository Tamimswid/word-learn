import 'package:flutter/foundation.dart';

/// One AI-generated quiz item from the `smooth-action` function.
@immutable
class ExerciseQuiz {
  const ExerciseQuiz({
    required this.word,
    required this.sentenceBlank,
    required this.options,
    required this.correctAnswer,
  });

  /// Returns `null` when the AI payload is incomplete or inconsistent.
  static ExerciseQuiz? tryParse(Object? value) {
    if (value is! Map) return null;

    final word = (value['word'] as String?)?.trim() ?? '';
    final sentenceBlank = (value['sentence_blank'] as String?)?.trim() ?? '';
    final correctAnswer = (value['correct_answer'] as String?)?.trim() ?? '';
    final rawOptions = value['options'];

    if (word.isEmpty ||
        sentenceBlank.isEmpty ||
        correctAnswer.isEmpty ||
        rawOptions is! List ||
        !_blankPattern.hasMatch(sentenceBlank)) {
      return null;
    }

    final options = <String>[];
    for (final raw in rawOptions) {
      if (raw is! String) continue;
      final option = raw.trim();
      if (option.isEmpty || options.contains(option)) continue;
      options.add(option);
    }

    String? matched;
    for (final option in options) {
      if (option.toLowerCase() == correctAnswer.toLowerCase()) {
        matched = option;
        break;
      }
    }
    if (matched == null || options.length < 2) return null;

    return ExerciseQuiz(
      word: word,
      sentenceBlank: sentenceBlank,
      options: options,
      correctAnswer: matched,
    );
  }

  final String word;
  final String sentenceBlank;
  final List<String> options;
  final String correctAnswer;

  static final RegExp _blankPattern = RegExp(r'_{3,}');
}
