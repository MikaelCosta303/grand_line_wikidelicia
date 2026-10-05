import 'dart:async';

import 'package:flutter/material.dart';

import '../data/api_service.dart';
import '../data/categories.dart';
import '../models/wiki_item.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'detail_sheet.dart';

/// Buscar: campo de busca com filtro por categoria, consultando
/// GET /{recurso}/en/search?name=
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  int _catIndex = defaultSearchIndex;
  int _token = 0;
  bool _loading = false;
  String? _error;
  String _query = '';
  List<WikiItem> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() => _query = value.trim());
    _debounce = Timer(const Duration(milliseconds: 400), _run);
  }

  void _pickCategory(int index) {
    setState(() => _catIndex = index);
    _run();
  }

  Future<void> _run() async {
    final query = _query;
    final token = ++_token;
    if (query.isEmpty) {
      setState(() {
        _loading = false;
        _error = null;
        _results = const [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final found = await api.search(categories[_catIndex], query);
      if (!mounted || token != _token) return;
      setState(() {
        _results = found;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || token != _token) return;
      setState(() {
        _error = '$e';
        _results = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final category = categories[_catIndex];
    final shown = _query.isEmpty ? '' : _query;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Buscar em ${category.name.toLowerCase()}…',
                hintStyle: TextStyle(color: p.mut),
                prefixIcon: Icon(Icons.search_rounded, color: p.mut),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                          _run();
                        },
                      ),
                filled: true,
                fillColor: p.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: p.acc),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (context, i) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final selected = i == _catIndex;
                return ChoiceChip(
                  showCheckmark: false,
                  label: Text('${categories[i].emoji} ${categories[i].name}'),
                  selected: selected,
                  onSelected: (_) => _pickCategory(i),
                  selectedColor: p.acc,
                  backgroundColor: p.card,
                  side: BorderSide(color: selected ? p.acc : p.line),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : p.ink,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: EndpointPill('${category.searchPath}$shown'),
          ),
          const SectionTitle('Resultados'),
          Expanded(child: _buildResults(category)),
        ],
      ),
    );
  }

  Widget _buildResults(Category category) {
    if (_loading) return const SingleChildScrollView(child: LoadingView());
    if (_error != null) {
      return SingleChildScrollView(
        child: ErrorView(message: _error!, onRetry: _run),
      );
    }
    if (_query.isEmpty) {
      return SingleChildScrollView(
        child: EmptyView(
          'Digite um nome para buscar em ${category.name}.',
          emoji: '🔎',
        ),
      );
    }
    if (_results.isEmpty) {
      return SingleChildScrollView(
        child: EmptyView('Nenhum resultado para "$_query".'),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _results.length,
      itemBuilder: (context, i) => ItemRow(
        item: _results[i],
        category: category,
        index: _catIndex + i,
        onTap: () => showDetailSheet(
          context,
          category,
          _results[i],
          _catIndex + i,
        ),
      ),
    );
  }
}
