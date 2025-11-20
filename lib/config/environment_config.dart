import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool _envFlag(String key, {bool def = false}) {
  final v = dotenv.env[key]?.trim().toLowerCase();
  if (v == null) return def;
  return v == '1' || v == 'true' || v == 'yes' || v == 'y';
}

class EnvironmentConfig {
  // ---------- Helpers ----------
  static bool _bool(String key, {bool def = false}) {
    final v = dotenv.env[key]?.trim().toLowerCase();
    if (v == null) return def;
    return v == '1' || v == 'true' || v == 'yes' || v == 'y';
  }

  static int _int(String key, {int def = 0}) {
    final v = int.tryParse((dotenv.env[key] ?? '').trim());
    return v ?? def;
  }

  // ---------- Plataforma ----------
  static bool get isEmulator => Platform.isAndroid || Platform.isIOS;
  static bool get isRelease => kReleaseMode;

  // ---------- Base URLs ----------
  static String getBaseUrl() {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    if (Platform.isAndroid) {
      return 'http://10.0.2.2';
    } else if (Platform.isIOS) {
      return 'http://localhost';
    } else {
      return 'http://localhost';
    }
  }

  static String getApiUrl() {
    final base = getBaseUrl();
    return base.endsWith('/') ? '${base}api' : '$base/api';
  }

  static String getPublicUrl() {
    final pub = dotenv.env['PUBLIC_BASE_URL'];
    if (pub != null && pub.isNotEmpty) return pub;
    return getBaseUrl();
  }

  static String get mapTilesUrl {
    return dotenv.env['MAP_TILES_URL'] ??
        'https://abcd.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}{r}.png';
  }

  // ---------- Network ----------
  static Duration get networkTimeout =>
      Duration(milliseconds: _int('NETWORK_TIMEOUT_MS', def: 6000));

  // ---------- Testing flags ----------
  static bool get testForceLogin       => _envFlag('TEST_FORCE_LOGIN', def: false);
  static bool get testForceOnboarding  => _envFlag('TEST_FORCE_ONBOARDING', def: false);
  static bool get testForceSpotlight   => _envFlag('TEST_FORCE_SPOTLIGHT', def: false);
  static int  get testStartTab        => _int('TEST_START_TAB', def: 0).clamp(0, 3);
  static String? get testLocale {
    final v = dotenv.env['TEST_LOCALE']?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  // ---------- Mock / Demo content ----------
  static bool get testShowMockCommerce  =>
      _envFlag('TEST_SHOW_MOCK_COMMERCE', def: false);

  static bool get testShowMockNgo       =>
      _envFlag('TEST_SHOW_MOCK_NGO', def: false);

  // ---------- Mock / Server ----------
  static bool get mockServer => _envFlag('MOCK_SERVER', def: false);

}
