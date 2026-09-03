import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../data/auth_models.dart';

class ContextPicker extends StatelessWidget {
  const ContextPicker({
    super.key,
    required this.contexts,
    required this.defaultContextKey,
    required this.onSelect,
    this.busy = false,
  });

  final List<LoginContext> contexts;
  final String? defaultContextKey;
  final ValueChanged<String> onSelect;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.contextPickerTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.contextPickerSubtitle,
          style: TextStyle(color: colors.textSecondary),
        ),
        const SizedBox(height: 24),
        ...contexts.map((item) {
          final isDefault = item.key == defaultContextKey;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: isDefault ? colors.primary.withValues(alpha: 0.08) : colors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: busy ? null : () => onSelect(item.key),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDefault ? colors.primary.withValues(alpha: 0.35) : colors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colors.primary.withValues(alpha: 0.12),
                        child: Icon(_iconFor(item.type), color: colors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (item.officeNames.isNotEmpty)
                              Text(
                                item.officeNames.join(', '),
                                style: TextStyle(fontSize: 13, color: colors.textSecondary),
                              ),
                            if (isDefault)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  l10n.contextSuggested,
                                  style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (busy)
                        const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  IconData _iconFor(ContextType type) => switch (type) {
        ContextType.platform => Icons.public_rounded,
        ContextType.orgAdmin => Icons.business_rounded,
        ContextType.officeAdmin => Icons.storefront_rounded,
        ContextType.employee => Icons.badge_outlined,
      };
}

class ContextSwitcher extends StatelessWidget {
  const ContextSwitcher({
    super.key,
    required this.contexts,
    required this.activeContextKey,
    required this.onSwitch,
    this.switching = false,
  });

  final List<LoginContext> contexts;
  final String? activeContextKey;
  final ValueChanged<String> onSwitch;
  final bool switching;

  @override
  Widget build(BuildContext context) {
    if (contexts.length <= 1) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colors = context.appColors;
    final active = _activeContext(contexts, activeContextKey);

    return PopupMenuButton<String>(
      enabled: !switching,
      tooltip: l10n.switchContext,
      onSelected: onSwitch,
      offset: const Offset(0, 40),
      itemBuilder: (context) => contexts
          .map(
            (item) => PopupMenuItem<String>(
              value: item.key,
              child: Row(
                children: [
                  Icon(_iconFor(item.type), size: 18, color: colors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.label, overflow: TextOverflow.ellipsis)),
                  if (item.key == activeContextKey)
                    Icon(Icons.check_rounded, size: 18, color: colors.primary),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (switching)
              SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
              )
            else
              Icon(_iconFor(active.type), size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                active.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.expand_more_rounded, size: 18, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(ContextType type) => switch (type) {
        ContextType.platform => Icons.public_rounded,
        ContextType.orgAdmin => Icons.business_rounded,
        ContextType.officeAdmin => Icons.storefront_rounded,
        ContextType.employee => Icons.badge_outlined,
      };
}

LoginContext _activeContext(List<LoginContext> contexts, String? activeContextKey) {
  for (final item in contexts) {
    if (item.key == activeContextKey) return item;
  }
  return contexts.first;
}

class NonEmployeeContextBanner extends StatelessWidget {
  const NonEmployeeContextBanner({
    super.key,
    required this.user,
    required this.onSwitchToEmployee,
  });

  final AuthUser user;
  final VoidCallback onSwitchToEmployee;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Material(
      color: colors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.nonEmployeeContextBanner(user.contextLabel),
                style: TextStyle(fontSize: 13, color: colors.textPrimary, height: 1.35),
              ),
            ),
            TextButton(onPressed: onSwitchToEmployee, child: Text(l10n.switchToEmployee)),
          ],
        ),
      ),
    );
  }
}
