#!/bin/sh
# Assemble www/ — the whole of raku.online — from the sources in this repo.
#
#   ./build.sh            build everything
#   ./build.sh tour       build one sub-site only
#
# The engine artifacts (raku.js, rakujs.js, rakujs.wasm) are committed at the
# root of www/ and are never generated here: other people's pages load
# https://raku.online/raku.js by that exact URL, and it resolves rakujs.js and
# rakujs.wasm relative to itself. Nothing may move them.
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
WWW="$ROOT/www"
RAKUPP="${RAKUPP:-rakupp}"

# The three files the outside world depends on. Checked after every build so a
# refactor cannot quietly break every embed in the wild.
FROZEN="raku.js rakujs.js rakujs.wasm"

build_theme() {
    echo "theme -> www/theme"
    rm -rf "$WWW/theme"
    mkdir -p "$WWW/theme"
    cp "$ROOT"/theme/* "$WWW/theme/"
}

build_tour() {
    echo "tour -> www/tour"
    ( cd "$ROOT/sites/tour" && "$RAKUPP" build.raku --clean )
    rm -rf "$WWW/tour"
    cp -R "$ROOT/sites/tour/out" "$WWW/tour"
}

build_spec() {
    echo "spec -> www/spec"
    ( cd "$ROOT/sites/spec" && "$RAKUPP" build.raku --clean && "$RAKUPP" rules.raku )
    rm -rf "$WWW/spec"
    cp -R "$ROOT/sites/spec/out" "$WWW/spec"
}

# Every /theme/ asset any page asks for must actually exist. The generators
# reference assets by name, so adding a <script> without adding the file ships
# a 404 that no page-existence check would catch.
check_theme_refs() {
    missing=0
    for a in $(grep -rho '/theme/[A-Za-z0-9._-]*' "$WWW" --include='*.html' | sort -u); do
        [ -s "$WWW$a" ] || { echo "missing asset: www$a" >&2; missing=1; }
    done
    [ "$missing" = 0 ] || exit 1
    echo "check: every referenced theme asset is present"
}

check_frozen() {
    for f in $FROZEN; do
        [ -s "$WWW/$f" ] || { echo "FROZEN FILE MISSING: www/$f" >&2; exit 1; }
    done
    echo "check: the frozen engine URLs are intact ($FROZEN)"
}

# No page may link to a sub-site's old root-absolute paths. Both generators take
# a base from their site.raku; this catches a regression in that plumbing.
check_no_stray_absolutes() {
    stray=$(grep -rhoE '(href|src)="/[a-z0-9-]+' "$WWW/tour" "$WWW/spec" --include='*.html' 2>/dev/null \
            | sed 's/.*="//' | sort -u \
            | grep -vE '^/(tour|spec|theme|play|rakupp|embed|builder|demo)$' || true)
    [ -z "$stray" ] || { echo "links escaping their base: $stray" >&2; exit 1; }
    echo "check: no sub-site link escapes its base"
}

case "${1:-all}" in
    theme) build_theme ;;
    tour)  build_tour ;;
    spec)  build_spec ;;
    all)   build_theme; build_tour; build_spec ;;
    *)     echo "usage: $0 [all|theme|tour|spec]" >&2; exit 2 ;;
esac

check_frozen
check_theme_refs
check_no_stray_absolutes
# JSON the client fetches carries URLs baked in at generation time, so a
# missing base here shows up only as a 404 when someone clicks a search hit.
check_json_urls() {
    bad=$(grep -ohE '"u":"/[a-z0-9-]+/' "$WWW"/spec/search-index.json "$WWW"/spec/rules/search-index.json 2>/dev/null \
          | sort -u | grep -v '^"u":"/spec/' || true)
    [ -z "$bad" ] || { echo "search index URLs missing their base: $bad" >&2; exit 1; }
    echo "check: search index URLs carry their base"
}
check_json_urls

echo "www/ assembled."
