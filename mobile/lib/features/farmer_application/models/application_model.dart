/// Validated invite payload returned from `GET /invites/validate`.
class InviteInfo {
  final String code;
  final String? inviterName;
  final int maxUses;
  final int usedCount;

  const InviteInfo({
    required this.code,
    this.inviterName,
    required this.maxUses,
    required this.usedCount,
  });

  int get remainingUses => maxUses - usedCount;

  factory InviteInfo.fromJson(Map<String, dynamic> json) => InviteInfo(
        code: json['code']?.toString() ?? '',
        inviterName: json['inviter_name']?.toString() ??
            (json['inviter'] as Map?)?['display_name']?.toString() ??
            (json['inviter'] as Map?)?['full_name']?.toString(),
        maxUses: (json['max_uses'] as num?)?.toInt() ?? 0,
        usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      );
}

class ApplicationFormData {
  // Step 1
  final String fullName;
  final String phone;
  final String? email;
  final String password;

  // Step 2
  final String businessName;
  final String? producerType;
  final String city;
  final String district;
  final String village;
  final String bio;

  // Step 3
  final List<String> productCategorySlugs;
  final String productExamples;
  final String? productionPlaceType;
  final String? applicationNote;

  // Step 4
  final String? applicationVideoKey;

  // Step 5 (consents)
  final bool kvkkAccepted;
  final bool platformTermsAccepted;
  final bool declaresOwnProduction;
  final bool declaresAccurateLocation;
  final bool declaresNotIntermediary;

  const ApplicationFormData({
    this.fullName = '',
    this.phone = '',
    this.email,
    this.password = '',
    this.businessName = '',
    this.producerType,
    this.city = '',
    this.district = '',
    this.village = '',
    this.bio = '',
    this.productCategorySlugs = const [],
    this.productExamples = '',
    this.productionPlaceType,
    this.applicationNote,
    this.applicationVideoKey,
    this.kvkkAccepted = false,
    this.platformTermsAccepted = false,
    this.declaresOwnProduction = false,
    this.declaresAccurateLocation = false,
    this.declaresNotIntermediary = false,
  });

  ApplicationFormData copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? businessName,
    String? producerType,
    String? city,
    String? district,
    String? village,
    String? bio,
    List<String>? productCategorySlugs,
    String? productExamples,
    String? productionPlaceType,
    String? applicationNote,
    String? applicationVideoKey,
    bool? kvkkAccepted,
    bool? platformTermsAccepted,
    bool? declaresOwnProduction,
    bool? declaresAccurateLocation,
    bool? declaresNotIntermediary,
    bool clearVideoKey = false,
  }) =>
      ApplicationFormData(
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        password: password ?? this.password,
        businessName: businessName ?? this.businessName,
        producerType: producerType ?? this.producerType,
        city: city ?? this.city,
        district: district ?? this.district,
        village: village ?? this.village,
        bio: bio ?? this.bio,
        productCategorySlugs:
            productCategorySlugs ?? this.productCategorySlugs,
        productExamples: productExamples ?? this.productExamples,
        productionPlaceType: productionPlaceType ?? this.productionPlaceType,
        applicationNote: applicationNote ?? this.applicationNote,
        applicationVideoKey: clearVideoKey
            ? null
            : (applicationVideoKey ?? this.applicationVideoKey),
        kvkkAccepted: kvkkAccepted ?? this.kvkkAccepted,
        platformTermsAccepted:
            platformTermsAccepted ?? this.platformTermsAccepted,
        declaresOwnProduction:
            declaresOwnProduction ?? this.declaresOwnProduction,
        declaresAccurateLocation:
            declaresAccurateLocation ?? this.declaresAccurateLocation,
        declaresNotIntermediary:
            declaresNotIntermediary ?? this.declaresNotIntermediary,
      );

  Map<String, dynamic> toJson({required String inviteCode}) => {
        'invite_code': inviteCode,
        'full_name': fullName,
        'phone': phone,
        if (email != null && email!.isNotEmpty) 'email': email,
        'password': password,
        'business_name': businessName,
        'producer_type': producerType,
        'city': city,
        'district': district,
        'village': village,
        'bio': bio,
        'product_categories': productCategorySlugs,
        'product_examples': productExamples,
        if (productionPlaceType != null)
          'production_place_type': productionPlaceType,
        if (applicationNote != null && applicationNote!.isNotEmpty)
          'application_note': applicationNote,
        if (applicationVideoKey != null)
          'application_video_key': applicationVideoKey,
        'kvkk_accepted': kvkkAccepted,
        'platform_terms_accepted': platformTermsAccepted,
        'declares_own_production': declaresOwnProduction,
        'declares_accurate_location': declaresAccurateLocation,
        'declares_not_intermediary': declaresNotIntermediary,
      };
}
