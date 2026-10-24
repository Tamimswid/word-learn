import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/supabase_client.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_handler.dart';
import 'exercise_data_source.dart';

class SupabaseExerciseDataSource implements ExerciseDataSource {
  SupabaseExerciseDataSource(this._client, this._data);

  final SupabaseClient _client;
  final AppSupabaseClient _data;

  // The quiz generator is deployed under this slug.
  static const String _quizFunction = 'smooth-action';
  static const int _wordLimit = 200;

  static const Failure _sessionFailure = Failure(
    'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
    type: FailureType.authentication,
  );

  static const Failure _quizFailure = Failure(
    'Alıştırma soruları oluşturulamadı. Lütfen tekrar deneyin.',
  );

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    return _data.select(
      'words',
      columns: 'id, word, translation, example_sentence, sentence_blank',
      filters: <String, Object?>{'user_id': userId},
      orderBy: 'created_at',
      limit: _wordLimit,
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> generateQuizzes(
    List<String> words,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);
    if (words.isEmpty) return const Right(<Map<String, dynamic>>[]);

    try {
      final response = await _client.functions.invoke(
        _quizFunction,
        body: <String, Object?>{'words': words},
      );

      final payload = response.data;
      if (payload is! Map || payload['success'] != true) {
        return const Left(_quizFailure);
      }

      final quizzes = payload['quizzes'];
      if (quizzes is! List) return const Left(_quizFailure);

      return Right(
        quizzes
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      return Left(
        SupabaseErrorHandler.map(
          error,
          stackTrace: stackTrace,
          fallbackMessage: _quizFailure.message,
        ),
      );
    }
  }
}
