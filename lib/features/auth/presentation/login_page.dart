import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../application/session_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const _demoEmail = 'sara@acme.demo';
  static const _demoPassword = 'Demo123!';

  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(sessionControllerProvider.notifier).login(
            _loginController.text,
            _passwordController.text,
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copyDemoCredential(String value, TextEditingController field) async {
    await Clipboard.setData(ClipboardData(text: value));
    field.text = value;
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.copied),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colors.primary,
                      child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _loginController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.emailOrCode,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) => (value == null || value.trim().length < 3) ? l10n.enterEmailOrCode : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 8) ? l10n.passwordMin8 : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(l10n.signIn),
                    ),
                    const SizedBox(height: 20),
                    if (!AppConfig.isProduction) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.demoLoginTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            _DemoCredentialRow(
                              label: l10n.demoEmailField,
                              value: _demoEmail,
                              onCopy: () => _copyDemoCredential(_demoEmail, _loginController),
                            ),
                            const SizedBox(height: 4),
                            _DemoCredentialRow(
                              label: l10n.demoPasswordField,
                              value: _demoPassword,
                              onCopy: () => _copyDemoCredential(_demoPassword, _passwordController),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.demoLoginNote,
                              style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      l10n.accountCreatedByAdmin,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCredentialRow extends StatelessWidget {
  const _DemoCredentialRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onCopy,
          tooltip: context.l10n.copy,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: Icon(Icons.copy_rounded, size: 18, color: colors.primary),
        ),
      ],
    );
  }
}
