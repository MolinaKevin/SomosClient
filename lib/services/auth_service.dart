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

    print('Attempting login with email: $email');

    final response = await http.post(url, headers: headers, body: body);
    print('Login response code: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      print('Login successful. Token: $token, User: $user');

      // Almacenar la información del usuario, incluyendo pass y referrer_pass
      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(key: 'user_name', value: user['name']);
      await _secureStorage.write(key: 'user_email', value: user['email']);
      await _secureStorage.write(key: 'user_phone', value: user['phone_number'] ?? '');
      await _secureStorage.write(key: 'profile_photo_url', value: user['profile_photo_url'] ?? '');
      await _secureStorage.write(key: 'user_pass', value: user['pass'] ?? ''); // Guardar pass
      await _secureStorage.write(key: 'user_referrer_pass', value: user['referrer_pass'] ?? ''); // Guardar referrer_pass

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

    print('Attempting registration with email: $email');

    final response = await http.post(url, headers: headers, body: body);
    print('Register response code: ${response.statusCode}');
    print('Register response body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];

      print('Registration successful. Token: $token, User: $user');

      // Almacenar la información del usuario, incluyendo pass y referrer_pass
      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(key: 'user_name', value: user['name']);
      await _secureStorage.write(key: 'user_email', value: user['email']);
      await _secureStorage.write(key: 'user_phone', value: user['phone_number'] ?? '');
      await _secureStorage.write(key: 'profile_photo_url', value: user['profile_photo_url'] ?? '');
      await _secureStorage.write(key: 'user_pass', value: user['pass'] ?? ''); // Guardar pass
      await _secureStorage.write(key: 'user_referrer_pass', value: user['referrer_pass'] ?? ''); // Guardar referrer_pass

      return {'success': true, 'user': user};
    } else {
      final errorData = jsonDecode(response.body);
      print('Registration failed with error: $errorData');
      return {'success': false, 'error': errorData};
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final baseUrl = await EnvironmentConfig.getBaseUrl(); // Obtiene la URL base
    final url = Uri.parse('$baseUrl/user');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('Fetching user details with token: $token');
    print('Requesting from URL: $url');

    final response = await http.get(url, headers: headers);
    print('Fetch user details response code: ${response.statusCode}');
    print('Fetch user details response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User details received: $data');

      // Almacena los nuevos datos que lleguen del endpoint /user
      await _secureStorage.write(key: 'user_name', value: data['name']);
      await _secureStorage.write(key: 'user_email', value: data['email']);
      await _secureStorage.write(key: 'user_phone', value: data['phone'] ?? '');
      await _secureStorage.write(key: 'profile_photo_url', value: data['profile_photo_url'] ?? '');
      await _secureStorage.write(key: 'user_pass', value: data['pass'] ?? ''); // Guardar pass
      await _secureStorage.write(key: 'user_referrer_pass', value: data['referrer_pass'] ?? ''); // Guardar referrer_pass

      return {
        'name': data['name'],
        'email': data['email'],
        'phone': data['phone'] ?? '',
        'profile_photo_url': data['profile_photo_url'] ?? '',
        'pass': data['pass'] ?? '',
        'referrer_pass': data['referrer_pass'] ?? ''
      };
    } else {
      print('Failed to fetch user details with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load user details');
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

    print('Fetching user data with token: $token');
    print('Requesting from URL: $url');

    final response = await http.get(url, headers: headers);
    print('Fetch user data response code: ${response.statusCode}');
    print('Fetch user data response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User data received: $data');

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
      String profilePhotoUrl = data['profile_photo_url'] ?? await _secureStorage.read(key: 'profile_photo_url') ?? '';
      String pass = data['pass'] ?? await _secureStorage.read(key: 'user_pass') ?? 'No disponible';
      String referrerPass = data['referrer_pass'] ?? await _secureStorage.read(key: 'user_referrer_pass') ?? 'No disponible';

      return {
        'name': name,
        'email': email,
        'phone': phone,
        'points': points,
        'profile_photo_url': profilePhotoUrl,
        'totalReferrals': totalReferrals,
        'pass': pass,
        'referrer_pass': referrerPass,
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
      print('Response body: ${response.body}');
      throw Exception('Failed to load user data');
    }
  }

  Future<void> logout() async {
    print('Logging out, clearing all secure storage.');
    await _secureStorage.deleteAll();
  }
}
