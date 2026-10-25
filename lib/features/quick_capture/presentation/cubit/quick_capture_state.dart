import 'package:flutter/foundation.dart';

import '../../../word_management/data/models/word_entry.dart';

enum QuickCaptureStatus { idle, saving, success, failure }

@immutable
class QuickCaptureState {
  const QuickCaptureState({
    this.status = QuickCaptureStatus.idle,
    this.message,
    this.word,
  });

  final QuickCaptureStatus status;
  final String? message;
  final WordEntry? word;

  bool get isSaving => status == QuickCaptureStatus.saving;
  bool get isSuccess => status == QuickCaptureStatus.success;
  bool get isFailure => status == QuickCaptureStatus.failure;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuickCaptureState &&
            other.status == status &&
            other.message == message &&
            other.word == word;
  }

  @override
  int get hashCode => Object.hash(status, message, word);
}
