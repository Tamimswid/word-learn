import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/home_snapshot.dart';
import 'home_data_source.dart';

class InMemoryHomeDataSource implements HomeDataSource {
  int _sessionSize = HomeSnapshot.defaultSessionSize;

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchSettings() async {
    return Right(<String, dynamic>{
      'daily_notification_limit': _sessionSize,
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
}
