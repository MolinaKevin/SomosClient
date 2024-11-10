import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';
import 'screens/login_screen.dart';
import 'app_localizations.dart'; // Importa las traducciones

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  Locale _userLocale = const Locale('en'); // Idioma por defecto

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    await Future.delayed(const Duration(seconds: 2)); // Simular la carga de splash

    // Cargar el idioma desde almacenamiento seguro si existe
    String? storedLocale = await _secureStorage.read(key: 'user_language');
    if (storedLocale != null) {
      _userLocale = Locale(storedLocale);
    }

    // Navegar a la pantalla principal con las traducciones correctas
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    final authToken = await _secureStorage.read(key: 'auth_token');

    // Obtener las traducciones utilizando `AppLocalizations`
    final translations = await loadTranslations(_userLocale);

    if (authToken == null) {
      // Ir a la pantalla de login si no hay token
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            translations: translations,
            onChangeLanguage: _changeLanguage,
            currentLocale: _userLocale,
          ),
        ),
      );
    } else {
      // Ir a la pantalla principal si el usuario ya está autenticado
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            translations: translations,
            onChangeLanguage: _changeLanguage,
            currentLocale: _userLocale,
            isAuthenticated: true,
          ),
        ),
      );
    }
  }

  void _changeLanguage(Locale newLocale) async {
    setState(() {
      _userLocale = newLocale;
    });
    await _secureStorage.write(key: 'user_language', value: newLocale.languageCode);

    // Recargar las traducciones y navegar a la pantalla principal
    final translations = await loadTranslations(newLocale);
    _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/somos_splash.png'),
      ),
    );
  }
}
