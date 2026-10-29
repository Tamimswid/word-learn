import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/word_summary.dart';

@immutable
class EditWordState {
  const EditWordState({this.status = LoadStatus.idle, this.word, this.failure});

  final LoadStatus status;
  final WordSummary? word;
  final Failure? failure;

  bool get isSaving => status == LoadStatus.loading;
}
