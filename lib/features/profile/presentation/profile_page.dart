import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/data/auth_models.dart';
import '../../notifications/application/notification_controller.dart';
import '../application/profile_controller.dart';
import '../data/emergency_contact_relation.dart';
import '../data/profile_repository.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<_EmergencyContactDraft?> _openContactDialog(
    BuildContext context, {
    EmergencyContact? contact,
  }) {
    return showDialog<_EmergencyContactDraft>(
      context: context,
      builder: (context) => _EmergencyContactDialog(contact: contact),
    );
  }

  Future<void> _saveContact(
    BuildContext context,
    WidgetRef ref, {
    EmergencyContact? existing,
  }) async {
    final l10n = context.l10n;
    final contacts = ref.read(profileControllerProvider).value?.employee?.emergencyContacts ?? const [];
    if (existing == null && contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emergencyContactLimit)));
      return;
    }

    final draft = await _openContactDialog(context, contact: existing);
    if (draft == null) return;

    if (draft.name.isEmpty || draft.phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emergencyContactRequired)));
      }
      return;
    }
    if (draft.relation == EmergencyContactRelation.other && draft.relationOther.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emergencyRelationOtherRequired)));
      }
      return;
    }

    try {
      final relation = draft.relation?.apiValue;
      final relationOther = draft.relation == EmergencyContactRelation.other ? draft.relationOther : null;
      if (existing == null) {
        await ref.read(profileControllerProvider.notifier).addEmergencyContact(
              name: draft.name,
              phone: draft.phone,
              relation: relation,
              relationOther: relationOther,
            );
      } else {
        await ref.read(profileControllerProvider.notifier).updateEmergencyContact(
              contactId: existing.id,
              name: draft.name,
              phone: draft.phone,
              relation: relation,
              relationOther: relationOther,
            );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emergencyContactSaved)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteContact(BuildContext context, WidgetRef ref, EmergencyContact contact) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEmergencyContact),
        content: Text(l10n.deleteEmergencyContactConfirm(contact.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(profileControllerProvider.notifier).deleteEmergencyContact(contact.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emergencyContactDeleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.employeeCodeCopied)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      body: ResponsiveContent(
        child: profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorView(
            message: e.toString(),
            onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
          ),
          data: (user) => RefreshIndicator(
            onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _ProfileHero(
                  user: user,
                  onCopyCode: user.employee?.employeeCode?.trim().isNotEmpty == true
                      ? () => _copyCode(context, user.employee!.employeeCode!.trim())
                      : null,
                ),
                const SizedBox(height: 14),
                _ProfileSection(
                  title: l10n.emergencyContact,
                  trailing: TextButton.icon(
                    onPressed: () => _saveContact(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.add),
                  ),
                  child: _EmergencyContactList(
                    contacts: user.employee?.emergencyContacts ?? const [],
                    onAdd: () => _saveContact(context, ref),
                    onEdit: (contact) => _saveContact(context, ref, existing: contact),
                    onDelete: (contact) => _deleteContact(context, ref, contact),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(pushNotificationServiceProvider).unregister();
                    await ref.read(sessionControllerProvider.notifier).logout();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(color: colors.error.withValues(alpha: 0.35)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.signOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, this.onCopyCode});

  final EmployeeIdentity user;
  final VoidCallback? onCopyCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = user.displayName.isNotEmpty ? user.displayName : user.email;
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E';
    final code = user.employee?.employeeCode?.trim();
    final roleLabel = user.roles.isNotEmpty ? user.roles.first : 'EMPLOYEE';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: isDark ? 0.94 : 0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 118,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned.fill(
                  bottom: 36,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colors.primary, colors.primaryDark],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: colors.textSecondary),
                ),
                const SizedBox(height: 12),
                _MetaChip(
                  icon: Icons.verified_user_outlined,
                  label: roleLabel,
                  filled: true,
                ),
                if (code != null && code.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: onCopyCode,
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: colors.muted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.badge_outlined, color: colors.primary, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.employeeCode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    code,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.copy_rounded, size: 18, color: colors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? colors.primary.withValues(alpha: 0.12) : colors.muted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled ? colors.primary.withValues(alpha: 0.25) : colors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: filled ? colors.primary : colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: filled ? colors.primary : colors.textPrimary,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(999), child: child);
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: isDark ? 0.94 : 0.97),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _EmergencyContactDraft {
  const _EmergencyContactDraft({
    required this.name,
    required this.phone,
    required this.relation,
    required this.relationOther,
  });

  final String name;
  final String phone;
  final EmergencyContactRelation? relation;
  final String relationOther;
}

class _EmergencyContactDialog extends StatefulWidget {
  const _EmergencyContactDialog({this.contact});

  final EmergencyContact? contact;

  @override
  State<_EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<_EmergencyContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _otherController;
  EmergencyContactRelation? _relation;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _nameController = TextEditingController(text: contact?.name ?? '');
    _phoneController = TextEditingController(text: contact?.phone ?? '');
    _otherController = TextEditingController(text: contact?.relationOther ?? '');
    _relation = EmergencyContactRelation.tryParse(contact?.relation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.contact != null;

    return AlertDialog(
      title: Text(editing ? l10n.editEmergencyContact : l10n.addEmergencyContact),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.emergencyContactName),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.emergencyContactPhone),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<EmergencyContactRelation>(
              // ignore: deprecated_member_use
              value: _relation,
              decoration: InputDecoration(labelText: l10n.emergencyContactRelation),
              items: EmergencyContactRelation.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.label(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _relation = value),
            ),
            if (_relation == EmergencyContactRelation.other) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _otherController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.emergencyContactRelationOther,
                  hintText: l10n.emergencyContactRelationOtherHint,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _EmergencyContactDraft(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              relation: _relation,
              relationOther: _otherController.text.trim(),
            ),
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _EmergencyContactList extends StatelessWidget {
  const _EmergencyContactList({
    required this.contacts,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<EmergencyContact> contacts;
  final VoidCallback onAdd;
  final ValueChanged<EmergencyContact> onEdit;
  final ValueChanged<EmergencyContact> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    if (contacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: colors.muted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.contact_emergency_outlined, size: 28, color: colors.textSecondary),
            const SizedBox(height: 8),
            Text(
              l10n.emergencyContactEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.addEmergencyContact),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          for (var i = 0; i < contacts.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _EmergencyContactCard(
              contact: contacts[i],
              onEdit: () => onEdit(contacts[i]),
              onDelete: () => onDelete(contacts[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  const _EmergencyContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  final EmergencyContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final relationLabel = EmergencyContactRelation.displayLabel(
      l10n: l10n,
      relation: contact.relation,
      other: contact.relationOther,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.person_outline_rounded, size: 18, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(contact.phone, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                if (relationLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    relationLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.edit,
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, color: colors.textSecondary),
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: colors.error),
          ),
        ],
      ),
    );
  }
}
