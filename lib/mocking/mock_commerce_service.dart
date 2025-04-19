class MockCommerceService {
  List<Map<String, dynamic>>? _cachedCommerces;

  Future<List<Map<String, dynamic>>> fetchCommerces({bool forceRefresh = false}) async {
    if (_cachedCommerces != null && !forceRefresh) {
      return _cachedCommerces!;
    }

    _cachedCommerces = [
      {
        "id": 1,
        "name": "Test Commerce",
        "description": null,
        "address": "test mejor",
        "city": "Göttingen",
        "plz": "37075",
        "email": null,
        "phone_number": null,
        "website": null,
        "opening_time": "07:53",
        "closing_time": "21:00",
        "latitude": "51.53636134",
        "longitude": "9.91903678",
        "points": null,
        "percent": "10.00",
        "donated_points": 90,
        "gived_points": 120,
        "active": true,
        "accepted": true,
        "avatar": null,
        "avatar_url": "lib/mocking/assets/avatar_com2.png",
        "background_image": "lib/mocking/assets/background_1.png",
        "fotos_urls": [
          "lib/mocking/images/foto_1.png",
          "lib/mocking/images/foto_2.png"
        ],
        "category_ids": [5, 8, 9],
        "seals_with_state": [
          {"id": 1, "state": "none"},
          {"id": 2, "state": "partial"},
          {"id": 3, "state": "full"},
          {"id": 4, "state": "none"},
          {"id": 5, "state": "partial"}
        ],
        "seal_ids": [1, 2, 3, 4, 5],
        "is_open": true,
      },
      {
        "id": 2,
        "name": "Comercio de Prueba",
        "description": null,
        "address": "123 Calle Falsa",
        "city": "Ciudad X",
        "plz": "12345",
        "email": null,
        "phone_number": null,
        "website": null,
        "opening_time": "07:59",
        "closing_time": "07:59",
        "latitude": null,
        "longitude": null,
        "points": null,
        "percent": "10.00",
        "donated_points": 716.56,
        "gived_points": 1235,
        "active": false,
        "accepted": false,
        "avatar": null,
        "avatar_url": "lib/mocking/assets/avatar_com1.png",
        "background_image": "lib/mocking/assets/background_2.png",
        "fotos_urls": [
          "lib/mocking/assets/background_3.png",
        ],
        "category_ids": [9, 10],
        "seals_with_state": [],
        "seal_ids": [],
        "is_open": false,
      }
    ];

    return _cachedCommerces!;
  }

  Future<List<Map<String, dynamic>>> fetchCommercesByCategories(List<int> categoryIds) async {
    return (await fetchCommerces()).where((c) {
      return categoryIds.any((id) => c['category_ids'].contains(id));
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchCommercesByFilters({
    required List<int> categoryIds,
    required List<Map<String, dynamic>> seals,
  }) async {
    return (await fetchCommerces()).where((c) {
      final matchCategory = categoryIds.any((id) => c['category_ids'].contains(id));
      final matchSeals = seals.every((s) =>
      c['seals_with_state']?.any((sw) => sw['id'] == s['id'] && sw['state'] == s['state']) ?? false);
      return matchCategory && matchSeals;
    }).toList();
  }
}
