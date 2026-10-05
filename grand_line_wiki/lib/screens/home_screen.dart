import 'package:flutter/material.dart';

import '../data/categories.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'category_screen.dart';

/// Início: banner de boas-vindas e a grade com as 16 categorias.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: AppHeader()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HeroBanner(
                title: 'Bem-vindo ao Grand Line',
                subtitle: 'Personagens, frutas, bandos, ilhas e muito mais.',
                emoji: '🏴‍☠️',
                chips: ['16 categorias', 'JSON · REST'],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionTitle('Categorias', trailing: 'Escolha um endpoint'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) => _CategoryTile(
                category: categories[i],
                index: i,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CategoryScreen(category: categories[i], index: i),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Text(
                'Dados da One Piece API (api-onepiece.com), uma API não oficial. '
                'One Piece © Eiichiro Oda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: p.mut, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.index,
    required this.onTap,
  });

  final Category category;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Material(
      color: p.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CategoryThumb(
                  emoji: category.emoji,
                  index: index,
                  emojiSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                category.listPath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: p.acc,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
