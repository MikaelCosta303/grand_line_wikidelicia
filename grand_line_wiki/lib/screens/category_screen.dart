import 'package:flutter/material.dart';

import '../data/api_service.dart';
import '../data/categories.dart';
import '../language_controller.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_api_error.dart';
import '../models/wiki_item.dart';
import '../widgets/widgets.dart';
import 'detail_sheet.dart';

/// Tela de uma categoria: banner com contagem e lista da API.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.category, required this.index});

  final Category category;
  final int index;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<WikiItem>> _items;
  late Future<int> _count;
  late String _apiLanguageCode;

  @override
  void initState() {
    super.initState();
    _apiLanguageCode = api.languageCode;
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = languageController.apiLanguageCode;
    if (languageCode == _apiLanguageCode) return;
    _apiLanguageCode = languageCode;
    _load(refresh: true);
  }

  void _load({bool refresh = false}) {
    _items = api.list(widget.category, refresh: refresh);
    _count = api.count(widget.category);
  }

  Widget _header(BuildContext context) {
    final c = widget.category;
    final strings = AppLocalizations.of(context)!;
    final name = c.localizedName(strings);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppHeader(title: name, onBack: () => Navigator.of(context).pop()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<int>(
            future: _count,
            builder: (context, snap) => HeroBanner(
              title: name,
              emoji: c.emoji,
              compact: true,
              chips: snap.hasData
                  ? [strings.itemCount('${snap.data}')]
                  : const [],
            ),
          ),
        ),
        SectionTitle(name),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<WikiItem>>(
          future: _items,
          builder: (context, snap) {
            final slivers = <Widget>[
              SliverToBoxAdapter(child: _header(context)),
            ];

            if (snap.connectionState != ConnectionState.done) {
              slivers.add(const SliverToBoxAdapter(child: LoadingView()));
            } else if (snap.hasError) {
              slivers.add(
                SliverToBoxAdapter(
                  child: ErrorView(
                    message: localizedApiError(context, snap.error!),
                    onRetry: () => setState(() => _load(refresh: true)),
                  ),
                ),
              );
            } else {
              final items = snap.data ?? const <WikiItem>[];
              if (items.isEmpty) {
                slivers.add(
                  SliverToBoxAdapter(
                    child: EmptyView(strings.emptyCategory),
                  ),
                );
              } else {
                slivers.add(
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) => ItemRow(
                        item: items[i],
                        category: c,
                        index: widget.index + i,
                        onTap: () => showDetailSheet(
                          context,
                          c,
                          items[i],
                          widget.index + i,
                        ),
                      ),
                    ),
                  ),
                );
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _load(refresh: true));
                try {
                  await _items;
                } catch (_) {
                  // O erro já aparece na tela.
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: slivers,
              ),
            );
          },
        ),
      ),
    );
  }
}
