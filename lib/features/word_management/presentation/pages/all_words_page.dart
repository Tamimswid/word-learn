import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/state/load_status.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../reminder/reminder.dart';
import '../cubit/word_list_cubit.dart';
import '../cubit/word_list_state.dart';
import '../dialogs/add_word_dialog.dart';
import '../dialogs/delete_word_dialog.dart';
import '../widgets/word_card.dart';

class AllWordsPage extends StatelessWidget {
  const AllWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WordListCubit>(
      create: (_) => locator<WordListCubit>()..load(),
      child: const _AllWordsView(),
    );
  }
}

class _AllWordsView extends StatelessWidget {
  const _AllWordsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tüm kelimeler')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addWord(context),
        tooltip: 'Kelime ekle',
        child: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<WordListCubit, WordListState>(
        listenWhen: (previous, current) =>
            previous.actionFailure != current.actionFailure &&
            current.actionFailure != null,
        listener: (context, state) {
          _showMessage(context, state.actionFailure!.message);
        },
        builder: (context, state) => _WordsBody(state: state),
      ),
    );
  }

  Future<void> _addWord(BuildContext context) async {
    final entry = await showAddWordDialog(context);
    if (!context.mounted || entry == null) return;

    context.read<WordListCubit>().addWord(entry);
    unawaited(locator<ReminderRepository>().reschedule());
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WordsBody extends StatefulWidget {
  const _WordsBody({required this.state});

  final WordListState state;

  @override
  State<_WordsBody> createState() => _WordsBodyState();
}

class _WordsBodyState extends State<_WordsBody> {
  static const double _loadMoreExtent = AppSpacing.huge * 8;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.status == LoadStatus.idle || state.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == LoadStatus.failure) {
      return _WordsError(
        message: state.failure?.message,
        onRetry: () => context.read<WordListCubit>().load(),
      );
    }

    if (state.words.isEmpty) return const _WordsEmpty();

    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.giant + AppSpacing.huge,
      ),
      itemCount: state.words.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index >= state.words.length) return const _PageLoader();

        final word = state.words[index];

        return Dismissible(
          key: ValueKey<String>(word.id),
          direction: DismissDirection.endToStart,
          background: const _DeleteBackground(),
          confirmDismiss: (_) => showDeleteWordDialog(context, word.word),
          onDismissed: (_) async {
            await context.read<WordListCubit>().deleteWord(word);
            unawaited(locator<ReminderRepository>().reschedule());
          },
          child: WordCard(word: word),
        );
      },
    );
  }

  void _handleScroll() {
    if (!_controller.hasClients) return;
    if (_controller.position.extentAfter > _loadMoreExtent) return;

    context.read<WordListCubit>().loadMore();
  }
}

class _PageLoader extends StatelessWidget {
  const _PageLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.destructiveSoft,
        borderRadius: AppRadius.xlAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            size: AppSpacing.lg,
            color: AppColors.destructive,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Sil',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.destructive,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordsEmpty extends StatelessWidget {
  const _WordsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.empty,
              width: AppSpacing.huge * 4,
              height: AppSpacing.huge * 4,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Henüz kelime yok',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sağ alttaki ekle butonuyla ilk kelimeni ekleyebilirsin.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordsError extends StatelessWidget {
  const _WordsError({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: AppSpacing.huge,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Kelimeler yüklenemedi',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Tekrar dene',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
