import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/github_service.dart';
import '../auth/auth_provider.dart';
import '../auth/login_dialog.dart';
import '../publish/publish_provider.dart';
import '../backup/backup_actions.dart';
import 'github_sign_in_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final folder = TextEditingController(text: '_roundup');
  final branch = TextEditingController(text: 'main');
  final site = TextEditingController(text: 'https://www.gapp.in');
  List<GitHubRepo> repos = [];
  String? repository, login, error;
  bool connected = false, busy = true;
  GitHubService get github => ref.read(githubServiceProvider);
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    folder.dispose();
    branch.dispose();
    site.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final session = await github.session();
      final hasToken = await github.isConnected();
      final repo = await github.getRepo();
      final path = await github.getFolder();
      final savedBranch = await github.getBranch();
      final url = await github.getSiteUrl();
      if (!mounted) return;
      setState(() {
        login = session?['login'];
        connected = hasToken;
        repository = repo;
        folder.text = path ?? '_roundup';
        branch.text = savedBranch ?? 'main';
        site.text = url ?? 'https://www.gapp.in';
        busy = false;
      });
    } catch (e) {
      fail(e);
    }
  }

  void fail(Object e) {
    if (mounted) {
      setState(() {
        busy = false;
        error = friendlyGitHubError(e);
      });
    }
  }

  Future<void> loadRepos() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final list = await github.listRepositories();
      if (mounted) {
        setState(() {
          repos = list;
          busy = false;
        });
      }
    } catch (e) {
      fail(e);
    }
  }

  Future<void> chooseRepo(String value) async {
    setState(() {
      repository = value;
      branch.text = repos.firstWhere((r) => r.fullName == value).branch;
      busy = true;
      error = null;
    });
    try {
      final url = await github.siteUrlFor(value);
      if (mounted && repository == value) {
        setState(() {
          site.text = url;
          busy = false;
        });
      }
    } catch (e) {
      fail(e);
    }
  }

  Future<void> browseFolder([String path = '']) async {
    if (repository == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final folders = await github.listContents(
        repository!,
        path,
        branch.text.trim(),
      );
      if (!mounted) return;
      setState(() => busy = false);
      final selected = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder:
            (ctx) => SafeArea(
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * .65,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(path.isEmpty ? 'Repository folders' : path),
                      trailing: TextButton(
                        onPressed: () => Navigator.pop(ctx, 'select:$path'),
                        child: const Text('Use folder'),
                      ),
                    ),
                    if (path.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.arrow_upward),
                        title: const Text('Parent folder'),
                        onTap:
                            () => Navigator.pop(
                              ctx,
                              'browse:${path.contains('/') ? path.substring(0, path.lastIndexOf('/')) : ''}',
                            ),
                      ),
                    Expanded(
                      child: ListView(
                        children:
                            folders
                                .map(
                                  (f) => ListTile(
                                    leading: const Icon(Icons.folder_outlined),
                                    title: Text(f.name),
                                    onTap:
                                        () => Navigator.pop(
                                          ctx,
                                          'browse:${f.path}',
                                        ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
      if (!mounted || selected == null) return;
      if (selected.startsWith('browse:')) {
        await browseFolder(selected.substring(7));
      } else {
        setState(() => folder.text = selected.substring(7));
      }
    } catch (e) {
      fail(e);
    }
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await github.testConnection(
        repository ?? '',
        folder.text.trim(),
        branch.text.trim(),
      );
      await github.saveConfig(
        repo: repository ?? '',
        folder: folder.text.trim(),
        branch: branch.text.trim(),
        siteUrl: site.text.trim(),
      );
      if (mounted) {
        setState(() => busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publishing destination saved')),
        );
      }
    } catch (e) {
      fail(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hn = ref.watch(authNotifierProvider);
    final knownRepos = {
      for (final r in repos) r.fullName: r.fullName,
      if (repository != null && repository!.isNotEmpty)
        repository!: repository!,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Publishing', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              connected
                  ? 'GitHub connected${login == null ? '' : ' · $login'}'
                  : 'Connect GitHub',
            ),
            subtitle: const Text('Publish roundups to a public repository'),
            trailing: TextButton(
              onPressed:
                  busy
                      ? null
                      : () async {
                        if (connected) {
                          await github.disconnect();
                          await load();
                        } else {
                          final ok = await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => GitHubSignInSheet(github: github),
                          );
                          if (ok == true && mounted) {
                            await load();
                            await loadRepos();
                          }
                        }
                      },
              child: Text(connected ? 'Disconnect' : 'Sign in'),
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (connected) ...[
            OutlinedButton.icon(
              onPressed: busy ? null : loadRepos,
              icon: const Icon(Icons.refresh),
              label: const Text('Load repositories'),
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: knownRepos.containsKey(repository) ? repository : null,
              decoration: const InputDecoration(labelText: 'Repository'),
              items:
                  knownRepos.keys
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
              onChanged:
                  busy
                      ? null
                      : (v) {
                        if (v != null && repos.any((r) => r.fullName == v)) {
                          chooseRepo(v);
                        }
                      },
            ),
            TextField(
              controller: branch,
              decoration: const InputDecoration(labelText: 'Branch'),
            ),
            TextField(
              controller: folder,
              decoration: InputDecoration(
                labelText: 'Content folder',
                helperText: 'For gapp.in, choose _roundup.',
                suffixIcon: IconButton(
                  tooltip: 'Browse folders',
                  onPressed: busy || repository == null ? null : browseFolder,
                  icon: const Icon(Icons.folder_open),
                ),
              ),
            ),
            TextField(
              controller: site,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                helperText: 'Used to open the published roundup.',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy || repository == null ? null : save,
              child: const Text('Check and save destination'),
            ),
          ],
          const Divider(height: 40),
          Text('Your library', style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Back up library and drafts'),
            subtitle: const Text(
              'Save a JSON file; GitHub credentials are excluded',
            ),
            onTap: () => BackupActions.export(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore backup'),
            subtitle: const Text(
              'Replace local library and drafts from a backup',
            ),
            onTap: () => BackupActions.restore(context, ref),
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              hn.isLoggedIn ? 'HN · ${hn.username}' : 'Hacker News account',
            ),
            trailing: TextButton(
              onPressed: () async {
                if (hn.isLoggedIn) {
                  await ref.read(authNotifierProvider.notifier).logout();
                } else if (mounted) {
                  await LoginDialog.show(context);
                }
              },
              child: Text(hn.isLoggedIn ? 'Sign out' : 'Sign in'),
            ),
          ),
        ],
      ),
    );
  }
}
