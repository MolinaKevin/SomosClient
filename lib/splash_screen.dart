import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';
import 'screens/login_screen.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
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
        builder: (context) => LoginScreen(onChangeLanguage: (locale) {}, currentLocale: Locale('en')),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyAppState(onChangeLanguage: (locale) {}, currentLocale: Locale('en')),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // O el color de fondo que prefieras
      body: Center(
        child: Image.asset(
          'assets/images/somos_splash.png',
          //width: 200,
          //height: 200,
        ),
      ),
    );
  }
}