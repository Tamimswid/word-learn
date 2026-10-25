import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/quick_capture_repository.dart';
import 'quick_capture_state.dart';

class QuickCaptureCubit extends Cubit<QuickCaptureState> {
  QuickCaptureCubit(this._repository) : super(const QuickCaptureState());

  final QuickCaptureRepository _repository;

  Future<void> save(String word) async {
    emit(const QuickCaptureState(status: QuickCaptureStatus.saving));

    final result = await _repository.save(word);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        QuickCaptureState(
          status: QuickCaptureStatus.failure,
          message: failure.message,
        ),
      ),
      (word) => emit(
        QuickCaptureState(
          status: QuickCaptureStatus.success,
          message: word.word,
          word: word,
        ),
      ),
    );
  }

  void fail(String message) {
    if (isClosed) return;
    emit(
      QuickCaptureState(status: QuickCaptureStatus.failure, message: message),
    );
  }

  void reset() {
    if (isClosed) return;
    emit(const QuickCaptureState());
  }
}
