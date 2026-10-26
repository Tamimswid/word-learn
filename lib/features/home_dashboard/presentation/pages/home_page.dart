import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/platform/process_text_service.dart';
import '../../../../core/router/app_route.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../word_management/presentation/dialogs/add_word_dialog.dart';
import '../../data/models/home_snapshot.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../sheets/home_settings_sheet.dart';
import '../widgets/home_header.dart';
import '../widgets/learning_rhythm_card.dart';
// import '../widgets/quick_practice_section.dart';
import '../widgets/recent_words_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => locator<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final ProcessTextService _processText = locator<ProcessTextService>();

  @override
  void initState() {
    super.initState();
    _processText.addListener(_handleProcessText);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleProcessText());
  }

  @override
  void dispose() {
    _processText.removeListener(_handleProcessText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<HomeCubit, HomeState>(
          listenWhen: (previous, current) =>
              previous.failure != current.failure && current.failure != null,
          listener: _showLoadFailure,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final snapshot = state.snapshot;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.md,
                  AppSpacing.screen,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.user != current.user,
                      builder: (context, state) => HomeHeader(
                        greetingName: state.firstName,
                        streakDays: snapshot.streakDays,
                        dailyLoginCount: snapshot.dailyLoginCount,
                        onOpenSettings: () => _openSettings(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    LearningRhythmCard(snapshot: snapshot),
                    const SizedBox(height: AppSpacing.xl),
                    AppAddButton(
                      expanded: true,
                      onPressed: () => _addWord(context),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Quick practice is temporarily hidden. The original
                    // widget and route wiring are kept below for re-enabling.
                    // QuickPracticeSection(
                    //   onSeeAll: () => _openExercise(context),
                    //   onLevelTap: () => _openExercise(context),
                    // ),
                    // const SizedBox(height: AppSpacing.xl),
                    RecentWordsSection(
                      words: snapshot.recentWords,
                      isLoading: state.isLoading,
                      onSeeAll: () => _openAllWords(context),
                      onDeleted: (word) => _removeWord(context, word),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLoadFailure(BuildContext context, HomeState state) {
    final failure = state.failure;
    if (failure == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: SnackBarAction(
            label: 'Tekrar dene',
            onPressed: () => context.read<HomeCubit>().load(),
          ),
        ),
      );
  }

  Future<void> _openSettings(BuildContext context) async {
    final snapshot = context.read<HomeCubit>().state.snapshot;

    final result = await showHomeSettingsSheet(
      context,
      initialSessionSize: snapshot.sessionSize,
    );
    if (!context.mounted || result == null) return;

    if (result.sessionSize != snapshot.sessionSize) {
      final failure = await context.read<HomeCubit>().updateSessionSize(
        result.sessionSize,
      );
      if (!context.mounted) return;

      _showMessage(
        context,
        failure?.message ??
            'Oturum başına ${result.sessionSize} kelime olarak kaydedildi.',
      );
      return;
    }

    if (result.reminderSaved) {
      _showMessage(context, 'Günlük hatırlatıcı güncellendi.');
    }
  }

  // void _openExercise(BuildContext context) {
  //   context.pushNamed(AppRoute.exercise.name);
  // }

  void _openAllWords(BuildContext context) {
    context.pushNamed(AppRoute.words.name);
  }

  Future<void> _handleProcessText() async {
    if (!mounted) return;

    final word = _processText.takePendingWord();
    if (word == null) return;

    await _addWord(context, initialWord: word);
  }

  Future<void> _addWord(BuildContext context, {String? initialWord}) async {
    final entry = await showAddWordDialog(context, initialWord: initialWord);
    if (!context.mounted || entry == null) return;

    context.read<HomeCubit>().addWord(
      LearnedWord(
        id: entry.id,
        word: entry.word,
        translation: entry.translation,
        exampleSentence: entry.exampleSentence,
        sentenceTranslation: entry.sentenceTranslation,
        arabicSentence: entry.arabicSentence,
        wordIndex: entry.wordIndex,
        createdAt: entry.createdAt,
      ),
    );
  }

  Future<void> _removeWord(BuildContext context, LearnedWord word) async {
    final failure = await context.read<HomeCubit>().deleteWord(word);
    if (!context.mounted || failure == null) return;

    _showMessage(context, failure.message);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
