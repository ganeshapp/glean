import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ScrollToTopFab extends StatefulWidget {
  const ScrollToTopFab({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<ScrollToTopFab> createState() => _ScrollToTopFabState();
}

class _ScrollToTopFabState extends State<ScrollToTopFab> {
  Offset _position = const Offset(0, 0);
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final size = MediaQuery.of(context).size;
      _position = Offset(
        size.width / 2 - 28,
        size.height - 160,
      );
      _initialized = true;
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              _position.dx + details.delta.dx,
              _position.dy + details.delta.dy,
            );
          });
        },
        child: FloatingActionButton.small(
          onPressed: () {
            widget.scrollController.animateTo(
              widget.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    );
  }
}
