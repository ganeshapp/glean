import '../../data/database/app_database.dart';

class MarkdownGenerator {
  MarkdownGenerator._();

  static const _newTab = '{:target="_blank"}';

  static String generateFrontmatter(String weekLabel, DateTime publishDate) {
    final dateStr =
        '${publishDate.year}-${publishDate.month.toString().padLeft(2, '0')}-${publishDate.day.toString().padLeft(2, '0')}';
    return '---\n'
        'title: "$weekLabel"\n'
        'date: $dateStr\n'
        'layout: single\n'
        'collection: weekly\n'
        'tags: [roundup]\n'
        '---\n';
  }

  static String generate(String weekLabel, List<BookmarksTableData> bookmarks) {
    final buf = StringBuffer();

    final articles =
        bookmarks.where((b) => b.type == 'hnArticle').toList();
    final quotes =
        bookmarks.where((b) => b.type == 'hnComment').toList();
    final tweets = bookmarks.where((b) => b.type == 'tweet').toList();
    final webSnippets =
        bookmarks.where((b) => b.type == 'website').toList();

    if (articles.isNotEmpty) {
      buf.writeln('## Articles\n');
      for (final a in articles) {
        final title = a.title ?? 'Untitled';
        final url = a.contentUrl ?? '#';
        final link = '[$title]($url)$_newTab';
        if (a.hnUrl != null) {
          buf.writeln(
              '$link [<i class="fab fa-fw fa-hacker-news"></i>](${a.hnUrl})$_newTab');
        } else {
          buf.writeln(link);
        }
        if (a.summary != null && a.summary!.isNotEmpty) {
          buf.writeln(a.summary!);
        }
        buf.writeln();
      }
    }

    if (quotes.isNotEmpty) {
      buf.writeln('## Quotes\n');
      for (final c in quotes) {
        final text = c.contentText ?? '';
        if (text.isNotEmpty) {
          buf.writeln(text);
        }
        final author = c.author ?? 'unknown';
        final url = c.contentUrl ?? '#';
        buf.writeln('-- [$author]($url)$_newTab');
        if (c.summary != null && c.summary!.isNotEmpty) {
          buf.writeln(c.summary!);
        }
        buf.writeln();
      }
    }

    if (tweets.isNotEmpty) {
      buf.writeln('## Tweets\n');
      for (final t in tweets) {
        final text = t.contentText ?? '';
        final author = t.author ?? '@unknown';
        final url = t.contentUrl ?? '#';
        if (text.isNotEmpty) {
          buf.writeln('$text - [$author]($url)$_newTab');
        } else {
          buf.writeln('[$author]($url)$_newTab');
        }
        if (t.summary != null && t.summary!.isNotEmpty) {
          buf.writeln(t.summary!);
        }
        buf.writeln();
      }
    }

    if (webSnippets.isNotEmpty) {
      buf.writeln('## Web\n');
      for (final w in webSnippets) {
        final text = w.contentText ?? '';
        final title = w.title ?? w.domain ?? 'Source';
        final url = w.contentUrl ?? '#';
        if (text.isNotEmpty) {
          buf.writeln('$text - [$title]($url)$_newTab');
        } else {
          buf.writeln('[$title]($url)$_newTab');
        }
        if (w.summary != null && w.summary!.isNotEmpty) {
          buf.writeln(w.summary!);
        }
        buf.writeln();
      }
    }

    return buf.toString().trimRight();
  }
}
