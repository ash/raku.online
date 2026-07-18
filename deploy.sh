#!/bin/sh
# Deploy www/ to the raku.online server (an sshfs mount by default).
# Usage: ./deploy.sh [destination-www-dir]
set -e

DEST="${1:-/Users/ash/sshfs/raku.online/raku.online/www}"
SRC="$(dirname "$0")/www"

[ -d "$DEST" ] || { echo "destination not found (sshfs not mounted?): $DEST" >&2; exit 1; }

# Stamp the cache-busting tag with a hash over every versioned asset, so
# browsers refetch worker.js / rakujs.{js,wasm} / examples.js exactly when any
# of them changes (examples can change without a new interpreter build).
# Edits www/index.html in place — commit it so the repo mirrors the live site.
TAG=$(cat "$SRC"/rakujs.wasm "$SRC"/rakujs.js "$SRC"/examples.js "$SRC"/worker.js | md5 -q | cut -c1-8)
sed -i '' -E "s/\?v=[0-9a-f]{8}/?v=$TAG/g" "$SRC"/index.html
echo "cache tag: ?v=$TAG"

cp "$SRC"/index.html "$SRC"/worker.js "$SRC"/examples.js \
   "$SRC"/rakujs.js "$SRC"/rakujs.wasm "$DEST"/

# macOS cp over sshfs leaves AppleDouble files, which the server would serve.
rm -f "$DEST"/._*

echo "deployed to $DEST:"
ls -l "$DEST"
