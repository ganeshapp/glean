# Glean

An Android Hacker News reader and personal reading library that turns saved links, comments, videos, and thoughts into a weekly roundup.

## The workflow

1. **Read:** browse HN, search, open discussions, and save directly from a story or comment. Tap a saved article’s bookmark again, or choose **Remove saved comment** in a comment’s long-press menu, to unsave. Removed items stay in Archived with their notes, and Undo restores them. Share links or selected text from another Android app into Glean. Capture saves locally first; titles and other metadata load afterward.
2. **Saved:** search the library, add a private thought, archive with undo, and include items in this week's draft. Notes autosave. Saving a known HN item or canonical URL reuses the existing bookmark.
3. **This week:** add saved items or select multiple gallery photos, drag cards into any order, and tap a card to edit its public text, quote, attribution, or source link. Articles, quotes, photos, videos, and web links can be interleaved. Each photo is its own card with an optional caption and explanation; use the drag handle or Move up / Move down. There are no mandatory content sections.
4. Edit the issue title and optional opening, read the rendered preview, and publish. Glean generates Markdown; no Markdown editor is required. Private notes only become public when you explicitly copy them into a card.

Drafts persist on the phone. Issue history keeps older drafts and published issues available. Publishing again updates the same issue file rather than appending duplicate content. Glean checks the remote file SHA and stops if somebody changed the file independently. An upload confirmation and a live-page check distinguish a GitHub commit from a completed Pages deployment.

## Photos, video, and links

Gallery photos are copied into the local draft, so moving or deleting the original does not break the issue. Glean rotates them upright, resizes the longest edge to at most 2400 pixels, converts to JPEG, and removes source metadata (including EXIF/GPS). Animated images use their first frame. The preview shows local photos before you connect GitHub. Photos are included in library backups.

Publishing uploads each photo to `assets/<content-hash>.jpg` inside your selected publishing folder before writing the Markdown. For `_roundup`, that means `_roundup/assets/` in GitHub and `/roundup/assets/` on the website. Retries reuse identical uploads and never overwrite a different image. Removing a photo from an issue removes its reference; already-published image files remain in GitHub so older revisions keep working.

YouTube watch, short, live, and share URLs produce responsive, privacy-enhanced HTML iframes with a clickable title as a fallback. The phone preview opens YouTube externally; the published page embeds the player. Playback remains subject to the video's embedding restrictions. URLs in notes and excerpts also become clickable links.

## GitHub and gapp.in

In Settings, choose **Connect GitHub**, copy the device code, and approve Glean at GitHub. No client secret or pasted PAT is required. The bundled public OAuth client ID is `Ov23liRaL0nYAN77ycqb`; device flow must be enabled on that registration. The app requests `public_repo` access and lists writable public repositories. Existing PAT connections remain readable during migration; reconnecting replaces them with the device-flow session.

For the companion website:

- Repository: `ganeshapp/ganeshapp.github.io`
- Folder: `_roundup`
- Branch: the site's publishing branch
- Site URL: `https://www.gapp.in` (the existing custom domain)

The website changes must be deployed before first use: a Jekyll `roundup` collection, `roundup` layout, and `/roundup/` index. Glean writes `_roundup/2026-W46.md`, for example, with a permalink of `/roundup/2026-W46/`. The Roundup index and site search discover it automatically.

For another build, override the public client ID with `--dart-define=GITHUB_CLIENT_ID=...`. Tokens stay in platform secure storage and are excluded from backups.

## Comment exports for AI

From a discussion's overflow menu, choose **Export discussion for AI**. Select 10, 30, or 50 top-level threads and 2 or 3 reply levels. Android WorkManager downloads up to 300 comments in the background, retries interrupted downloads, and resumes pending work after restart. Android's battery and network policies can delay execution.

Open **Comment exports** in the sidebar to inspect, share, retry, or delete an export. The JSON preserves reply hierarchy, authors, source URLs, sibling rank, missing branches, and sampling limits. Glean does not call an AI service itself.

- **Share for AI** sends a `.txt` file containing the insight prompt and the complete exported JSON together.
- **Share as text** sends that same content as plain text; long discussions automatically use a text attachment to avoid Android's share-size limit.
- **Save for AI** saves the combined file directly to your device. If Gemini is absent from the Android share sheet, use this and attach the saved file in Gemini. No Slack detour or separate prompt copy is needed. Android only lists apps that accept the selected share type; Glean cannot force an app to accept attachments.
- **JSON options** retains raw JSON sharing and **Save JSON to device**. **Copy insight prompt** and **Inspect JSON** remain available.

HN's API does **not** expose comment vote counts. Exports use HN's ranked display order, not an invented vote threshold. Limited or interrupted samples are labeled explicitly. See the [official HN API](https://github.com/HackerNews/API).

Comment long-press actions also include **Copy text** and **Select text…** for copying just a few lines.

## Backup and migration

Settings can export or restore a JSON backup of saved items, private notes, ordered drafts, publication history, photos, and completed comment exports. Backups have a 200 MB limit. Restore replaces the local library after confirmation; GitHub credentials stay on the device. Database version 3 preserves existing bookmarks, notes, drafts, and published flags and adds photo storage. Both old version 1 backups and photo-inclusive version 2 backups can be restored. Previously generated Markdown files are left in their existing location and are not imported as editable issues.

## Development

Requires Flutter 3.29+ / Dart 3.7+ and an Android SDK. Android 5.0+ is supported.

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
flutter build apk --release --split-per-abi
```

The repository's existing release build configuration uses the local debug signing key. Keep the same signing key when updating an installed build; use a dedicated release keystore for wider distribution.

Tests cover v1/v2 database migrations, photo import/recovery, image normalization, media publishing and upload retries, AI sharing/save formats, persistent mixed ordering, private/public text boundaries, autosave, URL deduplication, backup validation, comment hierarchy and sampling, OAuth polling, safe GitHub updates, and phone layouts. Optional test artifacts:

```sh
GLEAN_SITE_FIXTURE=/tmp/roundup-fixture.md flutter test test/roundup_repository_test.dart
GLEAN_TEST_FONT_DIR="$FLUTTER_ROOT/bin/cache/artifacts/material_fonts" \
GLEAN_TEST_SCREENSHOTS=/tmp/glean-screenshots flutter test test/widget_test.dart
```

## License

MIT
