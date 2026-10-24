import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../data_sources/word_data_source.dart';
import '../models/word_entry.dart';
import 'word_repository.dart';

class WordRepositoryImpl implements WordRepository {
  WordRepositoryImpl(this._source);

  final WordDataSource _source;

  static const Failure _generationFailure = Failure(
    'Kelime oluşturulamadı. Lütfen tekrar deneyin.',
  );

  @override
  Future<Either<Failure, WordEntry>> generateWord(
    String word, {
    String? translation,
  }) async {
    final result = await _source.generateWord(word);

    return result.fold<Future<Either<Failure, WordEntry>>>(
      (failure) async => Left(failure),
      (payload) => _saveTranslation(payload, translation),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteWord(String id) {
    return _source.deleteWord(id);
  }

  Future<Either<Failure, WordEntry>> _saveTranslation(
    Map<String, dynamic> payload,
    String? translation,
  ) async {
    if (payload['success'] != true) {
      return Left(_failureFrom(payload['error']));
    }

    final data = payload['data'];
    if (data is! Map) return const Left(_generationFailure);

    final entry = WordEntry.fromJson(Map<String, dynamic>.from(data));
    final override = translation?.trim();
    if (override == null || override.isEmpty || override == entry.translation) {
      return Right(entry);
    }

    // The word is already saved; keep the generated entry if the override
    // cannot be applied.
    final updated = await _source.updateTranslation(entry.id, override);

    return updated.fold(
      (_) => Right<Failure, WordEntry>(entry),
      (row) => Right<Failure, WordEntry>(WordEntry.fromJson(row)),
    );
  }

  Failure _failureFrom(Object? error) {
    if (error is String && error.contains('23505')) {
      return const Failure(
        'Bu kelime zaten eklenmiş.',
        type: FailureType.conflict,
        code: '23505',
      );
    }

    return _generationFailure;
  }
}
