import 'package:flutter/material.dart';

import '../data/categories.dart';
import '../language_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/wiki_item.dart';
import '../theme.dart';
import '../theme_controller.dart';
import 'item_description.dart';
import 'item_image.dart';

/// Gira o filho continuamente (a bússola do logo).
class Spin extends StatefulWidget {
  const Spin({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 12),
  });

  final Widget child;
  final Duration duration;

  @override
  State<Spin> createState() => _SpinState();
}

class _SpinState extends State<Spin> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _controller, child: widget.child);
}

/// Faz o filho flutuar suavemente (o ícone do banner).
class Bob extends StatefulWidget {
  const Bob({super.key, required this.child});

  final Widget child;

  @override
  State<Bob> createState() => _BobState();
}

class _BobState extends State<Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -8 * t),
          child: Transform.rotate(angle: 0.07 * t, child: child),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    void wave(double base, double amp, double opacity) {
      final path = Path()..moveTo(0, base);
      final w = size.width / 4;
      for (var i = 0; i < 4; i++) {
        path.quadraticBezierTo(
          w * i + w / 2,
          base + (i.isEven ? -amp : amp),
          w * (i + 1),
          base,
        );
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = color.withValues(alpha: opacity),
      );
    }

    wave(size.height * 0.55, size.height * 0.45, 0.5);
    wave(size.height * 0.75, size.height * 0.35, 1);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.color != color;
}

/// Banner com gradiente de oceano, ondas e ícone flutuante.
class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.emoji,
    this.chips = const [],
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final List<String> chips;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [const Color(0xFF0F3A5C), p.sea, const Color(0xFF62C3C0)],
            stops: const [0, 0.6, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: p.deep.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 14,
              top: 12,
              child: Bob(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: compact ? 44 : 58),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  18, compact ? 16 : 20, 18, compact ? 38 : 46),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 76),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: pirate(compact ? 28 : 32, color: Colors.white),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chip in chips)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              chip,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -1,
              height: 30,
              child: CustomPaint(painter: _WavePainter(p.bg)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: p.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 18, color: p.ink),
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho: voltar (opcional), bússola, título, idioma e tema.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.title, this.onBack});

  final String? title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final strings = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          if (onBack != null) ...[
            _SquareButton(
              icon: Icons.arrow_back_rounded,
              tooltip: strings.back,
              onTap: onBack!,
            ),
            const SizedBox(width: 10),
          ],
          const Spin(child: Text('🧭', style: TextStyle(fontSize: 22))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title ?? strings.appTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pirate(24, color: p.ink),
            ),
          ),
          PopupMenuButton<Locale>(
            tooltip: strings.languageTooltip,
            initialValue: languageController.locale,
            onSelected: (locale) async {
              try {
                await languageController.setLocale(locale);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.languageSaveFailed)),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('pt', 'BR'),
                child: _LanguageMenuItem(
                  label: strings.languagePortuguese,
                  selected:
                      languageController.locale == const Locale('pt', 'BR'),
                ),
              ),
              PopupMenuItem(
                value: const Locale('en'),
                child: _LanguageMenuItem(
                  label: strings.languageEnglish,
                  selected: languageController.locale == const Locale('en'),
                ),
              ),
              PopupMenuItem(
                value: const Locale('fr'),
                child: _LanguageMenuItem(
                  label: strings.languageFrench,
                  selected: languageController.locale == const Locale('fr'),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.language_rounded, size: 20, color: p.ink),
            ),
          ),
          _SquareButton(
            icon: Icons.contrast_rounded,
            tooltip: strings.toggleTheme,
            onTap: () => themeController.toggle(Theme.of(context).brightness),
          ),
        ],
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 24,
            child: selected ? const Icon(Icons.check_rounded, size: 18) : null,
          ),
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}

class Tag extends StatelessWidget {
  const Tag(
    this.text, {
    super.key,
    this.translate = false,
    this.protectedTerms = const [],
  });

  final String text;
  final bool translate;
  final List<String> protectedTerms;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: p.gold.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(99),
      ),
      child: translate
          ? LocalizedText(
              text,
              maxLines: 1,
              protectedTerms: protectedTerms,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: p.ink,
              ),
            )
          : Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: p.ink,
              ),
            ),
    );
  }
}

/// Linha de lista: miniatura, nome, subtítulo e etiqueta.
class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.item,
    required this.category,
    required this.index,
    required this.onTap,
  });

  final WikiItem item;
  final Category category;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final description = item.description;
    final subtitle = description ?? item.subtitle;
    final tag = item.tag;
    final subtitleKey = description == null
        ? item.subtitleFieldKey ?? 'subtitle'
        : 'description';
    final translateSubtitle =
        subtitle != null && WikiItem.isTranslatableField(subtitleKey, subtitle);
    final translateTag = tag != null &&
        WikiItem.isTranslatableField(item.tagFieldKey ?? 'tag', tag);
    final protectedNames = item.protectedNames;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: p.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ItemImage(
                  category: category,
                  item: item,
                  index: index,
                  size: 54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null)
                        translateSubtitle
                            ? LocalizedText(
                                subtitle,
                                maxLines: 1,
                                protectedTerms: protectedNames,
                                style: TextStyle(fontSize: 12, color: p.mut),
                              )
                            : Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: p.mut),
                              ),
                    ],
                  ),
                ),
                if (tag != null) ...[
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Tag(
                      tag,
                      translate: translateTag,
                      protectedTerms: protectedNames,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: pirate(22, color: p.ink)),
          if (trailing != null)
            Text(trailing!, style: TextStyle(fontSize: 11.5, color: p.mut)),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
}

class EmptyView extends StatelessWidget {
  const EmptyView(this.message, {super.key, this.emoji = '🌊'});

  final String message;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.mut, fontSize: 13.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final strings = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚓', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: p.mut, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}
