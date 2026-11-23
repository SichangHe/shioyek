#!/bin/sh
# Copy Sioyek's config and database into Shioyek's directories.
# Existing Shioyek directories are kept as *.bak-TIMESTAMP.
# Usage: curl -fsSL https://raw.githubusercontent.com/SichangHe/shioyek/main/migrate_from_sioyek.sh | sh
set -eu

case "$(uname -s)" in
    Darwin) DATA="$HOME/Library/Application Support" ;;
    Linux) DATA="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
    *) echo "error: only macOS and Linux are supported" >&2; exit 1 ;;
esac
STAMP="$(date +%Y%m%d%H%M%S)"

migrate() { # parent dir
    [ -d "$1/sioyek" ] || { echo "skip: no $1/sioyek"; return; }
    [ -e "$1/shioyek" ] && mv "$1/shioyek" "$1/shioyek.bak-$STAMP" && echo "backup: $1/shioyek.bak-$STAMP"
    cp -R "$1/sioyek" "$1/shioyek"
    echo "copied: $1/sioyek -> $1/shioyek"
}

pgrep -x shioyek >/dev/null 2>&1 && { echo "error: quit shioyek first" >&2; exit 1; }
migrate "$HOME/.config"
migrate "$DATA"
