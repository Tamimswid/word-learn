import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/load_status.dart';
import '../../data/models/word_entry.dart';
import '../../data/models/word_summary.dart';
import '../../data/repositories/word_repository.dart';
import 'word_list_state.dart';

class WordListCubit extends Cubit<WordListState> {
  WordListCubit(this._repository) : super(const WordListState());

  static const int pageSize = 10;

  final WordRepository _repository;

  Future<void> load() async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: LoadStatus.loading,
        clearFailure: true,
        clearActionFailure: true,
      ),
    );

    final result = await _repository.fetchWords(offset: 0, limit: pageSize);

    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(status: LoadStatus.failure, failure: failure)),
      (page) => emit(
        WordListState(
          words: page.words,
          status: LoadStatus.success,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    emit(state.copyWith(isLoadingMore: true, clearActionFailure: true));

    final result = await _repository.fetchWords(
      offset: state.words.length,
      limit: pageSize,
    );

    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoadingMore: false, actionFailure: failure)),
      (page) {
        final knownIds = state.words.map((word) => word.id).toSet();
        final fresh = page.words
            .where((word) => !knownIds.contains(word.id))
            .toList(growable: false);

        emit(
          state.copyWith(
            words: _rerank(<WordSummary>[...state.words, ...fresh]),
            isLoadingMore: false,
            hasMore: page.hasMore,
            clearActionFailure: true,
          ),
        );
      },
    );
  }

  Future<void> deleteWord(WordSummary word) async {
    final index = state.words.indexWhere((item) => item.id == word.id);
    if (index < 0) return;

    final remaining = <WordSummary>[...state.words]..removeAt(index);
    emit(state.copyWith(words: _rerank(remaining), clearActionFailure: true));

    final result = await _repository.deleteWord(word.id);

    if (isClosed) return;

    result.fold((failure) {
      final restored = <WordSummary>[...state.words]
        ..insert(index.clamp(0, state.words.length), word);

      emit(state.copyWith(words: _rerank(restored), actionFailure: failure));
    }, (_) {});
  }

  void addWord(WordEntry entry) {
    final item = WordSummary(
      id: entry.id,
      word: entry.word,
      translation: entry.translation,
      exampleSentence: entry.exampleSentence,
      errorCount: 0,
      successCount: 0,
      rank: 1,
      sentenceTranslation: entry.sentenceTranslation,
      arabicSentence: entry.arabicSentence,
      wordIndex: entry.wordIndex,
    );

    emit(
      state.copyWith(
        words: _rerank(<WordSummary>[item, ...state.words]),
        status: LoadStatus.success,
        clearFailure: true,
        clearActionFailure: true,
      ),
    );
  }

  static List<WordSummary> _rerank(List<WordSummary> words) {
    return <WordSummary>[
      for (var index = 0; index < words.length; index++)
        words[index].copyWith(rank: index + 1),
    ];
  }
}
