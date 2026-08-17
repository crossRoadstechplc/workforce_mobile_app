import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../application/evaluation_controller.dart';

class EvaluationDueBanner extends ConsumerWidget {
  const EvaluationDueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(evaluationListControllerProvider);
    final due = async.value?.where((e) => e.needsSelfScore).toList() ?? const [];
    if (due.isEmpty) return const SizedBox.shrink();
    final item = due.first;
    final colors = context.appColors;
    final l10n = context.l10n;
    return Material(
      color: colors.warningBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/evaluations/${item.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.assignment_outlined, color: colors.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.evaluationDueCard(item.cycleName),
                  style: TextStyle(fontWeight: FontWeight.w700, color: colors.warning),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.warning),
            ],
          ),
        ),
      ),
    );
  }
}
