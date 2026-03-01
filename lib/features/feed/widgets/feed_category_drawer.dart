import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/auth_provider.dart';
import '../../auth/login_dialog.dart';
import '../feed_screen.dart';

class FeedCategoryDrawer extends ConsumerWidget {
  const FeedCategoryDrawer({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final FeedCategory selectedCategory;
  final void Function(FeedCategory) onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, ref, authState),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final category in FeedCategory.values)
                  _buildCategoryTile(context, category),
                const Divider(),
                _buildNavTile(
                  context,
                  icon: Icons.bookmark,
                  label: 'Bookmarks',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/bookmarks');
                  },
                ),
                _buildNavTile(
                  context,
                  icon: Icons.publish,
                  label: 'Publish to GitHub',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/publish');
                  },
                ),
                const Divider(),
                _buildNavTile(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AuthState authState) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Text(
                'HN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Spacer(),
          if (authState.isLoggedIn)
            Row(
              children: [
                Text(
                  authState.username!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ref.read(authNotifierProvider.notifier).logout();
                  },
                  child: const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await LoginDialog.show(context);
              },
              child: const Text(
                'Tap to login',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, FeedCategory category) {
    final isSelected = category == selectedCategory;
    return ListTile(
      leading: Icon(
        category.icon,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      title: Text(
        category.label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.primary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary,
      onTap: () => onCategorySelected(category),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(color: AppColors.primary)),
      onTap: onTap,
    );
  }
}
