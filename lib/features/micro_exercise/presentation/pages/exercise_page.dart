import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/router/app_route.dart';
import '../../../../core/state/load_status.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/exercise_item.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/exercise_state.dart';
import '../widgets/exercise_footer.dart';
import '../widgets/exercise_header.dart';
import '../widgets/exercise_item_view.dart';
import '../widgets/exercise_meta.dart';
import '../widgets/exercise_meta_pill.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key, required this.seedIds});

  final List<String> seedIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExerciseCubit>(
      create: (_) => locator<ExerciseCubit>()..load(seedIds: seedIds),
      child: _ExerciseView(seedIds: seedIds),
    );
  }
}

class _ExerciseView extends StatelessWidget {
  const _ExerciseView({required this.seedIds});

  final List<String> seedIds;

  static const Duration _quickFeedback = Duration(milliseconds: 900);
  static const Duration _readingFeedback = Duration(milliseconds: 1600);
  static const Duration _matchingFeedback = Duration(milliseconds: 550);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ExerciseCubit, ExerciseState>(
          listenWhen: (previous, current) =>
              previous.isFinished != current.isFinished ||
              (previous.answer != current.answer && current.answer != null),
          listener: (context, state) {
            if (state.isFinished) {
              context.goNamed(AppRoute.home.name);
              return;
            }

            if (state.answer != null) {
              _scheduleNext(context, state.current?.type);
            }
          },
          builder: (context, state) {
            if (state.status == LoadStatus.idle ||
                state.status == LoadStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == LoadStatus.failure) {
              return _ExerciseError(
                message: state.failure?.message,
                onRetry: () =>
                    context.read<ExerciseCubit>().load(seedIds: seedIds),
              );
            }

            final item = state.current;
            if (item == null) return const SizedBox.shrink();

            return _ExerciseShell(state: state, item: item);
          },
        ),
      ),
    );
  }

  void _scheduleNext(BuildContext context, ExerciseType? type) {
    final delay = switch (type) {
      ExerciseType.spelling || ExerciseType.sentence => _readingFeedback,
      ExerciseType.matching => _matchingFeedback,
      _ => _quickFeedback,
    };

    Future<void>.delayed(delay, () {
      if (!context.mounted) return;
      final cubit = context.read<ExerciseCubit>();
      if (!cubit.isClosed) cubit.next();
    });
  }
}

class _ExerciseShell extends StatelessWidget {
  const _ExerciseShell({required this.state, required this.item});

  final ExerciseState state;
  final ExerciseItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExerciseHeader(
          title: item.type.title,
          position: state.position,
          total: state.total,
          progress: state.progress,
          onBack: () => context.goNamed(AppRoute.home.name),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xxl,
              AppSpacing.screen,
              AppSpacing.lg,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExerciseMetaPill(
                      level: item.type.level,
                      duration: item.type.duration,
                    ),
                    const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),
                    KeyedSubtree(
                      key: ValueKey<int>(state.index),
                      child: ExerciseItemView(item: item, answer: state.answer),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const ExerciseFooter(),
      ],
    );
  }
}

class _ExerciseError extends StatelessWidget {
  const _ExerciseError({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExerciseHeader(
          title: 'Alıştırma',
          position: 0,
          total: 0,
          progress: 0,
          onBack: () => context.goNamed(AppRoute.home.name),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: AppSpacing.huge,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Alıştırma hazırlanamadı',
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
          ),
        ),
      ],
    );
  }
}
