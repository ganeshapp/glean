import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database/app_database.dart';
import '../capture/save_actions.dart';
import 'bookmark_provider.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});
  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String query = '';
  String filter = 'Saved';
  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(bookmarksStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        actions: [
          IconButton(
            tooltip: 'Settings and backup',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => query = v.toLowerCase()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search titles, excerpts, and your thoughts',
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children:
                  ['Saved', 'With thoughts', 'Archived']
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: filter == f,
                            onSelected: (_) => setState(() => filter = f),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          Expanded(
            child: bookmarks.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, _) =>
                      const Center(child: Text('Could not load saved items.')),
              data: (all) {
                final list =
                    all
                        .where(
                          (b) =>
                              b.archived == (filter == 'Archived') &&
                              (filter != 'With thoughts' ||
                                  (b.summary?.isNotEmpty ?? false)) &&
                              [
                                    b.title,
                                    b.contentText,
                                    b.summary,
                                    b.domain,
                                    b.author,
                                    b.contentUrl,
                                  ]
                                  .whereType<String>()
                                  .join(' ')
                                  .toLowerCase()
                                  .contains(query),
                        )
                        .toList();
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        query.isNotEmpty
                            ? 'No matches. Try another search.'
                            : filter == 'Archived'
                            ? 'Archived items appear here.'
                            : 'Save from HN or share a link from another app. Add a thought whenever you want.',
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => card(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget card(BookmarksTableData b) => Dismissible(
    key: ValueKey('${b.id}-${b.archived}'),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.all(20),
      child: Icon(b.archived ? Icons.unarchive : Icons.archive),
    ),
    confirmDismiss: (_) async {
      await archive(b);
      return false;
    },
    child: Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: InkWell(
        onTap: () => context.push('/saved/${b.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${typeLabel(b.type)}${b.domain == null ? '' : ' · ${b.domain}'}${b.isPublished ? ' · Published' : ''}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 6),
              Text(
                b.title?.isNotEmpty == true
                    ? b.title!
                    : b.contentText ?? b.contentUrl ?? 'Saved excerpt',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (b.summary?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    b.summary!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/saved/${b.id}'),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      b.summary?.isNotEmpty == true
                          ? 'Edit thought'
                          : 'Add thought',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await SaveActions.includeThisWeek(ref, b.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Included in this week’s draft'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.playlist_add, size: 18),
                    label: const Text('This week'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Future<void> archive(BookmarksTableData b) async {
    await ref.read(bookmarkRepositoryProvider).archive(b.id, !b.archived);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(b.archived ? 'Restored' : 'Archived'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed:
                () => ref
                    .read(bookmarkRepositoryProvider)
                    .archive(b.id, b.archived),
          ),
        ),
      );
    }
  }
}

String typeLabel(String type) => switch (type) {
  'hnArticle' => 'HN article',
  'hnComment' => 'HN comment',
  'tweet' => 'Post',
  'video' => 'Video',
  _ => 'Web',
};
