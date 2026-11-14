import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:workmanager/workmanager.dart';
import '../../data/api/comment_export_service.dart';
import '../../data/database/app_database.dart';

@pragma('vm:entry-point')
void exportDispatcher() {
  Workmanager().executeTask((task, input) async {
    if (task != 'glean.commentExport' || input?['id'] is! String) return true;
    final db = AppDatabase();
    try {
      return await ExportJobs(db).perform(input!['id'] as String);
    } finally {
      await db.close();
    }
  });
}

class ExportJobs {
  final AppDatabase db;
  ExportJobs(this.db);
  Future<List<CommentExport>> list() =>
      (db.select(db.commentExports)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  Future<void> schedule(String id, {bool replace = false}) async {
    if (!Platform.isAndroid) return;
    await Workmanager().registerOneOffTask(
      'glean-export-$id',
      'glean.commentExport',
      inputData: {'id': id},
      existingWorkPolicy:
          replace ? ExistingWorkPolicy.replace : ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(seconds: 30),
    );
  }

  Future<String> enqueue(
    int storyId,
    String title,
    int depth,
    int rootLimit,
  ) async {
    final id = '$storyId-${DateTime.now().microsecondsSinceEpoch}';
    await db
        .into(db.commentExports)
        .insert(
          CommentExportsCompanion.insert(
            id: id,
            storyId: storyId,
            title: title,
            depth: Value(depth),
            rootLimit: Value(rootLimit),
          ),
        );
    try {
      await schedule(id);
    } catch (_) {
      await status(
        id,
        'failed',
        error: 'Could not schedule the download. Tap Retry.',
      );
    }
    return id;
  }

  Future<void> resumePending() async {
    for (final job in await list()) {
      if (['queued', 'running', 'retrying'].contains(job.status)) {
        await schedule(job.id);
      }
    }
  }

  Future<void> status(
    String id,
    String state, {
    String? error,
    String? json,
  }) async {
    await (db.update(db.commentExports)..where((t) => t.id.equals(id))).write(
      CommentExportsCompanion(
        status: Value(state),
        error: Value(error),
        jsonContent: json == null ? const Value.absent() : Value(json),
      ),
    );
  }

  Future<bool> perform(String id, {CommentExportService? service}) async {
    final job =
        await (db.select(db.commentExports)
          ..where((t) => t.id.equals(id))).getSingleOrNull();
    if (job == null || job.status == 'ready') return true;
    await status(id, 'running');
    try {
      final data = await (service ?? CommentExportService())
          .build(job.storyId, replyLevels: job.depth, rootLimit: job.rootLimit)
          .timeout(const Duration(minutes: 5));
      await status(
        id,
        'ready',
        json: const JsonEncoder.withIndent('  ').convert(data),
      );
      return true;
    } catch (_) {
      await status(
        id,
        'retrying',
        error:
            'Download interrupted. Android will retry when connected; you can also retry manually.',
      );
      return false;
    }
  }

  Future<void> retry(String id) async {
    await status(id, 'queued');
    await schedule(id, replace: true);
  }

  Future<void> delete(String id) async {
    if (Platform.isAndroid) {
      await Workmanager().cancelByUniqueName('glean-export-$id');
    }
    await (db.delete(db.commentExports)..where((t) => t.id.equals(id))).go();
  }
}
