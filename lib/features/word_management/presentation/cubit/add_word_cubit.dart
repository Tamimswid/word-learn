import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/load_status.dart';
import '../../data/models/word_entry.dart';
import '../../data/repositories/word_repository.dart';
import 'add_word_state.dart';

class AddWordCubit extends Cubit<AddWordState> {
  AddWordCubit(this._repository) : super(const AddWordState());

  final WordRepository _repository;

  Future<WordEntry?> add(String word, {String? translation}) async {
    if (state.isLoading) return null;

    emit(const AddWordState(status: LoadStatus.loading));

    final result = await _repository.generateWord(
      word,
      translation: translation,
    );

    if (isClosed) return null;

    return result.fold<WordEntry?>(
      (failure) {
        emit(AddWordState(status: LoadStatus.failure, failure: failure));
        return null;
      },
      (entry) {
        emit(AddWordState(status: LoadStatus.success, entry: entry));
        return entry;
      },
    );
  }

  void clearError() {
    if (state.status == LoadStatus.failure) {
      emit(const AddWordState());
    }
  }
}
