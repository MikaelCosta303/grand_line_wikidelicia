import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'categories.dart';
import '../models/wiki_item.dart';

@immutable
class ImageAttribution {
  const ImageAttribution({
    required this.sourceName,
    required this.fileTitle,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.filePageUrl,
  });

  final String sourceName;
  final String fileTitle;
  final String author;
  final String license;
  final String licenseUrl;
  final String filePageUrl;

  Map<String, String> toJson() => {
        'sourceName': sourceName,
        'fileTitle': fileTitle,
        'author': author,
        'license': license,
        'licenseUrl': licenseUrl,
        'filePageUrl': filePageUrl,
      };

  factory ImageAttribution.fromJson(Map<String, dynamic> json) =>
      ImageAttribution(
        sourceName: json['sourceName'] as String,
        fileTitle: json['fileTitle'] as String,
        author: json['author'] as String,
        license: json['license'] as String,
        licenseUrl: json['licenseUrl'] as String,
        filePageUrl: json['filePageUrl'] as String,
      );
}

@immutable
class CachedItemImage {
  const CachedItemImage({required this.file, this.attribution});

  final File file;
  final ImageAttribution? attribution;
}

class _FandomLicense {
  const _FandomLicense(this.name, this.url, {this.requiresAuthor = false});

  final String name;
  final String url;
  final bool requiresAuthor;
}

class CommonsImageService {
  CommonsImageService({
    http.Client? client,
    Future<Directory> Function()? directoryProvider,
  })  : _client = client ?? http.Client(),
        _directoryProvider =
            directoryProvider ?? getApplicationSupportDirectory;

  static const _maxImageBytes = 12 * 1024 * 1024;
  static const _allowedLicenses = {
    'CC0',
    'Public domain',
    'CC BY',
    'CC BY-SA',
  };

  final http.Client _client;
  final Future<Directory> Function() _directoryProvider;
  final Map<String, Future<CachedItemImage?>> _pending = {};

  Future<CachedItemImage?> load(Category category, WikiItem item) async {
    final key = _cacheKey(category, item);
    final pending = _pending.putIfAbsent(
      key,
      () => _load(key, category, item),
    );
    try {
      return await pending;
    } catch (_) {
      _pending.remove(key);
      rethrow;
    }
  }

  Future<CachedItemImage?> _load(
    String key,
    Category category,
    WikiItem item,
  ) async {
    final directory = Directory(
      '${(await _directoryProvider()).path}${Platform.pathSeparator}item_images',
    );
    await directory.create(recursive: true);
    final imageFile = File('${directory.path}${Platform.pathSeparator}$key');
    final metadataFile =
        File('${directory.path}${Platform.pathSeparator}$key.json');

    if (await imageFile.exists()) {
      final attribution = await _readAttribution(metadataFile);
      return CachedItemImage(file: imageFile, attribution: attribution);
    }

    var imageUrl = item.imageUrl;
    ImageAttribution? attribution;
    if (imageUrl == null) {
      if (await metadataFile.exists()) {
        final decoded = jsonDecode(await metadataFile.readAsString());
        if (decoded is Map && decoded['notFound'] == true) return null;
      }
      final saved = await _readMetadata(metadataFile);
      if (saved != null) {
        imageUrl = saved.$1;
        attribution = saved.$2;
      } else {
        final match =
            await _findFandomImage(item.title) ??
            await _findCommonsImage(category, item.title);
        if (match == null) {
          await metadataFile.writeAsString(
            jsonEncode({'notFound': true}),
            flush: true,
          );
          return null;
        }
        imageUrl = match.$1;
        attribution = match.$2;
        await metadataFile.writeAsString(
          jsonEncode({
            'imageUrl': imageUrl,
            'attribution': attribution.toJson(),
          }),
          flush: true,
        );
      }
    }

    var downloaded = await _tryDownloadImage(imageUrl, imageFile);
    if (!downloaded && item.imageUrl != null) {
      final match =
          await _findFandomImage(item.title) ??
          await _findCommonsImage(category, item.title);
      if (match == null) return null;
      imageUrl = match.$1;
      attribution = match.$2;
      await metadataFile.writeAsString(
        jsonEncode({
          'imageUrl': imageUrl,
          'attribution': attribution.toJson(),
        }),
        flush: true,
      );
      downloaded = await _tryDownloadImage(imageUrl, imageFile);
    }
    if (!downloaded) {
      throw const HttpException('Unable to download the selected image.');
    }

    if (attribution == null) {
      await metadataFile.writeAsString(
        jsonEncode({'imageUrl': imageUrl}),
        flush: true,
      );
    }
    return CachedItemImage(file: imageFile, attribution: attribution);
  }

  Future<(String, ImageAttribution)?> _findFandomImage(
    String canonicalName,
  ) async {
    final articleUri = Uri.https('onepiece.fandom.com', '/api.php', {
      'action': 'query',
      'titles': canonicalName,
      'redirects': '1',
      'prop': 'pageimages|info',
      'piprop': 'thumbnail|name',
      'pithumbsize': '640',
      'inprop': 'url',
      'format': 'json',
      'formatversion': '2',
    });
    try {
      final articleResponse = await _client
          .get(articleUri, headers: _fandomHeaders)
          .timeout(const Duration(seconds: 15));
      if (articleResponse.statusCode != 200) {
        throw HttpException(
          'One Piece Wiki returned ${articleResponse.statusCode}.',
        );
      }
      final articleData = _decodeMediaWikiResponse(articleResponse.bodyBytes);
      final pages = _mediaWikiPages(articleData);
      if (pages.isEmpty || pages.first is! Map) return null;
      final page = pages.first;
      if (page['missing'] == true ||
          _normalize(page['title'] as String? ?? '') !=
              _normalize(canonicalName)) {
        return null;
      }
      final fileName = page['pageimage'];
      final thumbnail = page['thumbnail'];
      if (fileName is! String ||
          thumbnail is! Map ||
          thumbnail['source'] is! String ||
          !_isFandomImageUrl(thumbnail['source'] as String)) {
        return null;
      }

      final fileTitle = 'File:$fileName';
      final fileUri = Uri.https('onepiece.fandom.com', '/api.php', {
        'action': 'query',
        'titles': fileTitle,
        'prop': 'imageinfo|revisions|info',
        'inprop': 'url',
        'iiprop': 'user',
        'rvprop': 'content',
        'rvslots': 'main',
        'format': 'json',
        'formatversion': '2',
      });
      final fileResponse = await _client
          .get(fileUri, headers: _fandomHeaders)
          .timeout(const Duration(seconds: 15));
      if (fileResponse.statusCode != 200) {
        throw HttpException(
          'One Piece Wiki file metadata returned ${fileResponse.statusCode}.',
        );
      }
      final fileData = _decodeMediaWikiResponse(fileResponse.bodyBytes);
      final filePages = _mediaWikiPages(fileData);
      if (filePages.isEmpty || filePages.first is! Map) return null;
      final filePage = filePages.first;
      final revisions = filePage['revisions'];
      if (revisions is! List || revisions.isEmpty) return null;
      final revision = revisions.first;
      if (revision is! Map) return null;
      final slots = revision['slots'];
      final main = slots is Map ? slots['main'] : null;
      final content = main is Map ? main['content'] : null;
      if (content is! String) return null;

      final license = _fandomOpenLicense(content);
      if (license == null) return null;
      final info = filePage['imageinfo'];
      final uploader = info is List && info.isNotEmpty && info.first is Map
          ? (info.first as Map)['user'] as String?
          : null;
      final declaredAuthor = _declaredAuthor(content);
      if (license.requiresAuthor &&
          (declaredAuthor == null || declaredAuthor.isEmpty)) {
        return null;
      }
      final author = declaredAuthor ?? uploader;
      final filePageUrl = filePage['fullurl'];
      if (filePageUrl is! String || !_isFandomFilePageUrl(filePageUrl)) {
        return null;
      }
      return (
        thumbnail['source'] as String,
        ImageAttribution(
          sourceName: 'One Piece Wiki (Fandom)',
          fileTitle: fileName,
          author: author ?? 'Public domain',
          license: license.name,
          licenseUrl: license.url,
          filePageUrl: filePageUrl,
        ),
      );
    } on HttpException catch (error) {
      debugPrint('One Piece Wiki image lookup failed: $error');
      return null;
    } on FormatException catch (error) {
      debugPrint('One Piece Wiki image response was invalid: $error');
      return null;
    } on http.ClientException catch (error) {
      debugPrint('One Piece Wiki image lookup failed: $error');
      return null;
    } on TimeoutException catch (error) {
      debugPrint('One Piece Wiki image lookup timed out: $error');
      return null;
    }
  }

  static const _fandomHeaders = {
    'Accept': 'application/json',
    'User-Agent':
        'GrandLineWiki/1.0 (https://github.com/MikaelCosta303/grand_line_wikidelicia)',
  };

  static Map<String, dynamic> _decodeMediaWikiResponse(List<int> bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic> || decoded['query'] is! Map) {
      throw const FormatException('Invalid MediaWiki response.');
    }
    return decoded;
  }

  static List<dynamic> _mediaWikiPages(Map<String, dynamic> response) {
    final query = response['query'];
    final pages = query is Map ? query['pages'] : null;
    return pages is List ? pages : const [];
  }

  static bool _isFandomImageUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'static.wikia.nocookie.net';
  }

  static bool _isFandomFilePageUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'onepiece.fandom.com' &&
        uri.path.startsWith('/wiki/File:');
  }

  static _FandomLicense? _fandomOpenLicense(String content) {
    final templates = RegExp(
      r'\{\{\s*([a-z0-9 _.-]+)',
      caseSensitive: false,
    ).allMatches(content).map((match) {
      return match.group(1)!.trim().toLowerCase().replaceAll(
            RegExp(r'[ _]+'),
            '-',
          );
    });
    for (final template in templates) {
      switch (template) {
        case 'cc-by-sa-3.0':
          return const _FandomLicense(
            'CC BY-SA 3.0',
            'https://creativecommons.org/licenses/by-sa/3.0/',
            requiresAuthor: true,
          );
        case 'cc-by-sa-4.0':
          return const _FandomLicense(
            'CC BY-SA 4.0',
            'https://creativecommons.org/licenses/by-sa/4.0/',
            requiresAuthor: true,
          );
        case 'cc-by-3.0':
          return const _FandomLicense(
            'CC BY 3.0',
            'https://creativecommons.org/licenses/by/3.0/',
            requiresAuthor: true,
          );
        case 'cc-by-4.0':
          return const _FandomLicense(
            'CC BY 4.0',
            'https://creativecommons.org/licenses/by/4.0/',
            requiresAuthor: true,
          );
        case 'cc0-1.0':
        case 'cc0':
          return const _FandomLicense(
            'CC0 1.0',
            'https://creativecommons.org/publicdomain/zero/1.0/',
          );
        case 'public-domain':
        case 'pd':
          return const _FandomLicense(
            'Public domain',
            'https://onepiece.fandom.com/wiki/One_Piece_Wiki:Copyrights',
          );
      }
    }
    return null;
  }

  static String? _declaredAuthor(String content) {
    final match = RegExp(
      r'\|\s*(?:author|artist)\s*=\s*([^|\n}]+)',
      caseSensitive: false,
    ).firstMatch(content);
    if (match == null) return null;
    final author = _plainText(match.group(1)!)
        .replaceAll(RegExp(r'\[\[|\]\]'), '')
        .trim();
    return author.isEmpty ? null : author;
  }

  Future<(String, ImageAttribution)?> _findCommonsImage(
    Category category,
    String canonicalName,
  ) async {
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'generator': 'search',
      'gsrsearch': 'filetype:bitmap "$canonicalName" "One Piece"',
      'gsrnamespace': '6',
      'gsrlimit': '10',
      'prop': 'imageinfo|categories',
      'cllimit': 'max',
      'clshow': '!hidden',
      'iiprop': 'url|extmetadata',
      'iiurlwidth': '640',
      'format': 'json',
    });
    final response = await _client.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'User-Agent':
            'GrandLineWiki/1.0 (https://github.com/MikaelCosta303/grand_line_wikidelicia)',
      },
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw HttpException('Wikimedia Commons returned ${response.statusCode}.');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid Wikimedia Commons response.');
    }
    final query = decoded['query'];
    if (query is! Map || query['pages'] is! Map) return null;

    final pages = (query['pages'] as Map).values.toList()
      ..sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
    final canonical = _normalize(canonicalName);
    for (final page in pages) {
      if (page is! Map || page['imageinfo'] is! List) continue;
      final infos = page['imageinfo'] as List;
      if (infos.isEmpty || infos.first is! Map) continue;
      final info = infos.first as Map;
      final url = info['thumburl'] ?? info['url'];
      final metadata = info['extmetadata'];
      if (url is! String || !_isWikimediaImageUrl(url) || metadata is! Map) {
        continue;
      }

      final fileTitle = (page['title'] as String? ?? '').replaceFirst(
        RegExp(r'^File:'),
        '',
      );
      final description = _metadataValue(metadata, 'ImageDescription');
      final categories = _categoryTitles(page['categories']);
      if (!_matchesCanonicalName(
        category,
        canonical,
        fileTitle,
        description,
        categories,
      )) {
        continue;
      }
      final license = _metadataValue(metadata, 'LicenseShortName');
      if (!_isAllowedLicense(license)) continue;

      final licenseUrl = _metadataValue(metadata, 'LicenseUrl');
      final filePageUrl = info['descriptionurl'];
      if (!_isAttributionUrl(licenseUrl) ||
          filePageUrl is! String ||
          !_isCommonsFilePageUrl(filePageUrl)) {
        continue;
      }
      final author = _plainText(
        _metadataValue(metadata, 'Artist').isEmpty
            ? _metadataValue(metadata, 'Credit')
            : _metadataValue(metadata, 'Artist'),
      );
      return (
        url,
        ImageAttribution(
          sourceName: 'Wikimedia Commons',
          fileTitle: fileTitle,
          author: author.isEmpty ? 'Unknown author' : author,
          license: license,
          licenseUrl: licenseUrl,
          filePageUrl: filePageUrl,
        ),
      );
    }
    return null;
  }

  Future<bool> _tryDownloadImage(String url, File destination) async {
    try {
      await _downloadImage(url, destination);
      return true;
    } on HttpException {
      return false;
    } on FormatException {
      return false;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> _downloadImage(String url, File destination) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('Image URL must use HTTPS.');
    }
    final response = await _client.get(uri, headers: const {
      'User-Agent': 'GrandLineWiki/1.0'
    }).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw HttpException('Image download returned ${response.statusCode}.');
    }
    if (response.bodyBytes.isEmpty ||
        response.bodyBytes.length > _maxImageBytes ||
        !_looksLikeSupportedImage(response.bodyBytes)) {
      throw const FormatException(
          'Image is invalid or exceeds the size limit.');
    }
    final partFile = File('${destination.path}.part');
    await partFile.writeAsBytes(response.bodyBytes, flush: true);
    await partFile.rename(destination.path);
  }

  Future<ImageAttribution?> _readAttribution(File metadataFile) async =>
      (await _readMetadata(metadataFile))?.$2;

  Future<(String, ImageAttribution?)?> _readMetadata(
    File metadataFile,
  ) async {
    if (!await metadataFile.exists()) return null;
    final decoded = jsonDecode(await metadataFile.readAsString());
    if (decoded is! Map<String, dynamic> || decoded['imageUrl'] is! String) {
      throw const FormatException('Invalid cached image metadata.');
    }
    final attributionJson = decoded['attribution'];
    return (
      decoded['imageUrl'] as String,
      attributionJson is Map<String, dynamic>
          ? ImageAttribution.fromJson(attributionJson)
          : null,
    );
  }

  static String _cacheKey(Category category, WikiItem item) {
    final source = 'strict-v3:${category.slug}:${item.id ?? item.title}';
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(source)) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    return '${category.slug}_${hash.toRadixString(16)}.img';
  }

  static bool _isAllowedLicense(String license) {
    if (_allowedLicenses.contains(license)) return true;
    return RegExp(r'^CC BY(?:-SA)?(?: [0-9.]+)?$').hasMatch(license);
  }

  static bool _isWikimediaImageUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'upload.wikimedia.org';
  }

  static bool _isCommonsFilePageUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'commons.wikimedia.org' &&
        uri.path.startsWith('/wiki/File:');
  }

  static bool _isAttributionUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https') return false;
    final host = uri.host.toLowerCase();
    return host == 'creativecommons.org' || host == 'commons.wikimedia.org';
  }

  static bool _looksLikeSupportedImage(List<int> bytes) {
    bool startsWith(List<int> signature) =>
        bytes.length >= signature.length &&
        Iterable<int>.generate(signature.length)
            .every((index) => bytes[index] == signature[index]);

    final png = startsWith([137, 80, 78, 71, 13, 10, 26, 10]);
    final jpeg = bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff;
    final gif = bytes.length >= 6 &&
        (String.fromCharCodes(bytes.take(6)) == 'GIF87a' ||
            String.fromCharCodes(bytes.take(6)) == 'GIF89a');
    final webp = bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
    return png || jpeg || gif || webp;
  }

  static bool _matchesCanonicalName(
    Category category,
    String normalizedName,
    String fileTitle,
    String description,
    List<String> categories,
  ) {
    if (normalizedName.isEmpty) return false;
    final title = _normalize(fileTitle);
    if (!_hasExactName(title, normalizedName)) return false;

    final categoryContext = categories.map(_normalize).join(' ');
    final context = '$title ${_normalize(description)} $categoryContext';
    if (!RegExp(r'\bone piece\b').hasMatch(context)) return false;

    final categoryTerms = switch (category.slug) {
      'fruits' => ['devil fruit', 'devil fruits', 'akuma no mi'],
      'characters' => ['character', 'characters'],
      'swords' => ['sword', 'swords', 'weapon', 'weapons'],
      'boats' => ['ship', 'ships', 'boat', 'boats'],
      'crews' => ['crew', 'crews'],
      'arcs' => ['arc', 'story arc'],
      'sagas' => ['saga', 'sagas'],
      'chapters' => ['chapter', 'chapters'],
      'tomes' => ['volume', 'volumes'],
      'episodes' => ['episode', 'episodes'],
      'movies' => ['movie', 'film'],
      'dials' => ['dial', 'dials'],
      'hakis' => ['haki'],
      'luffy-gears' => ['gear', 'gears'],
      'luffy-techniques' => ['technique', 'techniques'],
      'locates' => ['location', 'locations', 'island', 'islands'],
      _ => const <String>[],
    };
    return categoryTerms.isEmpty ||
        categoryTerms.any(
          (term) => RegExp(
            '\\b${RegExp.escape(term)}\\b',
          ).hasMatch(categoryContext),
        );
  }

  static bool _hasExactName(String normalizedTitle, String normalizedName) {
    final name = RegExp.escape(normalizedName);
    return RegExp(r'(?:^| )' + name + r'(?: |$)').hasMatch(normalizedTitle);
  }

  static List<String> _categoryTitles(dynamic value) {
    if (value is! List) return const [];
    return [
      for (final category in value)
        if (category is Map && category['title'] is String)
          category['title'] as String,
    ];
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  static String _metadataValue(Map metadata, String key) {
    final value = metadata[key];
    if (value is Map && value['value'] is String) {
      return value['value'] as String;
    }
    return '';
  }

  static String _plainText(String value) => value
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .trim();
}

final commonsImageService = CommonsImageService();
