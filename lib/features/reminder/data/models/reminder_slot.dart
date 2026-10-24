import 'package:flutter/foundation.dart';

/// A single word bound to the moment its notification fires.
@immutable
class ReminderSlot {
  const ReminderSlot({
    required this.wordId,
    required this.word,
    required this.translation,
    required this.at,
  });

  final String wordId;
  final String word;
  final String translation;
  final DateTime at;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReminderSlot &&
            other.wordId == wordId &&
            other.word == word &&
            other.translation == translation &&
            other.at == at;
  }

  @override
  int get hashCode => Object.hash(wordId, word, translation, at);
}
