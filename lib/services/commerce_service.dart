import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class CommerceService {
  List<Map<String, dynamic>>? _cachedCommerces;

  /// - 'prepend' -> mocks antes de los reales
  /// - 'append'  -> mocks después de los reales
  /// - 'only'    -> solo mocks (ignora API)
  static const String _mockMode = 'only';

  Future<List<Map<String, dynamic>>> fetchCommerces({bool forceRefresh = false}) async {
    if (_cachedCommerces != null && !forceRefresh) return _cachedCommerces!;

    final useMocks = EnvironmentConfig.testShowMockCommerce;
    final baseUrl  = EnvironmentConfig.getBaseUrl();
    final url      = Uri.parse('$baseUrl/commerces');
    final headers  = {'Content-Type': 'application/json'};

    final mocks = useMocks ? _mockCommerces() : const <Map<String, dynamic>>[];

    // Solo mocks
    if (useMocks && _mockMode == 'only') {
      _cachedCommerces = mocks;
      return _cachedCommerces!;
    }

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body)['data'] as List<dynamic>);
        final real = _parseCommerces(data);

        List<Map<String, dynamic>> combined;
        if (_mockMode == 'prepend') {
          combined = [...mocks, ...real];
        } else if (_mockMode == 'append') {
          combined = [...real, ...mocks];
        } else {
          combined = real;
        }

        _cachedCommerces = combined;
        return combined;
      } else {
        if (useMocks) {
          _cachedCommerces = mocks;
          return mocks;
        }
        throw Exception('Failed to load commerces (status ${response.statusCode})');
      }
    } catch (_) {
      if (useMocks) {
        _cachedCommerces = mocks;
        return mocks;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommercesByCategories(List<int> categoryIds) async {
    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/commerces/filter-by-categories');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'category_ids': categoryIds});

    // Solo mocks
    if (EnvironmentConfig.testShowMockCommerce && _mockMode == 'only') {
      return _mockCommerces()
          .where((m) => (m['category_ids'] as List).any(categoryIds.contains))
          .toList();
    }

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var real = _parseCommerces(jsonDecode(response.body)['data'] as List<dynamic>);

        if (EnvironmentConfig.testShowMockCommerce) {
          final mocks = _mockCommerces()
              .where((m) => (m['category_ids'] as List).any(categoryIds.contains))
              .toList();
          if (_mockMode == 'prepend') real = [...mocks, ...real];
          if (_mockMode == 'append')  real = [...real, ...mocks];
        }
        return real;
      } else {
        if (EnvironmentConfig.testShowMockCommerce) {
          return _mockCommerces()
              .where((m) => (m['category_ids'] as List).any(categoryIds.contains))
              .toList();
        }
        throw Exception('Failed to load filtered commerces (status ${response.statusCode})');
      }
    } catch (_) {
      if (EnvironmentConfig.testShowMockCommerce) {
        return _mockCommerces()
            .where((m) => (m['category_ids'] as List).any(categoryIds.contains))
            .toList();
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommercesByFilters({
    required List<int> categoryIds,
    required List<Map<String, dynamic>> seals,
  }) async {
    final baseUrl = EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/commerces/filter-by-filters');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'category_ids': categoryIds,
      'seals': seals.map((s) => {'id': s['id'], 'state': s['state']}).toList(),
    });

    // Solo mocks
    if (EnvironmentConfig.testShowMockCommerce && _mockMode == 'only') {
      return _filterMocks(categoryIds: categoryIds, seals: seals);
    }

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var real = _parseCommerces(jsonDecode(response.body)['data'] as List<dynamic>);
        if (EnvironmentConfig.testShowMockCommerce) {
          final mocks = _filterMocks(categoryIds: categoryIds, seals: seals);
          if (_mockMode == 'prepend') real = [...mocks, ...real];
          if (_mockMode == 'append')  real = [...real, ...mocks];
        }
        return real;
      } else {
        if (EnvironmentConfig.testShowMockCommerce) {
          return _filterMocks(categoryIds: categoryIds, seals: seals);
        }
        throw Exception('Failed to load filtered commerces (status ${response.statusCode})');
      }
    } catch (_) {
      if (EnvironmentConfig.testShowMockCommerce) {
        return _filterMocks(categoryIds: categoryIds, seals: seals);
      }
      rethrow;
    }
  }

  // --------- Parsers ----------
  List<Map<String, dynamic>> _parseCommerces(List<dynamic> data) {
    return data.map<Map<String, dynamic>>((c) => {
      'id': c['id'],
      'name': c['name'],
      'address': c['address'],
      'phone_number': c['phone_number'],
      'avatar_url': c['avatar_url'],
      'background_image': c['background_image'],
      'is_open': c['is_open'],
      'latitude': c['latitude'],
      'longitude': c['longitude'],
      'fotos_urls': c['fotos_urls'],
      'seals_with_state': _normalizeSealsWS(c['seals_with_state']),
      'category_ids': c['category_ids'],
    }).toList();
  }

  // --------- MOCKS (15 comercios) ----------
  List<Map<String, dynamic>> _mockCommerces() {
    return [
      // Innenstadt / centro
      {
        'id': -101,
        'name': 'Café SOMOS',
        'address': 'Lindenstr. 12, 14467 Potsdam',
        'phone_number': '+49 331 1234567',
        'avatar_url': 'https://picsum.photos/seed/somos-cafe/128',
        'background_image': 'https://picsum.photos/seed/somos-cafe-bg/900/400',
        'is_open': true,
        'latitude': 52.4009,
        'longitude': 13.0603,
        'fotos_urls': [
          'https://picsum.photos/seed/somos-cafe-f1/600/400',
          'https://picsum.photos/seed/somos-cafe-f2/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'full'},     // Local
          {'id': 2, 'state': 'partial'},
          {'id': 3, 'state': 'full'},
          {'id': 4, 'state': 'partial'},  // Vegan
        ]),
        'category_ids': [1, 4],
      },
      {
        'id': -102,
        'name': 'Tienda Verde',
        'address': 'Friedrich-Ebert-Str. 75, 14469 Potsdam',
        'phone_number': '+49 331 7654321',
        'avatar_url': 'https://picsum.photos/seed/tienda-verde/128',
        'background_image': 'https://picsum.photos/seed/tienda-verde-bg/900/400',
        'is_open': false,
        'latitude': 52.4092,
        'longitude': 13.0418,
        'fotos_urls': [
          'https://picsum.photos/seed/tienda-verde-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 2, 'state': 'full'},   // Fair Trade
        ]),
        'category_ids': [2, 5],
      },
      {
        'id': -107,
        'name': 'Fair Fashion Potsdam',
        'address': 'Brandenburger Str. 45, 14467 Potsdam',
        'phone_number': '+49 331 555000',
        'avatar_url': 'https://picsum.photos/seed/fair-fashion/128',
        'background_image': 'https://picsum.photos/seed/fair-fashion-bg/900/400',
        'is_open': true,
        'latitude': 52.3990,
        'longitude': 13.0630,
        'fotos_urls': [
          'https://picsum.photos/seed/fair-fashion-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 2, 'state': 'partial'}, // Fair
          {'id': 1, 'state': 'partial'},
          {'id': 4, 'state': 'full'},
          {'id': 3, 'state': 'full'},    // Organic
        ]),
        'category_ids': [3, 5],
      },

      // Potsdam West / Sanssouci
      {
        'id': -104,
        'name': 'Kaffee am Park',
        'address': 'Allee nach Sanssouci 3, 14471 Potsdam',
        'phone_number': '+49 331 222001',
        'avatar_url': 'https://picsum.photos/seed/kaffee-park/128',
        'background_image': 'https://picsum.photos/seed/kaffee-park-bg/900/400',
        'is_open': true,
        'latitude': 52.4050,
        'longitude': 13.0410,
        'fotos_urls': [
          'https://picsum.photos/seed/kaffee-park-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'partial'}, // Local
          {'id': 3, 'state': 'partial'}, // Organic
        ]),
        'category_ids': [1, 5],
      },
      {
        'id': -105,
        'name': 'Markthalle West',
        'address': 'Zeppelinstraße 24, 14471 Potsdam',
        'phone_number': '+49 331 222888',
        'avatar_url': 'https://picsum.photos/seed/markthalle-west/128',
        'background_image': 'https://picsum.photos/seed/markthalle-west-bg/900/400',
        'is_open': false,
        'latitude': 52.4010,
        'longitude': 13.0350,
        'fotos_urls': [
          'https://picsum.photos/seed/markthalle-west-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'full'},    // Local
          {'id': 2, 'state': 'partial'},
          {'id': 4, 'state': 'full'},
          {'id': 3, 'state': 'partial'}, // Organic
        ]),
        'category_ids': [2, 5],
      },

      // Bornstedt
      {
        'id': -108,
        'name': 'Hofladen Bornstedt',
        'address': 'Ribbeckstraße 23, 14469 Potsdam',
        'phone_number': '+49 331 9876501',
        'avatar_url': 'https://picsum.photos/seed/hofladen-bornstedt/128',
        'background_image': 'https://picsum.photos/seed/hofladen-bornstedt-bg/900/400',
        'is_open': true,
        'latitude': 52.4210,
        'longitude': 13.0430,
        'fotos_urls': [
          'https://picsum.photos/seed/hofladen-bornstedt-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 3, 'state': 'full'}, // Organic
          {'id': 2, 'state': 'partial'},
          {'id': 4, 'state': 'full'},
          {'id': 1, 'state': 'partial'}, // Local
        ]),
        'category_ids': [2, 5],
      },

      // Golm
      {
        'id': -112,
        'name': 'Eco Cosmetics Golm',
        'address': 'Zur Möser 16, 14476 Potsdam (Golm)',
        'phone_number': '+49 331 444123',
        'avatar_url': 'https://picsum.photos/seed/eco-cosmetics-golm/128',
        'background_image': 'https://picsum.photos/seed/eco-cosmetics-golm-bg/900/400',
        'is_open': true,
        'latitude': 52.4140,
        'longitude': 12.9680,
        'fotos_urls': [
          'https://picsum.photos/seed/eco-cosmetics-golm-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 3, 'state': 'partial'}, // Organic
          {'id': 2, 'state': 'partial'}, // Fair
        ]),
        'category_ids': [2, 8],
      },

      // Nauener Vorstadt
      {
        'id': -115,
        'name': 'Tea House Nauener Vorstadt',
        'address': 'Jägerallee 12, 14469 Potsdam',
        'phone_number': '+49 331 222990',
        'avatar_url': 'https://picsum.photos/seed/teahouse-nauener/128',
        'background_image': 'https://picsum.photos/seed/teahouse-nauener-bg/900/400',
        'is_open': false,
        'latitude': 52.4160,
        'longitude': 13.0630,
        'fotos_urls': [
          'https://picsum.photos/seed/teahouse-nauener-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'full'}, // Local
        ]),
        'category_ids': [1],
      },

      // Babelsberg (varios)
      {
        'id': -103,
        'name': 'BioBäckerei Babelsberg',
        'address': 'Karl-Liebknecht-Str. 28, 14482 Potsdam (Babelsberg)',
        'phone_number': '+49 331 300100',
        'avatar_url': 'https://picsum.photos/seed/biobaeckerei-babelsberg/128',
        'background_image': 'https://picsum.photos/seed/biobaeckerei-babelsberg-bg/900/400',
        'is_open': true,
        'latitude': 52.3910,
        'longitude': 13.1080,
        'fotos_urls': [
          'https://picsum.photos/seed/biobaeckerei-babelsberg-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 3, 'state': 'full'},    // Organic
          {'id': 1, 'state': 'partial'}, // Local
        ]),
        'category_ids': [2, 5],
      },
      {
        'id': -106,
        'name': 'Veggie Corner',
        'address': 'Rudolf-Breitscheid-Str. 50, 14482 Potsdam (Babelsberg Süd)',
        'phone_number': '+49 331 300200',
        'avatar_url': 'https://picsum.photos/seed/veggie-corner/128',
        'background_image': 'https://picsum.photos/seed/veggie-corner-bg/900/400',
        'is_open': true,
        'latitude': 52.3820,
        'longitude': 13.1170,
        'fotos_urls': [
          'https://picsum.photos/seed/veggie-corner-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 4, 'state': 'full'},    // Vegan
          {'id': 2, 'state': 'partial'}, // Fair
        ]),
        'category_ids': [1, 4],
      },
      {
        'id': -113,
        'name': 'Café am Griebnitzsee',
        'address': 'Albrechtstr. 2, 14482 Potsdam (Griebnitzsee)',
        'phone_number': '+49 331 300300',
        'avatar_url': 'https://picsum.photos/seed/cafe-griebnitz/128',
        'background_image': 'https://picsum.photos/seed/cafe-griebnitz-bg/900/400',
        'is_open': false,
        'latitude': 52.4030,
        'longitude': 13.1320,
        'fotos_urls': [
          'https://picsum.photos/seed/cafe-griebnitz-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'partial'}, // Local
          {'id': 4, 'state': 'partial'}, // Vegan
        ]),
        'category_ids': [1, 4],
      },

      // Drewitz / Stern / Teltower Vorstadt / Kirchsteigfeld
      {
        'id': -109,
        'name': 'Repair Café Drewitz',
        'address': 'Konrad-Wolf-Allee 30, 14480 Potsdam (Drewitz)',
        'phone_number': '+49 331 300400',
        'avatar_url': 'https://picsum.photos/seed/repair-cafe-drewitz/128',
        'background_image': 'https://picsum.photos/seed/repair-cafe-drewitz-bg/900/400',
        'is_open': true,
        'latitude': 52.3770,
        'longitude': 13.1160,
        'fotos_urls': [
          'https://picsum.photos/seed/repair-cafe-drewitz-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'full'}, // Local (comunidad)
        ]),
        'category_ids': [6],
      },
      {
        'id': -110,
        'name': 'Zero Waste Shop Stern',
        'address': 'Newtonstr. 5, 14480 Potsdam (Stern)',
        'phone_number': '+49 331 300500',
        'avatar_url': 'https://picsum.photos/seed/zero-waste-stern/128',
        'background_image': 'https://picsum.photos/seed/zero-waste-stern-bg/900/400',
        'is_open': true,
        'latitude': 52.3830,
        'longitude': 13.0580,
        'fotos_urls': [
          'https://picsum.photos/seed/zero-waste-stern-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 3, 'state': 'partial'}, // Organic
          {'id': 2, 'state': 'full'},    // Fair
        ]),
        'category_ids': [2, 5],
      },
      {
        'id': -111,
        'name': 'Radladen Teltower Vorstadt',
        'address': 'Schlaatzweg 1, 14473 Potsdam (Teltower Vorstadt)',
        'phone_number': '+49 331 300600',
        'avatar_url': 'https://picsum.photos/seed/radladen-teltower/128',
        'background_image': 'https://picsum.photos/seed/radladen-teltower-bg/900/400',
        'is_open': false,
        'latitude': 52.3860,
        'longitude': 13.0700,
        'fotos_urls': [
          'https://picsum.photos/seed/radladen-teltower-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'partial'}, // Local
        ]),
        'category_ids': [7],
      },
      {
        'id': -114,
        'name': 'Local Market Kirchsteigfeld',
        'address': 'Stern-Center-Platz 2, 14480 Potsdam (Kirchsteigfeld)',
        'phone_number': '+49 331 300700',
        'avatar_url': 'https://picsum.photos/seed/markt-kirchsteigfeld/128',
        'background_image': 'https://picsum.photos/seed/markt-kirchsteigfeld-bg/900/400',
        'is_open': true,
        'latitude': 52.3580,
        'longitude': 13.1310,
        'fotos_urls': [
          'https://picsum.photos/seed/markt-kirchsteigfeld-f1/600/400',
        ],
        'seals_with_state': _normalizeSealsWS([
          {'id': 1, 'state': 'full'}, // Local
          {'id': 3, 'state': 'partial'}, // Organic
        ]),
        'category_ids': [2, 5],
      },
    ];
  }

  /// Normaliza estados de seals a los que usa la UI:
  /// - 'verified'  -> 'full'
  /// - 'candidate' -> 'partial'
  /// - deja pasar 'full' / 'partial'
  List<Map<String, dynamic>> _normalizeSealsWS(dynamic raw) {
    final list = (raw as List?) ?? const [];
    return list.map<Map<String, dynamic>>((e) {
      final id = e['id'];
      final st = (e['state'] ?? '').toString().toLowerCase();
      String norm;
      switch (st) {
        case 'verified':
          norm = 'full';
          break;
        case 'candidate':
          norm = 'partial';
          break;
        case 'full':
        case 'partial':
          norm = st;
          break;
        default:
          norm = 'partial';
      }
      return {'id': id, 'state': norm};
    }).toList();
  }

  List<Map<String, dynamic>> _filterMocks({
    required List<int> categoryIds,
    required List<Map<String, dynamic>> seals,
  }) {
    final sealIdToStates = <int, Set<String>>{};
    for (final s in seals) {
      final id = s['id'] as int;
      final st = (s['state'] ?? '').toString().toLowerCase();
      final norm = (st == 'verified') ? 'full' : (st == 'candidate') ? 'partial' : st;
      sealIdToStates.putIfAbsent(id, () => <String>{}).add(norm);
    }

    bool matchesSeals(List<dynamic> sealsWithState) {
      if (sealIdToStates.isEmpty) return true;
      for (final entry in sealIdToStates.entries) {
        final id = entry.key;
        final acceptable = entry.value;
        final found = sealsWithState.any((m) =>
        (m['id'] == id) && (acceptable.isEmpty || acceptable.contains((m['state'] ?? '').toString())));
        if (!found) return false;
      }
      return true;
    }

    return _mockCommerces().where((m) {
      final cats = (m['category_ids'] as List).cast<int>();
      final sealsWS = (m['seals_with_state'] as List);
      final catOk = categoryIds.isEmpty || cats.any(categoryIds.contains);
      final sealOk = matchesSeals(sealsWS);
      return catOk && sealOk;
    }).toList();
  }
}
