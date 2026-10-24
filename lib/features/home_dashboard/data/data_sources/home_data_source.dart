import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

/// Raw home data from the backend. Mapping to [HomeSnapshot] lives in the
/// repository layer.
abstract interface class HomeDataSource {
  Future<Either<Failure, Map<String, dynamic>>> fetchSettings();

  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords();

  Future<Either<Failure, Unit>> updateSessionSize(int size);
}
