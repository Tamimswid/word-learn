import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/word_entry.dart';

@immutable
class AddWordState {
  const AddWordState({this.status = LoadStatus.idle, this.entry, this.failure});

  final LoadStatus status;
  final WordEntry? entry;
  final Failure? failure;

  bool get isLoading => status == LoadStatus.loading;
}
