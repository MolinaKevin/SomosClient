import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDataProvider extends ChangeNotifier {
  String name = 'Juan Pérez';
  String email = 'juan.perez@example.com';
  String phone = '+1 234 567 8900';
  String points = '25555';
  String totalReferrals = '35';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  UserDataProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    name = await _secureStorage.read(key: 'user_name') ?? 'Juan Pérez';
    email = await _secureStorage.read(key: 'user_email') ?? 'juan.perez@example.com';
    phone = await _secureStorage.read(key: 'user_phone') ?? '+1 234 567 8900';
    points = await _secureStorage.read(key: 'user_points') ?? '25555';
    totalReferrals = await _secureStorage.read(key: 'user_total_referrals') ?? '35';
    notifyListeners();
  }

  Future<void> saveUserData(String newName, String newEmail, String newPhone) async {
    name = newName;
    email = newEmail;
    phone = newPhone;
    await _secureStorage.write(key: 'user_name', value: name);
    await _secureStorage.write(key: 'user_email', value: email);
    await _secureStorage.write(key: 'user_phone', value: phone);
    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    notifyListeners();
  }
}
