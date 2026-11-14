import 'package:html/parser.dart' as html;

String plainText(String source) =>
    html
        .parseFragment(
          source
              .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
              .replaceAll(
                RegExp(r'</p\s*>|<p\s*>', caseSensitive: false),
                '\n\n',
              ),
        )
        .text
        ?.trim() ??
    '';

String? safeWebUrl(String? value) {
  final uri = Uri.tryParse(value?.trim() ?? '');
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  return uri.toString();
}

String? canonicalUrl(String? value) {
  final safe = safeWebUrl(value);
  if (safe == null) return null;
  final uri = Uri.parse(safe);
  final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
  if (host == 'youtu.be' || host == 'youtube.com' || host == 'm.youtube.com') {
    final id =
        host == 'youtu.be'
            ? (uri.pathSegments.isEmpty ? null : uri.pathSegments.first)
            : uri.queryParameters['v'];
    if (id != null && id.isNotEmpty) return 'https://youtube.com/watch?v=$id';
  }
  final query = Map<String, String>.from(uri.queryParameters)..removeWhere(
    (k, v) => k.startsWith('utm_') || ['fbclid', 'gclid', 'si'].contains(k),
  );
  final keys = query.keys.toList()..sort();
  return uri
      .replace(
        scheme: 'https',
        host: host == 'twitter.com' ? 'x.com' : host,
        fragment: '',
        queryParameters:
            query.isEmpty ? null : {for (final k in keys) k: query[k]!},
        query: query.isEmpty ? '' : null,
      )
      .toString();
}
