import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/word_summary.dart';

@immutable
class WordListState {
  const WordListState({
    this.words = const <WordSummary>[],
    this.status = LoadStatus.idle,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.failure,
    this.actionFailure,
  });

  final List<WordSummary> words;
  final LoadStatus status;
  final bool isLoadingMore;
  final bool hasMore;
  final Failure? failure;
  final Failure? actionFailure;

  bool get isLoading => status == LoadStatus.loading;

  bool get isEmpty => status == LoadStatus.success && words.isEmpty;

  bool get canLoadMore =>
      hasMore && status == LoadStatus.success && !isLoadingMore;

  WordListState copyWith({
    List<WordSummary>? words,
    LoadStatus? status,
    bool? isLoadingMore,
    bool? hasMore,
    Failure? failure,
    Failure? actionFailure,
    bool clearFailure = false,
    bool clearActionFailure = false,
  }) {
    return WordListState(
      words: words ?? this.words,
      status: status ?? this.status,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      failure: clearFailure ? null : (failure ?? this.failure),
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
    );
  }
}
