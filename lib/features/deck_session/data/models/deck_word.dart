import 'package:flutter/foundation.dart';

/// A word waiting in the review deck, including its SRS counters.
@immutable
class DeckWord {
  const DeckWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.exampleSentence,
    required this.sentenceBlank,
    required this.errorCount,
    required this.successCount,
    required this.masteryLevel,
    this.lastReviewedAt,
    this.createdAt,
  });

  factory DeckWord.fromJson(Map<String, dynamic> json) {
    return DeckWord(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      exampleSentence: json['example_sentence'] as String? ?? '',
      sentenceBlank: json['sentence_blank'] as String? ?? '',
      errorCount: _asInt(json['error_count']),
      successCount: _asInt(json['success_count']),
      masteryLevel: _asInt(json['mastery_level']),
      lastReviewedAt: DateTime.tryParse(
        json['last_reviewed_at'] as String? ?? '',
      )?.toLocal(),
      createdAt: DateTime.tryParse(
        json['created_at'] as String? ?? '',
      )?.toLocal(),
    );
  }

  final String id;
  final String word;
  final String translation;
  final String exampleSentence;
  final String sentenceBlank;
  final int errorCount;
  final int successCount;
  final int masteryLevel;
  final DateTime? lastReviewedAt;
  final DateTime? createdAt;

  static int _asInt(Object? value) => value is num ? value.toInt() : 0;
}
