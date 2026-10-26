import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Renders [text] with every whole-word occurrence of [highlight] emphasized,
/// falling back to the whitespace token at [highlightIndex].
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    this.highlight = '',
    required this.style,
    this.highlightStyle,
    this.textAlign,
    this.textDirection,
    this.highlightIndex,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String highlight;
  final TextStyle style;
  final TextStyle? highlightStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  /// 0-based whitespace token to emphasize when [highlight] is empty.
  final int? highlightIndex;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans();
    if (spans == null) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<InlineSpan>? _buildSpans() {
    if (text.isEmpty) return null;

    final emphasized =
        highlightStyle ??
        style.copyWith(
          color: AppColors.primaryGlow,
          fontWeight: FontWeight.w500,
        );

    return _spansForWord(emphasized) ?? _spansForIndex(emphasized);
  }

  List<InlineSpan>? _spansForWord(TextStyle emphasized) {
    if (highlight.isEmpty) return null;

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final spans = <InlineSpan>[];
    var cursor = 0;
    var index = lowerText.indexOf(lowerHighlight);

    while (index >= 0) {
      final end = index + lowerHighlight.length;
      if (_isWholeWord(text, index, end)) {
        if (index > cursor) {
          spans.add(TextSpan(text: text.substring(cursor, index)));
        }
        spans.add(
          TextSpan(text: text.substring(index, end), style: emphasized),
        );
        cursor = end;
      }
      index = lowerText.indexOf(lowerHighlight, index + 1);
    }

    if (spans.isEmpty) return null;
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return spans;
  }

  List<InlineSpan>? _spansForIndex(TextStyle emphasized) {
    final index = highlightIndex ?? -1;
    if (index < 0) return null;

    final tokens = RegExp(r'\S+').allMatches(text).toList(growable: false);
    if (index >= tokens.length) return null;

    final start = tokens[index].start;
    final end = tokens[index].end;

    return <InlineSpan>[
      if (start > 0) TextSpan(text: text.substring(0, start)),
      TextSpan(text: text.substring(start, end), style: emphasized),
      if (end < text.length) TextSpan(text: text.substring(end)),
    ];
  }

  static bool _isWholeWord(String text, int start, int end) {
    final startsWord = start == 0 || !_isLetter(text.codeUnitAt(start - 1));
    final endsWord = end == text.length || !_isLetter(text.codeUnitAt(end));
    return startsWord && endsWord;
  }

  static bool _isLetter(int codeUnit) {
    return (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
  }
}
