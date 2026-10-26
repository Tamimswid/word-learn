import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/features/micro_exercise/micro_exercise.dart';
import 'package:wordlearn/features/micro_exercise/presentation/widgets/pronunciation_exercise_view.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('doğru telaffuz geri bildirimini gösterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PronunciationExerciseView(
          item: PronunciationExercise(
            word: 'resilient',
            translation: 'dayanıklı',
          ),
          answer: ExerciseAnswer(
            isCorrect: true,
            correctAnswer: 'resilient',
            selected: 'resilient',
          ),
          onResult: _result,
          onSkip: _skip,
        ),
      ),
    );

    expect(find.text('Telaffuzun anlaşıldı!'), findsOneWidget);
    expect(find.text('Duyduğum: resilient'), findsOneWidget);
  });

  testWidgets('yanlış telaffuzda doğru kelimeyi gösterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PronunciationExerciseView(
          item: PronunciationExercise(
            word: 'resilient',
            translation: 'dayanıklı',
          ),
          answer: ExerciseAnswer(
            isCorrect: false,
            correctAnswer: 'resilient',
            selected: 'resilience',
          ),
          onResult: _result,
          onSkip: _skip,
        ),
      ),
    );

    expect(find.text('Doğru telaffuz: resilient'), findsOneWidget);
    expect(find.text('Duyduğum: resilience'), findsOneWidget);
  });
}

void _result(String _) {}

void _skip() {}
