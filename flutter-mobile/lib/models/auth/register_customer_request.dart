class RegisterCustomerRequest {
  final String phone;
  final String fullName;
  final String email;
  final String password;

  const RegisterCustomerRequest({
    required this.phone,
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'full_name': fullName,
        'email': email,
        'password': password,
      };
}
