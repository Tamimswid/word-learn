import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/supabase_client.dart';
import '../../../../core/errors/failure.dart';
import 'home_data_source.dart';

class SupabaseHomeDataSource implements HomeDataSource {
  SupabaseHomeDataSource(this._client, this._data);

  final SupabaseClient _client;
  final AppSupabaseClient _data;

  static const Failure _sessionFailure = Failure(
    'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
    type: FailureType.authentication,
  );

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    final result = await _data.select(
      'user_settings',
      columns: 'current_streak, daily_notification_limit',
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
      columns: 'id, word, translation, created_at',
      filters: <String, Object?>{'user_id': userId},
      orderBy: 'created_at',
    );
  }

  @override
  Future<Either<Failure, Unit>> updateSessionSize(int size) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    final result = await _data.upsert(
      'user_settings',
      <String, dynamic>{
        'user_id': userId,
        'daily_notification_limit': size,
      },
      onConflict: 'user_id',
    );

    return result.map((_) => unit);
  }
}
