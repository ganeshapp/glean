import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/content_utils.dart';
import 'github_oauth_service.dart';

class GitHubService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final GitHubOAuthService _oauth;
  Future<String>? _refreshing;
  GitHubService({
    Dio? dio,
    FlutterSecureStorage? storage,
    GitHubOAuthService? oauth,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: 'https://api.github.com',
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ),
       _storage = storage ?? const FlutterSecureStorage(),
       _oauth = oauth ?? GitHubOAuthService();

  Future<Map<String, dynamic>?> session() async {
    final raw = await _storage.read(key: 'github_session');
    return raw == null
        ? null
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<bool> isConnected() async =>
      await session() != null ||
      (await _storage.read(key: 'github_pat'))?.isNotEmpty == true;
  Future<String?> getRepo() => _storage.read(key: 'github_repo');
  Future<String?> getFolder() => _storage.read(key: 'github_folder');
  Future<String?> getBranch() => _storage.read(key: 'github_branch');
  Future<String?> getSiteUrl() => _storage.read(key: 'github_site_url');

  Future<void> connect(Map<String, dynamic> tokens) async {
    final token = tokens['access_token'] as String;
    final response = await _dio.get('/user', options: _auth(token));
    final login = (response.data as Map)['login'] as String;
    final old = await session();
    final data = {
      ...tokens,
      'login': login,
      if (tokens['expires_in'] is num)
        'expires_at':
            DateTime.now()
                .add(Duration(seconds: (tokens['expires_in'] as num).toInt()))
                .toIso8601String(),
    };
    await _storage.write(key: 'github_session', value: jsonEncode(data));
    await _storage.delete(key: 'github_pat');
    if (old != null && old['login'] != login) {
      for (final key in [
        'github_repo',
        'github_folder',
        'github_branch',
        'github_site_url',
      ]) {
        await _storage.delete(key: key);
      }
    }
  }

  Future<void> disconnect() async {
    await _storage.delete(key: 'github_session');
    await _storage.delete(key: 'github_pat');
  }

  Future<String> _token() async {
    final data = await session();
    if (data == null) {
      final legacy = await _storage.read(key: 'github_pat');
      if (legacy != null && legacy.isNotEmpty) return legacy;
      throw StateError('Connect GitHub in Settings first.');
    }
    final expiry = DateTime.tryParse(data['expires_at'] as String? ?? '');
    if (expiry != null &&
        expiry.isBefore(DateTime.now().add(const Duration(minutes: 2)))) {
      return _refreshing ??= _refresh(
        data,
      ).whenComplete(() => _refreshing = null);
    }
    return data['access_token'] as String;
  }

  Future<String> _refresh(Map<String, dynamic> current) async {
    final refresh = current['refresh_token'] as String?;
    if (refresh == null) {
      throw StateError('Your GitHub session expired. Please reconnect.');
    }
    final tokens = await _oauth.refresh(refresh);
    await connect(tokens);
    return tokens['access_token'] as String;
  }

  Options _auth(String token) => Options(
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    },
  );
  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async =>
      _dio.get(path, queryParameters: query, options: _auth(await _token()));

  Future<void> saveConfig({
    required String repo,
    required String folder,
    required String branch,
    required String siteUrl,
  }) async {
    if (!RegExp(r'^[\w.-]+/[\w.-]+$').hasMatch(repo) || branch.trim().isEmpty) {
      throw StateError('Choose a repository and branch.');
    }
    if (folder.startsWith('/') ||
        folder.split('/').any((p) => p == '..' || p == '.')) {
      throw StateError('Use a folder inside the repository.');
    }
    if (safeWebUrl(siteUrl) == null) {
      throw StateError('Enter the public website URL, including https://.');
    }
    await _storage.write(key: 'github_repo', value: repo);
    await _storage.write(
      key: 'github_folder',
      value: folder.replaceAll(RegExp(r'/+$'), ''),
    );
    await _storage.write(key: 'github_branch', value: branch);
    await _storage.write(
      key: 'github_site_url',
      value: siteUrl.replaceAll(RegExp(r'/+$'), ''),
    );
  }

  Future<List<GitHubRepo>> listRepositories() async {
    final repos = <GitHubRepo>[];
    for (var page = 1; ; page++) {
      final response = await _get(
        '/user/repos',
        query: {
          'per_page': 100,
          'page': page,
          'sort': 'updated',
          'affiliation': 'owner,collaborator',
        },
      );
      final list = response.data as List;
      repos.addAll(
        list
            .where(
              (e) => e['permissions']?['push'] == true && e['private'] != true,
            )
            .map(
              (e) => GitHubRepo(
                fullName: e['full_name'],
                name: e['name'],
                branch: e['default_branch'] ?? 'main',
              ),
            ),
      );
      if (list.length < 100) break;
    }
    return repos;
  }

  Future<List<GitHubContentItem>> listContents(
    String repo,
    String path,
    String branch,
  ) async {
    final response = await _get(
      '/repos/$repo/contents/${_path(path)}',
      query: {'ref': branch},
    );
    return (response.data as List)
        .where((e) => e['type'] == 'dir')
        .map(
          (e) => GitHubContentItem(
            name: e['name'],
            path: e['path'],
            type: e['type'],
          ),
        )
        .toList();
  }

  Future<String> siteUrlFor(String repo) async {
    try {
      final result = await _get('/repos/$repo/pages');
      final url = (result.data as Map)['html_url'] as String?;
      if (safeWebUrl(url) != null) return url!.replaceAll(RegExp(r'/+$'), '');
    } on DioException catch (e) {
      if (e.response?.statusCode != 404 && e.response?.statusCode != 403) {
        rethrow;
      }
    }
    if (repo.toLowerCase() == 'ganeshapp/ganeshapp.github.io') {
      return 'https://www.gapp.in';
    }
    final parts = repo.split('/');
    return 'https://${parts.first}.github.io${parts.last.toLowerCase() == '${parts.first.toLowerCase()}.github.io' ? '' : '/${parts.last}'}';
  }

  Future<void> testConnection(String repo, String folder, String branch) async {
    final response = await _get('/repos/$repo');
    if ((response.data as Map)['permissions']?['push'] != true) {
      throw StateError('This account cannot write to the repository.');
    }
    await _get(
      '/repos/$repo/contents/${_path(folder)}',
      query: {'ref': branch},
    );
  }

  static String _path(String path) =>
      path.split('/').map(Uri.encodeComponent).join('/');

  Future<GitHubPublication> publish({
    required String repo,
    required String path,
    required String branch,
    required String content,
    String? expectedSha,
    List<GitHubAsset> assets = const [],
    void Function(int done, int total)? onPhotoProgress,
  }) async {
    final endpoint = '/repos/$repo/contents/${_path(path)}';
    Map<String, dynamic>? existing;
    try {
      final response = await _get(endpoint, query: {'ref': branch});
      existing = Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
    }
    final sha = existing?['sha'] as String?;
    var unchanged = false;
    if (existing != null) {
      final old = utf8.decode(
        base64Decode((existing['content'] as String).replaceAll('\n', '')),
      );
      unchanged = old == content;
      if (!unchanged && (expectedSha == null || expectedSha != sha)) {
        throw StateError(
          'This file already exists or changed on GitHub. Your local draft is safe. Resolve the remote change before updating.',
        );
      }
    } else if (expectedSha != null) {
      throw StateError(
        'The published file was removed on GitHub. Your local draft is safe.',
      );
    }
    // Publish references only after every image is available. Uploads are
    // immutable and idempotent, so a failed batch can be retried safely.
    for (var i = 0; i < assets.length; i++) {
      onPhotoProgress?.call(i, assets.length);
      await _uploadAsset(repo, branch, assets[i]);
    }
    if (assets.isNotEmpty) onPhotoProgress?.call(assets.length, assets.length);
    if (unchanged) {
      return GitHubPublication(sha!, existing!['html_url'] as String? ?? '');
    }
    final response = await _dio.put(
      endpoint,
      options: _auth(await _token()),
      data: {
        'message':
            'Publish roundup ${path.split('/').last.replaceAll('.md', '')}',
        'branch': branch,
        'content': base64Encode(utf8.encode(content)),
        if (sha != null) 'sha': sha,
      },
    );
    final file = (response.data as Map)['content'] as Map;
    return GitHubPublication(
      file['sha'] as String,
      file['html_url'] as String? ?? '',
    );
  }

  Future<void> _uploadAsset(
    String repo,
    String branch,
    GitHubAsset asset,
  ) async {
    final endpoint = '/repos/$repo/contents/${_path(asset.path)}';
    final expected =
        sha1.convert([
          ...utf8.encode('blob ${asset.bytes.length}\u0000'),
          ...asset.bytes,
        ]).toString();
    Future<bool> exists() async {
      try {
        final response = await _get(endpoint, query: {'ref': branch});
        if ((response.data as Map)['sha'] == expected) return true;
        throw StateError(
          'An image at this destination changed on GitHub. Your local photo is safe.',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) return false;
        rethrow;
      }
    }

    if (await exists()) return;
    try {
      await _dio.put(
        endpoint,
        options: _auth(await _token()),
        data: {
          'message': 'Add roundup photo',
          'branch': branch,
          'content': base64Encode(asset.bytes),
        },
      );
    } on DioException catch (e) {
      if ([409, 422].contains(e.response?.statusCode) && await exists()) return;
      rethrow;
    }
  }

  Future<bool> isLive(String url, String issueId, int revision) async {
    final safe = safeWebUrl(url);
    if (safe == null) return false;
    final response = await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    ).get<String>(
      safe,
      queryParameters: {'glean_check': DateTime.now().millisecondsSinceEpoch},
      options: Options(responseType: ResponseType.plain),
    );
    final html = response.data ?? '';
    return html.contains('name="glean-issue" content="$issueId"') &&
        html.contains('name="glean-revision" content="$revision"');
  }
}

class GitHubRepo {
  final String fullName, name, branch;
  const GitHubRepo({
    required this.fullName,
    required this.name,
    this.branch = 'main',
  });
}

class GitHubContentItem {
  final String name, path, type;
  const GitHubContentItem({
    required this.name,
    required this.path,
    required this.type,
  });
}

class GitHubPublication {
  final String sha, fileUrl;
  const GitHubPublication(this.sha, this.fileUrl);
}

class GitHubAsset {
  final String path;
  final Uint8List bytes;
  const GitHubAsset(this.path, this.bytes);
}

String friendlyGitHubError(Object error) {
  if (error is DioException) {
    return switch (error.response?.statusCode) {
      401 => 'GitHub sign-in expired or was revoked. Reconnect in Settings.',
      403 =>
        'GitHub denied access or rate-limited this request. Check permissions and try again.',
      404 => 'Repository, branch, or folder was not found. Check Settings.',
      409 || 422 =>
        'The file changed on GitHub. Your draft is safe; retry after checking the repository.',
      _ => 'Could not reach GitHub. Your draft is saved; please try again.',
    };
  }
  return error is StateError
      ? error.message.toString()
      : 'Could not finish the operation. Please try again.';
}
