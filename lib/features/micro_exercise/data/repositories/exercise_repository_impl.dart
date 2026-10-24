import 'dart:math' as math;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../data_sources/exercise_data_source.dart';
import '../models/exercise_item.dart';
import '../models/exercise_quiz.dart';
import '../models/exercise_word.dart';
import 'exercise_repository.dart';

/// Turns the words the user missed into a short mixed exercise session.
///
/// The AI quiz batch supplies the sentences and answer choices; matching,
/// spelling and translation distractors are built from the user's word list.
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._source, {math.Random? random})
    : _random = random ?? math.Random();

  final ExerciseDataSource _source;
  final math.Random _random;

  static const int _maxSeedWords = 5;
  static const int _minSeedWords = 2;
  static const int _matchingPairs = 2;
  static const int _choiceOptions = 3;
  static const int _spellingDistractors = 2;
  static const int _minSentenceTokens = 3;
  static const String _blankToken = '______';

  static final RegExp _blankPattern = RegExp(r'\(?\s*_{3,}\s*\)?');
  static final RegExp _letterPattern = RegExp(r'^[a-z]+$');
  static final RegExp _edgePunctuation = RegExp(r'^[.,!?;:"“”]+|[.,!?;:"“”]+$');
  static final RegExp _repeatedSpace = RegExp(r'\s+');

  static const Failure _notEnoughWords = Failure(
    'Alıştırma için en az iki kelime gerekiyor.',
    type: FailureType.notFound,
  );

  static const Failure _sessionFailure = Failure(
    'Alıştırma soruları oluşturulamadı. Lütfen tekrar deneyin.',
  );

  @override
  Future<Either<Failure, List<ExerciseItem>>> buildSession({
    required List<String> seedIds,
  }) async {
    final wordsResult = await _source.fetchWords();
    final wordsFailure = wordsResult.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (wordsFailure != null) return Left(wordsFailure);

    final allWords = wordsResult
        .getOrElse(() => const <Map<String, dynamic>>[])
        .map(ExerciseWord.fromJson)
        .where((word) => word.isValid)
        .toList(growable: false);

    final seeds = _pickSeeds(seedIds, allWords);
    if (seeds.length < _minSeedWords) return const Left(_notEnoughWords);

    final quizzesResult = await _source.generateQuizzes(
      seeds.map((seed) => seed.word).toList(growable: false),
    );
    final quizzesFailure = quizzesResult.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (quizzesFailure != null) return Left(quizzesFailure);

    final quizzes = <String, ExerciseQuiz>{};
    for (final row in quizzesResult.getOrElse(
      () => const <Map<String, dynamic>>[],
    )) {
      final quiz = ExerciseQuiz.tryParse(row);
      if (quiz == null) continue;
      quizzes.putIfAbsent(quiz.word.toLowerCase(), () => quiz);
    }
    if (quizzes.isEmpty) return const Left(_sessionFailure);

    final quizSeeds = seeds
        .where((seed) => quizzes.containsKey(seed.word.toLowerCase()))
        .toList(growable: false);

    final items = <ExerciseItem>[];
    final trueFalse = _buildTrueFalse(quizSeeds, quizzes);
    if (trueFalse != null) items.add(trueFalse);

    final matching = _buildMatching(seeds);
    if (matching != null) items.add(matching);

    final fillBlank = _buildFillBlank(quizSeeds, quizzes);
    if (fillBlank != null) items.add(fillBlank);

    final spelling = _buildSpelling(seeds, quizzes);
    if (spelling != null) items.add(spelling);

    final translation = _buildTranslation(quizSeeds, quizzes, allWords);
    if (translation != null) items.add(translation);

    final sentence = _buildSentence(quizSeeds, quizzes, allWords);
    if (sentence != null) items.add(sentence);

    if (items.isEmpty) return const Left(_sessionFailure);
    return Right(items);
  }

  static List<ExerciseWord> _pickSeeds(
    List<String> seedIds,
    List<ExerciseWord> allWords,
  ) {
    final byId = <String, ExerciseWord>{
      for (final word in allWords) word.id: word,
    };
    final seeds = <ExerciseWord>[];
    final seenIds = <String>{};
    for (final id in seedIds) {
      if (seeds.length >= _maxSeedWords) break;
      final seed = byId[id];
      if (seed == null || !seenIds.add(seed.id)) continue;
      seeds.add(seed);
    }
    return seeds;
  }

  ExerciseQuiz? _quizAt(
    List<ExerciseWord> seeds,
    Map<String, ExerciseQuiz> quizzes,
    int index,
  ) {
    if (seeds.isEmpty) return null;
    final seed = seeds[index % seeds.length];
    return quizzes[seed.word.toLowerCase()];
  }

  ExerciseItem? _buildTrueFalse(
    List<ExerciseWord> seeds,
    Map<String, ExerciseQuiz> quizzes,
  ) {
    final quiz = _quizAt(seeds, quizzes, 0);
    if (quiz == null) return null;

    final distractors = quiz.options
        .where(
          (option) => option.toLowerCase() != quiz.correctAnswer.toLowerCase(),
        )
        .toList(growable: false);
    if (distractors.isEmpty) return null;

    final useCorrect = _random.nextBool();
    final underlined = useCorrect
        ? quiz.correctAnswer
        : distractors[_random.nextInt(distractors.length)];
    final sentence = _fillBlank(quiz.sentenceBlank, underlined);
    if (sentence == null) return null;

    return TrueFalseExercise(
      word: quiz.word,
      sentence: sentence,
      underlinedWord: underlined,
      isCorrect: useCorrect,
    );
  }

  ExerciseItem? _buildMatching(List<ExerciseWord> seeds) {
    final pairs = <MatchingPair>[];
    final seenTranslations = <String>{};
    for (final seed in seeds) {
      final translation = seed.translation.trim();
      if (!seenTranslations.add(translation.toLowerCase())) continue;
      pairs.add(
        MatchingPair(
          wordId: seed.id,
          word: seed.word,
          translation: translation,
        ),
      );
      if (pairs.length == _matchingPairs) break;
    }

    if (pairs.length < _matchingPairs) return null;
    return MatchingExercise(pairs: pairs);
  }

  ExerciseItem? _buildFillBlank(
    List<ExerciseWord> seeds,
    Map<String, ExerciseQuiz> quizzes,
  ) {
    final quiz = _quizAt(seeds, quizzes, 1);
    if (quiz == null) return null;

    final options = _buildOptions(quiz.correctAnswer, quiz.options);
    if (options == null) return null;

    return FillBlankExercise(
      word: quiz.word,
      sentenceBlank: _normalizeBlank(quiz.sentenceBlank),
      options: options,
      correctAnswer: quiz.correctAnswer,
    );
  }

  ExerciseItem? _buildSpelling(
    List<ExerciseWord> seeds,
    Map<String, ExerciseQuiz> quizzes,
  ) {
    for (final seed in seeds) {
      final word = seed.word.trim().toLowerCase();
      if (word.length < 3 || !_letterPattern.hasMatch(word)) continue;

      final missing = word.substring(1, word.length - 1).split('');
      final used = missing.toSet();
      final letters = <String>[...missing];

      var attempts = 0;
      while (letters.length < missing.length + _spellingDistractors &&
          attempts < 100) {
        attempts++;
        final letter = String.fromCharCode(97 + _random.nextInt(26));
        if (!used.add(letter)) continue;
        letters.add(letter);
      }

      letters.shuffle(_random);
      final masked =
          '${word[0]}${'_' * (word.length - 2)}${word[word.length - 1]}';
      final quiz = quizzes[word];
      final source = quiz?.sentenceBlank ?? seed.sentenceBlank;
      final sentence = source.isEmpty ? '' : _fillBlank(source, masked) ?? '';

      return SpellingExercise(
        word: word,
        translation: seed.translation,
        sentence: sentence,
        letters: letters,
      );
    }
    return null;
  }

  ExerciseItem? _buildTranslation(
    List<ExerciseWord> seeds,
    Map<String, ExerciseQuiz> quizzes,
    List<ExerciseWord> allWords,
  ) {
    final quiz = _quizAt(seeds, quizzes, 2);
    if (quiz == null) return null;

    final word = _wordFor(quiz.word, allWords);
    if (word == null) return null;

    final sentence = _fillBlank(quiz.sentenceBlank, quiz.correctAnswer);
    if (sentence == null) return null;

    final options = _buildOptions(
      word.translation,
      allWords
          .where((candidate) => candidate.id != word.id)
          .map((candidate) => candidate.translation),
    );
    if (options == null) return null;

    return TranslationExercise(
      word: word.word,
      sentence: sentence,
      options: options,
      correctAnswer: word.translation,
    );
  }

  ExerciseItem? _buildSentence(
    List<ExerciseWord> seeds,
    Map<String, ExerciseQuiz> quizzes,
    List<ExerciseWord> allWords,
  ) {
    final quiz = _quizAt(seeds, quizzes, 3);
    if (quiz == null) return null;

    final word = _wordFor(quiz.word, allWords);
    if (word == null) return null;

    final sentence = _fillBlank(quiz.sentenceBlank, quiz.correctAnswer);
    if (sentence == null) return null;

    final tokens = sentence
        .split(' ')
        .map((token) => token.replaceAll(_edgePunctuation, ''))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
    if (tokens.length < _minSentenceTokens) return null;

    final shuffled = <String>[...tokens]..shuffle(_random);
    return SentenceExercise(
      word: word.word,
      translation: word.translation,
      tokens: shuffled,
      correctSentence: tokens.join(' '),
    );
  }

  List<String>? _buildOptions(String correct, Iterable<String> candidates) {
    final options = <String>[correct];
    final seen = <String>{correct.toLowerCase()};
    final pool = candidates.toList(growable: false)..shuffle(_random);

    for (final candidate in pool) {
      if (options.length >= _choiceOptions) break;
      final text = candidate.trim();
      if (text.isEmpty || !seen.add(text.toLowerCase())) continue;
      options.add(text);
    }

    if (options.length < 2) return null;
    options.shuffle(_random);
    return options;
  }

  String? _fillBlank(String sentence, String word) {
    if (!_blankPattern.hasMatch(sentence)) return null;
    return sentence
        .replaceFirst(_blankPattern, word)
        .replaceAll(_repeatedSpace, ' ')
        .trim();
  }

  String _normalizeBlank(String sentence) {
    return sentence
        .replaceAll(_blankPattern, _blankToken)
        .replaceAll(_repeatedSpace, ' ')
        .trim();
  }

  static ExerciseWord? _wordFor(String word, List<ExerciseWord> allWords) {
    final lower = word.toLowerCase();
    for (final candidate in allWords) {
      if (candidate.word.toLowerCase() == lower) return candidate;
    }
    return null;
  }
}
