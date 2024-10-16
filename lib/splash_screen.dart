import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';
import 'screens/login_screen.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, String> translations;

  const SplashScreen({super.key, required this.translations});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula la duración de la pantalla de inicio.
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginScreen(
          onChangeLanguage: (locale) {},
          currentLocale: Locale('en'),
          translations: widget.translations, // Ahora el campo existe
        ),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyHomePage(
          translations: widget.translations, // Usamos las mismas traducciones
          onChangeLanguage: (locale) {},
          currentLocale: Locale('en'),
          initialIndex: 0,
          isAuthenticated: true,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/somos_splash.png',
        ),
      ),
    );
  }
}
