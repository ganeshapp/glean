import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/hn_api_service.dart';
import '../../data/models/hn_comment.dart';
import '../../data/models/hn_story.dart';
import '../feed/feed_provider.dart';

class CommentNode {
  final HnComment comment;
  List<CommentNode> children;
  final int depth;
  bool isCollapsed;

  CommentNode({
    required this.comment,
    List<CommentNode>? children,
    this.depth = 0,
    this.isCollapsed = false,
  }) : children = children ?? [];

  int get totalChildCount {
    int count = children.length;
    for (final child in children) {
      count += child.totalChildCount;
    }
    return count;
  }
}

class CommentsState {
  final HnStory? story;
  final List<CommentNode> commentTree;
  final bool isLoading;
  final String? error;

  const CommentsState({
    this.story,
    this.commentTree = const [],
    this.isLoading = false,
    this.error,
  });

  CommentsState copyWith({
    HnStory? story,
    List<CommentNode>? commentTree,
    bool? isLoading,
    String? error,
  }) {
    return CommentsState(
      story: story ?? this.story,
      commentTree: commentTree ?? this.commentTree,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final HnApiService _api;
  final int storyId;
  bool _disposed = false;

  CommentsNotifier(this._api, this.storyId) : super(const CommentsState());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    _disposed = false;
    state = const CommentsState(isLoading: true);
    try {
      final story = await _api.getStory(storyId);
      if (_disposed) return;
      if (story == null) {
        state = const CommentsState(error: 'Story not found');
        return;
      }

      state = CommentsState(story: story, isLoading: true);

      final topComments = await _fetchBatch(story.kids);
      if (_disposed) return;

      final nodes = topComments
          .map((c) => CommentNode(comment: c, depth: 0))
          .toList();

      state = CommentsState(story: story, commentTree: nodes);

      await _loadNextLevel(nodes);
    } catch (e) {
      if (!_disposed) {
        state = CommentsState(
          story: state.story,
          commentTree: state.commentTree,
          error: e.toString(),
        );
      }
    }
  }

  Future<List<HnComment>> _fetchBatch(List<int> ids) async {
    if (ids.isEmpty) return [];
    final results = <HnComment>[];
    const batchSize = 20;
    for (var i = 0; i < ids.length; i += batchSize) {
      if (_disposed) return results;
      final batch = ids.sublist(i, (i + batchSize).clamp(0, ids.length));
      final futures = batch.map((id) => _api.getComment(id));
      final fetched = await Future.wait(futures);
      results.addAll(
        fetched.whereType<HnComment>().where((c) => !c.deleted && !c.dead),
      );
    }
    return results;
  }

  Future<void> _loadNextLevel(List<CommentNode> nodes) async {
    if (_disposed) return;

    final allKidIds = <int>[];
    final parentMap = <int, CommentNode>{};
    for (final node in nodes) {
      for (final kidId in node.comment.kids) {
        allKidIds.add(kidId);
        parentMap[kidId] = node;
      }
    }
    if (allKidIds.isEmpty) return;

    final children = await _fetchBatch(allKidIds);
    if (_disposed) return;

    final childMap = <int, HnComment>{};
    for (final c in children) {
      childMap[c.id] = c;
    }

    final nextLevel = <CommentNode>[];
    for (final node in nodes) {
      final childNodes = node.comment.kids
          .where((id) => childMap.containsKey(id))
          .map((id) => CommentNode(
                comment: childMap[id]!,
                depth: node.depth + 1,
              ))
          .toList();
      node.children = childNodes;
      nextLevel.addAll(childNodes);
    }

    if (!_disposed) {
      state = state.copyWith(commentTree: List.from(state.commentTree));
    }

    await _loadNextLevel(nextLevel);
  }

  void toggleCollapse(int commentId) {
    final newTree = _toggleInTree(state.commentTree, commentId);
    state = state.copyWith(commentTree: newTree);
  }

  List<CommentNode> _toggleInTree(List<CommentNode> nodes, int id) {
    return nodes.map((node) {
      if (node.comment.id == id) {
        return CommentNode(
          comment: node.comment,
          children: node.children,
          depth: node.depth,
          isCollapsed: !node.isCollapsed,
        );
      }
      return CommentNode(
        comment: node.comment,
        children: _toggleInTree(node.children, id),
        depth: node.depth,
        isCollapsed: node.isCollapsed,
      );
    }).toList();
  }
}

final commentsNotifierProvider = StateNotifierProvider.family<
    CommentsNotifier, CommentsState, int>((ref, storyId) {
  final api = ref.watch(hnApiServiceProvider);
  return CommentsNotifier(api, storyId);
});
