import 'package:flutter/material.dart';

import '../../app/theme.dart';

class FoundingBadge extends StatelessWidget {
  final bool small;
  const FoundingBadge({super.key, this.small = true});

  @override
  Widget build(BuildContext context) {
    final fontSize = small ? 11.0 : 13.0;
    final iconSize = small ? 14.0 : 18.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: AppColors.secondary, size: iconSize),
          const SizedBox(width: 4),
          Text(
            'Kurucu Üretici',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
