import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Hairline borders used across cards, inputs and outlined controls.
abstract final class AppBorders {
  static const double width = 1;

  static const BorderSide side = BorderSide(
    color: AppColors.border,
    width: width,
  );

  static const BorderSide sideStrong = BorderSide(
    color: AppColors.borderStrong,
    width: width,
  );

  static const BorderSide sidePrimary = BorderSide(
    color: AppColors.primaryBorder,
    width: width,
  );

  static const BorderSide sideSuccess = BorderSide(
    color: AppColors.successBorder,
    width: width,
  );

  static const BorderSide sideDestructive = BorderSide(
    color: AppColors.destructiveBorder,
    width: width,
  );

  static const BorderSide none = BorderSide.none;

  static const Border all = Border(
    top: side,
    right: side,
    bottom: side,
    left: side,
  );

  static const Border bottom = Border(bottom: side);
}
