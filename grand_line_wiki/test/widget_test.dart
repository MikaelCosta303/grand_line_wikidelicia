import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grand_line_wiki/language_controller.dart';
import 'package:grand_line_wiki/data/api_service.dart';
import 'package:grand_line_wiki/data/commons_image_service.dart';
import 'package:grand_line_wiki/data/categories.dart';
import 'package:grand_line_wiki/l10n/app_localizations.dart';
import 'package:grand_line_wiki/models/wiki_item.dart';
import 'package:grand_line_wiki/screens/detail_sheet.dart';
import 'package:grand_line_wiki/screens/home_screen.dart';
import 'package:grand_line_wiki/screens/home_shell.dart';
import 'package:grand_line_wiki/screens/splash_screen.dart';
import 'package:grand_line_wiki/services/description_translation_service.dart';
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
            'description': 'A fruit that grants powers.',
            'origin': 'Foosha Village',
            'job': 'A pirate captain who protects his crew.',
            'type': 'Paramecia',
          }),
          index: 0,
          imageLoader: (category, item) async => null,
          descriptionTranslator: (text) async => text == 'Description'
              ? 'Descrição'
              : switch (text) {
                  'A fruit that grants powers.' =>
                    'Uma fruta que concede poderes.',
                  'Job' => 'Profissão',
                  'A pirate captain who protects his crew.' =>
                    'Um capitão pirata que protege sua tripulação.',
                  _ => text,
                },
        ),
      ),
    );

    expect(find.text('Gomu Gomu no Mi'), findsOneWidget);
    await tester.pump();
    expect(find.text('Uma fruta que concede poderes.'), findsOneWidget);
    expect(
      find.text('Um capitão pirata que protege sua tripulação.'),
      findsOneWidget,
    );
    expect(find.text('Foosha Village'), findsOneWidget);
    expect(find.text('Paramecia'), findsOneWidget);
    expect(find.textContaining('GET '), findsNothing);
    expect(find.textContaining('/v2/'), findsNothing);
    expect(find.textContaining('api.api-onepiece.com'), findsNothing);
  });

  testWidgets('Rótulos do detalhe acompanham o idioma selecionado', (
    tester,
  ) async {
    await languageController.setLocale(const Locale('fr'));
    await tester.pumpWidget(
      _localizedApp(
        DetailSheet(
          category: categories.firstWhere((c) => c.slug == 'fruits'),
          item: WikiItem.fromJson({
            'name': 'Gomu Gomu no Mi',
            'description': 'Un fruit aux pouvoirs spéciaux.',
          }),
          index: 0,
          imageLoader: (category, item) async => null,
          descriptionTranslator: (text) async =>
              text == 'Description' ? 'Description traduite' : text,
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Description traduite'), findsOneWidget);
    expect(find.text('Un fruit aux pouvoirs spéciaux.'), findsOneWidget);
    await languageController.setLocale(const Locale('pt', 'BR'));
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

  test('Tradução de descrição em cache não modifica nome ou nomenclatura',
      () async {
    var translations = 0;
    final translator = DescriptionTranslationService(
      translate: (text) async {
        translations++;
        return 'Descrição traduzida';
      },
    );
    final item = WikiItem.fromJson({
      'name': 'Gomu Gomu no Mi',
      'type': 'Paramecia',
      'description': 'A fruit that grants powers.',
    });

    final translated = await translator.translate(item.description!);
    final reused = await translator.translate(item.description!);

    expect(translated, 'Descrição traduzida');
    expect(reused, translated);
    expect(translations, 1);
    expect(item.title, 'Gomu Gomu no Mi');
    expect(item.tag, 'Paramecia');
  });

  test('Tradução identifica idioma de cada campo de personagem', () async {
    final sourceLanguages = <String>[];
    final translator = DescriptionTranslationService(
      identifyLanguage: (text) async {
        final language = switch (text) {
          '19 ans' || 'vivant' => 'fr',
          _ => 'en',
        };
        sourceLanguages.add(language);
        return language;
      },
      translate: (text) async => 'pt: $text',
    );

    final age = await translator.translate(
      '19 ans',
      sourceLanguageCode: 'en',
      targetLanguageCode: 'pt',
    );
    final status = await translator.translate(
      'vivant',
      sourceLanguageCode: 'en',
      targetLanguageCode: 'pt',
    );
    final job = await translator.translate(
      'Captain',
      sourceLanguageCode: 'en',
      targetLanguageCode: 'pt',
    );

    expect(age, 'pt: 19 ans');
    expect(status, 'pt: vivant');
    expect(job, 'pt: Captain');
    expect(sourceLanguages, ['fr', 'fr', 'en']);
  });

  test('Campos traduzíveis em personagens mantêm nomes e nomenclaturas', () {
    expect(WikiItem.isTranslatableField('age', '19 ans'), isTrue);
    expect(WikiItem.isTranslatableField('status', 'vivant'), isTrue);
    expect(
      WikiItem.isTranslatableField('job', 'Captain of the Straw Hat Pirates'),
      isTrue,
    );
    expect(WikiItem.isTranslatableField('name', 'Monkey D. Luffy'), isFalse);
    expect(WikiItem.isTranslatableField('crew', 'Straw Hat Pirates'), isFalse);
    expect(WikiItem.isTranslatableField('fruit', 'Gomu Gomu no Mi'), isFalse);
  });

  test('Tradução preserva nome canônico e siglas dentro do texto', () async {
    final translator = DescriptionTranslationService(
      translate: (text) async => '[$text]',
    );

    final result = await translator.translate(
      'The CP9 mission follows Monkey D. Luffy.',
      sourceLanguageCode: 'en',
      targetLanguageCode: 'pt',
      protectedTerms: const ['Monkey D. Luffy'],
    );

    expect(
      result,
      '[The] CP9[ mission follows] Monkey D. Luffy[.]',
    );
  });

  test('Imagem licenciada do Commons fica salva em cache persistente',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('grand-line-images-');
    addTearDown(() => directory.delete(recursive: true));
    final requests = <String>[];
    final client = MockClient((request) async {
      requests.add(request.url.host);
      if (request.url.host == 'onepiece.fandom.com') {
        return Response(
          jsonEncode({
            'query': {
              'pages': [
                {
                  'pageid': -1,
                  'ns': 0,
                  'title': 'Gomu Gomu no Mi',
                  'missing': true,
                },
              ],
            },
          }),
          200,
        );
      }
      if (request.url.host == 'commons.wikimedia.org') {
        return Response(
          jsonEncode({
            'query': {
              'pages': {
                '1': {
                  'index': 1,
                  'title': 'File:Gomu Gomu no Mi illustration.jpg',
                  'categories': [
                    {'title': 'Category:One Piece devil fruits'},
                  ],
                  'imageinfo': [
                    {
                      'thumburl': 'https://upload.wikimedia.org/test.png',
                      'descriptionurl':
                          'https://commons.wikimedia.org/wiki/File:Gomu_Gomu_no_Mi',
                      'extmetadata': {
                        'ImageDescription': {'value': 'Gomu Gomu no Mi'},
                        'Artist': {'value': 'Test Artist'},
                        'LicenseShortName': {'value': 'CC BY-SA 4.0'},
                        'LicenseUrl': {
                          'value':
                              'https://creativecommons.org/licenses/by-sa/4.0',
                        },
                      },
                    },
                  ],
                },
              },
            },
          }),
          200,
        );
      }
      return Response.bytes(
        [137, 80, 78, 71, 13, 10, 26, 10, 0],
        200,
        headers: {'content-type': 'image/png'},
      );
    });
    final category = categories.firstWhere((c) => c.slug == 'fruits');
    final item = WikiItem.fromJson({
      'id': 42,
      'name': 'Gomu Gomu no Mi',
    });
    final imageService = CommonsImageService(
      client: client,
      directoryProvider: () async => directory,
    );

    final cached = await imageService.load(category, item);

    expect(cached, isNotNull);
    expect(await cached!.file.exists(), isTrue);
    expect(cached.attribution?.license, 'CC BY-SA 4.0');
    expect(cached.attribution?.author, 'Test Artist');

    final restartedService = CommonsImageService(
      client: MockClient((request) async {
        fail('Image and attribution should be available from disk.');
      }),
      directoryProvider: () async => directory,
    );
    final restored = await restartedService.load(category, item);

    expect(restored?.file.path, cached.file.path);
    expect(restored?.attribution?.license, 'CC BY-SA 4.0');
    expect(
      requests,
      [
        'onepiece.fandom.com',
        'commons.wikimedia.org',
        'upload.wikimedia.org',
      ],
    );
  });

  test('Commons rejeita nome coincidente sem contexto da categoria', () async {
    final directory = await Directory.systemTemp.createTemp(
      'grand-line-image-match-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final client = MockClient((request) async {
      if (request.url.host == 'onepiece.fandom.com') {
        return Response(
          jsonEncode({
            'query': {
              'pages': [
                {
                  'pageid': -1,
                  'ns': 0,
                  'title': 'Gomu Gomu no Mi',
                  'missing': true,
                },
              ],
            },
          }),
          200,
        );
      }
      expect(request.url.queryParameters['gsrsearch'],
          contains('"Gomu Gomu no Mi"'));
      return Response(
        jsonEncode({
          'query': {
            'pages': {
              '1': {
                'index': 1,
                'title': 'File:Gomu Gomu no Mi.jpg',
                'categories': [
                  {'title': 'Category:One Piece characters'},
                ],
                'imageinfo': [
                  {
                    'thumburl': 'https://upload.wikimedia.org/test.png',
                    'descriptionurl':
                        'https://commons.wikimedia.org/wiki/File:Gomu_Gomu_no_Mi',
                    'extmetadata': {
                      'ImageDescription': {
                        'value': 'A character holding a Gomu Gomu no Mi.',
                      },
                      'Artist': {'value': 'Test Artist'},
                      'LicenseShortName': {'value': 'CC BY-SA 4.0'},
                      'LicenseUrl': {
                        'value':
                            'https://creativecommons.org/licenses/by-sa/4.0',
                      },
                    },
                  },
                ],
              },
            },
          },
        }),
        200,
      );
    });
    final category = categories.firstWhere((c) => c.slug == 'fruits');
    final service = CommonsImageService(
      client: client,
      directoryProvider: () async => directory,
    );

    final image = await service.load(
      category,
      WikiItem.fromJson({'id': 314, 'name': 'Gomu Gomu no Mi'}),
    );

    expect(image, isNull);
  });

  test('Fandom usa a página exata e exige licença explícita', () async {
    final directory = await Directory.systemTemp.createTemp(
      'grand-line-fandom-image-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final requests = <String>[];
    final client = MockClient((request) async {
      requests.add(request.url.host);
      if (request.url.host == 'onepiece.fandom.com' &&
          request.url.queryParameters['prop'] == 'pageimages|info') {
        expect(request.url.queryParameters['titles'], 'Monkey D. Luffy');
        return Response(
          jsonEncode({
            'query': {
              'pages': [
                {
                  'pageid': 1444,
                  'title': 'Monkey D. Luffy',
                  'pageimage': 'Luffy licensed image.png',
                  'thumbnail': {
                    'source':
                        'https://static.wikia.nocookie.net/onepiece/images/luffy.png',
                  },
                },
              ],
            },
          }),
          200,
        );
      }
      if (request.url.host == 'onepiece.fandom.com') {
        return Response(
          jsonEncode({
            'query': {
              'pages': [
                {
                  'pageid': 123,
                  'title': 'File:Luffy licensed image.png',
                  'fullurl':
                      'https://onepiece.fandom.com/wiki/File:Luffy_licensed_image.png',
                  'imageinfo': [
                    {'user': 'Uploader'},
                  ],
                  'revisions': [
                    {
                      'slots': {
                        'main': {
                          'content':
                              '{{CC-BY-SA-4.0}}\\n|artist=Verified Artist',
                        },
                      },
                    },
                  ],
                },
              ],
            },
          }),
          200,
        );
      }
      return Response.bytes(
        [137, 80, 78, 71, 13, 10, 26, 10, 0],
        200,
        headers: {'content-type': 'image/png'},
      );
    });
    final category = categories.firstWhere((c) => c.slug == 'characters');
    final service = CommonsImageService(
      client: client,
      directoryProvider: () async => directory,
    );

    final image = await service.load(
      category,
      WikiItem.fromJson({'id': 1, 'name': 'Monkey D. Luffy'}),
    );

    expect(image, isNotNull);
    expect(image!.attribution?.sourceName, 'One Piece Wiki (Fandom)');
    expect(image.attribution?.author, 'Verified Artist');
    expect(image.attribution?.license, 'CC BY-SA 4.0');
    expect(
      requests,
      [
        'onepiece.fandom.com',
        'onepiece.fandom.com',
        'static.wikia.nocookie.net',
      ],
    );
  });

  test('Fandom rejeita imagens sem licença reutilizável', () async {
    final directory = await Directory.systemTemp.createTemp(
      'grand-line-fandom-license-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final client = MockClient((request) async {
      if (request.url.host == 'onepiece.fandom.com' &&
          request.url.queryParameters['prop'] == 'pageimages|info') {
        return Response(
          jsonEncode({
            'query': {
              'pages': [
                {
                  'pageid': 1444,
                  'title': 'Monkey D. Luffy',
                  'pageimage': 'Luffy anime screenshot.png',
                  'thumbnail': {
                    'source':
                        'https://static.wikia.nocookie.net/onepiece/images/luffy.png',
                  },
                },
              ],
            },
          }),
          200,
        );
      }
      if (request.url.host == 'onepiece.fandom.com') {
        return Response(
          jsonEncode({
            'query': {
              'pages': [
                {
                  'pageid': 123,
                  'title': 'File:Luffy anime screenshot.png',
                  'fullurl':
                      'https://onepiece.fandom.com/wiki/File:Luffy_anime_screenshot.png',
                  'imageinfo': [
                    {'user': 'Uploader'},
                  ],
                  'revisions': [
                    {
                      'slots': {
                        'main': {'content': '{{Screenshot}}'},
                      },
                    },
                  ],
                },
              ],
            },
          }),
          200,
        );
      }
      return Response(
        jsonEncode({
          'query': {'pages': <String, dynamic>{}},
        }),
        200,
      );
    });
    final category = categories.firstWhere((c) => c.slug == 'characters');
    final service = CommonsImageService(
      client: client,
      directoryProvider: () async => directory,
    );

    final image = await service.load(
      category,
      WikiItem.fromJson({'id': 2, 'name': 'Monkey D. Luffy'}),
    );

    expect(image, isNull);
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
