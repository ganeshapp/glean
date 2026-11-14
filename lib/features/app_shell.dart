import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'share_receiver/share_handler.dart';
import 'publish/roundup_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigation;
  const AppShell({super.key, required this.navigation});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  ShareHandler? handler;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        handler = ShareHandler(ref, context)..init();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(currentIssueProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    handler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: widget.navigation,
    bottomNavigationBar: NavigationBar(
      selectedIndex: widget.navigation.currentIndex,
      onDestinationSelected: (i) => widget.navigation.goBranch(i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.chrome_reader_mode_outlined),
          selectedIcon: Icon(Icons.chrome_reader_mode),
          label: 'Read',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline),
          selectedIcon: Icon(Icons.bookmark),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.view_agenda_outlined),
          selectedIcon: Icon(Icons.view_agenda),
          label: 'This week',
        ),
      ],
    ),
  );
}
