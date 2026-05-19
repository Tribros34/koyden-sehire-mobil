import 'package:flutter/material.dart';

import 'package:koyden_sehire/app/theme.dart';

class FoundingBadge extends StatelessWidget {
  final bool small;
  const FoundingBadge({super.key, this.small = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconSize = small ? 14.0 : 18.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? AppSpacing.sm : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: cs.tertiary, size: iconSize),
          const SizedBox(width: 4),
          Text(
            'Kurucu Üretici',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.tertiary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
