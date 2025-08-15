import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/environment_config.dart';

class TranslationService {
  Future<Map<String, dynamic>> fetchTranslations(String language) async {
    final publicUrl = await EnvironmentConfig.getPublicUrl();
    final url = Uri.parse('$publicUrl/lang/$language.json');

    final response = await http.get(url).timeout(const Duration(seconds: 6));
    debugPrint('GET $url -> ${response.statusCode}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load translations ($language)');
  }


  Future<List<Locale>> fetchAvailableLocales() async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/l10n/locales');

    final response = await http.get(url).timeout(const Duration(seconds: 6));
    debugPrint('GET $url -> ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final locales = (jsonResponse['locales'] as List).cast<String>();
      return locales.map((code) => Locale(code)).toList();
    }
    throw Exception('Failed to load available locales');
  }

}
