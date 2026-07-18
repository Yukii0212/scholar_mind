import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../constants/app_assets.dart';

class ScholarPalette extends ThemeExtension<ScholarPalette> {
  const ScholarPalette({
    required this.brandStart,
    required this.brandEnd,
    required this.accent,
    required this.canvas,
    required this.canvasDeep,
    required this.panel,
    required this.panelStrong,
    required this.stroke,
    required this.textMuted,
    required this.success,
    required this.warning,
  });

  final Color brandStart;
  final Color brandEnd;
  final Color accent;
  final Color canvas;
  final Color canvasDeep;
  final Color panel;
  final Color panelStrong;
  final Color stroke;
  final Color textMuted;
  final Color success;
  final Color warning;

  LinearGradient get brandGradient => LinearGradient(
        colors: [brandStart, brandEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get panelGradient => LinearGradient(
        colors: [panelStrong, panel],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  ScholarPalette copyWith({
    Color? brandStart,
    Color? brandEnd,
    Color? accent,
    Color? canvas,
    Color? canvasDeep,
    Color? panel,
    Color? panelStrong,
    Color? stroke,
    Color? textMuted,
    Color? success,
    Color? warning,
  }) {
    return ScholarPalette(
      brandStart: brandStart ?? this.brandStart,
      brandEnd: brandEnd ?? this.brandEnd,
      accent: accent ?? this.accent,
      canvas: canvas ?? this.canvas,
      canvasDeep: canvasDeep ?? this.canvasDeep,
      panel: panel ?? this.panel,
      panelStrong: panelStrong ?? this.panelStrong,
      stroke: stroke ?? this.stroke,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  ScholarPalette lerp(
    ThemeExtension<ScholarPalette>? other,
    double t,
  ) {
    if (other is! ScholarPalette) return this;

    return ScholarPalette(
      brandStart: Color.lerp(brandStart, other.brandStart, t)!,
      brandEnd: Color.lerp(brandEnd, other.brandEnd, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      canvasDeep: Color.lerp(canvasDeep, other.canvasDeep, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panelStrong: Color.lerp(panelStrong, other.panelStrong, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension ScholarThemeContext on BuildContext {
  ScholarPalette get scholarPalette =>
      Theme.of(this).extension<ScholarPalette>() ?? ScholarPalettes.midnight;
}

class ScholarPalettes {
  const ScholarPalettes._();

  static const midnight = ScholarPalette(
    brandStart: Color(0xFF2556EB),
    brandEnd: Color(0xFF7A5CFF),
    accent: Color(0xFFFFD577),
    canvas: Color(0xFF050913),
    canvasDeep: Color(0xFF020511),
    panel: Color(0xFF0A1224),
    panelStrong: Color(0xFF101A34),
    stroke: Color(0xFF233052),
    textMuted: Color(0xFF9AA7C7),
    success: Color(0xFF2EE59D),
    warning: Color(0xFFFFC857),
  );

  static const scholarBlue = ScholarPalette(
    brandStart: Color(0xFF2556EB),
    brandEnd: Color(0xFF80B7FF),
    accent: Color(0xFFFFCE7A),
    canvas: Color(0xFFF5F8FF),
    canvasDeep: Color(0xFFEAF1FF),
    panel: Color(0xFFFFFFFF),
    panelStrong: Color(0xFFF2F6FF),
    stroke: Color(0xFFD9E4FF),
    textMuted: Color(0xFF64708E),
    success: Color(0xFF18A874),
    warning: Color(0xFFE6A300),
  );

  static const sakuraPink = ScholarPalette(
    brandStart: Color(0xFFEB3B8C),
    brandEnd: Color(0xFFFF9FCC),
    accent: Color(0xFFFFD577),
    canvas: Color(0xFF080711),
    canvasDeep: Color(0xFF03030B),
    panel: Color(0xFF120C1E),
    panelStrong: Color(0xFF21122F),
    stroke: Color(0xFF3C254D),
    textMuted: Color(0xFFC1AFCB),
    success: Color(0xFF2EE59D),
    warning: Color(0xFFFFC857),
  );
}

class ScholarScaffoldBackground extends StatelessWidget {
  const ScholarScaffoldBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.canvas, palette.canvasDeep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _AmbientGlow(
              color: palette.brandStart.withValues(alpha: 0.18),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -160,
            left: -90,
            child: _AmbientGlow(
              color: palette.brandEnd.withValues(alpha: 0.12),
              size: 300,
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class ScholarPanel extends StatelessWidget {
  const ScholarPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.borderRadius = 8,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: palette.stroke.withValues(alpha: 0.78)),
        gradient: palette.panelGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class ScholarIconBadge extends StatelessWidget {
  const ScholarIconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 36,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final badgeColor = color ?? palette.brandStart;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            badgeColor,
            Color.alphaBlend(Colors.white.withValues(alpha: 0.14), badgeColor),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.54,
      ),
    );
  }
}

class ScholarBrand extends StatelessWidget {
  const ScholarBrand({
    super.key,
    this.compact = false,
    this.logoSize = 28,
  });

  final bool compact;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _themeIcon(context),
          width: logoSize,
          height: logoSize,
        ),
        const Gap(8),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
            children: [
              const TextSpan(text: 'Scholar'),
              TextSpan(
                text: 'Mind',
                style: TextStyle(color: context.scholarPalette.brandEnd),
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const Gap(8),
          Text(
            'Organize. Understand. Succeed.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.scholarPalette.textMuted,
                ),
          ),
        ],
      ],
    );
  }
}

class ScholarSectionHeader extends StatelessWidget {
  const ScholarSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (subtitle != null) ...[
                const Gap(4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.scholarPalette.textMuted,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ScholarProgressBar extends StatelessWidget {
  const ScholarProgressBar({
    super.key,
    required this.value,
    this.height = 7,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: palette.stroke.withValues(alpha: 0.6),
        valueColor: AlwaysStoppedAnimation<Color>(palette.brandStart),
      ),
    );
  }
}

class ScholarIllustration extends StatefulWidget {
  const ScholarIllustration({
    super.key,
    this.size = 150,
    this.animate = true,
  });

  final double size;
  final bool animate;

  @override
  State<ScholarIllustration> createState() => _ScholarIllustrationState();
}

class _ScholarIllustrationState extends State<ScholarIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.animate) {
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
    final palette = context.scholarPalette;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final lift = math.sin(_controller.value * math.pi) * 8;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 24,
                child: Container(
                  width: widget.size * 0.82,
                  height: widget.size * 0.08,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: palette.brandStart.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 18 - lift,
                right: 20,
                child: Icon(
                  Icons.auto_awesome,
                  color: palette.accent,
                  size: widget.size * 0.14,
                ),
              ),
              Positioned(
                top: 42 - lift,
                left: 24,
                child: Transform.rotate(
                  angle: -0.22,
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: palette.brandEnd,
                    size: widget.size * 0.34,
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 34,
                child: _BookStack(
                  color: palette.brandStart,
                  width: widget.size * 0.28,
                  height: widget.size * 0.48,
                ),
              ),
              Positioned(
                bottom: 28,
                left: widget.size * 0.43,
                child: _BookStack(
                  color: palette.brandEnd,
                  width: widget.size * 0.2,
                  height: widget.size * 0.62,
                ),
              ),
              Positioned(
                bottom: 30,
                right: 26,
                child: Icon(
                  Icons.menu_book_rounded,
                  color: palette.textMuted.withValues(alpha: 0.8),
                  size: widget.size * 0.33,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookStack extends StatelessWidget {
  const _BookStack({
    required this.color,
    required this.width,
    required this.height,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.65), color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}

String scholarThemeIconAsset(BuildContext context) {
  return _themeIcon(context);
}

String _themeIcon(BuildContext context) {
  final palette = context.scholarPalette;

  if (palette.brandStart == ScholarPalettes.sakuraPink.brandStart) {
    return AppAssets.sakuraPinkIcon;
  }

  if (palette.brandEnd == ScholarPalettes.scholarBlue.brandEnd) {
    return AppAssets.scholarBlueIcon;
  }

  return AppAssets.darkIcon;
}
