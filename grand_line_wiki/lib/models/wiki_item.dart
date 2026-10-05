/// Item genérico devolvido pela API.
///
/// Como cada recurso da One Piece API tem campos diferentes, o app não
/// depende de um formato fixo: procura nome, subtítulo, etiqueta e imagem
/// em chaves comuns e mostra todos os campos simples no detalhe.
class WikiItem {
  WikiItem(this.raw);

  factory WikiItem.fromJson(dynamic json) {
    if (json is Map) {
      return WikiItem(Map<String, dynamic>.from(json));
    }
    return WikiItem({'name': '$json'});
  }

  final Map<String, dynamic> raw;

  static const _titleKeys = [
    'name',
    'roman_name',
    'title',
    'label',
    'japanese_name',
    'french_name',
  ];
  static const _subtitleKeys = [
    'job',
    'type',
    'description',
    'roman_name',
    'crew',
    'origin',
    'status',
  ];
  static const _tagKeys = ['bounty', 'type', 'status', 'saga', 'size', 'number'];
  static const _imageKeys = [
    'image',
    'img',
    'picture',
    'thumbnail',
    'image_url',
    'url_image',
  ];

  String? get id => _text(raw['id']);

  String get title => _first(_titleKeys) ?? 'Sem nome';

  String? get subtitle => _first(_subtitleKeys, exclude: {title});

  String? get tag => _first(_tagKeys, exclude: {title, subtitle ?? ''});

  /// Endereço da imagem, se a resposta da API trouxer um.
  String? get imageUrl {
    for (final key in _imageKeys) {
      final value = raw[key];
      final candidate = value is Map ? value['url'] : value;
      if (candidate is String && candidate.startsWith('http')) {
        return candidate;
      }
    }
    return null;
  }

  /// Todos os campos simples da resposta, com o nome da chave legível.
  List<MapEntry<String, String>> get fields {
    final out = <MapEntry<String, String>>[];
    raw.forEach((key, value) {
      if (key == 'id' || _imageKeys.contains(key)) return;
      final text = _text(value);
      if (text == null) return;
      out.add(MapEntry(_humanize(key), text));
    });
    return out;
  }

  String? _first(List<String> keys, {Set<String> exclude = const {}}) {
    for (final key in keys) {
      final value = _text(raw[key]);
      if (value != null && value.isNotEmpty && !exclude.contains(value)) {
        return value;
      }
    }
    return null;
  }

  static String? _text(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) return '$value';
    if (value is List) {
      final parts = <String>[];
      for (final item in value) {
        final text = _text(item);
        if (text == null || text.isEmpty) continue;
        parts.add(text);
        if (parts.length >= 5) break;
      }
      return parts.isEmpty ? null : parts.join(', ');
    }
    if (value is Map) {
      for (final key in const ['name', 'title', 'label', 'text', 'value']) {
        final nested = _text(value[key]);
        if (nested != null) return nested;
      }
      for (final entry in value.entries) {
        if (entry.key == 'id' || entry.key == 'url' || entry.key == 'image') {
          continue;
        }
        final nested = _text(entry.value);
        if (nested != null) return nested;
      }
      return null;
    }
    return null;
  }

  static String _humanize(String key) {
    final spaced = key.replaceAll('_', ' ').trim();
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}
