import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_line_wiki/language_controller.dart';
import 'package:grand_line_wiki/data/api_service.dart';
import 'package:grand_line_wiki/data/categories.dart';
import 'package:grand_line_wiki/l10n/app_localizations.dart';
import 'package:grand_line_wiki/models/wiki_item.dart';
import 'package:grand_line_wiki/screens/detail_sheet.dart';
import 'package:grand_line_wiki/screens/home_screen.dart';
import 'package:grand_line_wiki/screens/home_shell.dart';
import 'package:grand_line_wiki/screens/splash_screen.dart';
import 'package:http/http.dart' show Response;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _localizedApp(Widget home) => ListenableBuilder(
      listenable: languageController,
      builder: (context, child) => MaterialApp(
        locale: languageController.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    );

void main() {
  testWidgets('Splash screen opens the home screen automatically', (
    tester,
  ) async {
    await languageController.setLocale(const Locale('pt', 'BR'));
    await tester.pumpWidget(_localizedApp(const SplashScreen()));

    expect(find.text('GRAND LINE'), findsOneWidget);
    expect(find.text('ONE PIECE WIKI'), findsOneWidget);
    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('Language menu switches the interface to English', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await languageController.setLocale(const Locale('pt', 'BR'));
    await tester.pumpWidget(_localizedApp(const HomeShell()));

    await tester.tap(find.byTooltip('Trocar idioma'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Português (Brasil)'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await languageController.setLocale(const Locale('en'));
    await tester.pump();
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);

    final restoredController = LanguageController();
    await restoredController.load();
    expect(restoredController.locale, const Locale('en'));
    expect(languageController.apiLanguageCode, 'en');

    await languageController.setLocale(const Locale('fr'));
    await tester.pump();
    expect(find.text('Catégories'), findsOneWidget);
    expect(languageController.apiLanguageCode, 'fr');

    await languageController.setLocale(const Locale('pt', 'BR'));
    await tester.pump();
    expect(find.text('Categorias'), findsOneWidget);
    expect(languageController.apiLanguageCode, 'en');
  });

  test('WikiItem lê nome, subtítulo, etiqueta, id e imagem', () {
    final item = WikiItem.fromJson({
      'id': 1,
      'name': 'Monkey D. Luffy',
      'job': 'Capitão',
      'bounty': '3 000 000 000',
      'image': 'https://example.com/luffy.png',
    });

    expect(item.title, 'Monkey D. Luffy');
    expect(item.subtitle, 'Capitão');
    expect(item.tag, '3 000 000 000');
    expect(item.id, '1');
    expect(item.imageUrl, 'https://example.com/luffy.png');
  });

  test('WikiItem usa texto de reserva quando não há nome', () {
    final item = WikiItem.fromJson({'id': 7});
    expect(item.title, 'Sem nome');
    expect(item.imageUrl, isNull);
  });

  test('WikiItem lê nomes aninhados em mapas e listas', () {
    final item = WikiItem.fromJson({
      'id': 9,
      'name': {'english': 'Monkey D. Luffy'},
      'aliases': ['Straw Hat', 'Captain'],
      'job': ['Pirate', 'Captain'],
    });

    expect(item.title, 'Monkey D. Luffy');
    expect(item.subtitle, 'Pirate, Captain');
  });

  test('WikiItem mantém o nome próprio original sem nome localizado', () {
    final item = WikiItem.fromJson({
      'french_name': 'Fruit Gum-Gum',
      'description': 'A fruit with special powers.',
    });

    expect(item.title, 'Sem nome');
    expect(item.subtitle, 'A fruit with special powers.');
    expect(item.fields.map((field) => field.key), ['Description']);
  });

  testWidgets('Detalhe não exibe rotas ou endpoints da API', (tester) async {
    await languageController.setLocale(const Locale('pt', 'BR'));
    await tester.pumpWidget(
      _localizedApp(
        DetailSheet(
          category: categories.firstWhere((c) => c.slug == 'fruits'),
          item: WikiItem.fromJson({
            'name': 'Gomu Gomu no Mi',
            'description': 'Uma fruta que concede poderes.',
          }),
          index: 0,
        ),
      ),
    );

    expect(find.text('Gomu Gomu no Mi'), findsOneWidget);
    expect(find.text('Uma fruta que concede poderes.'), findsOneWidget);
    expect(find.textContaining('GET '), findsNothing);
    expect(find.textContaining('/v2/'), findsNothing);
    expect(find.textContaining('api.api-onepiece.com'), findsNothing);
  });

  testWidgets('Início não exibe rotas da API nos cards de categoria', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(const Scaffold(body: HomeScreen())),
    );

    expect(find.text('/fruits/en'), findsNothing);
    expect(find.textContaining('/v2/'), findsNothing);
  });

  test('WikiItem lê a URL de imagem da fruta no campo filename', () {
    final item = WikiItem.fromJson({
      'id': 1,
      'name': 'Gum-Gum Fruit',
      'filename': 'https://images.api-onepiece.com/fruits/gomu.png',
    });

    expect(
      item.imageUrl,
      'https://images.api-onepiece.com/fruits/gomu.png',
    );
  });

  test('As 16 categorias montam os quatro endpoints', () {
    expect(categories.length, 16);
    final fruits = categories.firstWhere((c) => c.slug == 'fruits');
    expect(fruits.listPath, '/fruits/en');
    expect(fruits.idPath, '/fruits/en/{id}');
    expect(fruits.searchPath, '/fruits/en/search?name=');
    expect(fruits.countPath, '/fruits/en/count');
    expect(fruits.listPathFor('fr'), '/fruits/fr');
    expect(fruits.searchPathFor('fr'), '/fruits/fr/search?name=');
  });

  test('API separa cache e rotas entre inglês e francês', () async {
    SharedPreferences.setMockInitialValues({});
    await languageController.setLocale(const Locale('pt', 'BR'));
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.path);
      final description = request.url.path.endsWith('/fr')
          ? 'Un fruit aux pouvoirs spéciaux.'
          : 'A fruit with special powers.';
      return Response.bytes(
        utf8.encode(
          '[{"id":1,"name":"Gomu Gomu no Mi","description":"$description"}]',
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final testApi = OnePieceApi(client: client);
    final fruits = categories.firstWhere(
      (category) => category.slug == 'fruits',
    );

    final englishItems = await testApi.list(fruits);
    await languageController.setLocale(const Locale('fr'));
    final frenchItems = await testApi.list(fruits);
    await languageController.setLocale(const Locale('pt', 'BR'));
    final portugueseUiItems = await testApi.list(fruits);

    expect(paths, ['/v2/fruits/en', '/v2/fruits/fr']);
    expect(englishItems.single.title, 'Gomu Gomu no Mi');
    expect(frenchItems.single.title, 'Gomu Gomu no Mi');
    expect(portugueseUiItems.single.title, 'Gomu Gomu no Mi');
    expect(englishItems.single.subtitle, 'A fruit with special powers.');
    expect(
      frenchItems.single.subtitle,
      'Un fruit aux pouvoirs spéciaux.',
    );
    expect(
      englishItems.single.fields
          .firstWhere((field) => field.key == 'Description')
          .value,
      'A fruit with special powers.',
    );
    expect(
      frenchItems.single.fields
          .firstWhere((field) => field.key == 'Description')
          .value,
      'Un fruit aux pouvoirs spéciaux.',
    );
    expect(
      portugueseUiItems.single.fields
          .firstWhere((field) => field.key == 'Description')
          .value,
      'A fruit with special powers.',
    );
  });
}
