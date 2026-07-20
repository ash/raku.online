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
# index.html loads worker/examples with the tag; raku.js passes it to the
# engine it importScripts, so embedded editors also refetch on a new release.
sed -i '' -E "s/\?v=[0-9a-f]{8}/?v=$TAG/g" "$SRC"/index.html "$SRC"/raku.js
echo "cache tag: ?v=$TAG"

cp "$SRC"/index.html "$SRC"/worker.js "$SRC"/examples.js \
   "$SRC"/rakujs.js "$SRC"/rakujs.wasm "$SRC"/raku.js "$DEST"/
# Helper pages now live in their own dirs, served at /builder/ and /demo/.
cp -R "$SRC"/builder "$SRC"/demo "$DEST"/

# macOS cp over sshfs leaves AppleDouble files, which the server would serve.
# Also drop retired flat aliases if they linger on the server.
find "$DEST" -name '._*' -delete
rm -f "$DEST"/embed.js "$DEST"/embed-builder.html "$DEST"/embed-demo.html

echo "deployed to $DEST:"
ls -l "$DEST"
