import 'package:flutter/foundation.dart';

/// A word row prepared for the all-words list.
@immutable
class WordSummary {
  const WordSummary({
    required this.id,
    required this.word,
    required this.translation,
    required this.exampleSentence,
    required this.errorCount,
    required this.successCount,
    required this.rank,
    this.sentenceTranslation = '',
    this.arabicSentence = '',
    this.wordIndex = -1,
  });

  factory WordSummary.fromJson(Map<String, dynamic> json, {required int rank}) {
    return WordSummary(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      exampleSentence: json['example_sentence'] as String? ?? '',
      errorCount: _asInt(json['error_count']),
      successCount: _asInt(json['success_count']),
      rank: rank,
      sentenceTranslation: json['sentence_translation'] as String? ?? '',
      arabicSentence: json['arabic_sentence'] as String? ?? '',
      wordIndex: _asInt(json['word_index'], fallback: -1),
    );
  }

  final String id;
  final String word;
  final String translation;
  final String exampleSentence;
  final int errorCount;
  final int successCount;
  final int rank;

  /// Turkish rendering of [exampleSentence]; empty until the backend has it.
  final String sentenceTranslation;

  /// Arabic translation of [exampleSentence].
  final String arabicSentence;

  /// 0-based whitespace token index of the word inside [arabicSentence].
  final int wordIndex;

  WordSummary copyWith({int? rank}) {
    return WordSummary(
      id: id,
      word: word,
      translation: translation,
      exampleSentence: exampleSentence,
      errorCount: errorCount,
      successCount: successCount,
      rank: rank ?? this.rank,
      sentenceTranslation: sentenceTranslation,
      arabicSentence: arabicSentence,
      wordIndex: wordIndex,
    );
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    return value is num ? value.toInt() : fallback;
  }
}
