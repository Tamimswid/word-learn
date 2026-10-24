import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';

/// Backend access for words. Business rules (payload validation, translation
/// override) stay in the repository.
abstract interface class WordDataSource {
  Future<Either<Failure, Map<String, dynamic>>> generateWord(String word);

  Future<Either<Failure, Map<String, dynamic>>> updateTranslation(
    String id,
    String translation,
  );

  Future<Either<Failure, Unit>> deleteWord(String id);
}
