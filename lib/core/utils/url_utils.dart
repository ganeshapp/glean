class UrlUtils {
  UrlUtils._();

  static String? extractDomain(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      var host = uri.host;
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }
      return host;
    } catch (_) {
      return null;
    }
  }
}
