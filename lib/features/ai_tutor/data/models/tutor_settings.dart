import 'package:flutter/foundation.dart';

/// Tutor behaviour settings, mirrored from `tutor_settings`.
@immutable
class TutorSettings {
  const TutorSettings({
    this.englishLevel = 'B1',
    this.correctionLevel = 'medium',
  });

  factory TutorSettings.fromJson(Map<String, dynamic> json) {
    return TutorSettings(
      englishLevel: json['english_level'] as String? ?? 'B1',
      correctionLevel: json['correction_level'] as String? ?? 'medium',
    );
  }

  final String englishLevel;
  final String correctionLevel;

  Map<String, String> toWire() {
    return <String, String>{
      'english_level': englishLevel,
      'correction_level': correctionLevel,
    };
  }
}
