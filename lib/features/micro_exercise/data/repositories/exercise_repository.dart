import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/exercise_item.dart';

abstract interface class ExerciseRepository {
  /// Builds the exercise session for the words the user did not know.
  Future<Either<Failure, List<ExerciseItem>>> buildSession({
    required List<String> seedIds,
  });
}
