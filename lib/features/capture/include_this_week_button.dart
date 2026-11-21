import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../publish/roundup_provider.dart';
import 'save_actions.dart';

class IncludeThisWeekButton extends ConsumerStatefulWidget {
  final int bookmarkId;
  final bool filled;
  final Future<bool> Function()? beforeInclude;
  const IncludeThisWeekButton({
    super.key,
    required this.bookmarkId,
    this.filled = false,
    this.beforeInclude,
  });
  @override
  ConsumerState<IncludeThisWeekButton> createState() =>
      _IncludeThisWeekButtonState();
}

class _IncludeThisWeekButtonState extends ConsumerState<IncludeThisWeekButton> {
  bool busy = false;
  Future<void> include() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      if (widget.beforeInclude != null && !await widget.beforeInclude!()) {
        return;
      }
      if (!mounted) return;
      await SaveActions.includeThisWeek(ref, widget.bookmarkId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Included in this week’s draft. Edit the public text there.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not add this item. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(currentWeekCardsProvider);
    final included =
        cards.valueOrNull?.any((c) => c.bookmarkId == widget.bookmarkId) ??
        false;
    final label =
        included
            ? 'Added this week'
            : busy
            ? 'Adding…'
            : cards.hasError
            ? 'Retry adding'
            : widget.filled
            ? 'Include this week'
            : 'This week';
    final icon = Icon(
      included ? Icons.playlist_add_check : Icons.playlist_add,
      size: 18,
    );
    final VoidCallback? action =
        busy || cards.isLoading || included ? null : include;
    return widget.filled
        ? FilledButton.icon(onPressed: action, icon: icon, label: Text(label))
        : TextButton.icon(onPressed: action, icon: icon, label: Text(label));
  }
}
