import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

/// Raw exercise data from the backend. Question building lives in the
/// repository.
abstract interface class ExerciseDataSource {
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords();

  Future<Either<Failure, List<Map<String, dynamic>>>> generateQuizzes(
    List<String> words,
  );
}
