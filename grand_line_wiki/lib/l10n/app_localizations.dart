import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
    Locale('pt', 'BR')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Grand Line Wiki'**
  String get appTitle;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageTooltip;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the language preference.'**
  String get languageSaveFailed;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Grand Line'**
  String get homeWelcome;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Characters, fruits, crews, islands, and much more.'**
  String get homeSubtitle;

  /// No description provided for @categoryCount.
  ///
  /// In en, this message translates to:
  /// **'16 categories'**
  String get categoryCount;

  /// No description provided for @homeSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Explore the world'**
  String get homeSectionHint;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @apiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Data from the One Piece API (api-onepiece.com), an unofficial API. One Piece © Eiichiro Oda.'**
  String get apiDisclaimer;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(String count);

  /// No description provided for @emptyCategory.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get emptyCategory;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @detailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detailCategory;

  /// No description provided for @detailId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get detailId;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @searchTab.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTab;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search in {category}…'**
  String searchHint(Object category);

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a name to search in {category}.'**
  String searchPrompt(Object category);

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\".'**
  String noSearchResults(Object query);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @apiNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found (404).'**
  String get apiNotFound;

  /// No description provided for @apiStatusError.
  ///
  /// In en, this message translates to:
  /// **'The API returned error {status}.'**
  String apiStatusError(String status);

  /// No description provided for @apiTimeout.
  ///
  /// In en, this message translates to:
  /// **'The API took too long to respond.'**
  String get apiTimeout;

  /// No description provided for @apiOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection or the API is unavailable.'**
  String get apiOffline;

  /// No description provided for @apiUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from the API.'**
  String get apiUnexpected;

  /// No description provided for @apiItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found.'**
  String get apiItemNotFound;

  /// No description provided for @apiEndpointNotFound.
  ///
  /// In en, this message translates to:
  /// **'This category is currently unavailable.'**
  String get apiEndpointNotFound;

  /// No description provided for @categorySagas.
  ///
  /// In en, this message translates to:
  /// **'Sagas'**
  String get categorySagas;

  /// No description provided for @categoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Devil Fruits'**
  String get categoryFruits;

  /// No description provided for @categoryChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get categoryChapters;

  /// No description provided for @categoryTomes.
  ///
  /// In en, this message translates to:
  /// **'Volumes'**
  String get categoryTomes;

  /// No description provided for @categoryEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get categoryEpisodes;

  /// No description provided for @categoryDials.
  ///
  /// In en, this message translates to:
  /// **'Dials'**
  String get categoryDials;

  /// No description provided for @categoryMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get categoryMovies;

  /// No description provided for @categorySwords.
  ///
  /// In en, this message translates to:
  /// **'Swords'**
  String get categorySwords;

  /// No description provided for @categoryHakis.
  ///
  /// In en, this message translates to:
  /// **'Haki'**
  String get categoryHakis;

  /// No description provided for @categoryLuffyGears.
  ///
  /// In en, this message translates to:
  /// **'Luffy\'s Gears'**
  String get categoryLuffyGears;

  /// No description provided for @categoryLuffyTechniques.
  ///
  /// In en, this message translates to:
  /// **'Luffy\'s Techniques'**
  String get categoryLuffyTechniques;

  /// No description provided for @categoryCrews.
  ///
  /// In en, this message translates to:
  /// **'Crews'**
  String get categoryCrews;

  /// No description provided for @categoryCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get categoryCharacters;

  /// No description provided for @categoryBoats.
  ///
  /// In en, this message translates to:
  /// **'Ships'**
  String get categoryBoats;

  /// No description provided for @categoryArcs.
  ///
  /// In en, this message translates to:
  /// **'Arcs'**
  String get categoryArcs;

  /// No description provided for @categoryLocates.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get categoryLocates;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
