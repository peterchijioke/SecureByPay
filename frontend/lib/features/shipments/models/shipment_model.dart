class ShipmentModel {
  final String id;
  final String trackingId;
  final String sender;
  final String receiver;
  final String pickupLocation;
  final String deliveryLocation;
  final double amount;
  final String currency;
  String status;
  String paymentStatus;
  final int processingTimeHours;

  ShipmentModel({
    required this.id,
    required this.trackingId,
    required this.sender,
    required this.receiver,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.processingTimeHours,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] ?? '',
      trackingId: json['trackingId'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      deliveryLocation: json['deliveryLocation'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 3000,
      currency: json['currency'] ?? 'NGN',
      status: json['status'] ?? 'In-Transit',
      paymentStatus: json['paymentStatus'] ?? 'Unpaid',
      processingTimeHours: json['processingTimeHours'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trackingId': trackingId,
        'sender': sender,
        'receiver': receiver,
        'pickupLocation': pickupLocation,
        'deliveryLocation': deliveryLocation,
        'amount': amount,
        'currency': currency,
        'status': status,
        'paymentStatus': paymentStatus,
        'processingTimeHours': processingTimeHours,
      };
}
