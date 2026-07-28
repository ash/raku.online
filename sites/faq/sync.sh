#!/bin/sh
# Pull the FAQ articles in from the rakupp repo, which is where they are written.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but rakupp/docs/faq stays the source of
# truth. Re-run this and rebuild whenever an article changes there.
set -e
SRC="${1:-${RAKUPP_SRC:-$HOME/raku++}}/docs/faq"
DEST="$(cd "$(dirname "$0")" && pwd)/src/pages"

[ -d "$SRC" ] || { echo "no FAQ sources at $SRC (pass the rakupp checkout as \$1)" >&2; exit 1; }
mkdir -p "$DEST"
rm -f "$DEST"/*.md
for f in "$SRC"/*.md; do
    case "$(basename "$f")" in
        README.md) continue ;;      # the index is generated from the articles
    esac
    cp "$f" "$DEST/"
done
echo "synced $(ls "$DEST"/*.md | wc -l | tr -d ' ') articles from $SRC"
