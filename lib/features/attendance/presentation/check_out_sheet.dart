import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';

/// Result of the checkout sheet.
/// - [cancelled] true → user aborted checkout
/// - [cancelled] false + empty [workDescription] → check out without worksheet
/// - [cancelled] false + non-empty [workDescription] → check out with worksheet
class CheckOutSheetResult {
  const CheckOutSheetResult({required this.cancelled, this.workDescription = ''});

  const CheckOutSheetResult.cancelled() : cancelled = true, workDescription = '';

  const CheckOutSheetResult.submit([this.workDescription = '']) : cancelled = false;

  final bool cancelled;
  final String workDescription;
}

Future<CheckOutSheetResult?> showCheckOutSheet(
  BuildContext context, {
  bool carriedOverShift = false,
  DateTime? shiftWorkDate,
}) {
  final colors = context.appColors;
  return showModalBottomSheet<CheckOutSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _CheckOutSheet(
      carriedOverShift: carriedOverShift,
      shiftWorkDate: shiftWorkDate,
    ),
  );
}

class _CheckOutSheet extends StatefulWidget {
  const _CheckOutSheet({required this.carriedOverShift, this.shiftWorkDate});
  final bool carriedOverShift;
  final DateTime? shiftWorkDate;

  @override
  State<_CheckOutSheet> createState() => _CheckOutSheetState();
}

class _CheckOutSheetState extends State<_CheckOutSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _trimmed => _controller.text.trim();

  String _shiftDateLabel(BuildContext context) {
    final l10n = context.l10n;
    if (widget.shiftWorkDate == null) return l10n.thatDay;
    return DateFormat('EEEE, MMM d', Localizations.localeOf(context).toString()).format(widget.shiftWorkDate!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Text(
            widget.carriedOverShift ? l10n.closeOpenShift : l10n.checkOut,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            widget.carriedOverShift
                ? l10n.checkoutCloseShiftHint(_shiftDateLabel(context))
                : l10n.checkoutDescribeTodayOptional,
            style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 6,
            maxLength: 5000,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.workSummaryOptional,
              hintText: widget.carriedOverShift ? l10n.workSummaryShiftHint : l10n.workSummaryHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.worksheetOptionalHint,
            style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, const CheckOutSheetResult.cancelled()),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, CheckOutSheetResult.submit(_trimmed)),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colors.error,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _trimmed.isEmpty
                        ? (widget.carriedOverShift ? l10n.skipAndCloseShift : l10n.skipAndCheckOut)
                        : (widget.carriedOverShift ? l10n.closeShift : l10n.checkOut),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
