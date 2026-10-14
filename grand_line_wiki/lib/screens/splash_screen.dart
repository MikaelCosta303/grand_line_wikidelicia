import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _duration = Duration(milliseconds: 1600);

  @override
  void initState() {
    super.initState();
    _openHome();
  }

  Future<void> _openHome() async {
    await Future<void>.delayed(_duration);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeShell(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      body: ColoredBox(
        color: palette.bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: palette.deep,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.gold, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: palette.deep.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sailing_rounded,
                    color: palette.gold,
                    size: 58,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'GRAND LINE',
                  textAlign: TextAlign.center,
                  style: pirate(42, color: palette.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  'ONE PIECE WIKI',
                  style: TextStyle(
                    color: palette.mut,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 40),
                Semantics(
                  label: strings.loading,
                  child: SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(4),
                      color: palette.acc,
                      backgroundColor: palette.line,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
