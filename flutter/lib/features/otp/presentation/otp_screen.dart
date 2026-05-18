import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants.dart';
import '../../../app/theme.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/otp_input.dart';
import '../providers/otp_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';

  @override
  void initState() {
    super.initState();
    // Auto-send on first open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpControllerProvider.notifier).send(widget.phone);
    });
  }

  Future<void> _verify() async {
    if (_code.length != AppConstants.otpLength) return;
    final ok = await ref
        .read(otpControllerProvider.notifier)
        .verify(phone: widget.phone, code: _code);
    if (!mounted) return;
    if (ok) {
      // Return verified=true to caller (application form).
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpControllerProvider);
    final masked = PhoneFormatter.mask(widget.phone);

    return Scaffold(
      appBar: AppBar(title: const Text('Telefon Doğrulama')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text('Telefon Doğrulama', style: context.text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '$masked numarasına 6 haneli doğrulama kodu gönderdik.',
                style: context.text.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              OtpInput(
                length: AppConstants.otpLength,
                onChanged: (v) => setState(() => _code = v),
                onCompleted: (_) => _verify(),
                enabled: !state.isVerifying,
                errorText: state.errorMessage,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Doğrula',
                isLoading: state.isVerifying,
                onPressed: _code.length == AppConstants.otpLength
                    ? _verify
                    : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: state.cooldownSeconds > 0
                    ? Text(
                        'Kodu tekrar gönder (${state.cooldownSeconds})',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    : TextButton(
                        onPressed: state.isSending
                            ? null
                            : () => ref
                                .read(otpControllerProvider.notifier)
                                .send(widget.phone),
                        child: const Text('Kodu Tekrar Gönder'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
