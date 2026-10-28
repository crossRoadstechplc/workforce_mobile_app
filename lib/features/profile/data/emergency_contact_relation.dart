import '../../../l10n/app_localizations.dart';

enum EmergencyContactRelation {
  mother,
  father,
  brother,
  sister,
  spouse,
  child,
  friend,
  relative,
  other;

  String get apiValue => switch (this) {
        EmergencyContactRelation.mother => 'MOTHER',
        EmergencyContactRelation.father => 'FATHER',
        EmergencyContactRelation.brother => 'BROTHER',
        EmergencyContactRelation.sister => 'SISTER',
        EmergencyContactRelation.spouse => 'SPOUSE',
        EmergencyContactRelation.child => 'CHILD',
        EmergencyContactRelation.friend => 'FRIEND',
        EmergencyContactRelation.relative => 'RELATIVE',
        EmergencyContactRelation.other => 'OTHER',
      };

  static EmergencyContactRelation? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return switch (value.trim().toUpperCase()) {
      'MOTHER' => EmergencyContactRelation.mother,
      'FATHER' => EmergencyContactRelation.father,
      'BROTHER' => EmergencyContactRelation.brother,
      'SISTER' => EmergencyContactRelation.sister,
      'SPOUSE' => EmergencyContactRelation.spouse,
      'CHILD' => EmergencyContactRelation.child,
      'FRIEND' => EmergencyContactRelation.friend,
      'RELATIVE' => EmergencyContactRelation.relative,
      'OTHER' => EmergencyContactRelation.other,
      _ => null,
    };
  }

  String label(AppLocalizations l10n) => switch (this) {
        EmergencyContactRelation.mother => l10n.relationMother,
        EmergencyContactRelation.father => l10n.relationFather,
        EmergencyContactRelation.brother => l10n.relationBrother,
        EmergencyContactRelation.sister => l10n.relationSister,
        EmergencyContactRelation.spouse => l10n.relationSpouse,
        EmergencyContactRelation.child => l10n.relationChild,
        EmergencyContactRelation.friend => l10n.relationFriend,
        EmergencyContactRelation.relative => l10n.relationRelative,
        EmergencyContactRelation.other => l10n.relationOther,
      };

  static String? displayLabel({
    required AppLocalizations l10n,
    String? relation,
    String? other,
  }) {
    final parsed = tryParse(relation);
    if (parsed == null) return null;
    if (parsed == EmergencyContactRelation.other) {
      final custom = other?.trim() ?? '';
      return custom.isNotEmpty ? custom : l10n.relationOther;
    }
    return parsed.label(l10n);
  }
}
