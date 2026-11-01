import 'package:flutter/foundation.dart';

import 'tutor_settings.dart';
import 'tutor_target_word.dart';

/// Everything the tutor loaded for this conversation.
///
/// Sent back with each `respond`/`end` call so the function does not re-read
/// the same rows from the database on every turn.
@immutable
class TutorSession {
  const TutorSession({
    this.settings = const TutorSettings(),
    this.targetWords = const <TutorTargetWord>[],
    this.summaries = const <String>[],
  });

  factory TutorSession.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'];
    final words = json['targetWords'];
    final summaries = json['summaries'];

    return TutorSession(
      settings: settings is Map
          ? TutorSettings.fromJson(Map<String, dynamic>.from(settings))
          : const TutorSettings(),
      targetWords: words is List
          ? words
                .whereType<Map>()
                .map(
                  (row) =>
                      TutorTargetWord.fromJson(Map<String, dynamic>.from(row)),
                )
                .toList(growable: false)
          : const <TutorTargetWord>[],
      summaries: summaries is List
          ? summaries
                .whereType<String>()
                .where((text) => text.trim().isNotEmpty)
                .toList(growable: false)
          : const <String>[],
    );
  }

  final TutorSettings settings;
  final List<TutorTargetWord> targetWords;
  final List<String> summaries;

  Map<String, Object?> toWire() {
    return <String, Object?>{
      'settings': settings.toWire(),
      'targetWords': targetWords
          .map((word) => word.toWire())
          .toList(growable: false),
      'summaries': summaries,
    };
  }
}
