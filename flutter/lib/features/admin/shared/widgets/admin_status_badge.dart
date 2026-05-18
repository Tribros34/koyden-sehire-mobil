import 'package:flutter/material.dart';

class AdminStatusBadge extends StatelessWidget {
  final String status;
  const AdminStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' => ('Bekliyor', Colors.amber),
      'approved' || 'active' => ('Onaylı', Colors.green),
      'rejected' => ('Reddedildi', Colors.red),
      'needs_video' => ('Video Gerekli', Colors.orange),
      'hidden' || 'passive' => ('Gizli', Colors.grey),
      'suspended' => ('Askıda', Colors.red),
      _ => (status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
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
