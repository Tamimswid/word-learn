import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../errors/failure.dart';
import '../errors/supabase_error_handler.dart';

/// Common gateway for every Supabase table operation.
///
/// All reads and writes go through here so transport/Postgrest errors are
/// mapped to [Failure] in one place and callers receive an `Either` result.
class AppSupabaseClient {
  AppSupabaseClient(this._client);

  final supabase.SupabaseClient _client;

  static const Failure _missingFilters = Failure(
    'İşlem için en az bir filtre gerekli.',
    type: FailureType.unexpected,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> select(
    String table, {
    String columns = '*',
    Map<String, Object?> filters = const {},
    String? orderBy,
    bool ascending = false,
    int? limit,
  }) {
    return _guard(() async {
      final filtered = _withFilters(
        _client.from(table).select(columns),
        filters,
      );

      supabase.PostgrestTransformBuilder<supabase.PostgrestList> query =
          filtered;
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final rows = await query;
      return List<Map<String, dynamic>>.from(rows);
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> values,
  ) {
    return _guard(() async {
      final row = await _client.from(table).insert(values).select().single();
      return Map<String, dynamic>.from(row);
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> upsert(
    String table,
    Map<String, dynamic> values, {
    String? onConflict,
  }) {
    return _guard(() async {
      final row = await _client
          .from(table)
          .upsert(values, onConflict: onConflict)
          .select()
          .single();
      return Map<String, dynamic>.from(row);
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> values, {
    required Map<String, Object?> filters,
  }) {
    if (filters.isEmpty) return Future.value(const Left(_missingFilters));

    return _guard(() async {
      final query = _withFilters(_client.from(table).update(values), filters);
      final row = await query.select().single();
      return Map<String, dynamic>.from(row);
    });
  }

  Future<Either<Failure, Unit>> delete(
    String table, {
    required Map<String, Object?> filters,
  }) {
    if (filters.isEmpty) return Future.value(const Left(_missingFilters));

    return _guard(() async {
      await _withFilters(_client.from(table).delete(), filters);
      return unit;
    });
  }

  supabase.PostgrestFilterBuilder<T> _withFilters<T>(
    supabase.PostgrestFilterBuilder<T> query,
    Map<String, Object?> filters,
  ) {
    var result = query;
    for (final entry in filters.entries) {
      final value = entry.value;
      result = value == null
          ? result.isFilter(entry.key, null)
          : result.eq(entry.key, value);
    }
    return result;
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error, stackTrace) {
      return Left(SupabaseErrorHandler.map(error, stackTrace: stackTrace));
    }
  }
}
