import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../auth/application/session_controller.dart';
import '../../profile/application/profile_controller.dart';

/// Shown only to the signed-in employee when today is their birthday.
class BirthdayBanner extends ConsumerWidget {
  const BirthdayBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileEmployee = ref.watch(profileControllerProvider.select((async) => async.value?.employee));
    final sessionEmployee = ref.watch(sessionControllerProvider.select((s) => s.user?.employee));
    final employee = profileEmployee ?? sessionEmployee;
    if (employee == null || !employee.isBirthdayToday) {
      return const SizedBox.shrink();
    }

    final orgName = ref.watch(sessionControllerProvider.select((s) => s.user?.organizationName));
    final colors = context.appColors;
    final l10n = context.l10n;
    final brand = (orgName != null && orgName.isNotEmpty) ? orgName : 'SPX';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _BirthdayBannerBody(
        title: l10n.birthdayBannerTitle,
        message: l10n.birthdayBannerMessage(brand),
        accent: colors.primary,
        surface: colors.primary.withValues(alpha: 0.12),
      ),
    );
  }
}

class _BirthdayBannerBody extends StatefulWidget {
  const _BirthdayBannerBody({
    required this.title,
    required this.message,
    required this.accent,
    required this.surface,
  });

  final String title;
  final String message;
  final Color accent;
  final Color surface;

  @override
  State<_BirthdayBannerBody> createState() => _BirthdayBannerBodyState();
}

class _BirthdayBannerBodyState extends State<_BirthdayBannerBody> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.15),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: widget.surface,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.cake_outlined, color: widget.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(fontWeight: FontWeight.w800, color: widget.accent),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.accent.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
