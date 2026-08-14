import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';

class AttendanceActionButton extends StatelessWidget {
  const AttendanceActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.expanded = false,
    this.outlined = false,
    this.floating = false,
    this.iconInBox = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final bool expanded;
  final bool outlined;
  final bool floating;
  final bool iconInBox;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final active = enabled && !loading && onPressed != null;
    final loadingLabel = context.l10n.checkingLocation;

    if (floating) {
      return Semantics(
        button: true,
        label: label,
        enabled: active,
        child: Material(
          elevation: active ? 6 : 0,
          shadowColor: color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(999),
          color: active ? color : colors.muted,
          child: InkWell(
            onTap: active ? onPressed : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  else if (iconInBox)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(icon, size: 14, color: active ? color : colors.textSecondary),
                    )
                  else
                    Icon(icon, size: 20, color: active ? Colors.white : colors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    loading ? loadingLabel : label,
                    style: TextStyle(
                      color: active ? Colors.white : colors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final child = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: outlined ? color : Colors.white),
          )
        else
          Icon(icon, size: 20, color: active ? (outlined ? color : Colors.white) : colors.textSecondary),
        const SizedBox(width: 10),
        Text(
          loading ? loadingLabel : label,
          style: TextStyle(
            color: active ? (outlined ? color : Colors.white) : colors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );

    if (outlined) {
      return SizedBox(
        width: expanded ? double.infinity : null,
        child: OutlinedButton(
          onPressed: active ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(expanded ? double.infinity : 168, 52),
            side: BorderSide(color: active ? color : colors.border, width: 1.2),
            foregroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: FilledButton(
        onPressed: active ? onPressed : null,
        style: FilledButton.styleFrom(
          minimumSize: Size(expanded ? double.infinity : 168, 52),
          backgroundColor: active ? color : colors.muted,
          foregroundColor: active ? Colors.white : colors.textSecondary,
          disabledBackgroundColor: colors.muted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
