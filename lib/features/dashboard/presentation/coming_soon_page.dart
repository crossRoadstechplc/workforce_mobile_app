import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title, required this.phase});
  final String title;
  final String phase;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.construction_rounded, size: 44), const SizedBox(height: 16), Text('$title is scheduled for $phase.', textAlign: TextAlign.center)]),
          ),
        ),
      );
}
