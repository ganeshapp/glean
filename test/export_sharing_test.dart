import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glean/data/api/comment_export_service.dart';
import 'package:glean/data/database/app_database.dart';
import 'package:glean/features/exports/export_sharing.dart';

class SavePicker extends FilePicker {
  Uint8List? saved;
  String? name;
  bool cancel = false;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    name = fileName;
    saved = bytes;
    return cancel ? null : '/downloads/$fileName';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final job = CommentExport(
    id: '42-1000',
    storyId: 42,
    title: 'Discussion',
    depth: 3,
    rootLimit: 30,
    status: 'ready',
    jsonContent:
        '{"comments":[{"text":"A useful angle","children":[{"text":"Context"}]}]}',
    createdAt: DateTime(2026),
  );
  late Directory tmp;
  final calls = <MethodCall>[];
  setUp(() async {
    calls.clear();
    tmp = await Directory.systemTemp.createTemp('glean-share-test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => tmp.path,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (c) async {
        calls.add(c);
        return 'chosen.app';
      },
    );
  });
  tearDown(() => tmp.delete(recursive: true));
  test(
    'AI attachment uses plain text and includes the prompt and complete JSON',
    () async {
      await ExportSharing.shareFile(job);
      expect(calls.single.method, 'shareFiles');
      expect(calls.single.arguments['mimeTypes'], ['text/plain']);
      final file = File(
        (calls.single.arguments['paths'] as List).single as String,
      );
      expect(file.path, endsWith('.txt'));
      final content = await file.readAsString();
      expect(content, contains(CommentExportService.analysisPrompt));
      expect(content, contains(job.jsonContent!));
      expect(content, contains('https://news.ycombinator.com/item?id=42'));
    },
  );
  test(
    'text sharing includes both pieces and large discussions fall back to file without truncation',
    () async {
      expect(await ExportSharing.shareText(job), true);
      expect(calls.single.method, 'share');
      expect(calls.single.arguments['text'], ExportSharing.aiText(job));
      calls.clear();
      final large = job.copyWith(
        jsonContent: Value('{"comments":["${'x' * (130 * 1024)}"]}'),
      );
      expect(await ExportSharing.shareText(large), false);
      expect(calls.single.method, 'shareFiles');
      expect(
        await File(calls.single.arguments['paths'][0]).readAsString(),
        ExportSharing.aiText(large),
      );
    },
  );
  test(
    'device saves include prompt in txt and retain raw JSON option; cancel is harmless',
    () async {
      final picker = SavePicker();
      FilePicker.platform = picker;
      expect(await ExportSharing.save(job), endsWith('.txt'));
      expect(String.fromCharCodes(picker.saved!), ExportSharing.aiText(job));
      expect(await ExportSharing.save(job, rawJson: true), endsWith('.json'));
      expect(String.fromCharCodes(picker.saved!), job.jsonContent!);
      picker.cancel = true;
      expect(await ExportSharing.save(job), isNull);
      await ExportSharing.shareFile(job, rawJson: true);
      expect(calls.single.arguments['mimeTypes'], ['application/json']);
    },
  );
}
