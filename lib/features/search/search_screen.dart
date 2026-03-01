import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/api/algolia_service.dart';
import '../../data/models/search_result.dart';
import 'search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search stories...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          onSubmitted: (query) {
            ref.read(searchNotifierProvider.notifier).search(query);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ref
                  .read(searchNotifierProvider.notifier)
                  .search(_controller.text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(state),
          const Divider(height: 1),
          Expanded(child: _buildResults(state)),
        ],
      ),
    );
  }

  Widget _buildFilters(SearchState state) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          DropdownButton<SearchTimeRange>(
            value: state.timeRange,
            dropdownColor: AppColors.surfaceElevated,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            underline: const SizedBox.shrink(),
            items: SearchTimeRange.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(searchNotifierProvider.notifier).setTimeRange(v);
              }
            },
          ),
          const Spacer(),
          DropdownButton<SearchSortOrder>(
            value: state.sortOrder,
            dropdownColor: AppColors.surfaceElevated,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            underline: const SizedBox.shrink(),
            items: SearchSortOrder.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(searchNotifierProvider.notifier).setSortOrder(v);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState state) {
    if (state.isLoading && state.results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.results.isEmpty && state.query.isNotEmpty && !state.isLoading) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    if (state.results.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: state.results.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        if (index >= state.results.length) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final hit = state.results[index];
        return _SearchResultCard(hit: hit);
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.hit});

  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (hit.url != null && hit.url!.isNotEmpty) {
          final uri = Uri.parse(hit.url!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '+ ${hit.points}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppDateUtils.timeAgo(hit.dateTime),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hit.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (hit.domain != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      hit.domain!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => context.push('/comments/${hit.objectId}'),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 20, color: AppColors.textSecondary),
                    const SizedBox(height: 2),
                    Text(
                      '${hit.numComments}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
