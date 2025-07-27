import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_localizations.dart';
import 'splash_screen.dart';
import 'providers/user_data_provider.dart';
import 'services/translation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TranslationService>(create: (_) => TranslationService()),
        ChangeNotifierProvider(
          create: (context) {
            final translationService = Provider.of<TranslationService>(context, listen: false);
            final provider = UserDataProvider(translationService);
            provider.initialize();
            return provider;
          },
        ),
      ],
      child: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) {
          final locales = userDataProvider.availableLocales.isNotEmpty
              ? userDataProvider.availableLocales
              : const [
            Locale('en', ''),
            Locale('es', ''),
            Locale('de', ''),
          ];

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: locales,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
