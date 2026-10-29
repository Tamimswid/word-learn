import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/load_status.dart';
import '../../data/models/word_summary.dart';
import '../../data/repositories/word_repository.dart';
import 'edit_word_state.dart';

class EditWordCubit extends Cubit<EditWordState> {
  EditWordCubit(this._repository) : super(const EditWordState());

  final WordRepository _repository;

  Future<WordSummary?> save(
    WordSummary current, {
    required String word,
    required String translation,
    required String exampleSentence,
    required String arabicSentence,
  }) async {
    if (state.isSaving) return null;

    emit(const EditWordState(status: LoadStatus.loading));

    final result = await _repository.updateWord(
      current,
      word: word,
      translation: translation,
      exampleSentence: exampleSentence,
      arabicSentence: arabicSentence,
    );

    if (isClosed) return null;

    return result.fold<WordSummary?>(
      (failure) {
        emit(EditWordState(status: LoadStatus.failure, failure: failure));
        return null;
      },
      (updated) {
        emit(EditWordState(status: LoadStatus.success, word: updated));
        return updated;
      },
    );
  }

  void clearError() {
    if (state.status == LoadStatus.failure) {
      emit(const EditWordState());
    }
  }
}
