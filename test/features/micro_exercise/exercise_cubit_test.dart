import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/errors/failure.dart';
import 'package:wordlearn/features/micro_exercise/micro_exercise.dart';

class _FakeExerciseRepository implements ExerciseRepository {
  _FakeExerciseRepository(this.items);

  final List<ExerciseItem> items;

  @override
  Future<Either<Failure, List<ExerciseItem>>> buildSession({
    required List<String> seedIds,
  }) async {
    return Right(items);
  }
}

const _pronunciation = PronunciationExercise(
  word: 'resilient',
  translation: 'dayanıklı',
);

Future<ExerciseCubit> _loadedCubit() async {
  final cubit = ExerciseCubit(
    _FakeExerciseRepository(const <ExerciseItem>[_pronunciation]),
  );
  await cubit.load(seedIds: const <String>['1']);
  return cubit;
}

void main() {
  test('doğru telaffuzu kabul eder', () async {
    final cubit = await _loadedCubit();
    addTearDown(cubit.close);

    cubit.answerPronunciation('Resilient!');

    expect(cubit.state.answer?.isCorrect, isTrue);
    expect(cubit.state.answer?.correctAnswer, 'resilient');
    expect(cubit.state.correctCount, 1);
  });

  test('kelimeyi cümle içinde duyduğunda da kabul eder', () async {
    final cubit = await _loadedCubit();
    addTearDown(cubit.close);

    cubit.answerPronunciation('The word is resilient');

    expect(cubit.state.answer?.isCorrect, isTrue);
  });

  test('yanlış telaffuzu reddeder', () async {
    final cubit = await _loadedCubit();
    addTearDown(cubit.close);

    cubit.answerPronunciation('resilience');

    expect(cubit.state.answer?.isCorrect, isFalse);
    expect(cubit.state.correctCount, 0);
  });

  test('atlanan telaffuz sorusu yanlış sayılır', () async {
    final cubit = await _loadedCubit();
    addTearDown(cubit.close);

    cubit.skipPronunciation();

    expect(cubit.state.answer?.isCorrect, isFalse);
    expect(cubit.state.answer?.selected, isNull);
    expect(cubit.state.correctCount, 0);
  });

  test('cevaplanan telaffuz sorusundan sonra oturum biter', () async {
    final cubit = await _loadedCubit();
    addTearDown(cubit.close);

    cubit.answerPronunciation('resilient');
    cubit.next();

    expect(cubit.state.isFinished, isTrue);
  });
}
