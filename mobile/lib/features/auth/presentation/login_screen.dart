import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref.read(authProvider.notifier).login(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        context.snack(next.errorMessage!, isError: true);
      }
      if (next.status == AuthStatus.farmerActive &&
          prev?.status != AuthStatus.farmerActive) {
        context.go('/farmer/dashboard');
      }
      if (next.status == AuthStatus.admin &&
          prev?.status != AuthStatus.admin) {
        context.go('/admin');
      }
    });

    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Üretici girişi',
                  style: context.text.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Onaylanmış üreticiler panelden ürünlerini yönetebilir.',
                  style: context.text.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Telefon (05XXXXXXXXX)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: Validators.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Şifre',
                  controller: _passwordController,
                  obscureText: _obscure,
                  validator: Validators.password,
                  textInputAction: TextInputAction.done,
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Giriş Yap',
                  isLoading: auth.isSubmitting,
                  onPressed: auth.isSubmitting ? null : _submit,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/apply'),
                    child: const Text('Üretici değil misiniz? Başvurun'),
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
