import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/roundup_repository.dart';
import '../bookmarks/bookmark_provider.dart';

final photoImportProvider = Provider(
  (ref) => PhotoImportService(ref.watch(appDatabaseProvider)),
);
final roundupPhotoProvider = StreamProvider.autoDispose
    .family<RoundupPhoto?, String>(
      (ref, id) =>
          RoundupRepository(ref.watch(appDatabaseProvider)).watchPhoto(id),
    );

class PhotoImportResult {
  final String issueId;
  final int added, existing, failed;
  const PhotoImportResult(
    this.issueId, {
    this.added = 0,
    this.existing = 0,
    this.failed = 0,
  });
  String get message =>
      '${added == 1 ? '1 photo added' : '$added photos added'}'
      '${existing > 0 ? ' · $existing already included' : ''}'
      '${failed > 0 ? ' · $failed could not be read; try selecting them again' : ''}';
}

class PhotoImportService {
  final AppDatabase db;
  final ImagePicker picker;
  PhotoImportService(this.db, {ImagePicker? picker})
    : picker = picker ?? ImagePicker();
  static const pendingKey = 'roundup_pending_photos';
  static const maxInputBytes = 40 * 1024 * 1024;
  static const maxPhotoBytes = 8 * 1024 * 1024;
  Future<PhotoImportResult?>? _recovery;
  bool _picking = false;

  Future<PhotoImportResult?> recover() =>
      _recovery ??= _recover().catchError((Object error) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(pendingKey);
        // A failed recovery must not prevent a fresh selection.
        return null;
      });
  Future<PhotoImportResult?> _recover() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(pendingKey);
    final lost = Platform.isAndroid ? await picker.retrieveLostData() : null;
    if (raw == null) return null;
    final pending = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final issueId = pending['issueId'] as String;
    var paths = List<String>.from(pending['paths'] as List);
    if (paths.isEmpty && lost?.files != null) {
      paths = lost!.files!.map((f) => f.path).toList();
    }
    if (paths.isEmpty) {
      await prefs.remove(pendingKey);
      return lost?.exception == null
          ? null
          : PhotoImportResult(issueId, failed: 1);
    }
    await prefs.setString(
      pendingKey,
      jsonEncode({'issueId': issueId, 'paths': paths}),
    );
    return _import(issueId, paths, prefs);
  }

  Future<PhotoImportResult?> pick(String issueId) async {
    await recover();
    if (_picking) return null;
    _picking = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        pendingKey,
        jsonEncode({'issueId': issueId, 'paths': <String>[]}),
      );
      final files = await picker.pickMultiImage(
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 95,
        requestFullMetadata: false,
      );
      if (files.isEmpty) {
        await prefs.remove(pendingKey);
        return null;
      }
      final paths = files.map((f) => f.path).toList();
      await prefs.setString(
        pendingKey,
        jsonEncode({'issueId': issueId, 'paths': paths}),
      );
      return await _import(issueId, paths, prefs);
    } finally {
      _picking = false;
    }
  }

  Future<PhotoImportResult> _import(
    String issueId,
    List<String> paths,
    SharedPreferences prefs,
  ) async {
    final repo = RoundupRepository(db);
    await repo.getIssue(issueId);
    var added = 0, existing = 0, failed = 0;
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.length() > maxInputBytes) {
          throw const FormatException('Photo is too large.');
        }
        final normalized = await compute(
          normalizePhoto,
          await file.readAsBytes(),
        );
        final photo = RoundupPhoto(
          id: normalized.id,
          bytes: normalized.bytes,
          width: normalized.width,
          height: normalized.height,
        );
        if (await repo.addPhoto(issueId, photo)) {
          added++;
        } else {
          existing++;
        }
      } catch (_) {
        failed++;
      }
    }
    await prefs.remove(pendingKey);
    return PhotoImportResult(
      issueId,
      added: added,
      existing: existing,
      failed: failed,
    );
  }
}

class NormalizedPhoto {
  final String id;
  final Uint8List bytes;
  final int width, height;
  const NormalizedPhoto(this.id, this.bytes, this.width, this.height);
}

NormalizedPhoto normalizePhoto(Uint8List input) {
  try {
    return _normalizePhoto(input);
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException('This photo could not be read.');
  }
}

NormalizedPhoto _normalizePhoto(Uint8List input) {
  if (input.length > PhotoImportService.maxInputBytes) {
    throw const FormatException('Photo is too large.');
  }
  final decoder = img.findDecoderForData(input);
  final info = decoder?.startDecode(input);
  if (info == null || info.width * info.height > 60 * 1000 * 1000) {
    throw const FormatException('This photo could not be read.');
  }
  final frame = decoder!.decodeFrame(0);
  if (frame == null) {
    throw const FormatException('This photo could not be read.');
  }
  var photo = img.bakeOrientation(frame);
  final scale = math.min(1.0, 2400 / math.max(photo.width, photo.height));
  if (scale < 1) {
    photo = img.copyResize(
      photo,
      width: (photo.width * scale).round(),
      height: (photo.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
  }
  // Fresh pixels remove EXIF/GPS and other source metadata from the public copy.
  final clean = img.Image(
    width: photo.width,
    height: photo.height,
    numChannels: 3,
  );
  img.fill(clean, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(clean, photo);
  final bytes = Uint8List.fromList(img.encodeJpg(clean, quality: 88));
  if (bytes.length > PhotoImportService.maxPhotoBytes) {
    throw const FormatException('Photo is too large.');
  }
  return NormalizedPhoto(
    sha256.convert(bytes).toString(),
    bytes,
    clean.width,
    clean.height,
  );
}
