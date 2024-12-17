import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class SealService {
  List<Map<String, dynamic>>? _cachedSeals;

  Future<List<Map<String, dynamic>>> fetchSeals({bool forceRefresh = false}) async {
    if (_cachedSeals != null && !forceRefresh) {
      print('Using cached seals');
      return _cachedSeals!;
    }

    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/seals');

    final headers = {
      'Content-Type': 'application/json',
    };

    print('Fetching seals from API: $url');
    final response = await http.get(url, headers: headers);

    print('Response status code: ${response.statusCode}');
    print('Raw seals response: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['data'] is List) {
        final data = body['data'] as List<dynamic>;
        print('Parsed seals data: $data');
        _cachedSeals = _processSeals(data);
        print('Processed seals: $_cachedSeals');
        return _cachedSeals!;
      } else {
        throw Exception('Invalid JSON structure: "data" is missing or not a list');
      }
    } else {
      print('Failed to load seals: ${response.body}');
      throw Exception('Failed to load seals');
    }
  }

  List<Map<String, dynamic>> _processSeals(List<dynamic> seals) {
    return seals.map((seal) {
      return {
        'id': seal['id'],
        'name': seal['translated_name'] ?? seal['name'],
        'slug': seal['slug'],
        'icon': seal['icon'],
        'image': seal['image'],
      };
    }).toList();
  }
}
