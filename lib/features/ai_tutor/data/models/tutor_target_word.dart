import 'package:flutter/foundation.dart';

/// A word the tutor should try to bring up naturally in conversation.
@immutable
class TutorTargetWord {
  const TutorTargetWord({required this.word, required this.translation});

  factory TutorTargetWord.fromJson(Map<String, dynamic> json) {
    return TutorTargetWord(
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
    );
  }

  final String word;
  final String translation;

  Map<String, String> toWire() {
    return <String, String>{'word': word, 'translation': translation};
  }
}
