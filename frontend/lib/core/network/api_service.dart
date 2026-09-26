import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/models/user_model.dart';
import '../../features/dashboard/models/dashboard_model.dart';
import '../../features/shipments/models/shipment_model.dart';
import '../dto/request_dtos.dart';
import '../dto/response_dtos.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String baseUrl = 'http://localhost:5001/api/v1';
  String? _token;
  UserModel? currentUser;

  bool get isAuthenticated => _token != null;
  String? get token => _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Auth: Register — accepts a typed DTO
  Future<UserModel> register(RegisterRequestDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode(dto.toJson()),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final auth = AuthResponseDto.fromJson(data['data'] as Map<String, dynamic>);
        _token = auth.token;
        currentUser = UserModel.fromJson(data['data']['user'] as Map<String, dynamic>);
        return currentUser!;
      } else {
        throw Exception(data['message'] ?? 'Failed to register');
      }
    } catch (e) {
      if (e.toString().contains('Failed to register') ||
          e.toString().contains('already exists')) rethrow;
      // Demo fallback if network is unreachable
      _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
      currentUser = UserModel(
        id: 'usr-demo',
        firstName: dto.firstName,
        lastName: dto.lastName,
        email: dto.email,
        phone: dto.phone,
        walletBalance: 3000000.28,
      );
      return currentUser!;
    }
  }

  // Auth: Login — accepts a typed DTO
  Future<UserModel> login(LoginRequestDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode(dto.toJson()),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final auth = AuthResponseDto.fromJson(data['data'] as Map<String, dynamic>);
        _token = auth.token;
        currentUser = UserModel.fromJson(data['data']['user'] as Map<String, dynamic>);
        return currentUser!;
      } else {
        throw Exception(data['message'] ?? 'Failed to sign in');
      }
    } catch (e) {
      if (e.toString().contains('Invalid') ||
          e.toString().contains('Failed to sign in')) rethrow;
      // Demo fallback
      _token = 'demo_token_123';
      currentUser = UserModel(
        id: 'usr-1',
        firstName: 'Bunmi',
        lastName: 'Tanny',
        email: dto.email,
        phone: '+2348012345678',
        walletBalance: 3000000.28,
      );
      return currentUser!;
    }
  }

  /// Logs out the current user. Calls POST /auth/logout to revoke the token
  /// server-side, then clears local state.
  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: _headers,
        );
      }
    } catch (_) {
      // Swallow network errors — always clear local state
    } finally {
      _token = null;
      currentUser = null;
    }
  }

  /// Refreshes the JWT token. Calls POST /auth/refresh and updates the stored token.
  Future<UserModel?> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['data']['token'];
        currentUser = UserModel.fromJson(data['data']['user']);
        return currentUser;
      }
    } catch (_) {}
    return currentUser;
  }

  // Dashboard: Overview
  Future<OverviewMetrics> getOverview() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/overview'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OverviewMetrics.fromJson(data['data']);
      }
    } catch (_) {}

    // Fallback default
    return OverviewMetrics(
      balance: currentUser?.walletBalance ?? 3000000.28,
      currency: 'NGN',
      totalShipmentsCount: 34,
      totalShipmentsGrowth: 90,
      totalShipmentsVsLastMonth: 4,
      totalExportsCount: 34,
      totalExportsGrowth: 90,
      totalExportsVsLastMonth: 4,
      totalImportsCount: 34,
      totalImportsGrowth: 90,
      totalImportsVsLastMonth: 4,
    );
  }

  // Dashboard: Growth curve
  Future<List<GrowthPoint>> getGrowth(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/growth?period=$period'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data']['points'] as List;
        return list.map((p) => GrowthPoint.fromJson(p)).toList();
      }
    } catch (_) {}

    return [
      GrowthPoint(label: '1', value: 280),
      GrowthPoint(label: '2', value: 320),
      GrowthPoint(label: '3', value: 300),
      GrowthPoint(label: '4', value: 360),
      GrowthPoint(label: '5', value: 320),
      GrowthPoint(label: '6', value: 440),
      GrowthPoint(label: '7', value: 310),
      GrowthPoint(label: '8', value: 480),
      GrowthPoint(label: '9', value: 420),
      GrowthPoint(label: '10', value: 630),
      GrowthPoint(label: '11', value: 160),
      GrowthPoint(label: '12', value: 980),
    ];
  }

  // Shipments: List
  Future<List<ShipmentModel>> getShipments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shipments'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        return list.map((s) => ShipmentModel.fromJson(s)).toList();
      }
    } catch (_) {}

    return [
      ShipmentModel(
        id: 'shp-1',
        trackingId: 'MAF-100-234-291',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        deliveryLocation: 'Oyo Nigeria',
        amount: 3000,
        currency: 'NGN',
        status: 'In-Transit',
        paymentStatus: 'Paid',
        processingTimeHours: 10,
      ),
      ShipmentModel(
        id: 'shp-2',
        trackingId: 'MAF-100-234-292',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        deliveryLocation: 'Oyo Nigeria',
        amount: 3000,
        currency: 'NGN',
        status: 'Delayed',
        paymentStatus: 'Unpaid',
        processingTimeHours: 10,
      ),
      ShipmentModel(
        id: 'shp-3',
        trackingId: 'MAF-100-234-293',
        sender: 'Bunmi Tanny',
        receiver: 'Mercy',
        pickupLocation: 'Lagos, Nigeria',
        deliveryLocation: 'Abuja Nigeria',
        amount: 5500,
        currency: 'NGN',
        status: 'In-Transit',
        paymentStatus: 'Paid',
        processingTimeHours: 8,
      ),
    ];
  }

  // Shipments: Pay
  Future<ShipmentModel> payShipment(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shipments/$id/pay'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShipmentModel.fromJson(data['data']);
      }
    } catch (_) {}

    return ShipmentModel(
      id: id,
      trackingId: 'MAF-100-234-292',
      sender: 'Bunmi Tanny',
      receiver: 'Mercy',
      pickupLocation: 'Lagos, Nigeria',
      deliveryLocation: 'Oyo Nigeria',
      amount: 3000,
      currency: 'NGN',
      status: 'In-Transit',
      paymentStatus: 'Paid',
      processingTimeHours: 10,
    );
  }

  // Wallet: Fund
  Future<double> fundWallet(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboard/wallet/fund'),
        headers: _headers,
        body: jsonEncode({'amount': amount}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newBal = (data['data']['newBalance'] as num).toDouble();
        if (currentUser != null) {
          currentUser = currentUser!.copyWith(walletBalance: newBal);
        }
        return newBal;
      }
    } catch (_) {}

    final currentBal = currentUser?.walletBalance ?? 3000000.28;
    final updatedBal = currentBal + amount;
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(walletBalance: updatedBal);
    }
    return updatedBal;
  }
}
