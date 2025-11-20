import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class CategoryService {
  List<Map<String, dynamic>>? _cachedCategories;

  /// Si quieres controlar específicamente categorías mock sin depender de mockServer,
  /// define este flag en tu EnvironmentConfig. Si no existe, usamos mockServer.
  bool get _useMockCategories {
    try {
      final v = (EnvironmentConfig as dynamic).testShowMockCategories;
      if (v is bool) return v;
    } catch (_) {}
    return EnvironmentConfig.mockServer == true;
  }

  Future<List<Map<String, dynamic>>> fetchCategories({bool forceRefresh = false}) async {
    if (_cachedCategories != null && !forceRefresh) {
      print('Using cached categories');
      return _cachedCategories!;
    }

    // --- MODO MOCK (directo) ---
    if (_useMockCategories) {
      print('🔌 MOCK_SERVER: fetchCategories() → usando mocks');
      final mockFlat = _mockFlatCategories();
      _cachedCategories = _buildCategoryHierarchy(mockFlat);
      return _cachedCategories!;
    }

    // --- Modo API ---
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/categories');
    final headers = {'Content-Type': 'application/json'};

    print('Fetching categories from API: $url');
    try {
      final response = await http.get(url, headers: headers);
      print('Response status code: ${response.statusCode}');
      print('Raw categories response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'] as List<dynamic>;
        } else {
          throw Exception('Invalid JSON structure for categories');
        }

        print('Parsed categories data: $list');
        _cachedCategories = _buildCategoryHierarchy(list);
        print('Processed category hierarchy: $_cachedCategories');
        return _cachedCategories!;
      } else {
        print('Failed to load categories: ${response.body}');
        if (_useMockCategories) {
          print('→ Fallback a mocks');
          final mockFlat = _mockFlatCategories();
          _cachedCategories = _buildCategoryHierarchy(mockFlat);
          return _cachedCategories!;
        }
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('⚠️ Error fetching categories: $e');
      if (_useMockCategories) {
        print('→ Fallback a mocks');
        final mockFlat = _mockFlatCategories();
        _cachedCategories = _buildCategoryHierarchy(mockFlat);
        return _cachedCategories!;
      }
      rethrow;
    }
  }

  /// Construye jerarquía padre→hijos a partir de una lista plana:
  /// Cada item debe traer: { id, name/translated_name, slug, parent_id }
  List<Map<String, dynamic>> _buildCategoryHierarchy(List<dynamic> categories) {
    final Map<int, Map<String, dynamic>> byId = {};
    final List<Map<String, dynamic>> roots = [];

    // 1) Normalizamos y generamos nodos
    for (final raw in categories) {
      if (raw == null) continue;
      final id = _asInt(raw['id']);
      final parentId = _asIntOrNull(raw['parent_id']);

      if (id == null) {
        print('Error: invalid category id in $raw');
        continue;
      }

      byId[id] = {
        'id': id,
        'name': (raw['translated_name'] ?? raw['name'] ?? 'Unnamed').toString(),
        'slug': (raw['slug'] ?? '').toString(),
        'parent_id': parentId,
        'children': <Map<String, dynamic>>[],
      };
    }

    // 2) Enlazamos hijos
    for (final node in byId.values) {
      final parentId = node['parent_id'] as int?;
      if (parentId != null && byId.containsKey(parentId)) {
        byId[parentId]!['children'].add(node);
      } else {
        roots.add(node);
      }
    }

    return roots;
  }

  // ---------- MOCKS ----------
  /// Devuelve una lista PLANA (no jerárquica) con parent_id
  /// Suficiente para construir una jerarquía variada de ejemplo.
  List<Map<String, dynamic>> _mockFlatCategories() {
    // Raíces
    final foodDrink = {'id': 1, 'name': 'Food & Drink', 'slug': 'food_drink', 'parent_id': null};
    final retail    = {'id': 2, 'name': 'Retail', 'slug': 'retail', 'parent_id': null};
    final services  = {'id': 3, 'name': 'Services', 'slug': 'services', 'parent_id': null};
    final culture   = {'id': 4, 'name': 'Culture', 'slug': 'culture', 'parent_id': null};
    final ngo       = {'id': 5, 'name': 'NGO / Non-profit', 'slug': 'ngo', 'parent_id': null};

    // Food & Drink
    final cafe        = {'id': 10, 'name': 'Café', 'slug': 'cafe', 'parent_id': 1};
    final restaurant  = {'id': 11, 'name': 'Restaurant', 'slug': 'restaurant', 'parent_id': 1};
    final bar         = {'id': 12, 'name': 'Bar', 'slug': 'bar', 'parent_id': 1};
    final bakery      = {'id': 13, 'name': 'Bakery', 'slug': 'bakery', 'parent_id': 1};
    final grocery     = {'id': 14, 'name': 'Grocery', 'slug': 'grocery', 'parent_id': 1};

    // Retail
    final clothing  = {'id': 20, 'name': 'Clothing', 'slug': 'clothing', 'parent_id': 2};
    final shoes     = {'id': 21, 'name': 'Shoes', 'slug': 'shoes', 'parent_id': 2};
    final ecoShop   = {'id': 22, 'name': 'Eco Shop', 'slug': 'eco_shop', 'parent_id': 2};
    final books     = {'id': 23, 'name': 'Books', 'slug': 'books', 'parent_id': 2};

    // Services
    final hairdresser = {'id': 30, 'name': 'Hairdresser', 'slug': 'hairdresser', 'parent_id': 3};
    final repair      = {'id': 31, 'name': 'Repair', 'slug': 'repair', 'parent_id': 3};
    final cowork      = {'id': 32, 'name': 'Coworking', 'slug': 'coworking', 'parent_id': 3};
    final logistics   = {'id': 33, 'name': 'Logistics', 'slug': 'logistics', 'parent_id': 3};

    // Culture
    final museum    = {'id': 40, 'name': 'Museum', 'slug': 'museum', 'parent_id': 4};
    final gallery   = {'id': 41, 'name': 'Gallery', 'slug': 'gallery', 'parent_id': 4};
    final theatre   = {'id': 42, 'name': 'Theatre', 'slug': 'theatre', 'parent_id': 4};


    return [
      foodDrink, retail, services, culture, ngo,
      cafe, restaurant, bar, bakery, grocery,
      clothing, shoes, ecoShop, books,
      hairdresser, repair, cowork, logistics,
      museum, gallery, theatre,
    ];
  }

  // ---------- utils ----------
  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  int? _asIntOrNull(dynamic v) => _asInt(v);
}
