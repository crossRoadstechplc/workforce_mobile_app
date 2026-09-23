import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/localization/l10n_extensions.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../application/session_controller.dart';
import 'context_picker.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.initialLogin});

  /// Prefill from invite handoff (`/login?email=` or deep link).
  final String? initialLogin;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _loginController;
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController(text: widget.initialLogin?.trim() ?? '');
  }

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
        final message = error is ApiException ? error.message : error.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _chooseContext(String contextKey) async {
    setState(() => _loading = true);
    try {
      await ref.read(sessionControllerProvider.notifier).selectContext(contextKey);
    } catch (error) {
      if (mounted) {
        final message = error is ApiException ? error.message : error.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final l10n = context.l10n;
    final colors = context.appColors;

    if (session.status == SessionStatus.selectContext && session.pendingContext != null) {
      final pending = session.pendingContext!;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton.icon(
                      onPressed: _loading ? null : () => ref.read(sessionControllerProvider.notifier).cancelContextSelection(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(l10n.backToSignIn),
                      style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                    ),
                    const SizedBox(height: 8),
                    ContextPicker(
                      contexts: pending.contexts,
                      defaultContextKey: pending.defaultContextKey,
                      busy: _loading,
                      onSelect: _chooseContext,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
                    Align(
                      child: Image.asset(
                        'lib/logo.png',
                        height: 96,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.loginTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
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
                      obscureText: _obscurePassword,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value == null || value.length < 6) ? l10n.passwordMin8 : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(l10n.signIn),
                    ),
                    const SizedBox(height: 16),
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
