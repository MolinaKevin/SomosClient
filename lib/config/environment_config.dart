import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class EnvironmentConfig {
  static bool get isEmulator {
    return Platform.isAndroid || Platform.isIOS;
  }
  /// Devuelve la URL base (sin sufijo /api) definida en .env,
  /// o bien, en emulador de Android, 10.0.2.2,
  /// o 'localhost' en dispositivos físicos.
  static String getBaseUrl() {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2';
    } else if (Platform.isIOS) {
      // iOS emulator usa localhost directamente
      return 'http://localhost';
    } else {
      // Web o desktop
      return 'http://localhost';
    }
  }

  /// Concatena el sufijo /api automáticamente
  static String getApiUrl() {
    final base = getBaseUrl();
    return base.endsWith('/') ? '${base}api' : '$base/api';
  }

  static String getPublicUrl() {
    return getBaseUrl();
  }
}
