import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../home_page.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;
  final Map<String, dynamic> translations; // Se agrega translations

  const LoginScreen({
    super.key,
    required this.onChangeLanguage,
    required this.currentLocale,
    required this.translations, // Required translations
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final AuthService authService = AuthService();
  bool _isLogin = true; // Variable para controlar si estamos en la pantalla de login o de registro

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      final result = await authService.login(email, password);

      if (result['success']) {
        final user = result['user'];

        // Aquí eliminamos la carga de las traducciones, ya que ya las recibimos como parámetro
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHomePage(
            translations: widget.translations, // Usamos las traducciones ya proporcionadas
            onChangeLanguage: widget.onChangeLanguage,
            currentLocale: widget.currentLocale,
            initialIndex: 0,
            isAuthenticated: true,
          ),
        ));
      } else {
        _showErrorMessage(result['error']);
      }
    } else {
      _showErrorMessage({'error': widget.translations['enterCredentials'] ?? 'Please enter credentials'});
    }
  }

  Future<void> _register() async {
    final name = _nameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final email = _emailController.text;

    if (name.isNotEmpty && password.isNotEmpty && email.isNotEmpty && password == confirmPassword) {
      final result = await authService.register(name, email, password, confirmPassword);

      if (result['success']) {
        final user = result['user'];

        // Eliminamos la carga de las traducciones
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHomePage(
            translations: widget.translations, // Usamos las traducciones ya proporcionadas
            onChangeLanguage: widget.onChangeLanguage,
            currentLocale: widget.currentLocale,
            initialIndex: 0,
            isAuthenticated: true,
          ),
        ));
      } else {
        _showErrorMessage(result['error']);
      }
    } else {
      _showErrorMessage({
        'error': widget.translations['enterAllFields'] ?? 'Please enter all fields and ensure passwords match'
      });
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.translations['fullName'] ?? 'Full Name',
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: widget.translations['email'] ?? 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: widget.translations['password'] ?? 'Password',
              ),
              obscureText: true,
            ),
            if (!_isLogin)
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: widget.translations['confirmPassword'] ?? 'Confirm Password',
                ),
                obscureText: true,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLogin ? _login : _register,
              child: Text(
                _isLogin
                    ? widget.translations['login'] ?? 'Login'
                    : widget.translations['register'] ?? 'Register',
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin
                    ? widget.translations['register'] ?? 'Register'
                    : widget.translations['login'] ?? 'Login',
              ),
            ),
            TextButton(
              onPressed: _skipLogin,
              child: Text(widget.translations['skipLogin'] ?? 'Skip Login'),
            ),
          ],
        ),
      ),
    );
  }
}
