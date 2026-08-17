import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../application/evaluation_controller.dart';
import '../data/evaluation_models.dart';

class EvaluationsListPage extends ConsumerWidget {
  const EvaluationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(evaluationListControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.evaluationsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.read(evaluationListControllerProvider.notifier).refresh(),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.read(evaluationListControllerProvider.notifier).refresh(),
          child: items.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 140),
                      child: Center(child: Text(l10n.noEvaluationsYet, style: TextStyle(color: colors.textSecondary))),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _Card(item: items[i]),
                ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item});
  final EvaluationSummary item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return AppCard(
      child: InkWell(
        onTap: () => context.push('/evaluations/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.cycleName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                StatusChip(label: _label(l10n, item.status), kind: _kind(item.status)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${fmt.format(item.periodStart)} – ${fmt.format(item.periodEnd)}'),
            if (item.selfDueAt != null) Text(l10n.evaluationDue(fmt.format(item.selfDueAt!))),
            if (item.overallSelf != null) Text(l10n.evaluationSelfAverage(item.overallSelf!.toStringAsFixed(1))),
          ],
        ),
      ),
    );
  }
}

String _label(AppLocalizations l10n, String status) {
  return switch (status) {
    'OPEN' || 'SELF_DRAFT' => l10n.evaluationStatusOpen,
    'SELF_SUBMITTED' || 'EVALUATOR_DRAFT' => l10n.evaluationStatusWaiting,
    'EVALUATOR_SUBMITTED' => l10n.evaluationStatusScored,
    'FINALIZED' => l10n.evaluationStatusFinal,
    _ => status,
  };
}

StatusKind _kind(String status) {
  return switch (status) {
    'OPEN' || 'SELF_DRAFT' => StatusKind.warning,
    'SELF_SUBMITTED' || 'EVALUATOR_DRAFT' => StatusKind.neutral,
    'EVALUATOR_SUBMITTED' || 'FINALIZED' => StatusKind.success,
    _ => StatusKind.neutral,
  };
}
