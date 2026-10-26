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

  // `*` keeps optional columns (sentence translation) flowing to the UI as
  // soon as the backend exposes them.
  static const String _listColumns = '*';

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
      // ignore: avoid_print
      print('[Supabase][generateWord] $error');
      if (error is FunctionException) {
        // ignore: avoid_print
        print(
          '[Supabase][generateWord] status=${error.status} '
          'details=${error.details}',
        );
      }
      // ignore: avoid_print
      print(stackTrace);

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
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWordsPage({
    required int offset,
    required int limit,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    return _data.select(
      'words',
      columns: _listColumns,
      filters: <String, Object?>{'user_id': userId},
      orderBy: 'created_at',
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteWord(String id) {
    return _data.delete('words', filters: <String, Object?>{'id': id});
  }
}
