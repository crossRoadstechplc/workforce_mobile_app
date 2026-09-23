import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../application/history_controller.dart';
import '../data/history_models.dart';
import 'worksheet_editor_sheet.dart';

Future<void> addWorksheetForTimesheet(
  BuildContext context,
  WidgetRef ref,
  TimesheetHistoryItem timesheet,
) async {
  final l10n = context.l10n;
  final description = await showWorksheetEditorSheet(
    context,
    title: l10n.addWorksheet,
    submitLabel: l10n.saveWorksheet,
  );
  if (description == null || !context.mounted) return;
  try {
    await ref.read(historyRepositoryProvider).createWorksheet(
          timesheetId: timesheet.id,
          workDescription: description,
        );
    await ref.read(historyControllerProvider.notifier).refresh();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.worksheetSaved)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

Future<void> editWorksheetItem(
  BuildContext context,
  WidgetRef ref, {
  required String worksheetId,
  String initialDescription = '',
}) async {
  final l10n = context.l10n;
  var descriptionSeed = initialDescription;
  if (descriptionSeed.isEmpty) {
    try {
      final full = await ref.read(historyRepositoryProvider).worksheet(worksheetId);
      descriptionSeed = full.description;
    } catch (_) {}
  }
  if (!context.mounted) return;
  final description = await showWorksheetEditorSheet(
    context,
    title: l10n.editWorksheet,
    initialDescription: descriptionSeed,
    submitLabel: l10n.saveWorksheet,
  );
  if (description == null || !context.mounted) return;
  try {
    await ref.read(historyRepositoryProvider).updateWorksheet(
          worksheetId: worksheetId,
          workDescription: description,
        );
    await ref.read(historyControllerProvider.notifier).refresh();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.worksheetSaved)));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
