import 'package:flutter/material.dart';

/// Soft branded backdrop with radial glows for the splash screen.
class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.isDark,
  });

  final Color primary;
  final Color primaryDark;
  final Color background;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0B1220),
                      primaryDark.withValues(alpha: 0.35),
                      background,
                    ]
                  : [
                      background,
                      primary.withValues(alpha: 0.08),
                      primaryDark.withValues(alpha: 0.14),
                    ],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: _GlowOrb(color: primary.withValues(alpha: isDark ? 0.22 : 0.16), size: 220),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: _GlowOrb(color: primaryDark.withValues(alpha: isDark ? 0.18 : 0.12), size: 260),
        ),
        CustomPaint(
          painter: _SplashPatternPainter(
            lineColor: primary.withValues(alpha: isDark ? 0.06 : 0.05),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _SplashPatternPainter extends CustomPainter {
  _SplashPatternPainter({required this.lineColor});
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPatternPainter oldDelegate) => false;
}
