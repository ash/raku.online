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
    # The bar names the engine version; take it from the binary that built the
    # site rather than a number kept in sync by hand.
    ver=$("$RAKUPP" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    [ -n "$ver" ] || { echo "could not read a version from '$RAKUPP --version'" >&2; exit 1; }
    sed -i '' "s/__RAKUPP_VERSION__/$ver/g" "$WWW/theme/shell.js"
    echo "       engine version in the bar: $ver"
}

build_tour() {
    echo "tour -> www/tour"
    ( cd "$ROOT/sites/tour" && "$RAKUPP" build.raku --clean )
    rm -rf "$WWW/tour"
    cp -R "$ROOT/sites/tour/out" "$WWW/tour"
}

build_faq() {
    echo "faq -> www/faq"
    ( cd "$ROOT/sites/faq" && "$RAKUPP" build.raku --clean )
    rm -rf "$WWW/faq"
    cp -R "$ROOT/sites/faq/out" "$WWW/faq"
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

# Every page must carry the site bar, or a section quietly becomes a dead end.
check_shell() {
    missing=""
    for page in "$WWW/index.html" "$WWW/play/index.html" "$WWW/drills/index.html" \
                "$WWW/rakupp/index.html" "$WWW/embed/index.html" \
                "$WWW/tour/index.html" "$WWW/spec/index.html" "$WWW/spec/rules/index.html" \
                "$WWW/faq/index.html"; do
        [ -f "$page" ] || { missing="$missing ${page#$WWW}(absent)"; continue; }
        grep -q 'theme/shell.js' "$page" || missing="$missing ${page#$WWW}"
    done
    [ -z "$missing" ] || { echo "pages without the site bar:$missing" >&2; exit 1; }
    echo "check: every section carries the site bar"
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
    stray=$(grep -rhoE '(href|src)="/[a-z0-9-]+' "$WWW/tour" "$WWW/spec" "$WWW/faq" --include='*.html' 2>/dev/null \
            | sed 's/.*="//' | sort -u \
            | grep -vE '^/(tour|spec|faq|theme|play|rakupp|embed|builder|demo)$' || true)
    [ -z "$stray" ] || { echo "links escaping their base: $stray" >&2; exit 1; }
    echo "check: no sub-site link escapes its base"
}

case "${1:-all}" in
    theme) build_theme ;;
    tour)  build_tour ;;
    spec)  build_spec ;;
    faq)   build_faq ;;
    all)   build_theme; build_tour; build_spec; build_faq ;;
    *)     echo "usage: $0 [all|theme|tour|spec|faq]" >&2; exit 2 ;;
esac

# The ?v= cache tag, hashed over every versioned engine asset, so browsers
# refetch worker.js / rakujs.{js,wasm} / examples.js exactly when one of them
# changes — examples can change without a new interpreter build.
#
# raku.js passes the tag to the engine it importScripts, so embedded editors on
# other people's sites refetch on a new release too. That is why raku.js is
# stamped alongside the playground's own page, and why this has to happen on
# every build rather than at publish time: what is committed must already be
# what gets served.
stamp_cache_tag() {
    tag=$(cat "$WWW"/rakujs.wasm "$WWW"/rakujs.js \
              "$WWW"/play/examples.js "$WWW"/play/worker.js | md5 -q | cut -c1-8)
    sed -i '' -E "s/\?v=[0-9a-f]{8}/?v=$tag/g" "$WWW"/play/index.html "$WWW"/raku.js
    echo "cache tag: ?v=$tag"

    # The drills ship their own JS and CSS and had no tag at all, so a returning
    # visitor kept running whatever they cached the first time. Their own hash,
    # since they change independently of the engine.
    dtag=$(cat "$WWW"/drills/js/*.js "$WWW"/drills/css/*.css "$WWW"/drills/data/*.js \
           | md5 -q | cut -c1-8)
    sed -i '' -E "s/\?v=[0-9a-f]{8}/?v=$dtag/g" "$WWW"/drills/index.html
    echo "drills cache tag: ?v=$dtag"

    # The shared theme, tagged once for the whole site. The generators used to
    # stamp /theme/ references with their own per-site version, so the identical
    # shell.js was fetched twice under two URLs — which defeats the point of
    # putting everything on one origin. Pages that are not generated had no tag
    # at all. One hash over theme/, applied to every page, fixes both.
    ttag=$(cat "$WWW"/theme/* | md5 -q | cut -c1-8)
    find "$WWW" -name '*.html' -print0 | xargs -0 sed -i '' -E \
        "s|(/theme/[A-Za-z0-9._-]+)(\?v=[0-9a-f]{8})?|\1?v=$ttag|g"
    echo "theme cache tag: ?v=$ttag"

    # raku.js as our own pages load it. The URL itself never changes — other
    # people's pages depend on the bare path — but ours can carry a tag so a new
    # embed script reaches our readers without waiting for a cache to expire.
    # Hashed after the stamping above, since that rewrites raku.js.
    rtag=$(md5 -q "$WWW"/raku.js | cut -c1-8)
    find "$WWW" -name '*.html' -print0 | xargs -0 sed -i '' -E \
        "s|(\"/raku\.js)(\?v=[0-9a-f]{8})?\"|\1?v=$rtag\"|g"
    echo "raku.js cache tag: ?v=$rtag"
}
stamp_cache_tag

# Links a script assembles at runtime are invisible to the HTML checks above,
# and they are where the base prefix keeps getting forgotten — the tour's
# Continue button and the spec's data fetches were both missed this way. Any
# absolute path built in theme JS must be prefixed with a published base.
check_runtime_urls() {
    # shell.js is exempt: the site bar spans the whole origin, so its links to
    # /play/, /tour/ and the rest are meant to be root-absolute.
    files=$(ls "$ROOT"/theme/*.js | grep -v '/shell\.js$')
    bad=$(grep -nE "(href|location\.href|fetch\()[^;]*['\"]/" $files \
          | grep -v '__SITE_BASE' | grep -v '__SEARCH_INDEX' | grep -v 'BASE *+' || true)
    [ -z "$bad" ] || {
        echo "absolute URLs built in theme JS without a base:" >&2
        echo "$bad" >&2
        exit 1
    }
    echo "check: runtime-built URLs carry a base"
}
check_runtime_urls

check_frozen
check_shell
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
