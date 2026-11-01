import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/load_status.dart';
import '../../data/models/chat_message.dart';
import '../../data/repositories/tutor_repository.dart';
import 'tutor_state.dart';

class TutorCubit extends Cubit<TutorState> {
  TutorCubit(this._repository) : super(const TutorState());

  final TutorRepository _repository;

  /// Same limit the `ai-tutor` function enforces on `userMessage`.
  static const int _maxMessageLength = 1200;

  Future<void> start() async {
    if (state.status == LoadStatus.loading || state.isReady) {
      return;
    }

    emit(const TutorState(status: LoadStatus.loading));

    final result = await _repository.start();

    if (isClosed) {
      return;
    }

    result.fold(
      (failure) {
        emit(TutorState(status: LoadStatus.failure, failure: failure));
      },
      (opening) {
        emit(
          TutorState(
            status: LoadStatus.success,
            messages: <ChatMessage>[ChatMessage.teacher(opening.text)],
            session: opening.session,
          ),
        );
      },
    );
  }

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || !state.canSend) {
      return;
    }

    final history = state.messages;
    emit(
      state.copyWith(
        messages: <ChatMessage>[...history, ChatMessage.user(message)],
        isAwaitingReply: true,
        clearCorrections: true,
        clearFailure: true,
      ),
    );

    final result = await _repository.respond(
      userMessage: _clamp(message),
      history: history,
      session: state.session,
    );

    if (isClosed) {
      return;
    }

    result.fold(
      (failure) {
        emit(state.copyWith(isAwaitingReply: false, failure: failure));
      },
      (reply) {
        emit(
          state.copyWith(
            messages: <ChatMessage>[
              ...state.messages,
              ChatMessage.teacher(reply.text),
            ],
            corrections: reply.corrections,
            isAwaitingReply: false,
            clearFailure: true,
          ),
        );
      },
    );
  }

  /// Asks the function to write the lesson memo; it is stored in `tutor_chats`.
  Future<void> finish() async {
    if (state.isTeacherSpeaking || state.isEnded) {
      return;
    }

    emit(state.copyWith(isSummarizing: true));

    final result = await _repository.end(
      history: state.messages,
      session: state.session,
    );

    if (isClosed) {
      return;
    }

    result.fold(
      (failure) {
        emit(state.copyWith(isSummarizing: false, failure: failure));
      },
      (summary) {
        emit(state.copyWith(isSummarizing: false, summary: summary));
      },
    );
  }

  static String _clamp(String message) {
    return message.length <= _maxMessageLength
        ? message
        : message.substring(0, _maxMessageLength);
  }
}
