abstract class Validators {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+'
    r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
    r'\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email address is required.';
    if (!_emailRegex.hasMatch(value.trim())) return 'Please enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters long.';
    if (value.length > 128) return 'Password is too long (max 128 characters).';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    return null;
  }

  static String? firstName(String? value) {
    if (value == null || value.trim().isEmpty) return 'First name is required.';
    if (value.trim().length > 50) return 'First name must be at most 50 characters.';
    return null;
  }

  static String? lastName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Last name is required.';
    if (value.trim().length > 50) return 'Last name must be at most 50 characters.';
    return null;
  }

  static final _phoneRegex = RegExp(r'^\+?[\d\s\-().]+$');

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    if (value.trim().length < 7) return 'Phone number must be at least 7 digits.';
    if (value.trim().length > 20) return 'Phone number must be at most 20 characters.';
    if (!_phoneRegex.hasMatch(value.trim())) return 'Phone number contains invalid characters.';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required.';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Amount must be a valid number.';
    if (n <= 0) return 'Amount must be a positive number.';
    if (n > 10000000) return 'Amount must not exceed ₦10,000,000.';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required.';
    return null;
  }
}
