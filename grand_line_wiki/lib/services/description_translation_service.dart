import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../language_controller.dart';

typedef DescriptionTranslation = Future<String> Function(String text);
typedef TextLanguageIdentification = Future<String?> Function(String text);

class DescriptionTranslationService {
  DescriptionTranslationService({
    DescriptionTranslation? translate,
    TextLanguageIdentification? identifyLanguage,
  })  : _translateOverride = translate,
        _identifyLanguageOverride = identifyLanguage;

  static const _supportedLanguages = <String, TranslateLanguage>{
    'en': TranslateLanguage.english,
    'fr': TranslateLanguage.french,
    'pt': TranslateLanguage.portuguese,
  };

  final DescriptionTranslation? _translateOverride;
  final TextLanguageIdentification? _identifyLanguageOverride;
  final Map<String, Future<String>> _cache = {};
  final Map<String, Future<String>> _languageCache = {};

  Future<String> translate(
    String text, {
    String? sourceLanguageCode,
    String? targetLanguageCode,
    Iterable<String> protectedTerms = const [],
  }) async {
    final target = targetLanguageCode ?? languageController.locale.languageCode;
    if (text.trim().isEmpty) return text;

    final defaultSource =
        sourceLanguageCode ?? languageController.apiLanguageCode;
    final source = await _identifySourceLanguage(text, defaultSource);
    if (source == target) return text;

    final sourceLanguage = _supportedLanguages[source];
    final targetLanguage = _supportedLanguages[target];
    if (sourceLanguage == null || targetLanguage == null) {
      throw ArgumentError('Unsupported translation pair: $source -> $target');
    }

    final terms = _protectedTerms(text, protectedTerms);
    final spans = terms.allMatches(text).toList();
    if (spans.isEmpty) {
      return _translateSegment(
          text, source, target, sourceLanguage, targetLanguage);
    }

    final output = StringBuffer();
    var cursor = 0;
    for (final span in spans) {
      if (span.start < cursor) continue;
      if (span.start > cursor) {
        output.write(
          await _translateSegment(
            text.substring(cursor, span.start),
            source,
            target,
            sourceLanguage,
            targetLanguage,
          ),
        );
      }
      output.write(text.substring(span.start, span.end));
      cursor = span.end;
    }
    if (cursor < text.length) {
      output.write(
        await _translateSegment(
          text.substring(cursor),
          source,
          target,
          sourceLanguage,
          targetLanguage,
        ),
      );
    }
    return output.toString();
  }

  Future<String> _translateSegment(
    String text,
    String sourceCode,
    String targetCode,
    TranslateLanguage source,
    TranslateLanguage target,
  ) async {
    if (text.trim().isEmpty) return text;
    final key = '$sourceCode:$targetCode:$text';
    final future = _cache.putIfAbsent(key, () async {
      if (_translateOverride != null) return _translateOverride(text);
      await _translationModelsReady(source, target);
      final pair = '$sourceCode:$targetCode';
      final translator = _translators.putIfAbsent(
        pair,
        () => OnDeviceTranslator(
          sourceLanguage: source,
          targetLanguage: target,
        ),
      );
      return translator.translateText(text);
    });
    try {
      return await future;
    } catch (_) {
      _cache.remove(key);
      rethrow;
    }
  }

  Future<String> _identifySourceLanguage(String text, String fallback) async {
    if (_identifyLanguageOverride == null && _translateOverride != null) {
      return fallback;
    }
    final key = '$fallback:$text';
    final future = _languageCache.putIfAbsent(key, () async {
      final identified =
          await (_identifyLanguageOverride ?? _identifyLanguage)(text);
      return identified != null && _supportedLanguages.containsKey(identified)
          ? identified
          : fallback;
    });
    return future;
  }

  static RegExp _protectedTerms(String text, Iterable<String> terms) {
    final unique = <String>{
      ...terms.where((term) => term.trim().length > 1),
      ...RegExp(r'\b[A-Z]\.(?:\s?[A-Z]\.)*')
          .allMatches(text)
          .map((match) => match.group(0)!),
      ...RegExp(r'\b[A-Z][A-Z0-9]{1,}(?:[-.][A-Z0-9]+)*\b')
          .allMatches(text)
          .map((match) => match.group(0)!),
    }.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    if (unique.isEmpty) return RegExp(r'(?!)');
    final alternatives = unique.map(RegExp.escape).join('|');
    return RegExp(
      '(?:^|[^A-Za-z0-9])(?:$alternatives)(?=\$|[^A-Za-z0-9])',
      caseSensitive: false,
    );
  }
}

final LanguageIdentifier _languageIdentifier = LanguageIdentifier(
  confidenceThreshold: 0.35,
);

Future<String?> _identifyLanguage(String text) async {
  final language = await _languageIdentifier.identifyLanguage(text);
  return language == _languageIdentifier.undeterminedLanguageCode
      ? null
      : language;
}

final Map<String, OnDeviceTranslator> _translators = {};
final Map<String, Future<void>> _modelsReady = {};

Future<void> _translationModelsReady(
  TranslateLanguage source,
  TranslateLanguage target,
) {
  final key = '${source.bcpCode}:${target.bcpCode}';
  return _modelsReady.putIfAbsent(key, () async {
    final manager = OnDeviceTranslatorModelManager();
    for (final language in {source, target}) {
      final downloaded = await manager.isModelDownloaded(language.bcpCode);
      if (!downloaded) {
        final success = await manager.downloadModel(language.bcpCode);
        if (!success) {
          throw StateError('Could not download ${language.bcpCode} model.');
        }
      }
    }
  }).catchError((Object error) {
    _modelsReady.remove(key);
    throw error;
  });
}

final descriptionTranslationService = DescriptionTranslationService();
