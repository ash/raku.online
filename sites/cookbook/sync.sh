#!/bin/sh
# Pull the cookbook in from the rakupp repo, which is where it is written.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but rakupp/docs/cookbook stays the source
# of truth. Re-run this and rebuild whenever a recipe changes there.
#
# Only the prose comes across. The recipes themselves are the .md at the top of
# docs/cookbook; the programs each one ships stay in the rakupp repo, and the
# pages link to them there rather than to a copy on this site — one file, under
# version control, instead of two that drift. What is copied across about them
# is their names: src/programs.txt lists every program the cookbook has, and
# build.raku checks each link against it, so a renamed or deleted file is caught
# here rather than becoming a GitHub 404 for a reader.
set -e
SRC="${1:-${RAKUPP_SRC:-$HOME/raku++}}/docs/cookbook"
HERE="$(cd "$(dirname "$0")" && pwd)"
PAGES="$HERE/src/pages"
MANIFEST="$HERE/src/programs.txt"

[ -d "$SRC" ] || { echo "no cookbook sources at $SRC (pass the rakupp checkout as \$1)" >&2; exit 1; }
mkdir -p "$PAGES"
rm -f "$PAGES"/*.md
rm -rf "$HERE/src/files"   # the programs used to be copied here; they are not any more

for f in "$SRC"/*.md; do
    case "$(basename "$f")" in
        README.md) continue ;;      # the index is generated from the recipes
    esac
    cp "$f" "$PAGES/"
done

: > "$MANIFEST"
for d in "$SRC"/*/; do
    [ -d "$d" ] || continue
    dir="$(basename "$d")"
    for f in "$d"*; do
        [ -f "$f" ] || continue
        echo "$dir/$(basename "$f")" >> "$MANIFEST"
    done
done
LC_ALL=C sort -o "$MANIFEST" "$MANIFEST"

echo "synced $(ls "$PAGES"/*.md 2>/dev/null | wc -l | tr -d ' ') recipe(s) from $SRC" \
     "($(wc -l < "$MANIFEST" | tr -d ' ') program(s) listed, none copied)"
