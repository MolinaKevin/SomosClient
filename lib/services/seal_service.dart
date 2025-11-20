import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class SealService {
  List<Map<String, dynamic>>? _cachedSeals;

  Future<List<Map<String, dynamic>>> fetchSeals({bool forceRefresh = false}) async {
    if (_cachedSeals != null && !forceRefresh) {
      return _cachedSeals!;
    }

    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/seals');
    final headers = {'Content-Type': 'application/json'};

    // Modo mock: devolvemos sellos predefinidos que vivirán en assets
    if (EnvironmentConfig.mockServer == true) {
      _cachedSeals = _mockSeals();
      return _cachedSeals!;
    }

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic> && body['data'] is List) {
          final data = body['data'] as List<dynamic>;
          _cachedSeals = _processSeals(data);
          return _cachedSeals!;
        } else {
          throw Exception('Invalid JSON structure: "data" missing or not list');
        }
      } else {
        throw Exception('Failed to load seals: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a mocks si falla el server
      _cachedSeals = _mockSeals();
      return _cachedSeals!;
    }
  }

  // --- Parse normal desde API ---
  List<Map<String, dynamic>> _processSeals(List<dynamic> seals) {
    return seals.map((seal) {
      return {
        'id'   : seal['id'],
        'name' : seal['translated_name'] ?? seal['name'],
        'slug' : seal['slug'],
        // en server podrías tener icon/image absolutas; para assets no las usamos
        'icon' : seal['icon'],
        'image': seal['image'],
        // opcional: base de assets (por si mezclás server + locales)
        'asset_base': 'assets/images/seals/${seal['slug']}',
      };
    }).toList();
  }

  // --- MOCKS: apuntan a assets locales ---
  List<Map<String, dynamic>> _mockSeals() {
    return [
      {
        'id': 1,
        'name': 'Gluten free',
        'slug': 'gluten_free',
        'asset_base': 'assets/images/seals/gluten_free',
      },
      {
        'id': 2,
        'name': 'Fair Trade',
        'slug': 'fair_trade',
        'asset_base': 'assets/images/seals/fair_trade',
      },
      {
        'id': 3,
        'name': 'Organic',
        'slug': 'organic',
        'asset_base': 'assets/images/seals/organic',
      },
      {
        'id': 4,
        'name': 'Vegan',
        'slug': 'vegan',
        'asset_base': 'assets/images/seals/vegan',
      },
      {
        'id': 5,
        'name': 'Plastic free',
        'slug': 'plastic_free',
        'asset_base': 'assets/images/seals/plastic_free',
      },
    ];
  }
}
