import 'content_utils.dart';

class YouTubeVideo {
  final String id;
  final int start;
  const YouTubeVideo(this.id, {this.start = 0});

  static YouTubeVideo? parse(String url) {
    final safe = safeWebUrl(url);
    if (safe == null) return null;
    final uri = Uri.parse(safe);
    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
    String? id;
    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      id = uri.pathSegments.first;
    } else if ([
      'youtube.com',
      'm.youtube.com',
      'youtube-nocookie.com',
    ].contains(host)) {
      if (uri.path == '/watch') id = uri.queryParameters['v'];
      if (uri.pathSegments.length >= 2 &&
          ['shorts', 'embed', 'live'].contains(uri.pathSegments.first)) {
        id = uri.pathSegments[1];
      }
    }
    if (id == null || !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)) return null;
    final raw = uri.queryParameters['start'] ?? uri.queryParameters['t'] ?? '';
    var seconds = int.tryParse(raw) ?? 0;
    final time = RegExp(r'^(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?$').firstMatch(raw);
    if (time != null && raw.isNotEmpty) {
      seconds =
          (int.tryParse(time[1] ?? '') ?? 0) * 3600 +
          (int.tryParse(time[2] ?? '') ?? 0) * 60 +
          (int.tryParse(time[3] ?? '') ?? 0);
    }
    return YouTubeVideo(id, start: seconds.clamp(0, 86400));
  }

  String get embedUrl =>
      'https://www.youtube-nocookie.com/embed/$id${start > 0 ? '?start=$start' : ''}';
  String get iframe =>
      '<div class="roundup-video" style="aspect-ratio:16/9;width:100%;margin:1em 0;">\n'
      '<iframe src="$embedUrl" title="YouTube video" loading="lazy" '
      'style="width:100%;height:100%;border:0;" '
      'allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" '
      'referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>\n</div>';
}
