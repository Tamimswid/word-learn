import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/supabase_client.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_handler.dart';
import 'word_data_source.dart';

class SupabaseWordDataSource implements WordDataSource {
  SupabaseWordDataSource(this._client, this._data);

  final SupabaseClient _client;
  final AppSupabaseClient _data;

  // The function is currently deployed under this slug; its entrypoint is
  // `generate-word-base`. Keep this in sync if it is redeployed by name.
  static const String _generateWordFunction = 'dynamic-endpoint';

  static const Failure _sessionFailure = Failure(
    'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
    type: FailureType.authentication,
  );

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateWord(
    String word,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    try {
      final response = await _client.functions.invoke(
        _generateWordFunction,
        body: <String, Object?>{'word': word, 'user_id': userId},
      );

      final payload = response.data;
      if (payload is! Map) {
        return const Left(
          Failure('Kelime oluşturulamadı. Lütfen tekrar deneyin.'),
        );
      }

      return Right(Map<String, dynamic>.from(payload));
    } catch (error, stackTrace) {
      return Left(
        SupabaseErrorHandler.map(
          error,
          stackTrace: stackTrace,
          fallbackMessage: 'Kelime oluşturulamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateTranslation(
    String id,
    String translation,
  ) {
    return _data.update(
      'words',
      <String, dynamic>{'translation': translation},
      filters: <String, Object?>{'id': id},
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteWord(String id) {
    return _data.delete('words', filters: <String, Object?>{'id': id});
  }
}
