import 'package:flutter/foundation.dart';

@immutable
class WordEntry {
  const WordEntry({
    required this.id,
    required this.userId,
    required this.word,
    required this.translation,
    required this.exampleSentence,
    required this.sentenceBlank,
    required this.options,
    required this.createdAt,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    final options = json['options_json'];

    return WordEntry(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      exampleSentence: json['example_sentence'] as String? ?? '',
      sentenceBlank: json['sentence_blank'] as String? ?? '',
      options: options is List
          ? options.whereType<String>().toList(growable: false)
          : const <String>[],
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  final String id;
  final String userId;
  final String word;
  final String translation;
  final String exampleSentence;
  final String sentenceBlank;
  final List<String> options;
  final DateTime? createdAt;
}
