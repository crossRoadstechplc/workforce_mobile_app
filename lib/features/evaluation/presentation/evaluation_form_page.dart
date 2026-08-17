import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../application/evaluation_controller.dart';
import '../data/evaluation_models.dart';

class EvaluationFormPage extends ConsumerStatefulWidget {
  const EvaluationFormPage({super.key, required this.id});
  final String id;

  @override
  ConsumerState<EvaluationFormPage> createState() => _EvaluationFormPageState();
}

class _EvaluationFormPageState extends ConsumerState<EvaluationFormPage> {
  int _step = 0;
  EvaluationDetail? _draft;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(evaluationDetailProvider(widget.id));
    final l10n = context.l10n;

    return async.when(
      loading: () => Scaffold(appBar: AppBar(title: Text(l10n.evaluationsTitle)), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.evaluationsTitle)),
        body: AppErrorView(message: e.toString(), onRetry: () => ref.invalidate(evaluationDetailProvider(widget.id))),
      ),
      data: (detail) {
        _draft ??= EvaluationDetail.fromJson(_toJson(detail));
        final draft = _draft!;
        final steps = [
          l10n.evaluationStepInfo,
          l10n.evaluationStepMetrics,
          l10n.evaluationStepRoles,
          l10n.evaluationStepSkills,
          l10n.evaluationStepGoals,
          l10n.evaluationStepReview,
        ];
        return Scaffold(
          appBar: AppBar(title: Text(detail.cycleName)),
          body: Column(
            children: [
              LinearProgressIndicator(value: (_step + 1) / steps.length),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(steps[_step], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [_stepBody(draft)],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      if (_step > 0)
                        OutlinedButton(onPressed: _saving ? null : () => setState(() => _step--), child: Text(l10n.back)),
                      const Spacer(),
                      if (_step < steps.length - 1)
                        FilledButton(
                          onPressed: _saving
                              ? null
                              : () async {
                                  await _autosave(draft);
                                  if (mounted) setState(() => _step++);
                                },
                          child: Text(l10n.next),
                        )
                      else if (draft.needsSelfScore)
                        FilledButton(
                          onPressed: _saving ? null : () => _submit(draft),
                          child: Text(l10n.evaluationSubmit),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stepBody(EvaluationDetail draft) {
    final l10n = context.l10n;
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final metrics = draft.scores.where((s) => s.section == 'METRIC').toList();
    final roles = draft.scores.where((s) => s.section == 'RESPONSIBILITY').toList();
    switch (_step) {
      case 0:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv(l10n.evaluationEmployee, draft.employeeName),
              _kv(l10n.evaluationPosition, draft.jobTitle ?? '—'),
              _kv(l10n.evaluationSupervisor, draft.supervisorName ?? '—'),
              _kv(l10n.evaluationPeriod, '${fmt.format(draft.periodStart)} – ${fmt.format(draft.periodEnd)}'),
              _kv(l10n.evaluationNumber, draft.number),
            ],
          ),
        );
      case 1:
        return _scoreList(draft, metrics, editable: draft.needsSelfScore);
      case 2:
        return _scoreList(draft, roles, editable: draft.needsSelfScore);
      case 3:
        return Column(
          children: draft.goals
              .map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.skill, style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (g.previousSelfScore != null) Text(l10n.evaluationPrevious(g.previousSelfScore.toString())),
                        const SizedBox(height: 8),
                        _chips(
                          selected: g.improvementSelfScore,
                          enabled: draft.needsSelfScore,
                          onSelect: (n) => setState(() => g.improvementSelfScore = n),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      case 4:
        return Column(
          children: draft.goals
              .map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.skill, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: !draft.needsSelfScore
                              ? null
                              : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: g.targetDate ?? DateTime.now().add(const Duration(days: 90)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 800)),
                                  );
                                  if (picked != null) setState(() => g.targetDate = picked);
                                },
                          child: Text(g.targetDate == null ? l10n.evaluationPickDate : fmt.format(g.targetDate!)),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          enabled: draft.needsSelfScore,
                          initialValue: g.criteria ?? '',
                          decoration: InputDecoration(labelText: l10n.evaluationCriteria),
                          maxLines: 3,
                          onChanged: (v) => g.criteria = v,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      default:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.evaluationReviewHint),
              const SizedBox(height: 12),
              if (draft.resultsVisible) ...[
                if (draft.focusCompetency != null) _kv(l10n.evaluationFocus, draft.focusCompetency),
                if (draft.actionPlan != null) _kv(l10n.evaluationActionPlan, draft.actionPlan),
              ],
            ],
          ),
        );
    }
  }

  Widget _scoreList(EvaluationDetail draft, List<EvaluationScoreItem> items, {required bool editable}) {
    return Column(
      children: items
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _chips(selected: s.selfScore, enabled: editable, onSelect: (n) => setState(() => s.selfScore = n)),
                    if (draft.resultsVisible && s.evaluatorScore != null) ...[
                      const SizedBox(height: 8),
                      Text(context.l10n.evaluationEvaluatorScore(s.evaluatorScore.toString())),
                      if (s.evaluatorComment != null && s.evaluatorComment!.isNotEmpty) Text(s.evaluatorComment!),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _chips({required int? selected, required bool enabled, required void Function(int) onSelect}) {
    final colors = context.appColors;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var n = 1; n <= 10; n++)
          ChoiceChip(
            label: Text('$n'),
            selected: selected == n,
            onSelected: enabled ? (_) => onSelect(n) : null,
            selectedColor: colors.primary.withValues(alpha: 0.18),
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

  Future<void> _autosave(EvaluationDetail draft) async {
    if (!draft.needsSelfScore) return;
    setState(() => _saving = true);
    try {
      await ref.read(evaluationRepositoryProvider).saveDraft(widget.id, draft);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submit(EvaluationDetail draft) async {
    final missing = draft.scores.where((s) => (s.section == 'METRIC' || s.section == 'RESPONSIBILITY') && s.selfScore == null);
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
          'periodStart': d.periodStart.toIso8601String(),
          'periodEnd': d.periodEnd.toIso8601String(),
        },
        'employee': {
          'name': d.employeeName,
          'jobTitle': d.jobTitle,
          'supervisor': {'name': d.supervisorName},
        },
        'scores': d.scores
            .map((s) => {
                  'itemKey': s.itemKey,
                  'section': s.section,
                  'label': s.label,
                  'selfScore': s.selfScore,
                  'evaluatorScore': s.evaluatorScore,
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
      };
}
