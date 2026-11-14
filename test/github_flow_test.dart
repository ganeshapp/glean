import 'dart:convert';
import 'dart:typed_data';
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
}
