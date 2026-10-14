// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Grand Line Wiki';

  @override
  String get languageTooltip => 'Changer de langue';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSaveFailed =>
      'Impossible d’enregistrer la langue sélectionnée.';

  @override
  String get back => 'Retour';

  @override
  String get toggleTheme => 'Changer de thème';

  @override
  String get homeWelcome => 'Bienvenue sur Grand Line';

  @override
  String get homeSubtitle =>
      'Personnages, fruits, équipages, îles et bien plus.';

  @override
  String get categoryCount => '16 catégories';

  @override
  String get homeSectionHint => 'Explorez le monde';

  @override
  String get categories => 'Catégories';

  @override
  String get apiDisclaimer =>
      'Données de la One Piece API (api-onepiece.com), une API non officielle. One Piece © Eiichiro Oda.';

  @override
  String get search => 'Rechercher';

  @override
  String itemCount(String count) {
    return '$count éléments';
  }

  @override
  String get emptyCategory => 'Aucun élément trouvé.';

  @override
  String get retry => 'Réessayer';

  @override
  String get detailCategory => 'Catégorie';

  @override
  String get detailId => 'ID';

  @override
  String get homeTab => 'Accueil';

  @override
  String get searchTab => 'Rechercher';

  @override
  String searchHint(Object category) {
    return 'Rechercher dans $category…';
  }

  @override
  String get results => 'Résultats';

  @override
  String searchPrompt(Object category) {
    return 'Saisissez un nom à rechercher dans $category.';
  }

  @override
  String noSearchResults(Object query) {
    return 'Aucun résultat pour « $query ».';
  }

  @override
  String get loading => 'Chargement';

  @override
  String get apiNotFound => 'Introuvable (404).';

  @override
  String apiStatusError(String status) {
    return 'L’API a renvoyé l’erreur $status.';
  }

  @override
  String get apiTimeout => 'L’API a mis trop de temps à répondre.';

  @override
  String get apiOffline => 'Pas de connexion Internet ou API indisponible.';

  @override
  String get apiUnexpected => 'Réponse inattendue de l’API.';

  @override
  String get apiItemNotFound => 'Élément introuvable.';

  @override
  String get apiEndpointNotFound =>
      'Cette catégorie est actuellement indisponible.';

  @override
  String get categorySagas => 'Sagas';

  @override
  String get categoryFruits => 'Fruits du Démon';

  @override
  String get categoryChapters => 'Chapitres';

  @override
  String get categoryTomes => 'Tomes';

  @override
  String get categoryEpisodes => 'Épisodes';

  @override
  String get categoryDials => 'Dials';

  @override
  String get categoryMovies => 'Films';

  @override
  String get categorySwords => 'Épées';

  @override
  String get categoryHakis => 'Haki';

  @override
  String get categoryLuffyGears => 'Gears de Luffy';

  @override
  String get categoryLuffyTechniques => 'Techniques de Luffy';

  @override
  String get categoryCrews => 'Équipages';

  @override
  String get categoryCharacters => 'Personnages';

  @override
  String get categoryBoats => 'Navires';

  @override
  String get categoryArcs => 'Arcs';

  @override
  String get categoryLocates => 'Lieux';
}
