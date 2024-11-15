import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'providers/user_data_provider.dart';
import 'screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    await userDataProvider.fetchAvailableLocales();
    await userDataProvider.loadUserData();
    await userDataProvider.loadTranslations();

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    final authToken = await _secureStorage.read(key: 'auth_token');
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    if (authToken == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            translations: userDataProvider.translations,
            onChangeLanguage: _changeLanguage,
            currentLocale: Locale(userDataProvider.language),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            translations: userDataProvider.translations,
            onChangeLanguage: _changeLanguage,
            currentLocale: Locale(userDataProvider.language),
            isAuthenticated: true,
          ),
        ),
      );
    }
  }

  void _changeLanguage(Locale newLocale) async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    await userDataProvider.saveUserData(
      userDataProvider.name,
      userDataProvider.email,
      userDataProvider.phone,
      newLocale.languageCode,
      userDataProvider.pass,
      userDataProvider.referrerPass,
    );

    await userDataProvider.loadTranslations();
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
