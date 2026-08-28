#!/bin/sh
# Pull the showcase and live READMEs — and live/ADOPTIONS.md — in from the
# rakupp repo.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but rakupp/showcase and rakupp/live stay
# the source of truth. Re-run this and rebuild whenever a README changes there.
#
# raytracer is skipped by name: it is not part of the public repo (too slow to
# show), and it must not reach the site even from a checkout that has it locally.
set -e
ROOT="${1:-${RAKUPP_SRC:-$HOME/raku++}}"
DEST="$(cd "$(dirname "$0")" && pwd)/src"

[ -d "$ROOT/showcase" ] || { echo "no showcase at $ROOT/showcase (pass the rakupp checkout as \$1)" >&2; exit 1; }

mkdir -p "$DEST/showcase" "$DEST/live"
rm -f "$DEST/showcase"/*.md "$DEST/live"/*.md

cp "$ROOT/showcase/README.md" "$DEST/showcase/README.md"
for d in "$ROOT/showcase"/*/; do
    name="$(basename "$d")"
    case "$name" in
        raytracer) continue ;;
    esac
    [ -f "$d/README.md" ] && cp "$d/README.md" "$DEST/showcase/$name.md"
done

cp "$ROOT/live/README.md" "$DEST/live/README.md"
for d in "$ROOT/live"/*/; do
    name="$(basename "$d")"
    [ -f "$d/README.md" ] && cp "$d/README.md" "$DEST/live/$name.md"
done

# Not a live entry: the list of software that adopted Raku++ rather than the
# other way round. It is what /in-use/ and /in-use/adoptions/ are built from,
# so a row added in rakupp reaches the site through this same sync.
cp "$ROOT/live/ADOPTIONS.md" "$DEST/live/ADOPTIONS.md"

echo "synced $(ls "$DEST/showcase"/*.md | wc -l | tr -d ' ') showcase + $(ls "$DEST/live"/*.md | wc -l | tr -d ' ') live file(s) from $ROOT"
