import 'package:flutter/foundation.dart';

@immutable
class ActivityPoint {
  const ActivityPoint({
    required this.label,
    required this.value,
    this.isCurrent = false,
  });

  final String label;
  final double value;
  final bool isCurrent;
}

@immutable
class LearnedWord {
  const LearnedWord({
    required this.id,
    required this.word,
    required this.translation,
    this.exampleSentence = '',
    this.sentenceTranslation = '',
    this.arabicSentence = '',
    this.wordIndex = -1,
    this.createdAt,
  });

  final String id;
  final String word;
  final String translation;
  final String exampleSentence;
  final String sentenceTranslation;
  final String arabicSentence;
  final int wordIndex;
  final DateTime? createdAt;
}

@immutable
class HomeSnapshot {
  const HomeSnapshot({
    required this.streakDays,
    required this.learnedCount,
    required this.changePercent,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.recentWords,
    required this.sessionSize,
    required this.dailyLoginCount,
  });

  final int streakDays;
  final int learnedCount;
  final int changePercent;
  final List<ActivityPoint> weeklyPoints;
  final List<ActivityPoint> monthlyPoints;
  final List<LearnedWord> recentWords;
  final int sessionSize;

  /// Server-side counter of app opens recorded today.
  final int dailyLoginCount;

  static const int recentWordLimit = 5;
  static const int defaultSessionSize = 10;

  static const List<String> weekdayLabels = <String>[
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  static const List<String> weekLabels = <String>[
    '1. Hf',
    '2. Hf',
    '3. Hf',
    '4. Hf',
  ];

  factory HomeSnapshot.zero() {
    final today = DateTime.now();
    return HomeSnapshot(
      streakDays: 0,
      learnedCount: 0,
      changePercent: 0,
      weeklyPoints: <ActivityPoint>[
        for (var index = 0; index < weekdayLabels.length; index++)
          ActivityPoint(
            label: weekdayLabels[index],
            value: 0,
            isCurrent: index == today.weekday - 1,
          ),
      ],
      monthlyPoints: <ActivityPoint>[
        for (var index = 0; index < weekLabels.length; index++)
          ActivityPoint(
            label: weekLabels[index],
            value: 0,
            isCurrent: index == weekLabels.length - 1,
          ),
      ],
      recentWords: const <LearnedWord>[],
      sessionSize: defaultSessionSize,
      dailyLoginCount: 0,
    );
  }

  HomeSnapshot copyWith({
    int? streakDays,
    int? learnedCount,
    int? changePercent,
    List<ActivityPoint>? weeklyPoints,
    List<ActivityPoint>? monthlyPoints,
    List<LearnedWord>? recentWords,
    int? sessionSize,
    int? dailyLoginCount,
  }) {
    return HomeSnapshot(
      streakDays: streakDays ?? this.streakDays,
      learnedCount: learnedCount ?? this.learnedCount,
      changePercent: changePercent ?? this.changePercent,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      monthlyPoints: monthlyPoints ?? this.monthlyPoints,
      recentWords: recentWords ?? this.recentWords,
      sessionSize: sessionSize ?? this.sessionSize,
      dailyLoginCount: dailyLoginCount ?? this.dailyLoginCount,
    );
  }
}
