import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/home_snapshot.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, HomeSnapshot>> fetchSnapshot();

  Future<Either<Failure, Unit>> updateSessionSize(int size);
}
