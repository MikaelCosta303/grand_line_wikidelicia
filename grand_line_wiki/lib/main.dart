import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'theme.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.load();
  runApp(const GrandLineApp());
}

class GrandLineApp extends StatelessWidget {
  const GrandLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) => MaterialApp(
        title: 'Grand Line Wiki',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.mode,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const HomeShell(),
      ),
    );
  }
}
