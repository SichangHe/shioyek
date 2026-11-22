# Shioyek

Shioyek is a fork of [Sioyek](https://github.com/ahrm/sioyek), the PDF viewer for research papers and technical books, maintained separately for macOS and Linux.

It installs as `shioyek` with its own config and data directories, so it can run alongside upstream Sioyek.

## Differences from Sioyek

- Each document is added to history as soon as it opens, so a crash no longer loses it. The reading position is also saved every 5 seconds.
- Only macOS and Linux are supported.
- Config: `~/.config/shioyek/prefs_user.config` and `keys_user.config`. The documentation for Sioyek's config options still applies.

## Install or update

macOS (Apple Silicon or Intel) and Linux (x86_64):

```sh
curl -fsSL https://raw.githubusercontent.com/SichangHe/shioyek/main/install.sh | sh
```

What it does:
- macOS: installs `shioyek.app` in `/Applications` and removes the download quarantine, so the unsigned app opens without a warning. It also links the `shioyek` command into `~/.local/bin`.
- Linux: extracts the AppImage into `~/.local/share/shioyek-app`, which works without FUSE. It adds the `shioyek` command to `~/.local/bin` and a "Shioyek" entry to the app menu.

To update, run the same command again. Manual downloads are on [Releases](../../releases). The `latest` prerelease is rebuilt on every push to `main`.

## License

GPL-3.0, same as upstream. See `LICENSE`.
