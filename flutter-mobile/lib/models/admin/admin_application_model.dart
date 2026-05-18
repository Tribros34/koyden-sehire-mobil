class AdminApplication {
  final String id;
  final String fullName;
  final String phone;
  final String businessName;
  final String producerType;
  final String city;
  final String district;
  final String? village;
  final String? productExamples;
  final String status;
  final DateTime createdAt;
  final String? inviteCode;
  final String? inviteTrust;
  final String? riskLevel;
  final String? profileDescription;
  final String? videoUrl;
  final String? adminNotes;

  const AdminApplication({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.businessName,
    required this.producerType,
    required this.city,
    required this.district,
    this.village,
    this.productExamples,
    required this.status,
    required this.createdAt,
    this.inviteCode,
    this.inviteTrust,
    this.riskLevel,
    this.profileDescription,
    this.videoUrl,
    this.adminNotes,
  });

  factory AdminApplication.fromJson(Map<String, dynamic> json) {
    return AdminApplication(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      producerType: json['producer_type']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      village: json['village']?.toString(),
      productExamples: json['product_examples']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
      inviteCode: json['invite_code']?.toString(),
      inviteTrust: json['invite_trust']?.toString(),
      riskLevel: json['risk_level']?.toString(),
      profileDescription: json['profile_description']?.toString(),
      videoUrl: json['video_url']?.toString(),
      adminNotes: json['admin_notes']?.toString(),
    );
  }
}
