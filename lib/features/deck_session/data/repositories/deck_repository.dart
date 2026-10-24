import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/deck_word.dart';

abstract interface class DeckRepository {
  Future<Either<Failure, List<DeckWord>>> fetchSession();

  Future<Either<Failure, Unit>> recordAnswer(
    DeckWord word, {
    required bool known,
  });
}
