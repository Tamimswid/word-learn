import 'package:flutter/material.dart';

import '../../../../core/design_system/app_assets.dart';

/// Large sign-in illustration with a slow, continuous float.
class AuthHero extends StatefulWidget {
  const AuthHero({super.key});

  @override
  State<AuthHero> createState() => _AuthHeroState();
}

class _AuthHeroState extends State<AuthHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const image = Image(
      image: AssetImage(AppAssets.signIn),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (_reduceMotion) return image;

    return AnimatedBuilder(
      animation: _controller,
      child: image,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -24 * value),
          child: child,
        );
      },
    );
  }
}
