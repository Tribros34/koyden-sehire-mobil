class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role; // 'farmer' | 'admin'
  final String status; // 'active' | 'suspended'

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
  });

  bool get isFarmer => role == 'farmer';
  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString(),
        role: json['role']?.toString() ?? 'farmer',
        status: json['status']?.toString() ?? 'active',
      );
}
