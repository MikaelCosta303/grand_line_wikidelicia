import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const _key = 'app_locale';
  static const supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en'),
    Locale('fr'),
  ];

  Locale locale = supportedLocales.first;

  String get apiLanguageCode => locale.languageCode == 'fr' ? 'fr' : 'en';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_key);
    if (savedCode == null) return;

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.toLanguageTag() == savedCode) {
        locale = supportedLocale;
        return;
      }
    }
  }

  Future<void> setLocale(Locale value) async {
    if (!supportedLocales.contains(value) || value == locale) return;
    locale = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.toLanguageTag());
  }
}

final languageController = LanguageController();
