import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.kind});
  final String label;
  final StatusKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (background, foreground) = switch (kind) {
      StatusKind.success => (colors.successBg, colors.success),
      StatusKind.warning => (colors.warningBg, colors.warning),
      StatusKind.error => (colors.errorBg, colors.error),
      StatusKind.neutral => (colors.muted, colors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

enum StatusKind { success, warning, error, neutral }
