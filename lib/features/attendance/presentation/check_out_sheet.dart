import 'package:flutter/material.dart';

Future<String?> showCheckOutSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _CheckOutSheet(),
  );
}

class _CheckOutSheet extends StatefulWidget {
  const _CheckOutSheet();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Finish your workday', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Briefly describe what you worked on today.'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 7,
            maxLength: 5000,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Completed attendance integration, tested leave workflow...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _controller.text.trim().length < 20 ? null : () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('Check out'),
          ),
        ],
      ),
    );
  }
}
