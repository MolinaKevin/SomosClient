import 'dart:convert';
import 'dart:io'; // Importa File para manejar archivos
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart'; // Importa EnvironmentConfig para obtener la URL base

class UserDataProvider extends ChangeNotifier {
  String name = 'Nombre no disponible';
  String email = 'Email no disponible';
  String phone = 'Teléfono no disponible';
  int points = 0;
  int totalReferrals = 0;
  String pass = 'No disponible'; // Somos Pass
  String referrerPass = 'No disponible'; // Pass de referido
  String language = 'es'; // Idioma predeterminado
  String profilePhotoUrl = ''; // URL del avatar del usuario

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  UserDataProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    // Obtener todos los datos almacenados de manera simultánea
    Map<String, String?> allData = await _secureStorage.readAll();

    // Imprimir todo el objeto tal como se recupera de FlutterSecureStorage
    print('Datos completos cargados desde secureStorage: $allData');

    // Asignar los valores a las variables correspondientes
    name = allData['user_name'] ?? 'Nombre no disponible';
    email = allData['user_email'] ?? 'Email no disponible';
    phone = allData['user_phone'] ?? 'Teléfono no disponible';
    points = int.tryParse(allData['user_points'] ?? '0') ?? 0;
    totalReferrals = int.tryParse(allData['user_total_referrals'] ?? '0') ?? 0;
    pass = allData['user_pass'] ?? 'No disponible';
    referrerPass = allData['user_referrer_pass'] ?? 'No disponible';
    language = allData['user_language'] ?? 'es';
    profilePhotoUrl = allData['profile_photo_url'] ?? '';

    // Imprimir los datos cargados individualmente
    print('Datos cargados:');
    print('Nombre: $name');
    print('Email: $email');
    print('Teléfono: $phone');
    print('Puntos: $points');
    print('Total Referidos: $totalReferrals');
    print('Somos Pass: $pass');
    print('Pass de referido: $referrerPass');
    print('Idioma: $language');
    print('Avatar URL: $profilePhotoUrl');

    notifyListeners(); // Notificar a los oyentes de los cambios
  }


  Future<void> saveUserData(String newName, String newEmail, String newPhone, String newLanguage, String newPass, String newReferrerPass) async {
    // Actualizar datos localmente antes de hacer la petición al servidor
    name = newName ?? name;
    email = newEmail ?? email;
    phone = newPhone ?? phone;
    language = newLanguage ?? language;
    pass = newPass ?? pass;
    referrerPass = newReferrerPass ?? referrerPass;

    // Enviar los datos actualizados al servidor
    try {
      final response = await _sendUserDataToServer(name, email, phone, language, pass, referrerPass);

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, guardar los datos localmente
        await _secureStorage.write(key: 'user_name', value: name);
        await _secureStorage.write(key: 'user_email', value: email);
        await _secureStorage.write(key: 'user_phone', value: phone);
        await _secureStorage.write(key: 'user_language', value: language); // Guardar el idioma
        await _secureStorage.write(key: 'user_pass', value: pass); // Guardar Somos Pass
        await _secureStorage.write(key: 'user_referrer_pass', value: referrerPass); // Guardar Pass de referido

        notifyListeners(); // Notificar a los oyentes de los cambios
        print('Datos guardados correctamente en el servidor y localmente.');
      } else {
        print('Error en la solicitud al servidor: ${response.body}');
      }
    } catch (e) {
      print('Error al enviar los datos al servidor: $e');
    }
  }

  // Función para hacer la solicitud al servidor utilizando baseUrl
  Future<http.Response> _sendUserDataToServer(String name, String email, String phone, String language, String pass, String referrerPass) async {
    // Obtén el baseUrl desde EnvironmentConfig
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user'); // Asegúrate de que este sea tu endpoint correcto

    // Obtén el token de autenticación almacenado
    final token = await _secureStorage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    // Cuerpo de la solicitud con los datos del usuario
    final Map<String, String> body = {
      'name': name,
      'email': email,
      'phone': phone,
      'language': language, // Se envía también el idioma
      'pass': pass, // Enviar Somos Pass
      'referrer_pass': referrerPass, // Enviar Pass de referido
    };

    // Encabezados que incluyen el token de autenticación
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Agrega el token de autenticación
    };

    print('Enviando datos al servidor con el token: $token');
    print('URL: $url');
    print('Body: $body');

    // Realiza la solicitud PUT
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    // Imprime la respuesta del servidor
    print('Código de respuesta del servidor: ${response.statusCode}');
    print('Respuesta del servidor: ${response.body}');

    return response;
  }

  // Función para subir el avatar
  Future<void> uploadAvatar(File imageFile) async {
    // Obtén el baseUrl desde EnvironmentConfig
    final baseUrl = await EnvironmentConfig.getBaseUrl();
    final url = Uri.parse('$baseUrl/user/upload-avatar'); // Endpoint para subir avatar

    // Obtén el token de autenticación almacenado
    final token = await _secureStorage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    // Crear la solicitud de multipart para subir el archivo
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('avatar', imageFile.path));

    print('Subiendo avatar al servidor con el token: $token');
    print('URL: $url');

    // Enviar la solicitud
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Avatar subido correctamente.');
      // Guardar la nueva URL del avatar
      final responseBody = await http.Response.fromStream(response);
      final jsonResponse = jsonDecode(responseBody.body);
      profilePhotoUrl = jsonResponse['profile_photo_url']; // Asumimos que la respuesta incluye la URL del nuevo avatar
      await _secureStorage.write(key: 'profile_photo_url', value: profilePhotoUrl);

      notifyListeners(); // Notificar a los oyentes del cambio de avatar
    } else {
      print('Error al subir el avatar: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    name = 'Nombre no disponible';
    email = 'Email no disponible';
    phone = 'Teléfono no disponible';
    points = 0;
    totalReferrals = 0;
    pass = 'No disponible'; // Limpiar Somos Pass
    referrerPass = 'No disponible'; // Limpiar Pass de referido
    language = 'es'; // Restablecer el idioma a 'es'
    profilePhotoUrl = ''; // Limpiar la URL del avatar

    notifyListeners(); // Notificar a los oyentes de los cambios
  }
}
