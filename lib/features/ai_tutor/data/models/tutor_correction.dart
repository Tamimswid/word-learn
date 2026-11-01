import 'package:flutter/foundation.dart';

/// A single language mistake the tutor pointed out in the learner's message.
@immutable
class TutorCorrection {
  const TutorCorrection({
    required this.original,
    required this.corrected,
    this.suggestion = '',
    this.explanation = '',
  });

  static TutorCorrection? tryParse(Map<String, dynamic> json) {
    final original = (json['original'] as String? ?? '').trim();
    final corrected = (json['corrected'] as String? ?? '').trim();
    if (original.isEmpty || corrected.isEmpty) return null;

    return TutorCorrection(
      original: original,
      corrected: corrected,
      suggestion: json['suggestion'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  final String original;
  final String corrected;
  final String suggestion;
  final String explanation;
}
