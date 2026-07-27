#!/bin/sh
# Deploy www/ to a raku.online mirror (an sshfs mount by default).
# Usage: ./deploy.sh [destination-www-dir]
#
# GitHub Pages is what serves raku.online: the workflow uploads www/ verbatim on
# every push to main and needs nothing from here. This is for a second host.
#
# Run ./build.sh first — this copies, it does not generate. The tour and spec are
# built from sites/ into www/tour and www/spec there.
set -e

DEST="${1:-/Users/ash/sshfs/raku.online/raku.online/www}"
SRC="$(cd "$(dirname "$0")" && pwd)/www"

[ -d "$DEST" ] || { echo "destination not found (sshfs not mounted?): $DEST" >&2; exit 1; }

# Stamp the cache-busting tag with a hash over every versioned asset, so
# browsers refetch worker.js / rakujs.{js,wasm} / examples.js exactly when any
# of them changes (examples can change without a new interpreter build).
# Edits the files in place — commit them so the repo mirrors the live site.
#
# The playground's own assets moved under play/ when the site went to one origin;
# rakujs.{js,wasm} stayed at the root because raku.js resolves them relative to
# itself and other people's pages load it from there.
TAG=$(cat "$SRC"/rakujs.wasm "$SRC"/rakujs.js "$SRC"/play/examples.js "$SRC"/play/worker.js \
      | md5 -q | cut -c1-8)
# play/index.html loads worker/examples with the tag; raku.js passes it to the
# engine it importScripts, so embedded editors also refetch on a new release.
sed -i '' -E "s/\?v=[0-9a-f]{8}/?v=$TAG/g" "$SRC"/play/index.html "$SRC"/raku.js
echo "cache tag: ?v=$TAG"

# The whole tree, not a file list: the site is several sub-sites deep now and any
# enumeration here would silently fall out of date the next time one is added.
if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude '.DS_Store' --exclude '._*' "$SRC"/ "$DEST"/
else
    rm -rf "$DEST"/*
    cp -R "$SRC"/. "$DEST"/
fi

# macOS cp over sshfs leaves AppleDouble files, which the server would serve.
find "$DEST" -name '._*' -delete
find "$DEST" -name '.DS_Store' -delete

# The three URLs other people's pages load directly. If a refactor ever moves
# them every embed in the wild breaks silently, so fail loudly here instead.
for f in raku.js rakujs.js rakujs.wasm; do
    [ -s "$DEST/$f" ] || { echo "FROZEN FILE MISSING AT DESTINATION: $f" >&2; exit 1; }
done

echo "deployed to $DEST"
