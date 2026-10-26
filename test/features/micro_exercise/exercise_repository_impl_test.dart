import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/errors/failure.dart';
import 'package:wordlearn/features/micro_exercise/data/data_sources/exercise_data_source.dart';
import 'package:wordlearn/features/micro_exercise/data/models/exercise_item.dart';
import 'package:wordlearn/features/micro_exercise/data/repositories/exercise_repository_impl.dart';

class _FakeExerciseDataSource implements ExerciseDataSource {
  _FakeExerciseDataSource({required this.words, required this.quizzes});

  final List<Map<String, dynamic>> words;
  final List<Map<String, dynamic>> quizzes;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWords() async {
    return Right(words);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> generateQuizzes(
    List<String> words,
  ) async {
    return Right(quizzes);
  }
}

Map<String, dynamic> _word(String id, String word, String translation) {
  return <String, dynamic>{
    'id': id,
    'word': word,
    'translation': translation,
    'example_sentence': 'Example with $word.',
    'sentence_blank': 'Example with ______.',
  };
}

Map<String, dynamic> _quiz(String word, String translation) {
  return <String, dynamic>{
    'word': word,
    'sentence_blank': 'Example with ______.',
    'options': <String>[translation, 'başka', 'farklı'],
    'correct_answer': translation,
  };
}

void main() {
  final words = <Map<String, dynamic>>[
    _word('1', 'resilient', 'dayanıklı'),
    _word('2', 'diligent', 'çalışkan'),
    _word('3', 'curious', 'meraklı'),
    _word('4', 'brave', 'cesur'),
    _word('5', 'calm', 'sakin'),
  ];
  final quizzes = <Map<String, dynamic>>[
    _quiz('resilient', 'dayanıklı'),
    _quiz('diligent', 'çalışkan'),
    _quiz('curious', 'meraklı'),
    _quiz('brave', 'cesur'),
    _quiz('calm', 'sakin'),
  ];

  ExerciseRepositoryImpl buildRepository() {
    return ExerciseRepositoryImpl(
      _FakeExerciseDataSource(words: words, quizzes: quizzes),
      random: math.Random(7),
    );
  }

  test('kaldırılan soru türleri yerine yeni akışı üretir', () async {
    final result = await buildRepository().buildSession(
      seedIds: const ['1', '2', '3', '4', '5'],
    );

    final items = result.getOrElse(() => const <ExerciseItem>[]);
    expect(items.map((item) => item.type).toList(), <ExerciseType>[
      ExerciseType.matching,
      ExerciseType.fillBlank,
      ExerciseType.spelling,
      ExerciseType.translation,
      ExerciseType.pronunciation,
    ]);
  });

  test('eşleştirme üç çifte kadar çıkar', () async {
    final result = await buildRepository().buildSession(
      seedIds: const ['1', '2', '3', '4', '5'],
    );

    final matching = result
        .getOrElse(() => const <ExerciseItem>[])
        .whereType<MatchingExercise>()
        .single;
    expect(matching.pairs, hasLength(3));
    expect(matching.pairs.first.word, 'resilient');
    expect(matching.pairs.first.translation, 'dayanıklı');
  });

  test('iki kelimeyle de eşleştirme ve telaffuz üretilir', () async {
    final result = await buildRepository().buildSession(
      seedIds: const ['1', '2'],
    );

    final items = result.getOrElse(() => const <ExerciseItem>[]);
    final matching = items.whereType<MatchingExercise>().single;
    expect(matching.pairs, hasLength(2));

    final pronunciation = items.whereType<PronunciationExercise>().single;
    expect(<String>['resilient', 'diligent'], contains(pronunciation.word));
  });
}
