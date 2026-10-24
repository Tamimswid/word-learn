import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import 'deck_data_source.dart';

class InMemoryDeckDataSource implements DeckDataSource {
  static const int _sessionSize = 10;

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchSettings() async {
    return const Right(<String, dynamic>{
      'daily_notification_limit': _sessionSize,
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords() async {
    return const Right(<Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, Unit>> updateProgress(
    String id, {
    required int successCount,
    required int errorCount,
    required int masteryLevel,
    required DateTime reviewedAt,
  }) async {
    return const Right(unit);
  }
}
