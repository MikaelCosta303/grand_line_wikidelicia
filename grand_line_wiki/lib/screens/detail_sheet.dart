import 'package:flutter/material.dart';

import '../data/api_service.dart';
import '../data/commons_image_service.dart';
import '../data/categories.dart';
import '../language_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/wiki_item.dart';
import '../services/description_translation_service.dart';
import '../theme.dart';
import '../widgets/item_description.dart';
import '../widgets/item_image.dart';

Future<void> showDetailSheet(
  BuildContext context,
  Category category,
  WikiItem item,
  int index,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DetailSheet(category: category, item: item, index: index),
  );
}

/// Janela que sobe por baixo com os dados do item.
class DetailSheet extends StatefulWidget {
  const DetailSheet({
    super.key,
    required this.category,
    required this.item,
    required this.index,
    this.imageLoader,
    this.descriptionTranslator,
  });

  final Category category;
  final WikiItem item;
  final int index;
  final Future<CachedItemImage?> Function(Category, WikiItem)? imageLoader;
  final DescriptionTranslation? descriptionTranslator;

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  late WikiItem _item = widget.item;
  late Future<CachedItemImage?> _itemImage;
  late String _apiLanguageCode;
  int _refreshGeneration = 0;

  @override
  void initState() {
    super.initState();
    _apiLanguageCode = api.languageCode;
    _itemImage = _loadImage(_item);
    _refresh();
  }

  Future<CachedItemImage?> _loadImage(WikiItem item) =>
      (widget.imageLoader ?? commonsImageService.load)(widget.category, item);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = languageController.apiLanguageCode;
    if (languageCode == _apiLanguageCode) return;
    _apiLanguageCode = languageCode;
    _refresh();
  }

  /// Consulta o endpoint do idioma atual para trazer o registro completo.
  /// Se falhar, continua mostrando os dados que já vieram da lista.
  Future<void> _refresh() async {
    final id = widget.item.id;
    if (id == null) return;
    final generation = ++_refreshGeneration;
    final requestedLanguage = _apiLanguageCode;
    try {
      final fresh = await api.byId(widget.category, id);
      if (!mounted ||
          generation != _refreshGeneration ||
          requestedLanguage != _apiLanguageCode ||
          fresh.raw.isEmpty) {
        return;
      }
      setState(() {
        _item = fresh;
        _itemImage = _loadImage(fresh);
      });
    } catch (_) {
      // Mantém os dados da lista.
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final strings = AppLocalizations.of(context)!;
    final c = widget.category;
    final categoryName = c.localizedName(strings);
    final id = _item.id;
    final fields = _item.fields.where((f) => f.value != _item.title).toList();

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: p.line,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              FutureBuilder<CachedItemImage?>(
                future: _itemImage,
                builder: (context, snapshot) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ItemImage(
                      category: c,
                      item: _item,
                      index: widget.index,
                      height: 120,
                      emojiSize: 62,
                      radius: 16,
                      imageLoader: widget.imageLoader,
                    ),
                    if (snapshot.data?.attribution case final attribution?)
                      imageAttributionLinks(context, attribution),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(_item.title, style: pirate(28, color: p.ink)),
              const SizedBox(height: 8),
              _InfoRow(strings.detailCategory, categoryName),
              for (final field in fields)
                _InfoRow(
                    field.key,
                    field.value,
                    translateLabel: true,
                    translateValue: WikiItem.isTranslatableField(
                      field.key,
                      field.value,
                    ),
                    translator: widget.descriptionTranslator,
                    protectedTerms: _item.protectedNames,
                  ),
              if (id != null) _InfoRow(strings.detailId, id),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
    this.label,
    this.value, {
    this.translateLabel = false,
    this.translateValue = false,
    this.translator,
    this.protectedTerms = const [],
  });

  final String label;
  final String value;
  final bool translateLabel;
  final bool translateValue;
  final DescriptionTranslation? translator;
  final List<String> protectedTerms;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    const valueStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: translateLabel
                ? LocalizedText(
                    label,
                    translator: translator,
                    protectedTerms: protectedTerms,
                    sourceLanguageCode: 'en',
                    style: TextStyle(fontSize: 13, color: p.mut),
                  )
                : Text(label, style: TextStyle(fontSize: 13, color: p.mut)),
          ),
          Expanded(
            child: translateValue
                ? LocalizedText(
                    value,
                    translator: translator,
                    protectedTerms: protectedTerms,
                    style: valueStyle,
                  )
                : Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
