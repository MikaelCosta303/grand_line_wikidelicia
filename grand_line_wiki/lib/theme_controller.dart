import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o tema escolhido (claro, escuro ou do sistema) e lembra entre aberturas.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode mode = ThemeMode.system;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (prefs.getString(_key)) {
        case 'dark':
          mode = ThemeMode.dark;
        case 'light':
          mode = ThemeMode.light;
        default:
          mode = ThemeMode.system;
      }
    } catch (_) {
      // Sem armazenamento disponível: segue o tema do sistema.
    }
  }

  Future<void> toggle(Brightness current) async {
    mode = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Ignora falha ao salvar: o tema continua valendo nesta sessão.
    }
  }
}

final themeController = ThemeController();
