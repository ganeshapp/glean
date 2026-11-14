import 'package:dio/dio.dart';

class GitHubAppConfig {
  static const clientId = String.fromEnvironment(
    'GITHUB_CLIENT_ID',
    defaultValue: 'Ov23liRaL0nYAN77ycqb',
  );
  static const scope = 'public_repo';
}

class DeviceCode {
  final String deviceCode, userCode;
  final int interval, expiresIn;
  const DeviceCode(
    this.deviceCode,
    this.userCode,
    this.interval,
    this.expiresIn,
  );
}

class GitHubOAuthService {
  final Dio dio;
  GitHubOAuthService({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://github.com',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );
  Options get options => Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {'Accept': 'application/json'},
  );

  Future<DeviceCode> start() async {
    final response = await dio.post(
      '/login/device/code',
      options: options,
      data: {
        'client_id': GitHubAppConfig.clientId,
        'scope': GitHubAppConfig.scope,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['device_code'] is! String) {
      throw StateError(_message(data['error']));
    }
    return DeviceCode(
      data['device_code'],
      data['user_code'],
      data['interval'] ?? 5,
      data['expires_in'] ?? 900,
    );
  }

  Future<Map<String, dynamic>?> poll(
    DeviceCode code, {
    required bool Function() cancelled,
    Future<void> Function(Duration)? wait,
    DateTime Function()? now,
  }) async {
    final clock = now ?? DateTime.now;
    final deadline = clock().add(Duration(seconds: code.expiresIn));
    final delay = wait ?? Future<void>.delayed;
    var interval = code.interval < 1 ? 1 : code.interval;
    var waited = 0;
    while (!cancelled()) {
      if (!clock().isBefore(deadline) || waited + interval >= code.expiresIn) {
        throw StateError('The code expired. Start sign-in again.');
      }
      await delay(Duration(seconds: interval));
      waited += interval;
      if (cancelled()) return null;
      if (!clock().isBefore(deadline)) {
        throw StateError('The code expired. Start sign-in again.');
      }
      final response = await dio.post(
        '/login/oauth/access_token',
        options: options,
        data: {
          'client_id': GitHubAppConfig.clientId,
          'device_code': code.deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      );
      if (cancelled()) return null;
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['access_token'] is String) return data;
      switch (data['error']) {
        case 'authorization_pending':
          break;
        case 'slow_down':
          interval += 5;
        default:
          throw StateError(_message(data['error']));
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await dio.post(
      '/login/oauth/access_token',
      options: options,
      data: {
        'client_id': GitHubAppConfig.clientId,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['access_token'] is! String) {
      throw StateError('Your GitHub session expired. Please reconnect.');
    }
    return data;
  }

  static String _message(dynamic error) => switch (error) {
    'access_denied' => 'Sign-in was declined on GitHub.',
    'expired_token' => 'The code expired. Start sign-in again.',
    'device_flow_disabled' =>
      'Enable Device Flow in the Glean OAuth app settings on GitHub.',
    'incorrect_client_credentials' =>
      'GitHub did not recognize the Glean client ID.',
    _ => 'GitHub sign-in could not finish. Please try again.',
  };
}
