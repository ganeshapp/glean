import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'read_story_ids';

class ReadStateNotifier extends StateNotifier<Set<int>> {
  ReadStateNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefsKey) ?? [];
    state = ids.map(int.parse).toSet();
  }

  Future<void> markRead(int storyId) async {
    if (state.contains(storyId)) return;
    state = {...state, storyId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsKey, state.map((id) => id.toString()).toList());
  }

  bool isRead(int storyId) => state.contains(storyId);
}

final readStateProvider =
    StateNotifierProvider<ReadStateNotifier, Set<int>>((ref) {
  return ReadStateNotifier();
});
