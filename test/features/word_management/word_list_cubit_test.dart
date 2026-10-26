import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/errors/failure.dart';
import 'package:wordlearn/features/word_management/data/models/word_entry.dart';
import 'package:wordlearn/features/word_management/data/models/word_page.dart';
import 'package:wordlearn/features/word_management/data/models/word_summary.dart';
import 'package:wordlearn/features/word_management/data/repositories/word_repository.dart';
import 'package:wordlearn/features/word_management/presentation/cubit/word_list_cubit.dart';

WordSummary _summary(int index) {
  return WordSummary(
    id: 'w$index',
    word: 'word$index',
    translation: 'translation$index',
    exampleSentence: 'sentence$index',
    errorCount: index,
    successCount: index + 1,
    rank: index + 1,
  );
}

class _FakeWordRepository implements WordRepository {
  _FakeWordRepository(int count)
    : _rows = <WordSummary>[
        for (var index = 0; index < count; index++) _summary(index),
      ];

  final List<WordSummary> _rows;
  final List<int> requestedOffsets = <int>[];
  bool failDelete = false;

  @override
  Future<Either<Failure, WordPage>> fetchWords({
    required int offset,
    required int limit,
  }) async {
    requestedOffsets.add(offset);

    final end = (offset + limit).clamp(0, _rows.length);
    final words = <WordSummary>[
      for (var index = offset; index < end; index++)
        _rows[index].copyWith(rank: index + 1),
    ];

    return Right(WordPage(words: words, hasMore: end < _rows.length));
  }

  @override
  Future<Either<Failure, Unit>> deleteWord(String id) async {
    if (failDelete) return const Left(Failure('silinemedi'));

    _rows.removeWhere((word) => word.id == id);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, WordEntry>> generateWord(
    String word, {
    String? translation,
  }) {
    throw UnsupportedError('not used in these tests');
  }
}

void main() {
  group('WordListCubit', () {
    test('loads ten words per page and keeps ranks in order', () async {
      final repository = _FakeWordRepository(12);
      final cubit = WordListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.words, hasLength(10));
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.words.first.rank, 1);
      expect(cubit.state.words.last.rank, 10);

      await cubit.loadMore();

      expect(repository.requestedOffsets, <int>[0, 10]);
      expect(cubit.state.words, hasLength(12));
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.words.last.rank, 12);
    });

    test('removes a word and reranks the remaining rows', () async {
      final repository = _FakeWordRepository(3);
      final cubit = WordListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.deleteWord(cubit.state.words[1]);

      expect(cubit.state.words.map((word) => word.word).toList(), <String>[
        'word0',
        'word2',
      ]);
      expect(cubit.state.words.map((word) => word.rank).toList(), <int>[1, 2]);
      expect(cubit.state.actionFailure, isNull);
    });

    test('restores a word when deletion fails', () async {
      final repository = _FakeWordRepository(3)..failDelete = true;
      final cubit = WordListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.deleteWord(cubit.state.words[1]);

      expect(cubit.state.words.map((word) => word.word).toList(), <String>[
        'word0',
        'word1',
        'word2',
      ]);
      expect(cubit.state.words.map((word) => word.rank).toList(), <int>[
        1,
        2,
        3,
      ]);
      expect(cubit.state.actionFailure?.message, 'silinemedi');
    });

    test('prepends a newly added word', () async {
      final repository = _FakeWordRepository(2);
      final cubit = WordListCubit(repository);
      addTearDown(cubit.close);

      await cubit.load();
      cubit.addWord(
        const WordEntry(
          id: 'new',
          userId: 'u1',
          word: 'new',
          translation: 'yeni',
          exampleSentence: '',
          sentenceBlank: '',
          options: <String>[],
          createdAt: null,
        ),
      );

      expect(cubit.state.words.map((word) => word.word).toList(), <String>[
        'new',
        'word0',
        'word1',
      ]);
      expect(cubit.state.words.map((word) => word.rank).toList(), <int>[
        1,
        2,
        3,
      ]);
    });
  });
}
