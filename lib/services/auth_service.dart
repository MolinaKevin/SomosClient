import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Helper to save user data in secure storage
  Future<void> _saveUserData(String token, Map<String, dynamic> user) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(key: 'user_name', value: user['name']);
    await _secureStorage.write(key: 'user_email', value: user['email']);
    await _secureStorage.write(key: 'user_phone', value: user['phone_number'] ?? '');
    await _secureStorage.write(key: 'profile_photo_url', value: user['profile_photo_url'] ?? '');
    await _secureStorage.write(key: 'user_pass', value: user['pass'] ?? '');
    await _secureStorage.write(key: 'user_referrer_pass', value: user['referrer_pass'] ?? '');
  }

  // Helper to get token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    print('Attempting login with email: $email');

    final response = await http.post(url, headers: headers, body: body);
    print('Login response code: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      print('Login successful. Token: $token, User: $user');

      await _saveUserData(token, user);
      return {'success': true, 'user': user};
    } else {
      final errorData = jsonDecode(response.body);
      print('Login failed with error: $errorData');
      return {'success': false, 'error': errorData};
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(String name, String email, String password, String confirmPassword) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    });

    print('Attempting registration with email: $email');

    final response = await http.post(url, headers: headers, body: body);
    print('Register response code: ${response.statusCode}');
    print('Register response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      print('Registration successful. Token: $token, User: $user');

      await _saveUserData(token, user);
      return {'success': true, 'user': user};
    } else {
      final errorData = jsonDecode(response.body);
      print('Registration failed with error: $errorData');
      return {'success': false, 'error': errorData};
    }
  }

  // Fetch user details
  Future<Map<String, dynamic>> fetchUserDetails() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('Fetching user details with token: $token');

    final response = await http.get(url, headers: headers);
    print('Fetch user details response code: ${response.statusCode}');
    print('Fetch user details response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User details received: $data');

      await _saveUserData(token, data);
      return data;
    } else {
      print('Failed to fetch user details');
      throw Exception('Failed to load user details');
    }
  }

  // Fetch user data and referrals
  Future<Map<String, dynamic>> fetchUserData() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/data');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('Fetching user data with token: $token');

    final response = await http.get(url, headers: headers);
    print('Fetch user data response code: ${response.statusCode}');
    print('Fetch user data response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User data received: $data');

      // Extracting referral data
      final referrals = data['referrals'] ?? {};
      final totalReferrals = referrals.values.fold(0, (sum, level) => sum + (level ?? 0));

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
      print('Failed to fetch user data');
      throw Exception('Failed to load user data');
    }
  }

  // Logout and clear storage
  Future<void> logout() async {
    print('Logging out, clearing all secure storage.');
    await _secureStorage.deleteAll();
  }
}
