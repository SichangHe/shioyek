#!/bin/sh
# Install or update Shioyek from the latest GitHub build.
# Usage: curl -fsSL https://raw.githubusercontent.com/SichangHe/shioyek/main/install.sh | sh
set -eu

REPO="SichangHe/shioyek"
TAG="${SHIOYEK_TAG:-latest}"
BASE="https://github.com/$REPO/releases/download/$TAG"
BIN_DIR="$HOME/.local/bin"

say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || die "curl is required"

TMP="$(mktemp -d)"
cleanup() {
    [ -n "${MNT:-}" ] && hdiutil detach -quiet "$MNT" 2>/dev/null || true
    rm -rf "$TMP"
}
trap cleanup EXIT INT TERM

fetch() { # url dest
    say "downloading $1"
    curl -fL --progress-bar -o "$2" "$1" || die "download failed: $1"
}

install_linux() {
    [ "$(uname -m)" = x86_64 ] || die "only x86_64 Linux builds exist (got $(uname -m))"
    DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
    APP_DIR="$DATA/shioyek-app"

    fetch "$BASE/shioyek-linux-x86_64.AppImage" "$TMP/shioyek.AppImage"
    chmod +x "$TMP/shioyek.AppImage"
    # extract so no FUSE is needed
    (cd "$TMP" && ./shioyek.AppImage --appimage-extract >/dev/null) || die "could not extract AppImage"

    rm -rf "$APP_DIR"
    mkdir -p "$(dirname "$APP_DIR")" "$BIN_DIR" "$DATA/applications"
    mv "$TMP/squashfs-root" "$APP_DIR"

    cat > "$BIN_DIR/shioyek" <<WRAP
#!/bin/sh
exec "$APP_DIR/AppRun" "\$@"
WRAP
    chmod +x "$BIN_DIR/shioyek"

    ICON="$(find "$APP_DIR" -maxdepth 1 -name 'shioyek*.png' | head -n 1)"
    cat > "$DATA/applications/shioyek.desktop" <<DESK
[Desktop Entry]
Name=Shioyek
Comment=PDF viewer for reading research papers and technical books
Exec=$BIN_DIR/shioyek %f
Icon=${ICON:-shioyek-icon-linux}
Terminal=false
Type=Application
Categories=Office;Viewer;
MimeType=application/pdf;
StartupWMClass=shioyek
DESK
    command -v update-desktop-database >/dev/null 2>&1 &&
        update-desktop-database "$DATA/applications" >/dev/null 2>&1 || true

    say "installed: $BIN_DIR/shioyek (app menu entry: Shioyek)"
}

install_mac() {
    case "$(uname -m)" in
        arm64) ARCH=arm64 ;;
        x86_64) ARCH=x86_64 ;;
        *) die "unsupported Mac architecture $(uname -m)" ;;
    esac
    fetch "$BASE/shioyek-mac-$ARCH.dmg" "$TMP/shioyek.dmg"

    MNT="$TMP/mnt"
    mkdir -p "$MNT"
    hdiutil attach -quiet -nobrowse -readonly -mountpoint "$MNT" "$TMP/shioyek.dmg" || die "could not open dmg"

    DEST=/Applications
    [ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; }
    osascript -e 'quit app "shioyek"' >/dev/null 2>&1 || true
    rm -rf "$DEST/shioyek.app"
    ditto "$MNT/shioyek.app" "$DEST/shioyek.app"
    hdiutil detach -quiet "$MNT" || true
    MNT=""

    # unsigned app: remove the download quarantine so macOS lets it open
    xattr -dr com.apple.quarantine "$DEST/shioyek.app" 2>/dev/null || true

    mkdir -p "$BIN_DIR"
    ln -sf "$DEST/shioyek.app/Contents/MacOS/shioyek" "$BIN_DIR/shioyek"

    say "installed: $DEST/shioyek.app (command: $BIN_DIR/shioyek)"
}

case "$(uname -s)" in
    Linux) install_linux ;;
    Darwin) install_mac ;;
    *) die "only macOS and Linux are supported" ;;
esac

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) say "note: add $BIN_DIR to your PATH to run 'shioyek' from a terminal" ;;
esac
say "rerun this command any time to update"
