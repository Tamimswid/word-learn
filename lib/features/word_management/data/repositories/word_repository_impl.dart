import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../data_sources/word_data_source.dart';
import '../models/word_entry.dart';
import '../models/word_page.dart';
import '../models/word_summary.dart';
import 'word_repository.dart';

class WordRepositoryImpl implements WordRepository {
  WordRepositoryImpl(this._source);

  final WordDataSource _source;

  static const Failure _generationFailure = Failure(
    'تعذر إنشاء الكلمة. يرجى المحاولة مرة أخرى.',
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
  Future<Either<Failure, WordPage>> fetchWords({
    required int offset,
    required int limit,
  }) async {
    final result = await _source.fetchWordsPage(offset: offset, limit: limit);

    return result.map((rows) {
      final words = <WordSummary>[
        for (var index = 0; index < rows.length; index++)
          WordSummary.fromJson(rows[index], rank: offset + index + 1),
      ];

      return WordPage(words: words, hasMore: rows.length == limit);
    });
  }

  @override
  Future<Either<Failure, WordSummary>> updateWord(
    WordSummary current, {
    required String word,
    required String translation,
    required String exampleSentence,
    required String arabicSentence,
  }) async {
    final values = <String, dynamic>{
      'word': word,
      'translation': translation,
      'example_sentence': exampleSentence,
      'arabic_sentence': arabicSentence,
    };

    if (exampleSentence != current.exampleSentence || word != current.word) {
      values['sentence_blank'] = _blankOut(exampleSentence, word);
    }

    // The Arabic highlight is a token index; an edited sentence invalidates it.
    if (arabicSentence != current.arabicSentence) {
      values['word_index'] = -1;
    }

    final result = await _source.updateWord(current.id, values);

    return result.map(
      (row) => WordSummary.fromJson(row, rank: current.rank),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteWord(String id) {
    return _source.deleteWord(id);
  }

  /// Rebuilds the fill-in-the-blank sentence with the current word.
  static String _blankOut(String sentence, String word) {
    if (sentence.isEmpty || word.isEmpty) return '';

    final pattern = RegExp(
      '\\b${RegExp.escape(word)}\\b',
      caseSensitive: false,
    );
    if (!pattern.hasMatch(sentence)) return '';

    return sentence.replaceFirst(pattern, '___');
  }

  Future<Either<Failure, WordEntry>> _saveTranslation(
    Map<String, dynamic> payload,
    String? translation,
  ) async {
    if (payload['success'] != true) {
      // ignore: avoid_print
      print('[Supabase][addWord] ${payload['error']}');
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
      (failure) {
        // ignore: avoid_print
        print(
          '[Supabase][updateTranslation] ${failure.message} | '
          '${failure.cause}',
        );
        return Right<Failure, WordEntry>(entry);
      },
      (row) => Right<Failure, WordEntry>(WordEntry.fromJson(row)),
    );
  }

  Failure _failureFrom(Object? error) {
    if (error is String && error.contains('23505')) {
      return const Failure(
        'هذه الكلمة مضافة بالفعل.',
        type: FailureType.conflict,
        code: '23505',
      );
    }

    return _generationFailure;
  }
}
