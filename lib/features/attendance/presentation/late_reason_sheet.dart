import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extensions.dart';

class LateReasonResult {
  const LateReasonResult(this.type, this.description);
  final String type;
  final String? description;
}

Future<LateReasonResult?> showLateReasonSheet(BuildContext context, int lateMinutes) {
  return showModalBottomSheet<LateReasonResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _LateReasonSheet(lateMinutes: lateMinutes),
  );
}

class _LateReasonSheet extends StatefulWidget {
  const _LateReasonSheet({required this.lateMinutes});
  final int lateMinutes;
  @override
  State<_LateReasonSheet> createState() => _LateReasonSheetState();
}

class _LateReasonSheetState extends State<_LateReasonSheet> {
  String? _selected;
  final _description = TextEditingController();

  bool get _canContinue {
    if (_selected == null) return false;
    if (_selected == 'OTHER' && _description.text.trim().length < 3) return false;
    return true;
  }

  Map<String, String> _reasons(BuildContext context) {
    final l10n = context.l10n;
    return {
      'TRAFFIC': l10n.reasonTraffic,
      'TRANSPORTATION': l10n.reasonTransportation,
      'HEALTH': l10n.reasonHealth,
      'FAMILY_EMERGENCY': l10n.reasonFamilyEmergency,
      'WEATHER': l10n.reasonWeather,
      'OTHER': l10n.reasonOther,
    };
  }

  @override
  void initState() {
    super.initState();
    _description.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _description.removeListener(_onDescriptionChanged);
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canContinue) return;
    Navigator.pop(
      context,
      LateReasonResult(_selected!, _description.text.trim().isEmpty ? null : _description.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reasons = _reasons(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.lateCheckInTitle(widget.lateMinutes),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(l10n.lateCheckInSubtitle),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reasons.entries
                  .map(
                    (entry) => ChoiceChip(
                      label: Text(entry.value),
                      selected: _selected == entry.key,
                      onSelected: (selected) {
                        if (selected) setState(() => _selected = entry.key);
                      },
                    ),
                  )
                  .toList(),
            ),
            if (_selected == 'OTHER') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _description,
                maxLines: 3,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.tellUsWhy,
                  alignLabelWithHint: true,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _canContinue ? _submit : null,
              child: Text(l10n.continueCheckIn),
            ),
          ],
        ),
      ),
    );
  }
}
