import 'package:flutter/material.dart';

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
  final reasons = const {
    'TRAFFIC': 'Traffic',
    'TRANSPORTATION': 'Transportation',
    'HEALTH': 'Health',
    'FAMILY_EMERGENCY': 'Family emergency',
    'WEATHER': 'Weather',
    'OTHER': 'Other',
  };

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('You are ${widget.lateMinutes} minute(s) late', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Select the reason before completing check-in.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reasons.entries.map((entry) => ChoiceChip(label: Text(entry.value), selected: _selected == entry.key, onSelected: (_) => setState(() => _selected = entry.key))).toList(),
          ),
          if (_selected == 'OTHER') ...[
            const SizedBox(height: 16),
            TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Tell us why', alignLabelWithHint: true)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selected == null || (_selected == 'OTHER' && _description.text.trim().length < 3)
                ? null
                : () => Navigator.pop(context, LateReasonResult(_selected!, _description.text.trim().isEmpty ? null : _description.text.trim())),
            child: const Text('Continue check-in'),
          ),
        ],
      ),
    );
  }
}
