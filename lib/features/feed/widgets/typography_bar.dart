import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';

class TypographySettings {
  double fontSize;
  double lineHeight;
  String fontFamily;

  TypographySettings({
    this.fontSize = 16.0,
    this.lineHeight = 1.3,
    this.fontFamily = 'Default',
  });
}

final typographyNotifier = ValueNotifier<TypographySettings>(
  TypographySettings(),
);

Future<void> loadTypographyPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  typographyNotifier.value = TypographySettings(
    fontSize: prefs.getDouble('font_size') ?? 16.0,
    lineHeight: prefs.getDouble('line_height') ?? 1.3,
    fontFamily: prefs.getString('font_family') ?? 'Default',
  );
}

Future<void> _saveTypographyPrefs(TypographySettings s) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('font_size', s.fontSize);
  await prefs.setDouble('line_height', s.lineHeight);
  await prefs.setString('font_family', s.fontFamily);
}

class TypographyBar extends StatefulWidget {
  const TypographyBar({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<TypographyBar> createState() => _TypographyBarState();
}

class _TypographyBarState extends State<TypographyBar> {
  late TypographySettings _settings;

  static const _fontFamilies = [
    'Default',
    'Roboto',
    'Roboto Slab',
    'Roboto Mono',
  ];

  @override
  void initState() {
    super.initState();
    _settings = TypographySettings(
      fontSize: typographyNotifier.value.fontSize,
      lineHeight: typographyNotifier.value.lineHeight,
      fontFamily: typographyNotifier.value.fontFamily,
    );
  }

  void _update() {
    typographyNotifier.value = TypographySettings(
      fontSize: _settings.fontSize,
      lineHeight: _settings.lineHeight,
      fontFamily: _settings.fontFamily,
    );
    _saveTypographyPrefs(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text('Font Size:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 4),
          _iconButton(Icons.text_decrease, () {
            setState(() {
              _settings.fontSize = (_settings.fontSize - 1).clamp(10, 24);
              _update();
            });
          }),
          _iconButton(Icons.text_increase, () {
            setState(() {
              _settings.fontSize = (_settings.fontSize + 1).clamp(10, 24);
              _update();
            });
          }),
          const SizedBox(width: 8),
          const Text('Line Height:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(width: 4),
          _iconButton(Icons.density_small, () {
            setState(() {
              _settings.lineHeight = (_settings.lineHeight - 0.1).clamp(1.0, 2.0);
              _update();
            });
          }),
          _iconButton(Icons.density_large, () {
            setState(() {
              _settings.lineHeight = (_settings.lineHeight + 0.1).clamp(1.0, 2.0);
              _update();
            });
          }),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _settings.fontFamily,
            dropdownColor: AppColors.surfaceElevated,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            underline: const SizedBox.shrink(),
            isDense: true,
            items: _fontFamilies
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _settings.fontFamily = v;
                  _update();
                });
              }
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: widget.onDone,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: AppColors.surfaceElevated,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            child: const Text('DONE', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
