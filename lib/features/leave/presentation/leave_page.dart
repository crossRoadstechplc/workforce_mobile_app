import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/status_chip.dart';
import '../application/leave_controller.dart';
import '../data/attendance_correction_models.dart';
import '../data/leave_models.dart';
import 'attendance_correction_sheet.dart';
import 'leave_request_sheet.dart';

class LeavePage extends ConsumerWidget {
  const LeavePage({super.key});

  Future<void> _request(BuildContext context, WidgetRef ref, LeaveState state) async {
    final l10n = context.l10n;
    final draft = await showLeaveRequestSheet(context, state.types, balance: state.balance);
    if (draft == null) return;
    try {
      await ref.read(leaveControllerProvider.notifier).create(
            leaveTypeId: draft.leaveTypeId,
            startDate: draft.startDate,
            endDate: draft.endDate,
            reason: draft.reason,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.leaveRequestSubmitted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _requestCorrection(BuildContext context, WidgetRef ref, LeaveState state) async {
    final l10n = context.l10n;
    final draft = await showAttendanceCorrectionSheet(context, blockedDateKeys: state.blockedCorrectionDateKeys);
    if (draft == null) return;
    try {
      await ref.read(leaveControllerProvider.notifier).submitCorrections(draft.dates, note: draft.note);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.attendanceCorrectionSubmitted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leaveControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: ResponsiveContent(
        child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(
          message: e.toString(),
          onRetry: () => ref.read(leaveControllerProvider.notifier).refresh(),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () => ref.read(leaveControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RequestActions(
                onRequestLeave: () => _request(context, ref, state),
                onRequestCorrection: () => _requestCorrection(context, ref, state),
              ),
              const SizedBox(height: 16),
              if (state.balance != null) ...[
                _BalanceCard(balance: state.balance!),
                const SizedBox(height: 16),
              ],
              _Summary(summary: state.summary),
              const SizedBox(height: 20),
              Text(l10n.attendanceCorrectionHistory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              if (state.corrections.isEmpty)
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(l10n.noAttendanceCorrections, style: TextStyle(color: context.appColors.textSecondary)),
                    ),
                  ),
                )
              else
                ...state.corrections.take(20).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CorrectionCard(item: c),
                      ),
                    ),
              const SizedBox(height: 20),
              Text(l10n.leaveHistory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              if (state.requests.isEmpty)
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(l10n.noLeaveRequests, style: TextStyle(color: context.appColors.textSecondary)),
                    ),
                  ),
                )
              else
                ...state.requests.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LeaveCard(
                      item: r,
                      onCancel: r.status == 'PENDING' ? () => ref.read(leaveControllerProvider.notifier).cancel(r.id) : null,
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _RequestActions extends StatelessWidget {
  const _RequestActions({required this.onRequestLeave, required this.onRequestCorrection});
  final VoidCallback onRequestLeave;
  final VoidCallback onRequestCorrection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(onPressed: onRequestLeave, icon: const Icon(Icons.beach_access_rounded), label: Text(l10n.requestLeave)),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onRequestCorrection,
          icon: const Icon(Icons.fact_check_outlined),
          label: Text(l10n.requestAttendanceCorrection),
        ),
        const SizedBox(height: 8),
        Text(l10n.leaveVsCorrectionHint, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12, height: 1.35)),
      ],
    );
  }
}

class _CorrectionCard extends StatelessWidget {
  const _CorrectionCard({required this.item});
  final AttendanceCorrectionRequest item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(locale).format(item.workDate);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(dateLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              StatusChip(label: _correctionStatusLabel(l10n, item.status), kind: _kind(item.status)),
            ],
          ),
          if (item.employeeNote?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(item.employeeNote!),
          ],
          if (item.adminNote?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.appColors.background, borderRadius: BorderRadius.circular(12)),
              child: Text(l10n.adminNote(item.adminNote!)),
            ),
          ],
        ],
      ),
    );
  }
}

String _correctionStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'PENDING' => l10n.attendanceCorrectionStatusPending,
      'APPROVED' => l10n.attendanceCorrectionStatusApproved,
      'REJECTED' => l10n.attendanceCorrectionStatusRejected,
      _ => status,
    };

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final AnnualLeaveBalance balance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);
    final carry = balance.oldestOpenCarry;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.annualLeaveTitle, style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            formatLeaveDays(balance.available),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
          ),
          Text(l10n.annualLeaveDaysAvailable, style: TextStyle(color: colors.textSecondary)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BalanceChip(label: l10n.annualLeaveThisYear(formatLeaveDays(balance.currentYearGrant))),
              if (balance.carriedIn > 0) _BalanceChip(label: l10n.annualLeaveCarried(formatLeaveDays(balance.carriedIn))),
              _BalanceChip(label: l10n.annualLeaveUsed(formatLeaveDays(balance.used))),
              if (balance.pending > 0) _BalanceChip(label: l10n.annualLeavePendingDays(formatLeaveDays(balance.pending))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.annualLeaveServiceYears('${balance.completedYears}'),
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          Text(
            l10n.annualLeaveNextGrant(formatLeaveDays(balance.nextYearGrant), dateFmt.format(balance.nextAnniversary)),
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          if (balance.completedYears < 1) ...[
            const SizedBox(height: 6),
            Text(
              l10n.annualLeaveProRata(formatLeaveDays(balance.available), '${balance.serviceMonthsThisYear}'),
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
          if (carry != null && carry.kind == 'CARRY') ...[
            const SizedBox(height: 6),
            Text(
              l10n.annualLeaveExpires(formatLeaveDays(carry.remaining), dateFmt.format(carry.expiresOn)),
              style: TextStyle(color: colors.warning, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
          if (balance.buckets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(l10n.annualLeaveBreakdown, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                children: [
                  for (final bucket in balance.buckets.where((b) => b.kind != 'EXPIRED'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${dateFmt.format(bucket.periodStart)} – ${dateFmt.format(bucket.periodEnd)}',
                              style: TextStyle(color: colors.textSecondary, fontSize: 12),
                            ),
                          ),
                          Text(
                            '${formatLeaveDays(bucket.remaining)} / ${formatLeaveDays(bucket.granted)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.muted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.summary});
  final LeaveSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(child: _Metric(label: l10n.approved, value: '${summary.approvedRequests}', kind: StatusKind.success)),
        const SizedBox(width: 8),
        Expanded(child: _Metric(label: l10n.pending, value: '${summary.pendingRequests}', kind: StatusKind.warning)),
        const SizedBox(width: 8),
        Expanded(child: _Metric(label: l10n.rejected, value: '${summary.rejectedRequests}', kind: StatusKind.error)),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.kind});
  final String label;
  final String value;
  final StatusKind kind;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.item, this.onCancel});
  final LeaveRequestItem item;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final days = item.numberOfDays.toStringAsFixed(item.numberOfDays % 1 == 0 ? 0 : 1);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.leaveTypeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              StatusChip(label: item.status, kind: _kind(item.status)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.daysCount(
              DateFormat('MMM d', locale).format(item.startDate),
              DateFormat('MMM d, yyyy', locale).format(item.endDate),
              days,
            ),
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(item.reason),
          if (item.decisionReason?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(12)),
              child: Text(l10n.adminNote(item.decisionReason!)),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close_rounded),
              label: Text(l10n.cancelRequest),
            ),
          ],
        ],
      ),
    );
  }
}

StatusKind _kind(String status) => switch (status) {
      'APPROVED' => StatusKind.success,
      'REJECTED' => StatusKind.error,
      'PENDING' => StatusKind.warning,
      _ => StatusKind.neutral,
    };
