import 'package:dartz/dartz.dart';
import 'package:translator/translator.dart';

import '../errors/failure.dart';

/// Tunable language pair for inline translations.
class TranslationConfig {
  const TranslationConfig({this.from = 'en', this.to = 'ar'});

  static const TranslationConfig standard = TranslationConfig();

  final String from;
  final String to;
}

/// Free Google-backed word and sentence translation, with a small cache so
/// repeated taps on the same word cost nothing.
class TranslationService {
  TranslationService({TranslationConfig? config})
    : _config = config ?? TranslationConfig.standard;

  final TranslationConfig _config;
  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, String> _cache = <String, String>{};

  Future<Either<Failure, String>> translate(String text) async {
    final value = text.trim();
    if (value.isEmpty) {
      return const Left(Failure('لا يوجد نص للترجمة.'));
    }

    final cached = _cache[value];
    if (cached != null) return Right(cached);

    try {
      final result = await _translator.translate(
        value,
        from: _config.from,
        to: _config.to,
      );
      _cache[value] = result.text;
      return Right(result.text);
    } catch (error, stackTrace) {
      return Left(
        Failure(
          'تعذر الترجمة. تحقق من اتصالك بالإنترنت.',
          type: FailureType.network,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
