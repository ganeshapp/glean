import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/api/comment_export_service.dart';
import '../../data/database/app_database.dart';
import '../bookmarks/bookmark_provider.dart';
import 'export_jobs.dart';

class ExportsScreen extends ConsumerStatefulWidget {
  const ExportsScreen({super.key});
  @override
  ConsumerState<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends ConsumerState<ExportsScreen> {
  Timer? timer;
  List<CommentExport>? jobs;
  String? error;
  ExportJobs get store => ExportJobs(ref.read(appDatabaseProvider));
  @override
  void initState() {
    super.initState();
    refresh();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => refresh());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    try {
      final list = await store.list();
      if (mounted) setState(() => jobs = list);
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load exports.');
    }
  }

  Future<void> share(CommentExport job) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/hn-${job.id}.json');
      await file.writeAsString(job.jsonContent!, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: job.title,
        text: CommentExportService.analysisPrompt,
      );
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              error =
                  'Could not share the JSON file. Try saving or sharing again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Comment exports'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body:
        jobs == null
            ? Center(
              child:
                  error == null
                      ? const CircularProgressIndicator()
                      : Text(error!),
            )
            : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Download ranked HN discussions, then share the JSON with an AI app to explore insights and interesting angles. HN does not expose comment vote totals.',
                ),
                const SizedBox(height: 12),
                if (error != null) Text(error!),
                if (jobs!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'Open a story’s comments and choose “Export discussion for AI” from the menu.',
                    ),
                  ),
                ...jobs!.map((job) {
                  final data =
                      job.jsonContent == null
                          ? null
                          : jsonDecode(job.jsonContent!) as Map;
                  final selection = data?['selection'] as Map?;
                  return Card(
                    margin: const EdgeInsets.only(top: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete export',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text(
                                            'Delete this export?',
                                          ),
                                          content: const Text(
                                            'The downloaded JSON will be removed. Your bookmarks are unchanged.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (ok == true) {
                                    await store.delete(job.id);
                                    await refresh();
                                  }
                                },
                              ),
                            ],
                          ),
                          Text(
                            job.status == 'ready'
                                ? '${selection?['fetched_comment_count'] ?? 0} comments · ${job.depth} reply levels${selection?['truncated'] == true ? ' · Limited sample' : ''}'
                                : '${job.status} · ${job.depth} reply levels',
                          ),
                          if (job.error != null) Text(job.error!),
                          if ([
                            'queued',
                            'running',
                            'retrying',
                          ].contains(job.status))
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: LinearProgressIndicator(),
                            ),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (job.status == 'ready') ...[
                                FilledButton.icon(
                                  onPressed: () => share(job),
                                  icon: const Icon(Icons.ios_share),
                                  label: const Text('Share JSON'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      const ClipboardData(
                                        text:
                                            CommentExportService.analysisPrompt,
                                      ),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Insight prompt copied',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Copy insight prompt'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder:
                                            (ctx) => SafeArea(
                                              child: SizedBox(
                                                height:
                                                    MediaQuery.of(
                                                      ctx,
                                                    ).size.height *
                                                    .8,
                                                child: SingleChildScrollView(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: SelectableText(
                                                    job.jsonContent!,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ),
                                  child: const Text('Inspect JSON'),
                                ),
                              ] else
                                TextButton(
                                  onPressed: () async {
                                    await store.retry(job.id);
                                    await refresh();
                                  },
                                  child: const Text('Retry'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
  );
}

Future<void> queueDiscussionExport(
  BuildContext context,
  WidgetRef ref,
  int storyId,
  String title,
) async {
  var depth = 3, roots = 30;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, set) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Export discussion for AI',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Uses HN’s ranked display order. Vote counts are unavailable. The JSON preserves reply context and source links.',
                      ),
                      DropdownButtonFormField<int>(
                        value: roots,
                        decoration: const InputDecoration(
                          labelText: 'Top-level comments',
                        ),
                        items:
                            [10, 30, 50]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text('$v ranked threads'),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => set(() => roots = v!),
                      ),
                      DropdownButtonFormField<int>(
                        value: depth,
                        decoration: const InputDecoration(
                          labelText:
                              'Reply levels below each top-level comment',
                        ),
                        items:
                            [2, 3]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text('$v levels'),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => set(() => depth = v!),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Up to 300 comments. Android downloads in the background when connected; timing depends on battery and network conditions.',
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Create JSON'),
                      ),
                    ],
                  ),
                ),
              ),
        ),
  );
  if (ok != true) return;
  await ExportJobs(
    ref.read(appDatabaseProvider),
  ).enqueue(storyId, title, depth, roots);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Export queued. Find it in the sidebar’s Comment exports.',
        ),
      ),
    );
  }
}
