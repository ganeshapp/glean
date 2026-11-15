import 'dart:convert';
import '../../data/database/app_database.dart';
import 'content_utils.dart';
import 'photo_paths.dart';
import 'youtube_video.dart';

class MarkdownGenerator {
  MarkdownGenerator._();
  // Editors contain plain text. Escape source material before Markdown/Liquid rendering.
  static String text(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAllMapped(RegExp(r'[\\`*_\[\]#]'), (m) => '\\${m[0]}');
  static String _link(String label, String url) {
    final safe = safeWebUrl(url);
    return safe == null
        ? text(label)
        : '[${text(label)}](<${safe.replaceAll('>', '%3E').replaceAll('<', '%3C')}>)';
  }

  static String paragraph(String value) {
    final out = StringBuffer();
    var end = 0;
    for (final match in RegExp(r'https?://[^\s<>]+').allMatches(value)) {
      var url = match.group(0)!.replaceAll(RegExp(r'[.,;!?]+$'), '');
      while (url.endsWith(')') &&
          ')'.allMatches(url).length > '('.allMatches(url).length) {
        url = url.substring(0, url.length - 1);
      }
      out.write(text(value.substring(end, match.start)));
      final safe = safeWebUrl(url);
      out.write(safe == null ? text(url) : _link(url, safe));
      end = match.start + url.length;
    }
    out.write(text(value.substring(end)));
    return out.toString();
  }

  static String body(
    RoundupIssue issue,
    List<RoundupCard> cards, {
    bool forPreview = false,
  }) {
    final out = <String>[];
    if (issue.introduction.trim().isNotEmpty) {
      out.add(paragraph(issue.introduction.trim()));
    }
    // Preserve the caller's editorial order, including mixed sources.
    for (final card in cards) {
      final quote = card.type == 'hnComment' || card.type == 'tweet';
      if (card.type == 'photo') {
        final id = card.photoId;
        if (id == null || !PhotoPaths.validId(id)) {
          throw StateError('This photo is missing.');
        }
        final url =
            forPreview ? 'glean-photo:$id' : PhotoPaths.publicUrl(issue, id);
        final alt =
            card.title.trim().isEmpty
                ? 'Roundup photo'
                : card.title.trim().replaceAll('\n', ' ');
        out.add('![${text(alt)}](<$url>)');
        if (card.title.trim().isNotEmpty) {
          out.add('*${paragraph(card.title.trim())}*');
        }
      } else if (quote) {
        if (card.excerpt.isNotEmpty) {
          out.add(
            card.excerpt
                .split('\n')
                .map((line) => '> ${paragraph(line)}')
                .join('\n'),
          );
        }
        out.add(
          '— ${_link(card.author.isNotEmpty ? card.author : 'Source', card.url)}',
        );
      } else {
        out.add(
          '### ${_link(card.title.isNotEmpty ? card.title : 'Saved link', card.url)}',
        );
        if (card.excerpt.isNotEmpty) {
          out.add(
            card.excerpt
                .split('\n')
                .map((line) => '> ${paragraph(line)}')
                .join('\n'),
          );
        }
      }
      final video = card.type == 'photo' ? null : YouTubeVideo.parse(card.url);
      if (video != null) {
        out.add(forPreview ? _link('Play on YouTube', card.url) : video.iframe);
      }
      if (card.blurb.trim().isNotEmpty) out.add(paragraph(card.blurb.trim()));
      if (card.discussionUrl.isNotEmpty && card.discussionUrl != card.url) {
        out.add(_link('HN discussion', card.discussionUrl));
      }
      out.add('<!-- roundup-item:${card.id} -->');
    }
    return out.join('\n\n');
  }

  static String document(RoundupIssue issue, List<RoundupCard> cards) {
    final date =
        '${issue.date.year}-${issue.date.month.toString().padLeft(2, '0')}-${issue.date.day.toString().padLeft(2, '0')}';
    // Entity-encode braces so untrusted captured text cannot invoke Liquid tags.
    final markdown = body(
      issue,
      cards,
    ).replaceAll('{', '&#123;').replaceAll('}', '&#125;');
    return '---\n'
        'title: ${jsonEncode(issue.title)}\n'
        'date: $date\n'
        'layout: roundup\n'
        'glean_issue: ${jsonEncode(issue.id)}\n'
        'glean_revision: ${issue.revision}\n'
        'permalink: /roundup/${issue.id}/\n'
        '---\n\n$markdown\n';
  }
}
