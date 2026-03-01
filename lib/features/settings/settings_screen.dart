import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../auth/auth_provider.dart';
import '../auth/login_dialog.dart';
import '../bookmarks/bookmark_provider.dart';
import '../publish/publish_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _patController = TextEditingController();
  final _repoController = TextEditingController();
  final _folderController = TextEditingController();
  bool _obscurePat = true;
  bool _testingConnection = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadGitHubConfig();
  }

  @override
  void dispose() {
    _patController.dispose();
    _repoController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  Future<void> _loadGitHubConfig() async {
    final github = ref.read(githubServiceProvider);
    final repo = await github.getRepo();
    final folder = await github.getFolder();
    // PAT is not read back for security
    setState(() {
      _repoController.text = repo ?? '';
      _folderController.text = folder ?? 'weekly';
      _loaded = true;
    });
  }

  Future<void> _saveGitHubConfig() async {
    final github = ref.read(githubServiceProvider);
    await github.saveConfig(
      pat: _patController.text.trim(),
      repo: _repoController.text.trim(),
      folder: _folderController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GitHub settings saved')),
      );
    }
  }

  Future<void> _testConnection() async {
    if (_patController.text.trim().isNotEmpty) {
      await _saveGitHubConfig();
    }
    setState(() => _testingConnection = true);
    final github = ref.read(githubServiceProvider);
    final ok = await github.testConnection();
    if (mounted) {
      setState(() => _testingConnection = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Connection successful!'
            : 'Connection failed. Check your settings.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: !_loaded
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              children: [
                _sectionHeader('HN Account'),
                ListTile(
                  title: Text(
                    authState.isLoggedIn
                        ? 'Logged in as: ${authState.username}'
                        : 'Not logged in',
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      if (authState.isLoggedIn) {
                        ref.read(authNotifierProvider.notifier).logout();
                      } else {
                        LoginDialog.show(context);
                      }
                    },
                    child: Text(authState.isLoggedIn ? 'Logout' : 'Login'),
                  ),
                ),
                const Divider(),
                _sectionHeader('GitHub Configuration'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _patController,
                        obscureText: _obscurePat,
                        decoration: InputDecoration(
                          labelText: 'GitHub PAT Token',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePat
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () =>
                                setState(() => _obscurePat = !_obscurePat),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _repoController,
                        decoration: const InputDecoration(
                          labelText: 'Repository (owner/repo)',
                          hintText: 'username/weekly-blog',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _folderController,
                        decoration: const InputDecoration(
                          labelText: 'Folder path',
                          hintText: 'weekly',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _testingConnection ? null : _testConnection,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side:
                                    const BorderSide(color: AppColors.primary),
                              ),
                              child: _testingConnection
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : const Text('Test Connection'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _saveGitHubConfig,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const Divider(),
                _sectionHeader('Data'),
                ListTile(
                  title: const Text('Clear all bookmarks'),
                  subtitle: const Text(
                    'Delete all bookmarks from local storage',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.delete_outline,
                      color: AppColors.error),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear all bookmarks?'),
                        content: const Text(
                            'This will permanently delete all bookmarks.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('DELETE',
                                style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(bookmarkRepositoryProvider).clearAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('All bookmarks cleared')),
                        );
                      }
                    }
                  },
                ),
                const Divider(),
                _sectionHeader('About'),
                const ListTile(
                  title: Text('Glean'),
                  subtitle: Text(
                    'Version 1.0.0',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
