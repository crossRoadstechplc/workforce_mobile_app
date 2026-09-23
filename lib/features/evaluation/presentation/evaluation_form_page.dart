import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../application/evaluation_controller.dart';
import '../data/evaluation_models.dart';

const _ratings = [
  (1, '😞', 'Unsatisfactory'),
  (2, '😕', 'Needs Improvement'),
  (3, '🙂', 'Meets Expectations'),
  (4, '😊', 'Exceeds Expectations'),
  (5, '🤩', 'Outstanding'),
];

class EvaluationFormPage extends ConsumerStatefulWidget {
  const EvaluationFormPage({super.key, required this.id});
  final String id;

  @override
  ConsumerState<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends ConsumerState<EvaluationFormPage> {
  EvaluationDetail? _draft;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(evaluationDetailProvider(widget.id));
    final l10n = context.l10n;

    return async.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: AppErrorView(message: e.toString(), onRetry: () => ref.invalidate(evaluationDetailProvider(widget.id))),
      ),
      data: (detail) {
        _draft ??= EvaluationDetail.fromJson(_toJson(detail));
        final draft = _draft!;
        final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
        final liveTotal = _liveSelfTotal(draft);
        return Scaffold(
          appBar: AppBar(
            leading: context.canPop()
                ? IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded))
                : null,
            title: Text(detail.cycleName),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(l10n.evaluationEmployee, draft.employeeName),
                    _kv(l10n.evaluationPosition, draft.jobTitle ?? '—'),
                    _kv('Department', draft.department ?? '—'),
                    _kv(l10n.evaluationSupervisor, draft.supervisorName ?? '—'),
                    _kv(l10n.evaluationPeriod, '${fmt.format(draft.periodStart)} – ${fmt.format(draft.periodEnd)}'),
                  ],
                ),
              ),
              if (draft.isCycleClosed) ...[
                const SizedBox(height: 12),
                Material(
                  color: context.appColors.warningBg,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline_rounded, color: context.appColors.warning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.evaluationCycleClosedBanner,
                            style: TextStyle(fontWeight: FontWeight.w600, color: context.appColors.warning, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ...draft.scores.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _scoreCard(draft, s),
                  )),
              if (draft.resultsVisible && (draft.focusCompetency?.isNotEmpty ?? false))
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv(l10n.evaluationFocus, draft.focusCompetency),
                      if (draft.actionPlan != null) _kv(l10n.evaluationActionPlan, draft.actionPlan),
                    ],
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      draft.resultsVisible && draft.overallEvaluator != null
                          ? l10n.evaluationEvaluatorTotal('${draft.overallEvaluator!.toStringAsFixed(0)} / 50')
                          : liveTotal == null
                              ? (draft.overallSelf == null ? '' : l10n.evaluationSelfAverage('${draft.overallSelf!.toStringAsFixed(0)} / 50'))
                              : l10n.evaluationSelfAverage('$liveTotal / 50'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (draft.needsSelfScore)
                    FilledButton(
                      onPressed: _saving ? null : () => _submit(draft),
                      child: Text(l10n.evaluationSubmit),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int? _liveSelfTotal(EvaluationDetail draft) {
    var total = 0;
    for (final s in draft.scores) {
      if (s.isSystem) {
        if (s.systemScore == null && s.selfScore == null) return null;
        total += s.systemScore ?? s.selfScore!;
      } else {
        if (s.selfScore == null) return null;
        total += s.selfScore!;
      }
    }
    return total;
  }

  Widget _scoreCard(EvaluationDetail draft, EvaluationScoreItem s) {
    final colors = context.appColors;
    final system = s.isSystem;
    final selected = system ? (s.systemScore ?? s.selfScore) : s.selfScore;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            ],
          ),
          if (s.prompt != null && s.prompt!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(s.prompt!, style: TextStyle(color: colors.textSecondary, height: 1.35)),
          ],
          const SizedBox(height: 12),
          _emojiRow(
            selected: selected,
            enabled: !draft.isReadOnly && draft.needsSelfScore && !system,
            onSelect: (n) => setState(() => s.selfScore = n),
          ),
          if (draft.resultsVisible && !system && s.evaluatorScore != null) ...[
            const SizedBox(height: 10),
            Text(context.l10n.evaluationEvaluatorScore(s.evaluatorScore.toString())),
            if (s.evaluatorComment != null && s.evaluatorComment!.isNotEmpty) Text(s.evaluatorComment!),
          ],
        ],
      ),
    );
  }

  Widget _emojiRow({required int? selected, required bool enabled, required void Function(int) onSelect}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final r in _ratings)
          GestureDetector(
            onTap: enabled ? () => onSelect(r.$1) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 56,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected == r.$1 ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected == r.$1 ? const Color(0xFF10B981) : const Color(0xFFE2E8F0), width: selected == r.$1 ? 2 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(r.$2, style: TextStyle(fontSize: 22, color: enabled || selected == r.$1 ? null : Colors.black38)),
                  Text('${r.$1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.appColors.textSecondary)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _kv(String k, String? v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
          Text(v ?? '—', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _submit(EvaluationDetail draft) async {
    final missing = draft.scores.where((s) => !s.isSystem && s.selfScore == null);
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.evaluationIncomplete)));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.evaluationSubmit),
        content: Text(context.l10n.evaluationSubmitConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.evaluationSubmit)),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await ref.read(evaluationRepositoryProvider).saveDraft(widget.id, draft);
      await ref.read(evaluationRepositoryProvider).submit(widget.id);
      ref.invalidate(evaluationListControllerProvider);
      ref.invalidate(evaluationDetailProvider(widget.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.evaluationSubmitted)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, dynamic> _toJson(EvaluationDetail d) => {
        'id': d.id,
        'number': d.number,
        'status': d.status,
        'cycle': {
          'name': d.cycleName,
          'status': d.cycleStatus,
          'periodStart': d.periodStart.toIso8601String(),
          'periodEnd': d.periodEnd.toIso8601String(),
        },
        'employee': {
          'name': d.employeeName,
          'jobTitle': d.jobTitle,
          'department': d.department,
          'supervisor': {'name': d.supervisorName},
        },
        'scores': d.scores
            .map((s) => {
                  'itemKey': s.itemKey,
                  'section': s.section,
                  'label': s.label,
                  'prompt': s.prompt,
                  'scoringSource': s.scoringSource,
                  'selfScore': s.selfScore,
                  'evaluatorScore': s.evaluatorScore,
                  'systemScore': s.systemScore,
                  'evaluatorComment': s.evaluatorComment,
                })
            .toList(),
        'goals': d.goals
            .map((g) => {
                  'id': g.id,
                  'skill': g.skill,
                  'previousSelfScore': g.previousSelfScore,
                  'previousEvaluatorScore': g.previousEvaluatorScore,
                  'improvementSelfScore': g.improvementSelfScore,
                  'improvementEvaluatorScore': g.improvementEvaluatorScore,
                  'targetDate': g.targetDate?.toIso8601String(),
                  'criteria': g.criteria,
                })
            .toList(),
        'periodSnapshot': d.periodSnapshot,
        'focusCompetency': d.focusCompetency,
        'actionPlan': d.actionPlan,
        'overallSelf': d.overallSelf,
        'overallEvaluator': d.overallEvaluator,
        'overallSelfBandLabel': d.overallSelfBandLabel,
        'ratingScale': {'max': d.ratingMax},
      };
}
