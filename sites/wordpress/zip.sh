#!/bin/sh
# Build www/embed/wordpress/raku-snippets.zip — the Raku Snippets plugin that
# /embed/wordpress/ offers for download — from the rakupp repo.
#
#   ./zip.sh [path-to-rakupp-checkout]
#
# rakupp/editors/wordpress stays the source of truth (it is also what runs on
# andrewshitov.com); the zip is committed here because Pages publishes committed
# files and runs no build. Re-run this whenever the plugin changes there.
set -e
ROOT="${1:-${RAKUPP_SRC:-$HOME/raku++}}"
SRC="$ROOT/editors/wordpress/raku-snippets"
OUT="$(cd "$(dirname "$0")/../.." && pwd)/www/embed/wordpress/raku-snippets.zip"

[ -f "$SRC/raku-snippets.php" ] || { echo "no plugin at $SRC (pass the rakupp checkout as \$1)" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -R "$SRC" "$TMP/raku-snippets"
# Fixed timestamps, so an unchanged plugin rebuilds to a byte-identical zip.
find "$TMP/raku-snippets" -exec touch -t 202001010000 {} +
rm -f "$OUT"
( cd "$TMP" && zip -q -X -r "$OUT" raku-snippets )
echo "raku-snippets.zip <- $SRC"
