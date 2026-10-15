import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/commons_image_service.dart';
import '../data/categories.dart';
import '../l10n/app_localizations.dart';
import '../models/wiki_item.dart';
import 'category_thumb.dart';

class ItemImage extends StatelessWidget {
  const ItemImage({
    super.key,
    required this.category,
    required this.item,
    required this.index,
    this.size,
    this.height,
    this.emojiSize = 26,
    this.radius = 12,
    this.imageLoader,
  });

  final Category category;
  final WikiItem item;
  final int index;
  final double? size;
  final double? height;
  final double emojiSize;
  final double radius;
  final Future<CachedItemImage?> Function(Category, WikiItem)? imageLoader;

  @override
  Widget build(BuildContext context) => FutureBuilder<CachedItemImage?>(
        future: (imageLoader ?? commonsImageService.load)(category, item),
        builder: (context, snapshot) {
          final result = snapshot.data;
          final fallback = CategoryThumb(
            emoji: category.emoji,
            index: index,
            size: size,
            height: height,
            emojiSize: emojiSize,
            radius: radius,
          );
          if (result == null) {
            if (!snapshot.hasError) return fallback;
            return Stack(
              children: [
                fallback,
                Positioned(
                  right: 4,
                  top: 4,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.imageUnavailable,
                    child: const Icon(Icons.broken_image_outlined, size: 16),
                  ),
                ),
              ],
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: SizedBox(
                  width: size,
                  height: height ?? size,
                  child: Image.file(
                    result.file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => fallback,
                  ),
                ),
              ),
              if (result.attribution != null)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Tooltip(
                    message: AppLocalizations.of(
                      context,
                    )!.imageSource(result.attribution!.sourceName),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xCCFFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          Icons.copyright_rounded,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

Widget imageAttributionLinks(
  BuildContext context,
  ImageAttribution attribution,
) {
  final strings = AppLocalizations.of(context)!;
  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.imageSource(attribution.sourceName)),
        TextButton.icon(
          onPressed: () => _openCommonsLink(attribution.filePageUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 16),
          label: Text(
            strings.commonsImageCredit(
              attribution.fileTitle,
              attribution.author,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () => _openCommonsLink(attribution.licenseUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 16),
          label: Text(strings.commonsLicense(attribution.license)),
        ),
      ],
    ),
  );
}

Future<void> _openCommonsLink(String value) async {
  final uri = Uri.parse(value);
  const allowedHosts = {
    'commons.wikimedia.org',
    'onepiece.fandom.com',
    'creativecommons.org',
  };
  if (uri.scheme != 'https' || !allowedHosts.contains(uri.host.toLowerCase())) {
    throw FormatException('Invalid image attribution link: $value');
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened) throw StateError('Could not open Wikimedia Commons link.');
}
