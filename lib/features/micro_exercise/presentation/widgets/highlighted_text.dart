import 'package:flutter/material.dart';

/// Text with one occurrence of [highlight] rendered in [highlightStyle].
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    required this.style,
    this.highlightStyle,
    this.textAlign,
  });

  final String text;
  final String highlight;
  final TextStyle style;
  final TextStyle? highlightStyle;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final index = _wordStart(text, highlight);
    if (index < 0) return Text(text, style: style, textAlign: textAlign);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + highlight.length),
            style: highlightStyle,
          ),
          TextSpan(text: text.substring(index + highlight.length)),
        ],
      ),
      style: style,
      textAlign: textAlign,
    );
  }

  /// First whole-word occurrence, so short words do not match inside others.
  static int _wordStart(String text, String highlight) {
    if (highlight.isEmpty) return -1;

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    var index = lowerText.indexOf(lowerHighlight);

    while (index >= 0) {
      final end = index + lowerHighlight.length;
      final startsWord = index == 0 || !_isLetter(text.codeUnitAt(index - 1));
      final endsWord = end == text.length || !_isLetter(text.codeUnitAt(end));
      if (startsWord && endsWord) return index;
      index = lowerText.indexOf(lowerHighlight, index + 1);
    }
    return -1;
  }

  static bool _isLetter(int codeUnit) {
    return (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
  }
}
