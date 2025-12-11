import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fusion_new/l10n/app_localizations.dart';
import 'package:fusion_new/language_provider.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'step_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace with local IP 
  const backendBaseUrl = "http://localhost:3000/api";

  runApp(const MyApp(backendBaseUrl: backendBaseUrl));
}

class MyApp extends StatelessWidget {
  final String backendBaseUrl;

  const MyApp({super.key, required this.backendBaseUrl});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StepTracker()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Hochschulsport Fulda',
            theme: ThemeData(
              primarySwatch: Colors.green,
            ),
            // Localization setup
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('de'), // German
            ],
            locale: languageProvider.currentLocale,
            home: LoginPage(
              backendBaseUrl: backendBaseUrl,
            ),
          );
        },
      ),
    );
  }
}