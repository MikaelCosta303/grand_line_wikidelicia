import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../language_controller.dart';
import '../models/wiki_item.dart';
import 'categories.dart';

enum ApiErrorType {
  notFound,
  status,
  timeout,
  offline,
  unexpected,
  itemNotFound,
  endpointNotFound,
}

class ApiException implements Exception {
  const ApiException(this.type, {this.statusCode, this.path});

  final ApiErrorType type;
  final int? statusCode;
  final String? path;

  @override
  String toString() => type.name;
}

/// Cliente da One Piece API. Os quatro endpoints consultados por categoria:
///
/// - listar:   GET /v2/{recurso}/{idioma}
/// - por ID:   GET /v2/{recurso}/{idioma}/{id}
/// - buscar:   GET /v2/{recurso}/{idioma}/search?name=
/// - contagem: GET /v2/{recurso}/{idioma}/count
class OnePieceApi {
  OnePieceApi({http.Client? client}) : _client = client ?? http.Client();

  static const host = 'api.api-onepiece.com';
  static const basePath = '/v2';

  final http.Client _client;
  final Map<String, List<WikiItem>> _cache = {};

  String get languageCode => languageController.apiLanguageCode;

  Uri _uri(
    Category c, {
    required String languageCode,
    String tail = '',
    Map<String, String>? query,
  }) => Uri.https(host, '$basePath/${c.slug}/$languageCode$tail', query);

  Future<dynamic> _get(Uri uri) async {
    try {
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 404) {
        throw const ApiException(
          ApiErrorType.notFound,
          statusCode: 404,
        );
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(
          ApiErrorType.status,
          statusCode: res.statusCode,
        );
      }
      final body = utf8.decode(res.bodyBytes);
      return body.isEmpty ? null : jsonDecode(body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(ApiErrorType.timeout);
    } on http.ClientException {
      throw const ApiException(ApiErrorType.offline);
    } on FormatException {
      throw const ApiException(ApiErrorType.unexpected);
    }
  }

  Future<List<WikiItem>> list(Category c, {bool refresh = false}) async {
    final lang = languageCode;
    final cacheKey = '$lang:${c.slug}';
    if (!refresh && _cache.containsKey(cacheKey)) return _cache[cacheKey]!;
    try {
      final items = _asItems(await _get(_uri(c, languageCode: lang)));
      _cache[cacheKey] = items;
      return items;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw ApiException(
          ApiErrorType.endpointNotFound,
          statusCode: 404,
          path: c.listPathFor(lang),
        );
      }
      rethrow;
    }
  }

  Future<WikiItem> byId(Category c, String id) async {
    final data = await _get(
      _uri(
        c,
        languageCode: languageCode,
        tail: '/${Uri.encodeComponent(id)}',
      ),
    );
    final items = _asItems(data);
    if (items.isEmpty) {
      throw const ApiException(ApiErrorType.itemNotFound);
    }
    return items.first;
  }

  Future<List<WikiItem>> search(Category c, String name) async {
    try {
      final data = await _get(
        _uri(
          c,
          languageCode: languageCode,
          tail: '/search',
          query: {'name': name},
        ),
      );
      return _asItems(data);
    } on ApiException catch (e) {
      // Sem resultados costuma voltar como 404.
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<int> count(Category c) async {
    final n = _toInt(
      await _get(
        _uri(c, languageCode: languageCode, tail: '/count'),
      ),
    );
    if (n == null) {
      throw const ApiException(ApiErrorType.unexpected);
    }
    return n;
  }

  static List<WikiItem> _asItems(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.map(WikiItem.fromJson).toList();
    if (data is Map) {
      for (final key in const ['results', 'items', 'data', 'entries', 'records']) {
        if (data.containsKey(key)) {
          final nested = _asItems(data[key]);
          if (nested.isNotEmpty || data[key] is List || data[key] is Map) {
            return nested;
          }
        }
      }
      for (final value in data.values) {
        if (value is List) return value.map(WikiItem.fromJson).toList();
      }
      return [WikiItem.fromJson(data)];
    }
    return [];
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    if (value is List) {
      for (final item in value) {
        final n = _toInt(item);
        if (n != null) return n;
      }
    }
    if (value is Map) {
      for (final v in value.values) {
        final n = _toInt(v);
        if (n != null) return n;
      }
    }
    return null;
  }
}

final api = OnePieceApi();
