import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'providers/user_data_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Puedes definir aquí tus traducciones iniciales o cargarlas desde otro lugar
    final Map<String, String> initialTranslations = {
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
      'viewPoints': 'Ver Puntos',
      'viewReferrals': 'Ver Referidos',
      // Agrega más traducciones aquí
    };

    return ChangeNotifierProvider(
      create: (_) => UserDataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          translations: initialTranslations, // Pasar las traducciones aquí
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('es', ''),
          Locale('de', ''),
        ],
      ),
    );
  }
}
