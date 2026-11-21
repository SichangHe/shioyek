# Shioyek

Shioyek is a fork of [Sioyek](https://github.com/ahrm/sioyek), the PDF viewer for research papers and technical books, maintained separately for macOS and Linux.

It installs as `shioyek` with its own config and data directories, so it can run alongside upstream Sioyek.

## Differences from Sioyek

- Each document is added to history as soon as it opens, so a crash no longer loses it. The reading position is also saved every 5 seconds.
- Only macOS and Linux are supported.
- Config: `~/.config/shioyek/prefs_user.config` and `keys_user.config`. The documentation for Sioyek's config options still applies.

## Download

Get the latest build from [Releases](../../releases). The `latest` prerelease is built from every push to `main`.

- Linux: `chmod +x shioyek-linux-x86_64.AppImage`, then run it.
- macOS: open the `.dmg` and drag `shioyek.app` to Applications. The app is not notarized, so before the first launch, run:
  `xattr -dr com.apple.quarantine /Applications/shioyek.app`

## License

GPL-3.0, same as upstream. See `LICENSE`.
