import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/session_controller.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscureCurrent = true;
  bool _obscureNext = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateNew(String? value) {
    if (value == null || value.length < 6) return 'Use at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_next.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(sessionControllerProvider.notifier).changePassword(_current.text, _next.text);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _passwordDecoration({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure your account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Change your temporary password',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text('This is required before you can access attendance and leave features. Use at least 6 characters.'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _current,
                      obscureText: _obscureCurrent,
                      decoration: _passwordDecoration(
                        label: 'Temporary password',
                        obscure: _obscureCurrent,
                        onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                      validator: (v) => (v?.length ?? 0) < 6 ? 'Enter your temporary password' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _next,
                      obscureText: _obscureNext,
                      decoration: _passwordDecoration(
                        label: 'New password',
                        obscure: _obscureNext,
                        onToggle: () => setState(() => _obscureNext = !_obscureNext),
                      ),
                      validator: _validateNew,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      obscureText: _obscureConfirm,
                      decoration: _passwordDecoration(
                        label: 'Confirm new password',
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Confirm your password' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: Text(_loading ? 'Saving...' : 'Change password'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading ? null : () => ref.read(sessionControllerProvider.notifier).logout(),
                      child: const Text('Sign out'),
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
