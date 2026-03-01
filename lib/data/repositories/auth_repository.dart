import '../api/hn_web_service.dart';

class AuthRepository {
  final HnWebService _web;

  AuthRepository({HnWebService? web}) : _web = web ?? HnWebService();

  Future<bool> login(String username, String password) =>
      _web.login(username, password);

  Future<void> logout() => _web.logout();

  Future<String?> getLoggedInUsername() => _web.getLoggedInUsername();

  Future<bool> isLoggedIn() => _web.isLoggedIn();

  Future<bool> upvote(int itemId) => _web.upvote(itemId);

  Future<bool> downvote(int itemId) => _web.downvote(itemId);

  Future<bool> reply(int parentId, String text) => _web.reply(parentId, text);
}
