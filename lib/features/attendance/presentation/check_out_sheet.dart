import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';

const _minDescriptionLength = 20;

Future<String?> showCheckOutSheet(
  BuildContext context, {
  bool carriedOverShift = false,
  DateTime? shiftWorkDate,
}) {
  final colors = context.appColors;
  return showModalBottomSheet<String>(
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
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().length >= _minDescriptionLength;

  int get _trimmedLength => _controller.text.trim().length;

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
                : l10n.checkoutDescribeToday,
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
            decoration: InputDecoration(
              labelText: l10n.workSummary,
              hintText: widget.carriedOverShift ? l10n.workSummaryShiftHint : l10n.workSummaryHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isValid
                ? l10n.readyToSubmit
                : l10n.minChars(_minDescriptionLength, _trimmedLength),
            style: TextStyle(
              fontSize: 12,
              color: _isValid ? colors.success : colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: _isValid ? () => Navigator.pop(context, _controller.text.trim()) : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colors.error,
                    disabledBackgroundColor: colors.muted,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.carriedOverShift ? l10n.closeShift : l10n.checkOut),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
