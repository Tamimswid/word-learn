import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/router/app_route.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../data/models/home_snapshot.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../dialogs/add_word_dialog.dart';
import '../sheets/session_size_sheet.dart';
import '../../../reminder/presentation/sheets/reminder_sheet.dart';
import '../widgets/home_header.dart';
import '../widgets/learning_rhythm_card.dart';
import '../widgets/quick_practice_section.dart';
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

class _HomeView extends StatelessWidget {
  const _HomeView();

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
                        onOpenSettings: () => _openSessionSettings(context),
                        onOpenReminder: () => _openReminder(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    LearningRhythmCard(snapshot: snapshot),
                    const SizedBox(height: AppSpacing.xl),
                    QuickPracticeSection(
                      onSeeAll: () => _openExercise(context),
                      onLevelTap: () => _openExercise(context),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    RecentWordsSection(
                      words: snapshot.recentWords,
                      isLoading: state.isLoading,
                      onAdd: () => _addWord(context),
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

  Future<void> _openSessionSettings(BuildContext context) async {
    final snapshot = context.read<HomeCubit>().state.snapshot;

    final value = await showSessionSizeSheet(
      context,
      initialValue: snapshot.sessionSize,
    );
    if (!context.mounted || value == null) return;

    final failure = await context.read<HomeCubit>().updateSessionSize(value);
    if (!context.mounted) return;

    _showMessage(
      context,
      failure?.message ?? 'Oturum başına $value kelime olarak kaydedildi.',
    );
  }

  void _openExercise(BuildContext context) {
    context.pushNamed(AppRoute.exercise.name);
  }

  Future<void> _openReminder(BuildContext context) async {
    final saved = await showReminderSheet(context);
    if (!context.mounted || saved != true) return;

    _showMessage(context, 'Günlük hatırlatıcı güncellendi.');
  }

  Future<void> _addWord(BuildContext context) async {
    final word = await showAddWordDialog(context);
    if (!context.mounted || word == null) return;

    context.read<HomeCubit>().addWord(word);
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
