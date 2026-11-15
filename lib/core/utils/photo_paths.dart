import '../../data/database/app_database.dart';
import 'content_utils.dart';

class PhotoPaths {
  static bool validId(String id) => RegExp(r'^[a-f0-9]{64}$').hasMatch(id);

  static String repositoryPath(RoundupIssue issue, String id) {
    if (!validId(id) || issue.filePath == null) {
      throw StateError(
        'Choose a publishing destination before uploading photos.',
      );
    }
    final parts = issue.filePath!.split('/')..removeLast();
    if (parts.any((p) => p.isEmpty || p == '.' || p == '..')) {
      throw StateError('The publishing folder is invalid.');
    }
    return [...parts, 'assets', '$id.jpg'].join('/');
  }

  static String publicUrl(RoundupIssue issue, String id) {
    if (safeWebUrl(issue.publicUrl) == null) {
      throw StateError('Choose a public website URL before publishing photos.');
    }
    final path = repositoryPath(issue, id)
        .split('/')
        .map((p) => p.startsWith('_') ? p.substring(1) : p)
        .map(Uri.encodeComponent)
        .join('/');
    // Issue URLs are <site base>/roundup/<issue>/, including project Pages bases.
    return Uri.parse(
      issue.publicUrl!,
    ).resolve('../../').resolve(path).toString();
  }
}
