import 'package:flutter/material.dart';

/// Animated day strip suggesting scroll from clock to timesheet history.
class TimesheetFlowStrip extends StatelessWidget {
  const TimesheetFlowStrip({
    super.key,
    required this.progress,
    required this.primary,
    required this.muted,
    required this.surface,
    required this.textSecondary,
    required this.isDark,
  });

  final Animation<double> progress;
  final Color primary;
  final Color muted;
  final Color surface;
  final Color textSecondary;
  final bool isDark;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final activeIndex = (progress.value * _dayLabels.length).floor() % _dayLabels.length;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_dayLabels.length, (index) {
                final isActive = index == activeIndex;
                final isPast = index < activeIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: isActive ? 34 : 28,
                    height: isActive ? 40 : 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? primary
                          : isPast
                              ? primary.withValues(alpha: isDark ? 0.22 : 0.14)
                              : muted.withValues(alpha: isDark ? 0.65 : 1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? primary
                            : primary.withValues(alpha: isDark ? 0.25 : 0.12),
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _dayLabels[index],
                      style: TextStyle(
                        fontSize: isActive ? 12 : 11,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        color: isActive ? Colors.white : textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 220,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: muted,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.35,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (progress.value % 1.0) * 188,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.35),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
