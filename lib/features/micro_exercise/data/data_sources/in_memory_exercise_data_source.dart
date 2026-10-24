import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import 'exercise_data_source.dart';

class InMemoryExerciseDataSource implements ExerciseDataSource {
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords() async {
    return const Right(<Map<String, dynamic>>[]);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> generateQuizzes(
    List<String> words,
  ) async {
    return const Right(<Map<String, dynamic>>[]);
  }
}
