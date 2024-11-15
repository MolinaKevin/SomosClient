import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/environment_config.dart';

class TranslationService {
  Future<Map<String, dynamic>> fetchTranslations(String language) async {
    final publicUrl = await EnvironmentConfig.getPublicUrl();
    final url = Uri.parse('$publicUrl/lang/$language.json');

    final response = await http.get(url);
    print('It will try in url: ${url}');
    print('Response code for translations: ${response.statusCode}');
    print('Response body for translations: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> translations = jsonDecode(response.body);
      print('Translations loaded: $translations');
      return translations;
    } else {
      print('Failed to load translations for language: $language');
      throw Exception('Failed to load translations');
    }
  }

  Future<List<Locale>> fetchAvailableLocales() async {
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/l10n/locales');

    final response = await http.get(url);
    print('Response code for available locales: ${response.statusCode}');
    print('Response body for available locales: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('locales')) {
        List<dynamic> locales = jsonResponse['locales'];
        List<Locale> localeList = locales.map((code) => Locale(code as String)).toList();
        print('Available locales loaded: $localeList');
        return localeList;
      } else {
        throw Exception('Locales key not found in response');
      }
    } else {
      print('Failed to load available locales');
      throw Exception('Failed to load available locales');
    }
  }
}
