# Glean

A dark-mode Flutter Android app that serves as a full-featured Hacker News client with enhanced bookmarking and weekly GitHub blog publishing.

## Features

- **HN Client** -- Browse Top, New, Ask HN, Show HN, Jobs stories with pull-to-refresh and infinite scroll
- **Threaded Comments** -- Colored depth bars, tap-to-collapse, long-press actions
- **Search** -- Algolia-powered with time range and sort filters
- **Authentication** -- Login to HN to upvote, downvote, and reply
- **Enhanced Bookmarking** -- Bookmark articles with summaries, bookmark individual comments
- **Share Intent** -- Receive tweets and web snippets from other apps
- **GitHub Publishing** -- Publish curated weekly bookmarks as markdown to a GitHub repo
- **Typography Controls** -- Adjustable font size, line height, and font family
- **Dark Mode Only** -- Orange accent on dark palette (no pink)

## Getting Started

### Prerequisites

- Flutter SDK (3.29+)
- Android SDK
- Dart SDK (3.7+)

### Setup

```bash
# Install dependencies
flutter pub get

# Run code generation (drift database, etc.)
dart run build_runner build --delete-conflicting-outputs

# Run on a connected device or emulator
flutter run

# Build release APK
flutter build apk --release
```

### Building Split APKs

```bash
flutter build apk --split-per-abi --release
```

This produces separate APKs for ARM64, ARM32, and x86_64.

## Tech Stack

- **State management:** Riverpod
- **Local DB:** drift (SQLite)
- **HTTP:** dio
- **Navigation:** go_router
- **Secure storage:** flutter_secure_storage

## License

MIT
