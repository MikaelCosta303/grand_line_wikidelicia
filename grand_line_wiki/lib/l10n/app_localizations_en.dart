// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Grand Line Wiki';

  @override
  String get languageTooltip => 'Change language';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSaveFailed => 'Could not save the language preference.';

  @override
  String get back => 'Back';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get homeWelcome => 'Welcome to the Grand Line';

  @override
  String get homeSubtitle =>
      'Characters, fruits, crews, islands, and much more.';

  @override
  String get categoryCount => '16 categories';

  @override
  String get homeSectionHint => 'Explore the world';

  @override
  String get categories => 'Categories';

  @override
  String get apiDisclaimer =>
      'Data from the One Piece API (api-onepiece.com), an unofficial API. One Piece © Eiichiro Oda.';

  @override
  String get search => 'Search';

  @override
  String itemCount(String count) {
    return '$count items';
  }

  @override
  String get emptyCategory => 'No items found.';

  @override
  String get retry => 'Try again';

  @override
  String get detailCategory => 'Category';

  @override
  String get detailId => 'ID';

  @override
  String get homeTab => 'Home';

  @override
  String get searchTab => 'Search';

  @override
  String searchHint(Object category) {
    return 'Search in $category…';
  }

  @override
  String get results => 'Results';

  @override
  String searchPrompt(Object category) {
    return 'Enter a name to search in $category.';
  }

  @override
  String noSearchResults(Object query) {
    return 'No results for \"$query\".';
  }

  @override
  String get loading => 'Loading';

  @override
  String get apiNotFound => 'Not found (404).';

  @override
  String apiStatusError(String status) {
    return 'The API returned error $status.';
  }

  @override
  String get apiTimeout => 'The API took too long to respond.';

  @override
  String get apiOffline => 'No internet connection or the API is unavailable.';

  @override
  String get apiUnexpected => 'Unexpected response from the API.';

  @override
  String get apiItemNotFound => 'Item not found.';

  @override
  String get apiEndpointNotFound => 'This category is currently unavailable.';

  @override
  String get categorySagas => 'Sagas';

  @override
  String get categoryFruits => 'Devil Fruits';

  @override
  String get categoryChapters => 'Chapters';

  @override
  String get categoryTomes => 'Volumes';

  @override
  String get categoryEpisodes => 'Episodes';

  @override
  String get categoryDials => 'Dials';

  @override
  String get categoryMovies => 'Movies';

  @override
  String get categorySwords => 'Swords';

  @override
  String get categoryHakis => 'Haki';

  @override
  String get categoryLuffyGears => 'Luffy\'s Gears';

  @override
  String get categoryLuffyTechniques => 'Luffy\'s Techniques';

  @override
  String get categoryCrews => 'Crews';

  @override
  String get categoryCharacters => 'Characters';

  @override
  String get categoryBoats => 'Ships';

  @override
  String get categoryArcs => 'Arcs';

  @override
  String get categoryLocates => 'Locations';
}
