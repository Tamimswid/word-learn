import 'package:flutter/material.dart';

import 'app_button.dart';

/// Primary add action shared across features.
class AppAddButton extends StatelessWidget {
  const AppAddButton({
    super.key,
    required this.onPressed,
    this.label = 'Kelime ekle',
    this.expanded = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      variant: AppButtonVariant.primary,
      expanded: expanded,
      icon: const Icon(Icons.add_rounded),
      onPressed: onPressed,
    );
  }
}
