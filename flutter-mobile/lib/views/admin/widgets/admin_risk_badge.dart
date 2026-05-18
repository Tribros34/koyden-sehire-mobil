import 'package:flutter/material.dart';

class AdminRiskBadge extends StatelessWidget {
  final String level;
  const AdminRiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      'low' => ('Düşük', Colors.green),
      'medium' => ('Orta', Colors.amber),
      'high' => ('Yüksek', Colors.red),
      _ => (level, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }
}
