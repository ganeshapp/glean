import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GitHubService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  GitHubService({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.github.com',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            )),
        _storage = storage ?? const FlutterSecureStorage();

  Future<String?> _getToken() => _storage.read(key: 'github_pat');
  Future<String?> getRepo() => _storage.read(key: 'github_repo');
  Future<String?> getFolder() => _storage.read(key: 'github_folder');

  Future<void> saveConfig({
    required String pat,
    required String repo,
    required String folder,
  }) async {
    await _storage.write(key: 'github_pat', value: pat);
    await _storage.write(key: 'github_repo', value: repo);
    await _storage.write(key: 'github_folder', value: folder);
  }

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.v3+json',
    });
  }

  Future<bool> testConnection() async {
    final token = await _getToken();
    final repo = await getRepo();
    if (token == null || repo == null) return false;
    try {
      final response = await _dio.get(
        '/repos/$repo',
        options: _authOptions(token),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// List repositories for the authenticated user (PAT).
  Future<List<GitHubRepo>> listRepositories(String token) async {
    try {
      final response = await _dio.get(
        '/user/repos',
        options: _authOptions(token),
        queryParameters: {'per_page': 100, 'sort': 'updated', 'type': 'owner'},
      );
      if (response.statusCode != 200) return [];
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => GitHubRepo(
                fullName: e['full_name'] as String? ?? '',
                name: e['name'] as String? ?? '',
              ))
          .where((r) => r.fullName.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// List contents of a path in the repo (root if path is empty). Returns only directories if [dirsOnly] is true.
  Future<List<GitHubContentItem>> listContents(
    String repo,
    String path,
    String token, {
    bool dirsOnly = true,
  }) async {
    try {
      final uri = path.isEmpty
          ? '/repos/$repo/contents'
          : '/repos/$repo/contents/${Uri.encodeComponent(path)}';
      final response = await _dio.get(uri, options: _authOptions(token));
      if (response.statusCode != 200) return [];
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => GitHubContentItem(
                name: e['name'] as String? ?? '',
                path: e['path'] as String? ?? '',
                type: e['type'] as String? ?? 'file',
              ))
          .where((e) => !dirsOnly || e.type == 'dir')
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns the SHA of existing file, or null if it doesn't exist.
  Future<String?> _getFileSha(String repo, String path, String token) async {
    try {
      final response = await _dio.get(
        '/repos/$repo/contents/$path',
        options: _authOptions(token),
      );
      if (response.statusCode == 200) {
        return response.data['sha'] as String?;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
    return null;
  }

  /// Gets existing file content (base64 decoded).
  Future<String?> _getFileContent(
      String repo, String path, String token) async {
    try {
      final response = await _dio.get(
        '/repos/$repo/contents/$path',
        options: _authOptions(token),
      );
      if (response.statusCode == 200) {
        final b64 = (response.data['content'] as String).replaceAll('\n', '');
        return utf8.decode(base64Decode(b64));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
    return null;
  }

  /// Creates or updates a file in the repo.
  Future<bool> publishFile({
    required String content,
    required String weekLabel,
  }) async {
    final token = await _getToken();
    final repo = await getRepo();
    final folder = await getFolder();
    if (token == null || repo == null) return false;

    final folderPath = (folder != null && folder.isNotEmpty) ? folder : 'weekly';
    final filePath = '$folderPath/$weekLabel.md';

    final sha = await _getFileSha(repo, filePath, token);
    final existingContent = sha != null
        ? await _getFileContent(repo, filePath, token)
        : null;

    final finalContent = existingContent != null
        ? '$existingContent\n\n$content'
        : content;

    final encoded = base64Encode(utf8.encode(finalContent));

    final data = <String, dynamic>{
      'message': 'Add $weekLabel bookmarks',
      'content': encoded,
    };
    if (sha != null) {
      data['sha'] = sha;
    }

    try {
      final response = await _dio.put(
        '/repos/$repo/contents/$filePath',
        data: data,
        options: _authOptions(token),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}

class GitHubRepo {
  final String fullName;
  final String name;
  GitHubRepo({required this.fullName, required this.name});
}

class GitHubContentItem {
  final String name;
  final String path;
  final String type; // 'dir' or 'file'
  GitHubContentItem(
      {required this.name, required this.path, required this.type});
}
