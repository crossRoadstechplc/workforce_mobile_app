import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

String formatDurationMinutes(BuildContext context, int minutes) {
  final total = minutes.abs();
  if (total <= 0) return '0m';
  final days = total ~/ 1440;
  final hours = (total % 1440) ~/ 60;
  final mins = total % 60;
  final parts = <String>[];
  if (days > 0) parts.add('${days}d');
  if (hours > 0) parts.add('${hours}h');
  if (mins > 0 || parts.isEmpty) parts.add('${mins}m');
  return parts.join(' ');
}
