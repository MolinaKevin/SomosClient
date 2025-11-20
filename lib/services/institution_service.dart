import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class InstitutionService {
  List<Map<String, dynamic>>? _cachedInstitutions;

  /// Modo: 'prepend' (mocks primero), 'append' (mocks después), 'only' (solo mocks)
  static const String _mockMode = 'only';

  Future<List<Map<String, dynamic>>> fetchInstitutions({bool forceRefresh = false}) async {
    if (_cachedInstitutions != null && !forceRefresh) return _cachedInstitutions!;

    final useMocks = EnvironmentConfig.testShowMockNgo;
    final baseUrl = EnvironmentConfig.getBaseUrl(); // síncrono
    final url = Uri.parse('$baseUrl/nros');
    final headers = {'Content-Type': 'application/json'};

    final mocks = useMocks ? _mockInstitutions() : const <Map<String, dynamic>>[];

    // ---------- SOLO MOCKS ----------
    if (useMocks && _mockMode == 'only') {
      _cachedInstitutions = mocks;
      return _cachedInstitutions!;
    }

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body)['data'] as List<dynamic>);
        final real = _parseInstitutions(data);

        List<Map<String, dynamic>> combined;
        if (_mockMode == 'prepend') {
          combined = [...mocks, ...real];
        } else if (_mockMode == 'append') {
          combined = [...real, ...mocks];
        } else {
          combined = real;
        }

        _cachedInstitutions = combined;
        return combined;
      } else {
        if (useMocks) {
          _cachedInstitutions = mocks;
          return mocks;
        }
        throw Exception('Failed to load institutions (status ${response.statusCode})');
      }
    } catch (e) {
      if (useMocks) {
        _cachedInstitutions = mocks;
        return mocks;
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _parseInstitutions(List<dynamic> data) {
    return data.map<Map<String, dynamic>>((i) => {
      'id': i['id'],
      'name': i['name'] ?? 'No Name',
      'address': i['address'] ?? 'No Address',
      'phone_number': i['phone_number'] ?? 'No Phone',
      'latitude': i['latitude'] ?? '',
      'longitude': i['longitude'] ?? '',
      'avatar_url': i['avatar_url'] ?? '',
      'background_image': i['background_image'] ?? '',
      'is_open': i['is_open'] ?? false,
      'fotos_urls': i['fotos_urls'],
      'entity_type': 'institution',
    }).toList();
  }

// MOCKS
  List<Map<String, dynamic>> _mockInstitutions() {
    return [
      {
        'id': -201,
        'name': 'Fundación Árbol',
        'address': 'Am Stadtkanal 5, 14467 Potsdam',
        'phone_number': '+49 331 9876543',
        'latitude': 52.4025,
        'longitude': 13.0612,
        'avatar_url': 'https://picsum.photos/seed/fundacion-arbol/128',
        'background_image': 'https://picsum.photos/seed/fundacion-arbol-bg/900/400',
        'is_open': true,
        'fotos_urls': [
          'https://picsum.photos/seed/fundacion-arbol-1/600/400',
          'https://picsum.photos/seed/fundacion-arbol-2/600/400',
        ],
        'entity_type': 'institution',
      },
      {
        'id': -202,
        'name': 'EcoVida e.V.',
        'address': 'Hegelallee 15, 14467 Potsdam',
        'phone_number': '+49 331 4567890',
        'latitude': 52.4048,
        'longitude': 13.0599,
        'avatar_url': 'https://picsum.photos/seed/ecovida/128',
        'background_image': 'https://picsum.photos/seed/ecovida-bg/900/400',
        'is_open': false,
        'fotos_urls': [
          'https://picsum.photos/seed/ecovida-1/600/400',
        ],
        'entity_type': 'institution',
      },
    ];
  }
}
