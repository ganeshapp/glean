import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'features/exports/export_jobs.dart';
import 'data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  if (Platform.isAndroid) {
    try {
      await Workmanager().initialize(exportDispatcher);
      final db = AppDatabase();
      try {
        await ExportJobs(db).resumePending();
      } finally {
        await db.close();
      }
    } catch (_) {
      /* Pending exports can be retried from the library. */
    }
  }
  runApp(const ProviderScope(child: GleanApp()));
}
