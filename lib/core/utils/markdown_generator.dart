import '../../data/database/app_database.dart';

class MarkdownGenerator {
  MarkdownGenerator._();

  static String generate(String weekLabel, List<BookmarksTableData> bookmarks) {
    final buf = StringBuffer();
    buf.writeln('# $weekLabel\n');

    final articles =
        bookmarks.where((b) => b.type == 'hnArticle').toList();
    final comments =
        bookmarks.where((b) => b.type == 'hnComment').toList();
    final tweets = bookmarks.where((b) => b.type == 'tweet').toList();
    final webSnippets =
        bookmarks.where((b) => b.type == 'website').toList();

    if (articles.isNotEmpty) {
      buf.writeln('## Articles\n');
      for (final a in articles) {
        final title = a.title ?? 'Untitled';
        final url = a.contentUrl ?? '#';
        buf.writeln('### [$title]($url)\n');
        if (a.summary != null && a.summary!.isNotEmpty) {
          buf.writeln('> ${a.summary}\n');
        }
        if (a.hnUrl != null) {
          buf.writeln('[HN Discussion](${a.hnUrl})\n');
        }
        buf.writeln('---\n');
      }
    }

    if (comments.isNotEmpty) {
      buf.writeln('## Comments\n');
      for (final c in comments) {
        final text = c.contentText ?? '';
        final lines = text.split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            buf.writeln('> $line');
          } else {
            buf.writeln('>');
          }
        }
        buf.writeln();
        final author = c.author ?? 'unknown';
        final url = c.contentUrl ?? '#';
        buf.writeln('-- [$author]($url)\n');
        buf.writeln('---\n');
      }
    }

    if (tweets.isNotEmpty) {
      buf.writeln('## Tweets\n');
      for (final t in tweets) {
        final text = t.contentText ?? '';
        final lines = text.split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            buf.writeln('> $line');
          } else {
            buf.writeln('>');
          }
        }
        buf.writeln();
        final author = t.author ?? '@unknown';
        final url = t.contentUrl ?? '#';
        buf.writeln('-- [$author]($url)\n');
        buf.writeln('---\n');
      }
    }

    if (webSnippets.isNotEmpty) {
      buf.writeln('## Web\n');
      for (final w in webSnippets) {
        final text = w.contentText ?? '';
        if (text.isNotEmpty) {
          final lines = text.split('\n');
          for (final line in lines) {
            if (line.trim().isNotEmpty) {
              buf.writeln('> $line');
            } else {
              buf.writeln('>');
            }
          }
          buf.writeln();
        }
        final title = w.title ?? w.domain ?? 'Source';
        final url = w.contentUrl ?? '#';
        buf.writeln('Source: [$title]($url)\n');
        buf.writeln('---\n');
      }
    }

    return buf.toString().trimRight();
  }
}
