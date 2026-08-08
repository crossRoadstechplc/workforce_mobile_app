import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.kind});
  final String label;
  final StatusKind kind;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (kind) {
      StatusKind.success => (const Color(0xFFDCFCE7), AppColors.success),
      StatusKind.warning => (const Color(0xFFFEF3C7), AppColors.warning),
      StatusKind.error => (const Color(0xFFFEE2E2), AppColors.error),
      StatusKind.neutral => (AppColors.muted, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

enum StatusKind { success, warning, error, neutral }
