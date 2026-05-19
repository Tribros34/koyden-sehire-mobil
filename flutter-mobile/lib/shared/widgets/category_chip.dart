import 'package:flutter/material.dart';

import 'package:koyden_sehire/app/theme.dart';

class AppCategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const AppCategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = selected
        ? cs.primaryContainer
        : cs.secondaryContainer.withValues(alpha: 0.45);
    final fgColor = selected ? cs.onPrimary : cs.secondary;

    return Material(
      color: bgColor,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fgColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
