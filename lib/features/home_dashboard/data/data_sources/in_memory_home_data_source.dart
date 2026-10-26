import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/home_snapshot.dart';
import 'home_data_source.dart';

class InMemoryHomeDataSource implements HomeDataSource {
  int _sessionSize = HomeSnapshot.defaultSessionSize;
  int _dailyLoginCount = 0;

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchSettings() async {
    return Right(<String, dynamic>{
      'daily_notification_limit': _sessionSize,
      'daily_login_count': _dailyLoginCount,
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords() async {
    return const Right(<Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, Unit>> updateSessionSize(int size) async {
    _sessionSize = size;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, int>> recordDailyLogin() async {
    _dailyLoginCount += 1;
    return Right(_dailyLoginCount);
  }
}
