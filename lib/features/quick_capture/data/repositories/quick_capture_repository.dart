import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../word_management/data/models/word_entry.dart';

abstract interface class QuickCaptureRepository {
  Future<Either<Failure, String>> readSelection();

  /// Saves the captured text as a word and lets the backend generate its data.
  Future<Either<Failure, WordEntry>> save(String word);
}
