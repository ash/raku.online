#!/bin/sh
# Build www/embed/excel/ — the Excel add-in behind =RAKU.EVAL formulas, as
# raku.online serves it — from the rakupp repo's bindings/spreadsheets.
#
#   ./sync.sh [path-to-rakupp-checkout]
#
# Pages publishes committed files and runs no build, so the add-in is built
# here and committed, like the WordPress plugin's zip. It is built with the
# site's OWN engine (www/rakujs.js, www/rakujs.wasm): /play/ and the add-in run
# the same build, and git stores the engine once, since the copy under
# embed/excel/ is the same blob. Run it after the engine in www/ is replaced
# (RELEASING.md, step 6), then commit www/. build.sh refuses to finish while
# the two engines differ.
#
# rakupp's release job builds the same add-in for the same address
# (rakujs-excel-<tag>.zip), for anyone serving it from somewhere else.
set -e
ROOT="${1:-${RAKUPP_SRC:-$HOME/raku++}}"
RAKUPP="${RAKUPP:-rakupp}"
WWW="$(cd "$(dirname "$0")/../.." && pwd)/www"
BUILD="$ROOT/bindings/spreadsheets/build.raku"

[ -f "$BUILD" ] || { echo "no $BUILD (pass the rakupp checkout as \$1)" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
"$RAKUPP" "$BUILD" --base=https://raku.online/embed/excel/ --rakujs="$WWW" --out="$TMP"
rm -rf "$WWW/embed/excel"
cp -R "$TMP/excel" "$WWW/embed/excel"
cmp -s "$WWW/rakujs.wasm" "$WWW/embed/excel/rakujs.wasm" \
    || { echo "embed/excel/rakujs.wasm is not www/rakujs.wasm" >&2; exit 1; }
echo "www/embed/excel <- $BUILD"
