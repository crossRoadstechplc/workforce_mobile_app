import 'package:flutter/material.dart';

import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import 'widgets/animated_splash_clock.dart';
import 'widgets/splash_background.dart';
import 'widgets/timesheet_flow_strip.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _minuteHandController;
  late final AnimationController _hourHandController;
  late final AnimationController _stripController;
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _minuteHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _hourHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 24000),
    )..repeat();

    _stripController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _minuteHandController.dispose();
    _hourHandController.dispose();
    _stripController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SplashBackground(
            primary: colors.primary,
            primaryDark: colors.primaryDark,
            background: colors.background,
            isDark: isDark,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: _fadeIn,
                    child: ScaleTransition(
                      scale: _scaleIn,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSplashClock(
                            minuteRotation: _minuteHandController,
                            hourRotation: _hourHandController,
                            primary: colors.primary,
                            primaryDark: colors.primaryDark,
                            surface: colors.surface,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 28),
                          Text(
                            l10n.appTitle,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.splashSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  FadeTransition(
                    opacity: _fadeIn,
                    child: TimesheetFlowStrip(
                      progress: _stripController,
                      primary: colors.primary,
                      muted: colors.muted,
                      surface: colors.surface,
                      textSecondary: colors.textSecondary,
                      isDark: isDark,
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.splashLoading,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
