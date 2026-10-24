import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import 'word_data_source.dart';

class InMemoryWordDataSource implements WordDataSource {
  final Map<String, Map<String, dynamic>> _rows =
      <String, Map<String, dynamic>>{};

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateWord(
    String word,
  ) async {
    final id = 'local-${DateTime.now().microsecondsSinceEpoch}';
    final row = <String, dynamic>{
      'id': id,
      'user_id': 'local',
      'word': word,
      'translation': '',
      'example_sentence': '',
      'sentence_blank': '',
      'options_json': const <String>[],
      'created_at': DateTime.now().toIso8601String(),
    };
    _rows[id] = row;

    return Right(<String, dynamic>{'success': true, 'data': row});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateTranslation(
    String id,
    String translation,
  ) async {
    final row = _rows[id];
    if (row == null) {
      return const Left(Failure('Kelime bulunamadı.'));
    }

    final updated = <String, dynamic>{...row, 'translation': translation};
    _rows[id] = updated;

    return Right(updated);
  }

  @override
  Future<Either<Failure, Unit>> deleteWord(String id) async {
    _rows.remove(id);
    return const Right(unit);
  }
}
