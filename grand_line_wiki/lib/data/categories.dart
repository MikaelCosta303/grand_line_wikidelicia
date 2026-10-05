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

  String get listPath => '/$slug/en';
  String get idPath => '/$slug/en/{id}';
  String get searchPath => '/$slug/en/search?name=';
  String get countPath => '/$slug/en/count';
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
