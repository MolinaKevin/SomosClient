import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import '../config/environment_config.dart';
import '../services/translation_service.dart';

class UserDataProvider extends ChangeNotifier {
  String name = 'Name not available';
  String email = 'Email not available';
  String phone = 'Telephone not available';
  double points = 0.0;
  int totalReferrals = 0;
  String pass = 'Not available';
  String referrerPass = 'Not available';
  String language = 'en';
  String profilePhotoUrl = '';
  Map<String, dynamic> translations = {};
  List<Locale> availableLocales = [];

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TranslationService _translationService;

  UserDataProvider(this._translationService) {
    initialize();
  }

  Future<void> initialize() async {
    await loadUserData();
    await fetchUserDataFromServer().catchError((e) {
      print('Error al sincronizar en segundo plano: $e');
    });
    await fetchAvailableLocales();
    await loadTranslations();
  }


  Future<void> fetchUserDataFromServer() async {
    try {
      final baseUrl = await EnvironmentConfig.getBaseUrl();
      final url = Uri.parse('$baseUrl/user');
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) throw Exception('Token de autenticación no encontrado');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        name = userData['name'] ?? 'Nombre no disponible';
        email = userData['email'] ?? 'Email no disponible';
        phone = userData['phone'] ?? 'Teléfono no disponible';
        points = userData['points'] ?? 0.0;
        totalReferrals = userData['total_referrals'] ?? 0;
        pass = userData['pass'] ?? 'No disponible';
        referrerPass = userData['referrer_pass'] ?? 'No disponible';
        language = userData['language'] ?? 'es';
        profilePhotoUrl = userData['profile_photo_url'] ?? '';

        print('Actualizando almacenamiento seguro con pass: $pass');

        await _secureStorage.write(key: 'user_pass', value: pass);
        print('Pass escrito en almacenamiento seguro.');

        final writtenPass = await _secureStorage.read(key: 'user_pass');
        print('Pass leído tras la escritura: $writtenPass');

        notifyListeners();
      } else {
        print('Error al sincronizar con el servidor: ${response.body}');
      }
    } catch (e) {
      print('Error al obtener los datos del servidor: $e');
      throw e;
    }
  }

  Future<void> loadUserData() async {
    Map<String, String?> allData = await _secureStorage.readAll();

    name = allData['user_name'] ?? 'Nombre no disponible';
    email = allData['user_email'] ?? 'Email no disponible';
    phone = allData['user_phone'] ?? 'Teléfono no disponible';
    points = double.tryParse(allData['user_points'] ?? '0') ?? 0.0;
    totalReferrals = int.tryParse(allData['user_total_referrals'] ?? '0') ?? 0;
    pass = allData['user_pass'] ?? 'No disponible';
    referrerPass = allData['user_referrer_pass'] ?? 'No disponible';
    language = allData['user_language'] ?? 'es';
    profilePhotoUrl = allData['profile_photo_url'] ?? '';

    print('Datos cargados del almacenamiento seguro.');
    print('$allData');
    notifyListeners();
  }

  Future<void> loadTranslations() async {
    try {
      translations = await _translationService.fetchTranslations(language);
      print('Traducciones cargadas para el idioma: $language');
    } catch (e) {
      print('Error al obtener las traducciones: $e');
      translations = {};
    }
    notifyListeners();
  }

  Future<void> fetchAvailableLocales() async {
    try {
      availableLocales = await _translationService.fetchAvailableLocales();
      print('Locales disponibles: $availableLocales');
    } catch (e) {
      print('Error al obtener locales disponibles: $e');
    }
    notifyListeners();
  }

  Future<void> saveUserData(String newName, String newEmail, String newPhone, String newLanguage, String newPass, String newReferrerPass) async {
    name = newName;
    email = newEmail;
    phone = newPhone;
    language = newLanguage;
    pass = newPass;
    referrerPass = newReferrerPass;

    try {
      final response = await _sendUserDataToServer(name, email, phone, language, pass, referrerPass);
      if (response.statusCode == 200) {
        await _secureStorage.write(key: 'user_name', value: name);
        await _secureStorage.write(key: 'user_email', value: email);
        await _secureStorage.write(key: 'user_phone', value: phone);
        await _secureStorage.write(key: 'user_language', value: language);
        await _secureStorage.write(key: 'user_pass', value: pass);
        print('Escribiendo pass en almacenamiento seguro: $pass');
        final writtenPass = await _secureStorage.read(key: 'user_pass');
        print('Pass leído tras la escritura: $writtenPass');
        await _secureStorage.write(key: 'user_referrer_pass', value: referrerPass);

        await loadTranslations();

        notifyListeners();
        print('Datos guardados en el servidor y almacenamiento local.');
      } else {
        print('Error al guardar los datos en el servidor: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar los datos al servidor: $e');
    }
  }

  Future<http.Response> _sendUserDataToServer(String name, String email, String phone, String language, String pass, String referrerPass) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user');
    final token = await _secureStorage.read(key: 'auth_token');

    if (token == null) throw Exception('Token de autenticación no encontrado');

    final Map<String, String> body = {
      'name': name,
      'email': email,
      'phone': phone,
      'language': language,
      'pass': pass,
      'referrer_pass': referrerPass,
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<void> uploadAvatar(File imageFile) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/upload-avatar');
    final token = await _secureStorage.read(key: 'auth_token');

    if (token == null) throw Exception('Token de autenticación no encontrado');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await http.Response.fromStream(response);
      final jsonResponse = jsonDecode(responseBody.body);
      profilePhotoUrl = jsonResponse['profile_photo_url'];
      await _secureStorage.write(key: 'profile_photo_url', value: profilePhotoUrl);
      notifyListeners();
    } else {
      print('Error al subir el avatar: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    name = 'Nombre no disponible';
    email = 'Email no disponible';
    phone = 'Teléfono no disponible';
    points = 0;
    totalReferrals = 0;
    pass = 'No disponible';
    referrerPass = 'No disponible';
    language = 'es';
    profilePhotoUrl = '';
    translations = {};
    availableLocales = [];

    notifyListeners();
  }
}
