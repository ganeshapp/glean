import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'photo_import_service.dart';

class RoundupPhotoView extends ConsumerWidget {
  final String photoId;
  final String caption;
  final double maxHeight;
  const RoundupPhotoView({
    super.key,
    required this.photoId,
    this.caption = '',
    this.maxHeight = 260,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(roundupPhotoProvider(photoId))
      .when(
        data:
            (photo) =>
                photo == null
                    ? const Text(
                      'Photo missing. Add it from your gallery again.',
                    )
                    : ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight),
                      child: Image.memory(
                        photo.bytes,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        semanticLabel:
                            caption.isEmpty ? 'Roundup photo' : caption,
                        errorBuilder:
                            (_, _, _) => const Text(
                              'This photo could not be displayed.',
                            ),
                      ),
                    ),
        loading:
            () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (_, _) => const Text('Could not load photo.'),
      );
}
