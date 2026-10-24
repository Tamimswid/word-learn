import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

/// Raw deck data from the backend. Due-word filtering and SRS math live in
/// the repository.
abstract interface class DeckDataSource {
  Future<Either<Failure, Map<String, dynamic>>> fetchSettings();

  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords();

  Future<Either<Failure, Unit>> updateProgress(
    String id, {
    required int successCount,
    required int errorCount,
    required int masteryLevel,
    required DateTime reviewedAt,
  });
}
