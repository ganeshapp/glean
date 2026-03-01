import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/hn_web_service.dart';
import '../../data/repositories/auth_repository.dart';

final hnWebServiceProvider = Provider<HnWebService>((ref) => HnWebService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(web: ref.watch(hnWebServiceProvider));
});

class AuthState {
  final String? username;
  final bool isLoading;
  final String? error;

  const AuthState({this.username, this.isLoading = false, this.error});

  bool get isLoggedIn => username != null && username!.isNotEmpty;

  AuthState copyWith({String? username, bool? isLoading, String? error}) {
    return AuthState(
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<void> checkAuth() async {
    final username = await _repo.getLoggedInUsername();
    state = AuthState(username: username);
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true);
    final success = await _repo.login(username, password);
    if (success) {
      state = AuthState(username: username);
      return true;
    }
    state = const AuthState(error: 'Login failed. Check your credentials.');
    return false;
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
