import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/backup_repository.dart';
import '../bookmarks/bookmark_provider.dart';
import '../exports/export_jobs.dart';
import '../publish/roundup_provider.dart';

class BackupActions {
  static Future<void> export(BuildContext context, WidgetRef ref) async {
    try {
      final raw =
          await BackupRepository(ref.read(appDatabaseProvider)).export();
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Glean backup',
        fileName:
            'glean-backup-${DateTime.now().toIso8601String().substring(0, 10)}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(raw)),
      );
      if (result != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup saved')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the backup. Please try again.'),
          ),
        );
      }
    }
  }

  static Future<void> restore(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null) return;
      final file = result.files.single;
      if (file.size > 50 * 1024 * 1024) {
        throw const FormatException('Backup is too large.');
      }
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      final repo = BackupRepository(ref.read(appDatabaseProvider));
      final data = repo.validate(utf8.decode(bytes));
      if (!context.mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Replace local library?'),
              content: Text(
                'Restore ${data.bookmarks.length} saved items and ${data.issues.length} issues. This replaces the current library, drafts, and exports. GitHub sign-in stays unchanged. Make a backup first if you want to keep the current data.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Restore'),
                ),
              ],
            ),
      );
      if (ok != true) return;
      final jobs = ExportJobs(ref.read(appDatabaseProvider));
      for (final job in await jobs.list()) {
        if (job.status != 'ready') await jobs.delete(job.id);
      }
      await repo.restore(data);
      ref.invalidate(currentIssueProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup restored')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not restore this backup. Use a valid Glean JSON backup.',
            ),
          ),
        );
      }
    }
  }
}
