import 'package:flutter/material.dart';

import 'package:koyden_sehire/app/theme.dart';

class VerifiedBadge extends StatelessWidget {
  final bool small;
  const VerifiedBadge({super.key, this.small = true});

  @override
  Widget build(BuildContext context) {
    final iconSize = small ? 14.0 : 18.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? AppSpacing.sm : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: AppColors.success, size: iconSize),
          const SizedBox(width: 4),
          Text(
            'Doğrulanmış Üretici',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
