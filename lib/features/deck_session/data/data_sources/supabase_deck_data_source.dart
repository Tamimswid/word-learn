import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/supabase_client.dart';
import '../../../../core/errors/failure.dart';
import 'deck_data_source.dart';

class SupabaseDeckDataSource implements DeckDataSource {
  SupabaseDeckDataSource(this._client, this._data);

  final SupabaseClient _client;
  final AppSupabaseClient _data;

  static const Failure _sessionFailure = Failure(
    'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
    type: FailureType.authentication,
  );

  static const int _wordLimit = 200;

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    final result = await _data.select(
      'user_settings',
      columns: 'daily_notification_limit',
      filters: <String, Object?>{'user_id': userId},
      limit: 1,
    );

    return result.map(
      (rows) => rows.isEmpty ? const <String, dynamic>{} : rows.first,
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    return _data.select(
      'words',
      columns:
          'id, word, translation, example_sentence, sentence_blank, '
          'error_count, success_count, mastery_level, last_reviewed_at, '
          'created_at',
      filters: <String, Object?>{'user_id': userId},
      orderBy: 'created_at',
      limit: _wordLimit,
    );
  }

  @override
  Future<Either<Failure, Unit>> updateProgress(
    String id, {
    required int successCount,
    required int errorCount,
    required int masteryLevel,
    required DateTime reviewedAt,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    final result = await _data.update(
      'words',
      <String, dynamic>{
        'success_count': successCount,
        'error_count': errorCount,
        'mastery_level': masteryLevel,
        'last_reviewed_at': reviewedAt.toUtc().toIso8601String(),
      },
      filters: <String, Object?>{'id': id, 'user_id': userId},
    );

    return result.map((_) => unit);
  }
}
