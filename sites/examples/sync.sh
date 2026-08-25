#!/bin/sh
# Pull the example programs in from the rakupp repo, which is where they live.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but rakupp/examples stays the source of
# truth. Re-run this and rebuild whenever a program or its README changes there.
#
# The captured outputs under src/outputs/ are NOT touched here: they are made
# by `rakupp build.raku --capture`, which runs every program for real.
set -e
SRC="${1:-${RAKUPP_SRC:-$HOME/raku++}}/examples"
DEST="$(cd "$(dirname "$0")" && pwd)/src/programs"

[ -d "$SRC" ] || { echo "no examples at $SRC (pass the rakupp checkout as \$1)" >&2; exit 1; }
mkdir -p "$DEST"
rm -f "$DEST"/*.raku "$DEST"/README.md
for f in "$SRC"/*.raku; do
    cp "$f" "$DEST/"
done
cp "$SRC/README.md" "$DEST/"
echo "synced $(ls "$DEST"/*.raku | wc -l | tr -d ' ') programs + README from $SRC"
