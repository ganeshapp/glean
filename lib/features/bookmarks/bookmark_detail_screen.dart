import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/content_utils.dart';
import '../../data/database/app_database.dart';
import '../publish/roundup_provider.dart';
import 'bookmark_provider.dart';

class BookmarkDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const BookmarkDetailScreen({super.key, required this.id});
  @override
  ConsumerState<BookmarkDetailScreen> createState() =>
      _BookmarkDetailScreenState();
}

class _BookmarkDetailScreenState extends ConsumerState<BookmarkDetailScreen> {
  final title = TextEditingController(),
      url = TextEditingController(),
      excerpt = TextEditingController(),
      note = TextEditingController();
  BookmarksTableData? item;
  String? error;
  bool saving = false, changed = false;
  Future<bool> writes = Future.value(true);
  int generation = 0;
  late List<String> persisted;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final b = await ref.read(bookmarkRepositoryProvider).get(widget.id);
      if (!mounted) return;
      setState(() {
        item = b;
        if (b == null) {
          error = 'This saved item is no longer available.';
          return;
        }
        title.text = b.title ?? '';
        url.text = b.contentUrl ?? '';
        excerpt.text = b.contentText ?? '';
        note.text = b.summary ?? '';
        persisted = values;
      });
      for (final c in [title, url, excerpt, note]) {
        c.addListener(() {
          if (mounted) {
            setState(() => changed = true);
            unawaited(save());
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load this saved item.');
    }
  }

  @override
  void dispose() {
    for (final c in [title, url, excerpt, note]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get values => [title.text, url.text, excerpt.text, note.text];

  Future<bool> save() {
    if (item == null) return Future.value(false);
    final snapshot = values;
    final revision = ++generation;
    final repo = ref.read(bookmarkRepositoryProvider);
    setState(() {
      saving = true;
      error = null;
    });
    writes = writes.then((_) async {
      try {
        await repo.updateDetails(
          widget.id,
          title: snapshot[0] == persisted[0] ? null : snapshot[0],
          url: snapshot[1] == persisted[1] ? null : snapshot[1],
          text: snapshot[2] == persisted[2] ? null : snapshot[2],
          note: snapshot[3] == persisted[3] ? null : snapshot[3],
        );
        persisted = snapshot;
        if (mounted && revision == generation) {
          setState(() {
            saving = false;
            changed = false;
          });
        }
        return true;
      } catch (_) {
        if (mounted && revision == generation) {
          setState(() {
            saving = false;
            error = 'Could not save your changes. Please try again.';
          });
        }
        return false;
      }
    });
    return writes;
  }

  Future<void> include() async {
    if (url.text.trim().isNotEmpty && safeWebUrl(url.text) == null) {
      setState(() => error = 'Enter a valid http or https source URL.');
      return;
    }
    if (!await save()) return;
    final b = await ref.read(bookmarkRepositoryProvider).get(widget.id);
    final issue = await ref.read(roundupRepositoryProvider).ensureWeek();
    if (b != null) {
      await ref.read(roundupRepositoryProvider).include(issue.id, b);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Included in this week’s draft. Edit the public text there.',
          ),
        ),
      );
    }
  }

  Future<void> leave() async {
    if (!changed || await save()) {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !changed && !saving,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) leave();
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Saved item'),
        actions: [
          TextButton(
            onPressed:
                saving
                    ? null
                    : () async {
                      if (await save() && context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Saved')));
                      }
                    },
            child: Text(
              saving
                  ? 'Saving…'
                  : changed
                  ? 'Retry save'
                  : 'Saved',
            ),
          ),
        ],
      ),
      body:
          item == null
              ? Center(
                child:
                    error == null
                        ? const CircularProgressIndicator()
                        : Text(error!),
              )
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  TextField(
                    controller: title,
                    maxLines: null,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: note,
                    minLines: 3,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Why did this catch your attention?',
                      helperText:
                          'Private note. Choose what to share in the roundup editor.',
                      hintText: 'A thought, a question, a video timestamp…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: saving ? null : include,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Include this week'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (safeWebUrl(url.text) != null)
                        OutlinedButton.icon(
                          onPressed:
                              () => launchUrl(
                                Uri.parse(url.text),
                                mode: LaunchMode.externalApplication,
                              ),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open source'),
                        ),
                      if (item!.hnUrl != null)
                        OutlinedButton(
                          onPressed: () {
                            final id =
                                Uri.tryParse(
                                  item!.hnUrl!,
                                )?.queryParameters['id'];
                            if (id != null) context.push('/comments/$id');
                          },
                          child: const Text('HN discussion'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: excerpt,
                    minLines: 3,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Source excerpt',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: url,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(labelText: 'Source URL'),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () async {
                      if (!await save()) return;
                      await ref
                          .read(bookmarkRepositoryProvider)
                          .archive(widget.id, !item!.archived);
                      await WidgetsBinding.instance.endOfFrame;
                      if (context.mounted) context.pop();
                    },
                    icon: const Icon(Icons.archive_outlined),
                    label: Text(
                      item!.archived ? 'Restore to saved' : 'Archive item',
                    ),
                  ),
                ],
              ),
    ),
  );
}
