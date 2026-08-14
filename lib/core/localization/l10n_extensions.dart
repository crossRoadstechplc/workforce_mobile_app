import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

String formatDurationMinutes(BuildContext context, int minutes) {
  return '${minutes ~/ 60}h ${minutes % 60}m';
}
