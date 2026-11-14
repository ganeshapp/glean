import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/content_utils.dart';
import '../../core/utils/markdown_generator.dart';
import '../../core/utils/week_utils.dart';
import '../../data/api/github_service.dart';
import '../../data/database/app_database.dart';
import '../bookmarks/bookmark_provider.dart';
import '../bookmarks/bookmarks_screen.dart';
import 'publish_provider.dart';
import 'roundup_provider.dart';

class PublishScreen extends ConsumerStatefulWidget {
  final String? issueId;
  const PublishScreen({super.key, this.issueId});
  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  bool busy = false;
  String? message;
  @override
  Widget build(BuildContext context) {
    final current = ref.watch(currentIssueProvider);
    final id = widget.issueId ?? current.valueOrNull?.id;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('This week')),
        body: Center(
          child:
              current.hasError
                  ? const Text('Could not open the draft.')
                  : const CircularProgressIndicator(),
        ),
      );
    }
    final issue = ref.watch(issueProvider(id));
    final cards = ref.watch(issueCardsProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.issueId == null ? 'This week' : 'Roundup'),
        actions: [
          IconButton(
            tooltip: 'Issue history',
            onPressed: () => history(),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Publishing settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: issue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, _) => const Center(child: Text('Could not open this issue.')),
        data:
            (draft) => cards.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, _) =>
                      const Center(child: Text('Could not load the cards.')),
              data:
                  (list) => Column(
                    children: [
                      ListTile(
                        title: Text(
                          draft.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          '${WeekUtils.weekDateRange(draft.date)} · ${list.length} items\n${draft.publishedAt == null
                              ? 'Draft saved on this device'
                              : draft.publishedRevision == draft.revision
                              ? 'Uploaded to GitHub'
                              : 'Changes saved · update available'}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          tooltip: 'Edit title and opening',
                          onPressed: busy ? null : () => editHeader(draft),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ),
                      if (draft.introduction.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              draft.introduction,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (message != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(message!),
                        ),
                      if (draft.publishedAt != null && draft.publicUrl != null)
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed:
                                  () => launchUrl(
                                    Uri.parse(draft.publicUrl!),
                                    mode: LaunchMode.externalApplication,
                                  ),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open published issue'),
                            ),
                            TextButton(
                              onPressed: busy ? null : () => checkLive(draft),
                              child: const Text('Check live page'),
                            ),
                          ],
                        ),
                      Expanded(
                        child:
                            list.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.view_agenda_outlined,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Build this week’s roundup one item at a time.',
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Add saved items, drag them into any order, and tap a card to edit what readers will see.',
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        FilledButton.icon(
                                          onPressed:
                                              () => addItems(draft, list),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add saved items'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : ReorderableListView.builder(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: list.length,
                                  buildDefaultDragHandles: false,
                                  onReorder: (oldIndex, newIndex) async {
                                    if (busy) return;
                                    final ids = list.map((c) => c.id).toList();
                                    if (newIndex > oldIndex) newIndex--;
                                    ids.insert(
                                      newIndex,
                                      ids.removeAt(oldIndex),
                                    );
                                    await run(
                                      () => ref
                                          .read(roundupRepositoryProvider)
                                          .reorder(draft.id, ids),
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    final card = list[index];
                                    return Card(
                                      key: ValueKey(card.id),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        onTap:
                                            busy ? null : () => editCard(card),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      typeLabel(card.type),
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .labelSmall,
                                                    ),
                                                  ),
                                                  PopupMenuButton<String>(
                                                    enabled: !busy,
                                                    tooltip: 'Card actions',
                                                    onSelected: (action) async {
                                                      if (action == 'remove') {
                                                        await run(
                                                          () => ref
                                                              .read(
                                                                roundupRepositoryProvider,
                                                              )
                                                              .removeCard(card),
                                                        );
                                                      } else {
                                                        final ids =
                                                            list
                                                                .map(
                                                                  (c) => c.id,
                                                                )
                                                                .toList();
                                                        final target =
                                                            action == 'up'
                                                                ? index - 1
                                                                : index + 1;
                                                        if (target >= 0 &&
                                                            target <
                                                                ids.length) {
                                                          ids.insert(
                                                            target,
                                                            ids.removeAt(index),
                                                          );
                                                          await run(
                                                            () => ref
                                                                .read(
                                                                  roundupRepositoryProvider,
                                                                )
                                                                .reorder(
                                                                  draft.id,
                                                                  ids,
                                                                ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    itemBuilder:
                                                        (_) => [
                                                          if (index > 0)
                                                            const PopupMenuItem(
                                                              value: 'up',
                                                              child: Text(
                                                                'Move up',
                                                              ),
                                                            ),
                                                          if (index <
                                                              list.length - 1)
                                                            const PopupMenuItem(
                                                              value: 'down',
                                                              child: Text(
                                                                'Move down',
                                                              ),
                                                            ),
                                                          const PopupMenuItem(
                                                            value: 'remove',
                                                            child: Text(
                                                              'Remove from issue',
                                                            ),
                                                          ),
                                                        ],
                                                  ),
                                                  ReorderableDragStartListener(
                                                    index: index,
                                                    enabled: !busy,
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(
                                                        8,
                                                      ),
                                                      child: Icon(
                                                        Icons.drag_handle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                card.title.isNotEmpty
                                                    ? card.title
                                                    : card.excerpt.isNotEmpty
                                                    ? card.excerpt
                                                    : card.url,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),
                                              if (card.author.isNotEmpty)
                                                Text('— ${card.author}'),
                                              const SizedBox(height: 8),
                                              Text(
                                                card.blurb.isEmpty
                                                    ? 'Tap to add your public thought'
                                                    : card.blurb,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    card.blurb.isEmpty
                                                        ? Theme.of(
                                                          context,
                                                        ).textTheme.bodySmall
                                                        : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Add saved items',
                                onPressed:
                                    busy ? null : () => addItems(draft, list),
                                icon: const Icon(Icons.add),
                              ),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      list.isEmpty || busy
                                          ? null
                                          : () => preview(draft, list),
                                  child: const Text('Preview'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed:
                                      list.isEmpty || busy
                                          ? null
                                          : () => publish(draft, list),
                                  child:
                                      busy
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Text(
                                            draft.publishedAt == null
                                                ? 'Publish'
                                                : 'Update issue',
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
      ),
    );
  }

  Future<void> run(Future<void> Function() task) async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await task();
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              message =
                  e is StateError
                      ? e.message.toString()
                      : 'Could not save this change. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> editHeader(RoundupIssue issue) async {
    final title = TextEditingController(text: issue.title),
        intro = TextEditingController(text: issue.introduction);
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Issue opening'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    maxLines: null,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: intro,
                    minLines: 3,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Opening thought (optional)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (title.text.trim().isNotEmpty) Navigator.pop(ctx, true);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (ok == true && mounted) {
      await run(
        () => ref
            .read(roundupRepositoryProvider)
            .editIssue(issue.id, title.text, intro.text),
      );
    }
    title.dispose();
    intro.dispose();
  }

  Future<void> editCard(RoundupCard card) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RoundupCardEditor(card: card)));
  }

  Future<void> addItems(RoundupIssue issue, List<RoundupCard> cards) async {
    final all = await ref.read(bookmarkRepositoryProvider).getAll();
    if (!mounted) return;
    final included = cards.map((c) => c.bookmarkId).toSet();
    final chosen = <int>{};
    var query = '';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, update) {
              final list =
                  all
                      .where(
                        (b) =>
                            !b.archived &&
                            !included.contains(b.id) &&
                            [b.title, b.contentText, b.summary, b.contentUrl]
                                .whereType<String>()
                                .join(' ')
                                .toLowerCase()
                                .contains(query),
                      )
                      .toList();
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(ctx).size.height * .7,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Add saved items'),
                          subtitle: const Text(
                            'Most recent first. Older saves remain available.',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            onChanged:
                                (v) => update(() => query = v.toLowerCase()),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search saved items',
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                              list.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'No more matching saved items.',
                                    ),
                                  )
                                  : ListView(
                                    children:
                                        list
                                            .map(
                                              (b) => CheckboxListTile(
                                                value: chosen.contains(b.id),
                                                onChanged:
                                                    (v) => update(() {
                                                      v == true
                                                          ? chosen.add(b.id)
                                                          : chosen.remove(b.id);
                                                    }),
                                                title: Text(
                                                  b.title?.isNotEmpty == true
                                                      ? b.title!
                                                      : b.contentText ??
                                                          b.contentUrl ??
                                                          'Saved item',
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  b.summary ??
                                                      typeLabel(b.type),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: FilledButton(
                            onPressed:
                                chosen.isEmpty
                                    ? null
                                    : () => Navigator.pop(ctx, true),
                            child: Text('Add ${chosen.length} items'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
    if (ok == true && mounted) {
      await run(() async {
        for (final id in chosen) {
          await ref
              .read(roundupRepositoryProvider)
              .include(issue.id, all.firstWhere((b) => b.id == id));
        }
      });
    }
  }

  void preview(RoundupIssue issue, List<RoundupCard> cards) => Navigator.of(
    context,
  ).push(
    MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Reader preview')),
            body: Markdown(
              data:
                  '# ${MarkdownGenerator.text(issue.title)}\n\n${MarkdownGenerator.body(issue, cards)}',
              selectable: true,
              onTapLink: (_, url, _) {
                if (safeWebUrl(url) != null) {
                  launchUrl(
                    Uri.parse(url!),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          ),
    ),
  );

  Future<void> publish(RoundupIssue draft, List<RoundupCard> entries) async {
    final invalid = entries.any(
      (c) =>
          (c.url.isNotEmpty && safeWebUrl(c.url) == null) ||
          (c.discussionUrl.isNotEmpty && safeWebUrl(c.discussionUrl) == null),
    );
    if (invalid) {
      setState(
        () => message = 'Fix the source links in the cards before publishing.',
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              draft.publishedAt == null
                  ? 'Publish this roundup?'
                  : 'Update this roundup?',
            ),
            content: Text(
              '${entries.length} cards and their public text will be published to your configured website. Your private saved notes are excluded.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Publish'),
              ),
            ],
          ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final github = ref.read(githubServiceProvider),
          repo = ref.read(roundupRepositoryProvider);
      if (draft.remoteSha == null) {
        final destination = await github.getRepo(),
            folder = await github.getFolder(),
            branch = await github.getBranch(),
            site = await github.getSiteUrl();
        if (destination == null ||
            branch == null ||
            site == null ||
            folder == null) {
          throw StateError(
            'Choose your publishing destination in Settings first.',
          );
        }
        await repo.bindDestination(
          draft.id,
          repo: destination,
          path: '${folder.isEmpty ? '' : '$folder/'}${draft.id}.md',
          branch: branch,
          publicUrl: '$site/roundup/${draft.id}/',
        );
      }
      final publication = await repo.snapshot(draft.id);
      final snapshot = publication.issue;
      final cards = publication.cards;
      final result = await github.publish(
        repo: snapshot.repository!,
        path: snapshot.filePath!,
        branch: snapshot.branch!,
        content: MarkdownGenerator.document(snapshot, cards),
        expectedSha: snapshot.remoteSha,
      );
      await repo.recordPublication(snapshot, cards, result.sha);
      if (mounted) {
        setState(
          () =>
              message =
                  'Uploaded to GitHub. The website may take a moment to rebuild.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => message = friendlyGitHubError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> checkLive(RoundupIssue issue) async {
    await run(() async {
      try {
        final live = await ref
            .read(githubServiceProvider)
            .isLive(issue.publicUrl!, issue.id, issue.publishedRevision!);
        if (mounted) {
          setState(
            () =>
                message =
                    live
                        ? 'The uploaded version is live on your website.'
                        : 'The website has not served this version yet. Check again shortly.',
          );
        }
      } catch (_) {
        if (mounted) {
          setState(
            () =>
                message =
                    'Could not verify the live page yet. Your GitHub upload is saved.',
          );
        }
      }
    });
  }

  Future<void> history() => showModalBottomSheet(
    context: context,
    builder:
        (ctx) => Consumer(
          builder:
              (ctx, ref, _) => SafeArea(
                child: ref
                    .watch(issuesProvider)
                    .when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const Text('Could not load issues.'),
                      data:
                          (issues) => ListView(
                            children: [
                              const ListTile(title: Text('Roundup history')),
                              ...issues.map(
                                (i) => ListTile(
                                  title: Text(i.title),
                                  subtitle: Text(
                                    '${i.id} · ${i.publishedAt == null ? 'Draft' : 'Uploaded'}',
                                  ),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    context.push('/issue/${i.id}');
                                  },
                                ),
                              ),
                            ],
                          ),
                    ),
              ),
        ),
  );
}

class RoundupCardEditor extends ConsumerStatefulWidget {
  final RoundupCard card;
  const RoundupCardEditor({super.key, required this.card});
  @override
  ConsumerState<RoundupCardEditor> createState() => _RoundupCardEditorState();
}

class _RoundupCardEditorState extends ConsumerState<RoundupCardEditor> {
  late final title = TextEditingController(text: widget.card.title),
      url = TextEditingController(text: widget.card.url),
      excerpt = TextEditingController(text: widget.card.excerpt),
      author = TextEditingController(text: widget.card.author),
      blurb = TextEditingController(text: widget.card.blurb);
  String? savedThought, error;
  bool saving = false, dirty = false;
  int generation = 0;
  late RoundupCard persisted = widget.card;
  Future<void> writes = Future.value();
  @override
  void initState() {
    super.initState();
    loadThought();
    for (final c in [title, url, excerpt, author, blurb]) {
      c.addListener(saveChange);
    }
  }

  Future<void> loadThought() async {
    if (widget.card.bookmarkId == null) return;
    final b = await ref
        .read(bookmarkRepositoryProvider)
        .get(widget.card.bookmarkId!);
    if (mounted) setState(() => savedThought = b?.summary);
  }

  void saveChange() {
    final run = ++generation;
    final snapshot = widget.card.copyWith(
      title: title.text,
      url: url.text,
      excerpt: excerpt.text,
      author: author.text,
      blurb: blurb.text,
    );
    final repo = ref.read(roundupRepositoryProvider);
    setState(() {
      saving = true;
      dirty = true;
      error = null;
    });
    writes = writes
        .then((_) async {
          await repo.editCard(snapshot, previous: persisted);
          persisted = snapshot;
        })
        .then((_) {
          if (mounted && run == generation) {
            setState(() {
              saving = false;
              dirty = false;
            });
          }
        })
        .catchError((Object e) {
          if (mounted && run == generation) {
            setState(() {
              saving = false;
              error = 'Could not save. Tap Retry before leaving.';
            });
          }
        });
  }

  @override
  void dispose() {
    for (final c in [title, url, excerpt, author, blurb]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving && !dirty,
    onPopInvokedWithResult: (didPop, _) async {
      if (!didPop) {
        await writes;
        await WidgetsBinding.instance.endOfFrame;
        if (context.mounted && !dirty && !saving) Navigator.pop(context);
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Edit roundup card'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              saving
                  ? 'Saving…'
                  : error != null
                  ? 'Not saved'
                  : 'Saved',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null)
            ListTile(
              title: Text(error!),
              trailing: TextButton(
                onPressed: saveChange,
                child: const Text('Retry'),
              ),
            ),
          const Text(
            'Everything on this card is public when you publish the issue.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: title,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Title (optional for quotes)',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: blurb,
            minLines: 4,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Your public thought',
              hintText: 'What makes this worth sharing?',
            ),
          ),
          if (savedThought?.isNotEmpty == true)
            TextButton.icon(
              onPressed: () => blurb.text = savedThought!,
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Use my saved thought as public text'),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: excerpt,
            minLines: 3,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Source excerpt / quote',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: author,
            decoration: const InputDecoration(
              labelText: 'Author / attribution',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Source URL'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
