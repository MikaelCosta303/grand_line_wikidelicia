// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Grand Line Wiki';

  @override
  String get languageTooltip => 'Trocar idioma';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSaveFailed =>
      'Não foi possível salvar o idioma selecionado.';

  @override
  String get back => 'Voltar';

  @override
  String get toggleTheme => 'Alternar tema';

  @override
  String get homeWelcome => 'Bem-vindo à Grand Line';

  @override
  String get homeSubtitle => 'Personagens, frutas, bandos, ilhas e muito mais.';

  @override
  String get categoryCount => '16 categorias';

  @override
  String get homeSectionHint => 'Explore o universo';

  @override
  String get categories => 'Categorias';

  @override
  String get apiDisclaimer =>
      'Dados da One Piece API (api-onepiece.com), uma API não oficial. One Piece © Eiichiro Oda.';

  @override
  String get search => 'Buscar';

  @override
  String itemCount(String count) {
    return '$count itens';
  }

  @override
  String get emptyCategory => 'Nenhum item encontrado.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get detailCategory => 'Categoria';

  @override
  String get detailId => 'ID';

  @override
  String get homeTab => 'Início';

  @override
  String get searchTab => 'Buscar';

  @override
  String searchHint(Object category) {
    return 'Buscar em $category…';
  }

  @override
  String get results => 'Resultados';

  @override
  String searchPrompt(Object category) {
    return 'Digite um nome para buscar em $category.';
  }

  @override
  String noSearchResults(Object query) {
    return 'Nenhum resultado para \"$query\".';
  }

  @override
  String get loading => 'Carregando';

  @override
  String get apiNotFound => 'Não encontrado (404).';

  @override
  String apiStatusError(String status) {
    return 'A API respondeu com erro $status.';
  }

  @override
  String get apiTimeout => 'A API demorou demais para responder.';

  @override
  String get apiOffline => 'Sem conexão com a internet ou API indisponível.';

  @override
  String get apiUnexpected => 'Resposta inesperada da API.';

  @override
  String get apiItemNotFound => 'Item não encontrado.';

  @override
  String get apiEndpointNotFound =>
      'Esta categoria está indisponível no momento.';

  @override
  String get categorySagas => 'Sagas';

  @override
  String get categoryFruits => 'Akuma no Mi';

  @override
  String get categoryChapters => 'Capítulos';

  @override
  String get categoryTomes => 'Volumes';

  @override
  String get categoryEpisodes => 'Episódios';

  @override
  String get categoryDials => 'Dials';

  @override
  String get categoryMovies => 'Filmes';

  @override
  String get categorySwords => 'Espadas';

  @override
  String get categoryHakis => 'Hakis';

  @override
  String get categoryLuffyGears => 'Gears do Luffy';

  @override
  String get categoryLuffyTechniques => 'Técnicas do Luffy';

  @override
  String get categoryCrews => 'Bandos';

  @override
  String get categoryCharacters => 'Personagens';

  @override
  String get categoryBoats => 'Barcos';

  @override
  String get categoryArcs => 'Arcos';

  @override
  String get categoryLocates => 'Locais';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Grand Line Wiki';

  @override
  String get languageTooltip => 'Trocar idioma';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSaveFailed =>
      'Não foi possível salvar o idioma selecionado.';

  @override
  String get back => 'Voltar';

  @override
  String get toggleTheme => 'Alternar tema';

  @override
  String get homeWelcome => 'Bem-vindo à Grand Line';

  @override
  String get homeSubtitle => 'Personagens, frutas, bandos, ilhas e muito mais.';

  @override
  String get categoryCount => '16 categorias';

  @override
  String get homeSectionHint => 'Explore o universo';

  @override
  String get categories => 'Categorias';

  @override
  String get apiDisclaimer =>
      'Dados da One Piece API (api-onepiece.com), uma API não oficial. One Piece © Eiichiro Oda.';

  @override
  String get search => 'Buscar';

  @override
  String itemCount(String count) {
    return '$count itens';
  }

  @override
  String get emptyCategory => 'Nenhum item encontrado.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get detailCategory => 'Categoria';

  @override
  String get detailId => 'ID';

  @override
  String get homeTab => 'Início';

  @override
  String get searchTab => 'Buscar';

  @override
  String searchHint(Object category) {
    return 'Buscar em $category…';
  }

  @override
  String get results => 'Resultados';

  @override
  String searchPrompt(Object category) {
    return 'Digite um nome para buscar em $category.';
  }

  @override
  String noSearchResults(Object query) {
    return 'Nenhum resultado para \"$query\".';
  }

  @override
  String get loading => 'Carregando';

  @override
  String get apiNotFound => 'Não encontrado (404).';

  @override
  String apiStatusError(String status) {
    return 'A API respondeu com erro $status.';
  }

  @override
  String get apiTimeout => 'A API demorou demais para responder.';

  @override
  String get apiOffline => 'Sem conexão com a internet ou API indisponível.';

  @override
  String get apiUnexpected => 'Resposta inesperada da API.';

  @override
  String get apiItemNotFound => 'Item não encontrado.';

  @override
  String get apiEndpointNotFound =>
      'Esta categoria está indisponível no momento.';

  @override
  String get categorySagas => 'Sagas';

  @override
  String get categoryFruits => 'Akuma no Mi';

  @override
  String get categoryChapters => 'Capítulos';

  @override
  String get categoryTomes => 'Volumes';

  @override
  String get categoryEpisodes => 'Episódios';

  @override
  String get categoryDials => 'Dials';

  @override
  String get categoryMovies => 'Filmes';

  @override
  String get categorySwords => 'Espadas';

  @override
  String get categoryHakis => 'Hakis';

  @override
  String get categoryLuffyGears => 'Gears do Luffy';

  @override
  String get categoryLuffyTechniques => 'Técnicas do Luffy';

  @override
  String get categoryCrews => 'Bandos';

  @override
  String get categoryCharacters => 'Personagens';

  @override
  String get categoryBoats => 'Barcos';

  @override
  String get categoryArcs => 'Arcos';

  @override
  String get categoryLocates => 'Locais';
}
