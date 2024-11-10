import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';
import 'splash_screen.dart';
import 'providers/user_data_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Delegados de localización
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Idiomas soportados
        supportedLocales: const [
          Locale('en', ''),
          Locale('es', ''),
          Locale('de', ''),
        ],
        // Determina el idioma inicial de la app
        localeResolutionCallback: (locale, supportedLocales) {
          // Asegura que el idioma sea uno soportado
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first; // Si no coincide, usar el primero (en este caso, inglés)
        },
        home: SplashScreen(), // Pantalla inicial de tu app
      ),
    );
  }
}
