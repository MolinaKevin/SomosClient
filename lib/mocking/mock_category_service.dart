class MockCategoryService {
  List<Map<String, dynamic>>? _cachedCategories;

  Future<List<Map<String, dynamic>>> fetchCategories({bool forceRefresh = false}) async {
    if (_cachedCategories != null && !forceRefresh) {
      print('Using cached categories from mock');
      return _cachedCategories!;
    }

    print('Fetching mock categories...');

    final mockRawCategories = [
      {'id': 1, 'name': 'Comida', 'translated_name': 'Food', 'slug': 'food', 'parent_id': null},
      {'id': 2, 'name': 'Ropa', 'translated_name': 'Clothes', 'slug': 'clothes', 'parent_id': null},
      {'id': 3, 'name': 'Bebidas', 'translated_name': 'Drinks', 'slug': 'drinks', 'parent_id': 1},
      {'id': 4, 'name': 'Verduras', 'translated_name': 'Vegetables', 'slug': 'vegetables', 'parent_id': 1},
      {'id': 5, 'name': 'Calzado', 'translated_name': 'Shoes', 'slug': 'shoes', 'parent_id': 2},
      {'id': 6, 'name': 'Electrónica', 'translated_name': 'Electronics', 'slug': 'electronics', 'parent_id': null},
      {'id': 7, 'name': 'Libros', 'translated_name': 'Books', 'slug': 'books', 'parent_id': null},
      {'id': 8, 'name': 'Restaurantes', 'translated_name': 'Restaurants', 'slug': 'restaurants', 'parent_id': 1},
      {'id': 9, 'name': 'Cafeterías', 'translated_name': 'Cafes', 'slug': 'cafes', 'parent_id': 1},
      {'id': 10, 'name': 'Supermercados', 'translated_name': 'Supermarkets', 'slug': 'supermarkets', 'parent_id': 1},
    ];

    _cachedCategories = _buildCategoryHierarchy(mockRawCategories);
    return _cachedCategories!;
  }

  List<Map<String, dynamic>> _buildCategoryHierarchy(List<dynamic> categories) {
    Map<int, Map<String, dynamic>> categoryMap = {};
    List<Map<String, dynamic>> rootCategories = [];

    for (var category in categories) {
      final id = category['id'];
      final parentId = category['parent_id'];

      categoryMap[id] = {
        'id': id,
        'name': category['translated_name'] ?? category['name'],
        'slug': category['slug'],
        'parent_id': parentId,
        'children': [],
      };
    }

    for (var category in categories) {
      final id = category['id'];
      final parentId = category['parent_id'];

      if (parentId != null && categoryMap.containsKey(parentId)) {
        categoryMap[parentId]!['children'].add(categoryMap[id]!);
      } else {
        rootCategories.add(categoryMap[id]!);
      }
    }

    return rootCategories;
  }
}
