import 'package:flutter/foundation.dart';

enum ExerciseType {
  trueFalse,
  matching,
  fillBlank,
  spelling,
  translation,
  sentence,
}

/// One question shown in the exercise flow.
@immutable
sealed class ExerciseItem {
  const ExerciseItem();

  ExerciseType get type;
}

class TrueFalseExercise extends ExerciseItem {
  const TrueFalseExercise({
    required this.word,
    required this.sentence,
    required this.underlinedWord,
    required this.isCorrect,
  });

  final String word;
  final String sentence;
  final String underlinedWord;
  final bool isCorrect;

  @override
  ExerciseType get type => ExerciseType.trueFalse;
}

class MatchingExercise extends ExerciseItem {
  const MatchingExercise({required this.pairs});

  final List<MatchingPair> pairs;

  @override
  ExerciseType get type => ExerciseType.matching;
}

@immutable
class MatchingPair {
  const MatchingPair({
    required this.wordId,
    required this.word,
    required this.translation,
  });

  final String wordId;
  final String word;
  final String translation;
}

class FillBlankExercise extends ExerciseItem {
  const FillBlankExercise({
    required this.word,
    required this.sentenceBlank,
    required this.options,
    required this.correctAnswer,
  });

  final String word;

  /// Sentence where the gap is the shared blank token.
  final String sentenceBlank;
  final List<String> options;
  final String correctAnswer;

  @override
  ExerciseType get type => ExerciseType.fillBlank;
}

class SpellingExercise extends ExerciseItem {
  const SpellingExercise({
    required this.word,
    required this.translation,
    required this.sentence,
    required this.letters,
  });

  final String word;
  final String translation;

  /// Example sentence with the word partially masked.
  final String sentence;

  /// Missing letters plus a few distractors, already shuffled.
  final List<String> letters;

  @override
  ExerciseType get type => ExerciseType.spelling;
}

class TranslationExercise extends ExerciseItem {
  const TranslationExercise({
    required this.word,
    required this.sentence,
    required this.options,
    required this.correctAnswer,
  });

  final String word;
  final String sentence;
  final List<String> options;
  final String correctAnswer;

  @override
  ExerciseType get type => ExerciseType.translation;
}

class SentenceExercise extends ExerciseItem {
  const SentenceExercise({
    required this.word,
    required this.translation,
    required this.tokens,
    required this.correctSentence,
  });

  final String word;
  final String translation;

  /// Sentence words already shuffled.
  final List<String> tokens;
  final String correctSentence;

  @override
  ExerciseType get type => ExerciseType.sentence;
}
