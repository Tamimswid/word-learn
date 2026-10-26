import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/exercise_item.dart';
import '../cubit/exercise_state.dart';

class PronunciationExerciseView extends StatefulWidget {
  const PronunciationExerciseView({
    super.key,
    required this.item,
    required this.answer,
    required this.onResult,
    required this.onSkip,
  });

  final PronunciationExercise item;
  final ExerciseAnswer? answer;
  final ValueChanged<String> onResult;
  final VoidCallback onSkip;

  @override
  State<PronunciationExerciseView> createState() =>
      _PronunciationExerciseViewState();
}

class _PronunciationExerciseViewState extends State<PronunciationExerciseView> {
  final SpeechToText _speech = SpeechToText();

  bool _initializing = true;
  bool _available = false;
  bool _listening = false;
  bool _submitted = false;
  String? _error;
  String? _heard;
  String? _localeId;

  @override
  void initState() {
    super.initState();
    if (widget.answer == null) {
      _prepareSpeech();
    }
  }

  @override
  void dispose() {
    unawaited(_speech.cancel());
    super.dispose();
  }

  Future<void> _prepareSpeech() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      final available = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );

      String? localeId;
      if (available) {
        try {
          localeId = _preferredLocale(await _speech.locales());
        } catch (_) {
          localeId = null;
        }
      }

      if (!mounted) return;
      setState(() {
        _initializing = false;
        _available = available;
        _localeId = localeId;
        if (!available) {
          _error = 'Mikrofon kullanılamıyor. İzin verildiğinden emin ol.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _available = false;
        _error = 'Mikrofon başlatılamadı.';
      });
    }
  }

  String? _preferredLocale(List<LocaleName> locales) {
    for (final preferred in const ['en_US', 'en_GB']) {
      for (final locale in locales) {
        if (locale.localeId == preferred) return preferred;
      }
    }
    for (final locale in locales) {
      if (locale.localeId.startsWith('en')) return locale.localeId;
    }
    return null;
  }

  Future<void> _startListening() async {
    if (!_available || _listening || _submitted || widget.answer != null) {
      return;
    }

    setState(() {
      _error = null;
      _heard = null;
      _listening = true;
    });

    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          localeId: _localeId,
          listenFor: const Duration(seconds: 6),
          pauseFor: const Duration(seconds: 2),
          cancelOnError: true,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _listening = false;
        _error = 'Mikrofon başlatılamadı.';
      });
    }
  }

  Future<void> _stopListening() async {
    if (!_listening && !_speech.isListening) return;
    await _speech.stop();
    if (!mounted) return;
    if (_listening && widget.answer == null) {
      setState(() => _listening = false);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;

    final words = result.recognizedWords.trim();
    if (words.isNotEmpty && words != _heard) {
      setState(() => _heard = words);
    }

    if (!result.finalResult || _submitted) return;

    if (words.isEmpty) {
      setState(() {
        _listening = false;
        _error = 'Seni duyamadım. Tekrar dene.';
      });
      return;
    }

    _submit(words);
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;

    if (status == 'listening') {
      if (!_listening) setState(() => _listening = true);
      return;
    }

    if (status == 'notListening' || status == 'done') {
      if (_listening) setState(() => _listening = false);
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;

    setState(() {
      _listening = false;
      _error = switch (error.errorMsg) {
        'error_no_match' ||
        'error_speech_timeout' => 'Seni duyamadım. Tekrar dene.',
        'error_permission' => 'Mikrofon izni verilmedi.',
        _ => 'Ses tanınamadı. Tekrar dene.',
      };
    });
  }

  void _submit(String words) {
    _submitted = true;
    setState(() => _listening = false);
    unawaited(_stopListening());
    widget.onResult(words);
  }

  @override
  Widget build(BuildContext context) {
    final answer = widget.answer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelimeyi yüksek sesle söyle.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),
        Text(
          widget.item.word,
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.item.translation,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.huge + AppSpacing.sm),
        if (answer != null)
          _AnswerFeedback(answer: answer)
        else if (_initializing)
          const Center(child: CircularProgressIndicator())
        else if (_available)
          _Microphone(
            listening: _listening,
            heard: _heard,
            error: _error,
            onPressed: _listening ? _stopListening : _startListening,
          )
        else
          _Unavailable(
            error: _error,
            onRetry: _prepareSpeech,
            onSkip: widget.onSkip,
          ),
      ],
    );
  }
}

class _Microphone extends StatelessWidget {
  const _Microphone({
    required this.listening,
    required this.heard,
    required this.error,
    required this.onPressed,
  });

  final bool listening;
  final String? heard;
  final String? error;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Material(
            color: listening ? AppColors.primary : AppColors.primarySoft,
            clipBehavior: Clip.antiAlias,
            shape: CircleBorder(
              side: listening ? AppBorders.sidePrimary : AppBorders.none,
            ),
            child: InkWell(
              onTap: onPressed,
              overlayColor: const WidgetStatePropertyAll(
                AppColors.foregroundFaint,
              ),
              child: SizedBox(
                width: AppSpacing.giant * 2,
                height: AppSpacing.giant * 2,
                child: Icon(
                  listening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: AppSpacing.xxxl,
                  color: listening
                      ? AppColors.onPrimary
                      : AppColors.primaryGlow,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          listening ? 'Dinliyorum…' : 'Mikrofona dokun ve kelimeyi söyle.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        if (heard != null && heard!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Duyduğum: $heard',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.secondaryForeground,
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({
    required this.error,
    required this.onRetry,
    required this.onSkip,
  });

  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.mic_off_rounded,
              size: AppSpacing.xxl,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                error ?? 'Bu cihazda ses tanıma kullanılamıyor.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            AppButton(
              label: 'Tekrar dene',
              variant: AppButtonVariant.secondary,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRetry,
            ),
            const SizedBox(width: AppSpacing.md),
            AppButton(
              label: 'Soruyu geç',
              variant: AppButtonVariant.ghost,
              onPressed: onSkip,
            ),
          ],
        ),
      ],
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({required this.answer});

  final ExerciseAnswer answer;

  @override
  Widget build(BuildContext context) {
    final correct = answer.isCorrect;
    final heard = answer.selected?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: correct ? AppColors.successSoft : AppColors.destructiveSoft,
        borderRadius: AppRadius.lgAll,
        border: Border.fromBorderSide(
          correct ? AppBorders.sideSuccess : AppBorders.sideDestructive,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: AppSpacing.xxl,
            color: correct ? AppColors.success : AppColors.destructive,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct
                      ? 'Telaffuzun anlaşıldı!'
                      : 'Doğru telaffuz: ${answer.correctAnswer}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                if (heard != null && heard.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Duyduğum: $heard',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ] else if (!correct) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bu soru atlandı.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
