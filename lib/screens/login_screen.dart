import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../home_page.dart';
import '../app_localizations.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;

  const LoginScreen({super.key, required this.onChangeLanguage, required this.currentLocale});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isLogin = true; // Variable para controlar si estamos en la pantalla de login o de registro

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      final url = Uri.parse('http://localhost/api/login');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'email': email, 'password': password});

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['token'];
          final user = data['user'];

          await _secureStorage.write(key: 'auth_token', value: token);
          await _secureStorage.write(key: 'user_name', value: user['name']);
          await _secureStorage.write(key: 'user_email', value: user['email']);
          await _secureStorage.write(key: 'user_phone', value: user['phone_number'] ?? '');

          final translations = await loadTranslations(widget.currentLocale);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MyHomePage(
              translations: translations,
              onChangeLanguage: widget.onChangeLanguage,
              currentLocale: widget.currentLocale,
              initialIndex: 0,
              isAuthenticated: true,
            ),
          ));
        } else {
          final errorData = jsonDecode(response.body);
          _showErrorMessage(errorData);
        }
      } catch (e) {
        _showErrorMessage({'error': 'Network error: $e'});
      }
    } else {
      _showErrorMessage({'error': 'Please enter credentials'});
    }
  }

  Future<void> _register() async {
    final name = _nameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final email = _emailController.text;

    if (name.isNotEmpty && password.isNotEmpty && email.isNotEmpty && password == confirmPassword) {
      final url = Uri.parse('http://localhost/api/register');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final token = data['token'];
          final user = data['user'];

          await _secureStorage.write(key: 'auth_token', value: token);
          await _secureStorage.write(key: 'user_name', value: user['name']);
          await _secureStorage.write(key: 'user_email', value: user['email']);
          await _secureStorage.write(key: 'user_phone', value: user['phone_number'] ?? '');

          final translations = await loadTranslations(widget.currentLocale);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MyHomePage(
              translations: translations,
              onChangeLanguage: widget.onChangeLanguage,
              currentLocale: widget.currentLocale,
              initialIndex: 0,
              isAuthenticated: true,
            ),
          ));
        } else {
          final errorData = jsonDecode(response.body);
          _showErrorMessage(errorData);
        }
      } catch (e) {
        _showErrorMessage({'error': 'Network error: $e'});
      }
    } else {
      _showErrorMessage({'error': 'Please enter all fields and ensure passwords match'});
    }
  }

  void _skipLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MyHomePage(
        translations: {}, // Deberías cargar las traducciones aquí
        onChangeLanguage: widget.onChangeLanguage,
        currentLocale: widget.currentLocale,
        initialIndex: 0,
        isAuthenticated: false, // Añade este parámetro
      ),
    ));
  }

  void _showErrorMessage(Map<String, dynamic> errorData) {
    String errorMessage = errorData.values.join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: localizations.translate('full_name')),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: localizations.translate('email')),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: localizations.translate('password')),
              obscureText: true,
            ),
            if (!_isLogin)
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: localizations.translate('confirm_password')),
                obscureText: true,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLogin ? _login : _register,
              child: Text(_isLogin ? localizations.translate('login') : localizations.translate('register')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? localizations.translate('register') : localizations.translate('login')),
            ),
            TextButton(
              onPressed: _skipLogin,
              child: Text(localizations.translate('skip_login')),
            ),
          ],
        ),
      ),
    );
  }
}
