import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cores do wireframe, nos modos claro e escuro.
class Palette {
  const Palette({
    required this.bg,
    required this.bg2,
    required this.ink,
    required this.mut,
    required this.card,
    required this.line,
    required this.acc,
    required this.sea,
    required this.deep,
    required this.gold,
  });

  final Color bg;
  final Color bg2;
  final Color ink;
  final Color mut;
  final Color card;
  final Color line;
  final Color acc;
  final Color sea;
  final Color deep;
  final Color gold;

  static const light = Palette(
    bg: Color(0xFFF6EFE0),
    bg2: Color(0xFFEFE3C7),
    ink: Color(0xFF1A2A40),
    mut: Color(0xFF6D7788),
    card: Color(0xFFFFFDF8),
    line: Color(0xFFE6D9BB),
    acc: Color(0xFFD9432B),
    sea: Color(0xFF1F6F8B),
    deep: Color(0xFF10233A),
    gold: Color(0xFFE7AA2C),
  );

  static const dark = Palette(
    bg: Color(0xFF0C1522),
    bg2: Color(0xFF101D30),
    ink: Color(0xFFEEF2F7),
    mut: Color(0xFF93A0B3),
    card: Color(0xFF15233A),
    line: Color(0xFF243550),
    acc: Color(0xFFFF6A4D),
    sea: Color(0xFF4FB3D1),
    deep: Color(0xFF060D17),
    gold: Color(0xFFF2C14E),
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Fonte de título (Pirata One), como no wireframe.
TextStyle pirate(double size, {Color? color}) =>
    GoogleFonts.pirataOne(fontSize: size, color: color, height: 1.05);

/// Gradiente colorido usado nas miniaturas, variando pelo índice.
LinearGradient hueGradient(int i) {
  final a = HSLColor.fromAHSL(1, (i * 23 + 8.0) % 360, 0.85, 0.62).toColor();
  final b = HSLColor.fromAHSL(1, (i * 23 + 48.0) % 360, 0.80, 0.52).toColor();
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [a, b],
  );
}

ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Palette.dark : Palette.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.acc,
      brightness: brightness,
    ).copyWith(primary: p.acc, surface: p.card),
  );

  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme)
        .apply(bodyColor: p.ink, displayColor: p.ink),
    dividerColor: p.line,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.acc.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: states.contains(WidgetState.selected) ? p.acc : p.mut,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? p.acc : p.mut,
        ),
      ),
    ),
  );
}
