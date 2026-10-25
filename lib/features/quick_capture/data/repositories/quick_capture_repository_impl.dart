import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../../core/errors/failure.dart';
import '../../../word_management/data/models/word_entry.dart';
import '../../../word_management/data/repositories/word_repository.dart';
import '../data_sources/selection_data_source.dart';
import 'quick_capture_repository.dart';

class QuickCaptureRepositoryImpl implements QuickCaptureRepository {
  QuickCaptureRepositoryImpl(this._selection, this._words);

  final SelectionDataSource _selection;
  final WordRepository _words;

  @override
  Future<Either<Failure, String>> readSelection() async {
    try {
      final text = await _selection.readSelectedText();
      if (text == null || text.isEmpty) {
        return const Left(
          Failure('Seçili metin bulunamadı.', type: FailureType.notFound),
        );
      }

      return Right(text);
    } on MissingPluginException catch (error, stackTrace) {
      return Left(
        Failure(
          'Metin yakalama bu platformda desteklenmiyor.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on PlatformException catch (error, stackTrace) {
      if (error.code == 'accessibility') {
        return Left(
          Failure(
            'Erişilebilirlik izni gerekli: Sistem Ayarları → Gizlilik ve '
            'Güvenlik → Erişilebilirlik.',
            type: FailureType.permission,
            cause: error,
            stackTrace: stackTrace,
          ),
        );
      }

      return Left(
        Failure(
          'Seçili metin okunamadı.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, WordEntry>> save(String word) {
    return _words.generateWord(word);
  }
}
