import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glean/data/api/github_oauth_service.dart';
import 'package:glean/data/api/github_service.dart';

class FakeAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) respond;
  FakeAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? s,
    Future<void>? c,
  ) => respond(o);
  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);
Dio client(Future<ResponseBody> Function(RequestOptions) respond) =>
    Dio(BaseOptions(baseUrl: 'https://api.github.com'))
      ..httpClientAdapter = FakeAdapter(respond);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () =>
        FlutterSecureStorage.setMockInitialValues({'github_pat': 'test-token'}),
  );
  test(
    'device sign-in waits, backs off, and returns only approved token',
    () async {
      var polls = 0;
      final waits = <int>[];
      final oauth = GitHubOAuthService(
        dio: client((r) async {
          expect(r.data['client_id'], GitHubAppConfig.clientId);
          expect((r.data as Map).containsKey('client_secret'), false);
          return json(
            [
              {'error': 'authorization_pending'},
              {'error': 'slow_down'},
              {'access_token': 'approved'},
            ][polls++],
          );
        }),
      );
      final result = await oauth.poll(
        const DeviceCode('device', 'USER-CODE', 5, 900),
        cancelled: () => false,
        wait: (d) async {
          waits.add(d.inSeconds);
        },
      );
      expect(waits, [5, 5, 10]);
      expect(result?['access_token'], 'approved');
    },
  );
  test('cancel and expiry stop polling', () async {
    var requests = 0;
    final oauth = GitHubOAuthService(
      dio: client((_) async {
        requests++;
        return json({'error': 'authorization_pending'});
      }),
    );
    expect(
      await oauth.poll(
        const DeviceCode('d', 'u', 5, 900),
        cancelled: () => true,
      ),
      isNull,
    );
    await expectLater(
      oauth.poll(
        const DeviceCode('d', 'u', 5, 10),
        cancelled: () => false,
        wait: (_) async {},
      ),
      throwsStateError,
    );
    expect(requests, 1);
  });
  test(
    'publishing replaces whole issue, identical retry does not write twice',
    () async {
      String? content, sha;
      var puts = 0;
      final api = GitHubService(
        dio: client((r) async {
          if (r.method == 'GET') {
            return content == null
                ? json({'message': 'not found'}, 404)
                : json({
                  'sha': sha,
                  'content': base64Encode(utf8.encode(content!)),
                  'html_url': 'https://github.com/example',
                });
          }
          puts++;
          if (sha != null) expect(r.data['sha'], sha);
          content = utf8.decode(base64Decode(r.data['content']));
          sha = 'sha$puts';
          expect(r.data['branch'], 'main');
          return json({
            'content': {'sha': sha, 'html_url': 'https://github.com/example'},
          }, 201);
        }),
      );
      final first = await api.publish(
        repo: 'owner/site',
        path: '_roundup/2026-W46.md',
        branch: 'main',
        content: 'one',
      );
      await api.publish(
        repo: 'owner/site',
        path: '_roundup/2026-W46.md',
        branch: 'main',
        content: 'one',
      );
      expect(puts, 1);
      await api.publish(
        repo: 'owner/site',
        path: '_roundup/2026-W46.md',
        branch: 'main',
        content: 'two',
        expectedSha: first.sha,
      );
      expect(content, 'two');
      expect(puts, 2);
      await expectLater(
        api.publish(
          repo: 'owner/site',
          path: '_roundup/2026-W46.md',
          branch: 'main',
          content: 'three',
          expectedSha: first.sha,
        ),
        throwsStateError,
      );
      expect(puts, 2);
    },
  );
  test('existing unrelated file is never overwritten', () async {
    final api = GitHubService(
      dio: client((r) async {
        expect(r.method, 'GET');
        return json({
          'sha': 'remote',
          'content': base64Encode(utf8.encode('Someone else’s writing')),
        });
      }),
    );
    await expectLater(
      api.publish(
        repo: 'owner/site',
        path: '_roundup/issue.md',
        branch: 'main',
        content: 'new',
      ),
      throwsStateError,
    );
  });
  test(
    'connection persists account only after validation and config keeps legacy token',
    () async {
      final api = GitHubService(
        dio: client((_) async => json({'login': 'owner'})),
      );
      await api.saveConfig(
        repo: 'owner/site',
        folder: '_roundup',
        branch: 'main',
        siteUrl: 'https://example.com',
      );
      expect(
        await const FlutterSecureStorage().read(key: 'github_pat'),
        'test-token',
      );
      await api.connect({'access_token': 'device-token'});
      expect((await api.session())?['login'], 'owner');
      expect(
        await const FlutterSecureStorage().read(key: 'github_pat'),
        isNull,
      );
    },
  );
  test(
    'photo upload failure blocks Markdown; retry skips existing photos before publishing',
    () async {
      final uploaded = <String, String>{};
      final puts = <String>[];
      var fail = true;
      final first = Uint8List.fromList([1, 2, 3]),
          second = Uint8List.fromList([4, 5]);
      String blob(Uint8List bytes) =>
          sha1.convert([
            ...utf8.encode('blob ${bytes.length}\u0000'),
            ...bytes,
          ]).toString();
      final api = GitHubService(
        dio: client((r) async {
          final name = r.path.split('/').last;
          if (r.method == 'GET') {
            expect(r.queryParameters['ref'], 'main');
            if (!uploaded.containsKey(name)) return json({}, 404);
            return json({
              'sha': uploaded[name],
              if (name == 'issue.md')
                'content': base64Encode(utf8.encode('Markdown')),
            });
          }
          puts.add(name);
          if (name == 'two.jpg' && fail) return json({}, 503);
          if (name.endsWith('.jpg')) {
            expect((r.data as Map).containsKey('sha'), false);
            final bytes = base64Decode(r.data['content']);
            uploaded[name] = blob(bytes);
          } else {
            expect(uploaded.keys, containsAll(['one.jpg', 'two.jpg']));
            uploaded[name] = 'markdown-sha';
          }
          return json({
            'content': {'sha': uploaded[name]},
          }, 201);
        }),
      );
      Future<GitHubPublication> publish() => api.publish(
        repo: 'owner/site',
        path: '_roundup/issue.md',
        branch: 'main',
        content: 'Markdown',
        assets: [
          GitHubAsset('_roundup/assets/one.jpg', first),
          GitHubAsset('_roundup/assets/two.jpg', second),
        ],
      );
      await expectLater(publish(), throwsA(isA<DioException>()));
      expect(uploaded.keys, ['one.jpg']);
      expect(puts, ['one.jpg', 'two.jpg']);
      fail = false;
      expect((await publish()).sha, 'markdown-sha');
      expect(puts, ['one.jpg', 'two.jpg', 'two.jpg', 'issue.md']);
      await publish();
      expect(puts.length, 4);
    },
  );
  test(
    'conflicting photo is never overwritten or referenced in a new issue',
    () async {
      final api = GitHubService(
        dio: client((r) async {
          expect(r.method, 'GET');
          return r.path.endsWith('.md')
              ? json({}, 404)
              : json({'sha': 'different-binary'});
        }),
      );
      await expectLater(
        api.publish(
          repo: 'owner/site',
          path: '_roundup/issue.md',
          branch: 'main',
          content: 'new',
          assets: [
            GitHubAsset('_roundup/assets/photo.jpg', Uint8List.fromList([1])),
          ],
        ),
        throwsStateError,
      );
    },
  );
}
