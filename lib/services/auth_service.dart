import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart'; // Importa EnvironmentConfig

class AuthService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl(); // Obtiene la URL base
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);
    print('se va a loggear. codigo: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      // Debugging
      print('Login response data: $data');
      print('User data after login: $user');

      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(key: 'user_name', value: user['name']);
      await _secureStorage.write(key: 'user_email', value: user['email']);
      await _secureStorage.write(key: 'user_phone', value: user['phone_number'] ?? '');

      return {'success': true, 'user': user};
    } else {
      final errorData = jsonDecode(response.body);
      print('Login failed with error: $errorData');
      return {'success': false, 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String confirmPassword) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl(); // Obtiene la URL base
    final url = Uri.parse('$baseUrl/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      // Debugging
      print('Register response data: $data');
      print('User data after registration: $user');

      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(key: 'user_name', value: user['name']);
      await _secureStorage.write(key: 'user_email', value: user['email']);
      await _secureStorage.write(key: 'user_phone', value: user['phone_number'] ?? '');

      return {'success': true, 'user': user};
    } else {
      final errorData = jsonDecode(response.body);
      print('Registration failed with error: $errorData');
      return {'success': false, 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final baseUrl = await EnvironmentConfig.getBaseUrl(); // Obtiene la URL base
    final url = Uri.parse('$baseUrl/user/data');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Debugging
      print('User data response: $data');

      int points = data['points'] ?? 0;

      final referrals = data['referrals'] ?? {};

      int level1 = referrals['level_1'] ?? 0;
      int level2 = referrals['level_2'] ?? 0;
      int level3 = referrals['level_3'] ?? 0;
      int level4 = referrals['level_4'] ?? 0;
      int level5 = referrals['level_5'] ?? 0;
      int level6 = referrals['level_6'] ?? 0;
      int level7 = referrals['level_7'] ?? 0;

      int totalReferrals = level1 + level2 + level3 + level4 + level5 + level6 + level7;
      int lowerLevelReferrals = data['lowlevelrefs'] ?? 0;

      String name = data['name'] ?? await _secureStorage.read(key: 'user_name') ?? 'Nombre no disponible';
      String email = data['email'] ?? await _secureStorage.read(key: 'user_email') ?? 'Email no disponible';
      String phone = data['phone'] ?? await _secureStorage.read(key: 'user_phone') ?? 'Teléfono no disponible';

      return {
        'name': name,
        'email': email,
        'phone': phone,
        'points': points,
        'totalReferrals': totalReferrals,
        'referrals': {
          'level_1': level1,
          'level_2': level2,
          'level_3': level3,
          'level_4': level4,
          'level_5': level5,
          'level_6': level6,
          'level_7': level7,
        },
        'lowerLevelReferrals': lowerLevelReferrals,
      };
    } else {
      print('Failed to fetch user data with status code: ${response.statusCode}');
      throw Exception('Failed to load user data');
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
}
