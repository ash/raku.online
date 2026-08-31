#!/bin/sh
# Pull the cookbook in from the rakupp repo, which is where it is written.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# raku.online keeps a copy so the site is buildable on its own (Pages publishes
# committed files and runs no build), but rakupp/docs/cookbook stays the source
# of truth. Re-run this and rebuild whenever a recipe changes there.
#
# Two kinds of file come across. The recipes themselves are the .md at the top
# of docs/cookbook. Each also has a directory of programs beside it, and those
# are flattened into src/files: on the site every recipe's programs live in one
# /cookbook/files/, so their basenames have to be unique across the whole
# cookbook — which this checks, rather than letting one silently overwrite
# another.
set -e
SRC="${1:-${RAKUPP_SRC:-$HOME/raku++}}/docs/cookbook"
HERE="$(cd "$(dirname "$0")" && pwd)"
PAGES="$HERE/src/pages"
FILES="$HERE/src/files"

[ -d "$SRC" ] || { echo "no cookbook sources at $SRC (pass the rakupp checkout as \$1)" >&2; exit 1; }
mkdir -p "$PAGES" "$FILES"
rm -f "$PAGES"/*.md "$FILES"/*

for f in "$SRC"/*.md; do
    case "$(basename "$f")" in
        README.md) continue ;;      # the index is generated from the recipes
    esac
    cp "$f" "$PAGES/"
done

for d in "$SRC"/*/; do
    [ -d "$d" ] || continue
    for f in "$d"*; do
        [ -f "$f" ] || continue
        name="$(basename "$f")"
        if [ -e "$FILES/$name" ]; then
            echo "two recipes ship a program called $name; rename one" >&2
            exit 1
        fi
        cp "$f" "$FILES/"
    done
done

echo "synced $(ls "$PAGES"/*.md 2>/dev/null | wc -l | tr -d ' ') recipe(s) and $(ls "$FILES" 2>/dev/null | wc -l | tr -d ' ') program(s) from $SRC"
