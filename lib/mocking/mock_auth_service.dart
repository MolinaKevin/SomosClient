import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockAuthService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> _saveUserData() async {
    await _secureStorage.write(key: 'auth_token', value: 'mock_token');
    await _secureStorage.write(key: 'user_name', value: 'Sophie');
    await _secureStorage.write(key: 'user_email', value: '1johanna11@web.de');
    await _secureStorage.write(key: 'user_phone', value: '123456789');
    await _secureStorage.write(key: 'profile_photo_url', value: 'lib/mocking/assets/test_avatar.png');
    await _secureStorage.write(key: 'user_pass', value: 'XX-USERPASS123');
    await _secureStorage.write(key: 'user_referrer_pass', value: '');
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Mock login with email: $email');
    await _saveUserData();
    return {
      'success': true,
      'user': {
        'id': 1,
        'name': 'Sophie',
        'email': '1johanna11@web.de',
        'phone_number': '123456789',
        'profile_photo_url': 'lib/mocking/assets/test_avatar.png',
        'pass': 'XX-USERPASS123',
        'referrer_pass': null,
        'language': 'de',
        'points': 129.06,
      },
    };
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String confirmPassword) async {
    print('Mock registration for $email');
    return await login(email, password);
  }

  Future<Map<String, dynamic>> fetchUserDetails() async {
    return {
      'id': 1,
      'name': 'Sophie',
      'email': '1johanna11@web.de',
      'phone': '123456789',
      'profile_photo_url': 'lib/mocking/assets/test_avatar.png',
      'pass': 'XX-USERPASS123',
      'referrer_pass': null,
      'points': 129.06,
      'language': 'de',
    };
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    return {
      'name': 'Sophie',
      'email': '1johanna11@web.de',
      'phone': '123456789',
      'points': 129.06,
      'profile_photo_url': 'lib/mocking/assets/test_avatar.png',
      'totalReferrals': 10,
      'referrals': {
        'level_1': 3,
        'level_2': 6,
        'level_3': 1,
        'level_4': 0,
        'level_5': 0,
        'level_6': 0,
        'level_7': 0,
      },
      'lowerLevelReferrals': 7,
    };
  }

  Future<void> logout() async {
    print('Mock logout: clearing secure storage.');
    await _secureStorage.deleteAll();
  }
}
