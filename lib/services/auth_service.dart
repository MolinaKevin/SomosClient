import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/environment_config.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ---------------- Helpers ----------------

  Future<void> _saveUserData(String token, Map<String, dynamic> user) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(key: 'user_name', value: user['name'] ?? '');
    await _secureStorage.write(key: 'user_email', value: user['email'] ?? '');
    await _secureStorage.write(
      key: 'user_phone',
      value: user['phone_number'] ?? user['phone'] ?? '',
    );
    await _secureStorage.write(
      key: 'profile_photo_url',
      value: user['profile_photo_url'] ?? '',
    );
    await _secureStorage.write(key: 'user_pass', value: user['pass'] ?? '');
    await _secureStorage.write(
      key: 'user_referrer_pass',
      value: user['referrer_pass'] ?? '',
    );
  }

  Future<String?> getToken() async => _secureStorage.read(key: 'auth_token');

  // ---------------- MOCKS ----------------

  String get _mockToken => 'mock-token-${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> _mockUser({
    String name = 'Mock User',
    String email = 'mock@example.com',
  }) {
    return {
      'id': -99,
      'name': name,
      'email': email,
      'phone_number': '+49 176 00000000',
      'profile_photo_url': 'https://picsum.photos/seed/mockuser/128',
      'background_image': 'https://picsum.photos/seed/mockbg/800/400',
      'points': 128.5,
      'referrals': {
        'level1': 2,
        'level2': 1,
        'level3': 0,
      },
      'lowlevelrefs': 1,
      'pass': '',
      'referrer_pass': '',
    };
  }

  // ---------------- Login ----------------

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (EnvironmentConfig.mockServer) {
      debugPrint('🔌 MOCK_SERVER: login() → éxito simulado');
      final token = _mockToken;
      final user = _mockUser(email: email);
      await _saveUserData(token, user);
      return {'success': true, 'user': user};
    }

    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    debugPrint('Attempting login with email: $email');

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint('Login response code: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];
        await _saveUserData(token, user);
        return {'success': true, 'user': user};
      } else {
        final errorData = _safeDecode(response.body);
        return {'success': false, 'error': errorData};
      }
    } catch (e) {
      debugPrint('Login failed with error: $e');
      if (EnvironmentConfig.mockServer) {
        final token = _mockToken;
        final user = _mockUser(email: email);
        await _saveUserData(token, user);
        return {'success': true, 'user': user};
      }
      rethrow;
    }
  }

  // ---------------- Register ----------------

  Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String confirmPassword,
      ) async {
    if (EnvironmentConfig.mockServer) {
      debugPrint('🔌 MOCK_SERVER: register() → éxito simulado');
      final token = _mockToken;
      final user = _mockUser(name: name, email: email);
      await _saveUserData(token, user);
      return {'success': true, 'user': user};
    }

    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    });

    debugPrint('Attempting registration with email: $email');

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint('Register response code: ${response.statusCode}');
      debugPrint('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = data['user'];
        await _saveUserData(token, user);
        return {'success': true, 'user': user};
      } else {
        final errorData = _safeDecode(response.body);
        return {'success': false, 'error': errorData};
      }
    } catch (e) {
      debugPrint('Registration failed with error: $e');
      if (EnvironmentConfig.mockServer) {
        final token = _mockToken;
        final user = _mockUser(name: name, email: email);
        await _saveUserData(token, user);
        return {'success': true, 'user': user};
      }
      rethrow;
    }
  }

  // ---------------- Fetch user (perfil simple) ----------------

  Future<Map<String, dynamic>> fetchUserDetails() async {
    final token = await getToken();
    if (token == null) {
      if (EnvironmentConfig.mockServer) {
        final mock = _mockUser();
        await _saveUserData(_mockToken, mock);
        return mock;
      }
      throw Exception('Token not found');
    }

    if (EnvironmentConfig.mockServer) {
      debugPrint('🔌 MOCK_SERVER: fetchUserDetails() → mock');
      final mock = _mockUser();
      await _saveUserData(token, mock);
      return mock;
    }

    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('Fetching user details with token: $token');

    final response = await http.get(url, headers: headers);
    debugPrint('Fetch user details response code: ${response.statusCode}');
    debugPrint('Fetch user details response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = _safeDecode(response.body);
      await _saveUserData(token, data);
      return data;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  // ---------------- Fetch user data (con puntos/referrals) ----------------

  Future<Map<String, dynamic>> fetchUserData() async {
    final token = await getToken();

    if (EnvironmentConfig.mockServer || token == null) {
      debugPrint('🔌 MOCK_SERVER: fetchUserData() → mock');
      final data = _mockUser();

      // Normalizar referrals -> Map<String, dynamic> y sumar como int
      final Map<String, dynamic> referrals =
      (data['referrals'] is Map) ? Map<String, dynamic>.from(data['referrals']) : {};
      final int totalReferrals = referrals.values
          .map((v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0)
          .fold<int>(0, (a, b) => a + b);

      await _saveUserData(token ?? _mockToken, data);
      return {
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'] ?? data['phone_number'],
        'points': data['points'] ?? 0,
        'profile_photo_url': data['profile_photo_url'] ?? '',
        'totalReferrals': totalReferrals,
        'referrals': referrals,
        'lowerLevelReferrals': data['lowlevelrefs'] ?? 0,
      };
    }

    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/data');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('Fetching user data with token: $token');

    final response = await http.get(url, headers: headers);
    debugPrint('Fetch user data response code: ${response.statusCode}');
    debugPrint('Fetch user data response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = _safeDecode(response.body);

      final Map<String, dynamic> referrals =
      (data['referrals'] is Map) ? Map<String, dynamic>.from(data['referrals']) : {};
      final int totalReferrals = referrals.values
          .map((v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0)
          .fold<int>(0, (a, b) => a + b);

      await _saveUserData(token, data);
      return {
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'],
        'points': data['points'] ?? 0,
        'profile_photo_url': data['profile_photo_url'] ?? '',
        'totalReferrals': totalReferrals,
        'referrals': referrals,
        'lowerLevelReferrals': data['lowlevelrefs'] ?? 0,
      };
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // ---------------- Logout ----------------

  Future<void> logout() async {
    debugPrint('Logging out, clearing all secure storage.');
    await _secureStorage.deleteAll();
  }

  // ---------------- Utils ----------------

  dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'raw': body};
    }
  }
}
