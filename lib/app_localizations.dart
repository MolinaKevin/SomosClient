import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, dynamic> _localizedStrings;

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('lib/mocking/assets/l10n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap;
      return true;
    } catch (e) {
      print('Error loading JSON file for locale ${locale.languageCode}: $e');
      _localizedStrings = {};
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

Future<Map<String, dynamic>> loadTranslations(Locale locale) async {
  try {
    final String jsonString = await rootBundle.loadString('lib/l10n/intl_${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap;
  } catch (e) {
    print('Error loading JSON file for locale ${locale.languageCode}: $e');
    return {};
  }
}
