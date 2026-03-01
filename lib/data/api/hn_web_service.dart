import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html/parser.dart' as html_parser;

import '../../core/constants/hn_constants.dart';

class HnWebService {
  final Dio _dio;
  final CookieJar _cookieJar;
  final FlutterSecureStorage _storage;

  HnWebService({
    Dio? dio,
    CookieJar? cookieJar,
    FlutterSecureStorage? storage,
  })  : _cookieJar = cookieJar ?? CookieJar(),
        _storage = storage ?? const FlutterSecureStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: HnConstants.webBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              followRedirects: false,
              validateStatus: (status) => status != null && status < 400,
            )) {
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<bool> login(String username, String password) async {
    try {
      await _dio.post(
        '/login',
        data: 'acct=$username&pw=$password',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final cookies = await _cookieJar
          .loadForRequest(Uri.parse(HnConstants.webBaseUrl));
      final userCookie = cookies.where((c) => c.name == 'user').firstOrNull;

      if (userCookie != null) {
        await _storage.write(key: 'hn_cookie', value: userCookie.value);
        await _storage.write(key: 'hn_username', value: username);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'hn_cookie');
    await _storage.delete(key: 'hn_username');
    _cookieJar.deleteAll();
  }

  Future<String?> getLoggedInUsername() async {
    return _storage.read(key: 'hn_username');
  }

  Future<bool> isLoggedIn() async {
    final cookie = await _storage.read(key: 'hn_cookie');
    return cookie != null && cookie.isNotEmpty;
  }

  Future<String?> _fetchAuthToken(int itemId) async {
    try {
      final response = await _dio.get('/item?id=$itemId');
      final doc = html_parser.parse(response.data as String);
      final voteLink = doc.querySelector('a[id="up_$itemId"]');
      if (voteLink != null) {
        final href = voteLink.attributes['href'] ?? '';
        final authMatch = RegExp(r'auth=([a-f0-9]+)').firstMatch(href);
        return authMatch?.group(1);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> upvote(int itemId) async {
    final auth = await _fetchAuthToken(itemId);
    if (auth == null) return false;
    try {
      await _dio.get('/vote?id=$itemId&how=up&auth=$auth');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> downvote(int itemId) async {
    final auth = await _fetchAuthToken(itemId);
    if (auth == null) return false;
    try {
      await _dio.get('/vote?id=$itemId&how=down&auth=$auth');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _fetchReplyHmac(int parentId) async {
    try {
      final response = await _dio.get('/reply?id=$parentId');
      final doc = html_parser.parse(response.data as String);
      final hmacInput = doc.querySelector('input[name="hmac"]');
      return hmacInput?.attributes['value'];
    } catch (_) {
      return null;
    }
  }

  Future<bool> reply(int parentId, String text) async {
    final hmac = await _fetchReplyHmac(parentId);
    if (hmac == null) return false;
    try {
      await _dio.post(
        '/comment',
        data: 'parent=$parentId&text=${Uri.encodeComponent(text)}&hmac=$hmac',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
