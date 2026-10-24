import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/word_entry.dart';

abstract interface class WordRepository {
  Future<Either<Failure, WordEntry>> generateWord(
    String word, {
    String? translation,
  });

  Future<Either<Failure, Unit>> deleteWord(String id);
}
