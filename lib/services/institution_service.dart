import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart'; // Importa EnvironmentConfig

class InstitutionService {
  List<Map<String, dynamic>>? _cachedInstitutions;

  Future<List<Map<String, dynamic>>> fetchInstitutions({bool forceRefresh = false}) async {
    if (_cachedInstitutions != null && !forceRefresh) {
      return _cachedInstitutions!;
    }

    final baseUrl = await EnvironmentConfig.getBaseUrl(); // Obtiene la URL base
    final url = Uri.parse('$baseUrl/nros');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    print('Response status Ins: ${response.statusCode}');
    print('Response body Ins: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      _cachedInstitutions = data.map<Map<String, dynamic>>((institution) {
        return {
          'id': institution['id'],
          'name': institution['name'] ?? 'No Name',
          'address': institution['address'] ?? 'No Address',
          'phone_number': institution['phone_number'] ?? 'No Phone',
          'latitude': institution['latitude'] ?? '',
          'longitude': institution['longitude'] ?? '',
          'avatar_url': institution['avatar_url'] ?? '',
          'background_image': institution['background_image'] ?? '',
          'is_open': institution['is_open'] ?? false,
          'fotos_urls': institution['fotos_urls'],
        };
      }).toList();

      return _cachedInstitutions!;
    } else {
      throw Exception('Failed to load institutions');
    }
  }
}
