import 'package:flutter/material.dart';

import '../di/app_locator.dart';
import '../platform/text_to_speech_service.dart';

/// Makes [child] pronounce [text] when tapped, without an extra icon.
class TapToSpeak extends StatelessWidget {
  const TapToSpeak({
    super.key,
    required this.text,
    required this.child,
    this.tooltip = 'Okunuşu dinle',
    this.language = 'en-US',
  });

  final String text;
  final Widget child;
  final String tooltip;
  final String language;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return child;

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => speakText(context, text, language: language),
          child: child,
        ),
      ),
    );
  }
}

Future<void> speakText(
  BuildContext context,
  String text, {
  String language = 'en-US',
}) async {
  final result = await locator<TextToSpeechService>().speak(
    text,
    language: language,
  );

  result.fold(
    (failure) {
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message)));
    },
    (_) {},
  );
}
