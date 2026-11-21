import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glean/widgets/editor_text_field.dart';

void main() {
  late TextEditingController controller;
  setUp(
    () =>
        controller = TextEditingController(
          text: 'First sentence. Second sentence.\nAnother line to edit.',
        ),
  );
  tearDown(() => controller.dispose());
  Future<void> mount(WidgetTester t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditorTextField(controller: controller, maxLines: null),
        ),
      ),
    );
    await t.showKeyboard(find.byType(TextField));
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
    await t.pumpAndSettle();
  }

  Offset position(WidgetTester t, int offset) {
    final render =
        t.state<EditableTextState>(find.byType(EditableText)).renderEditable;
    return render.localToGlobal(
      render.getLocalRectForCaret(TextPosition(offset: offset)).center,
    );
  }

  testWidgets(
    'Android single touch positions cursor even with phantom IME Shift held',
    (t) async {
      await mount(t);
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await t.tapAt(position(t, 3));
      await t.pumpAndSettle();
      expect(controller.selection.isCollapsed, true);
      expect(controller.selection.extentOffset, closeTo(3, 1));
      await t.pump(const Duration(milliseconds: 600));
      await t.tapAt(position(t, 20));
      await t.pumpAndSettle();
      expect(controller.selection.isCollapsed, true);
      expect(controller.selection.extentOffset, closeTo(20, 1));
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
  testWidgets(
    'long press, double tap and mouse Shift-click keep selecting text',
    (t) async {
      await mount(t);
      await t.longPressAt(position(t, 3));
      await t.pumpAndSettle();
      expect(controller.selection.isCollapsed, false);
      await t.pump(const Duration(seconds: 1));
      await t.tapAt(position(t, 19));
      await t.pump(const Duration(milliseconds: 80));
      await t.tapAt(position(t, 19));
      await t.pumpAndSettle();
      expect(controller.selection.isCollapsed, false);
      await t.pump(const Duration(seconds: 1));
      controller.selection = const TextSelection.collapsed(offset: 0);
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await t.tapAt(position(t, 20), kind: PointerDeviceKind.mouse);
      await t.pumpAndSettle();
      expect(controller.selection.isCollapsed, false);
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
  testWidgets(
    'prose requests sentence casing from the keyboard; URL casing stays unchanged',
    (t) async {
      await mount(t);
      expect(
        t.testTextInput.setClientArgs!['inputType']['name'],
        'TextInputType.multiline',
      );
      expect(
        t.testTextInput.setClientArgs!['textCapitalization'],
        'TextCapitalization.sentences',
      );
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditorTextField(
              controller: controller,
              keyboardType: TextInputType.url,
              textCapitalization: TextCapitalization.none,
            ),
          ),
        ),
      );
      await t.showKeyboard(find.byType(TextField));
      expect(
        t.testTextInput.setClientArgs!['textCapitalization'],
        'TextCapitalization.none',
      );
    },
  );
}
