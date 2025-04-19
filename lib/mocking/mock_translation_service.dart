import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MockTranslationService {
  Future<Map<String, dynamic>> fetchTranslations(String language) async {
    try {
      final jsonString = await rootBundle.loadString('lib/mocking/assets/l10n/$language.json');
      final Map<String, dynamic> translations = json.decode(jsonString);
      print('Loaded local translations for $language');
      return translations;
    } catch (e) {
      print('Error loading local translation for $language: $e');
      return {};
    }
  }

  Future<List<Locale>> fetchAvailableLocales() async {
    return const [
      Locale('en'),
      Locale('es'),
      Locale('de'),
    ];
  }
}
