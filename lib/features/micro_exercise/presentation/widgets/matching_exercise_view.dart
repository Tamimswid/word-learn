import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/models/exercise_item.dart';
import '../cubit/exercise_state.dart';

class MatchingExerciseView extends StatefulWidget {
  const MatchingExerciseView({
    super.key,
    required this.item,
    required this.answer,
    required this.onCompleted,
  });

  final MatchingExercise item;
  final ExerciseAnswer? answer;
  final void Function({required bool hadMistake}) onCompleted;

  @override
  State<MatchingExerciseView> createState() => _MatchingExerciseViewState();
}

class _MatchingExerciseViewState extends State<MatchingExerciseView> {
  static const Duration _wrongResetDelay = Duration(milliseconds: 450);
  static const Duration _completionDelay = Duration(milliseconds: 250);

  late final List<_MatchTile> _tiles;
  final Set<String> _matchedPairIds = <String>{};
  final Set<int> _wrongTiles = <int>{};
  Timer? _wrongTimer;
  int? _selectedIndex;
  bool _hadMistake = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _tiles = <_MatchTile>[
      for (final pair in widget.item.pairs) ...[
        _MatchTile(pairId: pair.wordId, label: pair.word, isWord: true),
        _MatchTile(pairId: pair.wordId, label: pair.translation, isWord: false),
      ],
    ]..shuffle();
  }

  @override
  void dispose() {
    _wrongTimer?.cancel();
    super.dispose();
  }

  void _select(int index) {
    if (widget.answer != null ||
        _completed ||
        _matchedPairIds.contains(_tiles[index].pairId)) {
      return;
    }

    if (_selectedIndex == index) {
      setState(() => _selectedIndex = null);
      return;
    }

    final selectedIndex = _selectedIndex;
    if (selectedIndex == null) {
      setState(() => _selectedIndex = index);
      return;
    }

    final first = _tiles[selectedIndex];
    final second = _tiles[index];
    final isPair =
        first.pairId == second.pairId && first.isWord != second.isWord;

    if (isPair) {
      setState(() {
        _matchedPairIds.add(first.pairId);
        _selectedIndex = null;
        _completed = _matchedPairIds.length == widget.item.pairs.length;
      });

      if (_completed) {
        Future<void>.delayed(_completionDelay, () {
          if (!mounted) return;
          widget.onCompleted(hadMistake: _hadMistake);
        });
      }
      return;
    }

    _hadMistake = true;
    _wrongTimer?.cancel();
    setState(() {
      _wrongTiles
        ..clear()
        ..addAll(<int>[selectedIndex, index]);
      _selectedIndex = null;
    });
    _wrongTimer = Timer(_wrongResetDelay, () {
      if (!mounted) return;
      setState(() => _wrongTiles.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eşlerini bul.',
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.huge),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisExtent: AppSpacing.huge * 2,
          ),
          itemBuilder: (context, index) {
            final tile = _tiles[index];
            return _MatchTileButton(
              label: tile.label,
              state: _stateFor(index),
              onTap: widget.answer == null ? () => _select(index) : null,
            );
          },
        ),
      ],
    );
  }

  _MatchTileState _stateFor(int index) {
    final tile = _tiles[index];
    if (_matchedPairIds.contains(tile.pairId)) return _MatchTileState.matched;
    if (_wrongTiles.contains(index)) return _MatchTileState.wrong;
    if (_selectedIndex == index) return _MatchTileState.selected;
    return _MatchTileState.idle;
  }
}

class _MatchTile {
  const _MatchTile({
    required this.pairId,
    required this.label,
    required this.isWord,
  });

  final String pairId;
  final String label;
  final bool isWord;
}

enum _MatchTileState { idle, selected, matched, wrong }

class _MatchTileButton extends StatelessWidget {
  const _MatchTileButton({
    required this.label,
    required this.state,
    this.onTap,
  });

  final String label;
  final _MatchTileState state;
  final VoidCallback? onTap;

  Color get _background => switch (state) {
    _MatchTileState.idle => AppColors.secondary,
    _MatchTileState.selected => AppColors.primarySoft,
    _MatchTileState.matched => AppColors.successSoft,
    _MatchTileState.wrong => AppColors.destructiveSoft,
  };

  Color get _foreground => switch (state) {
    _MatchTileState.idle => AppColors.secondaryForeground,
    _MatchTileState.selected => AppColors.primaryGlow,
    _MatchTileState.matched => AppColors.success,
    _MatchTileState.wrong => AppColors.destructive,
  };

  BorderSide get _border => switch (state) {
    _MatchTileState.idle => BorderSide.none,
    _MatchTileState.selected => AppBorders.sidePrimary,
    _MatchTileState.matched => AppBorders.sideSuccess,
    _MatchTileState.wrong => AppBorders.sideDestructive,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _background,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: _border,
      ),
      child: InkWell(
        onTap: onTap,
        overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(color: _foreground),
            ),
          ),
        ),
      ),
    );
  }
}
