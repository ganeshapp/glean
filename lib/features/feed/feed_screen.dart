import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../auth/auth_provider.dart';
import '../share_receiver/share_handler.dart';
import 'feed_provider.dart';
import 'widgets/feed_category_drawer.dart';
import 'widgets/story_card.dart';
import 'widgets/typography_bar.dart';

enum FeedCategory {
  top('Top', Icons.whatshot),
  newest('New', Icons.bolt),
  ask('Ask HN', Icons.help_outline),
  show('Show HN', Icons.play_circle_outline),
  jobs('Jobs', Icons.work_outline);

  const FeedCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  FeedCategory _category = FeedCategory.top;
  final ScrollController _scrollController = ScrollController();
  ShareHandler? _shareHandler;
  bool _showTypography = false;

  // For draggable FAB
  Offset? _fabPosition;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    loadTypographyPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedNotifierProvider.notifier).loadCategory(_category);
      ref.read(authNotifierProvider.notifier).checkAuth();
      _shareHandler = ShareHandler(ref, context);
      _shareHandler!.init();
    });
  }

  @override
  void dispose() {
    _shareHandler?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedNotifierProvider.notifier).loadMore();
    }
  }

  void _onCategorySelected(FeedCategory category) {
    setState(() => _category = category);
    Navigator.pop(context);
    ref.read(feedNotifierProvider.notifier).loadCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedNotifierProvider);

    return Scaffold(
      drawer: FeedCategoryDrawer(
        selectedCategory: _category,
        onCategorySelected: _onCategorySelected,
      ),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                title: const Text('Glean'),
                floating: true,
                snap: true,
                forceElevated: innerBoxIsScrolled,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => context.push('/search'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        ref.read(feedNotifierProvider.notifier).refresh(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_fields),
                    onPressed: () =>
                        setState(() => _showTypography = !_showTypography),
                  ),
                ],
              ),
              if (_showTypography)
                SliverToBoxAdapter(
                  child: TypographyBar(
                    onDone: () =>
                        setState(() => _showTypography = false),
                  ),
                ),
            ],
            body: _buildBody(feedState),
          ),
          _buildDraggableFab(),
        ],
      ),
    );
  }

  Widget _buildDraggableFab() {
    final size = MediaQuery.of(context).size;
    _fabPosition ??= Offset(size.width / 2 - 24, size.height - 140);

    return Positioned(
      left: _fabPosition!.dx,
      top: _fabPosition!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _fabPosition = Offset(
              (_fabPosition!.dx + details.delta.dx)
                  .clamp(0, size.width - 56),
              (_fabPosition!.dy + details.delta.dy)
                  .clamp(0, size.height - 56),
            );
          });
        },
        child: FloatingActionButton.small(
          heroTag: 'scrollFab',
          onPressed: () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
              );
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildBody(FeedState state) {
    if (state.error != null && state.stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Failed to load stories',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(feedNotifierProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isLoading && state.stories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
      child: ValueListenableBuilder<TypographySettings>(
        valueListenable: typographyNotifier,
        builder: (context, typo, _) {
          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.stories.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              if (index >= state.stories.length) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              return StoryCard(
                story: state.stories[index],
                fontSize: typo.fontSize,
                lineHeight: typo.lineHeight,
              );
            },
          );
        },
      ),
    );
  }
}
