import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/router/app_route.dart';
import '../../../../core/state/load_status.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/deck_cubit.dart';
import '../cubit/deck_state.dart';
import '../widgets/deck_stack.dart';

class DeckPage extends StatelessWidget {
  const DeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeckCubit>(
      create: (_) => locator<DeckCubit>()..load(),
      child: const _DeckView(),
    );
  }
}

class _DeckView extends StatelessWidget {
  const _DeckView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          gradient: AppGradients.glow,
        ),
        child: SafeArea(
          child: BlocConsumer<DeckCubit, DeckState>(
            listenWhen: (previous, current) =>
                previous.isFinished != current.isFinished ||
                (current.failure != null &&
                    current.failure != previous.failure &&
                    current.status == LoadStatus.success),
            listener: (context, state) {
              if (state.isFinished) {
                final seeds = state.unknownWords
                    .map((word) => word.id)
                    .toList(growable: false);
                if (seeds.length > 1) {
                  context.goNamed(AppRoute.exercise.name, extra: seeds);
                } else {
                  context.goNamed(AppRoute.home.name);
                }
                return;
              }

              final failure = state.failure;
              if (failure != null) _showFailure(context, failure.message);
            },
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.sm,
                      AppSpacing.screen,
                      0,
                    ),
                    child: _DeckHeader(
                      progress: state.total == 0
                          ? 0
                          : state.index / state.total,
                      position: state.position.clamp(0, state.total),
                      total: state.total,
                      onClose: () => context.goNamed(AppRoute.home.name),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screen,
                          ),
                          child: _buildBody(context, state),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DeckState state) {
    if (state.status == LoadStatus.idle ||
        state.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == LoadStatus.failure) {
      return _DeckError(message: state.failure?.message);
    }

    if (state.current == null) return const SizedBox.shrink();

    return DeckStack(
      words: state.words.sublist(state.index),
      onAnswer: (known) => context.read<DeckCubit>().answer(known: known),
    );
  }

  void _showFailure(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.progress,
    required this.position,
    required this.total,
    required this.onClose,
  });

  final double progress;
  final int position;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AppIconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Kapat',
              variant: AppIconButtonVariant.ghost,
              size: AppSpacing.xxxl,
              onPressed: onClose,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Bugünün kartları',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    total == 0 ? 'Hazırlanıyor' : '$position / $total',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xxxl),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: AppRadius.pillAll,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(value: value);
            },
          ),
        ),
      ],
    );
  }
}

class _DeckError extends StatelessWidget {
  const _DeckError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            'Kartlar yüklenemedi',
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
            onPressed: () => context.read<DeckCubit>().load(),
          ),
        ],
      ),
    );
  }
}
