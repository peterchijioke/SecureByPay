class OverviewMetrics {
  final double balance;
  final String currency;
  final int totalShipmentsCount;
  final double totalShipmentsGrowth;
  final int totalShipmentsVsLastMonth;
  final int totalExportsCount;
  final double totalExportsGrowth;
  final int totalExportsVsLastMonth;
  final int totalImportsCount;
  final double totalImportsGrowth;
  final int totalImportsVsLastMonth;

  OverviewMetrics({
    required this.balance,
    required this.currency,
    required this.totalShipmentsCount,
    required this.totalShipmentsGrowth,
    required this.totalShipmentsVsLastMonth,
    required this.totalExportsCount,
    required this.totalExportsGrowth,
    required this.totalExportsVsLastMonth,
    required this.totalImportsCount,
    required this.totalImportsGrowth,
    required this.totalImportsVsLastMonth,
  });

  factory OverviewMetrics.fromJson(Map<String, dynamic> json) {
    return OverviewMetrics(
      balance: (json['balance'] as num?)?.toDouble() ?? 3000000.28,
      currency: json['currency'] ?? 'NGN',
      totalShipmentsCount: json['totalShipments']?['count'] ?? 34,
      totalShipmentsGrowth:
          (json['totalShipments']?['growthPercentage'] as num?)?.toDouble() ?? 90,
      totalShipmentsVsLastMonth:
          json['totalShipments']?['vsLastMonth'] ?? 4,
      totalExportsCount: json['totalExports']?['count'] ?? 34,
      totalExportsGrowth:
          (json['totalExports']?['growthPercentage'] as num?)?.toDouble() ?? 90,
      totalExportsVsLastMonth: json['totalExports']?['vsLastMonth'] ?? 4,
      totalImportsCount: json['totalImports']?['count'] ?? 34,
      totalImportsGrowth:
          (json['totalImports']?['growthPercentage'] as num?)?.toDouble() ?? 90,
      totalImportsVsLastMonth: json['totalImports']?['vsLastMonth'] ?? 4,
    );
  }
}

class GrowthPoint {
  final String label;
  final double value;

  GrowthPoint({required this.label, required this.value});

  factory GrowthPoint.fromJson(Map<String, dynamic> json) {
    return GrowthPoint(
      label: json['label'].toString(),
      value: (json['value'] as num).toDouble(),
    );
  }
}
