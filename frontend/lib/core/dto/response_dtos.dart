class UserResponseDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final double walletBalance;
  final String currency;
  final String createdAt;

  const UserResponseDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.walletBalance,
    required this.currency,
    required this.createdAt,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) => UserResponseDto(
        id: json['id'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'user',
        walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'NGN',
        createdAt: json['createdAt'] as String? ?? '',
      );

  String get fullName => '$firstName $lastName'.trim();
}

class AuthResponseDto {
  final String token;
  final UserResponseDto user;

  const AuthResponseDto({required this.token, required this.user});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => AuthResponseDto(
        token: json['token'] as String,
        user: UserResponseDto.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class MetricBlockDto {
  final int count;
  final double growthPercentage;
  final int vsLastMonth;

  const MetricBlockDto({
    required this.count,
    required this.growthPercentage,
    required this.vsLastMonth,
  });

  factory MetricBlockDto.fromJson(Map<String, dynamic> json) => MetricBlockDto(
        count: (json['count'] as num?)?.toInt() ?? 0,
        growthPercentage: (json['growthPercentage'] as num?)?.toDouble() ?? 0.0,
        vsLastMonth: (json['vsLastMonth'] as num?)?.toInt() ?? 0,
      );
}

class OverviewResponseDto {
  final double balance;
  final String currency;
  final MetricBlockDto totalShipments;
  final MetricBlockDto totalExports;
  final MetricBlockDto totalImports;

  const OverviewResponseDto({
    required this.balance,
    required this.currency,
    required this.totalShipments,
    required this.totalExports,
    required this.totalImports,
  });

  factory OverviewResponseDto.fromJson(Map<String, dynamic> json) => OverviewResponseDto(
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'NGN',
        totalShipments: MetricBlockDto.fromJson(json['totalShipments'] as Map<String, dynamic>? ?? {}),
        totalExports: MetricBlockDto.fromJson(json['totalExports'] as Map<String, dynamic>? ?? {}),
        totalImports: MetricBlockDto.fromJson(json['totalImports'] as Map<String, dynamic>? ?? {}),
      );
}

class GrowthPointDto {
  final String label;
  final double value;

  const GrowthPointDto({required this.label, required this.value});

  factory GrowthPointDto.fromJson(Map<String, dynamic> json) => GrowthPointDto(
        label: json['label'] as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
      );
}

class GrowthResponseDto {
  final String period;
  final List<GrowthPointDto> points;

  const GrowthResponseDto({required this.period, required this.points});

  factory GrowthResponseDto.fromJson(Map<String, dynamic> json) => GrowthResponseDto(
        period: json['period'] as String? ?? 'year',
        points: (json['points'] as List<dynamic>? ?? [])
            .map((p) => GrowthPointDto.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}

class FundWalletResponseDto {
  final double newBalance;

  const FundWalletResponseDto({required this.newBalance});

  factory FundWalletResponseDto.fromJson(Map<String, dynamic> json) =>
      FundWalletResponseDto(newBalance: (json['newBalance'] as num?)?.toDouble() ?? 0.0);
}

class ShipmentResponseDto {
  final String id;
  final String trackingId;
  final String sender;
  final String receiver;
  final String pickupLocation;
  final String pickupCountry;
  final String deliveryLocation;
  final String deliveryCountry;
  final double amount;
  final String currency;
  final String status;
  final String paymentStatus;
  final int processingTimeHours;
  final String createdAt;
  final String userId;

  const ShipmentResponseDto({
    required this.id,
    required this.trackingId,
    required this.sender,
    required this.receiver,
    required this.pickupLocation,
    required this.pickupCountry,
    required this.deliveryLocation,
    required this.deliveryCountry,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.processingTimeHours,
    required this.createdAt,
    required this.userId,
  });

  factory ShipmentResponseDto.fromJson(Map<String, dynamic> json) => ShipmentResponseDto(
        id: json['id'] as String? ?? '',
        trackingId: json['trackingId'] as String? ?? '',
        sender: json['sender'] as String? ?? '',
        receiver: json['receiver'] as String? ?? '',
        pickupLocation: json['pickupLocation'] as String? ?? '',
        pickupCountry: json['pickupCountry'] as String? ?? '',
        deliveryLocation: json['deliveryLocation'] as String? ?? '',
        deliveryCountry: json['deliveryCountry'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'NGN',
        status: json['status'] as String? ?? '',
        paymentStatus: json['paymentStatus'] as String? ?? '',
        processingTimeHours: (json['processingTimeHours'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
      );
}
