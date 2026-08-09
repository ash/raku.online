#!/bin/sh
# Pull the book in from the rakupp repo, which is where it is written.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but rakupp/docs/book stays the source of
# truth. The PDF comes across too: the site links it for download rather than
# regenerating it, because building it needs pandoc and a TeX engine and the
# published artifact must be the same one the repo shipped.
#
# Re-run this and rebuild whenever a chapter changes there.
set -e
SRC="${1:-${RAKUPP_SRC:-$HOME/raku++}}/docs/book"
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HERE/src/pages"

[ -d "$SRC/ch" ] || { echo "no book sources at $SRC/ch (pass the rakupp checkout as \$1)" >&2; exit 1; }

mkdir -p "$DEST"
rm -f "$DEST"/*.md
cp "$SRC"/ch/*.md "$DEST/"
echo "synced $(ls "$DEST"/*.md | wc -l | tr -d ' ') chapters from $SRC/ch"

PDF="$SRC/Raku++-Internals.pdf"
if [ -f "$PDF" ]; then
    cp "$PDF" "$HERE/src/"
    echo "synced the PDF ($(du -h "$PDF" | cut -f1))"
else
    echo "warning: no PDF at $PDF — build it with: rakupp docs/book/build.raku" >&2
fi
