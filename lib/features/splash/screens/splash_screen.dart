import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_design.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _introController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return Scaffold(
      body: ScholarScaffoldBackground(
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_introController, _orbitController]),
              builder: (context, child) {
                final intro = Curves.easeOutCubic.transform(
                  _introController.value,
                );
                final pulse =
                    1 + math.sin(_orbitController.value * math.pi * 2) * 0.035;

                return Opacity(
                  opacity: intro,
                  child: Transform.translate(
                    offset: Offset(0, (1 - intro) * 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: pulse,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 156,
                                height: 156,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(38),
                                  border: Border.all(
                                    color: palette.brandEnd
                                        .withValues(alpha: 0.55),
                                  ),
                                  gradient: palette.panelGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: palette.brandStart
                                          .withValues(alpha: 0.34),
                                      blurRadius: 44,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(23),
                                  child: Image.asset(
                                    scholarThemeIconAsset(context),
                                  ),
                                ),
                              ),
                              for (final spark in _sparks)
                                Positioned(
                                  left: spark.left,
                                  top: spark.top,
                                  child: Transform.rotate(
                                    angle: _orbitController.value *
                                            math.pi *
                                            2 +
                                        spark.rotation,
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: spark.size,
                                      color: spark.color == _SparkColor.accent
                                          ? palette.accent
                                          : palette.brandEnd,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Gap(28),
                        const ScholarBrand(logoSize: 34),
                        const Gap(18),
                        SizedBox(
                          width: 180,
                          child: ScholarProgressBar(
                            value: _introController.value,
                            height: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

const _sparks = [
  _Spark(-18, 12, 18, _SparkColor.accent, 0),
  _Spark(140, 22, 14, _SparkColor.brand, 0.5),
  _Spark(122, -18, 24, _SparkColor.accent, 0.1),
  _Spark(8, 134, 13, _SparkColor.brand, 0.4),
];

class _Spark {
  const _Spark(
    this.left,
    this.top,
    this.size,
    this.color,
    this.rotation,
  );

  final double left;
  final double top;
  final double size;
  final _SparkColor color;
  final double rotation;
}

enum _SparkColor { accent, brand }
