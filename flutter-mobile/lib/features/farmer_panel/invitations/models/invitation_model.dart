class InviteCodeItem {
  final String id;
  final String code;
  final int maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;
  final List<InvitedPerson> invited;

  const InviteCodeItem({
    required this.id,
    required this.code,
    required this.maxUses,
    required this.usedCount,
    required this.isActive,
    this.expiresAt,
    this.invited = const [],
  });

  int get remaining => (maxUses - usedCount).clamp(0, maxUses);

  factory InviteCodeItem.fromJson(Map<String, dynamic> json) {
    final invitedList = (json['invitations'] as List?) ?? const [];
    return InviteCodeItem(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      maxUses: (json['max_uses'] as num?)?.toInt() ?? 0,
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] != false,
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      invited: invitedList
          .whereType<Map>()
          .map((m) => InvitedPerson.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class InvitedPerson {
  final String? name;
  final String status; // submitted | approved | rejected
  final DateTime? createdAt;

  const InvitedPerson({this.name, required this.status, this.createdAt});

  factory InvitedPerson.fromJson(Map<String, dynamic> json) => InvitedPerson(
        name: json['full_name']?.toString() ?? json['name']?.toString(),
        status: json['status']?.toString() ?? 'submitted',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}
