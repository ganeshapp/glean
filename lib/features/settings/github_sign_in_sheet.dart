import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/api/github_oauth_service.dart';
import '../../data/api/github_service.dart';

class GitHubSignInSheet extends StatefulWidget {
  final GitHubService github;
  const GitHubSignInSheet({super.key, required this.github});
  @override
  State<GitHubSignInSheet> createState() => _GitHubSignInSheetState();
}

class _GitHubSignInSheetState extends State<GitHubSignInSheet> {
  final oauth = GitHubOAuthService();
  DeviceCode? code;
  String? error;
  bool cancelled = false;
  int attempt = 0;
  @override
  void initState() {
    super.initState();
    unawaited(start());
  }

  @override
  void dispose() {
    cancelled = true;
    super.dispose();
  }

  Future<void> start() async {
    final run = ++attempt;
    setState(() {
      code = null;
      error = null;
    });
    try {
      final next = await oauth.start();
      if (!mounted || cancelled || run != attempt) return;
      setState(() => code = next);
      final tokens = await oauth.poll(
        next,
        cancelled: () => cancelled || !mounted || run != attempt,
      );
      if (tokens == null || !mounted || cancelled) return;
      await widget.github.connect(tokens);
      if (mounted && !cancelled) Navigator.pop(context, true);
    } catch (e) {
      if (mounted && !cancelled) setState(() => error = friendlyGitHubError(e));
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Connect GitHub', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text(
            'Approve Glean on GitHub to publish to your public repositories. Your reading and private notes stay on this device.',
          ),
          const SizedBox(height: 20),
          if (error != null) ...[
            Text(error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: start, child: const Text('Try again')),
          ] else if (code == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            SelectableText(
              code!.userCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Copy code and open GitHub'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code!.userCode));
                final opened = await launchUrl(
                  Uri.parse('https://github.com/login/device'),
                  mode: LaunchMode.externalApplication,
                );
                if (!opened && mounted) {
                  setState(
                    () =>
                        error =
                            'Open github.com/login/device in your browser and enter the code.',
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Waiting for approval. Return here after approving.',
              textAlign: TextAlign.center,
            ),
          ],
          TextButton(
            onPressed: () {
              cancelled = true;
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
}
