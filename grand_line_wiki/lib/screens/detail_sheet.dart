import 'package:flutter/material.dart';

import '../data/api_service.dart';
import '../data/categories.dart';
import '../models/wiki_item.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

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

/// Janela que sobe por baixo com os dados do item e o endpoint consultado.
class DetailSheet extends StatefulWidget {
  const DetailSheet({
    super.key,
    required this.category,
    required this.item,
    required this.index,
  });

  final Category category;
  final WikiItem item;
  final int index;

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  late WikiItem _item = widget.item;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// Consulta GET /{recurso}/en/{id} para trazer o registro completo.
  /// Se falhar, continua mostrando os dados que já vieram da lista.
  Future<void> _refresh() async {
    final id = widget.item.id;
    if (id == null) return;
    try {
      final fresh = await api.byId(widget.category, id);
      if (!mounted || fresh.raw.isEmpty) return;
      setState(() => _item = fresh);
    } catch (_) {
      // Mantém os dados da lista.
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final c = widget.category;
    final id = _item.id;
    final endpoint = id != null
        ? 'GET ${OnePieceApi.basePath}/${c.slug}/en/$id'
        : 'GET ${OnePieceApi.basePath}/${c.slug}/en';
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
              CategoryThumb(
                emoji: c.emoji,
                index: widget.index,
                imageUrl: _item.imageUrl,
                height: 120,
                emojiSize: 62,
                radius: 16,
              ),
              const SizedBox(height: 12),
              Text(_item.title, style: pirate(28, color: p.ink)),
              const SizedBox(height: 8),
              _InfoRow('Categoria', c.name),
              for (final field in fields) _InfoRow(field.key, field.value),
              if (id != null) _InfoRow('ID', id),
              _InfoRow('Endpoint', endpoint, selectable: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.selectable = false});

  final String label;
  final String value;
  final bool selectable;

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
            child: Text(label, style: TextStyle(fontSize: 13, color: p.mut)),
          ),
          Expanded(
            child: selectable
                ? SelectableText(value, style: valueStyle)
                : Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
