import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../config/environment_config.dart';
import '../services/translation_service.dart';
import '../services/auth_service.dart';

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

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TranslationService _translationService;

  UserDataProvider(this._translationService) {
    initialize();
  }

  // ---------- Helpers ----------
  void _applyUserData(Map<String, dynamic> userData) {
    name = userData['name'] ?? 'Nombre no disponible';
    email = userData['email'] ?? 'Email no disponible';
    phone = userData['phone'] ?? userData['phone_number'] ?? 'Teléfono no disponible';

    // points robusto
    points = (userData['points'] is num)
        ? (userData['points'] as num).toDouble()
        : double.tryParse('${userData['points'] ?? 0}') ?? 0.0;

    // totalReferrals robusto (admite totalReferrals o total_referrals)
    totalReferrals = userData['totalReferrals'] ??
        userData['total_referrals'] ??
        0;

    pass = userData['pass'] ?? 'No disponible';
    referrerPass = userData['referrer_pass'] ?? 'No disponible';
    language = userData['language'] ?? language;
    profilePhotoUrl = userData['profile_photo_url'] ?? '';
  }

  Future<void> _persistMinimalUserData() async {
    await _secureStorage.write(key: 'user_name', value: name);
    await _secureStorage.write(key: 'user_email', value: email);
    await _secureStorage.write(key: 'user_phone', value: phone);
    await _secureStorage.write(key: 'user_points', value: points.toString());
    await _secureStorage.write(key: 'user_total_referrals', value: '$totalReferrals');
    await _secureStorage.write(key: 'user_pass', value: pass);
    await _secureStorage.write(key: 'user_referrer_pass', value: referrerPass);
    await _secureStorage.write(key: 'user_language', value: language);
    await _secureStorage.write(key: 'profile_photo_url', value: profilePhotoUrl);
  }

  // ---------- Lifecycle ----------
  Future<void> initialize() async {
    await loadUserData();
    await fetchUserDataFromServer().catchError((e) {
      debugPrint('Error al sincronizar en segundo plano: $e');
    });
    await fetchAvailableLocales();
    await loadTranslations();
  }

  // ---------- User fetch (centralizado en AuthService) ----------
  Future<void> fetchUserDataFromServer() async {
    try {
      final auth = AuthService();
      // AuthService ya respeta MOCK_SERVER y devuelve mock si está activo
      final data = await auth.fetchUserData();

      _applyUserData(data);
      await _persistMinimalUserData();

      notifyListeners();
    } catch (e) {
      debugPrint('Error al obtener los datos del servidor: $e');
      rethrow;
    }
  }

  Future<void> loadUserData() async {
    final allData = await _secureStorage.readAll();

    name = allData['user_name'] ?? 'Nombre no disponible';
    email = allData['user_email'] ?? 'Email no disponible';
    phone = allData['user_phone'] ?? 'Teléfono no disponible';
    points = double.tryParse(allData['user_points'] ?? '0') ?? 0.0;
    totalReferrals = int.tryParse(allData['user_total_referrals'] ?? '0') ?? 0;
    pass = allData['user_pass'] ?? 'No disponible';
    referrerPass = allData['user_referrer_pass'] ?? 'No disponible';
    language = allData['user_language'] ?? 'es';
    profilePhotoUrl = allData['profile_photo_url'] ?? '';

    debugPrint('Datos cargados del almacenamiento seguro.');
    debugPrint('$allData');
    notifyListeners();
  }

  // ---------- Translations ----------
  Future<void> loadTranslations() async {
    try {
      final map = await _translationService
          .fetchTranslations(language)
          .timeout(const Duration(seconds: 6));

      translations = map;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('translations_cache_$language', jsonEncode(map));

      debugPrint('Traducciones ONLINE ($language) cargadas y cacheadas.');
    } catch (e) {
      debugPrint('loadTranslations() falló: $e — intento cache/assets');

      final prefs = await SharedPreferences.getInstance();

      // 1) Cache
      final cached = prefs.getString('translations_cache_$language');
      if (cached != null) {
        translations = jsonDecode(cached) as Map<String, dynamic>;
        debugPrint('Traducciones desde CACHE ($language).');
        notifyListeners();
        return;
      }

      // 2) Assets locales
      try {
        final assetStr = await rootBundle.loadString('assets/i18n/$language.json');
        translations = jsonDecode(assetStr) as Map<String, dynamic>;
        debugPrint('Traducciones desde ASSETS ($language).');
      } catch (e2) {
        // 3) Último recurso mínimo
        translations = {
          'navigation': {
            'map': 'Map',
            'list': 'List',
            'pointsTab': 'Points',
            'profile': 'Profile',
          },
          'common': {'close': 'Close'},
          'user': {'profile': 'User Profile'}
        };
        debugPrint('Traducciones por DEFECTO (mínimas).');
      }
      notifyListeners();
    }
  }

  Future<void> fetchAvailableLocales() async {
    try {
      availableLocales = await _translationService
          .fetchAvailableLocales()
          .timeout(const Duration(seconds: 6));
      debugPrint('Locales disponibles: $availableLocales');
    } catch (e) {
      debugPrint('Locales fallaron: $e — uso fallback');
      availableLocales = const [Locale('en'), Locale('es'), Locale('de')];
    }
    notifyListeners();
  }

  // ---------- Save profile ----------
  Future<void> saveUserData(
      String newName,
      String newEmail,
      String newPhone,
      String newLanguage,
      String newPass,
      String newReferrerPass,
      ) async {
    name = newName;
    email = newEmail;
    phone = newPhone;
    language = newLanguage;
    pass = newPass;
    referrerPass = newReferrerPass;

    try {
      if (EnvironmentConfig.mockServer) {
        // Simula guardado local y recarga de traducciones
        await _persistMinimalUserData();
        await loadTranslations();
        notifyListeners();
        debugPrint('🧩 MOCK_SERVER: datos de usuario guardados localmente.');
        return;
      }

      final response = await _sendUserDataToServer(
        name, email, phone, language, pass, referrerPass,
      );

      if (response.statusCode == 200) {
        await _persistMinimalUserData();
        await loadTranslations();
        notifyListeners();
        debugPrint('Datos guardados en el servidor y almacenamiento local.');
      } else {
        debugPrint('Error al guardar los datos en el servidor: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error al enviar los datos al servidor: $e');
    }
  }

  Future<http.Response> _sendUserDataToServer(
      String name,
      String email,
      String phone,
      String language,
      String pass,
      String referrerPass,
      ) async {
    if (EnvironmentConfig.mockServer) {
      // Simula 200 sin tocar red
      return http.Response('{"ok":true}', 200);
    }

    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user');
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) throw Exception('Token de autenticación no encontrado');

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    final body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'language': language,
      'pass': pass,
      'referrer_pass': referrerPass,
    });

    return http.put(url, headers: headers, body: body);
  }

  // ---------- Avatar ----------
  Future<void> uploadAvatar(File imageFile) async {
    if (EnvironmentConfig.mockServer) {
      // Simula subida: asigna una URL y persiste
      profilePhotoUrl = 'https://picsum.photos/seed/mock-avatar-${DateTime.now().millisecondsSinceEpoch}/200';
      await _secureStorage.write(key: 'profile_photo_url', value: profilePhotoUrl);
      notifyListeners();
      debugPrint('🧩 MOCK_SERVER: avatar simulado actualizado.');
      return;
    }

    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/upload-avatar');
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) throw Exception('Token de autenticación no encontrado');

    final request = http.MultipartRequest('POST', url)
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
      debugPrint('Error al subir el avatar: ${response.statusCode}');
    }
  }

  // ---------- Logout ----------
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
