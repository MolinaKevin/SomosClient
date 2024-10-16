import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDataProvider extends ChangeNotifier {
  String name = 'Nombre no disponible';
  String email = 'Email no disponible';
  String phone = 'Teléfono no disponible';
  int points = 0;
  int totalReferrals = 0;
  String pass = 'No disponible'; // Somos Pass
  String referrerPass = 'No disponible'; // Pass de referido

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  UserDataProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    name = await _secureStorage.read(key: 'user_name') ?? 'Nombre no disponible';
    email = await _secureStorage.read(key: 'user_email') ?? 'Email no disponible';
    phone = await _secureStorage.read(key: 'user_phone') ?? 'Teléfono no disponible';
    points = int.tryParse(await _secureStorage.read(key: 'user_points') ?? '0') ?? 0;
    totalReferrals = int.tryParse(await _secureStorage.read(key: 'user_total_referrals') ?? '0') ?? 0;
    pass = await _secureStorage.read(key: 'user_pass') ?? 'No disponible'; // Cargar Somos Pass
    referrerPass = await _secureStorage.read(key: 'user_referrer_pass') ?? 'No disponible'; // Cargar Pass de referido

    notifyListeners(); // Notificar a los oyentes de los cambios
  }

  void setUserData(String newName, String newEmail, String newPhone, int newPoints, int newTotalReferrals, String newPass, String newReferrerPass) {
    name = newName ?? 'Nombre no disponible';
    email = newEmail ?? 'Email no disponible';
    phone = newPhone ?? 'Teléfono no disponible';
    points = newPoints;
    totalReferrals = newTotalReferrals;
    pass = newPass ?? 'No disponible';
    referrerPass = newReferrerPass ?? 'No disponible';

    // Guardar en el almacenamiento seguro
    _secureStorage.write(key: 'user_name', value: name);
    _secureStorage.write(key: 'user_email', value: email);
    _secureStorage.write(key: 'user_phone', value: phone);
    _secureStorage.write(key: 'user_points', value: points.toString());
    _secureStorage.write(key: 'user_total_referrals', value: totalReferrals.toString());
    _secureStorage.write(key: 'user_pass', value: pass); // Guardar Somos Pass
    _secureStorage.write(key: 'user_referrer_pass', value: referrerPass); // Guardar Pass de referido

    notifyListeners(); // Notificar a los oyentes de los cambios
  }

  Future<void> saveUserData(String newName, String newEmail, String newPhone) async {
    name = newName ?? name;
    email = newEmail ?? email;
    phone = newPhone ?? phone;

    await _secureStorage.write(key: 'user_name', value: name);
    await _secureStorage.write(key: 'user_email', value: email);
    await _secureStorage.write(key: 'user_phone', value: phone);

    notifyListeners(); // Notificar a los oyentes de los cambios
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    name = 'Nombre no disponible';
    email = 'Email no disponible';
    phone = 'Teléfono no disponible';
    points = 0;
    totalReferrals = 0;
    pass = 'No disponible'; // Limpiar Somos Pass
    referrerPass = 'No disponible'; // Limpiar Pass de referido

    notifyListeners(); // Notificar a los oyentes de los cambios
  }
}
