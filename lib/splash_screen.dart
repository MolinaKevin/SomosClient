import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'providers/user_data_provider.dart';
import 'screens/login_screen.dart';
import 'config/environment_config.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  Future<void> _initializeApp() async {
    final p = Provider.of<UserDataProvider>(context, listen: false);

    Future<void> _safeStep(
        String label,
        Future<void> Function() fn, {
          Duration timeout = const Duration(seconds: 5),
          Future<void> Function()? fallback,
        }) async {
      try {
        debugPrint('→ $label…');
        await fn().timeout(timeout);
        debugPrint('✓ $label listo');
      } on TimeoutException catch (e) {
        debugPrint('⏱ $label timeout: $e');
        if (fallback != null) await fallback();
      } catch (e, st) {
        debugPrint('✗ $label error: $e\n$st');
        if (fallback != null) await fallback();
      }
    }

    await _safeStep(
      'fetchAvailableLocales()',
          () => p.fetchAvailableLocales(),
      fallback: () async {
        p.availableLocales = const [Locale('es'), Locale('en'), Locale('de')];
      },
    );

    await _safeStep(
      'loadUserData()',
          () => p.loadUserData(),
    );

    await _safeStep(
      'loadTranslations()',
          () => p.loadTranslations(),
      fallback: () async {
        p.translations = {
          'navigation': {
            'map': 'Map',
            'list': 'List',
            'pointsTab': 'Points',
            'profile': 'Profile',
          },
          'common': {'close': 'Close'}
        };
      },
    );

    if (!mounted) return;
    _navigateToNextScreen();
  }


  Future<String?> _safeReadToken() async {
    try {
      return await _secureStorage
          .read(key: 'auth_token')
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('SecureStorage read failed: $e');
      return null;
    }
  }

  void _navigateToNextScreen() async {
    final userDataProvider =
    Provider.of<UserDataProvider>(context, listen: false);

    final authToken = await _safeReadToken();
    final forceLogin = EnvironmentConfig.testForceLogin;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final locale = Locale(userDataProvider.language);

      if (forceLogin || authToken == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              translations: userDataProvider.translations,
              onChangeLanguage: _changeLanguage,
              currentLocale: locale,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MyHomePage(
              translations: userDataProvider.translations,
              onChangeLanguage: _changeLanguage,
              currentLocale: locale,
              isAuthenticated: true,
            ),
          ),
        );
      }
    });
  }

  Future<void> _changeLanguage(Locale newLocale) async {
    final userDataProvider =
    Provider.of<UserDataProvider>(context, listen: false);

    try {
      await userDataProvider.saveUserData(
        userDataProvider.name,
        userDataProvider.email,
        userDataProvider.phone,
        newLocale.languageCode,
        userDataProvider.pass,
        userDataProvider.referrerPass,
      );
      await userDataProvider.loadTranslations();
    } catch (e, st) {
      debugPrint('Change language error: $e\n$st');
    } finally {
      if (!mounted) return;
      _navigateToNextScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7EFE4),
      body: Center(
        child: SizedBox(
          height: 120,
          child: Image(
            image: AssetImage('assets/images/somos_splash.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
