import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class CategoryService {
  List<Map<String, dynamic>>? _cachedCategories;

  Future<List<Map<String, dynamic>>> fetchCategories({bool forceRefresh = false}) async {
    if (_cachedCategories != null && !forceRefresh) {
      print('Using cached categories');
      return _cachedCategories!;
    }

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/categories');

    final headers = {
      'Content-Type': 'application/json',
    };

    print('Fetching categories from API: $url');
    final response = await http.get(url, headers: headers);

    print('Response status code: ${response.statusCode}');
    print('Raw categories response: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print('Parsed categories data: $data');
      _cachedCategories = _buildCategoryHierarchy(data);
      print('Processed category hierarchy: $_cachedCategories');
      return _cachedCategories!;
    } else {
      print('Failed to load categories: ${response.body}');
      throw Exception('Failed to load categories');
    }
  }

  List<Map<String, dynamic>> _buildCategoryHierarchy(List<dynamic> categories) {
    Map<int, Map<String, dynamic>> categoryMap = {};
    List<Map<String, dynamic>> rootCategories = [];

    print('Building category hierarchy...');
    for (var category in categories) {
      final id = category['id'] is int ? category['id'] : int.tryParse(category['id'].toString());
      final parentId = category['parent_id'] is int
          ? category['parent_id']
          : category['parent_id'] != null
          ? int.tryParse(category['parent_id'].toString())
          : null;

      if (id == null) {
        print('Error: Invalid ID in category: $category');
        continue;
      }

      categoryMap[id] = {
        'id': id,
        'name': category['translated_name'] ?? category['name'],
        'slug': category['slug'],
        'parent_id': parentId,
        'children': [],
      };
    }

    for (var category in categories) {
      final id = category['id'] is int ? category['id'] : int.tryParse(category['id'].toString());
      final parentId = category['parent_id'] is int
          ? category['parent_id']
          : category['parent_id'] != null
          ? int.tryParse(category['parent_id'].toString())
          : null;

      if (id == null) {
        print('Error: Skipping invalid category: $category');
        continue;
      }

      if (parentId != null && categoryMap.containsKey(parentId)) {
        print('Adding category $id as a child of $parentId');
        categoryMap[parentId]!['children'].add(categoryMap[id]!);
      } else {
        rootCategories.add(categoryMap[id]!);
      }
    }

    print('Final root categories: $rootCategories');
    return rootCategories;
  }
}
