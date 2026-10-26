import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/supabase_client.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_handler.dart';
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
      columns:
          'current_streak, daily_notification_limit, daily_login_count',
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

    // `*` so optional word fields (sentence translation) arrive as soon as
    // the backend exposes them, without a broken select in the meantime.
    return _data.select(
      'words',
      columns: '*',
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

  @override
  Future<Either<Failure, int>> recordDailyLogin() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Left(_sessionFailure);

    final now = DateTime.now();
    final loginDate = [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
    ].join('-');

    try {
      final result = await _client.rpc(
        'record_daily_login',
        params: <String, dynamic>{'p_login_date': loginDate},
      );

      if (result is num) return Right(result.toInt());

      return const Left(Failure('Günlük giriş sayısı alınamadı.'));
    } catch (error, stackTrace) {
      return Left(
        SupabaseErrorHandler.map(
          error,
          stackTrace: stackTrace,
          fallbackMessage: 'Günlük giriş sayısı güncellenemedi.',
        ),
      );
    }
  }
}
