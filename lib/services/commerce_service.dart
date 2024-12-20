
import 'dart:convert';
import 'package:http/http.dart' as http;
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

    print('Commerces wachin: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      _cachedCommerces = _parseCommerces(data);
      return _cachedCommerces!;
    } else {
      throw Exception('Failed to load commerces');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommercesByCategories(List<int> categoryIds) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/commerces/filter-by-categories');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'category_ids': categoryIds,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return _parseCommerces(data);
    } else {
      throw Exception('Failed to load filtered commerces');
    }
  }

  List<Map<String, dynamic>> _parseCommerces(List<dynamic> data) {
    return data.map<Map<String, dynamic>>((commerce) {
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
        'seals_with_state': commerce['seals_with_state'],
        'category_ids': commerce['category_ids'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchCommercesByFilters({
    required List<int> categoryIds,
    required List<Map<String, dynamic>> seals,
  }) async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/commerces/filter-by-filters');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'category_ids': categoryIds,
      'seals': seals.map((seal) => {
        'id': seal['id'],
        'state': seal['state'],
      }).toList(),
    });

    print('enviadoooo: ${body}');

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return _parseCommerces(data);
    } else {
      throw Exception('Failed to load filtered commerces');
    }
  }

}
