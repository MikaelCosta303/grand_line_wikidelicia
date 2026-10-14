import 'package:flutter/material.dart';

import 'language_controller.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.load();
  await languageController.load();
  runApp(const GrandLineApp());
}

class GrandLineApp extends StatelessWidget {
  const GrandLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) => ListenableBuilder(
        listenable: languageController,
        builder: (context, child) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          locale: languageController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          themeMode: themeController.mode,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
