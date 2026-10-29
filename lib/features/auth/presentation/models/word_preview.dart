/// A word and one example sentence shown on the sign-in preview cards.
class WordPreview {
  const WordPreview({required this.word, required this.sentence});

  final String word;
  final String sentence;
}

/// Three cards cycled on the sign-in screen.
const List<WordPreview> wordPreviewDeck = <WordPreview>[
  WordPreview(
    word: 'Curious',
    sentence: 'Stay curious, and every new word becomes a small discovery.',
  ),
  WordPreview(
    word: 'Consistent',
    sentence: 'A few minutes every day build a vocabulary that lasts.',
  ),
  WordPreview(
    word: 'Recall',
    sentence: 'Reviewing at the right moment helps you recall words for good.',
  ),
];
