import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  String? _customBaseUrl;

  String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
        return 'http://localhost:5001/api/v1';
      }
      if (origin.isNotEmpty && !origin.startsWith('file://')) {
        if (origin.contains('backend')) {
          return '$origin/api/v1';
        }
      }
    }
    return 'https://securebypay-backend-69wy.onrender.com/api/v1';
  }

  set baseUrl(String url) {
    _customBaseUrl = url;
  }
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

  Future<UserModel> register(RegisterRequestDto dto) async {
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
  }

  Future<UserModel> login(LoginRequestDto dto) async {
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
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: _headers,
        );
      }
    } catch (_) {
    } finally {
      _token = null;
      currentUser = null;
    }
  }

  Future<UserModel?> refreshToken() async {
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
    return currentUser;
  }

  Future<OverviewMetrics> getOverview() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/overview'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return OverviewMetrics.fromJson(data['data']);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to load overview data');
    }
  }

  Future<List<GrowthPoint>> getGrowth(String period) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/growth?period=$period'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final list = data['data']['points'] as List;
      return list.map((p) => GrowthPoint.fromJson(p)).toList();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to load growth data');
    }
  }

  Future<List<ShipmentModel>> getShipments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/shipments'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((s) => ShipmentModel.fromJson(s)).toList();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to load shipments');
    }
  }

  Future<ShipmentModel> payShipment(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shipments/$id/pay'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return ShipmentModel.fromJson(data['data']['shipment'] ?? data['data']);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to process shipment payment');
    }
  }

  Future<double> fundWallet(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dashboard/wallet/fund'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final newBal = (data['data']['newBalance'] as num).toDouble();
      if (currentUser != null) {
        currentUser = currentUser!.copyWith(walletBalance: newBal);
      }
      return newBal;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to fund wallet');
    }
  }
}
