class CityDensity {
  final String city;
  final int farmerCount;
  final int pendingApplications;
  final String riskLevel;

  const CityDensity({
    required this.city,
    required this.farmerCount,
    required this.pendingApplications,
    required this.riskLevel,
  });

  bool get isHighRisk => riskLevel == 'high';
  bool get isMediumRisk => riskLevel == 'medium';

  factory CityDensity.fromJson(Map<String, dynamic> json) => CityDensity(
        city: json['city']?.toString() ?? '',
        farmerCount: (json['farmer_count'] as num?)?.toInt() ?? 0,
        pendingApplications:
            (json['pending_applications'] as num?)?.toInt() ?? 0,
        riskLevel: json['risk_level']?.toString() ?? 'low',
      );
}
