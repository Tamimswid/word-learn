import 'package:flutter/foundation.dart';

import 'word_summary.dart';

/// One page of the all-words list.
@immutable
class WordPage {
  const WordPage({required this.words, required this.hasMore});

  final List<WordSummary> words;
  final bool hasMore;
}
