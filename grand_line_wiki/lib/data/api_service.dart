import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/wiki_item.dart';
import 'categories.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Cliente da One Piece API. Os quatro endpoints consultados por categoria:
///
/// - listar:   GET /v2/{recurso}/en
/// - por ID:   GET /v2/{recurso}/en/{id}
/// - buscar:   GET /v2/{recurso}/en/search?name=
/// - contagem: GET /v2/{recurso}/en/count
class OnePieceApi {
  OnePieceApi({http.Client? client}) : _client = client ?? http.Client();

  static const host = 'api.api-onepiece.com';
  static const basePath = '/v2';

  final http.Client _client;
  final Map<String, List<WikiItem>> _cache = {};

  Uri _uri(Category c, {String tail = '', Map<String, String>? query}) =>
      Uri.https(host, '$basePath/${c.slug}/en$tail', query);

  Future<dynamic> _get(Uri uri) async {
    try {
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 404) {
        throw ApiException('Não encontrado (404).', statusCode: 404);
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(
          'A API respondeu com erro ${res.statusCode}.',
          statusCode: res.statusCode,
        );
      }
      final body = utf8.decode(res.bodyBytes);
      return body.isEmpty ? null : jsonDecode(body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('A API demorou demais para responder.');
    } on http.ClientException {
      throw ApiException('Sem conexão com a internet ou API indisponível.');
    } on FormatException {
      throw ApiException('Resposta inesperada da API.');
    }
  }

  Future<List<WikiItem>> list(Category c, {bool refresh = false}) async {
    if (!refresh && _cache.containsKey(c.slug)) return _cache[c.slug]!;
    try {
      final items = _asItems(await _get(_uri(c)));
      _cache[c.slug] = items;
      return items;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw ApiException(
          'O endpoint ${c.listPath} não foi encontrado. '
          'Confira o nome do recurso na documentação da API.',
          statusCode: 404,
        );
      }
      rethrow;
    }
  }

  Future<WikiItem> byId(Category c, String id) async {
    final data = await _get(_uri(c, tail: '/${Uri.encodeComponent(id)}'));
    final items = _asItems(data);
    if (items.isEmpty) throw ApiException('Item não encontrado.');
    return items.first;
  }

  Future<List<WikiItem>> search(Category c, String name) async {
    try {
      final data = await _get(_uri(c, tail: '/search', query: {'name': name}));
      return _asItems(data);
    } on ApiException catch (e) {
      // Sem resultados costuma voltar como 404.
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<int> count(Category c) async {
    final n = _toInt(await _get(_uri(c, tail: '/count')));
    if (n == null) throw ApiException('Resposta inesperada da API.');
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
