import 'package:flutter/foundation.dart';

/// A saved word used to build the exercise session.
@immutable
class ExerciseWord {
  const ExerciseWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.exampleSentence,
    required this.sentenceBlank,
  });

  factory ExerciseWord.fromJson(Map<String, dynamic> json) {
    return ExerciseWord(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      exampleSentence: json['example_sentence'] as String? ?? '',
      sentenceBlank: json['sentence_blank'] as String? ?? '',
    );
  }

  final String id;
  final String word;
  final String translation;
  final String exampleSentence;
  final String sentenceBlank;

  bool get isValid =>
      id.isNotEmpty && word.trim().isNotEmpty && translation.trim().isNotEmpty;
}
