import 'dart:async';

import 'package:ai_wave_animations/ai_wave_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/platform/speech_to_text_service.dart';
import '../../../../core/platform/text_to_speech_service.dart';
import '../../../../core/platform/translation_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../word_management/data/repositories/word_repository.dart';
import '../../data/models/chat_message.dart';
import '../cubit/tutor_cubit.dart';
import '../cubit/tutor_state.dart';
import '../widgets/word_typer.dart';

class AiTutorPage extends StatelessWidget {
  const AiTutorPage({super.key, this.onEndConversation});

  final VoidCallback? onEndConversation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TutorCubit>(
      create: (_) => locator<TutorCubit>()..start(),
      child: _AiTutorView(onEndConversation: onEndConversation),
    );
  }
}

/// Voice stages of the conversation. The mic is never toggled by hand:
/// it closes while the teacher speaks and opens as soon as the teacher stops.
enum _TalkMode { idle, speaking, listening, userSpeaking }

class _AiTutorView extends StatefulWidget {
  const _AiTutorView({this.onEndConversation});

  final VoidCallback? onEndConversation;

  @override
  State<_AiTutorView> createState() => _AiTutorViewState();
}

class _AiTutorViewState extends State<_AiTutorView> {
  static const String _waitingText = '…';

  final WaveController _waveController = WaveController(
    activity: WaveActivity.idle,
  );

  late final TextToSpeechService _speech;
  late final SpeechToTextService _dictation;

  _TalkMode _mode = _TalkMode.idle;
  bool _isTeacherMuted = false;
  bool _isListening = false;
  String _heardText = '';

  /// The teacher sentence currently being spoken; null while the reply is
  /// being awaited or the voice has not started yet, so text never appears
  /// before the audio does.
  String? _speakingText;
  Duration? _speakingDuration;

  /// Arabic translation of the current teacher sentence; null = English.
  String? _sentenceTranslation;
  bool _isTranslatingSentence = false;

  Timer? _pauseTimer;
  Timer? _fallbackTimer;
  int _turnAtListenStart = 0;
  int _listenGeneration = 0;
  String? _lastSpokenText;

  @override
  void initState() {
    super.initState();
    _speech = locator<TextToSpeechService>();
    _dictation = locator<SpeechToTextService>();
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _fallbackTimer?.cancel();
    _waveController.dispose();
    unawaited(_speech.stop());
    unawaited(_dictation.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محادثة مع المعلم'),
        forceMaterialTransparency: true,
      ),
      body: AppAnimatedBackground(
        child: SafeArea(
          child: BlocConsumer<TutorCubit, TutorState>(
            listenWhen: (previous, current) =>
                previous.messages.length != current.messages.length ||
                previous.isTeacherSpeaking != current.isTeacherSpeaking ||
                previous.failure != current.failure ||
                previous.summary != current.summary,
            listener: (context, state) {
              _syncWave();

              if (state.failure != null) {
                _showMessage(state.failure!.message);
                unawaited(_startListening());
              }

              if (state.summary != null) {
                _showSummary(state.summary!);
              }

              final teacher = _latest(state, ChatRole.teacher)?.content;
              if (teacher != null && teacher != _lastSpokenText) {
                _lastSpokenText = teacher;
                unawaited(_startTeacherTurn(teacher));
              }
            },
            builder: (context, state) {
              // The wave lives only while the teacher's voice is playing.
              final waveActive = _mode == _TalkMode.speaking;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.lg,
                      AppSpacing.screen,
                      AppSpacing.xs,
                    ),
                    child: _teacherArea(state),
                  ),
                  Expanded(
                    child: Center(
                      child: LiquidWave(
                        width: 240,
                        height: 240,
                        rimWidth: 2,
                        controller: _waveController,
                        colors: waveActive
                            ? const [AppColors.primary, AppColors.primaryGlow]
                            : const [
                                AppColors.primarySoft,
                                AppColors.primarySoft,
                              ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: _userArea(state),
                  ),
                  _Controls(
                    isTeacherMuted: _isTeacherMuted,
                    onToggleMute: () =>
                        setState(() => _isTeacherMuted = !_isTeacherMuted),
                    onEnd: _endConversation,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static ChatMessage? _latest(TutorState state, ChatRole role) {
    for (var index = state.messages.length - 1; index >= 0; index--) {
      if (state.messages[index].role == role) return state.messages[index];
    }
    return null;
  }

  Widget _teacherArea(TutorState state) {
    final text = _speakingText;

    // Ses başlayana kadar metin gösterilmez; eski cümle de tekrar çıkmaz.
    if (text == null) {
      final failed = state.hasFailed;
      return Text(
        failed ? (state.failure?.message ?? _waitingText) : _waitingText,
        textDirection: failed ? TextDirection.rtl : TextDirection.ltr,
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.mutedForeground,
        ),
      );
    }

    final translation = _sentenceTranslation;
    if (translation != null) {
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Çevriye dokununca orijinal İngilizce geri gelir.
              onTap: () => setState(() => _sentenceTranslation = null),
              child: Text(
                translation,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),
          _translateIcon(onPressed: _translateSentence),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: WordTyper(
            key: ValueKey<String>(text),
            text: text,
            duration: _speakingDuration,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.foreground,
            ),
            wrongWords: [
              for (final correction in state.corrections)
                ...correction.original
                    .trim()
                    .split(RegExp(r'\s+'))
                    .map((word) => word.toLowerCase()),
            ],
            onTap: () => unawaited(_replayTeacher(text)),
            onWordTranslate: _translateWord,
            onWordLongPress: _saveWord,
          ),
        ),
        _translateIcon(onPressed: _translateSentence),
      ],
    );
  }

  Widget _translateIcon({required VoidCallback onPressed}) {
    return IconButton(
      tooltip: 'ترجم الجملة',
      visualDensity: VisualDensity.compact,
      icon: const Icon(
        Icons.translate_rounded,
        size: 18,
        color: AppColors.mutedForeground,
      ),
      onPressed: onPressed,
    );
  }

  Future<String?> _translateWord(String word) async {
    final result = await locator<TranslationService>().translate(word);
    return result.fold((failure) {
      _showMessage(failure.message);
      return null;
    }, (value) => value);
  }

  Future<void> _translateSentence() async {
    final text = _speakingText;
    if (text == null || _isTranslatingSentence) return;

    setState(() => _isTranslatingSentence = true);
    final result = await locator<TranslationService>().translate(text);
    if (!mounted) return;
    setState(() => _isTranslatingSentence = false);

    result.fold(
      (failure) => _showMessage(failure.message),
      (value) => setState(() => _sentenceTranslation = value),
    );
  }

  Future<void> _saveWord(String word) async {
    _showMessage('يتم إضافة الكلمة…');

    final result = await locator<WordRepository>().generateWord(word);
    if (!mounted) return;

    result.fold(
      (failure) => _showMessage(failure.message),
      (_) => _showMessage('تمت إضافة "$word" إلى قائمة كلماتك.'),
    );
  }

  Widget _userArea(TutorState state) {
    if (!state.isReady) {
      return AppButton(
        label: 'إعادة المحاولة',
        variant: AppButtonVariant.secondary,
        onPressed: () => context.read<TutorCubit>().start(),
      );
    }

    final heard = _heardText.trim();
    final hint = _isListening ? 'أستمع إليك…' : 'تكلم الآن وسيرد عليك المعلم';

    if (heard.isNotEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          heard,
          key: ValueKey<String>(heard),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.foreground),
        ),
      );
    }

    return Text(
      hint,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.mutedForeground),
    );
  }

  /// The wave is alive only while the teacher's voice is actually playing.
  void _syncWave() {
    _waveController.activity = _mode == _TalkMode.speaking
        ? WaveActivity.speaking
        : WaveActivity.idle;
  }

  Future<void> _startTeacherTurn(String text) async {
    _pauseTimer?.cancel();
    _fallbackTimer?.cancel();
    _listenGeneration++;

    if (_isListening || _dictation.isListening) {
      await _dictation.cancel();
    }
    if (!mounted) return;

    setState(() {
      _mode = _TalkMode.speaking;
      _isListening = false;
      _heardText = '';
      _speakingText = null;
      _speakingDuration = null;
      _sentenceTranslation = null;
    });
    _syncWave();

    await _speakTeacher(text);
    if (!mounted) return;

    // TTS kuyruğu tamamen bitmeden mikrofon açılmaz; son ses yakalanmasın.
    await Future<void>.delayed(SpeechToTextConfig.conversation.micOpenDelay);
    if (!mounted) return;

    await _startListening();
  }

  Future<void> _speakTeacher(String text) async {
    if (_isTeacherMuted) {
      if (mounted) {
        // Sessiz modda ses olmayacağı için metin hemen gösterilir.
        setState(() {
          _speakingText = text;
          _speakingDuration = null;
        });
      }
      return;
    }

    _waveController.activity = WaveActivity.speaking;

    await _speech.speak(
      text,
      onStarted: (audioDuration) {
        if (!mounted) return;
        setState(() {
          _speakingText = text;
          _speakingDuration = audioDuration > Duration.zero
              ? audioDuration
              : null;
        });
      },
    );

    if (!mounted) return;
  }

  Future<void> _replayTeacher(String text) async {
    if (_mode == _TalkMode.speaking) {
      return;
    }

    await _startTeacherTurn(text);
  }

  Future<void> _startListening() async {
    if (!mounted) return;

    final state = context.read<TutorCubit>().state;
    if (!state.isReady || state.isTeacherSpeaking || state.isEnded) {
      return;
    }
    if (_isListening || _dictation.isListening) return;

    final generation = _listenGeneration;
    _turnAtListenStart = state.turnCount;
    setState(() {
      _mode = _TalkMode.listening;
      _heardText = '';
    });
    _syncWave();

    final result = await _dictation.start(
      onPartial: _onUserActivity,
      onFinal: _onFinalWords,
      onListeningChanged: _onListeningChanged,
      onSoundLevel: _onSoundLevel,
      onFailure: _onDictationFailure,
    );

    if (!mounted) return;

    // The teacher may have started talking while the session was opening.
    final stateAfter = context.read<TutorCubit>().state;
    if (generation != _listenGeneration ||
        _mode == _TalkMode.speaking ||
        stateAfter.isTeacherSpeaking ||
        stateAfter.isEnded) {
      await _dictation.cancel();
      return;
    }

    if (result.isLeft()) {
      _showMessage(result.fold((failure) => failure.message, (_) => ''));
      if (!mounted) return;
      setState(() => _mode = _TalkMode.idle);
      _syncWave();
    }
  }

  void _onUserActivity(String words) {
    if (!mounted || _mode == _TalkMode.speaking) return;

    _resetPauseTimer();

    if (_heardText != words || _mode != _TalkMode.userSpeaking) {
      setState(() {
        _heardText = words;
        _mode = _TalkMode.userSpeaking;
      });
      _syncWave();
    }
  }

  void _onSoundLevel(double level) {
    if (!mounted ||
        _mode == _TalkMode.speaking ||
        level < SpeechToTextConfig.conversation.soundLevelThreshold) {
      return;
    }

    _resetPauseTimer();

    if (_mode != _TalkMode.userSpeaking) {
      setState(() => _mode = _TalkMode.userSpeaking);
      _syncWave();
    }
  }

  void _onListeningChanged(bool listening) {
    if (!mounted) return;
    setState(() => _isListening = listening);
  }

  void _onFinalWords(String words) {
    if (_mode == _TalkMode.speaking) {
      return;
    }

    unawaited(_finalizeWords(words));
  }

  void _onDictationFailure(Failure failure) {
    _pauseTimer?.cancel();
    _fallbackTimer?.cancel();
    if (!mounted || _mode == _TalkMode.speaking) return;

    if (failure.code == 'error_no_match') {
      unawaited(_restartListening());
      return;
    }

    setState(() => _mode = _TalkMode.idle);
    _syncWave();
    _showMessage(failure.message);
  }

  void _resetPauseTimer() {
    _pauseTimer?.cancel();
    _pauseTimer = Timer(SpeechToTextConfig.conversation.sendAfterPause, () {
      if (!mounted || !_isListening) return;

      final words = _heardText.trim();
      if (words.isEmpty) {
        setState(() => _mode = _TalkMode.listening);
        _syncWave();
        return;
      }

      unawaited(_dictation.stop());

      // Some platforms never deliver a final result after stop().
      _fallbackTimer?.cancel();
      _fallbackTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        final state = context.read<TutorCubit>().state;
        if (state.turnCount == _turnAtListenStart && !state.isTeacherSpeaking) {
          unawaited(_finalizeWords(_heardText));
        }
      });
    });
  }

  Future<void> _finalizeWords(String words) async {
    _pauseTimer?.cancel();
    _fallbackTimer?.cancel();

    // The mic must be fully closed before the message goes out, so the
    // teacher's answer is never recorded.
    if (_isListening || _dictation.isListening) {
      await _dictation.cancel();
    }

    final text = words.trim();
    if (!mounted) return;

    final cubit = context.read<TutorCubit>();
    setState(() {
      _heardText = '';
      _isListening = false;
      _mode = _TalkMode.idle;
      _speakingText = null;
      _speakingDuration = null;
      _sentenceTranslation = null;
    });
    _syncWave();

    if (text.isEmpty) {
      unawaited(_restartListening());
      return;
    }

    cubit.send(text);
  }

  Future<void> _restartListening() async {
    if (_isListening || _dictation.isListening) {
      await _dictation.cancel();
    }
    if (!mounted) return;
    await _startListening();
  }

  void _endConversation() {
    final cubit = context.read<TutorCubit>();

    _pauseTimer?.cancel();
    _fallbackTimer?.cancel();
    _listenGeneration++;
    if (_isListening) unawaited(_dictation.cancel());
    setState(() {
      _isListening = false;
      _heardText = '';
      _mode = _TalkMode.idle;
    });

    // Nothing to summarise before the learner has said anything.
    if (cubit.state.turnCount == 0) {
      widget.onEndConversation?.call();
      return;
    }

    unawaited(cubit.finish());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSummary(String summary) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sheet,
          AppSpacing.xxl,
          AppSpacing.sheet,
          AppSpacing.sheet + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الدرس',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  summary,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.secondaryForeground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'إغلاق',
              expanded: true,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                widget.onEndConversation?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.isTeacherMuted,
    required this.onToggleMute,
    required this.onEnd,
  });

  final bool isTeacherMuted;
  final VoidCallback onToggleMute;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.xxl,
        AppSpacing.screen,
        AppSpacing.xxl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            button: true,
            label: isTeacherMuted ? 'تشغيل صوت المعلم' : 'كتم صوت المعلم',
            child: AppIconButton(
              tooltip: isTeacherMuted ? 'تشغيل صوت المعلم' : 'كتم صوت المعلم',
              icon: Icon(
                isTeacherMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
              ),
              size: AppSpacing.giant,
              isSelected: isTeacherMuted,
              onPressed: onToggleMute,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          AppIconButton(
            tooltip: 'إنهاء المحادثة',
            icon: const Icon(Icons.close_rounded),
            size: AppSpacing.giant,
            onPressed: onEnd,
          ),
        ],
      ),
    );
  }
}
