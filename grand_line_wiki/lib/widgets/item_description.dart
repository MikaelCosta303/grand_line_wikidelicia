import 'package:flutter/material.dart';

import '../data/api_service.dart';
import '../l10n/app_localizations.dart';
import '../services/description_translation_service.dart';

class LocalizedText extends StatelessWidget {
  const LocalizedText(
    this.text, {
    super.key,
    this.maxLines,
    this.style,
    this.translator,
    this.protectedTerms = const [],
    this.sourceLanguageCode,
  });

  final String text;
  final int? maxLines;
  final TextStyle? style;
  final DescriptionTranslation? translator;
  final List<String> protectedTerms;
  final String? sourceLanguageCode;

  @override
  Widget build(BuildContext context) {
    final original = Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: style,
    );
    final sourceLanguageCode = this.sourceLanguageCode ?? api.languageCode;
    final strings = AppLocalizations.of(context)!;
    return FutureBuilder<String>(
      future: translator != null
          ? translator!(text)
          : descriptionTranslationService.translate(
              text,
              sourceLanguageCode: sourceLanguageCode,
              protectedTerms: protectedTerms,
            ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              original,
              Text(
                strings.translationUnavailable,
                maxLines: maxLines,
                overflow: maxLines == null ? null : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          );
        }
        return Text(
          snapshot.data ?? text,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          style: style,
        );
      },
    );
  }
}
