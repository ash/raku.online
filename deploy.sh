#!/bin/sh
# Deploy www/ to the raku.online server (an sshfs mount by default).
# Usage: ./deploy.sh [destination-www-dir]
set -e

DEST="${1:-/Users/ash/sshfs/raku.online/raku.online/www}"
SRC="$(dirname "$0")/www"

[ -d "$DEST" ] || { echo "destination not found (sshfs not mounted?): $DEST" >&2; exit 1; }

cp "$SRC"/index.html "$SRC"/worker.js "$SRC"/examples.js \
   "$SRC"/rakujs.js "$SRC"/rakujs.wasm "$DEST"/

# macOS cp over sshfs leaves AppleDouble files, which the server would serve.
rm -f "$DEST"/._*

echo "deployed to $DEST:"
ls -l "$DEST"
