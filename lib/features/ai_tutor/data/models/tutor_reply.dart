import 'package:flutter/foundation.dart';

import 'tutor_correction.dart';

/// The tutor's answer to one learner message.
@immutable
class TutorReply {
  const TutorReply({
    required this.text,
    this.corrections = const <TutorCorrection>[],
  });

  static TutorReply? tryParse(Map<String, dynamic> json) {
    final text = (json['reply'] as String? ?? '').trim();
    if (text.isEmpty) return null;

    final raw = json['corrections'];
    final corrections = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (row) =>
                    TutorCorrection.tryParse(Map<String, dynamic>.from(row)),
              )
              .whereType<TutorCorrection>()
              .toList(growable: false)
        : const <TutorCorrection>[];

    return TutorReply(text: text, corrections: corrections);
  }

  final String text;
  final List<TutorCorrection> corrections;
}
