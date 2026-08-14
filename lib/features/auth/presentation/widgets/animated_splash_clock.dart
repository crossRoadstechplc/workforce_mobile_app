import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Classic analog clock with smoothly moving hands.
class AnimatedSplashClock extends StatelessWidget {
  const AnimatedSplashClock({
    super.key,
    required this.minuteRotation,
    required this.hourRotation,
    required this.primary,
    required this.primaryDark,
    required this.surface,
    required this.isDark,
    this.size = 112,
  });

  final Animation<double> minuteRotation;
  final Animation<double> hourRotation;
  final Color primary;
  final Color primaryDark;
  final Color surface;
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: surface,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.35 : 0.22),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.45 : 0.2),
          width: 2,
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([minuteRotation, hourRotation]),
        builder: (context, _) {
          return CustomPaint(
            painter: _SplashClockPainter(
              minuteAngle: minuteRotation.value * 2 * math.pi,
              hourAngle: hourRotation.value * 2 * math.pi,
              primary: primary,
              primaryDark: primaryDark,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _SplashClockPainter extends CustomPainter {
  _SplashClockPainter({
    required this.minuteAngle,
    required this.hourAngle,
    required this.primary,
    required this.primaryDark,
    required this.isDark,
  });

  final double minuteAngle;
  final double hourAngle;
  final Color primary;
  final Color primaryDark;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.55 : 0.35)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi - math.pi / 2;
      final inner = radius * (i % 3 == 0 ? 0.78 : 0.84);
      final outer = radius * 0.92;
      final start = Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle));
      final end = Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle));
      tickPaint.strokeWidth = i % 3 == 0 ? 2.5 : 1.5;
      canvas.drawLine(start, end, tickPaint);
    }

    _drawHand(
      canvas,
      center,
      radius * 0.52,
      hourAngle - math.pi / 2,
      primaryDark,
      4.5,
    );
    _drawHand(
      canvas,
      center,
      radius * 0.68,
      minuteAngle - math.pi / 2,
      primary,
      3,
    );

    canvas.drawCircle(center, 5, Paint()..color = primaryDark);
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.white);
  }

  void _drawHand(Canvas canvas, Offset center, double length, double angle, Color color, double width) {
    final end = Offset(center.dx + length * math.cos(angle), center.dy + length * math.sin(angle));
    canvas.drawLine(
      center,
      end,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashClockPainter oldDelegate) =>
      oldDelegate.minuteAngle != minuteAngle || oldDelegate.hourAngle != hourAngle;
}
