import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../data_sources/home_data_source.dart';
import '../models/home_snapshot.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._source);

  final HomeDataSource _source;

  static const int _chartDayWindow = 28;

  @override
  Future<Either<Failure, HomeSnapshot>> fetchSnapshot() async {
    final (settingsResult, wordsResult) = await (
      _source.fetchSettings(),
      _source.fetchWords(),
    ).wait;

    final failure =
        settingsResult.fold<Failure?>((failure) => failure, (_) => null) ??
        wordsResult.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);

    final settings = settingsResult.getOrElse(
      () => const <String, dynamic>{},
    );
    final wordRows = wordsResult.getOrElse(
      () => const <Map<String, dynamic>>[],
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final learnedByDate = <String, int>{};

    for (final row in wordRows) {
      final createdAt = DateTime.tryParse(
        row['created_at'] as String? ?? '',
      )?.toLocal();
      if (createdAt == null) continue;

      final key = _dayKey(
        DateTime(createdAt.year, createdAt.month, createdAt.day),
      );
      learnedByDate[key] = (learnedByDate[key] ?? 0) + 1;
    }

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weeklyPoints = <ActivityPoint>[
      for (var index = 0; index < HomeSnapshot.weekdayLabels.length; index++)
        ActivityPoint(
          label: HomeSnapshot.weekdayLabels[index],
          value: (learnedByDate[_dayKey(
                    weekStart.add(Duration(days: index)),
                  )] ??
                  0)
              .toDouble(),
          isCurrent: weekStart.add(Duration(days: index)) == today,
        ),
    ];

    final windowStart = today.subtract(
      const Duration(days: _chartDayWindow - 1),
    );
    final monthlyPoints = <ActivityPoint>[
      for (var week = 0; week < HomeSnapshot.weekLabels.length; week++)
        ActivityPoint(
          label: HomeSnapshot.weekLabels[week],
          value: <int>[
            for (var day = 0; day < 7; day++)
              learnedByDate[_dayKey(
                    windowStart.add(Duration(days: week * 7 + day)),
                  )] ??
                  0,
          ].fold(0, (sum, value) => sum + value).toDouble(),
          isCurrent: week == HomeSnapshot.weekLabels.length - 1,
        ),
    ];

    final thisMonthStart = DateTime(now.year, now.month);
    final lastMonthStart = DateTime(now.year, now.month - 1);
    var thisMonthCount = 0;
    var lastMonthCount = 0;
    for (final row in wordRows) {
      final createdAt = DateTime.tryParse(
        row['created_at'] as String? ?? '',
      )?.toLocal();
      if (createdAt == null) continue;
      if (!createdAt.isBefore(thisMonthStart)) {
        thisMonthCount++;
      } else if (!createdAt.isBefore(lastMonthStart) &&
          createdAt.isBefore(thisMonthStart)) {
        lastMonthCount++;
      }
    }

    final changePercent = lastMonthCount == 0
        ? (thisMonthCount == 0 ? 0 : 100)
        : ((thisMonthCount - lastMonthCount) / lastMonthCount * 100).round();

    final recentWords = wordRows
        .take(HomeSnapshot.recentWordLimit)
        .map(
          (row) => LearnedWord(
            id: row['id'] as String? ?? '',
            word: row['word'] as String? ?? '',
            translation: row['translation'] as String? ?? '',
            createdAt: DateTime.tryParse(
              row['created_at'] as String? ?? '',
            )?.toLocal(),
          ),
        )
        .toList(growable: false);

    return Right(
      HomeSnapshot(
        streakDays: _asInt(settings['current_streak']),
        learnedCount: wordRows.length,
        changePercent: changePercent,
        weeklyPoints: weeklyPoints,
        monthlyPoints: monthlyPoints,
        recentWords: recentWords,
        sessionSize: _asInt(
          settings['daily_notification_limit'],
          fallback: HomeSnapshot.defaultSessionSize,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> updateSessionSize(int size) {
    return _source.updateSessionSize(size);
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    return value is num ? value.toInt() : fallback;
  }

  static String _dayKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
