import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../mocking/mock_translation_service.dart';

class UserDataProvider extends ChangeNotifier {
  String name = 'Name not available';
  String email = 'Email not available';
  String phone = 'Telephone not available';
  double points = 0.0;
  int totalReferrals = 0;
  String pass = 'Not available';
  String referrerPass = 'Not available';
  String language = 'en';
  String profilePhotoUrl = 'lib/mocking/assets/test_avatar.png';
  Map<String, dynamic> translations = {};
  List<Locale> availableLocales = [];

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final MockTranslationService _translationService;

  UserDataProvider(this._translationService) {
    initialize();
  }

  Future<void> initialize() async {
    await loadUserData();
    await fetchAvailableLocales();
    await loadTranslations();
  }

  Future<void> loadUserData() async {
    Map<String, String?> allData = await _secureStorage.readAll();

    name = allData['user_name'] ?? 'Mock User';
    email = allData['user_email'] ?? 'mock@example.com';
    phone = allData['user_phone'] ?? '+0000000000';
    points = double.tryParse(allData['user_points'] ?? '42.0') ?? 42.0;
    totalReferrals = int.tryParse(allData['user_total_referrals'] ?? '7') ?? 7;
    pass = allData['user_pass'] ?? 'mockpass123';
    referrerPass = allData['user_referrer_pass'] ?? 'refmock456';
    language = allData['user_language'] ?? 'en';
    profilePhotoUrl = allData['profile_photo_url'] ?? 'lib/mocking/assets/test_avatar.png';

    print('Mock user data loaded from storage: $allData');
    notifyListeners();
  }

  Future<void> loadTranslations() async {
    try {
      translations = await _translationService.fetchTranslations(language);
      print('Loaded mock translations for: $language');
    } catch (e) {
      print('Error loading translations: $e');
      translations = {};
    }
    notifyListeners();
  }

  Future<void> fetchAvailableLocales() async {
    try {
      availableLocales = await _translationService.fetchAvailableLocales();
      print('Available mock locales: $availableLocales');
    } catch (e) {
      print('Error fetching locales: $e');
    }
    notifyListeners();
  }

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

    await _secureStorage.write(key: 'user_name', value: name);
    await _secureStorage.write(key: 'user_email', value: email);
    await _secureStorage.write(key: 'user_phone', value: phone);
    await _secureStorage.write(key: 'user_language', value: language);
    await _secureStorage.write(key: 'user_pass', value: pass);
    await _secureStorage.write(key: 'user_referrer_pass', value: referrerPass);

    await loadTranslations();

    print('Mock user data saved');
    notifyListeners();
  }

  Future<void> uploadAvatar(File imageFile) async {
    // Simula subida y guarda la ruta local
    profilePhotoUrl = imageFile.path;
    await _secureStorage.write(key: 'profile_photo_url', value: profilePhotoUrl);
    print('Mock avatar updated: $profilePhotoUrl');
    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();

    name = 'Mock User';
    email = 'mock@example.com';
    phone = '+0000000000';
    points = 0;
    totalReferrals = 0;
    pass = 'mockpass123';
    referrerPass = 'refmock456';
    language = 'en';
    profilePhotoUrl = 'lib/mocking/assets/test_avatar.png';
    translations = {};
    availableLocales = [];

    print('Mock user logged out');
    notifyListeners();
  }
}
