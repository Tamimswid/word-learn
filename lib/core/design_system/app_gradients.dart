import 'package:flutter/widgets.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  /// Violet halo used behind onboarding and completion screens.
  static const RadialGradient glow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.1,
    colors: [Color(0x475D69CB), AppColors.transparent],
    stops: [0, 0.75],
  );
}
