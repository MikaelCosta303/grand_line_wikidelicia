import '../l10n/app_localizations.dart';

/// As 16 categorias do app, uma para cada recurso da One Piece API.
///
/// Os caminhos seguem o padrão `/{slug}/en`. Só `characters` e `fruits`
/// foram confirmados na documentação; para os outros, confira o nome exato
/// do recurso em https://documentation.api-onepiece.com e ajuste o `slug`
/// aqui, que é o único lugar onde ele aparece.
class Category {
  const Category(this.name, this.emoji, this.slug, {this.confirmed = false});

  final String name;
  final String emoji;
  final String slug;
  final bool confirmed;

  String get listPath => listPathFor('en');
  String get idPath => idPathFor('en');
  String get searchPath => searchPathFor('en');
  String get countPath => countPathFor('en');

  String listPathFor(String languageCode) => '/$slug/$languageCode';
  String idPathFor(String languageCode) => '/$slug/$languageCode/{id}';
  String searchPathFor(String languageCode) =>
      '/$slug/$languageCode/search?name=';
  String countPathFor(String languageCode) => '/$slug/$languageCode/count';

  String localizedName(AppLocalizations strings) => switch (slug) {
    'sagas' => strings.categorySagas,
    'fruits' => strings.categoryFruits,
    'chapters' => strings.categoryChapters,
    'tomes' => strings.categoryTomes,
    'episodes' => strings.categoryEpisodes,
    'dials' => strings.categoryDials,
    'movies' => strings.categoryMovies,
    'swords' => strings.categorySwords,
    'hakis' => strings.categoryHakis,
    'luffy-gears' => strings.categoryLuffyGears,
    'luffy-techniques' => strings.categoryLuffyTechniques,
    'crews' => strings.categoryCrews,
    'characters' => strings.categoryCharacters,
    'boats' => strings.categoryBoats,
    'arcs' => strings.categoryArcs,
    'locates' => strings.categoryLocates,
    _ => name,
  };
}

const categories = <Category>[
  Category('Sagas', '📖', 'sagas'),
  Category('Akuma no Mi', '🍎', 'fruits', confirmed: true),
  Category('Capítulos', '📑', 'chapters'),
  Category('Volumes', '📚', 'tomes'),
  Category('Episódios', '📺', 'episodes'),
  Category('Dials', '🐚', 'dials'),
  Category('Filmes', '🎬', 'movies'),
  Category('Espadas', '⚔️', 'swords'),
  Category('Hakis', '🔥', 'hakis'),
  Category('Gears do Luffy', '⚙️', 'luffy-gears'),
  Category('Técnicas do Luffy', '👊', 'luffy-techniques'),
  Category('Bandos', '🚩', 'crews'),
  Category('Personagens', '🧑‍🤝‍🧑', 'characters', confirmed: true),
  Category('Barcos', '⛵', 'boats'),
  Category('Arcos', '🗺️', 'arcs'),
  Category('Locais', '📍', 'locates'),
];

/// Categoria usada por padrão na aba Buscar (Personagens).
const defaultSearchIndex = 12;
