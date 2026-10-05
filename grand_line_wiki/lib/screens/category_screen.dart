import 'package:flutter/material.dart';

import '../data/api_service.dart';
import '../data/categories.dart';
import '../models/wiki_item.dart';
import '../widgets/widgets.dart';
import 'detail_sheet.dart';

/// Tela de uma categoria: banner, endpoints consultados e a lista da API.
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load({bool refresh = false}) {
    _items = api.list(widget.category, refresh: refresh);
    _count = api.count(widget.category);
  }

  Widget _header(BuildContext context) {
    final c = widget.category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppHeader(title: c.name, onBack: () => Navigator.of(context).pop()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<int>(
            future: _count,
            builder: (context, snap) => HeroBanner(
              title: c.name,
              subtitle: 'Base: ${OnePieceApi.host}${OnePieceApi.basePath}',
              emoji: c.emoji,
              compact: true,
              chips: snap.hasData ? ['${snap.data} itens'] : const [],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: EndpointBox(
            lines: [
              ('Listar', c.listPath),
              ('Por ID', c.idPath),
              ('Buscar', c.searchPath),
              ('Contagem', c.countPath),
            ],
          ),
        ),
        SectionTitle(c.name),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
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
                    message: '${snap.error}',
                    onRetry: () => setState(() => _load(refresh: true)),
                  ),
                ),
              );
            } else {
              final items = snap.data ?? const <WikiItem>[];
              if (items.isEmpty) {
                slivers.add(
                  const SliverToBoxAdapter(
                    child: EmptyView('Nenhum item retornado por este endpoint.'),
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
