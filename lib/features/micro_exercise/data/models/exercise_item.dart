import 'package:flutter/foundation.dart';

enum ExerciseType { matching, fillBlank, spelling, translation, pronunciation }

/// One question shown in the exercise flow.
@immutable
sealed class ExerciseItem {
  const ExerciseItem();

  ExerciseType get type;
}

/// Pairs English words with their Turkish meanings.
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

class PronunciationExercise extends ExerciseItem {
  const PronunciationExercise({required this.word, required this.translation});

  final String word;
  final String translation;

  @override
  ExerciseType get type => ExerciseType.pronunciation;
}
