import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Prose input with sentence casing and a touch-only workaround for the
/// Android IME phantom Shift state in Flutter 3.29 (flutter/flutter#184744).
/// Remove the workaround after adopting an engine with flutter/flutter#185292.
class EditorTextField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final int? minLines, maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  const EditorTextField({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(),
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
  });

  @override
  State<EditorTextField> createState() => _EditorTextFieldState();
}

class _EditorTextFieldState extends State<EditorTextField> {
  PointerDeviceKind? _pointerKind;

  void _placeTouchCursor() {
    // TextField.onTap runs after a single tap's selection has been updated.
    // It is not called for double taps, long presses or selection-handle drags.
    // Keep mouse Shift-click and hardware Shift-arrow selection unchanged.
    if (defaultTargetPlatform != TargetPlatform.android ||
        _pointerKind != PointerDeviceKind.touch ||
        !HardwareKeyboard.instance.isShiftPressed) {
      return;
    }
    final selection = widget.controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      widget.controller.selection = TextSelection.collapsed(
        offset: selection.extentOffset,
        affinity: selection.affinity,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (event) => _pointerKind = event.kind,
    child: TextField(
      controller: widget.controller,
      decoration: widget.decoration,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      onTap: _placeTouchCursor,
    ),
  );
}
