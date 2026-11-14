import 'package:flutter_test/flutter_test.dart';
import 'package:glean/data/api/comment_export_service.dart';
import 'package:glean/features/share_receiver/share_handler.dart';
import 'package:glean/data/models/bookmark.dart';

void main() {
  test(
    'export preserves ranked roots and nesting without inventing vote counts',
    () async {
      final items = <int, Map<String, dynamic>>{
        1: {
          'id': 1,
          'title': 'Story',
          'kids': [4, 2, 99],
          'score': 120,
          'descendants': 8,
        },
        4: {
          'id': 4,
          'parent': 1,
          'by': 'A',
          'text':
              'First <i>ranked</i> <a href="https://example.com">source</a>',
          'kids': [5],
        },
        2: {'id': 2, 'parent': 1, 'by': 'B', 'text': 'Second', 'kids': []},
        5: {
          'id': 5,
          'parent': 4,
          'by': 'C',
          'text': 'Reply',
          'kids': [6],
        },
        6: {
          'id': 6,
          'parent': 5,
          'by': 'D',
          'text': 'Deeper',
          'kids': [7],
        },
        7: {
          'id': 7,
          'parent': 6,
          'deleted': true,
          'text': 'Must never export deleted text',
          'kids': [8],
        },
        8: {'id': 8, 'parent': 7, 'text': 'Beyond limit'},
      };
      final result = await CommentExportService(
        fetch: (id) async => items[id],
      ).build(1, rootLimit: 2);
      final comments = result['comments'] as List;
      expect(comments.map((c) => c['id']), [4, 2]);
      expect(comments.first['text'], 'First ranked source');
      expect(comments.first['links'], ['https://example.com']);
      final hidden = comments.first['replies'][0]['replies'][0]['replies'][0];
      expect(hidden['unavailable'], true);
      expect(hidden['text'], '');
      expect(hidden['omitted_reply_count'], 1);
      expect(result['selection']['truncated'], true);
      expect(result['selection']['comment_vote_counts_available'], false);
      expect(comments.first.containsKey('score'), false);
    },
  );
  test(
    'budget and partial network failure produce explicitly limited exports',
    () async {
      final fetched = <int>[];
      final service = CommentExportService(
        fetch: (id) async {
          fetched.add(id);
          if (id == 1) {
            return {
              'id': 1,
              'kids': [2, 3, 4],
            };
          }
          if (id == 3) throw StateError('offline');
          return {
            'id': id,
            'parent': 1,
            'text': 'Comment',
            'kids': [id + 10],
          };
        },
      );
      final data = await service.build(1, maxComments: 2);
      expect(data['selection']['unavailable_comment_ids'], [3]);
      expect(data['selection']['truncated'], true);
      expect(fetched, [1, 2, 3]);
    },
  );
  test('share parser uses exact hosts and retains selected text', () {
    final capture = SharedCapture.parse(
      'An interesting angle https://x.com/person/status/42',
    );
    expect(capture.type, BookmarkType.tweet);
    expect(capture.author, '@person');
    expect(capture.text, 'An interesting angle');
    expect(
      SharedCapture.parse('https://notx.com/article').type,
      BookmarkType.website,
    );
    expect(
      SharedCapture.parse('https://youtube.com/watch?v=123&t=40').type,
      BookmarkType.video,
    );
    expect(
      SharedCapture.parse('https://news.ycombinator.com/item?id=55').hnId,
      55,
    );
    expect(
      SharedCapture.parse('Selected text without a URL').text,
      'Selected text without a URL',
    );
  });
}
