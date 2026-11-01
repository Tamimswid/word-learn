import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// Typing pace for the word-by-word reveal, tied to the teacher's speech.
class WordTyperConfig {
  const WordTyperConfig({
    this.charsPerSecond = 10,
    this.wordFade = const Duration(milliseconds: 140),
  });

  static const WordTyperConfig standard = WordTyperConfig();

  /// How fast words appear; 10 chars/s keeps up with speech without lagging.
  final double charsPerSecond;

  final Duration wordFade;
}

/// Reveals [text] word by word at the pace of [WordTyperConfig]; words listed
/// in [wrongWords] (case-insensitive) render in the wrong-word style.
///
/// Tapping a word swaps it for its translation ([onWordTranslate]); tapping
/// the translation swaps the English word back. A long press reports the word
/// through [onWordLongPress] (used to save it to the learner's word list).
class WordTyper extends StatefulWidget {
  const WordTyper({
    super.key,
    required this.text,
    required this.style,
    this.wrongWords = const <String>[],
    this.wrongStyle,
    this.config = WordTyperConfig.standard,
    this.duration,
    this.onTap,
    this.onWordTranslate,
    this.onWordLongPress,
  });

  final String text;
  final TextStyle style;
  final List<String> wrongWords;
  final TextStyle? wrongStyle;
  final WordTyperConfig config;

  /// Real length of the spoken audio; when given, words are revealed across
  /// exactly this span so text never runs ahead of the voice.
  final Duration? duration;

  /// Tap on empty space around the words (used to replay the teacher).
  final VoidCallback? onTap;

  /// Returns the Arabic translation of a word, or null when it fails.
  final Future<String?> Function(String word)? onWordTranslate;

  /// Long press on a word (used to save it to the learner's word list).
  final void Function(String word)? onWordLongPress;

  @override
  State<WordTyper> createState() => _WordTyperState();
}

class _WordTyperState extends State<WordTyper> {
  Timer? _timer;
  int _visible = 0;

  /// Bare word → Arabic translation currently shown in place of the word.
  final Map<String, String> _translated = <String, String>{};
  final Set<String> _loading = <String>{};

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(WordTyper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.duration != widget.duration ||
        oldWidget.config.charsPerSecond != widget.config.charsPerSecond) {
      _restart();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    _visible = 0;
    _translated.clear();
    _loading.clear();

    final words = _tokens();
    if (words.isEmpty) return;

    final totalChars = widget.text.length;
    final spokenMs = widget.duration?.inMilliseconds ?? 0;
    final totalMs = spokenMs > 0
        ? spokenMs
        : (totalChars / widget.config.charsPerSecond * 1000).round();

    var before = 0;
    final starts = <int>[];
    for (final word in words) {
      starts.add(totalMs * before ~/ totalChars);
      before += word.length + 1;
    }

    final start = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      var next = _visible;
      while (next < starts.length && elapsed >= starts[next]) {
        next++;
      }
      if (next == _visible && next < starts.length) return;

      if (mounted) setState(() => _visible = next);
      if (_visible >= words.length) timer.cancel();
    });
  }

  List<String> _tokens() {
    return widget.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
  }

  static String _bare(String word) {
    return word.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '').toLowerCase();
  }

  bool _isWrong(String word) {
    final bare = _bare(word);
    if (bare.isEmpty) return false;
    return widget.wrongWords.contains(bare);
  }

  Future<void> _toggleWord(String word) async {
    final bare = _bare(word);
    if (bare.isEmpty || widget.onWordTranslate == null) return;

    if (_translated.containsKey(bare)) {
      setState(() => _translated.remove(bare));
      return;
    }
    if (_loading.contains(bare)) return;

    setState(() => _loading.add(bare));
    final translation = await widget.onWordTranslate!(bare);
    if (!mounted) return;
    setState(() {
      _loading.remove(bare);
      if (translation != null && translation.trim().isNotEmpty) {
        _translated[bare] = translation.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = _tokens();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            for (var index = 0; index < words.length; index++)
              AnimatedOpacity(
                opacity: index < _visible ? 1 : 0,
                duration: widget.config.wordFade,
                child: _wordWidget(words[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _wordWidget(String word) {
    final bare = _bare(word);
    final translation = _translated[bare];
    final busy = _loading.contains(bare);

    final translated = translation != null;
    final label = busy ? '…' : (translated ? translation : word);
    final style = _isWrong(word)
        ? (widget.wrongStyle ?? _wrongStyle(widget.style))
        : (translated
              ? widget.style.copyWith(color: AppColors.primary)
              : widget.style);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onWordTranslate == null ? null : () => _toggleWord(word),
      onLongPress: widget.onWordLongPress == null
          ? null
          : () => widget.onWordLongPress!(word),
      child: Text(
        label,
        textDirection: translated ? TextDirection.rtl : TextDirection.ltr,
        style: style,
      ),
    );
  }

  static TextStyle _wrongStyle(TextStyle style) {
    return style.copyWith(color: AppColors.destructive);
  }
}
