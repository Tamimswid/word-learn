import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/tutor_correction.dart';
import '../../data/models/tutor_session.dart';

@immutable
class TutorState {
  const TutorState({
    this.messages = const <ChatMessage>[],
    this.session = const TutorSession(),
    this.corrections = const <TutorCorrection>[],
    this.status = LoadStatus.idle,
    this.isAwaitingReply = false,
    this.isSummarizing = false,
    this.summary,
    this.failure,
  });

  final List<ChatMessage> messages;
  final TutorSession session;
  final List<TutorCorrection> corrections;
  final LoadStatus status;
  final bool isAwaitingReply;
  final bool isSummarizing;
  final String? summary;
  final Failure? failure;

  bool get isLoading => status == LoadStatus.loading;

  bool get hasFailed => status == LoadStatus.failure;

  bool get isReady => status == LoadStatus.success;

  bool get isTeacherSpeaking => isAwaitingReply || isSummarizing;

  bool get canSend => isReady && !isTeacherSpeaking;

  bool get isEnded => summary != null;

  int get turnCount =>
      messages.where((message) => message.role == ChatRole.user).length;

  TutorState copyWith({
    List<ChatMessage>? messages,
    TutorSession? session,
    List<TutorCorrection>? corrections,
    LoadStatus? status,
    bool? isAwaitingReply,
    bool? isSummarizing,
    String? summary,
    Failure? failure,
    bool clearCorrections = false,
    bool clearFailure = false,
  }) {
    return TutorState(
      messages: messages ?? this.messages,
      session: session ?? this.session,
      corrections: clearCorrections
          ? const <TutorCorrection>[]
          : corrections ?? this.corrections,
      status: status ?? this.status,
      isAwaitingReply: isAwaitingReply ?? this.isAwaitingReply,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      summary: summary ?? this.summary,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
