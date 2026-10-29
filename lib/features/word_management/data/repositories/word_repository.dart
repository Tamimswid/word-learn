import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/word_entry.dart';
import '../models/word_page.dart';
import '../models/word_summary.dart';

abstract interface class WordRepository {
  Future<Either<Failure, WordEntry>> generateWord(
    String word, {
    String? translation,
  });

  Future<Either<Failure, WordPage>> fetchWords({
    required int offset,
    required int limit,
  });

  Future<Either<Failure, WordSummary>> updateWord(
    WordSummary current, {
    required String word,
    required String translation,
    required String exampleSentence,
    required String arabicSentence,
  });

  Future<Either<Failure, Unit>> deleteWord(String id);
}
