import 'package:flutter/widgets.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  /// Soft lift used by learning cards.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -12,
    ),
  ];

  static const List<BoxShadow> none = [];
}
