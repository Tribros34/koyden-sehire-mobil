class InviteNode {
  final String id;
  final String fullName;
  final String city;
  final String? inviteCode;
  final double trustScore;
  final bool isFoundingFarmer;
  final List<InviteNode> invitees;

  const InviteNode({
    required this.id,
    required this.fullName,
    required this.city,
    this.inviteCode,
    required this.trustScore,
    required this.isFoundingFarmer,
    required this.invitees,
  });

  factory InviteNode.fromJson(Map<String, dynamic> json) => InviteNode(
        id: json['id']?.toString() ?? '',
        fullName:
            json['full_name']?.toString() ?? json['name']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        inviteCode: json['invite_code']?.toString(),
        trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
        isFoundingFarmer: json['is_founding_farmer'] == true,
        invitees: ((json['invitees'] ?? json['children']) as List? ?? [])
            .map((e) => InviteNode.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
