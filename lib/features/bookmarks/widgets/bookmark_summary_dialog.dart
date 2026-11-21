import 'package:flutter/material.dart';

class BookmarkSummaryDialog extends StatefulWidget {
  const BookmarkSummaryDialog({super.key, this.initialSummary});

  final String? initialSummary;

  static Future<String?> show(BuildContext context, {String? initialSummary}) {
    return showDialog<String>(
      context: context,
      builder: (_) => BookmarkSummaryDialog(initialSummary: initialSummary),
    );
  }

  @override
  State<BookmarkSummaryDialog> createState() => _BookmarkSummaryDialogState();
}

class _BookmarkSummaryDialogState extends State<BookmarkSummaryDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSummary);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your thought'),
      content: TextField(
        textCapitalization: TextCapitalization.sentences,
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Why did this catch your attention?',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
