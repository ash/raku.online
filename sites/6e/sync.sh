#!/bin/sh
# Pull the 6.e article in from the rakupp repo, which is where it is written.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but rakupp/docs/guide/LANGUAGE-6E.md stays
# the source of truth. Re-run this and rebuild whenever it changes there.
set -e
SRC="${1:-${RAKUPP_SRC:-$HOME/raku++}}/docs/guide/LANGUAGE-6E.md"
DEST="$(cd "$(dirname "$0")" && pwd)/src/page.md"

[ -f "$SRC" ] || { echo "no article at $SRC (pass the rakupp checkout as \$1)" >&2; exit 1; }
cp "$SRC" "$DEST"
echo "synced $(wc -l < "$DEST" | tr -d ' ') lines from $SRC"
