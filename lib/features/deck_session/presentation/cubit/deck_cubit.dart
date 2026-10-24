import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/load_status.dart';
import '../../data/models/deck_word.dart';
import '../../data/repositories/deck_repository.dart';
import 'deck_state.dart';

class DeckCubit extends Cubit<DeckState> {
  DeckCubit(this._repository) : super(const DeckState());

  final DeckRepository _repository;

  Future<void> load() async {
    if (state.isLoading) return;

    emit(state.copyWith(status: LoadStatus.loading, clearFailure: true));

    final result = await _repository.fetchSession();

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: LoadStatus.failure, failure: failure),
      ),
      (words) => emit(
        DeckState(words: words, status: LoadStatus.success),
      ),
    );
  }

  /// Advances the deck immediately and persists the answer in the background.
  void answer({required bool known}) {
    final word = state.current;
    if (word == null) return;

    emit(
      state.copyWith(
        index: state.index + 1,
        unknownWords: known
            ? state.unknownWords
            : <DeckWord>[...state.unknownWords, word],
        status: LoadStatus.success,
        clearFailure: true,
      ),
    );

    unawaited(_persist(word, known: known));
  }

  Future<void> _persist(DeckWord word, {required bool known}) async {
    final result = await _repository.recordAnswer(word, known: known);

    if (isClosed) return;

    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) {},
    );
  }
}
