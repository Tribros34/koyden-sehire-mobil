import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/turkish_chars.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/application_provider.dart';
import '../providers/invite_provider.dart';

class InviteEntryScreen extends ConsumerStatefulWidget {
  final String? prefillCode;
  const InviteEntryScreen({super.key, this.prefillCode});

  @override
  ConsumerState<InviteEntryScreen> createState() => _InviteEntryScreenState();
}

class _InviteEntryScreenState extends ConsumerState<InviteEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.prefillCode ?? '');
    if ((widget.prefillCode ?? '').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(inviteValidationProvider.notifier)
            .validate(widget.prefillCode!);
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final code = _codeController.text.trim().toUpperCase();
    final ok =
        await ref.read(inviteValidationProvider.notifier).validate(code);
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(inviteValidationProvider).errorMessage;
      if (err != null) context.snack(err, isError: true);
    }
  }

  void _continue() {
    final info = ref.read(inviteValidationProvider).info;
    if (info == null) return;
    ref.read(applicationFormProvider.notifier).reset();
    ref.read(applicationFormProvider.notifier).setInvite(info);
    context.push('/apply/form');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inviteValidationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Üretici Başvurusu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Davet Kodu', style: context.text.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Üretici başvuruları davet sistemiyle alınmaktadır. Lütfen size iletilen davet kodunu girin.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Davet Kodu',
                  hint: 'KYS-XXXXXX',
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  validator: Validators.inviteCode,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    TextInputFormatter.withFunction((old, neu) {
                      return neu.copyWith(text: TurkishChars.toUpper(neu.text));
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Kodu Doğrula',
                  isLoading: state.isLoading,
                  onPressed: state.isLoading ? null : _validate,
                ),
                if (state.info != null) ...[
                  const SizedBox(height: 24),
                  _InviteInfoCard(
                    inviterName: state.info!.inviterName,
                    remainingUses: state.info!.remainingUses,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Başvuruya Devam Et',
                    onPressed: _continue,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteInfoCard extends StatelessWidget {
  final String? inviterName;
  final int remainingUses;
  const _InviteInfoCard({
    required this.inviterName,
    required this.remainingUses,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inviterName == null
                      ? 'Davet kodu doğrulandı.'
                      : '$inviterName sizi Köyden Şehre\'ye davet etti.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (remainingUses > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Bu kodun $remainingUses kullanım hakkı kaldı.',
                    style: const TextStyle(color: AppColors.textSecondary),
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
