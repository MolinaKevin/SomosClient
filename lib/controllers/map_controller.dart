import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/commerce_service.dart';
import '../services/institution_service.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';

class MapDataController {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<Map<String, dynamic>> markerData = [];
  List<Map<String, dynamic>> categories = [];
  final CommerceService commerceService = CommerceService();
  final InstitutionService institutionService = InstitutionService();
  final AuthService authService = AuthService();
  final CategoryService categoryService = CategoryService();

  double points = 0.0;

  Future<void> initializeData({required Map<String, dynamic> translations}) async {
    await fetchData(translations: translations);
    await fetchCategories();
  }

  Future<void> fetchData({required Map<String, dynamic> translations, bool forceRefresh = false}) async {
    final commerces = await commerceService.fetchCommerces(forceRefresh: forceRefresh);
    final institutions = await institutionService.fetchInstitutions(forceRefresh: forceRefresh);
    final userData = await authService.fetchUserData();

    markerData = [
      ...commerces.map((commerce) => {
        'id': commerce['id'],
        'name': commerce['name'] ?? translations['common']['noDataAvailable'] ?? 'Name not available',
        'address': commerce['address'] ?? translations['entities']?['noAddress'] ?? 'Address not available',
        'phone': commerce['phone_number'] ?? translations['entities']?['noPhone'] ?? 'Phone not available',
        'email': commerce['email'] ?? translations['entities']?['noEmail'] ?? 'Email not available',
        'city': commerce['city'] ?? translations['entities']?['noCity'] ?? 'City not available',
        'description': commerce['description'] ?? translations['entities']?['noDescription'] ?? 'Description not available',
        'latitude': double.tryParse(commerce['latitude']?.toString() ?? '') ?? 0.0,
        'longitude': double.tryParse(commerce['longitude']?.toString() ?? '') ?? 0.0,
        'is_open': commerce['is_open'] ?? false,
        'avatar': commerce['avatar'],
        'avatar_url': commerce['avatar_url'],
        'background_image': commerce['background_image'] ?? '',
        'fotos_urls': commerce['fotos_urls'] ?? [],
      }).toList(),
      ...institutions.map((institution) => {
        'id': institution['id'],
        'name': institution['name'] ?? translations['common']['noDataAvailable'] ?? 'Name not available',
        'address': institution['address'] ?? translations['entities']?['noAddress'] ?? 'Address not available',
        'phone': institution['phone_number'] ?? translations['entities']?['noPhone'] ?? 'Phone not available',
        'email': institution['email'] ?? translations['entities']?['noEmail'] ?? 'Email not available',
        'city': institution['city'] ?? translations['entities']?['noCity'] ?? 'City not available',
        'description': institution['description'] ?? translations['entities']?['noDescription'] ?? 'Description not available',
        'latitude': double.tryParse(institution['latitude']?.toString() ?? '') ?? 0.0,
        'longitude': double.tryParse(institution['longitude']?.toString() ?? '') ?? 0.0,
        'is_open': institution['is_open'] ?? false,
        'avatar': institution['avatar'],
        'avatar_url': institution['avatar_url'],
        'background_image': institution['background_image'] ?? '',
        'fotos_urls': institution['fotos_urls'] ?? [],
      }).toList(),
    ];

    points = userData['points'] ?? 0.0;
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await categoryService.fetchCategories();
      categories = fetchedCategories;
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchFilteredMarkers(List<Map<String, dynamic>> selectedCategories, {required Map<String, dynamic> translations}) async {
    try {
      List<int> categoryIds = selectedCategories.map((category) => category['id'] as int).toList();
      final commerces = await commerceService.fetchCommercesByCategories(categoryIds);
      final institutions = await institutionService.fetchInstitutions(); // Ajusta esto si las instituciones también pueden ser filtradas

      markerData = [
        ...commerces.map((commerce) => {
          'id': commerce['id'],
          'name': commerce['name'] ?? translations['common']['noDataAvailable'] ?? 'Name not available',
          'address': commerce['address'] ?? translations['entities']?['noAddress'] ?? 'Address not available',
          'phone': commerce['phone_number'] ?? translations['entities']?['noPhone'] ?? 'Phone not available',
          'email': commerce['email'] ?? translations['entities']?['noEmail'] ?? 'Email not available',
          'city': commerce['city'] ?? translations['entities']?['noCity'] ?? 'City not available',
          'description': commerce['description'] ?? translations['entities']?['noDescription'] ?? 'Description not available',
          'latitude': double.tryParse(commerce['latitude']?.toString() ?? '') ?? 0.0,
          'longitude': double.tryParse(commerce['longitude']?.toString() ?? '') ?? 0.0,
          'is_open': commerce['is_open'] ?? false,
          'avatar': commerce['avatar'],
          'avatar_url': commerce['avatar_url'],
          'background_image': commerce['background_image'] ?? '',
          'fotos_urls': commerce['fotos_urls'] ?? [],
        }).toList(),
        ...institutions.map((institution) => {
          'id': institution['id'],
          'name': institution['name'] ?? translations['common']['noDataAvailable'] ?? 'Name not available',
          'address': institution['address'] ?? translations['entities']?['noAddress'] ?? 'Address not available',
          'phone': institution['phone_number'] ?? translations['entities']?['noPhone'] ?? 'Phone not available',
          'email': institution['email'] ?? translations['entities']?['noEmail'] ?? 'Email not available',
          'city': institution['city'] ?? translations['entities']?['noCity'] ?? 'City not available',
          'description': institution['description'] ?? translations['entities']?['noDescription'] ?? 'Description not available',
          'latitude': double.tryParse(institution['latitude']?.toString() ?? '') ?? 0.0,
          'longitude': double.tryParse(institution['longitude']?.toString() ?? '') ?? 0.0,
          'is_open': institution['is_open'] ?? false,
          'avatar': institution['avatar'],
          'avatar_url': institution['avatar_url'],
          'background_image': institution['background_image'] ?? '',
          'fotos_urls': institution['fotos_urls'] ?? [],
        }).toList(),
      ];
    } catch (e) {
      print('Error fetching filtered markers: $e');
      rethrow;
    }
  }
}
