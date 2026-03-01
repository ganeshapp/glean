import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/hn_api_service.dart';
import '../../data/models/hn_comment.dart';
import '../../data/models/hn_story.dart';
import '../feed/feed_provider.dart';

class CommentNode {
  final HnComment comment;
  final List<CommentNode> children;
  final int depth;
  bool isCollapsed;

  CommentNode({
    required this.comment,
    this.children = const [],
    this.depth = 0,
    this.isCollapsed = false,
  });

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

  CommentsNotifier(this._api, this.storyId) : super(const CommentsState());

  Future<void> load() async {
    state = const CommentsState(isLoading: true);
    try {
      final story = await _api.getStory(storyId);
      if (story == null) {
        state = const CommentsState(error: 'Story not found');
        return;
      }

      final tree = await _buildCommentTree(story.kids, 0);
      state = CommentsState(story: story, commentTree: tree);
    } catch (e) {
      state = CommentsState(error: e.toString());
    }
  }

  Future<List<CommentNode>> _buildCommentTree(
      List<int> ids, int depth) async {
    if (ids.isEmpty) return [];

    final futures = ids.map((id) => _api.getComment(id));
    final comments = await Future.wait(futures);
    final nodes = <CommentNode>[];

    for (final comment in comments) {
      if (comment == null || comment.deleted || comment.dead) continue;
      final children = await _buildCommentTree(comment.kids, depth + 1);
      nodes.add(CommentNode(
        comment: comment,
        children: children,
        depth: depth,
      ));
    }

    return nodes;
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
