import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:koyden_sehire/app/constants.dart';
import 'package:koyden_sehire/app/theme.dart';
import 'package:koyden_sehire/core/utils/phone_formatter.dart';
import 'package:koyden_sehire/shared/extensions/context_extensions.dart';
import 'package:koyden_sehire/shared/widgets/app_button.dart';
import 'package:koyden_sehire/shared/widgets/otp_input.dart';
import 'package:koyden_sehire/services/otp_repository.dart';
import 'package:koyden_sehire/controllers/otp_controller.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';
  late final OtpController _ctrl;

  @override
  void initState() {
    super.initState();
    // Lazily register the controller for this route.
    _ctrl = Get.put(OtpController(Get.find<OtpRepository>()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.send(widget.phone);
    });
  }

  @override
  void dispose() {
    Get.delete<OtpController>();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.length != AppConstants.otpLength) return;
    final ok = await _ctrl.verify(phone: widget.phone, code: _code);
    if (!mounted) return;
    if (ok) {
      // Return verified=true to caller (application form).
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Obx(() => OtpInput(
                    length: AppConstants.otpLength,
                    onChanged: (v) => setState(() => _code = v),
                    onCompleted: (_) => _verify(),
                    enabled: !_ctrl.isVerifying.value,
                    errorText: _ctrl.errorMessage.value,
                  )),
              const SizedBox(height: 24),
              Obx(() => AppButton(
                    label: 'Doğrula',
                    isLoading: _ctrl.isVerifying.value,
                    onPressed: _code.length == AppConstants.otpLength
                        ? _verify
                        : null,
                  )),
              const SizedBox(height: 16),
              Center(
                child: Obx(() {
                  final cooldown = _ctrl.cooldownSeconds.value;
                  if (cooldown > 0) {
                    return Text(
                      'Kodu tekrar gönder ($cooldown)',
                      style:
                          const TextStyle(color: AppColors.textSecondary),
                    );
                  }
                  return TextButton(
                    onPressed: _ctrl.isSending.value
                        ? null
                        : () => _ctrl.send(widget.phone),
                    child: const Text('Kodu Tekrar Gönder'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
