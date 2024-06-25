import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_localizations.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
        Locale('de', ''),
      ],
    );
  }
}

class MyAppState extends StatefulWidget {
  final Function(Locale) onChangeLanguage;
  final Locale currentLocale;

  const MyAppState({super.key, required this.onChangeLanguage, required this.currentLocale});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppState> {
  Locale _locale = const Locale('en');
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _locale = widget.currentLocale;
    _checkAuth();
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Future<void> _checkAuth() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginScreen(onChangeLanguage: _changeLanguage, currentLocale: _locale),
      ));
    } else {
      final translations = await loadTranslations(_locale);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyHomePage(
          translations: translations,
          onChangeLanguage: _changeLanguage,
          currentLocale: _locale,
          initialIndex: 0,
          isAuthenticated: true,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: loadTranslations(_locale),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Error loading translations: ${snapshot.error}');
          return const Center(child: Text('Error loading translations'));
        }
        final translations = snapshot.data!;
        return MaterialApp(
          locale: _locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
            Locale('de', ''),
          ],
          debugShowCheckedModeBanner: false,
          home: MyHomePage(
            translations: translations,
            onChangeLanguage: _changeLanguage,
            currentLocale: _locale,
            initialIndex: 0,
            isAuthenticated: true,
          ),
        );
      },
    );
  }
}
