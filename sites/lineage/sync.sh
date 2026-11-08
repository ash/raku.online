#!/bin/sh
# Pull the report in from the rakupp repo, which is where it is written.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but
# rakupp/docs/dev/PERL6-FEATURES-IN-OTHER-LANGUAGES.md stays the source of
# truth. Re-run this and rebuild whenever it changes there: the build names
# every evidence entry whose link the new text no longer has.
set -e
SRC="${1:-${RAKUPP_SRC:-$HOME/raku++}}/docs/dev/PERL6-FEATURES-IN-OTHER-LANGUAGES.md"
DEST="$(cd "$(dirname "$0")" && pwd)/src/report.md"

[ -f "$SRC" ] || { echo "no report at $SRC (pass the rakupp checkout as \$1)" >&2; exit 1; }
cp "$SRC" "$DEST"
echo "synced $(wc -w < "$DEST" | tr -d ' ') words from $SRC"
