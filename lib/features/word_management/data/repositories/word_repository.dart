import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/word_entry.dart';
import '../models/word_page.dart';

abstract interface class WordRepository {
  Future<Either<Failure, WordEntry>> generateWord(
    String word, {
    String? translation,
  });

  Future<Either<Failure, WordPage>> fetchWords({
    required int offset,
    required int limit,
  });

  Future<Either<Failure, Unit>> deleteWord(String id);
}
