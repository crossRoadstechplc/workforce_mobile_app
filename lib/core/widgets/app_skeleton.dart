import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key, this.height = 16, this.width, this.radius = 8});
  final double height;
  final double? width;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Opacity(
          opacity: 0.45 + (_controller.value * 0.35),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        ),
      ),
    );
  }
}

class AttendanceCardSkeleton extends StatelessWidget {
  const AttendanceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      label: 'Loading attendance',
      child: Container(
        height: 210,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: AppSkeleton(height: 22, width: 170)),
                SizedBox(width: 16),
                AppSkeleton(height: 28, width: 80, radius: 14),
              ],
            ),
            SizedBox(height: 28),
            AppSkeleton(width: 210),
            SizedBox(height: 12),
            AppSkeleton(width: 150),
            Spacer(),
            AppSkeleton(height: 52, radius: 12),
          ],
        ),
      ),
    );
  }
}
