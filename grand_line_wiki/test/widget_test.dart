import 'package:flutter_test/flutter_test.dart';
import 'package:grand_line_wiki/data/categories.dart';
import 'package:grand_line_wiki/models/wiki_item.dart';

void main() {
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

  test('As 16 categorias montam os quatro endpoints', () {
    expect(categories.length, 16);
    final fruits = categories.firstWhere((c) => c.slug == 'fruits');
    expect(fruits.listPath, '/fruits/en');
    expect(fruits.idPath, '/fruits/en/{id}');
    expect(fruits.searchPath, '/fruits/en/search?name=');
    expect(fruits.countPath, '/fruits/en/count');
  });
}
