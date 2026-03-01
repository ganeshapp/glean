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
