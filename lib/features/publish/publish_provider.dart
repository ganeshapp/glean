import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/github_service.dart';

final githubServiceProvider = Provider<GitHubService>((ref) => GitHubService());
