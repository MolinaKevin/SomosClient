import 'dart:io';

class EnvironmentConfig {
  static Future<bool> isEmulator() async {
    if (Platform.isAndroid) {
      return true;
    }
    return false;
  }

  // Método para obtener el baseUrl
  static Future<String> getBaseUrl() async {
    bool emulator = await isEmulator();
    return emulator ? 'http://10.0.2.2/api' : 'http://localhost/api';
  }
}
