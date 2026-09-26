class RegisterRequestDto {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String role;

  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.role = 'user',
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      };
}

class LoginRequestDto {
  final String email;
  final String password;

  const LoginRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class FundWalletRequestDto {
  final double amount;

  const FundWalletRequestDto({required this.amount});

  Map<String, dynamic> toJson() => {'amount': amount};
}
