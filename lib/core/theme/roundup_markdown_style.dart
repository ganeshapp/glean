import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

MarkdownStyleSheet roundupMarkdownStyle(ThemeData theme) {
  final colors = theme.colorScheme;
  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurface,
      height: 1.5,
    ),
    a: TextStyle(color: colors.primary, decoration: TextDecoration.underline),
    blockquote: theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurface,
      height: 1.5,
    ),
    blockquoteDecoration: BoxDecoration(
      color: colors.surface,
      border: Border(left: BorderSide(color: colors.primary, width: 3)),
    ),
    blockquotePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    code: theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurface,
      backgroundColor: colors.surface,
      fontFamily: 'monospace',
    ),
    codeblockDecoration: BoxDecoration(color: colors.surface),
  );
}
