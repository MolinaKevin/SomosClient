import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/environment_config.dart';

class CommerceService {
  List<Map<String, dynamic>>? _cachedCommerces;

  Future<List<Map<String, dynamic>>> fetchCommerces({bool forceRefresh = false}) async {
    if (_cachedCommerces != null && !forceRefresh) {
      return _cachedCommerces!;
    }

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/commerces');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      _cachedCommerces = data.map<Map<String, dynamic>>((commerce) {
        return {
          'id': commerce['id'],
          'name': commerce['name'],
          'address': commerce['address'],
          'phone_number': commerce['phone_number'],
          'avatar_url': commerce['avatar_url'],
          'background_image': commerce['background_image'],
          'is_open': commerce['is_open'],
          'latitude': commerce['latitude'],
          'longitude': commerce['longitude'],
          'fotos_urls': commerce['fotos_urls'],
        };
      }).toList();
      return _cachedCommerces!;
    } else {
      throw Exception('Failed to load commerces');
    }
  }
}
