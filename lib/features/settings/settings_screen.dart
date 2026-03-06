import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/api/github_service.dart';
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
  bool _obscurePat = true;
  bool _testingConnection = false;
  bool _loaded = false;
  bool _loadingRepos = false;

  List<GitHubRepo> _repos = [];
  String? _selectedRepo;
  List<GitHubContentItem> _rootFolders = [];
  String? _selectedRootFolder; // null = Root
  List<GitHubContentItem> _subfolders = [];
  String? _selectedSubfolder;

  @override
  void initState() {
    super.initState();
    _loadGitHubConfig();
  }

  @override
  void dispose() {
    _patController.dispose();
    super.dispose();
  }

  String get _folderPath {
    if (_selectedSubfolder != null && _selectedSubfolder!.isNotEmpty) {
      return _selectedSubfolder!; // full path from repo root
    }
    return _selectedRootFolder ?? '';
  }

  Future<void> _loadGitHubConfig() async {
    final github = ref.read(githubServiceProvider);
    final repo = await github.getRepo();
    final folder = await github.getFolder();
    setState(() {
      _selectedRepo = repo;
      if (folder != null && folder.isNotEmpty) {
        final parts = folder.split('/');
        _selectedRootFolder = parts.isNotEmpty ? parts.first : null;
        _selectedSubfolder =
            parts.length > 1 ? folder : null; // full path for dropdown match
      } else {
        _selectedRootFolder = null;
        _selectedSubfolder = null;
      }
      _loaded = true;
    });
  }

  Future<void> _loadRepositories() async {
    final pat = _patController.text.trim();
    if (pat.isEmpty) return;
    setState(() => _loadingRepos = true);
    final github = ref.read(githubServiceProvider);
    final repos = await github.listRepositories(pat);
    if (mounted) {
      setState(() {
        _repos = repos;
        _loadingRepos = false;
        if (_repos.isNotEmpty && !_repos.any((r) => r.fullName == _selectedRepo)) {
          _selectedRepo = _repos.first.fullName;
          _rootFolders = [];
          _subfolders = [];
          _selectedRootFolder = null;
          _selectedSubfolder = null;
          _loadRootFolders();
        }
      });
    }
  }

  Future<void> _loadRootFolders() async {
    if (_selectedRepo == null) return;
    final token = _patController.text.trim();
    if (token.isEmpty) return;
    final github = ref.read(githubServiceProvider);
    final folders =
        await github.listContents(_selectedRepo!, '', token, dirsOnly: true);
    if (mounted) {
      setState(() {
        _rootFolders = folders;
        _subfolders = [];
      });
      if (_selectedRootFolder != null) await _loadSubfolders();
    }
  }

  Future<void> _loadSubfolders() async {
    if (_selectedRepo == null || _selectedRootFolder == null) return;
    final token = _patController.text.trim();
    if (token.isEmpty) return;
    final github = ref.read(githubServiceProvider);
    final folders = await github.listContents(
        _selectedRepo!, _selectedRootFolder!, token, dirsOnly: true);
    if (mounted) {
      setState(() {
        _subfolders = folders;
        _selectedSubfolder = null;
      });
    }
  }

  Future<void> _saveGitHubConfig() async {
    final github = ref.read(githubServiceProvider);
    await github.saveConfig(
      pat: _patController.text.trim(),
      repo: _selectedRepo ?? '',
      folder: _folderPath.isEmpty ? 'weekly' : _folderPath,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GitHub settings saved')),
      );
    }
  }

  Future<void> _testConnection() async {
    await _saveGitHubConfig();
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _loadingRepos ? null : _loadRepositories,
                        icon: _loadingRepos
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              )
                            : const Icon(Icons.folder_open, size: 18),
                        label: Text(_loadingRepos
                            ? 'Loading…'
                            : 'Load repositories'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _repos.any((r) => r.fullName == _selectedRepo)
                            ? _selectedRepo
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Repository',
                        ),
                        dropdownColor: AppColors.surfaceElevated,
                        items: [
                          if (_selectedRepo != null &&
                              !_repos.any((r) => r.fullName == _selectedRepo))
                            DropdownMenuItem(
                              value: _selectedRepo,
                              child: Text(
                                _selectedRepo!,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ..._repos
                              .map((r) => DropdownMenuItem(
                                    value: r.fullName,
                                    child: Text(r.fullName,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                        ],
                        onChanged: (v) async {
                          setState(() {
                            _selectedRepo = v;
                            _rootFolders = [];
                            _subfolders = [];
                            _selectedRootFolder = null;
                            _selectedSubfolder = null;
                          });
                          await _loadRootFolders();
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedRootFolder,
                        decoration: const InputDecoration(
                          labelText: 'Folder',
                        ),
                        dropdownColor: AppColors.surfaceElevated,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Root'),
                          ),
                          ..._rootFolders
                              .map((d) => DropdownMenuItem(
                                    value: d.path,
                                    child: Text(d.name,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                        ],
                        onChanged: _selectedRepo == null
                            ? null
                            : (v) async {
                                setState(() {
                                  _selectedRootFolder = v;
                                  _selectedSubfolder = null;
                                  _subfolders = [];
                                });
                                if (v != null) await _loadSubfolders();
                              },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedSubfolder,
                        decoration: const InputDecoration(
                          labelText: 'Subfolder (optional)',
                        ),
                        dropdownColor: AppColors.surfaceElevated,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('—'),
                          ),
                          ..._subfolders
                              .map((d) => DropdownMenuItem(
                                    value: d.path,
                                    child: Text(d.name,
                                        overflow: TextOverflow.ellipsis),
                                  )),
                        ],
                        onChanged: _selectedRootFolder == null
                            ? null
                            : (v) {
                                setState(() => _selectedSubfolder = v);
                              },
                      ),
                      if (_folderPath.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Path: $_folderPath',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
                    'Version 1.0.2',
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
