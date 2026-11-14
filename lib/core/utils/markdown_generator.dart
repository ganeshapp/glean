import 'dart:convert';
import '../../data/database/app_database.dart';
import 'content_utils.dart';

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

  static String body(RoundupIssue issue, List<RoundupCard> cards) {
    final out = <String>[];
    if (issue.introduction.trim().isNotEmpty) {
      out.add(text(issue.introduction.trim()));
    }
    // Preserve the caller's editorial order, including mixed sources.
    for (final card in cards) {
      final quote = card.type == 'hnComment' || card.type == 'tweet';
      if (quote) {
        if (card.excerpt.isNotEmpty) {
          out.add(
            card.excerpt
                .split('\n')
                .map((line) => '> ${text(line)}')
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
                .map((line) => '> ${text(line)}')
                .join('\n'),
          );
        }
      }
      if (card.blurb.trim().isNotEmpty) out.add(text(card.blurb.trim()));
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
